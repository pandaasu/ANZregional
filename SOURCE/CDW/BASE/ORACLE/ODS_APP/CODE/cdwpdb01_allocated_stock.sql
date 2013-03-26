create or replace package cdwpdb01_allocated_stock as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : cdwpdb01_allocated_stock
 Owner   : site_app

 Description
 -----------
 Allocated Stock data for Plant databases - to feed pPlan

 1. PAR_ACTION (MANDATORY)

    *SNACK - extract and send Allocated stock data for MCA and SCO Plant databases
    *ALL - extract and send Allocated stock data for all assigned Plant Databases


 YYYY/MM   Author             Description
 -------   -----------------  -----------
 2008/02   Scott R. Harding   Created     
 2008/02   Linden Glen        Modified for multi segment use
                              Modified to send file to MCA and SCO 
 2012/12   Trevor Keon        Removed send to SCO as part of Plant DB decomission 
 
*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2);

end cdwpdb01_allocated_stock;
/

/****************/
/* Package Body */
/****************/
create or replace package body cdwpdb01_allocated_stock as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure execute_extract(par_interface in varchar2,
                             par_segment in varchar2);


   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameters
      /*-*/
      if (upper(par_action) != '*SNACK' and 
          upper(par_action) != '*ALL') then
         raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL or *SNACK');
      end if;

      /*-*/
      /* Execute extract routines
      /*-*/
      if upper(par_action) = '*ALL' or upper(par_action) = '*SNACK' then
         execute_extract('CDWPDB01.5','01'); -- MCA/Ballarat
--         execute_extract('CDWPDB01.6','01'); -- SCO/Scoresby       T.K [20/12/2012] - Removed SCO call due to server decomissioning (WO#453241) 
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CDWPDB01 ALLOCATED STOCK - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;


   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_extract(par_interface in varchar2,
                             par_segment in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_start boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_allocated_stock is
        SELECT   company_code, 
                 bus_sgmnt_code, 
                 plant_code, 
                 matl_code, 
                 matl_desc,
                 to_char(SUM(confirmed_qty),'fm0000000000.00000') AS confirmed_qty,
                 (SELECT to_char(mars_week)
                    FROM mars_date_dim
                   WHERE TRUNC (SYSDATE, 'DD') = calendar_date) AS mars_week,
                 to_char(SYSDATE,'yyyymmddhh24miss') AS TIMESTAMP
            FROM (
                  -- Select Australia Snack Sales Orders and Purchase Orders that are Outstanding (i.e. No Delivery created).
                  -- Note: This query does not include Sales Orders and Purchase Orders created today.
                  SELECT a.company_code AS company_code,
                         b.bus_sgmnt_code AS bus_sgmnt_code,
                         a.plant_code AS plant_code, b.matl_code AS matl_code,
                         b.matl_desc_en AS matl_desc, a.base_uom_qty AS confirmed_qty
                    FROM outstanding_order_fact a, matl_dim b
                   WHERE a.company_code = '147'
                     AND a.creatn_date >= TRUNC (SYSDATE - 14, 'DD')
                     AND a.matl_code = b.matl_code
                     AND b.bus_sgmnt_code = par_segment
                     AND a.doc_xactn_type_code <> '3'            -- Exclude Deliveries
                  UNION ALL
                  -- Select Australia Snack Deliveries that are Outstanding (i.e. No Invoice created), and are not yet Picked Confirmed.
                  SELECT a.company_code AS company_code,
                         b.bus_sgmnt_code AS bus_sgmnt_code,
                         a.plant_code AS plant_code, b.matl_code AS matl_code,
                         b.matl_desc_en AS matl_desc,
                         a.base_uom_dlvry_qty AS confirmed_qty
                    FROM dlvry_fact a, matl_dim b
                   WHERE a.company_code = '147'
                     AND a.creatn_date >= TRUNC (SYSDATE - 14, 'DD')
                     AND a.matl_code = b.matl_code
                     AND b.bus_sgmnt_code = par_segment
                     AND a.dlvry_line_status = 'OUTSTANDING'
                     AND a.dlvry_procg_stage = 'REQUEST')
        GROUP BY company_code, bus_sgmnt_code, plant_code, matl_code, matl_desc;
      rec_allocated_stock  csr_allocated_stock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_start := true;


      /*-*/
      /* Open Cursor for output
      /*-*/
      open csr_allocated_stock;
      loop
         fetch csr_allocated_stock into rec_allocated_stock;
         if (csr_allocated_stock%notfound) then
            exit;
         end if;

         /*-*/
         /* Create Outbound Interface if record(s) exist
         /*-*/
         if (var_start) then

            var_instance := lics_outbound_loader.create_interface(par_interface,null,par_interface || '.dat');

            var_start := false;

         end if;

         /*-*/
         /* Append Data Lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          rpad(to_char(nvl(rec_allocated_stock.company_code,' ')),6, ' ') ||   
                                          rpad(to_char(nvl(rec_allocated_stock.bus_sgmnt_code,' ')),4, ' ') ||   
                                          rpad(to_char(nvl(rec_allocated_stock.plant_code,' ')),4, ' ') ||   
                                          rpad(to_char(nvl(rec_allocated_stock.matl_code,' ')),18, ' ') ||    
                                          rpad(to_char(nvl(rec_allocated_stock.matl_desc,' ')),40, ' ') ||  
                                          rpad(to_char(nvl(rec_allocated_stock.confirmed_qty,' ')),16, ' ') ||   
                                          rpad(to_char(nvl(rec_allocated_stock.mars_week,' ')),7, ' ') ||  
                                          rpad(to_char(nvl(rec_allocated_stock.timestamp,' ')),16, ' '));   
      end loop;
      close csr_allocated_stock;

      /*-*/
      /* Finalise Interface
      /*-*/
      if lics_outbound_loader.is_created = true then
         lics_outbound_loader.finalise_interface;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_extract;

end cdwpdb01_allocated_stock;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym cdwpdb01_allocated_stock for ods_app.cdwpdb01_allocated_stock;
grant execute on cdwpdb01_allocated_stock to public;

create or replace package ladims01_material as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : ladims01_material
 Owner   : site_app

 Description
 -----------
 Material Master Data

 1. PAR_HISTORY (OPTIONAL)

    ## - Number of days changes to extract
    0 - Full extract (default)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/02   Linden Glen    Created

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in number default 0);

end ladims01_material;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladims01_material as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_history in number default 0) is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_instance number(15,0);
      var_start boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_matl_master is
         select a.sap_material_code as sap_material_code,
                a.bds_material_desc_zh as material_desc_ch, 
                a.material_type as material_type,
                a.base_uom as base_uom,
                a.xplant_status as xplant_status,
                b.special_procurement_type as special_procurement_type,
                b.abc_indctr as abc_indctr,
                nvl(to_char(a.creatn_date,'yyyymmdd'),'19000101') as creatn_date
         from bds_material_hdr a,
              bds_material_plant_hdr b
         where a.sap_material_code = b.sap_material_code
           and a.bds_lads_status = '1'
           and a.bds_lads_date >= sysdate - var_history
           and b.plant_code = 'CN02';
      rec_matl_master  csr_matl_master%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_start := true;

      /*-*/
      /* Define number of days to extract
      /*-*/
      if (par_history = 0) then
         var_history := 99999;
      else
         var_history := par_history;
      end if;

      /*-*/
      /* Open Cursor for output
      /*-*/
      open csr_matl_master;
      loop
         fetch csr_matl_master into rec_matl_master;
         if (csr_matl_master%notfound) then
            exit;
         end if;

         /*-*/
         /* Create Outbound Interface if record(s) exist
         /*-*/
         if (var_start) then

            var_instance := lics_outbound_loader.create_interface('LADIMS01');

            var_start := false;

         end if;

         /*-*/
         /* Append Data Lines
         /*-*/
         lics_outbound_loader.append_data(rpad(to_char(nvl(rec_matl_master.sap_material_code,' ')),18, ' ') ||
                                          nvl(rec_matl_master.material_desc_ch,' ')||rpad(' ',40-length(nvl(rec_matl_master.material_desc_ch,' ')),' ') ||
                                          rpad(to_char(nvl(rec_matl_master.material_type,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.base_uom,' ')),3, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.xplant_status,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.special_procurement_type,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.abc_indctr,' ')),1, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.creatn_date,' ')),8, ' '));

      end loop;
      close csr_matl_master;

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
         raise_application_error(-20000, 'FATAL ERROR - LADIMS01 MATERIAL - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladims01_material;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladims01_material for site_app.ladims01_material;
grant execute on ladims01_material to public;

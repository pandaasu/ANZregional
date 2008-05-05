create or replace package ladcad04_order_summary as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : ladcad04_order_summary
 Owner   : site_app

 Description
 -----------
 Order Summary Data

 1. PAR_HISTORY (OPTIONAL)

    ## - Number of days changes to extract (default : 7)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/01   Linden Glen    Created
 2008/01   Linden Glen    Added data check to stop empty interfaces
 2008/02   Linden Glen    Added NIV values

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in number default 7);

end ladcad04_order_summary;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladcad04_order_summary as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_history in number default 7) is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_start boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_order_summary is
         select a.ord_doc_num as ord_doc_num,
                a.ord_doc_line_num as ord_doc_line_num,
                a.ord_lin_status as ord_lin_status,
                a.sap_order_type_code as sap_order_type_code,
                a.sap_doc_currcy_code as sap_doc_currcy_code,
                a.sap_sold_to_cust_code as sap_sold_to_cust_code,
                a.sap_bill_to_cust_code as sap_bill_to_cust_code,
                a.sap_ship_to_cust_code as sap_ship_to_cust_code,
                a.sap_plant_code as sap_plant_code,
                a.sap_material_code as sap_material_code,
                a.sap_ord_qty_uom_code as sap_ord_qty_uom_code,
                to_char(a.creation_date,'yyyymmdd') as ord_creation_date,
                to_char(a.agr_date,'yyyymmdd') as agreed_del_date,
                to_char(a.sch_date,'yyyymmdd') as scheduled_del_date,
                to_char(a.del_date,'yyyymmdd') as del_date,
                to_char(a.pod_date,'yyyymmdd') as pod_date,
                to_char(a.ord_qty,'fm0000000000.00000') as ord_qty,
                to_char(a.del_qty,'fm0000000000.00000') as del_qty,
                to_char(a.pod_qty,'fm0000000000.00000') as pod_qty,
                to_char(a.ord_niv,'fm0000000000.00000') as ord_niv,
                to_char(a.del_niv,'fm0000000000.00000') as del_niv,
                to_char(a.pod_niv,'fm0000000000.00000') as pod_niv
         from order_fact a
         where a.sap_company_code in ('135','234')
           and a.ord_lin_status in ('*ORD','*DEL','*POD','*INV')
           and (trunc(a.ord_trn_date) >= trunc(sysdate) - par_history or
                trunc(a.del_trn_date) >= trunc(sysdate) - par_history or
                trunc(a.pod_trn_date) >= trunc(sysdate) - par_history);
      rec_order_summary  csr_order_summary%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameters
      /*-*/
      if (par_history < 1) then 
         raise_application_error(-20000, 'History parameter (' || par_history || ') cannot be less than 1');
      end if;

      /*-*/
      /* Initialise variables
      /*-*/
      var_start := true;

      /*-*/
      /* Open Cursor for output
      /*-*/
      open csr_order_summary;
      loop
         fetch csr_order_summary into rec_order_summary;
         if (csr_order_summary%notfound) then
            exit;
         end if;

         /*-*/
         /* Create Outbound Interface if record(s) exist
         /*-*/
         if (var_start) then

            var_instance := lics_outbound_loader.create_interface('LADCAD04',null,'LADCAD04.dat');

            var_start := false;

         end if;

         /*-*/
         /* Append Data Lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          rpad(to_char(nvl(rec_order_summary.ord_doc_num,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.ord_doc_line_num,' ')),6, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.ord_lin_status,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.sap_order_type_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.sap_doc_currcy_code,' ')),5, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.sap_sold_to_cust_code,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.sap_bill_to_cust_code,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.sap_ship_to_cust_code,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.sap_plant_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.sap_material_code,' ')),18, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.sap_ord_qty_uom_code,' ')),3, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.ord_creation_date,' ')),8, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.agreed_del_date,' ')),8, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.scheduled_del_date,' ')),8, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.del_date,' ')),8, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.pod_date,' ')),8, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.ord_qty,' ')),16, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.del_qty,' ')),16, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.pod_qty,' ')),16, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.ord_niv,' ')),16, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.del_niv,' ')),16, ' ') ||
                                          rpad(to_char(nvl(rec_order_summary.pod_niv,' ')),16, ' '));

      end loop;
      close csr_order_summary;

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
         raise_application_error(-20000, 'FATAL ERROR - LADCAD04 ORDER SUMMARY - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladcad04_order_summary;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladcad04_order_summary for site_app.ladcad04_order_summary;
grant execute on ladcad04_order_summary to public;

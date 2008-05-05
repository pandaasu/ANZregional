create or replace package ladcad02_price_list as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : ladcad02_price_list
 Owner   : site_app

 Description
 -----------
 Price List Data


 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/01   Linden Glen    Created
 2008/01   Linden Glen    Added data check to stop empty interfaces

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ladcad02_price_list;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladcad02_price_list as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_start boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_price_master is
         select b.kschl as price_list_type,
                a.vkorg as sap_company_code,
                a.matnr as sap_material_code,
                b.konwa as price_list_currcy,
                b.kmein as uom,
                a.datab as eff_start_date,
                a.datbi as eff_end_date,
                to_char(b.kbetr,'fm00000.00000') as list_price
         from lads_prc_lst_hdr a,
              lads_prc_lst_det b
         where a.vakey = b.vakey
           and a.kschl = b.kschl
           and a.datab = b.datab
           and a.knumh = b.knumh
           and a.vkorg = '135'
           and a.kschl in ('PR00');
      rec_price_master  csr_price_master%rowtype;

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
      open csr_price_master;
      loop
         fetch csr_price_master into rec_price_master;
         if (csr_price_master%notfound) then
            exit;
         end if;

         /*-*/
         /* Create Outbound Interface if record(s) exist
         /*-*/
         if (var_start) then

            var_instance := lics_outbound_loader.create_interface('LADCAD02',null,'LADCAD02.dat');

            var_start := false;

         end if;

         /*-*/
         /* Append Data Lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          rpad(to_char(nvl(rec_price_master.price_list_type,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_price_master.sap_company_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_price_master.sap_material_code,' ')),18, ' ') ||
                                          rpad(to_char(nvl(rec_price_master.price_list_currcy,' ')),5, ' ') ||
                                          rpad(to_char(nvl(rec_price_master.uom,' ')),3, ' ') ||
                                          rpad(to_char(nvl(rec_price_master.eff_start_date,' ')),8, ' ') ||
                                          rpad(to_char(nvl(rec_price_master.eff_end_date,' ')),8, ' ') ||
                                          rpad(to_char(nvl(rec_price_master.list_price,' ')),11, ' '));

      end loop;
      close csr_price_master;

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
         raise_application_error(-20000, 'FATAL ERROR - LADCAD02 PRICE LIST - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladcad02_price_list;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladcad02_price_list for site_app.ladcad02_price_list;
grant execute on ladcad02_price_list to public;

/******************/
/* Package Header */
/******************/
create or replace package efxsbw06_dis_std_itm_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxsbw06_dis_std_itm_extract
    Owner   : iface_app

    Description
    -----------
    Display Standard Item Extract - EFEX to SAP BW

    This package extracts the Efex display standard items and sends the extract file
    to the SAP BW environment.
    The ICS interface EFXSBW06 has been created for this purpose.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/10   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_sales_org_code in varchar2,
                     par_dstbn_chnl_code in varchar2,
                     par_division_code in varchar2,
                     par_company_code in varchar2);

end efxsbw06_dis_std_itm_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxsbw06_dis_std_itm_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_market_id constant number := 4;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_sales_org_code in varchar2,
                     par_dstbn_chnl_code in varchar2,
                     par_division_code in varchar2,
                     par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_start boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(t01.display_standard_id) as display_standard_id,
                to_char(t01.display_item_id) as display_item_id
           from display_standard_items t01;
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_start := true;

      /*-*/
      /* Open cursor for output
      /*-*/
      open csr_extract;
      loop
         fetch csr_extract into rcd_extract;
         if csr_extract%notfound then
            exit;
         end if;

         /*-*/
         /* Create outbound interface if record(s) exist
         /*-*/
         if (var_start) then
            var_instance := lics_outbound_loader.create_interface('EFXSBW06',null,'EFEX_DIS_STD_ITM_EXTRACT.DAT.'||to_char(sysdate,'yyyymmddhh24miss'));
            var_start := false;
         end if;

         /*-*/
         /* Append data lines when required
         /*-*/
         lics_outbound_loader.append_data('"'||replace(par_sales_org_code,'"','""')||'";'||
                                          '"'||replace(par_dstbn_chnl_code,'"','""')||'";'||
                                          '"'||replace(par_division_code,'"','""')||'";'||
                                          '"'||replace(par_company_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.display_standard_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.display_item_id,'"','""')||'"');

      end loop;
      close csr_extract;

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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;


         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - EFXSBW06 EFEX_DIS_STD_ITM_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxsbw06_dis_std_itm_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxsbw06_dis_std_itm_extract for iface_app.efxsbw06_dis_std_itm_extract;
grant execute on efxsbw06_dis_std_itm_extract to public;

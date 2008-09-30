/******************/
/* Package Header */
/******************/
create or replace package efxsbw08_display_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxsbw08_display_extract
    Owner   : iface_app

    Description
    -----------
    Display Extract - EFEX to SAP BW

    This package extracts the Efex displays that have been modified within the last
    history number of days and sends the extract file to the SAP BW environment.
    The ICS interface EFXSBW08 has been created for this purpose.

    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

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
                     par_company_code in varchar2,
                     par_history in varchar2 default 0);

end efxsbw08_display_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxsbw08_display_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_sales_org_code in varchar2,
                     par_dstbn_chnl_code in varchar2,
                     par_division_code in varchar2,
                     par_company_code in varchar2,
                     par_history in varchar2 default 0) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_history number;
      var_instance number(15,0);
      var_start boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(t01.customer_id) as customer_id,
                to_char(t01.display_item_id) as display_item_id,
                to_char(t01.user_id) as user_id,
                to_char(t01.call_date,'yyyymmdd') as call_date,
                t01.display_in_store as display_in_store
           from display_distribution t01
          where (t01.user_id, t01.call_date) in (select user_id, call_date from call where trunc(t01.modified_date) >= trunc(sysdate) - var_history);
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
      /* Define number of days to extract
      /*-*/
      if (par_history = 0) then
         var_history := 99999;
      else
         var_history := par_history;
      end if;

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
            var_instance := lics_outbound_loader.create_interface('EFXSBW08',null,'EFEX_DISPLAY_EXTRACT.DAT.'||to_char(sysdate,'yyyymmddhh24miss'));
            var_start := false;
         end if;

         /*-*/
         /* Append data lines when required
         /*-*/
         lics_outbound_loader.append_data('"'||replace(par_sales_org_code,'"','""')||'";'||
                                          '"'||replace(par_dstbn_chnl_code,'"','""')||'";'||
                                          '"'||replace(par_division_code,'"','""')||'";'||
                                          '"'||replace(par_company_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.customer_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.display_item_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.call_date,'"','""')||'";'||
                                          '"'||replace(rcd_extract.user_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.display_in_store,'"','""')||'"');

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
         raise_application_error(-20000, 'FATAL ERROR - EFXSBW08 EFEX_DISPLAY_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxsbw08_display_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxsbw08_display_extract for iface_app.efxsbw08_display_extract;
grant execute on efxsbw08_display_extract to public;

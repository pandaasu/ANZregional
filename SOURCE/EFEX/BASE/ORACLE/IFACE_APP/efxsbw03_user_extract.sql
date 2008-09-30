/******************/
/* Package Header */
/******************/
create or replace package efxsbw03_user_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxsbw03_user_extract
    Owner   : iface_app

    Description
    -----------
    User Extract - EFEX to SAP BW

    This package extracts the Efex users that have been modified within the last
    history number of days and sends the extract file to the SAP BW environment.
    The ICS interface EFXSBW03 has been created for this purpose.

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

end efxsbw03_user_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxsbw03_user_extract as

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
         select to_char(t01.user_id) as user_id,
                t01.username as username,
                t01.firstrname as firstrname,
                t01.lastname as lastname,
                t01.description as description,
                t01.city as city
           from users t01
          where t01.market_id = con_market_id
            and trunc(t01.modified_date) >= trunc(sysdate) - var_history;
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
            var_instance := lics_outbound_loader.create_interface('EFXSBW03',null,'EFEX_USER_EXTRACT.DAT.'||to_char(sysdate,'yyyymmddhh24miss'));
            var_start := false;
         end if;

         /*-*/
         /* Append data lines when required
         /*-*/
         lics_outbound_loader.append_data('"'||replace(par_sales_org_code,'"','""')||'";'||
                                          '"'||replace(par_dstbn_chnl_code,'"','""')||'";'||
                                          '"'||replace(par_division_code,'"','""')||'";'||
                                          '"'||replace(par_company_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.user_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.username,'"','""')||'";'||
                                          '"'||replace(rcd_extract.firstname,'"','""')||'";'||
                                          '"'||replace(rcd_extract.lastname,'"','""')||'";'||
                                          '"'||replace(rcd_extract.description,'"','""')||'";'||
                                          '"'||replace(rcd_extract.city,'"','""')||'"');

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
         raise_application_error(-20000, 'FATAL ERROR - EFXSBW03 EFEX_USER_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxsbw03_user_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxsbw03_user_extract for iface_app.efxsbw03_user_extract;
grant execute on efxsbw03_user_extract to public;

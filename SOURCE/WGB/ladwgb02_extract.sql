--
-- LADWGB02_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE SITE_APP.ladwgb02_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladwgb02_extract
    Owner   : site_app

    Description
    -----------
    China Vendor Data - LADS to WGB



    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the LADS vendor that have been modified within the last
    history number of days and sends the extract file to the Wrigleys Golden Bear environment.
    The ICS interface LADWGB05 has been created for this purpose.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created
    2010/02   Steve Gregan   Added new interface fields

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in varchar2 default 0);

end ladwgb02_extract;
/


--
-- LADWGB02_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM LADWGB02_EXTRACT FOR SITE_APP.LADWGB02_EXTRACT;



--
-- LADWGB02_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY SITE_APP.ladwgb02_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_history in varchar2 default 0) is

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
         select decode(trim(t01.vendor_code),null,';','"'||replace(trim(t01.vendor_code),'"','""')||'";') as vendor_code,
                decode(trim(t02.vendor_name),null,';','"'||replace(trim(t02.vendor_name),'"','""')||'";') as vendor_name,
                decode(trim(t01.group_key),null,';','"'||replace(trim(t01.group_key),'"','""')||'";') as group_key,
                decode(trim(t01.representative_name),null,';','"'||replace(trim(t01.representative_name),'"','""')||'";') as representative_name,
                decode(trim(t01.deletion_flag),null,';','"'||replace(trim(t01.deletion_flag),'"','""')||'";') as deletion_flag,
                decode(trim(t03.bank_number),null,';','"'||replace(trim(t03.bank_number),'"','""')||'";') as bank_number,
                decode(trim(t03.bank_account_number),null,';','"'||replace(trim(t03.bank_account_number),'"','""')||'";') as bank_account_number,
                decode(trim(t03.bank_name),null,';','"'||replace(trim(t03.bank_name),'"','""')||'";') as bank_name,
                decode(trim(t03.bank_branch),null,';','"'||replace(trim(t03.bank_branch),'"','""')||'";') as bank_branch,
                decode(trim(t03.location),null,'','"'||replace(trim(t03.location),'"','""')||'"') as location
           from bds_vend_header t01,
                (select t01.vendor_code,
                        max(ltrim(t01.name ||' '|| t01.name_02)) as vendor_name
                   from bds_addr_vendor t01
                  where t01.address_version = 'I'
                    and t01.country = 'CN'
                    and t01.language_ISO = 'ZH'
                  group by t01.vendor_code) t02,
                bds_vend_bank t03
          where t01.vendor_code = t02.vendor_code
            and t01.vendor_code = t03.vendor_code
            and trunc(t01.bds_lads_date) >= trunc(sysdate) - var_history;
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
            var_instance := lics_outbound_loader.create_interface('LADWGB02',null,'LADWGB02.DAT');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data(rcd_extract.vendor_code ||
                                          rcd_extract.vendor_name ||
                                          rcd_extract.group_key ||
                                          rcd_extract.representative_name ||
                                          rcd_extract.deletion_flag ||
                                          rcd_extract.bank_number ||
                                          rcd_extract.bank_account_number ||
                                          rcd_extract.bank_name ||
                                          rcd_extract.bank_branch ||
                                          rcd_extract.location);

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
         raise_application_error(-20000, 'FATAL ERROR - LADWGB02 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladwgb02_extract;
/


--
-- LADWGB02_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM LADWGB02_EXTRACT FOR SITE_APP.LADWGB02_EXTRACT;


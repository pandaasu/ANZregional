--
-- LADWGB04_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE SITE_APP.ladwgb04_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladwgb04_extract
    Owner   : site_app

    Description
    -----------
    China Customer Standard Hierarchy - LADS to WGB



    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the LADS customer standard hierarchy that have been modified within the last
    history number of days and sends the extract file to the Wrigleys Golden Bear environment.
    The ICS interface LADWGB04 has been created for this purpose.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in varchar2 default 0);

end ladwgb04_extract;
/


--
-- LADWGB04_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM LADWGB04_EXTRACT FOR SITE_APP.LADWGB04_EXTRACT;


GRANT EXECUTE ON SITE_APP.LADWGB04_EXTRACT TO PUBLIC;


--
-- LADWGB04_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY SITE_APP.ladwgb04_extract as

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
         select decode(trim(t01.sap_hier_cust_code),null,';','"'||replace(trim(t01.sap_hier_cust_code),'"','""')||'";') as sap_hier_cust_code,
                decode(trim(t01.sap_sales_org_code),null,';','"'||replace(trim(t01.sap_sales_org_code),'"','""')||'";') as sap_sales_org_code,
                decode(trim(t01.sap_distbn_chnl_code),null,';','"'||replace(trim(t01.sap_distbn_chnl_code),'"','""')||'";') as sap_distbn_chnl_code,
                decode(trim(t01.sap_division_code),null,';','"'||replace(trim(t01.sap_division_code),'"','""')||'";') as sap_division_code,
                decode(trim(t01.sap_cust_code_level_1),null,';','"'||replace(trim(t01.sap_cust_code_level_1),'"','""')||'";') as sap_cust_code_level_1,
                decode(trim(t01.cust_name_en_level_1),null,';','"'||replace(trim(t01.cust_name_en_level_1),'"','""')||'";') as cust_name_en_level_1,
                decode(trim(t01.sap_sales_org_code_level_1),null,';','"'||replace(trim(t01.sap_sales_org_code_level_1),'"','""')||'";') as sap_sales_org_code_level_1,
                decode(trim(t01.sap_distbn_chnl_code_level_1),null,';','"'||replace(trim(t01.sap_distbn_chnl_code_level_1),'"','""')||'";') as sap_distbn_chnl_code_level_1,
                decode(trim(t01.sap_division_code_level_1),null,';','"'||replace(trim(t01.sap_division_code_level_1),'"','""')||'";') as sap_division_code_level_1,
                decode(trim(t01.cust_hier_sort_level_1),null,';','"'||replace(trim(t01.cust_hier_sort_level_1),'"','""')||'";') as cust_hier_sort_level_1,
                decode(trim(t01.sap_cust_code_level_2),null,';','"'||replace(trim(t01.sap_cust_code_level_2),'"','""')||'";') as sap_cust_code_level_2,
                decode(trim(t01.cust_name_en_level_2),null,';','"'||replace(trim(t01.cust_name_en_level_2),'"','""')||'";') as cust_name_en_level_2,
                decode(trim(t01.sap_sales_org_code_level_2),null,';','"'||replace(trim(t01.sap_sales_org_code_level_2),'"','""')||'";') as sap_sales_org_code_level_2,
                decode(trim(t01.sap_distbn_chnl_code_level_2),null,';','"'||replace(trim(t01.sap_distbn_chnl_code_level_2),'"','""')||'";') as sap_distbn_chnl_code_level_2,
                decode(trim(t01.sap_division_code_level_2),null,';','"'||replace(trim(t01.sap_division_code_level_2),'"','""')||'";') as sap_division_code_level_2,
                decode(trim(t01.cust_hier_sort_level_2),null,';','"'||replace(trim(t01.cust_hier_sort_level_2),'"','""')||'";') as cust_hier_sort_level_2,
                decode(trim(t01.sap_cust_code_level_3),null,';','"'||replace(trim(t01.sap_cust_code_level_3),'"','""')||'";') as sap_cust_code_level_3,
                decode(trim(t01.cust_name_en_level_3),null,';','"'||replace(trim(t01.cust_name_en_level_3),'"','""')||'";') as cust_name_en_level_3,
                decode(trim(t01.sap_sales_org_code_level_3),null,';','"'||replace(trim(t01.sap_sales_org_code_level_3),'"','""')||'";') as sap_sales_org_code_level_3,
                decode(trim(t01.sap_distbn_chnl_code_level_3),null,';','"'||replace(trim(t01.sap_distbn_chnl_code_level_3),'"','""')||'";') as sap_distbn_chnl_code_level_3,
                decode(trim(t01.sap_division_code_level_3),null,';','"'||replace(trim(t01.sap_division_code_level_3),'"','""')||'";') as sap_division_code_level_3,
                decode(trim(t01.cust_hier_sort_level_3),null,';','"'||replace(trim(t01.cust_hier_sort_level_3),'"','""')||'";') as cust_hier_sort_level_3,
                decode(trim(t01.sap_cust_code_level_4),null,';','"'||replace(trim(t01.sap_cust_code_level_4),'"','""')||'";') as sap_cust_code_level_4,
                decode(trim(t01.cust_name_en_level_4),null,';','"'||replace(trim(t01.cust_name_en_level_4),'"','""')||'";') as cust_name_en_level_4,
                decode(trim(t01.sap_sales_org_code_level_4),null,';','"'||replace(trim(t01.sap_sales_org_code_level_4),'"','""')||'";') as sap_sales_org_code_level_4,
                decode(trim(t01.sap_distbn_chnl_code_level_4),null,';','"'||replace(trim(t01.sap_distbn_chnl_code_level_4),'"','""')||'";') as sap_distbn_chnl_code_level_4,
                decode(trim(t01.sap_division_code_level_4),null,';','"'||replace(trim(t01.sap_division_code_level_4),'"','""')||'";') as sap_division_code_level_4,
                decode(trim(t01.cust_hier_sort_level_4),null,';','"'||replace(trim(t01.cust_hier_sort_level_4),'"','""')||'";') as cust_hier_sort_level_4,
                decode(trim(t01.sap_cust_code_level_5),null,';','"'||replace(trim(t01.sap_cust_code_level_5),'"','""')||'";') as sap_cust_code_level_5,
                decode(trim(t01.cust_name_en_level_5),null,';','"'||replace(trim(t01.cust_name_en_level_5),'"','""')||'";') as cust_name_en_level_5,
                decode(trim(t01.sap_sales_org_code_level_5),null,';','"'||replace(trim(t01.sap_sales_org_code_level_5),'"','""')||'";') as sap_sales_org_code_level_5,
                decode(trim(t01.sap_distbn_chnl_code_level_5),null,';','"'||replace(trim(t01.sap_distbn_chnl_code_level_5),'"','""')||'";') as sap_distbn_chnl_code_level_5,
                decode(trim(t01.sap_division_code_level_5),null,';','"'||replace(trim(t01.sap_division_code_level_5),'"','""')||'";') as sap_division_code_level_5,
                decode(trim(t01.cust_hier_sort_level_5),null,'','"'||replace(trim(t01.cust_hier_sort_level_5),'"','""')||'"') as cust_hier_sort_level_5
           from std_hier t01
          where t01.sap_sales_org_code = '135';
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
            var_instance := lics_outbound_loader.create_interface('LADWGB04',null,'LADWGB04.DAT');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data(rcd_extract.sap_hier_cust_code ||
                                          rcd_extract.sap_sales_org_code ||
                                          rcd_extract.sap_distbn_chnl_code ||
                                          rcd_extract.sap_division_code ||
                                          rcd_extract.sap_cust_code_level_1 ||
                                          rcd_extract.cust_name_en_level_1 ||
                                          rcd_extract.sap_sales_org_code_level_1 ||
                                          rcd_extract.sap_distbn_chnl_code_level_1 ||
                                          rcd_extract.sap_division_code_level_1 ||
                                          rcd_extract.cust_hier_sort_level_1 ||
                                          rcd_extract.sap_cust_code_level_2 ||
                                          rcd_extract.cust_name_en_level_2 ||
                                          rcd_extract.sap_sales_org_code_level_2 ||
                                          rcd_extract.sap_distbn_chnl_code_level_2 ||
                                          rcd_extract.sap_division_code_level_2 ||
                                          rcd_extract.cust_hier_sort_level_2 ||
                                          rcd_extract.sap_cust_code_level_3 ||
                                          rcd_extract.cust_name_en_level_3 ||
                                          rcd_extract.sap_sales_org_code_level_3 ||
                                          rcd_extract.sap_distbn_chnl_code_level_3 ||
                                          rcd_extract.sap_division_code_level_3 ||
                                          rcd_extract.cust_hier_sort_level_3 ||
                                          rcd_extract.sap_cust_code_level_4 ||
                                          rcd_extract.cust_name_en_level_4 ||
                                          rcd_extract.sap_sales_org_code_level_4 ||
                                          rcd_extract.sap_distbn_chnl_code_level_4 ||
                                          rcd_extract.sap_division_code_level_4 ||
                                          rcd_extract.cust_hier_sort_level_4 ||
                                          rcd_extract.sap_cust_code_level_5 ||
                                          rcd_extract.cust_name_en_level_5 ||
                                          rcd_extract.sap_sales_org_code_level_5 ||
                                          rcd_extract.sap_distbn_chnl_code_level_5 ||
                                          rcd_extract.sap_division_code_level_5 ||
                                          rcd_extract.cust_hier_sort_level_5);

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
         raise_application_error(-20000, 'FATAL ERROR - LADWGB04 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladwgb04_extract;
/


--
-- LADWGB04_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM LADWGB04_EXTRACT FOR SITE_APP.LADWGB04_EXTRACT;


GRANT EXECUTE ON SITE_APP.LADWGB04_EXTRACT TO PUBLIC;

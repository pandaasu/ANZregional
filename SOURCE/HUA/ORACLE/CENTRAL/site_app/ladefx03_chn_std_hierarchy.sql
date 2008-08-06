/******************/
/* Package Header */
/******************/
create or replace package ladefx03_chn_std_hierarchy as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladefx03_chn_std_hierarchy
    Owner   : site_app

    Description
    -----------
    China Standard Hierachy Data - LADS to EFEX

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ladefx03_chn_std_hierarchy;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladefx03_chn_std_hierarchy as

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
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_start boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_std_hierarchy is
         select t01.sap_cust_code_level_1 as sap_cust_code_level_1,
                t01.sap_cust_code_level_2 as sap_cust_code_level_2,
                t01.sap_cust_code_level_3 as sap_cust_code_level_3,
                t01.sap_cust_code_level_4 as sap_cust_code_level_4,
                max(t01.cust_name_en_level_1) as cust_name_en_level_1,
                max(t01.cust_name_en_level_2) as cust_name_en_level_2,
                max(t01.cust_name_en_level_3) as cust_name_en_level_3,
                max(t01.cust_name_en_level_4) as cust_name_en_level_4
         from std_hier t01
         where t01.sap_sales_org_code = '135'
           and not(t01.sap_cust_code_level_1 is null)
           and not(t01.sap_cust_code_level_2 is null)
           and not(t01.sap_cust_code_level_3 is null)
           and not(t01.sap_cust_code_level_4 is null)
         group by t01.sap_cust_code_level_1,
                  t01.sap_cust_code_level_2,
                  t01.sap_cust_code_level_3,
                  t01.sap_cust_code_level_4;
      rcd_std_hierarchy csr_std_hierarchy%rowtype;

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
      open csr_std_hierarchy;
      loop
         fetch csr_std_hierarchy into rcd_std_hierarchy;
         if csr_std_hierarchy%notfound then
            exit;
         end if;

         /*-*/
         /* Create outbound interface if record(s) exist
         /*-*/
         if (var_start) then
            var_instance := lics_outbound_loader.create_interface('LADEFX03',null,'LADEFX03.dat');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          rpad(nvl(rcd_std_hierarchy.sap_cust_code_level_1,' '),10,' ') ||
                                          rpad(nvl(rcd_std_hierarchy.sap_cust_code_level_2,' '),10,' ') ||
                                          rpad(nvl(rcd_std_hierarchy.sap_cust_code_level_3,' '),10,' ') ||
                                          rpad(nvl(rcd_std_hierarchy.sap_cust_code_level_4,' '),10,' ') ||
                                          nvl(substr(rcd_std_hierarchy.cust_name_en_level_1,1,50),' ')||rpad(' ',50-length(nvl(substr(rcd_std_hierarchy.cust_name_en_level_1,1,50),' ')),' ') ||
                                          nvl(substr(rcd_std_hierarchy.cust_name_en_level_2,1,50),' ')||rpad(' ',50-length(nvl(substr(rcd_std_hierarchy.cust_name_en_level_2,1,50),' ')),' ') ||
                                          nvl(substr(rcd_std_hierarchy.cust_name_en_level_3,1,50),' ')||rpad(' ',50-length(nvl(substr(rcd_std_hierarchy.cust_name_en_level_3,1,50),' ')),' ') ||
                                          nvl(substr(rcd_std_hierarchy.cust_name_en_level_4,1,50),' ')||rpad(' ',50-length(nvl(substr(rcd_std_hierarchy.cust_name_en_level_4,1,50),' ')),' '));

      end loop;
      close csr_std_hierarchy;

      /*-*/
      /* Finalise interface
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
         raise_application_error(-20000, 'FATAL ERROR - LADEFX03 CHINA STANDARD HIERARCHY - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladefx03_chn_std_hierarchy;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladefx03_chn_std_hierarchy for site_app.ladefx03_chn_std_hierarchy;
grant execute on ladefx03_chn_std_hierarchy to public;

/******************/
/* Package Header */
/******************/
create or replace package ladefx04_chn_geo_hierarchy as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladefx04_chn_geo_hierarchy
    Owner   : site_app

    Description
    -----------
    China Geographic Hierachy Data - LADS to EFEX

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/08   Linden Glen    Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ladefx04_chn_geo_hierarchy;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladefx04_chn_geo_hierarchy as

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
      cursor csr_geo_hierarchy is
         select t01.sap_cust_code_level_1 as sap_cust_code_level_1,
                t01.sap_cust_code_level_2 as sap_cust_code_level_2,
                t01.sap_cust_code_level_3 as sap_cust_code_level_3,
                t01.sap_cust_code_level_4 as sap_cust_code_level_4,
                t01.sap_cust_code_level_5 as sap_cust_code_level_5,
                nvl(max(t01.cust_name_en_level_1),'*UNKNOWN') as cust_name_en_level_1,
                nvl(max(t01.cust_name_en_level_2),'*UNKNOWN') as cust_name_en_level_2,
                nvl(max(t01.cust_name_en_level_3),'*UNKNOWN') as cust_name_en_level_3,
                nvl(max(t01.cust_name_en_level_4),'*UNKNOWN') as cust_name_en_level_4,
                nvl(max(t01.cust_name_en_level_5),'*UNKNOWN') as cust_name_en_level_5
         from sales_force_geo_hier t01
         where t01.sap_sales_org_code = '135'
           and not(t01.sap_cust_code_level_1 is null)
           and not(t01.sap_cust_code_level_2 is null)
           and not(t01.sap_cust_code_level_3 is null)
           and not(t01.sap_cust_code_level_4 is null)
           and not(t01.sap_cust_code_level_5 is null)
         group by t01.sap_cust_code_level_1,
                  t01.sap_cust_code_level_2,
                  t01.sap_cust_code_level_3,
                  t01.sap_cust_code_level_4,
                  t01.sap_cust_code_level_5;
      rcd_geo_hierarchy csr_geo_hierarchy%rowtype;

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
      open csr_geo_hierarchy;
      loop
         fetch csr_geo_hierarchy into rcd_geo_hierarchy;
         if csr_geo_hierarchy%notfound then
            exit;
         end if;

         /*-*/
         /* Create outbound interface if record(s) exist
         /*-*/
         if (var_start) then
            var_instance := lics_outbound_loader.create_interface('LADEFX04',null,'LADEFX04.dat');
            lics_outbound_loader.append_data('CTL');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_geo_hierarchy.sap_cust_code_level_1,' ')||rpad(' ',10-length(nvl(rcd_geo_hierarchy.sap_cust_code_level_1,' ')),' ') ||
                                          nvl(rcd_geo_hierarchy.sap_cust_code_level_2,' ')||rpad(' ',10-length(nvl(rcd_geo_hierarchy.sap_cust_code_level_2,' ')),' ') ||
                                          nvl(rcd_geo_hierarchy.sap_cust_code_level_3,' ')||rpad(' ',10-length(nvl(rcd_geo_hierarchy.sap_cust_code_level_3,' ')),' ') ||
                                          nvl(rcd_geo_hierarchy.sap_cust_code_level_4,' ')||rpad(' ',10-length(nvl(rcd_geo_hierarchy.sap_cust_code_level_4,' ')),' ') ||
                                          nvl(rcd_geo_hierarchy.sap_cust_code_level_5,' ')||rpad(' ',10-length(nvl(rcd_geo_hierarchy.sap_cust_code_level_5,' ')),' ') ||
                                          nvl(substr(rcd_geo_hierarchy.cust_name_en_level_1,1,50),' ')||rpad(' ',50-length(nvl(substr(rcd_geo_hierarchy.cust_name_en_level_1,1,50),' ')),' ') ||
                                          nvl(substr(rcd_geo_hierarchy.cust_name_en_level_2,1,50),' ')||rpad(' ',50-length(nvl(substr(rcd_geo_hierarchy.cust_name_en_level_2,1,50),' ')),' ') ||
                                          nvl(substr(rcd_geo_hierarchy.cust_name_en_level_3,1,50),' ')||rpad(' ',50-length(nvl(substr(rcd_geo_hierarchy.cust_name_en_level_3,1,50),' ')),' ') ||
                                          nvl(substr(rcd_geo_hierarchy.cust_name_en_level_4,1,50),' ')||rpad(' ',50-length(nvl(substr(rcd_geo_hierarchy.cust_name_en_level_4,1,50),' ')),' ') ||
                                          nvl(substr(rcd_geo_hierarchy.cust_name_en_level_5,1,50),' ')||rpad(' ',50-length(nvl(substr(rcd_geo_hierarchy.cust_name_en_level_5,1,50),' ')),' '));

      end loop;
      close csr_geo_hierarchy;

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
         raise_application_error(-20000, 'FATAL ERROR - LADEFX04 CHINA GEOGRAPHIC HIERARCHY - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladefx04_chn_geo_hierarchy;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladefx04_chn_geo_hierarchy for site_app.ladefx04_chn_geo_hierarchy;
grant execute on ladefx04_chn_geo_hierarchy to public;

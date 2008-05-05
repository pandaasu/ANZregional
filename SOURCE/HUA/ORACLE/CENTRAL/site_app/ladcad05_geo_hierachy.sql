create or replace package ladcad05_geo_hierachy as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : ladcad05_geo_hierachy
 Owner   : site_app

 Description
 -----------
 Geographic Hierachy Data


 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/01   Linden Glen    Created
 2008/01   Linden Glen    Added data check to stop empty interfaces
 2008/03   Linden Glen    Modified Name output to allow for Chinese characters

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ladcad05_geo_hierachy;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladcad05_geo_hierachy as

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
      cursor csr_geo_hieracy is
         select a.sap_hier_cust_code as sap_hier_cust_code,
                a.sap_sales_org_code as sap_sales_org_code,
                a.sap_distbn_chnl_code as sap_distbn_chnl_code,
                a.sap_division_code as sap_division_code,
                a.sap_cust_code_level_1 as sap_cust_code_level_1,
                a.cust_name_en_level_1 as cust_name_en_level_1,
                a.sap_sales_org_code_level_1 as sap_sales_org_code_level_1,
                a.sap_distbn_chnl_code_level_1 as sap_distbn_chnl_code_level_1,
                a.sap_division_code_level_1 as sap_division_code_level_1,
                a.cust_hier_sort_level_1 as cust_hier_sort_level_1,
                a.sap_cust_code_level_2 as sap_cust_code_level_2,
                a.cust_name_en_level_2 as cust_name_en_level_2,
                a.sap_sales_org_code_level_2 as sap_sales_org_code_level_2,
                a.sap_distbn_chnl_code_level_2 as sap_distbn_chnl_code_level_2,
                a.sap_division_code_level_2 as sap_division_code_level_2,
                a.cust_hier_sort_level_2 as cust_hier_sort_level_2,
                a.sap_cust_code_level_3 as sap_cust_code_level_3,
                a.cust_name_en_level_3 as cust_name_en_level_3,
                a.sap_sales_org_code_level_3 as sap_sales_org_code_level_3,
                a.sap_distbn_chnl_code_level_3 as sap_distbn_chnl_code_level_3,
                a.sap_division_code_level_3 as sap_division_code_level_3,
                a.cust_hier_sort_level_3 as cust_hier_sort_level_3,
                a.sap_cust_code_level_4 as sap_cust_code_level_4,
                a.cust_name_en_level_4 as cust_name_en_level_4,
                a.sap_sales_org_code_level_4 as sap_sales_org_code_level_4,
                a.sap_distbn_chnl_code_level_4 as sap_distbn_chnl_code_level_4,
                a.sap_division_code_level_4 as sap_division_code_level_4,
                a.cust_hier_sort_level_4 as cust_hier_sort_level_4,
                a.sap_cust_code_level_5 as sap_cust_code_level_5,
                a.cust_name_en_level_5 as cust_name_en_level_5,
                a.sap_sales_org_code_level_5 as sap_sales_org_code_level_5,
                a.sap_distbn_chnl_code_level_5 as sap_distbn_chnl_code_level_5,
                a.sap_division_code_level_5 as sap_division_code_level_5,
                a.cust_hier_sort_level_5 as cust_hier_sort_level_5,
                a.sap_cust_code_level_6 as sap_cust_code_level_6,
                a.cust_name_en_level_6 as cust_name_en_level_6,
                a.sap_sales_org_code_level_6 as sap_sales_org_code_level_6,
                a.sap_distbn_chnl_code_level_6 as sap_distbn_chnl_code_level_6,
                a.sap_division_code_level_6 as sap_division_code_level_6,
                a.cust_hier_sort_level_6 as cust_hier_sort_level_6,
                a.sap_cust_code_level_7 as sap_cust_code_level_7,
                a.cust_name_en_level_7 as cust_name_en_level_7,
                a.sap_sales_org_code_level_7 as sap_sales_org_code_level_7,
                a.sap_distbn_chnl_code_level_7 as sap_distbn_chnl_code_level_7,
                a.sap_division_code_level_7 as sap_division_code_level_7,
                a.cust_hier_sort_level_7 as cust_hier_sort_level_7,
                a.sap_cust_code_level_8 as sap_cust_code_level_8,
                a.cust_name_en_level_8 as cust_name_en_level_8,
                a.sap_sales_org_code_level_8 as sap_sales_org_code_level_8,
                a.sap_distbn_chnl_code_level_8 as sap_distbn_chnl_code_level_8,
                a.sap_division_code_level_8 as sap_division_code_level_8,
                a.cust_hier_sort_level_8 as cust_hier_sort_level_8,
                a.sap_cust_code_level_9 as sap_cust_code_level_9,
                a.cust_name_en_level_9 as cust_name_en_level_9,
                a.sap_sales_org_code_level_9 as sap_sales_org_code_level_9,
                a.sap_distbn_chnl_code_level_9 as sap_distbn_chnl_code_level_9,
                a.sap_division_code_level_9 as sap_division_code_level_9,
                a.cust_hier_sort_level_9 as cust_hier_sort_level_9,
                a.sap_cust_code_level_10 as sap_cust_code_level_10,
                a.cust_name_en_level_10 as cust_name_en_level_10,
                a.sap_sales_org_code_level_10 as sap_sales_org_code_level_10,
                a.sap_distbn_chnl_code_level_10 as sap_distbn_chnl_code_level_10,
                a.sap_division_code_level_10 as sap_division_code_level_10,
                a.cust_hier_sort_level_10 as cust_hier_sort_level_10
         from sales_force_geo_hier a
         where sap_sales_org_code = '135';
      rec_geo_hieracy  csr_geo_hieracy%rowtype;

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
      open csr_geo_hieracy;
      loop
         fetch csr_geo_hieracy into rec_geo_hieracy;
         if (csr_geo_hieracy%notfound) then
            exit;
         end if;

         /*-*/
         /* Create Outbound Interface if record(s) exist
         /*-*/
         if (var_start) then

            var_instance := lics_outbound_loader.create_interface('LADCAD05',null,'LADCAD05.dat');

            var_start := false;

         end if;

         /*-*/
         /* Append Data Lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_hier_cust_code,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_sales_org_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_distbn_chnl_code,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_division_code,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_cust_code_level_1,' ')),10, ' ') ||
                                          nvl(rec_geo_hieracy.cust_name_en_level_1,' ')||rpad(' ',40-length(nvl(rec_geo_hieracy.cust_name_en_level_1,' ')),' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_sales_org_code_level_1,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_distbn_chnl_code_level_1,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_division_code_level_1,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.cust_hier_sort_level_1,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_cust_code_level_2,' ')),10, ' ') ||
                                          nvl(rec_geo_hieracy.cust_name_en_level_2,' ')||rpad(' ',40-length(nvl(rec_geo_hieracy.cust_name_en_level_2,' ')),' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_sales_org_code_level_2,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_distbn_chnl_code_level_2,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_division_code_level_2,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.cust_hier_sort_level_2,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_cust_code_level_3,' ')),10, ' ') ||
                                          nvl(rec_geo_hieracy.cust_name_en_level_3,' ')||rpad(' ',40-length(nvl(rec_geo_hieracy.cust_name_en_level_3,' ')),' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_sales_org_code_level_3,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_distbn_chnl_code_level_3,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_division_code_level_3,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.cust_hier_sort_level_3,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_cust_code_level_4,' ')),10, ' ') ||
                                          nvl(rec_geo_hieracy.cust_name_en_level_4,' ')||rpad(' ',40-length(nvl(rec_geo_hieracy.cust_name_en_level_4,' ')),' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_sales_org_code_level_4,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_distbn_chnl_code_level_4,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_division_code_level_4,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.cust_hier_sort_level_4,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_cust_code_level_5,' ')),10, ' ') ||
                                          nvl(rec_geo_hieracy.cust_name_en_level_5,' ')||rpad(' ',40-length(nvl(rec_geo_hieracy.cust_name_en_level_5,' ')),' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_sales_org_code_level_5,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_distbn_chnl_code_level_5,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_division_code_level_5,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.cust_hier_sort_level_5,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_cust_code_level_6,' ')),10, ' ') ||
                                          nvl(rec_geo_hieracy.cust_name_en_level_6,' ')||rpad(' ',40-length(nvl(rec_geo_hieracy.cust_name_en_level_6,' ')),' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_sales_org_code_level_6,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_distbn_chnl_code_level_6,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_division_code_level_6,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.cust_hier_sort_level_6,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_cust_code_level_7,' ')),10, ' ') ||
                                          nvl(rec_geo_hieracy.cust_name_en_level_7,' ')||rpad(' ',40-length(nvl(rec_geo_hieracy.cust_name_en_level_7,' ')),' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_sales_org_code_level_7,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_distbn_chnl_code_level_7,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_division_code_level_7,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.cust_hier_sort_level_7,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_cust_code_level_8,' ')),10, ' ') ||
                                          nvl(rec_geo_hieracy.cust_name_en_level_8,' ')||rpad(' ',40-length(nvl(rec_geo_hieracy.cust_name_en_level_8,' ')),' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_sales_org_code_level_8,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_distbn_chnl_code_level_8,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_division_code_level_8,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.cust_hier_sort_level_8,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_cust_code_level_9,' ')),10, ' ') ||
                                          nvl(rec_geo_hieracy.cust_name_en_level_9,' ')||rpad(' ',40-length(nvl(rec_geo_hieracy.cust_name_en_level_9,' ')),' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_sales_org_code_level_9,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_distbn_chnl_code_level_9,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_division_code_level_9,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.cust_hier_sort_level_9,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_cust_code_level_10,' ')),10, ' ') ||
                                          nvl(rec_geo_hieracy.cust_name_en_level_10,' ')||rpad(' ',40-length(nvl(rec_geo_hieracy.cust_name_en_level_10,' ')),' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_sales_org_code_level_10,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_distbn_chnl_code_level_10,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.sap_division_code_level_10,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_geo_hieracy.cust_hier_sort_level_10,' ')),10, ' '));

      end loop;
      close csr_geo_hieracy;

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
         raise_application_error(-20000, 'FATAL ERROR - LADCAD05 GEOGRAPHIC HIERACHY - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladcad05_geo_hierachy;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladcad05_geo_hierachy for site_app.ladcad05_geo_hierachy;
grant execute on ladcad05_geo_hierachy to public;

CREATE OR REPLACE PACKAGE           "ODS_DFNODS01_MONITOR" as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_fcst_type_code in varchar2,
                     par_fcst_version in varchar2,
                     par_company_code in varchar2,
                     par_sales_org_code in varchar2,
                     par_moe_code in varchar2,
                     par_distbn_chnl_code in varchar2,
                     par_division_code in varchar2,
                     par_casting_year in varchar2,
                     par_casting_period in varchar2);

end ods_dfnods01_monitor;
 
/


CREATE OR REPLACE PACKAGE BODY           "ODS_DFNODS01_MONITOR" as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_function constant varchar2(128) := 'ODS Forecast Monitor';
   con_ema_group constant varchar2(64) := '"MFANZ CDW Group"@esosn1';
   con_ema_code constant varchar2(32) := 'DFNODS01';

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_fcst_type_code in varchar2,
                     par_fcst_version in varchar2,
                     par_company_code in varchar2,
                     par_sales_org_code in varchar2,
                     par_moe_code in varchar2,
                     par_distbn_chnl_code in varchar2,
                     par_division_code in varchar2,
                     par_casting_year in varchar2,
                     par_casting_period in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return - no monitoring
      /*-*/
      return;

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
         /* Send the notification
         /*-*/
         begin
            ods_notification.send_email(con_function,
                                        lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code),
                                        'Forecast (' || par_fcst_type_code || '/' || par_fcst_version || '/' || par_company_code || '/' || par_sales_org_code || '/' || par_moe_code || '/' || par_distbn_chnl_code  || '/' || par_division_code || '/' || par_casting_year || '/' || par_casting_period || ')' || chr(13) || substr(SQLERRM, 1, 1024));
		 exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'ODS_DFNODS01_MONITOR - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ods_dfnods01_monitor;
/

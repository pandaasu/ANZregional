--
-- LICS_ALERTING  (Package) 
--
CREATE OR REPLACE PACKAGE LICS_APP.lics_alerting as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_alert
 Owner   : lics_app
 Author  : Steve Gregan - August 2006

 DESCRIPTION
 -----------
 Local Interface Control System - Alerting

 The package implements the alerting functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2011/10   Ben Halicki    Created

*******************************************************************************/

   /**/
   /* Public declarations
   /**/
   procedure execute;
   
end lics_alerting;
/



--
-- LICS_ALERTING  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY LICS_APP.lics_alerting as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /**/
   /* Private declarations
   /**/
   function retrieve_alert_count(par_search_txt in varchar2, par_last_run in date) return number;

   /*-*/
   /* Public definitions
   /*-*/   
   var_title         varchar2(128);

   /*******************************************************/
   /* This function performs the alerting routine         */
   /*******************************************************/
   procedure execute is
   
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_alert_01 is
         select t01.ale_srch_txt, 
                t01.ale_msg_txt
           from lics_alert t01;
      rcd_lics_alert_01   csr_lics_alert_01%rowtype;

      /*-*/
      /* Local definitions
      /*-*/
      var_sql_stmt      varchar2(4000);
      var_alert_count   number;    
      var_last_run      date;
      var_start_time    date;
      var_msg_txt       varchar2(2000);      
      var_system        varchar2(200); 
      var_gateway       varchar2(200);
      var_sender        varchar2(200);
      var_found         boolean;
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
   
      /*----------------------*/
      /* Initialise variables */
      /*----------------------*/
      var_system := lics_parameter.system_code || '_' || lics_parameter.system_unit || '_' || lics_parameter.system_environment;
      var_gateway := lics_setting_configuration.retrieve_setting('LICS_SMS_ALERT_PROFILE','GATEWAY_ADDR');
      var_sender := lics_setting_configuration.retrieve_setting('LICS_SMS_ALERT_PROFILE','SENDER_ID');
      var_title := 'Interface Control System - LICS Alerting';
      
      var_found := false;
      
      /*-*/
      /*  Start logging
      /**/ 
      lics_logging.start_log('LICS_ALERTING','LICS_ALERTING');
      
      /*-*/
      /*  Retrieve last run control date/time
      /**/ 
      var_last_run := lics_last_run_control.get_last_run('LICS_ALERTING');
      if (var_last_run is null) then
         var_last_run := sysdate;
      end if;
      
      var_start_time := sysdate;
      
      open csr_lics_alert_01;
      loop
         fetch csr_lics_alert_01 into rcd_lics_alert_01;
         exit when csr_lics_alert_01%notfound;
         
         var_alert_count := retrieve_alert_count(rcd_lics_alert_01.ale_srch_txt,var_last_run);
         
         if (var_alert_count > 0) then
                       
            lics_logging.write_log(rcd_lics_alert_01.ale_srch_txt || ' - ' || rcd_lics_alert_01.ale_msg_txt || ' - Count: ' || var_alert_count);
              
            if (var_found=false) then
               var_msg_txt := 'Alerts received for ' || var_system || ' - ';
            end if;
            
            if (var_found=true) then
               var_msg_txt := var_msg_txt || ', ' || rcd_lics_alert_01.ale_msg_txt || ':' || var_alert_count;
            else
               var_msg_txt := var_msg_txt || ' ' || rcd_lics_alert_01.ale_msg_txt || ':' || var_alert_count;
            end if;
            
            var_found := true;
            
         end if;
         
      end loop;
      
      if (var_found = true) then
         /*-*/
         /* Send SMS notification
         /**/      
         lics_mailer.create_email(var_system,
                                 var_gateway, 
                                 var_sender,
                                 lics_parameter.email_smtp_host, 
                                 lics_parameter.email_smtp_port);
         lics_mailer.create_part(null);
         lics_mailer.append_data(var_msg_txt);
         lics_mailer.finalise_email('utf-8');        
      else
         lics_logging.write_log('No alerts found');
      end if;

      /*-*/
      /* Update last run control date/time
      /**/      
      lics_last_run_control.set_last_run('LICS_ALERTING', var_start_time);

      lics_logging.end_log;

      /*--------------------*/
      /* Commit transaction */
      /*--------------------*/      
      commit;
      
   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         if (not lics_logging.is_created ) then
            lics_logging.start_log('LICS_ALERTING', 'LICS_ALERTING');
         end if;
      
         lics_logging.write_log('Exception raised - ' || SQLERRM);
         lics_logging.end_log;

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;   
   
   /*******************************************************/
   /* This function retrieves the alert count             */
   /*******************************************************/   
   function retrieve_alert_count(par_search_txt in varchar2, par_last_run in date) return number is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_alert_log_01 is
         select count(*) as alert_count
           from
           (select t01.het_header as alert_header,
                   t01.het_end_time as alert_datime,
                   t02.hem_text as alert_text
              from lics_hdr_trace t01,
                   lics_hdr_message t02
             where t01.het_header=t02.hem_header
               and t01.het_hdr_trace=t02.hem_hdr_trace
               and t01.het_status=8
            union all
            select t01.het_header as alert_header,
                   t01.het_end_time as alert_datime,
                   t02.dam_text as alert_text
              from lics_hdr_trace t01,
                   lics_dta_message t02
             where t01.het_header=t02.dam_header
               and t01.het_hdr_trace=t02.dam_hdr_trace
               and t01.het_status=8
            union all
            select t01.jot_execution as alert_header,
                   t01.jot_end_time as alert_datime,
                   t01.jot_message as alert_text   
              from lics_job_trace t01
             where t01.jot_status=5
           ) t01 where t01.alert_datime >= par_last_run
                   and t01.alert_text like '%' || par_search_txt || '%';
       rcd_alert_log_01    csr_alert_log_01%rowtype;

      /*-*/
      /* Local definitions
      /*-*/
      var_alert_count pls_integer;
       
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
   
      open csr_alert_log_01;
      fetch csr_alert_log_01 into rcd_alert_log_01;
      
      var_alert_count := rcd_alert_log_01.alert_count;

      close csr_alert_log_01;
    
      return var_alert_count;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));
        
   /*-------------*/
   /* End routine */
   /*-------------*/   
   end retrieve_alert_count;
 
end lics_alerting;
/


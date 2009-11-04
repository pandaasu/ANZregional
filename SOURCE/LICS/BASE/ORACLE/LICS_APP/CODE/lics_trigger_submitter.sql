/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_trigger_submitter
 Owner   : lics_app
 Author  : Steve Gregan - July 2005

 DESCRIPTION
 -----------
 Local Interface Control System - Trigger Submitter

 The package implements the trigger submission functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/07   Steve Gregan   Created
 2009/11   Steve Gregan   Added execute overload for log data

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_trigger_submitter as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_tri_function in varchar2,
                     par_tri_procedure in varchar2,
                     par_tri_setting in varchar2);
   procedure execute(par_tri_function in varchar2,
                     par_tri_procedure in varchar2,
                     par_tri_log_data in varchar2,
                     par_tri_setting in varchar2);

end lics_trigger_submitter;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_trigger_submitter as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_tri_function in varchar2,
                     par_tri_procedure in varchar2,
                     par_tri_setting in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_alert varchar2(256);
      var_email varchar2(256);
      var_job varchar2(256);

      /*-*/
      /* Local constants
      /*-*/
      con_alt_group constant varchar2(32) := 'TRIGGER_SUBMIT_ALERT';
      con_ema_group constant varchar2(32) := 'TRIGGER_SUBMIT_EMAIL_GROUP';
      con_tri_group constant varchar2(32) := 'TRIGGER_SUBMIT_JOB_GROUP';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the requested setting values
      /*-*/
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, upper(par_tri_setting));
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, upper(par_tri_setting));
      var_job := lics_setting_configuration.retrieve_setting(con_tri_group, upper(par_tri_setting));
      if var_alert is null then
         var_alert := '*NONE';
      end if;
      if var_email is null then
         var_email := '*NONE';
      end if;
      if var_job is null then
         raise_application_error(-20000, 'Setting value (group=TRIGGER_SUBMIT_JOB_GROUP and code=' || upper(par_tri_setting) || ') not found - unable to continue');
      end if;

      /*-*/
      /* Load the requested trigger
      /*-*/
      lics_trigger_loader.execute(par_tri_function,
                                  par_tri_procedure,
                                  var_alert,
                                  var_email,
                                  var_job);

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
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Trigger Submitter - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_tri_function in varchar2,
                     par_tri_procedure in varchar2,
                     par_tri_log_data in varchar2,
                     par_tri_setting in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_alert varchar2(256);
      var_email varchar2(256);
      var_job varchar2(256);

      /*-*/
      /* Local constants
      /*-*/
      con_alt_group constant varchar2(32) := 'TRIGGER_SUBMIT_ALERT';
      con_ema_group constant varchar2(32) := 'TRIGGER_SUBMIT_EMAIL_GROUP';
      con_tri_group constant varchar2(32) := 'TRIGGER_SUBMIT_JOB_GROUP';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the requested setting values
      /*-*/
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, upper(par_tri_setting));
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, upper(par_tri_setting));
      var_job := lics_setting_configuration.retrieve_setting(con_tri_group, upper(par_tri_setting));
      if var_alert is null then
         var_alert := '*NONE';
      end if;
      if var_email is null then
         var_email := '*NONE';
      end if;
      if var_job is null then
         raise_application_error(-20000, 'Setting value (group=TRIGGER_SUBMIT_JOB_GROUP and code=' || upper(par_tri_setting) || ') not found - unable to continue');
      end if;

      /*-*/
      /* Load the requested trigger
      /*-*/
      lics_trigger_loader.execute(par_tri_function,
                                  par_tri_procedure,
                                  par_tri_log_data,
                                  var_alert,
                                  var_email,
                                  var_job);

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
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Trigger Submitter - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lics_trigger_submitter;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_trigger_submitter for lics_app.lics_trigger_submitter;
grant execute on lics_trigger_submitter to public;

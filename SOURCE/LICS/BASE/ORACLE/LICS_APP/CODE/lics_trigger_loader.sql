/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_trigger_loader
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - trigger Loader

 The package implements the trigger loader functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/06   Steve Gregan   Added group to lics_triggered table
 2009/11   Steve Gregan   Added log data to lics_triggered table
                          Added execute overload for log data

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_trigger_loader as

   /**/
   /* Public declarations
   /**/
   procedure execute(par_function in varchar2,
                     par_procedure in varchar2,
                     par_opr_alert in varchar2,
                     par_ema_group in varchar2,
                     par_group in varchar2);
   procedure execute(par_function in varchar2,
                     par_procedure in varchar2,
                     par_log_data in varchar2,
                     par_opr_alert in varchar2,
                     par_ema_group in varchar2,
                     par_group in varchar2);

end lics_trigger_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_trigger_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_triggered lics_triggered%rowtype;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_function in varchar2,
                     par_procedure in varchar2,
                     par_opr_alert in varchar2,
                     par_ema_group in varchar2,
                     par_group in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create the new triggered data
      /*-*/
      select lics_triggered_sequence.nextval into rcd_lics_triggered.tri_sequence from dual;
      rcd_lics_triggered.tri_group := par_group;
      rcd_lics_triggered.tri_function := par_function;
      rcd_lics_triggered.tri_procedure := par_procedure;
      rcd_lics_triggered.tri_timestamp := sysdate;
      rcd_lics_triggered.tri_opr_alert := par_opr_alert;
      rcd_lics_triggered.tri_ema_group := par_ema_group;
      rcd_lics_triggered.tri_log_data := null;
      insert into lics_triggered
         (tri_sequence,
          tri_group,
          tri_function,
          tri_procedure,
          tri_timestamp,
          tri_opr_alert,
          tri_ema_group,
          tri_log_data)
         values(rcd_lics_triggered.tri_sequence,
                rcd_lics_triggered.tri_group,
                rcd_lics_triggered.tri_function,
                rcd_lics_triggered.tri_procedure,
                rcd_lics_triggered.tri_timestamp,
                rcd_lics_triggered.tri_opr_alert,
                rcd_lics_triggered.tri_ema_group,
                rcd_lics_triggered.tri_log_data);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Log the event
      /*-*/
      lics_notification.log_success(lics_constant.job_loader,
                                    null,
                                    lics_constant.type_procedure,
                                    par_group,
                                    '(' || rcd_lics_triggered.tri_function || ') ' || rcd_lics_triggered.tri_procedure,
                                    null,
                                    null,
                                    null,
                                    'TRIGGER LOADER SUCCESS');

      /*-*/
      /* Notify the trigger processor(s)
      /*-*/
      lics_pipe.spray(lics_constant.type_daemon, par_group, lics_constant.pipe_wake);

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
         /* Log the event fatal
         /*-*/
         begin
            lics_notification.log_fatal(lics_constant.job_loader,
                                        null,
                                        lics_constant.type_procedure,
                                        par_group,
                                        '(' || par_function || ') ' || par_procedure,
                                        null,
                                        null,
                                        null,
                                        'TRIGGER LOADER FAILED - ' ||  substr(SQLERRM, 1, 1024));
         exception
            when others then
               null;
         end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_function in varchar2,
                     par_procedure in varchar2,
                     par_log_data in varchar2,
                     par_opr_alert in varchar2,
                     par_ema_group in varchar2,
                     par_group in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create the new triggered data
      /*-*/
      select lics_triggered_sequence.nextval into rcd_lics_triggered.tri_sequence from dual;
      rcd_lics_triggered.tri_group := par_group;
      rcd_lics_triggered.tri_function := par_function;
      rcd_lics_triggered.tri_procedure := par_procedure;
      rcd_lics_triggered.tri_timestamp := sysdate;
      rcd_lics_triggered.tri_opr_alert := par_opr_alert;
      rcd_lics_triggered.tri_ema_group := par_ema_group;
      rcd_lics_triggered.tri_log_data := par_log_data;
      insert into lics_triggered
         (tri_sequence,
          tri_group,
          tri_function,
          tri_procedure,
          tri_timestamp,
          tri_opr_alert,
          tri_ema_group,
          tri_log_data)
         values(rcd_lics_triggered.tri_sequence,
                rcd_lics_triggered.tri_group,
                rcd_lics_triggered.tri_function,
                rcd_lics_triggered.tri_procedure,
                rcd_lics_triggered.tri_timestamp,
                rcd_lics_triggered.tri_opr_alert,
                rcd_lics_triggered.tri_ema_group,
                rcd_lics_triggered.tri_log_data);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Log the event
      /*-*/
      lics_notification.log_success(lics_constant.job_loader,
                                    null,
                                    lics_constant.type_procedure,
                                    par_group,
                                    '(' || rcd_lics_triggered.tri_function || ') ' || nvl(rcd_lics_triggered.tri_log_data,rcd_lics_triggered.tri_procedure),
                                    null,
                                    null,
                                    null,
                                    'TRIGGER LOADER SUCCESS');

      /*-*/
      /* Notify the trigger processor(s)
      /*-*/
      lics_pipe.spray(lics_constant.type_daemon, par_group, lics_constant.pipe_wake);

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
         /* Log the event fatal
         /*-*/
         begin
            lics_notification.log_fatal(lics_constant.job_loader,
                                        null,
                                        lics_constant.type_procedure,
                                        par_group,
                                        '(' || par_function || ') ' || nvl(par_log_data,par_procedure),
                                        null,
                                        null,
                                        null,
                                        'TRIGGER LOADER FAILED - ' ||  substr(SQLERRM, 1, 1024));
         exception
            when others then
               null;
         end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lics_trigger_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_trigger_loader for lics_app.lics_trigger_loader;
grant execute on lics_trigger_loader to public;
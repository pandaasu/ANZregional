/******************/
/* Package Header */
/******************/
create or replace package lics_stream_processor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_stream_processor
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - Stream Processor

    The package implements the stream processor functionality.

    1. This package executes stream action and provides callbacks for implementations.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_stream in number, par_task in number, par_event in number);
   function callback_event return varchar2;
   function callback_text return varchar2;
   function callback_lock return varchar2;
   function callback_alert return varchar2;
   function callback_email return varchar2;

end lics_stream_processor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_stream_processor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   var_event lics_str_action.sta_evt_code%type;
   var_text lics_str_action.sta_evt_text%type;
   var_lock lics_str_action.sta_evt_lock%type;
   var_alert lics_str_action.sta_opr_alert%type;
   var_email lics_str_action.sta_ema_group%type;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_stream in number, par_task in number, par_event in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_error varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_action is 
         select t01.*
           from lics_str_action t01
          where t01.sta_str_seqn = par_stream
            and t01.sta_tsk_seqn = par_task
            and t01.sta_evt_seqn = par_event;
      rcd_action csr_action%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the routine
      /*-*/
      var_error := null;
      var_event := null;
      var_lock := null;
      var_alert := null;
      var_email := null;

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_stream is null then
         raise_application_error(-20000, 'Action stream sequence must be supplied');
      end if;
      if par_task is null then
         raise_application_error(-20000, 'Action task sequence must be supplied');
      end if;
      if par_event is null then
         raise_application_error(-20000, 'Action event sequence must be supplied');
      end if;

      /*-*/
      /* Retrieve the stream action
      /*-*/
      open csr_action;
      fetch csr_action into rcd_action;
      if csr_action%notfound then
         raise_application_error(-20000, 'Stream action not found (' || to_char(par_stream) || '/' || to_char(par_task) || '/' || to_char(par_event) || ')');
      end if;
      close csr_action;
      if rcd_action.sta_status != '*OPENED' then
         raise_application_error(-20000, 'Stream action is not *OPENED (' || to_char(par_stream) || '/' || to_char(par_task) || '/' || to_char(par_event) || ')');
      end if;

      /*-*/
      /* Process the event
      /* **notes**
      /* 1. Action procedure should always perform own commit or rollback
      /*    (this processor will always perform commit/rollback for safety)
      /*-*/
      var_error := null;
      var_event := rcd_action.sta_evt_code;
      var_text := rcd_action.sta_evt_text;
      var_lock := rcd_action.sta_evt_lock;
      var_alert := rcd_action.sta_opr_alert;
      var_email := rcd_action.sta_ema_group;
      begin
         execute immediate 'begin ' || rcd_action.sta_evt_proc || '; end;';
         commit;
      exception
         when others then
            rollback;
            var_error := substr(SQLERRM, 1, 3000);
      end;
      var_event := null;
      var_text := null;
      var_lock := null;
      var_alert := null;
      var_email := null;

      /*-*/
      /* Update the stream action and commit
      /* **note** 1. The update must happen after the stream action procedure has executed
      /*             so that the strean poller does not trigger the next task until after
      /*             the current one completes.
      /*          2. The update must always happen regardless of the outcome of
      /*             the stream action procedure.
      /*-*/
      if var_error is null then

         /*-*/
         /* Update the current action to completed
         /*-*/
         update lics_str_action
            set sta_completed = '1'
          where sta_str_seqn = rcd_action.sta_str_seqn
            and sta_tsk_seqn = rcd_action.sta_tsk_seqn
            and sta_evt_seqn = rcd_action.sta_evt_seqn;
         commit;

      else

         /*-*/
         /* Update the current action to *FAILED
         /*-*/
         update lics_str_action
            set sta_failed = '1',
                sta_message = var_error
          where sta_str_seqn = rcd_action.sta_str_seqn
            and sta_tsk_seqn = rcd_action.sta_tsk_seqn
            and sta_evt_seqn = rcd_action.sta_evt_seqn;
         commit;

         /*-*/
         /* Raise the exeception to the caller
         /*-*/
         raise_application_error(-20000, var_error);

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Stream Processor - Execute - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*****************************************************/
   /* This function performs the callback event routine */
   /*****************************************************/
   function callback_event return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the stream action event
      /*-*/
      return var_event;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_event;

   /*****************************************************/
   /* This function performs the callback text routine */
   /*****************************************************/
   function callback_text return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the stream action text
      /*-*/
      return var_text;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_text;

   /****************************************************/
   /* This function performs the callback lock routine */
   /****************************************************/
   function callback_lock return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the stream action lock
      /*-*/
      return var_lock;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_lock;

   /*****************************************************/
   /* This function performs the callback alert routine */
   /*****************************************************/
   function callback_alert return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the stream action alert
      /*-*/
      return var_alert;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_alert;

   /*****************************************************/
   /* This function performs the callback email routine */
   /*****************************************************/
   function callback_email return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the stream action email
      /*-*/
      return var_email;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_email;

end lics_stream_processor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_stream_processor for lics_app.lics_stream_processor;
grant execute on lics_stream_processor to public;

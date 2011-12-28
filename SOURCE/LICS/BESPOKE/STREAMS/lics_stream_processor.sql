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
    2009/01   Steve Gregan   Added parameter functionality
    2011/11   Steve Gregan   Added stream multiple dependency functionality

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_stream in number, par_task in varchar2, par_event in varchar2);
   function callback_event return varchar2;
   function callback_text return varchar2;
   function callback_lock return varchar2;
   function callback_alert return varchar2;
   function callback_email return varchar2;
   function callback_parameter(par_code in varchar2) return varchar2;
   function callback_is_cancelled return boolean;

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
   var_stream lics_str_exe_event.ste_exe_seqn%type;
   var_event lics_str_exe_event.ste_evt_code%type;
   var_text lics_str_exe_event.ste_evt_text%type;
   var_lock lics_str_exe_event.ste_evt_lock%type;
   var_alert lics_str_exe_event.ste_opr_alert%type;
   var_email lics_str_exe_event.ste_ema_group%type;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_stream in number, par_task in varchar2, par_event in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_error varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_event is 
         select t01.*
           from lics_str_exe_event t01
          where t01.ste_exe_seqn = par_stream
            and t01.ste_tsk_code = par_task
            and t01.ste_evt_code = par_event;
      rcd_event csr_event%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the routine
      /*-*/
      var_stream := null;
      var_error := null;
      var_event := null;
      var_lock := null;
      var_alert := null;
      var_email := null;

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_stream is null then
         raise_application_error(-20000, 'Stream sequence must be supplied');
      end if;
      if par_task is null then
         raise_application_error(-20000, 'Task code must be supplied');
      end if;
      if par_event is null then
         raise_application_error(-20000, 'Event code must be supplied');
      end if;

      /*-*/
      /* Retrieve the stream event
      /*-*/
      open csr_event;
      fetch csr_event into rcd_event;
      if csr_event%notfound then
         raise_application_error(-20000, 'Stream execution event not found (' || to_char(par_stream) || '/' || par_task || '/' || par_event || ')');
      end if;
      close csr_event;
      if rcd_event.ste_exe_status != '*OPENED' then
         raise_application_error(-20000, 'Stream execution event is not *OPENED (' || to_char(par_stream) || '/' || par_task || '/' || par_event || ')');
      end if;

      /*-*/
      /* Update the current event to *WORKING
      /*-*/
      update lics_str_exe_event
         set ste_exe_status = '*WORKING',
             ste_exe_start = sysdate,
             ste_exe_end = sysdate
       where ste_exe_seqn = rcd_event.ste_exe_seqn
         and ste_tsk_code = rcd_event.ste_tsk_code
         and ste_evt_code = rcd_event.ste_evt_code;
      commit;

      /*-*/
      /* Process the execution event
      /* **notes**
      /* 1. Action procedure should always perform own commit or rollback
      /*    (this processor will always perform commit/rollback for safety)
      /*-*/
      var_error := null;
      var_stream := rcd_event.ste_exe_seqn;
      var_event := rcd_event.ste_evt_code;
      var_text := rcd_event.ste_evt_text;
      var_lock := rcd_event.ste_evt_lock;
      var_alert := rcd_event.ste_opr_alert;
      var_email := rcd_event.ste_ema_group;
      begin
         execute immediate 'begin ' || rcd_event.ste_evt_proc || '; end;';
         commit;
      exception
         when others then
            rollback;
            var_error := substr(SQLERRM, 1, 3000);
      end;
      var_stream := null;
      var_event := null;
      var_text := null;
      var_lock := null;
      var_alert := null;
      var_email := null;

      /*-*/
      /* Update the stream event and commit
      /* **note** 1. The update must happen after the stream event procedure has executed
      /*             so that the stream poller does not trigger the next task until after
      /*             the current one completes.
      /*          2. The update must always happen regardless of the outcome of
      /*             the stream event procedure.
      /*-*/
      if var_error is null then

         /*-*/
         /* Update the current event to *COMPLETED
         /*-*/
         update lics_str_exe_event
            set ste_exe_status = '*COMPLETED',
                ste_exe_end = sysdate
          where ste_exe_seqn = rcd_event.ste_exe_seqn
            and ste_tsk_code = rcd_event.ste_tsk_code
            and ste_evt_code = rcd_event.ste_evt_code;
         commit;

      else

         /*-*/
         /* Update the current event to *FAILED
         /*-*/
         update lics_str_exe_event
            set ste_exe_status = '*FAILED',
                ste_exe_end = sysdate,
                ste_exe_message = var_error
          where ste_exe_seqn = rcd_event.ste_exe_seqn
            and ste_tsk_code = rcd_event.ste_tsk_code
            and ste_evt_code = rcd_event.ste_evt_code;
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

   /*********************************************************/
   /* This function performs the callback parameter routine */
   /*********************************************************/
   function callback_parameter(par_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_parameter is 
         select t01.stp_par_value
           from lics_str_exe_param t01
          where t01.stp_exe_seqn = var_stream
            and t01.stp_par_code = upper(par_code);
      rcd_parameter csr_parameter%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the stream parameter
      /*-*/
      var_return := null;
      open csr_parameter;
      fetch csr_parameter into rcd_parameter;
      if csr_parameter%found then
         var_return := rcd_parameter.stp_par_value;
      end if;
      close csr_parameter;

      /*-*/
      /* Return the stream parameter
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_parameter;

   /************************************************************/
   /* This function performs the callback is cancelled routine */
   /************************************************************/
   function callback_is_cancelled return boolean is

      /*-*/
      /* Local definitions
      /*-*/
      var_return boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_stream is 
         select t01.*
           from lics_str_exe_header t01
          where t01.sth_exe_seqn = var_stream;
      rcd_stream csr_stream%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the stream status
      /*-*/
      var_return := false;
      open csr_stream;
      fetch csr_stream into rcd_stream;
      if csr_stream%found then
         if rcd_stream.sth_exe_status = '*OPNCANCEL' then
            var_return := true;
         end if;
      end if;
      close csr_stream;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_is_cancelled;

end lics_stream_processor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_stream_processor for lics_app.lics_stream_processor;
grant execute on lics_stream_processor to public;

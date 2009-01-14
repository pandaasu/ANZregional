/******************/
/* Package Header */
/******************/
create or replace package lics_stream_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_stream_loader
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - Stream loader

    The package implements the stream loader functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/09   Steve Gregan   Created
    2009/01   Steve Gregan   Added parameter functionality

   /**/
   /* Public declarations
   /**/
   procedure clear_parameters;
   procedure set_parameter(par_code in varchar2, par_value in varchar2);
   procedure execute(par_stream in varchar2, par_procedure in varchar2);

end lics_stream_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_stream_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   type rcd_parameter is record(code varchar2(32 char), value varchar2(4000 char));
   type typ_parameter is table of rcd_parameter index by binary_integer;
   tbl_parameter typ_parameter;

   /********************************************************/
   /* This procedure performs the clear parameters routine */
   /********************************************************/
   procedure clear_parameters is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the parameters
      /*-*/
      tbl_parameter.delete;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear_parameters;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure set_parameter(par_code in varchar2, par_value in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Insert/update the parameter value
      /*-*/
      var_found := false;
      for idx in 1..tbl_parameter.count loop
         if tbl_parameter(idx).code = upper(par_code) then
            tbl_parameter(idx).value := par_value;
            var_found := true;
            exit;
         end if;
      end loop;
      if var_found = false then
        tbl_parameter(tbl_parameter.count+1).code := upper(par_code);
        tbl_parameter(tbl_parameter.count).value := par_value;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_parameter;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_stream in varchar2, par_procedure in varchar2) is


      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      rcd_lics_str_action lics_str_action%rowtype;
      rcd_lics_str_parameter lics_str_parameter%rowtype;
      var_procedure lics_str_action.sta_evt_proc%type;
      var_str_seqn number;
      var_tsk_seqn number;
      var_evt_seqn number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.*
           from lics_str_header t01
          where upper(t01.sth_str_code) = upper(par_stream);
      rcd_header csr_header%rowtype;

      cursor csr_task is
         select t01.*
           from lics_str_task t01
          where t01.stt_str_code = rcd_header.sth_str_code
          start with t01.stt_tsk_pcde = '*TOP'
        connect by prior t01.stt_str_code = t01.stt_str_code
                and prior t01.stt_tsk_code = t01.stt_tsk_pcde
          order siblings by t01.stt_tsk_seqn;
      rcd_task csr_task%rowtype;

      cursor csr_event is
         select t01.*
           from lics_str_event t01
          where t01.ste_str_code = rcd_task.stt_str_code
            and t01.ste_tsk_code = rcd_task.stt_tsk_code
          order by t01.ste_evt_seqn asc;
      rcd_event csr_event%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_stream is null then
         raise_application_error(-20000, 'Parameter stream must be supplied');
      end if;
      var_procedure := par_procedure;

      /*-*/
      /* Retrieve the stream header
      /*-*/
      open csr_header;
      fetch csr_header into rcd_header;
      if csr_header%notfound then
         raise_application_error(-20000, 'Stream (' || upper(par_stream) || ') does not exist');
      end if;
      close csr_header;
      if rcd_header.sth_status != '1' then
         raise_application_error(-20000, 'Stream (' || upper(par_stream) || ') is not active');
      end if;

      /*-*/
      /* Initialise the sequence for current stream action
      /*-*/
      select lics_stream_sequence.nextval into var_str_seqn from dual;

      /*-*/
      /* Retrieve the stream tasks
      /*-*/
      var_tsk_seqn := 0;
      open csr_task;
      loop
         fetch csr_task into rcd_task;
         if csr_task%notfound then
            exit;
         end if;
         var_tsk_seqn := var_tsk_seqn + 1;

         /*-*/
         /* Retrieve the task events
         /*-*/
         var_evt_seqn := 0;
         open csr_event;
         loop
            fetch csr_event into rcd_event;
            if csr_event%notfound then
               exit;
            end if;
            var_evt_seqn := var_evt_seqn + 1;

            /*-*/
            /* Create the stream action
            /*-*/
            rcd_lics_str_action.sta_str_seqn := var_str_seqn;
            rcd_lics_str_action.sta_tsk_seqn := var_tsk_seqn;
            rcd_lics_str_action.sta_evt_seqn := var_evt_seqn;
            rcd_lics_str_action.sta_str_code := rcd_header.sth_str_code;
            rcd_lics_str_action.sta_str_text := rcd_header.sth_str_text;
            rcd_lics_str_action.sta_tsk_pcde := rcd_task.stt_tsk_pcde;
            rcd_lics_str_action.sta_tsk_code := rcd_task.stt_tsk_code;
            rcd_lics_str_action.sta_tsk_text := rcd_task.stt_tsk_text;
            rcd_lics_str_action.sta_evt_code := rcd_event.ste_evt_code;
            rcd_lics_str_action.sta_evt_text := rcd_event.ste_evt_text;
            rcd_lics_str_action.sta_evt_lock := rcd_event.ste_evt_lock;
            if upper(trim(rcd_event.ste_evt_lock)) = '*NONE' then
               rcd_lics_str_action.sta_evt_lock := '*LOCK:' || to_char(var_str_seqn) || ':' || to_char(var_tsk_seqn) || ':' || to_char(var_evt_seqn);
            end if;
            rcd_lics_str_action.sta_evt_proc := rcd_event.ste_evt_proc;
            if upper(trim(rcd_event.ste_evt_proc)) = '*SUPPLIED' then
               rcd_lics_str_action.sta_evt_proc := var_procedure;
            end if;
            rcd_lics_str_action.sta_job_group := rcd_event.ste_job_group;
            rcd_lics_str_action.sta_opr_alert := rcd_event.ste_opr_alert;
            rcd_lics_str_action.sta_ema_group := rcd_event.ste_ema_group;
            rcd_lics_str_action.sta_timestamp := sysdate;
            rcd_lics_str_action.sta_status := '*CREATED';
            if rcd_task.stt_tsk_pcde = '*TOP' then
               rcd_lics_str_action.sta_status := '*OPENED';
            end if;
            rcd_lics_str_action.sta_selected := '0';
            rcd_lics_str_action.sta_completed := '0';
            rcd_lics_str_action.sta_failed := '0';
            rcd_lics_str_action.sta_message := null;

            /*-*/
            /* Perform the parameter substitutions
            /*-*/
            for idx in 1..tbl_parameter.count loop
               rcd_lics_str_action.sta_evt_lock := replace(rcd_lics_str_action.sta_evt_lock,'<%='||tbl_parameter(idx).code||'%>',tbl_parameter(idx).value);
               rcd_lics_str_action.sta_evt_proc := replace(rcd_lics_str_action.sta_evt_proc,'<%='||tbl_parameter(idx).code||'%>',tbl_parameter(idx).value);
               rcd_lics_str_action.sta_job_group := replace(rcd_lics_str_action.sta_job_group,'<%='||tbl_parameter(idx).code||'%>',tbl_parameter(idx).value);
            end loop;

            /*-*/
            /* Create the stream action
            /*-*/
            insert into lics_str_action values rcd_lics_str_action;

         end loop;
         close csr_event;

      end loop;
      close csr_task;

      /*-*/
      /* Create the stream parameters
      /*-*/
      for idx in 1..tbl_parameter.count loop
         rcd_lics_str_parameter.stp_str_seqn := var_str_seqn;
         rcd_lics_str_parameter.stp_par_code := tbl_parameter(idx).code;
         rcd_lics_str_parameter.stp_par_value := tbl_parameter(idx).value;
         insert into lics_str_parameter values rcd_lics_str_parameter;
      end loop;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Stream Loader - Execute - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lics_stream_loader;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_stream_loader for lics_app.lics_stream_loader;
grant execute on lics_stream_loader to public;
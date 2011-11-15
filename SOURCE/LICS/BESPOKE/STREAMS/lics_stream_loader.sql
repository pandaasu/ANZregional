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
    2011/10   Steve Gregan   Added stream multiple dependency functionality

   /*-*/
   /* Public declarations
   /*-*/
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
   procedure execute(par_stream in varchar2, par_text in varchar2, par_procedure in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      rcd_lics_str_exe_header lics_str_exe_header%rowtype;
      rcd_lics_str_exe_task lics_str_exe_task%rowtype;
      rcd_lics_str_exe_depend lics_str_exe_depend%rowtype;
      rcd_lics_str_exe_event lics_str_exe_event%rowtype;
      rcd_lics_str_exe_param lics_str_exe_param%rowtype;
      var_text lics_str_exe_header.sth_exe_text%type;
      var_procedure lics_str_exe_event.ste_evt_proc%type;
      var_exe_seqn number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.*
           from lics_str_header t01
          where upper(t01.sth_str_code) = upper(par_stream);
      rcd_header csr_header%rowtype;

      cursor csr_event is
         select t01.*
           from lics_str_event t01
          where t01.ste_str_code = rcd_header.sth_str_code
          order by t01.ste_tsk_code asc,
                   t01.ste_evt_code asc;
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
      if par_text is null then
         raise_application_error(-20000, 'Parameter text must be supplied');
      end if;
      var_text := par_text;
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
      /* Initialise the sequence for current execution
      /*-*/
      select lics_stream_sequence.nextval into var_exe_seqn from dual;

      /*-*/
      /* Create the stream execution header
      /*-*/
      insert into lics_str_exe_header
         select var_exe_seqn,
                var_text,
                '*PENDING',
                '*NONE',
                sysdate,
                sysdate,
                sysdate,
                t01.*
           from lics_str_header t01
          where t01.sth_str_code = par_stream;

      /*-*/
      /* Create the stream execution tasks
      /*-*/
      insert into lics_str_exe_task
         select var_exe_seqn,
                '*PENDING',
                t01.*
           from lics_str_task t01
          where t01.stt_str_code = par_stream;

      /*-*/
      /* Create the stream execution dependencies
      /*-*/
      insert into lics_str_exe_depend
         select var_exe_seqn,
                t01.*
           from lics_str_depend t01
          where t01.std_str_code = par_stream;

      /*-*/
      /* Create the stream execution events
      /*-*/
      open csr_event;
      loop
         fetch csr_event into rcd_event;
         if csr_event%notfound then
            exit;
         end if;

         /*-*/
         /* Create the stream execution event
         /*-*/
         rcd_lics_str_exe_event.ste_exe_seqn := var_exe_seqn;
         rcd_lics_str_exe_event.ste_exe_status := '*PENDING';
         rcd_lics_str_exe_event.ste_exe_message := null;
         rcd_lics_str_exe_event.ste_str_code := rcd_event.ste_str_code;
         rcd_lics_str_exe_event.ste_tsk_code := rcd_event.ste_tsk_code;
         rcd_lics_str_exe_event.ste_evt_code := rcd_event.ste_evt_code;
         rcd_lics_str_exe_event.ste_evt_seqn := rcd_event.ste_evt_seqn;
         rcd_lics_str_exe_event.ste_evt_text := rcd_event.ste_evt_text;
         rcd_lics_str_exe_event.ste_evt_lock := rcd_event.ste_evt_lock;
         if upper(trim(rcd_event.ste_evt_lock)) = '*NONE' then
            rcd_lics_str_exe_event.ste_evt_lock := '*LOCK:' || to_char(var_exe_seqn) || ':' || rcd_event.ste_tsk_code || ':' || rcd_event.ste_evt_code;
         end if;
         rcd_lics_str_exe_event.ste_evt_proc := rcd_event.ste_evt_proc;
         if upper(trim(rcd_event.ste_evt_proc)) = '*SUPPLIED' then
            rcd_lics_str_exe_event.ste_evt_proc := var_procedure;
         end if;
         rcd_lics_str_exe_event.ste_job_group := rcd_event.ste_job_group;
         rcd_lics_str_exe_event.ste_opr_alert := rcd_event.ste_opr_alert;
         rcd_lics_str_exe_event.ste_ema_group := rcd_event.ste_ema_group;

         /*-*/
         /* Perform the parameter substitutions
         /*-*/
         for idx in 1..tbl_parameter.count loop
            rcd_lics_str_exe_event.ste_evt_lock := replace(rcd_lics_str_exe_event.ste_evt_lock,'<'||tbl_parameter(idx).code||'>',tbl_parameter(idx).value);
            rcd_lics_str_exe_event.ste_evt_proc := replace(rcd_lics_str_exe_event.ste_evt_proc,'<'||tbl_parameter(idx).code||'>',tbl_parameter(idx).value);
            rcd_lics_str_exe_event.ste_job_group := replace(rcd_lics_str_exe_event.ste_job_group,'<'||tbl_parameter(idx).code||'>',tbl_parameter(idx).value);
         end loop;

         /*-*/
         /* Create the stream action
         /*-*/
         insert into lics_str_exe_event values rcd_lics_str_exe_event;

      end loop;
      close csr_event;

      /*-*/
      /* Create the stream parameters
      /*-*/
      for idx in 1..tbl_parameter.count loop
         rcd_lics_str_exe_param.stp_exe_seqn := var_exe_seqn;
         rcd_lics_str_exe_param.stp_par_code := tbl_parameter(idx).code;
         rcd_lics_str_exe_param.stp_par_value := tbl_parameter(idx).value;
         insert into lics_str_exe_param values rcd_lics_str_exe_param;
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
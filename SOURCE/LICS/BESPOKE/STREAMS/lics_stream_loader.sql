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
   procedure load(par_stream in varchar2, par_text in varchar2, par_procedure in varchar2);
   procedure set_parameter(par_code in varchar2, par_value in varchar2);
   procedure execute;

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
   pvar_stream lics_str_exe_header.sth_str_code%type;
   pvar_text lics_str_exe_header.sth_exe_text%type;
   pvar_procedure lics_str_exe_event.ste_evt_proc%type;
   type rcd_parameter is record(code varchar2(32 char), text varchar2(128 char), value varchar2(64 char));
   type typ_parameter is table of rcd_parameter index by binary_integer;
   tbl_parameter typ_parameter;

   /***************************************************/
   /* This procedure performs the stream load routine */
   /***************************************************/
   procedure load(par_stream in varchar2, par_text in varchar2, par_procedure in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.*
           from lics_str_header t01
          where upper(t01.sth_str_code) = pvar_stream;
      rcd_header csr_header%rowtype;

      cursor csr_param is
         select t01.*
           from lics_str_param t01
          where t01.stp_str_code = rcd_header.sth_str_code
          order by t01.stp_par_code asc;
      rcd_param csr_param%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_stream is null then
         raise_application_error(-20000, 'Stream code must be supplied');
      end if;
      if par_text is null then
         raise_application_error(-20000, 'Stream execution text must be supplied');
      end if;
      pvar_stream := upper(par_stream);
      pvar_text := par_text;
      pvar_procedure := par_procedure;

      /*-*/
      /* Retrieve the stream header
      /*-*/
      open csr_header;
      fetch csr_header into rcd_header;
      if csr_header%notfound then
         raise_application_error(-20000, 'Stream (' || pvar_stream || ') does not exist');
      end if;
      close csr_header;

      /*-*/
      /* Load the parameter array
      /*-*/
      tbl_parameter.delete;
      open csr_param;
      loop
         fetch csr_param into rcd_param;
         if csr_param%notfound then
            exit;
         end if;
         tbl_parameter(tbl_parameter.count+1).code := upper(rcd_param.stp_par_code);
         tbl_parameter(tbl_parameter.count).text := rcd_param.stp_par_text;
         tbl_parameter(tbl_parameter.count).value := rcd_param.stp_par_value;
      end loop;
      close csr_param;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure set_parameter(par_code in varchar2, par_value in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_fixed boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Update the parameter value
      /*-*/
      var_found := false;
      var_fixed := false;
      for idx in 1..tbl_parameter.count loop
         if tbl_parameter(idx).code = upper(par_code) then
            if upper(tbl_parameter(idx).value) = '*SUPPLIED' then
               tbl_parameter(idx).value := par_value;
            else
               var_fixed := true;
            end if;
            var_found := true;
            exit;
         end if;
      end loop;
      if var_fixed = true then
         raise_application_error(-20000, 'Parameter (' || upper(par_code) || ') is fixed - unable to change');
      end if;
      if var_found = false then
         raise_application_error(-20000, 'Parameter (' || upper(par_code) || ') does not exist in stream');
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_parameter;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

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
      var_exe_seqn number;
      var_par_code varchar2(32 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.*
           from lics_str_header t01
          where upper(t01.sth_str_code) = pvar_stream;
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
      if pvar_stream is null then
         raise_application_error(-20000, 'Stream has not been loaded');
      end if;

      /*-*/
      /* Check the parameter values
      /*-*/
      var_par_code := null;
      for idx in 1..tbl_parameter.count loop
         if upper(tbl_parameter(idx).value) = '*SUPPLIED' then
            var_par_code := tbl_parameter(idx).code;
            exit;
         end if;
      end loop;
      if not(var_par_code is null) then
         raise_application_error(-20000, 'Parameter type *SUPPLIED (' || var_par_code || ') does not have a value');
      end if;

      /*-*/
      /* Retrieve the stream header
      /*-*/
      open csr_header;
      fetch csr_header into rcd_header;
      if csr_header%notfound then
         raise_application_error(-20000, 'Stream (' || pvar_stream || ') does not exist');
      end if;
      close csr_header;
      if rcd_header.sth_status != '1' then
         raise_application_error(-20000, 'Stream (' || pvar_stream || ') is not active');
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
                pvar_text,
                '*PENDING',
                '*NONE',
                sysdate,
                sysdate,
                sysdate,
                t01.*
           from lics_str_header t01
          where t01.sth_str_code = rcd_header.sth_str_code;

      /*-*/
      /* Create the stream parameters
      /*-*/
      for idx in 1..tbl_parameter.count loop
         rcd_lics_str_exe_param.stp_exe_seqn := var_exe_seqn;
         rcd_lics_str_exe_param.stp_str_code := rcd_header.sth_str_code;
         rcd_lics_str_exe_param.stp_par_code := tbl_parameter(idx).code;
         rcd_lics_str_exe_param.stp_par_text := tbl_parameter(idx).text;
         rcd_lics_str_exe_param.stp_par_value := tbl_parameter(idx).value;
         insert into lics_str_exe_param values rcd_lics_str_exe_param;
      end loop;

      /*-*/
      /* Create the stream execution tasks
      /*-*/
      insert into lics_str_exe_task
         select var_exe_seqn,
                '*PENDING',
                sysdate,
                sysdate,
                t01.*
           from lics_str_task t01
          where t01.stt_str_code = rcd_header.sth_str_code;

      /*-*/
      /* Create the stream execution dependencies
      /*-*/
      insert into lics_str_exe_depend
         select var_exe_seqn,
                t01.*
           from lics_str_depend t01
          where t01.std_str_code = rcd_header.sth_str_code;

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
         rcd_lics_str_exe_event.ste_exe_queued := sysdate;
         rcd_lics_str_exe_event.ste_exe_open := sysdate;
         rcd_lics_str_exe_event.ste_exe_start := sysdate;
         rcd_lics_str_exe_event.ste_exe_end := sysdate;
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
            rcd_lics_str_exe_event.ste_evt_proc := pvar_procedure;
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
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Reset the stream
      /*-*/
      pvar_stream := null;

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
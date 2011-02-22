/******************/
/* Package Header */
/******************/
create or replace package lics_pipe as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_pipe
    Owner   : lics_app
    Author  : Steve Gregan - January 2004

    DESCRIPTION
    -----------
    Local Interface Control System - Pipe

    The package implements the pipe functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2005/11   Steve Gregan   Added receive_timed function
    2011/02   Steve Gregan   End point architecture version

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure send(par_pipe in varchar2, par_message in varchar2);
   procedure spray(par_type in varchar2, par_prefix in varchar2, par_message in varchar2);
   function receive(par_pipe in varchar2) return varchar2;
   function receive_timed(par_pipe in varchar2, par_interval in number) return varchar2;
   function check_queue(par_pipe in varchar2) return varchar2;

end lics_pipe;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_pipe as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure update_pipe(par_pipe in varchar2, par_message in varchar2);

   /********************************************/
   /* This procedure performs the send routine */
   /********************************************/
   procedure send(par_pipe in varchar2, par_message in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Send the message to the pipe
      /*-*/
      update_pipe(par_pipe, par_message);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send;

   /*********************************************/
   /* This procedure performs the spray routine */
   /*********************************************/
   procedure spray(par_type in varchar2, par_prefix in varchar2, par_message in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_like varchar2(32);
      var_work varchar2(1);
      var_client_info varchar2(64);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_job_trace_01 is 
         select t01.jot_execution,
                t01.jot_int_group
           from lics_job_trace t01
          where t01.jot_type = par_type
            and (t01.jot_status = lics_constant.job_working or
                 t01.jot_status = lics_constant.job_idle or
                 t01.jot_status = lics_constant.job_suspended)
            and t01.jot_int_group like var_like;
      rcd_lics_job_trace_01 csr_lics_job_trace_01%rowtype;

      cursor csr_v$session_01 is 
         select 'x'
            from v$session t01
           where t01.client_info = var_client_info;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the prefix test
      /*-*/
      var_like := par_prefix || '%';

      /*-*/
      /* Retrieve background jobs from LICS_JOB_TRACE that satisfy the queue prefix
      /*-*/
      open csr_lics_job_trace_01;
      loop
         fetch csr_lics_job_trace_01 into rcd_lics_job_trace_01;
         if csr_lics_job_trace_01%notfound then
            exit;
         end if;

         /*-*/
         /* Check for an active session for the current execution
         /* note - client info was set in job processor
         /*-*/
         var_client_info := 'ICSJOB:' || to_char(rcd_lics_job_trace_01.jot_execution,'FM999999999999990');
         open csr_v$session_01;
         fetch csr_v$session_01 into var_work;
         if csr_v$session_01%found then

            /*-*/
            /* Send the message to the pipe based on type
            /*-*/
            case par_type
               when lics_constant.type_file then
                  update_pipe(lics_constant.queue_file || rcd_lics_job_trace_01.jot_int_group, par_message);
               when lics_constant.type_inbound then
                  update_pipe(lics_constant.queue_inbound || rcd_lics_job_trace_01.jot_int_group, par_message);
               when lics_constant.type_outbound then
                  update_pipe(lics_constant.queue_outbound || rcd_lics_job_trace_01.jot_int_group, par_message);
               when lics_constant.type_passthru then
                  update_pipe(lics_constant.queue_passthru || rcd_lics_job_trace_01.jot_int_group, par_message);
               when lics_constant.type_daemon then
                  update_pipe(lics_constant.queue_daemon || rcd_lics_job_trace_01.jot_int_group, par_message);
               when lics_constant.type_poller then
                  update_pipe(lics_constant.queue_poller || rcd_lics_job_trace_01.jot_int_group, par_message);
               else
                  raise_application_error(-20000, 'LICS_PIPE - Spray - Job type (' || par_type || ') does not support pipes');
            end case;

         end if;
         close csr_v$session_01;

      end loop;
      close csr_lics_job_trace_01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end spray;

   /**********************************************/
   /* This function performs the receive routine */
   /**********************************************/
   function receive(par_pipe in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_status integer;
      var_message varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Receive the message from the pipe (blocking - wait maximum)
      /*-*/
      var_status := dbms_pipe.receive_message(par_pipe);
      if var_status <> 0 then
         raise_application_error(-20000, 'LICS_PIPE - Receive - Unable to receive message from pipe (' || par_pipe || ')');
      end if;
      dbms_pipe.unpack_message(var_message);

      /*-*/
      /* Return the message
      /*-*/
      return var_message;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end receive;

   /****************************************************/
   /* This function performs the receive timed routine */
   /****************************************************/
   function receive_timed(par_pipe in varchar2, par_interval in number) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_status integer;
      var_message varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Receive the message from the pipe (blocking - wait par_interval)
      /*-*/
      var_message := null;
      var_status := dbms_pipe.receive_message(par_pipe, par_interval);
      if var_status > 1 then
         raise_application_error(-20000, 'LICS_PIPE - Receive Timed - Unable to receive message from pipe (' || par_pipe || ')');
      end if;
      if var_status = 0 then
         dbms_pipe.unpack_message(var_message);
      end if;

      /*-*/
      /* Return the message
      /*-*/
      return var_message;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end receive_timed;

   /**************************************************/
   /* This function performs the check queue routine */
   /**************************************************/
   function check_queue(par_pipe in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_status integer;
      var_message varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Receive the message from the pipe (no blocking - no wait)
      /*-*/
      var_message := null;
      var_status := dbms_pipe.receive_message(par_pipe,0);
      if var_status > 1 then
         raise_application_error(-20000, 'LICS_PIPE - Check - Unable to receive message from pipe (' || par_pipe || ')');
      end if;
      if var_status = 0 then
         dbms_pipe.unpack_message(var_message);
      end if;

      /*-*/
      /* Return the message
      /*-*/
      return var_message;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end check_queue;

   /***************************************************/
   /* This procedure performs the update pipe routine */
   /***************************************************/
   procedure update_pipe(par_pipe in varchar2, par_message in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_locked boolean;
      var_status integer;
      var_lock_handle varchar2(128);
      var_message varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Aquire the pipe lock - exclusive mode
      /* 1. Timeout after 10 seconds and ignore
      /*-*/
      var_locked := false;
      dbms_lock.allocate_unique('LICS_' || par_pipe, var_lock_handle);
      var_status := dbms_lock.request(var_lock_handle, 6, 10);
      if var_status > 1 then
         raise_application_error(-20000, 'LICS_PIPE - Update Pipe - Unable to aquire pipe lock (' || par_pipe || ')');
      end if;
      if var_status = 1 then
         return;
      end if;
      var_locked := true;

      /*-*/
      /* Peek at the pipe - Receive the message from the pipe (no blocking - no wait)
      /* 1. Message found - replace as required
      /* 2. Message not found - put new message
      /*-*/
      var_status := dbms_pipe.receive_message(par_pipe,0);
      if var_status > 1 then
         raise_application_error(-20000, 'LICS_PIPE - Update Pipe - Unable to receive message from pipe (' || par_pipe || ')');
      end if;
      if var_status = 0 then
         dbms_pipe.unpack_message(var_message);
         if var_message = lics_constant.pipe_wake then
            var_message := par_message;
         elsif var_message = lics_constant.pipe_suspend then
            if par_message <> lics_constant.pipe_wake then
               var_message := par_message;
            end if;
         elsif var_message = lics_constant.pipe_release then
            if par_message <> lics_constant.pipe_wake then
               var_message := par_message;
            end if;
         elsif var_message = lics_constant.pipe_stop then
            var_message := var_message;
         end if;
      elsif var_status = 1 then
         var_message := par_message;
      end if;

      /*-*/
      /* Send the message to the pipe
      /*-*/
      dbms_pipe.pack_message(var_message);
      var_status := dbms_pipe.send_message(par_pipe);
      if var_status <> 0 then
         raise_application_error(-20000, 'LICS_PIPE - Update Pipe - Unable to send message to pipe (' || par_pipe || ')');
      end if;

      /*-*/
      /* Release the pipe lock
      /*-*/
      var_status := dbms_lock.release(var_lock_handle);

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         var_message := substr(SQLERRM, 1, 1024);
         if var_locked = true then
            begin
               var_status := dbms_lock.release(var_lock_handle);
            exception
               when others then
                  null;
            end;
         end if;
         raise_application_error(-20000, var_message);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_pipe;

end lics_pipe;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_pipe for lics_app.lics_pipe;
grant execute on lics_pipe to public;
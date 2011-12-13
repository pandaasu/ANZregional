/******************/
/* Package Header */
/******************/
create or replace package lics_stream_monitor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_stream_monitor
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - Stream Monitor

    The package implements the stream monitor functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function get_nodes(par_exe_seqn in number) return lics_strvew_table pipelined;

end lics_stream_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_stream_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /**************************************************/
   /* This procedure performs the get stream routine */
   /**************************************************/
   function get_nodes(par_exe_seqn in number) return lics_strvew_table pipelined is

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_header is 
         select t01.*
           from lics_str_exe_header t01
          where t01.sth_exe_seqn = par_exe_seqn;
      rcd_header csr_header%rowtype;

      cursor csr_task is
         select level,
                 t01.*
           from lics_str_exe_task t01
          where t01.stt_exe_seqn = rcd_header.sth_exe_seqn
          start with t01.stt_tsk_pcde = '*TOP'
        connect by prior t01.stt_exe_seqn = t01.stt_exe_seqn
                and prior t01.stt_tsk_code = t01.stt_tsk_pcde
          order siblings by t01.stt_tsk_type asc,
                            t01.stt_tsk_seqn asc;
      rcd_task csr_task%rowtype;

      cursor csr_param is
         select t01.*
           from lics_str_exe_param t01
          where t01.stp_exe_seqn = rcd_header.sth_exe_seqn
          order by t01.stp_par_code asc;
      rcd_param csr_param%rowtype;

      cursor csr_depend is
         select t01.*
           from lics_str_exe_depend t01
          where t01.std_exe_seqn = rcd_task.stt_exe_seqn
            and t01.std_tsk_code = rcd_task.stt_tsk_code
          order by t01.std_dep_code asc;
      rcd_depend csr_depend%rowtype;

      cursor csr_event is
         select t01.*
           from lics_str_exe_event t01
          where t01.ste_exe_seqn = rcd_task.stt_exe_seqn
            and t01.ste_tsk_code = rcd_task.stt_tsk_code
          order by t01.ste_evt_seqn asc;
      rcd_event csr_event%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Pipe the stream root node
      /*-*/
      open csr_header;
      fetch csr_header into rcd_header;
      if csr_header%found then
         pipe row(lics_strvew_object(0,
                                     'S',
                                     rcd_header.sth_str_code,
                                     rcd_header.sth_str_text,
                                     rcd_header.sth_exe_seqn,
                                     rcd_header.sth_exe_text,
                                     rcd_header.sth_exe_status,
                                     rcd_header.sth_exe_request,
                                     to_char(rcd_header.sth_exe_load,'yyyy/mm/dd hh24:mi:ss'),
                                     to_char(rcd_header.sth_exe_start,'yyyy/mm/dd hh24:mi:ss'),
                                     to_char(rcd_header.sth_exe_end,'yyyy/mm/dd hh24:mi:ss'),
                                     null,
                                     null,
                                     null,
                                     null));
         open csr_param;
         loop
            fetch csr_param into rcd_param;
            if csr_param%notfound then
               exit;
            end if;
            pipe row(lics_strvew_object(0,
                                        'P',
                                        rcd_param.stp_par_code,
                                        rcd_param.stp_par_text,
                                        rcd_param.stp_par_value,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null));
         end loop;
         close csr_param;

         /*-*/
         /* Pipe the stream task nodes
         /*-*/
         open csr_task;
         loop
            fetch csr_task into rcd_task;
            if csr_task%notfound then
               exit;
            end if;
            if rcd_task.stt_tsk_type = '*EXEC' then
               pipe row(lics_strvew_object(rcd_task.level,
                                           'T',
                                           rcd_task.stt_tsk_code,
                                           rcd_task.stt_tsk_text,
                                           rcd_task.stt_exe_status,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null));
               open csr_event;
               loop
                  fetch csr_event into rcd_event;
                  if csr_event%notfound then
                     exit;
                  end if;
                  pipe row(lics_strvew_object(rcd_task.level+1,
                                              'E',
                                              rcd_event.ste_evt_code,
                                              rcd_event.ste_evt_text,
                                              rcd_event.ste_evt_lock,
                                              rcd_event.ste_evt_proc,
                                              rcd_event.ste_job_group,
                                              rcd_event.ste_opr_alert,
                                              rcd_event.ste_ema_group,
                                              rcd_event.ste_exe_status,
                                              rcd_event.ste_exe_message,
                                              null,
                                              null,
                                              null,
                                              null));
               end loop;
               close csr_event;
            else
               pipe row(lics_strvew_object(rcd_task.level,
                                           'G',
                                           rcd_task.stt_tsk_code,
                                           rcd_task.stt_tsk_text,
                                           rcd_task.stt_exe_status,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null));
               open csr_depend;
               loop
                  fetch csr_depend into rcd_depend;
                  if csr_depend%notfound then
                     exit;
                  end if;
                  pipe row(lics_strvew_object(rcd_task.level,
                                              'D',
                                              rcd_depend.std_tsk_code,
                                              rcd_depend.std_dep_code,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null));
               end loop;
               close csr_depend;
            end if;
         end loop;
         close csr_task;

      end if;

      /*-*/
      /* Return
      /*-*/  
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'ICS_STREAM_MONITOR - GET_NODES - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_nodes;

end lics_stream_monitor;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_stream_monitor for lics_app.lics_stream_monitor;
grant execute on lics_stream_monitor to public;
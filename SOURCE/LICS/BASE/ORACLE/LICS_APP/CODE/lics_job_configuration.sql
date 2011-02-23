/******************/
/* Package Header */
/******************/
create or replace package lics_job_configuration as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_job_configuration
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Job Configuration

 The package implements the job configuration functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/11   Steve Gregan   Added poller functionality
 2011/02   Steve Gregan   End point architecture version

*******************************************************************************/

   /**/
   /* Public declarations
   /**/
   function insert_job(par_job in varchar2,
                       par_description in varchar2,
                       par_res_group in varchar2,
                       par_exe_history in number,
                       par_opr_alert in varchar2,
                       par_ema_group in varchar2,
                       par_type in varchar2,
                       par_int_group in varchar2,
                       par_procedure in varchar2,
                       par_next in varchar2,
                       par_interval in varchar2,
                       par_status in varchar2) return varchar2;
   function update_job(par_job in varchar2,
                       par_description in varchar2,
                       par_res_group in varchar2,
                       par_exe_history in number,
                       par_opr_alert in varchar2,
                       par_ema_group in varchar2,
                       par_type in varchar2,
                       par_int_group in varchar2,
                       par_procedure in varchar2,
                       par_next in varchar2,
                       par_interval in varchar2,
                       par_status in varchar2) return varchar2;
   function delete_job(par_job in varchar2) return varchar2;

end lics_job_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_job_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_job lics_job%rowtype;

   /*************************************************/
   /* This function performs the insert job routine */
   /*************************************************/
   function insert_job(par_job in varchar2,
                       par_description in varchar2,
                       par_res_group in varchar2,
                       par_exe_history in number,
                       par_opr_alert in varchar2,
                       par_ema_group in varchar2,
                       par_type in varchar2,
                       par_int_group in varchar2,
                       par_procedure in varchar2,
                       par_next in varchar2,
                       par_interval in varchar2,
                       par_status in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);
      var_hash_error boolean;
      var_hash_count number;
      var_hash_index number;
      var_interval number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_job_01 is 
         select *
           from lics_job t01
          where t01.job_job = rcd_lics_job.job_job;
      rcd_lics_job_01 csr_lics_job_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Job Configuration - Insert Job';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_job.job_job := upper(par_job);
      rcd_lics_job.job_description := par_description;
      rcd_lics_job.job_res_group := par_res_group;
      rcd_lics_job.job_exe_history := par_exe_history;
      rcd_lics_job.job_opr_alert := par_opr_alert;
      rcd_lics_job.job_ema_group := par_ema_group;
      rcd_lics_job.job_type := upper(par_type);
      rcd_lics_job.job_int_group := upper(par_int_group);
      rcd_lics_job.job_procedure := par_procedure;
      rcd_lics_job.job_next := par_next;
      rcd_lics_job.job_interval := par_interval;
      rcd_lics_job.job_status := par_status;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_job.job_job is null then
         var_message := var_message || chr(13) || 'Job must be specified';
      end if;
      if rcd_lics_job.job_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_lics_job.job_exe_history <= 0 then
         var_message := var_message || chr(13) || 'Execution history must be greater than zero';
      end if;
      if rcd_lics_job.job_type != lics_constant.type_file and
         rcd_lics_job.job_type != lics_constant.type_inbound and
         rcd_lics_job.job_type != lics_constant.type_outbound and
         rcd_lics_job.job_type != lics_constant.type_passthru and
         rcd_lics_job.job_type != lics_constant.type_daemon and
         rcd_lics_job.job_type != lics_constant.type_poller and
         rcd_lics_job.job_type != lics_constant.type_procedure then
         var_message := var_message || chr(13) || 'Job type must be *FILE, *INBOUND, *OUTBOUND, *PASSTHRU, *DAEMON, *POLLER or *PROCEDURE';
      end if;
      if rcd_lics_job.job_type = lics_constant.type_file or
         rcd_lics_job.job_type = lics_constant.type_inbound or
         rcd_lics_job.job_type = lics_constant.type_outbound or
         rcd_lics_job.job_type = lics_constant.type_passthru or
         rcd_lics_job.job_type = lics_constant.type_daemon or
         rcd_lics_job.job_type = lics_constant.type_poller then
         if rcd_lics_job.job_int_group is null then
            var_message := var_message || chr(13) || 'Job group must be specified for *FILE, *INBOUND, *OUTBOUND, *PASSTHRU, *DAEMON or *POLLER';
         else
            var_hash_error := false;
            var_hash_count := 0;
            var_hash_index := 0;
            for idx_count in 1..length(rcd_lics_job.job_int_group) loop
               if substr(rcd_lics_job.job_int_group, idx_count, 1) < 'A' or substr(rcd_lics_job.job_int_group, idx_count, 1) > 'Z' then
                  if substr(rcd_lics_job.job_int_group, idx_count, 1) < '0' or substr(rcd_lics_job.job_int_group, idx_count, 1) > '9' then
                     if substr(rcd_lics_job.job_int_group, idx_count, 1) <> '_' then
                        if substr(rcd_lics_job.job_int_group, idx_count, 1) <> '#' then
                           var_hash_error := true;
                        else
                           var_hash_count := var_hash_count + 1;
                           var_hash_index := idx_count;
                        end if;
                     end if;
                  end if;
               end if;
            end loop;
            if var_hash_error = true then
               var_message := var_message || chr(13) || 'Job group - characters must be A-Z, 0-9, _(underscore), #(hash)';
            end if;
            if var_hash_count > 1 then
               var_message := var_message || chr(13) || 'Job group - only one parallel separator (#) allowed';
            end if;
            if var_hash_count = 1 then
               if var_hash_index = 1 or var_hash_index = length(rcd_lics_job.job_int_group) then
                  var_message := var_message || chr(13) || 'Job group - parallel separator (#) must not be in first or last position';
               end if;
            end if;
         end if;
         if rcd_lics_job.job_type = lics_constant.type_daemon or
            rcd_lics_job.job_type = lics_constant.type_poller then
            if rcd_lics_job.job_procedure is null then
               var_message := var_message || chr(13) || 'Job procedure must be specified for *DAEMON or *POLLER';
            end if;
         else
            if not(rcd_lics_job.job_procedure is null) then
               var_message := var_message || chr(13) || 'Job procedure must not be specified for *FILE, *INBOUND, *OUTBOUND, *PASSTHRU';
            end if;
         end if;
         if upper(rcd_lics_job.job_next) != 'SYSDATE' then
            var_message := var_message || chr(13) || 'Job next must be SYSDATE for *FILE, *INBOUND, *OUTBOUND, *PASSTHRU, *DAEMON or *POLLER';
         end if;
         if rcd_lics_job.job_type = lics_constant.type_poller then
            if rcd_lics_job.job_interval is null then
               var_message := var_message || chr(13) || 'Job interval must be specified for *POLLER';
            else
               begin
                  var_interval := to_number(trim(rcd_lics_job.job_interval));
               exception
                  when others then
                     var_message := var_message || chr(13) || 'Job interval must be numeric for *POLLER';
               end;
            end if;
         else
            if not(rcd_lics_job.job_interval is null) then
               var_message := var_message || chr(13) || 'Job interval must not be specified for *FILE, *INBOUND, *OUTBOUND, *PASSTHRU or *DAEMON';
            end if;
         end if;
      else
         if not(rcd_lics_job.job_int_group is null) then
            var_message := var_message || chr(13) || 'Job group must not be specified for *PROCEDURE';
         end if;
         if rcd_lics_job.job_procedure is null then
            var_message := var_message || chr(13) || 'Job procedure must be specified for *PROCEDURE';
         end if;
         if rcd_lics_job.job_next is null then
            var_message := var_message || chr(13) || 'Job next must be specified for *PROCEDURE';
         end if;
         if rcd_lics_job.job_interval is null then
            var_message := var_message || chr(13) || 'Job interval must be specified for *PROCEDURE';
         end if;
      end if;
      if rcd_lics_job.job_status != lics_constant.status_inactive and
         rcd_lics_job.job_status != lics_constant.status_active then
         var_message := var_message || chr(13) || 'Status must be active or inactive';
      end if;

      /*-*/
      /* Job must not already exist
      /*-*/
      open csr_lics_job_01;
      fetch csr_lics_job_01 into rcd_lics_job_01;
      if csr_lics_job_01%found then
         var_message := var_message || chr(13) || 'Job (' || rcd_lics_job.job_job || ') already exists';
      end if;
      close csr_lics_job_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new job
      /*-*/
      insert into lics_job
         (job_job,
          job_description,
          job_res_group,
          job_exe_history,
          job_opr_alert,
          job_ema_group,
          job_type,
          job_int_group,
          job_procedure,
          job_next,
          job_interval,
          job_status)
         values(rcd_lics_job.job_job,
                rcd_lics_job.job_description,
                rcd_lics_job.job_res_group,
                rcd_lics_job.job_exe_history,
                rcd_lics_job.job_opr_alert,
                rcd_lics_job.job_ema_group,
                rcd_lics_job.job_type,
                rcd_lics_job.job_int_group,
                rcd_lics_job.job_procedure,
                rcd_lics_job.job_next,
                rcd_lics_job.job_interval,
                rcd_lics_job.job_status);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
   end insert_job;

   /*************************************************/
   /* This function performs the update job routine */
   /*************************************************/
   function update_job(par_job in varchar2,
                       par_description in varchar2,
                       par_res_group in varchar2,
                       par_exe_history in number,
                       par_opr_alert in varchar2,
                       par_ema_group in varchar2,
                       par_type in varchar2,
                       par_int_group in varchar2,
                       par_procedure in varchar2,
                       par_next in varchar2,
                       par_interval in varchar2,
                       par_status in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);
      var_hash_error boolean;
      var_hash_count number;
      var_hash_index number;
      var_interval number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_job_01 is 
         select *
           from lics_job t01
          where t01.job_job = rcd_lics_job.job_job;
      rcd_lics_job_01 csr_lics_job_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Job Configuration - Update Job';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_job.job_job := upper(par_job);
      rcd_lics_job.job_description := par_description;
      rcd_lics_job.job_res_group := par_res_group;
      rcd_lics_job.job_exe_history := par_exe_history;
      rcd_lics_job.job_opr_alert := par_opr_alert;
      rcd_lics_job.job_ema_group := par_ema_group;
      rcd_lics_job.job_type := upper(par_type);
      rcd_lics_job.job_int_group := upper(par_int_group);
      rcd_lics_job.job_procedure := par_procedure;
      rcd_lics_job.job_next := par_next;
      rcd_lics_job.job_interval := par_interval;
      rcd_lics_job.job_status := par_status;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_job.job_job is null then
         var_message := var_message || chr(13) || 'Job must be specified';
      end if;
      if rcd_lics_job.job_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_lics_job.job_exe_history <= 0 then
         var_message := var_message || chr(13) || 'Execution history must be greater than zero';
      end if;
      if rcd_lics_job.job_type = lics_constant.type_file or
         rcd_lics_job.job_type = lics_constant.type_inbound or
         rcd_lics_job.job_type = lics_constant.type_outbound or
         rcd_lics_job.job_type = lics_constant.type_passthru or
         rcd_lics_job.job_type = lics_constant.type_daemon or
         rcd_lics_job.job_type = lics_constant.type_poller then
         if rcd_lics_job.job_int_group is null then
            var_message := var_message || chr(13) || 'Job group must be specified for *FILE, *INBOUND, *OUTBOUND, *PASSTHRU, *DAEMON or *POLLER';
         else
            var_hash_error := false;
            var_hash_count := 0;
            var_hash_index := 0;
            for idx_count in 1..length(rcd_lics_job.job_int_group) loop
               if substr(rcd_lics_job.job_int_group, idx_count, 1) < 'A' or substr(rcd_lics_job.job_int_group, idx_count, 1) > 'Z' then
                  if substr(rcd_lics_job.job_int_group, idx_count, 1) < '0' or substr(rcd_lics_job.job_int_group, idx_count, 1) > '9' then
                     if substr(rcd_lics_job.job_int_group, idx_count, 1) <> '_' then
                        if substr(rcd_lics_job.job_int_group, idx_count, 1) <> '#' then
                           var_hash_error := true;
                        else
                           var_hash_count := var_hash_count + 1;
                           var_hash_index := idx_count;
                        end if;
                     end if;
                  end if;
               end if;
            end loop;
            if var_hash_error = true then
               var_message := var_message || chr(13) || 'Job group - characters must be A-Z, 0-9, _(underscore), #(hash)';
            end if;
            if var_hash_count > 1 then
               var_message := var_message || chr(13) || 'Job group - only one parallel separator (#) allowed';
            end if;
            if var_hash_count = 1 then
               if var_hash_index = 1 or var_hash_index = length(rcd_lics_job.job_int_group) then
                  var_message := var_message || chr(13) || 'Job group - parallel separator (#) must not be in first or last position';
               end if;
            end if;
         end if;
         if rcd_lics_job.job_type = lics_constant.type_daemon or
            rcd_lics_job.job_type = lics_constant.type_poller then
            if rcd_lics_job.job_procedure is null then
               var_message := var_message || chr(13) || 'Job procedure must be specified for *DAEMON or *POLLER';
            end if;
         else
            if not(rcd_lics_job.job_procedure is null) then
               var_message := var_message || chr(13) || 'Job procedure must not be specified for *FILE, *INBOUND, *OUTBOUND, *PASSTHRU';
            end if;
         end if;
         if upper(rcd_lics_job.job_next) != 'SYSDATE' then
            var_message := var_message || chr(13) || 'Job next must be SYSDATE for *FILE, *INBOUND, *OUTBOUND, *PASSTHRU, *DAEMON or *POLLER';
         end if;
         if rcd_lics_job.job_type = lics_constant.type_poller then
            if rcd_lics_job.job_interval is null then
               var_message := var_message || chr(13) || 'Job interval must be specified for *POLLER';
            else
               begin
                  var_interval := to_number(trim(rcd_lics_job.job_interval));
               exception
                  when others then
                     var_message := var_message || chr(13) || 'Job interval must be numeric for *POLLER';
               end;
            end if;
         else
            if not(rcd_lics_job.job_interval is null) then
               var_message := var_message || chr(13) || 'Job interval must not be specified for *FILE, *INBOUND, *OUTBOUND, *PASSTHRU or *DAEMON';
            end if;
         end if;
      else
         if not(rcd_lics_job.job_int_group is null) then
            var_message := var_message || chr(13) || 'Job group must not be specified for *PROCEDURE';
         end if;
         if rcd_lics_job.job_procedure is null then
            var_message := var_message || chr(13) || 'Job procedure must be specified for *PROCEDURE';
         end if;
         if rcd_lics_job.job_next is null then
            var_message := var_message || chr(13) || 'Job next must be specified for *PROCEDURE';
         end if;
         if rcd_lics_job.job_interval is null then
            var_message := var_message || chr(13) || 'Job interval must be specified for *PROCEDURE';
         end if;
      end if;
      if rcd_lics_job.job_status != lics_constant.status_inactive and
         rcd_lics_job.job_status != lics_constant.status_active then
         var_message := var_message || chr(13) || 'Status must be active or inactive';
      end if;

      /*-*/
      /* Job must already exist and be the same type
      /*-*/
      open csr_lics_job_01;
      fetch csr_lics_job_01 into rcd_lics_job_01;
      if csr_lics_job_01%notfound then
         var_message := var_message || chr(13) || 'Job (' || rcd_lics_job.job_job || ') does not exist';
      end if;
      close csr_lics_job_01;
      if rcd_lics_job.job_type != rcd_lics_job_01.job_type then
         var_message := var_message || chr(13) || 'Job type must be the same as the existing job type (' || rcd_lics_job_01.job_type || ')';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing job
      /*-*/
      update lics_job
         set job_description = rcd_lics_job.job_description,
             job_res_group = rcd_lics_job.job_res_group,
             job_exe_history = rcd_lics_job.job_exe_history,
             job_opr_alert = rcd_lics_job.job_opr_alert,
             job_ema_group = rcd_lics_job.job_ema_group,
             job_type = rcd_lics_job.job_type,
             job_int_group = rcd_lics_job.job_int_group,
             job_procedure = rcd_lics_job.job_procedure,
             job_next = rcd_lics_job.job_next,
             job_interval = rcd_lics_job.job_interval,
             job_status = rcd_lics_job.job_status
         where job_job = rcd_lics_job.job_job;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
   end update_job;

   /*************************************************/
   /* This function performs the delete job routine */
   /*************************************************/
   function delete_job(par_job in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_job_01 is 
         select *
           from lics_job t01
          where t01.job_job = rcd_lics_job.job_job;
      rcd_lics_job_01 csr_lics_job_01%rowtype;

      cursor csr_lics_job_trace_01 is 
         select 'x'
           from lics_job_trace t01,
                lics_hdr_trace t02
          where t01.jot_job = rcd_lics_job.job_job
            and t01.jot_execution = t02.het_execution;
      rcd_lics_job_trace_01 csr_lics_job_trace_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Job Configuration - Delete Job';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_job.job_job := upper(par_job);

      /*-*/
      /* Job must already exist
      /*-*/
      open csr_lics_job_01;
      fetch csr_lics_job_01 into rcd_lics_job_01;
      if csr_lics_job_01%notfound then
         var_message := var_message || chr(13) || 'Job (' || rcd_lics_job.job_job || ') does not exist';
      end if;
      close csr_lics_job_01;

      /*-*/
      /* Job must have no interface history
      /*-*/
      open csr_lics_job_trace_01;
      fetch csr_lics_job_trace_01 into rcd_lics_job_trace_01;
      if csr_lics_job_trace_01%found then
         var_message := var_message || chr(13) || 'Job (' || rcd_lics_job.job_job || ') has interface header history attached';
      end if;
      close csr_lics_job_trace_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing job and trace data
      /*-*/
      delete from lics_job_trace
         where jot_job = rcd_lics_job.job_job;
      delete from lics_job
         where job_job = rcd_lics_job.job_job;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
   end delete_job;

end lics_job_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_job_configuration for lics_app.lics_job_configuration;
grant execute on lics_job_configuration to public;
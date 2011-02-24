/******************/
/* Package Header */
/******************/
create or replace package lics_file_processor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_file_processor
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - File Processor

    The package implements the file processor functionality.

    1. This package has been designed as a single instance class to facilitate
       re-engineering in an object oriented language. That is, in an OO environment
       the host would create one or more instances of this class and pass the reference
       to the target objects. However, in the PL/SQL environment only one global instance
       is available at any one time.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/02   Steve Gregan   End point architecture version

   *******************************************************************************/

   /**/
   /* Public declarations
   /**/
   procedure execute(par_group in varchar2,
                     par_job in varchar2,
                     par_execution in number);

end lics_file_processor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_file_processor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /**/
   /* Private declarations
   /**/
   procedure select_file;

   /*-*/
   /* Private definitions
   /*-*/
   cnt_process_count constant number(5,0) := 50;
   type typ_process is table of number(15,0) index by binary_integer;
   tbl_process typ_process;
   var_ctl_pipe varchar2(128);
   var_ctl_wake boolean;
   var_ctl_suspend boolean;
   var_ctl_stop boolean;
   rcd_lics_interface lics_interface%rowtype;
   rcd_lics_file lics_file%rowtype;
   var_group lics_job.job_int_group%type;
   var_search lics_job.job_int_group%type;
   var_job lics_job.job_job%type;
   var_execution lics_job_trace.jot_execution%type;

   /*******************************************************/
   /* This procedure performs the execute process routine */
   /*******************************************************/
   procedure execute(par_group in varchar2,
                     par_job in varchar2,
                     par_execution in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_suspended boolean;
      var_message varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameter variable
      /*-*/
      var_group := par_group;
      var_job := par_job;
      var_execution := par_execution;
      var_search := par_group;
      if instr(var_search,'#',1,1) <> 0 then
         var_search := substr(var_search,1,instr(var_search,'#',1,1)-1);
      end if;

      /*-*/
      /* Set the controls
      /*-*/
      var_ctl_pipe := lics_constant.queue_file || var_group;
      var_ctl_wake := false;
      var_ctl_suspend := false;
      var_ctl_stop := false;
      var_suspended := false;

      /*-*/
      /* Process the file group until stop requested
      /*-*/
      loop

         /*-*/
         /* Select the interface when requested
         /*-*/
         if var_suspended = false then

            /*-*/
            /* Update the job trace status
            /*-*/
            update lics_job_trace
               set jot_status = lics_constant.job_working
             where jot_execution = var_execution;
            if sql%notfound then
               raise_application_error(-20000, 'Execute - Job trace (' || to_char(var_execution,'FM999999999999990') || ') does not exist');
            end if;
            commit;

            /*-*/
            /* Select the files until exhausted
            /*-*/
            loop
               var_ctl_wake := false;
               var_ctl_suspend := false;
               var_ctl_stop := false;
               select_file;
               if var_ctl_suspend = true then
                  var_suspended := true;
               end if;
               if var_ctl_wake = false or
                  var_ctl_suspend = true or
                  var_ctl_stop = true then
                  exit;
               end if;
            end loop;

            /*-*/
            /* Exit when requested
            /*-*/
            if var_ctl_stop = true then
               exit;
            end if;

         end if;

         /*-*/
         /* Update the job trace status
         /*-*/
         if var_suspended = false then
            update lics_job_trace
               set jot_status = lics_constant.job_idle
             where jot_execution = var_execution;
         else
            update lics_job_trace
               set jot_status = lics_constant.job_suspended
             where jot_execution = var_execution;
         end if;
         if sql%notfound then
            raise_application_error(-20000, 'Execute - Job trace (' || to_char(var_execution,'FM999999999999990') || ') does not exist');
         end if;
         commit;

         /*-*/
         /* Wait for pipe message (blocked - no maximum)
         /* **note** this is the sleep code
         /*-*/
         var_message := lics_pipe.receive(var_ctl_pipe);
         if trim(var_message) = lics_constant.pipe_stop then
            exit;
         end if;
         if trim(var_message) = lics_constant.pipe_suspend then
            var_suspended := true;
         end if;
         if trim(var_message) = lics_constant.pipe_release then
            var_suspended := false;
         end if;

      end loop; 

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
            lics_notification.log_fatal(var_job,
                                        var_execution,
                                        lics_constant.type_outbound,
                                        var_group,
                                        null,
                                        null,
                                        null,
                                        null,
                                        'FILE PROCESSOR FAILED - ' || substr(SQLERRM, 1, 1024));
         exception
            when others then
               raise_application_error(-20000, 'FATAL ERROR - Interface Control System - File Processor - ' || substr(SQLERRM, 1, 1024));
         end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***************************************************/
   /* This procedure performs the select file routine */
   /***************************************************/
   procedure select_file is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;
      var_check varchar2(4000);
      var_lod_error boolean;
      var_fil_file lics_file.fil_file%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_interface_01 is 
         select t01.*
           from lics_interface t01
          where t01.int_type in (lics_constant.type_inbound, lics_constant.type_passthru)
            and t01.int_lod_type = '*POLL'
            and t01.int_lod_group = var_search
            and t01.int_status = lics_constant.status_active
       order by t01.int_priority asc,
                t01.int_interface asc;
      rcd_lics_interface_01 csr_lics_interface_01%rowtype;

      cursor csr_all_directories_01 is 
         select t01.directory_path
           from all_directories t01
          where t01.directory_name = rcd_lics_interface_01.int_fil_path;
      rcd_all_directories_01 csr_all_directories_01%rowtype;

      cursor csr_lics_file_01 is 
         select t01.fil_name
           from lics_file t01
          where t01.fil_path = rcd_lics_interface.int_interface
            and t01.fil_status = lics_constant.file_available
       order by t01.fil_file asc;
      rcd_lics_file_01 csr_lics_file_01%rowtype;

      cursor csr_lics_file_02 is 
         select t01.fil_file,
                t01.fil_name,
                t01.fil_status
           from lics_file t01
          where t01.fil_file = var_fil_file
                for update nowait;
      rcd_lics_file_02 csr_lics_file_02%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the interfaces related to the process
      /* notes - status = status_active
      /*       - sorted by priority ascending
      /*-*/
      open csr_lics_interface_01;
      loop
         fetch csr_lics_interface_01 into rcd_lics_interface_01;
         if csr_lics_interface_01%notfound then
            exit;
         end if;

         /*-*/
         /* Set the private interface variables
         /*-*/
         rcd_lics_interface.int_interface := rcd_lics_interface_01.int_interface;
         rcd_lics_interface.int_description := rcd_lics_interface_01.int_description;
         rcd_lics_interface.int_type := rcd_lics_interface_01.int_type;
         rcd_lics_interface.int_group := rcd_lics_interface_01.int_group;
         rcd_lics_interface.int_fil_path := rcd_lics_interface_01.int_fil_path;
         rcd_lics_interface.int_opr_alert := rcd_lics_interface_01.int_opr_alert;
         rcd_lics_interface.int_ema_group := rcd_lics_interface_01.int_ema_group;

         /*-*/
         /* Retrieve the operating system directory name from the oracle directory
         /*-*/
         open csr_all_directories_01;
         fetch csr_all_directories_01 into rcd_all_directories_01;
         if csr_all_directories_01%notfound then
            raise_application_error(-20000, 'Select Interface - Directory (' || rcd_lics_interface_01.int_fil_path || ') does not exist');
         end if;
         close csr_all_directories_01;
         rcd_lics_interface.int_fil_path := rcd_all_directories_01.directory_path;

         /*-*/
         /* Process files in batches (based on process count constant)
         /*-*/
         loop

            /*-*/
            /* Retrieve the files related to the interface
            /* notes - status = file_available
            /*       - sorted by file ascending
            /*       - next processing count group
            /*-*/
            tbl_process.delete;
            open csr_lics_file_01;
            loop
               fetch csr_lics_file_01 into rcd_lics_file_01;
               if csr_lics_file_01%notfound then
                  exit;
               end if;
               tbl_process(tbl_process.count + 1) := rcd_lics_file_01.fil_file;
               if tbl_process.count >= cnt_process_count then
                  exit;
               end if;
            end loop;
            close csr_lics_file_01;

            /*-*/
            /* Break the processing loop when required
            /*-*/
            if tbl_process.count = 0 then
               exit;
            end if;

            /*-*/
            /* Process the current group of files
            /*-*/
            for idx in 1..tbl_process.count loop

               /*-*/
               /* Set the next file
               /*-*/
               var_fil_file := tbl_process(idx);

               /*-*/
               /* Attempt to lock the file row
               /* notes - must still exist
               /*         must still be status = file_available
               /*         must not be locked
               /*-*/
               var_available := true;
               begin
                  open csr_lics_file_02;
                  fetch csr_lics_file_02 into rcd_lics_file_02;
                  if csr_lics_file_02%notfound then
                     var_available := false;
                  end if;
                  if rcd_lics_file_02.fil_status <> lics_constant.file_available then
                     var_available := false;
                  end if;
               exception
                  when others then
                     var_available := false;
               end;
               if csr_lics_file_02%isopen then
                  close csr_lics_file_02;
               end if;

               /*-*/
               /* Release the file lock when not available
               /* 1. Cursor row locks are not released until commit or rollback
               /* 2. Cursor close does not release row locks
               /*-*/
               if var_available = false then

                  /*-*/
                  /* Rollback to release row locks
                  /*-*/
                  rollback;

               /*-*/
               /* Process the file when available
               /*-*/
               else

                  /*-*/
                  /* Initialise the file data
                  /*-*/
                  rcd_lics_file.fil_file := rcd_lics_file_02.fil_file;
                  rcd_lics_file.fil_name := rcd_lics_file_02.fil_name;
                  rcd_lics_file.fil_message := null;

                  /*-*/
                  /* Load the interface based on the interface type
                  /*-*/
                  var_lod_error := false;
                  begin
                     if upper(rcd_lics_interface.int_type) = '*INBOUND' then
                        lics_inbound_loader.execute(rcd_lics_interface.int_interface, rcd_lics_file.fil_name);
                     elsif upper(rcd_lics_interface.int_type) = '*PASSTHRU' then
                        lics_passthru_loader.execute(rcd_lics_interface.int_interface, rcd_lics_file.fil_name);
                     end if;
                  exception
                     when others then
                        var_lod_error := true;
                        if upper(rcd_lics_interface.int_type) = '*INBOUND' then
                           rcd_lics_file.fil_message := 'Inbound loader failed - ' || substr(SQLERRM, 1, 1536);
                        elsif upper(rcd_lics_interface.int_type) = '*PASSTHRU' then
                           rcd_lics_file.fil_message := 'Passthru loader failed - ' || substr(SQLERRM, 1, 1536);
                        end if;
                  end;

                  /*-*/
                  /* Archive the interface file when required
                  /*-*/
                  if upper(rcd_lics_interface.int_type) = '*INBOUND' then
                     if var_lod_error = false then
                        begin
                           lics_filesystem.archive_file_gzip(rcd_lics_interface.int_fil_path, rcd_lics_file.fil_name, lics_parameter.archive_directory, rcd_lics_file.fil_name||'.gz', '1');
                        exception
                           when others then
                              var_lod_error := true;
                              rcd_lics_file.fil_message := 'File Archive failed - ' || substr(SQLERRM, 1, 1536);
                        end;
                     end if;
                  end if;

                  /*-*/
                  /* Delete/update the file as required
                  /*-*/
                  if var_lod_error = false then
                     delete from lics_file
                      where fil_file = rcd_lics_file.fil_file;
                  else
                     rcd_lics_file.fil_status := lics_constant.file_error;
                     update lics_file
                        set fil_status = rcd_lics_file.fil_status,
                            fil_message = rcd_lics_file.fil_message
                      where fil_file = rcd_lics_file.fil_file;
                  end if;

                  /*-*/
                  /* Commit the database
                  /*-*/
                  commit;

                  /*-*/
                  /* Log the file event
                  /*-*/
                  if var_lod_error = false then
                     lics_notification.log_success(var_job,
                                                   var_execution,
                                                   lics_constant.type_file,
                                                   rcd_lics_interface.int_lod_group,
                                                   null,
                                                   rcd_lics_interface.int_interface,
                                                   rcd_lics_file.fil_file,
                                                   null,
                                                   'FILE PROCESSOR SUCCESS');
                  else
                     lics_notification.log_error(var_job,
                                                 var_execution,
                                                 lics_constant.type_file,
                                                 rcd_lics_interface.int_lod_group,
                                                 null,
                                                 rcd_lics_interface.int_interface,
                                                 rcd_lics_file.fil_file,
                                                 null,
                                                 'FILE PROCESSOR ERROR - see file message for more details',
                                                 rcd_lics_interface.int_opr_alert,
                                                 rcd_lics_interface.int_ema_group);
                  end if;

               end if;

            end loop;

            /*-*/
            /* Check the pipe for new message
            /*
            /* **notes**
            /* 1. Wake - continue and remember the state to process any interfaces already passed
            /* 2. Suspend - break the processing and suspend the processor
            /* 3. Release - continue and reset the suspend control
            /* 4. Stop - break the processing and stop the processor
            /* 5. Default - continue and ignore the instruction
            /*-*/
            var_check := lics_pipe.check_queue(var_ctl_pipe);
            case trim(var_check)
               when lics_constant.pipe_wake then
                  var_ctl_wake := true;
               when lics_constant.pipe_suspend then
                  var_ctl_suspend := true;
               when lics_constant.pipe_release then
                  var_ctl_suspend := false;
               when lics_constant.pipe_stop then
                  var_ctl_stop := true;
               else
                  null;
            end case;
            if var_ctl_suspend = true or
               var_ctl_stop = true then
               exit;
            end if;

         end loop;

         /*-*/
         /* Break the loop when required
         /*-*/
         if var_ctl_suspend = true or
            var_ctl_stop = true then
            exit;
         end if;

      end loop;
      close csr_lics_interface_01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_file;

end lics_file_processor;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_file_processor for lics_app.lics_file_processor;
grant execute on lics_file_processor to public;
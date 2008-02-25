/******************/
/* Package Header */
/******************/
create or replace package lics_outbound_loader as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_outbound_loader
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Outbound Loader

 The package implements the outbound loader functionality.

 1. Applications can only create outbound interface instances using
    the supplied procedures in this package.

 2. The outbound loader can be aborted at any time using the
    add exception method.

 3. The host application is responsible for deciding the type of exception
    processing. The implementation can choose to abort the interface on the
    first exception (invoke the finalise interface method) or load all exceptions
    before aborting the interface. The architecture supports multiple exceptions
    for each outbound interface.

 4. This package has been designed as a single instance class to facilitate
    re-engineering in an object oriented language. That is, in an OO environment
    the host would create one or more instances of this class and pass the reference
    to the target objects. However, in the PL/SQL environment only one global instance
    is available at any one time.

 5. All methods have been implemented as autonomous transactions so as not
    to interfere with the commit boundaries of the host application.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2006/08   Steve Gregan   Added search functionality
 2006/08   Steve Gregan   Added message name functionality
 2008/03   Steve Gregan   Added append raw functionality

*******************************************************************************/

   /**/
   /* Public declarations
   /**/
   function create_interface(par_interface in varchar2) return number;
   function create_interface(par_interface in varchar2, par_fil_name in varchar2) return number;
   function create_interface(par_interface in varchar2, par_fil_name in varchar2, par_msg_name in varchar2) return number;
   procedure append_data(par_record in varchar2);
   procedure append_raw(par_record in raw);
   procedure add_exception(par_exception in varchar2);
   procedure add_search(par_tag in varchar2, par_value in varchar2);
   procedure finalise_interface;
   function is_created return boolean;

end lics_outbound_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_outbound_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_interface lics_interface%rowtype;
   rcd_lics_header lics_header%rowtype;
   rcd_lics_hdr_trace lics_hdr_trace%rowtype;
   rcd_lics_hdr_message lics_hdr_message%rowtype;
   var_hdr_control lics_header.hea_header%type;
   var_hdr_message lics_hdr_message.hem_msg_seq%type;
   var_opened boolean;
   var_fil_handle utl_file.file_type;

   /*******************************************************/
   /* This function performs the create interface routine */
   /*******************************************************/
   function create_interface(par_interface in varchar2) return number is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create the interface with generated file name
      /*-*/
      return create_interface(par_interface, null);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_interface;

   /*******************************************************/
   /* This function performs the create interface routine */
   /*******************************************************/
   function create_interface(par_interface in varchar2, par_fil_name in varchar2) return number is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create the interface with generated file name
      /*-*/
      return create_interface(par_interface, par_fil_name, null);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_interface;

   /*******************************************************/
   /* This function performs the create interface routine */
   /*******************************************************/
   function create_interface(par_interface in varchar2, par_fil_name in varchar2, par_msg_name in varchar2) return number is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_pth_name varchar2(256);
      var_fil_path varchar2(128);
      var_fil_name varchar2(64);
      var_msg_name varchar2(64);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_interface_01 is 
         select t01.int_interface,
                t01.int_description,
                t01.int_type,
                t01.int_group,
                t01.int_fil_path,
                t01.int_fil_prefix,
                t01.int_fil_sequence,
                t01.int_fil_extension,
                t01.int_opr_alert,
                t01.int_ema_group,
                t01.int_status
           from lics_interface t01
          where t01.int_interface = rcd_lics_interface.int_interface;
      rcd_lics_interface_01 csr_lics_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the interface variable
      /*-*/
      rcd_lics_interface.int_interface := par_interface;

      /*-*/
      /* Re-initialise the package
      /*-*/
      var_hdr_control := null;
      rcd_lics_header.hea_header := null;

      /*-*/
      /* Retrieve the requested outbound interface
      /* notes - must exist
      /*         must be outbound type
      /*         must be active
      /*         must not be locked
      /*-*/
      open csr_lics_interface_01;
      fetch csr_lics_interface_01 into rcd_lics_interface_01;
      if csr_lics_interface_01%notfound then
         raise_application_error(-20000, 'Create Interface - Interface (' || rcd_lics_interface.int_interface || ') does not exist');
      end if;
      close csr_lics_interface_01;
      if rcd_lics_interface_01.int_type <> lics_constant.type_outbound then
         raise_application_error(-20000, 'Create Interface - Interface (' || rcd_lics_interface.int_interface || ') must be type ' || lics_constant.type_outbound);
      end if;
      if rcd_lics_interface_01.int_status <> lics_constant.status_active then
         raise_application_error(-20000, 'Create Interface - Interface (' || rcd_lics_interface.int_interface || ') is not active');
      end if;
      if par_fil_name is null then
         if rcd_lics_interface_01.int_fil_prefix is null then
            raise_application_error(-20000, 'Create Interface - Interface (' || rcd_lics_interface.int_interface || ') must have file prefix specified');
         end if;
         if rcd_lics_interface_01.int_fil_sequence is null then
            raise_application_error(-20000, 'Create Interface - Interface (' || rcd_lics_interface.int_interface || ') must have file sequence length specified');
         end if;
         if rcd_lics_interface_01.int_fil_extension is null then
            raise_application_error(-20000, 'Create Interface - Interface (' || rcd_lics_interface.int_interface || ') must have file extension specified');
         end if;
      end if;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_interface.int_interface := rcd_lics_interface_01.int_interface;
      rcd_lics_interface.int_description := rcd_lics_interface_01.int_description;
      rcd_lics_interface.int_type := rcd_lics_interface_01.int_type;
      rcd_lics_interface.int_group := rcd_lics_interface_01.int_group;
      rcd_lics_interface.int_fil_path := rcd_lics_interface_01.int_fil_path;
      rcd_lics_interface.int_fil_prefix := rcd_lics_interface_01.int_fil_prefix;
      rcd_lics_interface.int_fil_sequence := rcd_lics_interface_01.int_fil_sequence;
      rcd_lics_interface.int_fil_extension := rcd_lics_interface_01.int_fil_extension;
      rcd_lics_interface.int_opr_alert := rcd_lics_interface_01.int_opr_alert;
      rcd_lics_interface.int_ema_group := rcd_lics_interface_01.int_ema_group;
      rcd_lics_interface.int_status := rcd_lics_interface_01.int_status;

      /*-*/
      /* Retrieve the next header sequence
      /*-*/
      select lics_header_sequence.nextval into rcd_lics_header.hea_header from dual;

      /*-*/
      /* Initialise the file name
      /*-*/
      if not(par_fil_name is null) then
         var_fil_name := par_fil_name;
      else
         var_fil_name := lics_file.generate_name(rcd_lics_interface.int_interface,
                                                 rcd_lics_interface.int_fil_prefix,
                                                 rcd_lics_interface.int_fil_sequence,
                                                 rcd_lics_interface.int_fil_extension);
      end if;

      /*-*/
      /* Initialise the message name
      /*-*/
      if not(par_msg_name is null) then
         var_msg_name := par_msg_name;
      else
         var_msg_name := var_fil_name;
      end if;

      /*-*/
      /* Create the new header
      /* notes - header_load_working
      /*-*/
      rcd_lics_header.hea_interface := rcd_lics_interface.int_interface;
      rcd_lics_header.hea_trc_count := 1;
      rcd_lics_header.hea_crt_user := user;
      rcd_lics_header.hea_crt_time := sysdate;
      rcd_lics_header.hea_fil_name := var_fil_name;
      rcd_lics_header.hea_msg_name := var_msg_name;
      rcd_lics_header.hea_status := lics_constant.header_load_working;
      insert into lics_header
         (hea_header,
          hea_interface,
          hea_trc_count,
          hea_crt_user,
          hea_crt_time,
          hea_fil_name,
          hea_msg_name,
          hea_status)
         values(rcd_lics_header.hea_header,
                rcd_lics_header.hea_interface,
                rcd_lics_header.hea_trc_count,
                rcd_lics_header.hea_crt_user,
                rcd_lics_header.hea_crt_time,
                rcd_lics_header.hea_fil_name,
                rcd_lics_header.hea_msg_name,
                rcd_lics_header.hea_status);

      /*-*/
      /* Create the new header trace
      /* notes - header_load_working
      /*-*/
      rcd_lics_hdr_trace.het_header := rcd_lics_header.hea_header;
      rcd_lics_hdr_trace.het_hdr_trace := rcd_lics_header.hea_trc_count;
      rcd_lics_hdr_trace.het_execution := null;
      rcd_lics_hdr_trace.het_user := user;
      rcd_lics_hdr_trace.het_str_time := sysdate;
      rcd_lics_hdr_trace.het_end_time := sysdate;
      rcd_lics_hdr_trace.het_status := lics_constant.header_load_working;
      insert into lics_hdr_trace
         (het_header,
          het_hdr_trace,
          het_execution,
          het_user,
          het_str_time,
          het_end_time,
          het_status)
         values(rcd_lics_hdr_trace.het_header,
                rcd_lics_hdr_trace.het_hdr_trace,
                rcd_lics_hdr_trace.het_execution,
                rcd_lics_hdr_trace.het_user,
                rcd_lics_hdr_trace.het_str_time,
                rcd_lics_hdr_trace.het_end_time,
                rcd_lics_hdr_trace.het_status);

      /*-*/
      /* Reset the header message sequence
      /*-*/
      var_hdr_message := 0;

      /**/
      /* Set the outbound path information
      /**/
      var_fil_path := rcd_lics_interface.int_fil_path;
      var_fil_name := rcd_lics_header.hea_fil_name;
      if substr(var_fil_path, -1, 1) <> lics_parameter.folder_delimiter then
         var_fil_path := var_fil_path || lics_parameter.folder_delimiter;
      end if;
      var_pth_name := var_fil_path || var_fil_name;

      /**/
      /* Open the outbound interface file 
      /**/
      begin
         var_fil_handle := utl_file.fopen(rcd_lics_interface.int_fil_path, rcd_lics_header.hea_fil_name, 'w', 32767);
      exception
         when utl_file.access_denied then
            raise_application_error(-20000, 'Create Interface - Access denied to outbound file (' || rcd_lics_interface.int_fil_path || '-' || rcd_lics_header.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when utl_file.invalid_path then
            raise_application_error(-20000, 'Create Interface - Invalid path to outbound file (' || rcd_lics_interface.int_fil_path || '-' || rcd_lics_header.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when utl_file.invalid_filename then
            raise_application_error(-20000, 'Create Interface - Invalid file name for outbound file (' || rcd_lics_interface.int_fil_path || '-' || rcd_lics_header.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when others then
            raise_application_error(-20000, 'Create Interface - Could not open outbound file (' || rcd_lics_interface.int_fil_path || '-' || rcd_lics_header.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
      end;
      var_opened := true;

      /*-*/
      /* Commit the database
      /* note - isolated commit (autonomous transaction)
      /*-*/
      commit;

      /**/
      /* Initialise the interface search
      /**/
      lics_interface_search.initialise(rcd_lics_header.hea_header);

      /**/
      /* Set the header control variable 
      /**/
      var_hdr_control := rcd_lics_header.hea_header;

      /**/
      /* Return the header number 
      /**/
      return rcd_lics_header.hea_header;

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
                                        lics_constant.type_outbound,
                                        rcd_lics_interface.int_group,
                                        null,
                                        rcd_lics_interface.int_interface,
                                        rcd_lics_header.hea_header,
                                        rcd_lics_hdr_trace.het_hdr_trace,
                                        'OUTBOUND LOADER FAILED - ' ||  substr(SQLERRM, 1, 512));
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Outbound Loader - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_interface;

   /***************************************************/
   /* This procedure performs the append data routine */
   /***************************************************/
   procedure append_data(par_record in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Existing header must exist
      /* notes - header control must not be null
      /*-*/
      if var_hdr_control is null then
         raise_application_error(-20000, 'Append Data - Interface has not been created');
      end if;

      /*-*/
      /* Write the outbound interface file line
      /*-*/
      utl_file.put_line(var_fil_handle, par_record);

      /*-*/
      /* Commit the database
      /* note - isolated commit (autonomous transaction)
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
         /* Log the event fatal
         /*-*/
         begin
            lics_notification.log_fatal(lics_constant.job_loader,
                                        null,
                                        lics_constant.type_outbound,
                                        rcd_lics_interface.int_group,
                                        null,
                                        rcd_lics_interface.int_interface,
                                        rcd_lics_header.hea_header,
                                        rcd_lics_hdr_trace.het_hdr_trace,
                                        'OUTBOUND LOADER FAILED - ' ||  substr(SQLERRM, 1, 512));
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Outbound Loader - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end append_data;

   /**************************************************/
   /* This procedure performs the append raw routine */
   /**************************************************/
   procedure append_raw(par_record in raw) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Existing header must exist
      /* notes - header control must not be null
      /*-*/
      if var_hdr_control is null then
         raise_application_error(-20000, 'Append Raw - Interface has not been created');
      end if;

      /*-*/
      /* Write the outbound interface file line
      /*-*/
      utl_file.put_raw(var_fil_handle, par_record);
      utl_file.fflush(var_fil_handle);
      utl_file.new_line(var_fil_handle);

      /*-*/
      /* Commit the database
      /* note - isolated commit (autonomous transaction)
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
         /* Log the event fatal
         /*-*/
         begin
            lics_notification.log_fatal(lics_constant.job_loader,
                                        null,
                                        lics_constant.type_outbound,
                                        rcd_lics_interface.int_group,
                                        null,
                                        rcd_lics_interface.int_interface,
                                        rcd_lics_header.hea_header,
                                        rcd_lics_hdr_trace.het_hdr_trace,
                                        'OUTBOUND LOADER FAILED - ' ||  substr(SQLERRM, 1, 512));
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Outbound Loader - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end append_raw;

   /*****************************************************/
   /* This procedure performs the add exception routine */
   /*****************************************************/
   procedure add_exception(par_exception in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Existing header must exist
      /* notes - header control must not be null
      /*-*/
      if var_hdr_control is null then
         raise_application_error(-20000, 'Add Exception - Interface has not been created');
      end if;

      /*-*/
      /* Update the header status when required
      /* note - header_load_working_error
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_load_working then
         rcd_lics_header.hea_status := lics_constant.header_load_working_error;
         update lics_header
            set hea_status = rcd_lics_header.hea_status
          where hea_header = rcd_lics_header.hea_header;
         if sql%notfound then
            raise_application_error(-20000, 'Add Exception - Header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist');
         end if;
      end if;

      /*-*/
      /* Update the header trace status when required
      /* note - header_load_working_error
      /*-*/
      if rcd_lics_hdr_trace.het_status = lics_constant.header_load_working then
         rcd_lics_hdr_trace.het_status := lics_constant.header_load_working_error;
         update lics_hdr_trace
            set het_status = rcd_lics_hdr_trace.het_status
          where het_header = rcd_lics_hdr_trace.het_header
            and het_hdr_trace = rcd_lics_hdr_trace.het_hdr_trace;
         if sql%notfound then
            raise_application_error(-20000, 'Add Exception - Header/trace (' || to_char(rcd_lics_hdr_trace.het_header,'FM999999999999990') || '/' || to_char(rcd_lics_hdr_trace.het_hdr_trace,'FM99990') || ') does not exist');
         end if;
      end if;

      /*-*/
      /* Insert the header message
      /*-*/
      var_hdr_message := var_hdr_message + 1;
      rcd_lics_hdr_message.hem_header := rcd_lics_hdr_trace.het_header;
      rcd_lics_hdr_message.hem_hdr_trace := rcd_lics_hdr_trace.het_hdr_trace;
      rcd_lics_hdr_message.hem_msg_seq := var_hdr_message;
      rcd_lics_hdr_message.hem_text := par_exception;
      insert into lics_hdr_message
         (hem_header,
          hem_hdr_trace,
          hem_msg_seq,
          hem_text)
      values(rcd_lics_hdr_message.hem_header,
             rcd_lics_hdr_message.hem_hdr_trace,
             rcd_lics_hdr_message.hem_msg_seq,
             rcd_lics_hdr_message.hem_text);

      /*-*/
      /* Commit the database
      /* note - isolated commit (autonomous transaction)
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
         /* Log the event fatal
         /*-*/
         begin
            lics_notification.log_fatal(lics_constant.job_loader,
                                        null,
                                        lics_constant.type_outbound,
                                        rcd_lics_interface.int_group,
                                        null,
                                        rcd_lics_interface.int_interface,
                                        rcd_lics_header.hea_header,
                                        rcd_lics_hdr_trace.het_hdr_trace,
                                        'OUTBOUND LOADER FAILED - ' ||  substr(SQLERRM, 1, 512));
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Outbound Loader - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_exception;

   /**************************************************/
   /* This procedure performs the add search routine */
   /**************************************************/
   procedure add_search(par_tag in varchar2, par_value in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Add the search tag and value
      /*-*/
      lics_interface_search.add_search(par_tag, par_value);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_search;

   /**********************************************************/
   /* This procedure performs the finalise interface routine */
   /**********************************************************/
   procedure finalise_interface is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Existing header must exist
      /* notes - header control must not be null
      /*-*/
      if var_hdr_control is null then
         raise_application_error(-20000, 'Finalise Interface - Interface has not been created');
      end if;

      /*-*/
      /* Re-initialise the package
      /*-*/
      var_hdr_control := null;

      /*-*/
      /* Finalise the interface search
      /*-*/
      lics_interface_search.finalise;

      /*-*/
      /* Update the header trace end time and status
      /* note - header_load_completed
      /*        header_load_completed_error
      /*-*/
      rcd_lics_hdr_trace.het_end_time := sysdate;
      if rcd_lics_hdr_trace.het_status = lics_constant.header_load_working then
         rcd_lics_hdr_trace.het_status := lics_constant.header_load_completed;
      else
         rcd_lics_hdr_trace.het_status := lics_constant.header_load_completed_error;
      end if;
      update lics_hdr_trace
         set het_end_time = rcd_lics_hdr_trace.het_end_time,
             het_status = rcd_lics_hdr_trace.het_status
       where het_header = rcd_lics_hdr_trace.het_header
         and het_hdr_trace = rcd_lics_hdr_trace.het_hdr_trace;
      if sql%notfound then
         raise_application_error(-20000, 'Finalise Interface - Header/trace (' || to_char(rcd_lics_hdr_trace.het_header,'FM999999999999990') || '/' || to_char(rcd_lics_hdr_trace.het_hdr_trace,'FM99990') || ') does not exist');
      end if;

      /*-*/
      /* Update the header status
      /* note - header_load_completed
      /*        header_load_completed_error
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_load_working then
         rcd_lics_header.hea_status := lics_constant.header_load_completed;
      else
         rcd_lics_header.hea_status := lics_constant.header_load_completed_error;
      end if;
      update lics_header
         set hea_status = rcd_lics_header.hea_status
       where hea_header = rcd_lics_header.hea_header;
      if sql%notfound then
         raise_application_error(-20000, 'Finalise Interface - Header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist');
      end if;

      /*-*/
      /* Close the outbound interface file
      /*-*/
      if var_opened = true then
         begin
            utl_file.fclose(var_fil_handle);
         exception
            when others then
               raise_application_error(-20000, 'Finalise Interface - Could not close outbound file (' || rcd_lics_interface.int_fil_path || '-' || rcd_lics_header.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         end;
         var_opened := false;
      end if;

      /*-*/
      /* Commit the database
      /* note - isolated commit (autonomous transaction)
      /*-*/
      commit;

      /*-*/
      /* Log the header/trace event
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_load_completed then
         lics_notification.log_success(lics_constant.job_loader,
                                       null,
                                       lics_constant.type_outbound,
                                       rcd_lics_interface.int_group,
                                       null,
                                       rcd_lics_interface.int_interface,
                                       rcd_lics_header.hea_header,
                                       rcd_lics_hdr_trace.het_hdr_trace,
                                       'OUTBOUND LOADER SUCCESS');
      else
         lics_notification.log_error(lics_constant.job_loader,
                                     null,
                                     lics_constant.type_outbound,
                                     rcd_lics_interface.int_group,
                                     null,
                                     rcd_lics_interface.int_interface,
                                     rcd_lics_header.hea_header,
                                     rcd_lics_hdr_trace.het_hdr_trace,
                                     'OUTBOUND LOADER ERROR - see trace messages for more details',
                                     rcd_lics_interface.int_opr_alert,
                                     rcd_lics_interface.int_ema_group);
      end if;

      /*-*/
      /* Notify the outbound group processor when required
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_load_completed then
         lics_pipe.spray(lics_constant.type_outbound, rcd_lics_interface.int_group, lics_constant.pipe_wake);
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
         /* Close the file handle whn required
         /*-*/
         if var_opened = true then
            begin
               utl_file.fclose(var_fil_handle);
            exception
               when others then
                  null;
            end;
         end if;

         /*-*/
         /* Log the event fatal
         /*-*/
         begin
            lics_notification.log_fatal(lics_constant.job_loader,
                                        null,
                                        lics_constant.type_outbound,
                                        rcd_lics_interface.int_group,
                                        null,
                                        rcd_lics_interface.int_interface,
                                        rcd_lics_header.hea_header,
                                        rcd_lics_hdr_trace.het_hdr_trace,
                                        'OUTBOUND LOADER FAILED - ' ||  substr(SQLERRM, 1, 512));
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Outbound Loader - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end finalise_interface;

   /*************************************************/
   /* This function performs the is created routine */
   /*************************************************/
   function is_created return boolean is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Existing header exists
      /*-*/
      if var_hdr_control is null then
         return false;
      end if;
      return true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end is_created;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package
   /*-*/
   var_hdr_control := null;

end lics_outbound_loader;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_outbound_loader for lics_app.lics_outbound_loader;
grant execute on lics_outbound_loader to public;
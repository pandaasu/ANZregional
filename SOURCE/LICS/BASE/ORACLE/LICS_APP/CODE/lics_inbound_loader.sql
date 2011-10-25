--
-- LICS_INBOUND_LOADER  (Package) 
--
CREATE OR REPLACE PACKAGE LICS_APP.lics_inbound_loader as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_inbound_loader
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Inbound Loader

 The package implements the inbound loader functionality.

 1. Applications can only create inbound interface instances using
    the supplied execute procedure in this package.

 2. This package has been designed as a single instance class to facilitate
    re-engineering in an object oriented language. That is, in an OO environment
    the host would create one or more instances of this class and pass the reference
    to the target objects. However, in the PL/SQL environment only one global instance
    is available at any one time.

 3. All methods have been implemented as autonomous transactions so as not
    to interfere with the commit boundaries of the host application.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2006/08   Steve Gregan   Added search functionality
 2006/08   Steve Gregan   Added message name functionality
 2011/02   Steve Gregan   End point architecture version
 2011/10   Ben Halicki    Added manual interface loader user tracing

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_interface in varchar2, par_fil_name in varchar2);
   procedure execute(par_interface in varchar2, par_fil_name in varchar2, par_usr_name in varchar2);

end lics_inbound_loader;
/


--
-- LICS_INBOUND_LOADER  (Synonym) 
--
CREATE PUBLIC SYNONYM LICS_INBOUND_LOADER FOR LICS_APP.LICS_INBOUND_LOADER;


GRANT EXECUTE ON LICS_APP.LICS_INBOUND_LOADER TO LICS_APP_EXEC;

GRANT EXECUTE ON LICS_APP.LICS_INBOUND_LOADER TO PUBLIC;


--
-- LICS_INBOUND_LOADER  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY LICS_APP.lics_inbound_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure receive_interface;
   procedure add_header_exception(par_exception in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_interface lics_interface%rowtype;
   rcd_lics_header lics_header%rowtype;
   rcd_lics_hdr_trace lics_hdr_trace%rowtype;
   rcd_lics_hdr_message lics_hdr_message%rowtype;
   var_hdr_message lics_hdr_message.hem_msg_seq%type;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_interface in varchar2, par_fil_name in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create the interface with user specified by current database user
      /*-*/
      execute(par_interface, par_fil_name, null);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_interface in varchar2, par_fil_name in varchar2, par_usr_name in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_usr_name  varchar2(20);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_interface_01 is
         select t01.int_interface,
                t01.int_description,
                t01.int_type,
                t01.int_group,
                t01.int_fil_path,
                t01.int_opr_alert,
                t01.int_ema_group,
                t01.int_search,
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
      var_usr_name := upper(par_usr_name);
      
      /*-*/
      /* Retrieve the requested interface
      /* notes - must exist
      /*         must be inbound type
      /*         must be active
      /*-*/
      open csr_lics_interface_01;
      fetch csr_lics_interface_01 into rcd_lics_interface_01;
      if csr_lics_interface_01%notfound then
         raise_application_error(-20000, 'Execute - Interface (' || rcd_lics_interface.int_interface || ') does not exist');
      end if;
      close csr_lics_interface_01;
      if rcd_lics_interface_01.int_type <> lics_constant.type_inbound then
         raise_application_error(-20000, 'Execute - Interface (' || rcd_lics_interface.int_interface || ') must be type ' || lics_constant.type_inbound);
      end if;
      if rcd_lics_interface_01.int_status <> lics_constant.status_active then
         raise_application_error(-20000, 'Execute - Interface (' || rcd_lics_interface.int_interface || ') is not active');
      end if;

      /*-*/
      /* Set the private variables
      /*-*/
      rcd_lics_interface.int_interface := rcd_lics_interface_01.int_interface;
      rcd_lics_interface.int_description := rcd_lics_interface_01.int_description;
      rcd_lics_interface.int_type := rcd_lics_interface_01.int_type;
      rcd_lics_interface.int_group := rcd_lics_interface_01.int_group;
      rcd_lics_interface.int_fil_path := rcd_lics_interface_01.int_fil_path;
      rcd_lics_interface.int_opr_alert := rcd_lics_interface_01.int_opr_alert;
      rcd_lics_interface.int_ema_group := rcd_lics_interface_01.int_ema_group;
      rcd_lics_interface.int_search := rcd_lics_interface_01.int_search;
      rcd_lics_interface.int_status := rcd_lics_interface_01.int_status;

      /*-*/
      /* Create the new header
      /* notes - header_load_working
      /*-*/
      select lics_header_sequence.nextval into rcd_lics_header.hea_header from dual;
      rcd_lics_header.hea_interface := rcd_lics_interface.int_interface;
      rcd_lics_header.hea_trc_count := 1;
      rcd_lics_header.hea_crt_time := sysdate;
      rcd_lics_header.hea_fil_name := par_fil_name;
      rcd_lics_header.hea_msg_name := par_fil_name;
      rcd_lics_header.hea_status := lics_constant.header_load_working;
      
      if (par_usr_name is null) then
        rcd_lics_header.hea_crt_user := user;
      else
        rcd_lics_header.hea_crt_user := var_usr_name;
      end if;
      
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

      /*-*/
      /* Commit the database (header/trace)
      /*-*/
      commit;

      /*-*/
      /* Receive the interface file
      /*-*/
      receive_interface;

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
         raise_application_error(-20000, 'Execute - Header/trace (' || to_char(rcd_lics_hdr_trace.het_header,'FM999999999999990') || '/' || to_char(rcd_lics_hdr_trace.het_hdr_trace,'FM99990') || ') does not exist');
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
         raise_application_error(-20000, 'Execute - Header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist');
      end if;

      /*-*/
      /* Commit the database (header/trace)
      /*-*/
      commit;

      /*-*/
      /* Log the header/trace event
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_load_completed then
         lics_notification.log_success(lics_constant.job_loader,
                                       null,
                                       lics_constant.type_inbound,
                                       rcd_lics_interface.int_group,
                                       null,
                                       rcd_lics_interface.int_interface,
                                       rcd_lics_header.hea_header,
                                       rcd_lics_hdr_trace.het_hdr_trace,
                                       'INBOUND LOADER SUCCESS');
      else
         lics_notification.log_error(lics_constant.job_loader,
                                     null,
                                     lics_constant.type_inbound,
                                     rcd_lics_interface.int_group,
                                     null,
                                     rcd_lics_interface.int_interface,
                                     rcd_lics_header.hea_header,
                                     rcd_lics_hdr_trace.het_hdr_trace,
                                     'INBOUND LOADER ERROR - see trace messages for more details',
                                     rcd_lics_interface.int_opr_alert,
                                     rcd_lics_interface.int_ema_group);
      end if;

      /*-*/
      /* Wake up the inbound processor when required
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_load_completed then
         lics_pipe.spray(lics_constant.type_inbound, rcd_lics_interface.int_group, lics_constant.pipe_wake);
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
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
                                        lics_constant.type_inbound,
                                        rcd_lics_interface.int_group,
                                        null,
                                        rcd_lics_interface.int_interface,
                                        rcd_lics_header.hea_header,
                                        rcd_lics_hdr_trace.het_hdr_trace,
                                        'INBOUND LOADER FAILED - ' ||  substr(SQLERRM, 1, 512));
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Inbound Loader - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*********************************************************/
   /* This procedure performs the receive interface routine */
   /*********************************************************/
   procedure receive_interface is

      /*-*/
      /* Local definitions
      /*-*/
      var_procedure varchar2(128);
      var_opened boolean;
      var_fil_handle utl_file.file_type;
      var_size number(5,0);
      var_work number(5,0);
      var_count number(9,0);
      var_data varchar2(4000);
      type tab_sequence is table of number(9,0) index by binary_integer;
      type tab_record is table of varchar2(4000) index by binary_integer;
      var_sequence tab_sequence;
      var_record tab_record;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_data_01 is
         select t01.dat_header,
                t01.dat_dta_seq,
                t01.dat_record,
                t01.dat_status
           from lics_data t01
          where t01.dat_header = rcd_lics_header.hea_header
       order by t01.dat_dta_seq asc;
      rcd_lics_data_01 csr_lics_data_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the opened variable
      /*-*/
      var_opened := false;

      /*-*/
      /* Open the inbound interface file
      /*-*/
      begin
         var_fil_handle := utl_file.fopen(lics_parameter.ics_inbound, rcd_lics_header.hea_fil_name, 'r', lics_parameter.inbound_line_max);
      exception
         when utl_file.access_denied then
            raise_application_error(-20000, 'Receive Interface - Access denied to inbound file (' || lics_parameter.ics_inbound || ' - ' || rcd_lics_header.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when utl_file.invalid_path then
            raise_application_error(-20000, 'Receive Interface - Invalid path to inbound file (' || lics_parameter.ics_inbound || ' - ' || rcd_lics_header.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when utl_file.invalid_filename then
            raise_application_error(-20000, 'Receive Interface - Invalid file name for inbound file (' || lics_parameter.ics_inbound || ' - ' || rcd_lics_header.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when others then
            raise_application_error(-20000, 'Receive Interface - Could not open inbound file (' || lics_parameter.ics_inbound || ' - ' || rcd_lics_header.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
      end;
      var_opened := true;

      /*-*/
      /* Process the inbound interface file
      /*-*/
      var_size := lics_parameter.inbound_array_size;
      var_work := 0;
      var_count := 0;
      loop

         /*-*/
         /* Read the inbound interface file rows
         /*-*/
         begin
            utl_file.get_line(var_fil_handle, var_data, lics_parameter.inbound_line_max);
         exception
            when no_data_found then
               exit;
            when others then
               raise_application_error(-20000, 'Receive Interface - Could not read inbound file (' || lics_parameter.ics_inbound || ' - ' || rcd_lics_header.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         end;

         /*-*/
         /* Load the bulk array
         /*-*/
         var_work := var_work + 1;
         var_count := var_count + 1;
         var_sequence(var_work) := var_count;
         var_record(var_work) := var_data;

         /*-*/
         /* Insert the bulk inbound data when required
         /*-*/
         if var_work = var_size then
            forall idx in 1..var_work
               insert into lics_data
                  (dat_header,
                   dat_dta_seq,
                   dat_record,
                   dat_status)
                  values(rcd_lics_header.hea_header,
                         var_sequence(idx),
                         var_record(idx),
                         lics_constant.data_available);
            var_work := 0;
         end if;

      end loop;

      /*-*/
      /* Insert the remaining bulk inbound data
      /*-*/
      if var_work > 0 then
         forall idx in 1..var_work
            insert into lics_data
               (dat_header,
                dat_dta_seq,
                dat_record,
                dat_status)
               values(rcd_lics_header.hea_header,
                      var_sequence(idx),
                      var_record(idx),
                      lics_constant.data_available);
      end if;

      /*-*/
      /* Close the inbound interface file
      /*-*/
      if var_opened = true then
         begin
            utl_file.fclose(var_fil_handle);
         exception
            when others then
               raise_application_error(-20000, 'Receive Interface - Could not close inbound file (' || lics_parameter.ics_inbound || ' - ' || rcd_lics_header.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         end;
         var_opened := false;
      end if;

      /*-*/
      /* Commit the database (data)
      /*-*/
      commit;

      /*-*/
      /* Search the inbound interface file when required
      /*-*/
      if not(rcd_lics_interface.int_search is null) then

         /*-*/
         /* Initialise the interface search
         /*-*/
         lics_interface_search.initialise(rcd_lics_header.hea_header);

         /*-*/
         /* Search the inbound data
         /*-*/
         var_procedure := 'begin ' || rcd_lics_interface.int_search || '.on_data(:data); end;';
         open csr_lics_data_01;
         loop
            fetch csr_lics_data_01 into rcd_lics_data_01;
            if csr_lics_data_01%notfound then
               exit;
            end if;

            /*-*/
            /* Fire the on data event in the inbound search implementation
            /*-*/
            execute immediate var_procedure using rcd_lics_data_01.dat_record;

         end loop;
         close csr_lics_data_01;

         /*-*/
         /* Finalise the interface search
         /*-*/
         lics_interface_search.finalise;

      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Application exception
      /*-*/
      when application_exception then
         if var_opened = true then
            begin
               utl_file.fclose(var_fil_handle);
            exception
               when others then
                  null;
            end;
         end if;
         add_header_exception('UTIL_FILE ERROR - ' || substr(SQLERRM, 1, 512));

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         if var_opened = true then
            begin
               utl_file.fclose(var_fil_handle);
            exception
               when others then
                  null;
            end;
         end if;
         add_header_exception('SQL ERROR - Receive Interface - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end receive_interface;

   /************************************************************/
   /* This procedure performs the add header exception routine */
   /************************************************************/
   procedure add_header_exception(par_exception in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

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
            raise_application_error(-20000, 'Add Header Exception - Header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist');
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
            raise_application_error(-20000, 'Add Header Exception - Header/trace (' || to_char(rcd_lics_hdr_trace.het_header,'FM999999999999990') || '/' || to_char(rcd_lics_hdr_trace.het_hdr_trace,'FM99990') || ') does not exist');
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
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_header_exception;

end lics_inbound_loader;
/


--
-- LICS_INBOUND_LOADER  (Synonym) 
--
CREATE PUBLIC SYNONYM LICS_INBOUND_LOADER FOR LICS_APP.LICS_INBOUND_LOADER;


GRANT EXECUTE ON LICS_APP.LICS_INBOUND_LOADER TO LICS_APP_EXEC;

GRANT EXECUTE ON LICS_APP.LICS_INBOUND_LOADER TO PUBLIC;

DROP PACKAGE CR_APP.SIL_INBOUND_PROCESSOR;

CREATE OR REPLACE PACKAGE CR_APP.sil_inbound_processor as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : STANDARD INTERFACE LOADER
 Package : sil_inbound_processor
 Owner   : CR_APP
 Author  : Linden Glen

 DESCRIPTION
 -----------
 STANDARD INTERFACE LOADER - sil_inbound_processor

 The package implements the inbound processor functionality.


 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/10   Linden Glen    Created

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_interface in varchar2, par_fil_name in varchar2);

end sil_inbound_processor;
/


DROP PACKAGE BODY CR_APP.SIL_INBOUND_PROCESSOR;

CREATE OR REPLACE PACKAGE BODY CR_APP.sil_inbound_processor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure receive_interface;

   /*-*/
   /* Private definitions
   /*-*/
   rcd_sil_interface sil_interface%rowtype;

   var_log_identifier varchar2(512 char);
   var_log_prefix varchar2(256);
   var_log_search varchar2(256);
   var_fil_name varchar2(64 char);


   /*******************************************************/
   /* This procedure performs the execute process routine */
   /*******************************************************/
   procedure execute(par_interface in varchar2, par_fil_name in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sil_interface_01 is
         select t01.int_interface,
                t01.int_description,
                t01.int_fil_path,
                t01.int_ema_group,
                t01.int_procedure,
                t01.int_status
           from sil_interface t01
          where t01.int_interface = rcd_sil_interface.int_interface;
      rcd_sil_interface_01 csr_sil_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the interface variable
      /*-*/
      rcd_sil_interface.int_interface := par_interface;

      /*-*/
      /* Validate and Set the file name variable
      /*-*/
      if (par_fil_name is null) then
         raise_application_error(-20000, 'File name parameter must be supplied');
      end if;
      var_fil_name := par_fil_name;

      /*-*/
      /* Retrieve the requested interface
      /* notes - must exist
      /*         must be active
      /*-*/
      open csr_sil_interface_01;
      fetch csr_sil_interface_01 into rcd_sil_interface_01;
      if csr_sil_interface_01%notfound then
         raise_application_error(-20000, 'Execute - Interface (' || rcd_sil_interface.int_interface || ') does not exist');
      end if;
      close csr_sil_interface_01;
      if rcd_sil_interface_01.int_status <> sil_parameter.inbound_intfc_active then
         raise_application_error(-20000, 'Execute - Interface (' || rcd_sil_interface.int_interface || ') is not active');
      end if;

      /*-*/
      /* Set the private variables
      /**/
      rcd_sil_interface.int_interface := rcd_sil_interface_01.int_interface;
      rcd_sil_interface.int_description := rcd_sil_interface_01.int_description;
      rcd_sil_interface.int_fil_path := rcd_sil_interface_01.int_fil_path;
      rcd_sil_interface.int_ema_group := rcd_sil_interface_01.int_ema_group;
      rcd_sil_interface.int_status := rcd_sil_interface_01.int_status;
      rcd_sil_interface.int_procedure := rcd_sil_interface_01.int_procedure;

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'STANDARD INTERFACE LOADER';
      var_log_search := 'SIL-' || rcd_sil_interface.int_interface;

      /*-*/
      /* Log start
      /*-*/
      sil_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Set the log identifier
      /*-*/
      var_log_identifier := sil_logging.callback_identifier;

      /*-*/
      /* Begin Processing
      /*-*/
      sil_logging.write_log('BEGIN - STANDARD INBOUND LOADER - Interface : ' || rcd_sil_interface.int_interface || ', File: ' || par_fil_name);


      /*-*/
      /* Receive the interface file
      /*-*/
      receive_interface;


      /*-*/
      /* Log end
      /*-*/
      sil_logging.write_log('END - Interface Load Complete');
      sil_logging.end_log;


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
         /* Log error
         /*-*/
         if (sil_logging.is_created = true) then
             sil_logging.write_log('** FATAL ERROR ** - ' || substr(SQLERRM, 1, 512));
             sil_logging.end_log;
         end if;

         /*-*/
         /* Notify by email of the fatal event
         /*-*/
         begin
            sil_notification.send_email(sil_parameter.system_code,
                                        sil_parameter.system_unit,
                                        sil_parameter.system_environment,
                                        'STANDARD INTERFACE LOADER',
                                        'SIL_INBOUND_LOADER.EXECUTE(' || nvl(par_interface,'<NOT SUPPLIED>') || ',' || nvl(par_fil_name,'<NOT SUPPLIED>') || ')',
                                        nvl(rcd_sil_interface.int_ema_group,sil_parameter.fatal_ema_group),
                                        'INBOUND PROCESSOR FAILED - see log : ' ||  nvl(var_log_identifier,'n/a'));
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, '** FATAL ERROR ** - Standard Interface Loader - ' || substr(SQLERRM, 1, 512));

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
      var_opened boolean;
      var_pth_name varchar2(256);
      var_fil_path varchar2(128);
      var_fil_handle utl_file.file_type;
      var_procedure varchar2(128);
      var_count number(9,0);
      var_data varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /**/
      /* Initialise the opened variable
      /**/
      var_opened := false;

      /**/
      /* Set the inbound path information
      /**/
      var_fil_path := rcd_sil_interface.int_fil_path;
      if substr(var_fil_path, -1, 1) <> sil_parameter.folder_delimiter then
         var_fil_path := var_fil_path || sil_parameter.folder_delimiter;
      end if;
      var_pth_name := var_fil_path || var_fil_name;

      /**/
      /* Open the inbound interface file
      /**/
      begin
         var_fil_handle := utl_file.fopen(upper(rcd_sil_interface.int_fil_path), var_fil_name, 'r', sil_parameter.inbound_line_max);
      exception
         when utl_file.access_denied then
            raise_application_error(-20000, 'Receive Interface - Access denied to inbound file (' || rcd_sil_interface.int_fil_path || ' - ' || var_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when utl_file.invalid_path then
            raise_application_error(-20000, 'Receive Interface - Invalid path to inbound file (' || rcd_sil_interface.int_fil_path || ' - ' || var_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when utl_file.invalid_filename then
            raise_application_error(-20000, 'Receive Interface - Invalid file name for inbound file (' || rcd_sil_interface.int_fil_path || ' - ' || var_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when others then
            raise_application_error(-20000, 'Receive Interface - Could not open inbound file (' || rcd_sil_interface.int_fil_path || ' - ' || var_fil_name || ') - ' || substr(SQLERRM, 1, 512));
      end;

      sil_logging.write_log('Interface file opened for processing');
      var_opened := true;

      /**/
      /* Process the inbound interface file
      /**/
      var_count := 0;

      sil_logging.write_log('Initiate ' || rcd_sil_interface.int_procedure || '.on_start');

      /*-*/
      /* Fire the on start event in the inbound interface implementation
      /*-*/
      var_procedure := 'begin ' || rcd_sil_interface.int_procedure || '.on_start; end;';
      execute immediate var_procedure;

      loop

         /**/
         /* Read the inbound interface file rows
         /**/
         begin
            utl_file.get_line(var_fil_handle, var_data, sil_parameter.inbound_line_max);
         exception
            when no_data_found then

               sil_logging.write_log('Initiate ' || rcd_sil_interface.int_procedure || '.on_end');

               /*-*/
               /* Fire the on end event in the inbound interface implementation
               /*-*/
               var_procedure := 'begin ' || rcd_sil_interface.int_procedure || '.on_end; end;';
               execute immediate var_procedure;

               exit;

            when others then
               raise_application_error(-20000, 'Receive Interface - Could not read inbound file (' || upper(rcd_sil_interface.int_fil_path) || ' - ' || var_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         end;

         /*-*/
         /* Increment count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Fire the on data event in the inbound interface implementation
         /*-*/
         var_procedure := 'begin ' || rcd_sil_interface.int_procedure || '.on_data(:data); end;';
         execute immediate var_procedure using var_data;

      end loop;

      /*-*/
      /* Close the inbound interface file
      /*-*/
      if var_opened = true then
         begin
            utl_file.fclose(var_fil_handle);
         exception
            when others then
               raise_application_error(-20000, 'Receive Interface - Could not close inbound file (' || upper(rcd_sil_interface.int_fil_path) || ' - ' || var_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         end;
         var_opened := false;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Application exception
      /**/
      when application_exception then
         if var_opened = true then
            begin
               utl_file.fclose(var_fil_handle);
            exception
               when others then
                  null;
            end;
         end if;
         raise_application_error(-20000, 'UTIL_FILE ERROR - ' || substr(SQLERRM, 1, 512));

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
         raise_application_error(-20000, 'SQL ERROR - Receive Interface - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end receive_interface;


end sil_inbound_processor;
/


DROP PUBLIC SYNONYM SIL_INBOUND_PROCESSOR;

CREATE PUBLIC SYNONYM SIL_INBOUND_PROCESSOR FOR CR_APP.SIL_INBOUND_PROCESSOR;



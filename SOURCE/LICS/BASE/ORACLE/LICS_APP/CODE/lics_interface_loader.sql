/******************/
/* Package Header */
/******************/
create or replace package lics_interface_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_interface_loader
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - Interface Loader

    The package implements the interface loader functionality.

    **NOTES**
    1. Inbound and passthru files are placed in the interface directory and will be
       loaded by the file processing poller.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/11   Steve Gregan   Created
    2011/01   Ben Halicki    Added call to archive inbound loader file on local filesystem
    2011/02   Steve Gregan   End point architecture version
    
   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function execute(par_interface in varchar2) return varchar2;

end lics_interface_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_interface_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   var_interface lics_interface.int_interface%type;

   /*-*/
   /* Private declarations
   /*-*/
   procedure read_xml_stream(par_stream in clob);
   
   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   function execute(par_interface in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);
      var_result varchar2(4000);
      var_fil_path varchar2(128);
      var_fil_name varchar2(64);
      var_fil_work varchar2(64);
      var_opened boolean;
      var_instance number(15,0);
      var_fil_handle utl_file.file_type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_interface is
         select t01.*
           from lics_interface t01
          where t01.int_interface = var_interface;
      rcd_lics_interface csr_lics_interface%rowtype;

      cursor csr_all_directories is 
         select t01.directory_path
           from all_directories t01
          where t01.directory_name = rcd_lics_interface.int_fil_path;
      rcd_all_directories csr_all_directories%rowtype;

      cursor csr_lics_temp is
         select t01.*
           from lics_temp t01
          order by t01.dat_dta_seq asc;
      rcd_lics_temp csr_lics_temp%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface File Loader';
      var_message := null;

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_interface := upper(par_interface);
      if var_interface is null then
         var_message := var_message || chr(13) || 'Interface must be specified';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Retrieve the requested interface
      /* notes - must exist
      /*         must be active
      /*-*/
      open csr_lics_interface;
      fetch csr_lics_interface into rcd_lics_interface;
      if csr_lics_interface%notfound then
         var_message := var_message || chr(13) || 'Interface (' || var_interface || ') does not exist';
      else
         if rcd_lics_interface.int_status <> lics_constant.status_active then
            var_message := var_message || chr(13) || 'Interface (' || rcd_lics_interface.int_interface || ') is not active';
         end if;
         if nvl(rcd_lics_interface.int_usr_invocation,'0') <> lics_constant.status_active then
            var_message := var_message || chr(13) || 'Interface (' || rcd_lics_interface.int_interface || ') does not allow user invocation';
         end if;
      end if;
      close csr_lics_interface;

      /**/
      /* Retrieve the operating system directory name from the oracle directory
      /**/
      open csr_all_directories;
      fetch csr_all_directories into rcd_all_directories;
      if csr_all_directories%notfound then
         var_message := var_message || chr(13) || 'Directory (' || rcd_lics_interface_01.int_fil_path || ') does not exist';
      end if;
      close csr_all_directories;
      var_fil_path := rcd_all_directories.directory_path;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Retrieve the stream data
      /*-*/
      read_xml_stream(lics_form.get_clob('LOAD_STREAM'));

      /*-*/
      /* Perform the interface user invocation validation function when required
      /*-*/
      if not(rcd_lics_interface.int_usr_validation is null) then
         open csr_lics_temp;
         loop
            fetch csr_lics_temp into rcd_lics_temp;
            if csr_lics_temp%notfound then
               exit;
            end if;
            execute immediate 'begin :result := ' || rcd_lics_interface.int_usr_validation || '.on_data(:data); end;' using out var_result, rcd_lics_temp.dat_record;
            if not(var_result is null) then
               var_message := var_message || chr(13) || 'File record (' || to_char(rcd_lics_temp.dat_dta_seq) || ') - ' || var_result;
            end if;
         end loop;
         close csr_lics_temp;
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Initialise the file name
      /* 1. INBOUND = unique file name
      /* 2. PASSTHRU = unique file name
      /* 3. OUTBOUND = unique file name or NULL(generated file name)
      /* 4. *POLL interfaces use the ^ character to exclude from the polling mechanism
      /*-*/
      var_fil_name := rcd_lics_interface.int_interface||'_LOADER_'||to_char(localtimestamp,'yyyymmddhh24missff')||'.TXT';
      var_fil_work := var_fil_name;
      if upper(rcd_lics_interface.int_lod_type) = '*POLL' then
         var_fil_work := '^'||var_fil_name;
      end if;
      if (upper(rcd_lics_interface.int_type) = '*OUTBOUND' and
          not(rcd_lics_interface.int_fil_prefix is null)) then
         var_fil_name := null;
      end if;

      /**/
      /* Create the file on the file system when INBOUND or PASSTHRU
      /**/
      if (upper(rcd_lics_interface.int_type) = '*INBOUND' or
          upper(rcd_lics_interface.int_type) = '*PASSTHRU') then
         begin
            var_opened := false;
            var_fil_handle := utl_file.fopen(upper(rcd_lics_interface.int_fil_path), var_fil_work, 'w', 32767);
            var_opened := true;
            open csr_lics_temp;
            loop
               fetch csr_lics_temp into rcd_lics_temp;
               if csr_lics_temp%notfound then
                  exit;
               end if;
               utl_file.put_line(var_fil_handle, rcd_lics_temp.dat_record);
            end loop;
            close csr_lics_temp;
            utl_file.fclose(var_fil_handle);
         exception
            when others then
               if var_opened = true then
                  begin
                     utl_file.fclose(var_fil_handle);
                  exception
                     when others then
                        null;
                  end;
               end if;
               raise_application_error(-20000, 'File system exception (' || rcd_lics_interface.int_fil_path || '-' || var_fil_work || ') - ' || substr(SQLERRM, 1, 1024));
         end;
         var_opened := false;
      end if;

      /*-*/
      /* Load the interface based on the interface type
      /* **notes** 1. When the file is restored it will go to the BASE directory
      /*-*/
      if upper(rcd_lics_interface.int_type) = '*INBOUND' then
         lics_inbound_loader.execute(rcd_lics_interface.int_interface, var_fil_work);
         lics_filesystem.archive_file_gzip(var_fil_path, var_fil_work, lics_parameter.archive_directory, var_fil_work||'.gz', '1', '1');
      elsif upper(rcd_lics_interface.int_type) = '*PASSTHRU' then
         lics_passthru_loader.execute(rcd_lics_interface.int_interface, var_fil_work);
         lics_filesystem.archive_file_gzip(var_fil_path, var_fil_work, lics_parameter.archive_directory, var_fil_work||'.gz', '1', '1');
      elsif upper(rcd_lics_interface.int_type) = '*OUTBOUND' then
         var_instance := lics_outbound_loader.create_interface(rcd_lics_interface.int_interface, var_fil_name, rcd_lics_interface.int_usr_message);
         open csr_lics_temp;
         loop
            fetch csr_lics_temp into rcd_lics_temp;
            if csr_lics_temp%notfound then
               exit;
            end if;
            lics_outbound_loader.append_data(rcd_lics_temp.dat_record);
         end loop;
         close csr_lics_temp;
         lics_outbound_loader.finalise_interface;
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

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
   end execute;

   /*******************************************************/
   /* This procedure performs the read xml stream routine */
   /*******************************************************/
   procedure read_xml_stream(par_stream in clob) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_xml_node_list xmlDom.domNodeList;
      obj_xml_node xmlDom.domNode;
      var_dta_seq lics_temp.dat_dta_seq%type;
      var_string varchar2(4000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the temporary data
      /*-*/
      delete from lics_temp;
      commit;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,par_stream);
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve and process the stream data
      /*-*/
      var_dta_seq := 0;
      obj_xml_node_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/TXTSTREAM/XR');
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         var_string := rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'text()'),'['),']');
         var_dta_seq := var_dta_seq + 1;
         insert into lics_temp
            (dat_dta_seq,
             dat_record)
            values(var_dta_seq,
                   var_string);
      end loop;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_xml_stream;

end lics_interface_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_interface_loader for lics_app.lics_interface_loader;
grant execute on lics_interface_loader to public;

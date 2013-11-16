--
-- LICS_INTERFACE_LOADER  (Package) 
--
CREATE OR REPLACE PACKAGE LICS_APP.lics_interface_loader as

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

    YYYY/MM   Author            Description
    -------   ------            -----------
    2008/11   Steve Gregan      Created
    2011/01   Ben Halicki       Added call to archive inbound loader file on local filesystem
    2011/02   Steve Gregan      End point architecture version
    2011/10   Trevor Keon
              Ben Halicki       Added manual interface loader user tracing

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function execute(par_interface in varchar2, par_usr_name in varchar2) return varchar2;
   
end lics_interface_loader;
/


--
-- LICS_INTERFACE_LOADER  (Synonym) 
--
--CREATE PUBLIC SYNONYM LICS_INTERFACE_LOADER FOR LICS_APP.LICS_INTERFACE_LOADER;


GRANT EXECUTE ON LICS_APP.LICS_INTERFACE_LOADER TO PUBLIC;


--
-- LICS_INTERFACE_LOADER  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY LICS_APP.lics_interface_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   var_interface lics_interface.int_interface%type;
   var_dta_seq lics_temp.dat_dta_seq%type;
   
   /*-*/
   /* Private declarations
   /*-*/
   procedure read_xml_stream(par_stream in clob);
   procedure read_xml_child(par_xml_node in xmlDom.domNode);
   
   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   function execute(par_interface in varchar2, par_usr_name in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);
      var_result varchar2(4000);
      var_fil_name varchar2(64);
      var_usr_name varchar2(10);
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
      
      var_usr_name := upper(par_usr_name);
      if var_usr_name is null then
         var_message := var_message || chr(13) || 'User name must be specified';
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
          execute immediate 'begin :result := ' || rcd_lics_interface.int_usr_validation || '.on_start; end;' using out var_result;
          if var_result is null then
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
          else
             var_message := var_message || chr(13) || var_result;
          end if;
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
      /*-*/
      var_fil_name := rcd_lics_interface.int_interface||'_LOADER_'||to_char(localtimestamp,'yyyymmddhh24missff')||'.TXT';
      if (upper(rcd_lics_interface.int_type) = '*OUTBOUND' and
          not(rcd_lics_interface.int_fil_prefix is null)) then
         var_fil_name := null;
      end if;

      /*-*/
      /* Create the file on the file system when INBOUND or PASSTHRU
      /*-*/
      if (upper(rcd_lics_interface.int_type) = '*INBOUND' or
          upper(rcd_lics_interface.int_type) = '*PASSTHRU') then
         begin
            var_opened := false;
            var_fil_handle := utl_file.fopen(lics_parameter.ics_inbound, var_fil_name, 'w', 32767);
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
               raise_application_error(-20000, 'File system exception (' || lics_parameter.ics_inbound || '-' || var_fil_name || ') - ' || substr(SQLERRM, 1, 1024));
         end;
         var_opened := false;
      end if;

      /*-*/
      /* Load the interface based on the interface type
      /*-*/
      if upper(rcd_lics_interface.int_type) = '*INBOUND' then
         lics_inbound_loader.execute(rcd_lics_interface.int_interface, var_fil_name, var_usr_name);
         lics_filesystem.archive_file_gzip(lics_parameter.inbound_directory, var_fil_name, lics_parameter.archive_directory, var_fil_name||'.gz', '1', '1');
      elsif upper(rcd_lics_interface.int_type) = '*PASSTHRU' then
         lics_passthru_loader.execute(rcd_lics_interface.int_interface, var_fil_name, var_usr_name);
      elsif upper(rcd_lics_interface.int_type) = '*OUTBOUND' then
         var_instance := lics_outbound_loader.create_interface(rcd_lics_interface.int_interface, var_fil_name, rcd_lics_interface.int_usr_message, var_usr_name);
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

      /*-*/
      /* Exception trap
      /*-*/
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

   /******************************************************/
   /* This procedure performs the read xml child routine */
   /******************************************************/
   procedure read_xml_child(par_xml_node in xmlDom.domNode) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_element xmlDom.domElement;
      obj_xml_node xmlDom.domNode;
      obj_xml_node_list xmlDom.domNodeList;
      var_string varchar2(4000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the attribute node
      /*-*/
      case upper(xmlDom.getNodeName(par_xml_node))
         when 'TXTSTREAM' then
            null;
         when 'XR' then
            var_dta_seq := var_dta_seq + 1;
         when '#CDATA-SECTION' then
            var_string := rtrim(ltrim(xmlDom.getNodeValue(par_xml_node),'['),']');
            insert into lics_temp
               (dat_dta_seq,
                dat_record)
               values(var_dta_seq,
                      var_string);
         else raise_application_error(-20000, 'read_xml_stream - Type (' || xmlDom.getNodeName(par_xml_node) || ') not recognised');
      end case;

      /*-*/
      /* Process the child nodes
      /*-*/
      obj_xml_node_list := xmlDom.getChildNodes(par_xml_node);
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         read_xml_child(obj_xml_node);
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_xml_child;

end lics_interface_loader;
/


--
-- LICS_INTERFACE_LOADER  (Synonym) 
--
CREATE OR REPLACE PUBLIC SYNONYM LICS_INTERFACE_LOADER FOR LICS_APP.LICS_INTERFACE_LOADER;

GRANT EXECUTE on LICS_APP.LICS_INTERFACE_LOADER TO LICS_EXEC;

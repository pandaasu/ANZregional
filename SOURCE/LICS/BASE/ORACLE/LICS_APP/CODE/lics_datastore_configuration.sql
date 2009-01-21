/******************/
/* Package Header */
/******************/
create or replace package lics_datastore_configuration as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_datastore_configuration
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - Data Store Configuration

    The package implements the data store configuration functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/01   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function get_nodes(par_system in varchar2) return lics_datastore_table pipelined;
   procedure define_store(par_user in varchar2);
   procedure delete_store(par_system in varchar2);

end lics_datastore_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_datastore_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_str_header lics_str_header%rowtype;
   rcd_lics_str_task lics_str_task%rowtype;
   rcd_lics_str_event lics_str_event%rowtype;

   /*************************************************/
   /* This procedure performs the get nodes routine */
   /*************************************************/
   function get_nodes(par_system in varchar2) return lics_stream_table pipelined is

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_group is
         select t01.*
           from lics_das_group t01
          where t01.dsg_system = upper(par_system)
          order by t01.dsg_group asc;
      rcd_group csr_group%rowtype;

      cursor csr_code is
         select t01.*
           from lics_das_code t01
          where t01.dsc_system = rcd_group.dsg_system
            and t01.dsc_group = rcd_group.dsg_group
          order by t01.dsc_code asc;
      rcd_code csr_code%rowtype;

      cursor csr_value is
         select t01.*
           from lics_das_code t01
          where t01.dsv_system = rcd_code.dsc_system
            and t01.dsv_group = rcd_code.dsc_group
          order by t01.dsv_sequence asc;
      rcd_value csr_value%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Pipe the data store root node
      /*-*/
      pipe row(lics_datastore_object(0,
                                     'S',
                                     null,
                                     null,
                                     'Data Store Root',
                                     null,
                                     null,
                                     null));

      /*-*/
      /* Pipe the data store group nodes
      /*-*/
      open csr_group;
      loop
         fetch csr_group into rcd_group;
         if csr_group%notfound then
            exit;
         end if;
         pipe row(lics_stream_object(1,
                                     'G',
                                     rcd_group.dsg_group,
                                     null,
                                     rcd_group.dsg_description,
                                     null,
                                     null,
                                     null));

         /*-*/
         /* Pipe the data store code nodes
         /*-*/
         open csr_code;
         loop
            fetch csr_code into rcd_code;
            if csr_code%notfound then
               exit;
            end if;
            pipe row(lics_stream_object(2,
                                        'C',
                                        rcd_code.dsc_group,
                                        rcd_code.dsc_code,
                                        rcd_code.dsc_description,
                                        null,
                                        rcd_code.dsc_val_type,
                                        rcd_code.dsc_val_data));

            /*-*/
            /* Pipe the data store value nodes
            /*-*/
            open csr_value;
            loop
               fetch csr_value into rcd_value;
               if csr_value%notfound then
                  exit;
               end if;
               pipe row(lics_stream_object(3,
                                           'V',
                                           rcd_value.dsv_group,
                                           rcd_value.dsv_code,
                                           null,
                                           rcd_value.dsv_value,
                                           null,
                                           null));
            end loop;
            close csr_value;

         end loop;
         close csr_code;

      end loop;
      close csr_group;

      /*-*/
      /* Return
      /*-*/  
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'ICS_DATASTORE_CONFIGURATION - GET_NODES - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_nodes;

   /****************************************************/
   /* This procedure performs the define store routine */
   /****************************************************/
   procedure define_store(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_xml_stream xmlDom.domNode;
      obj_xml_node_list xmlDom.domNodeList;
      obj_xml_node xmlDom.domNode;
      var_tsk_seqn number;
      var_evt_seqn number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check_stream is 
         select t01.*
           from lics_str_header t01
          where t01.sth_str_code = rcd_lics_str_header.sth_str_code;
      rcd_check_stream csr_check_stream%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('TRANSACTION_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve and process the stream header
      /*-*/
      obj_xml_stream := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/ICS_STREAM');
      rcd_lics_str_header.sth_str_code := upper(xslProcessor.valueOf(obj_xml_stream,'@CODE'));
      rcd_lics_str_header.sth_str_text := xslProcessor.valueOf(obj_xml_stream,'@TEXT');
      rcd_lics_str_header.sth_status := xslProcessor.valueOf(obj_xml_stream,'@STATUS');
      rcd_lics_str_header.sth_upd_user := par_user;
      rcd_lics_str_header.sth_upd_time := sysdate;
      open csr_check_stream;
      fetch csr_check_stream into rcd_check_stream;
      if csr_check_stream%found then
         update lics_str_header
            set sth_str_text = rcd_lics_str_header.sth_str_text,
                sth_status = rcd_lics_str_header.sth_status,
                sth_upd_user = rcd_lics_str_header.sth_upd_user,
                sth_upd_time = rcd_lics_str_header.sth_upd_time
          where sth_str_code = rcd_lics_str_header.sth_str_code;
         delete from lics_str_event where ste_str_code = rcd_lics_str_header.sth_str_code;
         delete from lics_str_task where stt_str_code = rcd_lics_str_header.sth_str_code;
      else
         insert into lics_str_header values rcd_lics_str_header;
      end if;
      close csr_check_stream;

      /*-*/
      /* Retrieve and process the stream nodes
      /*-*/
      var_tsk_seqn := 0;
      obj_xml_node_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/ICS_STREAM/NODES/NODE');
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         if upper(xslProcessor.valueOf(obj_xml_node,'@TYPE')) = 'T' then
            var_tsk_seqn := var_tsk_seqn + 1;
            rcd_lics_str_task.stt_str_code := rcd_lics_str_header.sth_str_code;
            rcd_lics_str_task.stt_tsk_code := upper(xslProcessor.valueOf(obj_xml_node,'@CODE'));
            rcd_lics_str_task.stt_tsk_pcde := upper(xslProcessor.valueOf(obj_xml_node,'@PARENT'));
            rcd_lics_str_task.stt_tsk_seqn := var_tsk_seqn;
            rcd_lics_str_task.stt_tsk_text := xslProcessor.valueOf(obj_xml_node,'@TEXT');
            insert into lics_str_task values rcd_lics_str_task;
            var_evt_seqn := 0;
         end if;
         if upper(xslProcessor.valueOf(obj_xml_node,'@TYPE')) = 'E' then
            var_evt_seqn := var_evt_seqn + 1;
            rcd_lics_str_event.ste_str_code := rcd_lics_str_task.stt_str_code;
            rcd_lics_str_event.ste_tsk_code := rcd_lics_str_task.stt_tsk_code;
            rcd_lics_str_event.ste_evt_code := upper(xslProcessor.valueOf(obj_xml_node,'@CODE'));
            rcd_lics_str_event.ste_evt_seqn := var_evt_seqn;
            rcd_lics_str_event.ste_evt_text := xslProcessor.valueOf(obj_xml_node,'@TEXT');
            rcd_lics_str_event.ste_evt_lock := upper(xslProcessor.valueOf(obj_xml_node,'@LOCK'));
            rcd_lics_str_event.ste_evt_proc := xslProcessor.valueOf(obj_xml_node,'@PROC');
            rcd_lics_str_event.ste_job_group := upper(xslProcessor.valueOf(obj_xml_node,'@GROUP'));
            rcd_lics_str_event.ste_opr_alert := nvl(xslProcessor.valueOf(obj_xml_node,'@ALERT'),'*NONE');
            rcd_lics_str_event.ste_ema_group := nvl(xslProcessor.valueOf(obj_xml_node,'@EMAIL'),'*NONE');
            insert into lics_str_event values rcd_lics_str_event;
         end if;
      end loop;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Commit the database
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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - ICS_DATASTORE_CONFIGURATION - DEFINE_STORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end define_store;

   /****************************************************/
   /* This procedure performs the delete store routine */
   /****************************************************/
   procedure delete_store(par_system in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Delete the store data
      /*-*/
      delete from lics_das_value where dsv_system = upper(par_system);
      delete from lics_das_code where dsc_system = upper(par_system);
      delete from lics_das_group where dsg_system = upper(par_system);
      delete from lics_das_system where dss_system = upper(par_system);

      /*-*/
      /* Commit the database
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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - ICS_DATASTORE_CONFIGURATION - DELETE_STORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_store;

end lics_datastore_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_datastore_configuration for lics_app.lics_datastore_configuration;
grant execute on lics_datastore_configuration to public;
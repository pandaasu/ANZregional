/******************/
/* Package Header */
/******************/
create or replace package lics_stream_configuration as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_stream_configuration
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - Stream Configuration

    The package implements the stream configuration functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/01   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure define_stream(par_user in varchar2);
   procedure copy_stream(par_copy in varchar2, par_code, par_text, par_status, par_user);
   procedure delete_stream(par_code in varchar2);

end lics_stream_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_stream_configuration as

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

   /*******************************************************/
   /* This procedure performs the put mobile data routine */
   /*******************************************************/
   procedure define_stream(par_user in varchar2) is

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
            rcd_lics_str_event.ste_opr_alert := xslProcessor.valueOf(obj_xml_node,'@ALERT');
            rcd_lics_str_event.ste_ema_group := xslProcessor.valueOf(obj_xml_node,'@EMAIL');
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
         raise_application_error(-20000, 'FATAL ERROR - ICS_STREAM_CONFIGURATION - DEFINE_STREAM - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end define_stream;

   /***************************************************/
   /* This procedure performs the copy stream routine */
   /***************************************************/
   procedure copy_stream(par_copy in varchar2, par_code, par_text, par_status, par_user) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_copy_stream is 
         select t01.*
           from lics_str_header t01
          where t01.sth_str_code = par_copy;
      rcd_copy_stream csr_copy_stream%rowtype;

      cursor csr_copy_task is 
         select t01.*
           from lics_str_task t01
          where t01.stt_str_code = par_copy
          order by t01.stt_tsk_seqn asc;
      rcd_copy_task csr_copy_task%rowtype;

      cursor csr_copy_event is 
         select t01.*
           from lics_str_event t01
          where t01.ste_str_code = par_copy
          order by t01.ste_tsk_code asc,
                   t01.ste_evt_seqn asc;
      rcd_copy_event csr_copy_event%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Copy the stream
      /*-*/
      open csr_copy_stream;
      fetch csr_copy_stream into rcd_copy_stream;
      if csr_copy_stream%notfound then
         raise_application_error(-20000, 'Stream (' || par_copy || ') does not exist');
      end if;
      close csr_copy_stream;
      rcd_lics_str_header.sth_str_code := par_code
      rcd_lics_str_header.sth_str_text := par_text;
      rcd_lics_str_header.sth_status := par_status;
      rcd_lics_str_header.sth_upd_user := par_user;
      rcd_lics_str_header.sth_upd_time := sysdate;
      insert into lics_str_header values rcd_lics_str_header;

      /*-*/
      /* Copy the stream tasks
      /*-*/
      open csr_copy_task;
      loop
         fetch csr_copy_task into rcd_copy_task;
         if csr_copy_task%notfound then
            exit;
         end if;
         rcd_lics_str_task.stt_str_code := rcd_lics_str_header.sth_str_code;
         rcd_lics_str_task.stt_tsk_code := rcd_copy_task.stt_tsk_code;
         rcd_lics_str_task.stt_tsk_pcde := rcd_copy_task.stt_tsk_pcde;
         rcd_lics_str_task.stt_tsk_seqn := rcd_copy_task.stt_tsk_seqn;
         rcd_lics_str_task.stt_tsk_text := rcd_copy_task.stt_tsk_text;
         insert into lics_str_task values rcd_lics_str_task;
      end loop;
      close csr_copy_task;

      /*-*/
      /* Copy the sytream events
      /*-*/
      open csr_copy_event;
      loop
         fetch csr_copy_event into rcd_copy_event;
         if csr_copy_event%notfound then
            exit;
         end if;
         rcd_lics_str_event.ste_str_code := rcd_lics_str_header.sth_str_code;
         rcd_lics_str_event.ste_tsk_code := rcd_copy_event.ste_tsk_code;
         rcd_lics_str_event.ste_evt_code := rcd_copy_event.ste_evt_code;
         rcd_lics_str_event.ste_evt_seqn := rcd_copy_event.ste_evt_seqn;
         rcd_lics_str_event.ste_evt_text := rcd_copy_event.ste_evt_text;
         rcd_lics_str_event.ste_evt_lock := rcd_copy_event.ste_evt_lock;
         rcd_lics_str_event.ste_evt_proc := rcd_copy_event.ste_evt_proc;
         rcd_lics_str_event.ste_job_group := rcd_copy_event.ste_job_group;
         rcd_lics_str_event.ste_opr_alert := rcd_copy_event.ste_opr_alert;
         rcd_lics_str_event.ste_ema_group := rcd_copy_event.ste_ema_group;
         insert into lics_str_event values rcd_lics_str_event;
      end loop;
      close csr_copy_event;

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
         raise_application_error(-20000, 'FATAL ERROR - ICS_STREAM_CONFIGURATION - COPY_STREAM - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end copy_stream;

   /*****************************************************/
   /* This procedure performs the delete stream routine */
   /*****************************************************/
   procedure delete_stream(par_code in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Delete the stream data
      /*-*/
      delete from lics_str_event where ste_str_code = upper(par_code);
      delete from lics_str_task where stt_str_code = upper(par_code);
      delete from lics_str_header where sth_str_code = upper(par_code);

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
         raise_application_error(-20000, 'FATAL ERROR - ICS_STREAM_CONFIGURATION - DELETE_STREAM - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_stream;

end lics_stream_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_stream_configuration for lics_app.lics_stream_configuration;
grant execute on lics_stream_configuration to public;
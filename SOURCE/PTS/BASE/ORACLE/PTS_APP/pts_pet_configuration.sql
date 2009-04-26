/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_pet_configuration as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_pet_configuration
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Pet Configuration

    This package contain the pet configuration functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function list_pets return pts_pet_list_type pipelined;
   function get_pet(par_pet_code in number) return pts_pet_data_type pipelined;
   function get_pet_class(par_pet_code in number) return pts_pet_class_type pipelined;
   function get_pet_sample(par_pet_code in number) return pts_pet_sample_type pipelined;
   procedure define_pet(par_user in varchar2);
   procedure copy_pet(par_copy in varchar2, par_code in varchar2, par_text in varchar2, par_status in varchar2, par_user in varchar2);
   procedure delete_pet(par_code in varchar2);

end pts_pet_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_pet_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_pts_pet_definition pts_pet_definition%rowtype;
   rcd_pts_pet_classification pts_pet_classification%rowtype;

   /************************************************/
   /* This procedure performs the get pets routine */
   /************************************************/
   function list_pets return pts_pet_list_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_stream xmlDom.domNode;
      obj_grp_list xmlDom.domNodeList;
      obj_grp_node xmlDom.domNode;
      obj_rul_list xmlDom.domNodeList;
      obj_rul_node xmlDom.domNode;
      obj_val_list xmlDom.domNodeList;
      obj_val_node xmlDom.domNode;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_select is 
         select t01.pde_pet_code,
                t01.pde_hou_code,
                t01.pde_pet_type,
                t02.hde_geo_zone
           from pts_pet_definition t01,
                pts_hou_definition t02,
                table(pts_app.pts_gen_function.select_list('*PET',null)) t03
          where t01.pde_hou_code = t02.hde_hou_code(+)
            and t01.pde_pet_code = t03.sel_code
          order by xxxxxx;
      rcd_select csr_select%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Clear the work selection temporary tables
      /*-*/
      delete from pts_wor_sel_group;
      delete from pts_wor_sel_rule;
      delete from pts_wor_sel_value;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('DATA_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve and process the stream header
      /*-*/
      obj_pts_stream := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_STREAM');
      ORDER_BY := upper(xslProcessor.valueOf(obj_pts_stream,'@CODE'));
      PAGE_SIZE := xslProcessor.valueOf(obj_pts_stream,'@TEXT');
      START_KEY := xslProcessor.valueOf(obj_pts_stream,'@STATUS');

      /*-*/
      /* Retrieve and process the stream nodes
      /*-*/
      var_tsk_seqn := 0;
      obj_grp_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_STREAM/GROUPS/GROUP');
      for idg in 0..xmlDom.getLength(obj_grp_list)-1 loop
         obj_grp_node := xmlDom.item(obj_grp_list,idg);
         rcd_pts_wor_sel_group.wsg_sel_group := upper(xslProcessor.valueOf(obj_grp_node,'@NAME'));
         insert into pts_wor_sel_group values rcd_pts_wor_sel_group;
         obj_rul_list := xslProcessor.selectNodes(obj_grp_node,'RULES/RULE');
         for idr in 0..xmlDom.getLength(obj_rul_list)-1 loop
            obj_rul_node := xmlDom.item(obj_rul_list,idr);
            rcd_pts_wor_sel_rule.wsr_sel_group := rcd_pts_wor_sel_group.wsg_sel_group;
            rcd_pts_wor_sel_rule.wsr_xxxxxx := upper(xslProcessor.valueOf(obj_rul_node,'@XXXX'));
            insert into pts_wor_sel_rule values rcd_pts_wor_sel_rule;
            obj_val_list := xslProcessor.selectNodes(obj_rul_node,'VALUES/VALUE');
            for idv in 0..xmlDom.getLength(obj_val_list)-1 loop
               obj_val_node := xmlDom.item(obj_val_list,idv);
               rcd_pts_wor_sel_value.wsv_sel_group := rcd_pts_wor_sel_rule.wsr_sel_group;
               rcd_pts_wor_sel_value.wsv_xxxx := rcd_pts_wor_sel_group.wsr_xxxxx;
               rcd_pts_wor_sel_value.wsv_xxxxxx := upper(xslProcessor.valueOf(obj_val_node,'@XXXX'));
               insert into pts_wor_sel_value values rcd_pts_wor_sel_value;
            end loop;
         end loop;
      end loop;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the pet selection list
      /*-*/
      open csr_select;
      loop
         fetch csr_select into rcd_select;
         if csr_select%notfound then
            exit;
         end if;

         /*-*/
         /* Pipe the pet selection list object
         /*-*/
         pipe row(pts_pet_list_object(rcd_select.xxx,rcd_select.xxx));

      end loop;
      close csr_select;

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
         raise_application_error(-20000, 'PTS_PET_CONFIGURATION - LIST_PETS - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_pets;

   /**************************************************/
   /* This procedure performs the define pet routine */
   /**************************************************/
   procedure define_pet(par_user in varchar2) is

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_PET_CONFIGURATION - DEFINE_PET - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end define_pet;

   /************************************************/
   /* This procedure performs the copy pet routine */
   /************************************************/
   procedure copy_pet(par_copy in varchar2, par_pet_code in number, par_text in varchar2, par_status in varchar2, par_user in varchar2) is

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
      rcd_lics_str_header.sth_str_code := upper(par_code);
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
         raise_application_error(-20000, 'FATAL ERROR - PTS_PET_CONFIGURATION - COPY_PET - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end copy_pet;

   /**************************************************/
   /* This procedure performs the delete pet routine */
   /**************************************************/
   procedure delete_pet(par_user in varchar2) is

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_PET_CONFIGURATION - DELETE_PET - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_pet;

end pts_app.pts_pet_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_pet_configuration for pts_app.pts_pet_configuration;
grant execute on pts_app.pts_pet_configuration to public;
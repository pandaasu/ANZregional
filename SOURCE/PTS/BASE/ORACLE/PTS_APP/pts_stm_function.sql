/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_stm_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_stm_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Selection Template Function

    This package contain the selection template functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function retrieve_list return pts_xml_type pipelined;
   function retrieve_data return pts_xml_type pipelined;
   procedure update_data(par_user in varchar2);

end pts_stm_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_stm_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*****************************************************/
   /* This procedure performs the retrieve list routine */
   /*****************************************************/
   function retrieve_list return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_pag_size number;
      var_row_count number;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.std_stm_code,
                t01.std_stm_text,
                nvl((select sva_val_text from pts_sys_value where sva_tab_code = '*STM_DEF' and sva_fld_code = 9 and sva_val_code = t01.std_stm_status),'*UNKNOWN') as std_stm_status
           from pts_stm_definition t01
          where t01.std_stm_code in (select sel_code from table(pts_app.pts_gen_function.get_list_data('*SELECTION',null)))
            and t01.std_stm_code > (select sel_code from table(pts_app.pts_gen_function.get_list_from))
          order by t01.std_stm_code asc;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Clear the message data
      /*-*/
      pts_gen_function.clear_mesg_data;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));
      pipe row(pts_xml_object('<LSTCTL COLCNT="2"/>'));

      /*-*/
      /* Retrieve the selection template list and pipe the results
      /*-*/
      var_pag_size := 20;
      var_row_count := 0;
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_row_count := var_row_count + 1;
         if var_row_count <= var_pag_size then
            pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.std_stm_code)||'" SELTXT="'||pts_to_xml('('||to_char(rcd_list.std_stm_code)||') '||rcd_list.std_stm_text)||'" COL1="'||pts_to_xml('('||to_char(rcd_list.std_stm_code)||') '||rcd_list.std_stm_text)||'" COL2="'||pts_to_xml(rcd_list.std_stm_status)||'"/>'));
         else
            exit;
         end if;
      end loop;
      close csr_list;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(pts_xml_object('</PTS_RESPONSE>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_STM_FUNCTION - RETRIEVE_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_list;

   /*****************************************************/
   /* This procedure performs the retrieve data routine */
   /*****************************************************/
   function retrieve_data return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_stm_code varchar2(32);
      var_tab_flag boolean;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_stm_definition t01
          where t01.std_stm_code = pts_to_number(var_stm_code);
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*STM_DEF',9)) t01;
      rcd_sta_code csr_sta_code%rowtype;

      cursor csr_tar_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*STM_DEF',3)) t01;
      rcd_tar_code csr_tar_code%rowtype;

      cursor csr_group is
         select t01.*
           from pts_stm_group t01
          where t01.stg_stm_code = rcd_retrieve.std_stm_code
          order by t01.stg_sel_group asc;
      rcd_group csr_group%rowtype;

      cursor csr_rule is
         select t01.*,
                t02.sfi_fld_text,
                t02.sfi_fld_rul_type,
                t02.sfi_fld_inp_leng
           from pts_stm_rule t01,
                pts_sys_field t02
          where t01.str_tab_code = t02.sfi_tab_code
            and t01.str_fld_code = t02.sfi_fld_code
            and t01.str_stm_code = rcd_retrieve.std_stm_code
            and t01.str_sel_group = rcd_group.stg_sel_group
          order by t01.str_tab_code asc,
                   t01.str_fld_code asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is
         select t01.*
           from pts_stm_value t01
          where t01.stv_stm_code = rcd_retrieve.std_stm_code
            and t01.stv_sel_group = rcd_group.stg_sel_group
            and t01.stv_tab_code = rcd_rule.str_tab_code
            and t01.stv_fld_code = rcd_rule.str_fld_code
          order by t01.stv_val_code asc;
      rcd_value csr_value%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Clear the message data
      /*-*/
      pts_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      var_stm_code := xslProcessor.valueOf(obj_pts_request,'@STMCODE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDSTM' and var_action != '*CRTSTM' and var_action != '*CPYSTM' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing selection template when required
      /*-*/
      if var_action = '*UPDSTM' or var_action = '*CPYSTM' then
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            pts_gen_function.add_mesg_data('Selection template ('||var_stm_code||') does not exist');
            return;
         end if;
         close csr_retrieve;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the status XML
      /*-*/
      open csr_sta_code;
      loop
         fetch csr_sta_code into rcd_sta_code;
         if csr_sta_code%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<STA_LIST VALCDE="'||rcd_sta_code.val_code||'" VALTXT="'||pts_to_xml(rcd_sta_code.val_text)||'"/>'));
      end loop;
      close csr_sta_code;

      /*-*/
      /* Pipe the target XML
      /*-*/
      open csr_tar_code;
      loop
         fetch csr_tar_code into rcd_tar_code;
         if csr_tar_code%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<TAR_LIST VALCDE="'||rcd_tar_code.val_code||'" VALTXT="'||pts_to_xml(rcd_tar_code.val_text)||'"/>'));
      end loop;
      close csr_tar_code;

      /*-*/
      /* Pipe the selection template XML
      /*-*/
      if var_action = '*UPDSTM' then
         var_output := '<SELECTION STMCODE="'||to_char(rcd_retrieve.std_stm_code)||'"';
         var_output := var_output||' STMTEXT="'||pts_to_xml(rcd_retrieve.std_stm_text)||'"';
         var_output := var_output||' STMSTAT="'||to_char(rcd_retrieve.std_stm_status)||'"';
         var_output := var_output||' STMTARG="'||to_char(rcd_retrieve.std_stm_target)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYSTM' then
         var_output := '<SELECTION STMCODE="'||to_char(rcd_retrieve.std_stm_code)||'"';
         var_output := var_output||' STMTEXT="'||pts_to_xml(rcd_retrieve.std_stm_text)||'"';
         var_output := var_output||' STMSTAT="'||to_char(rcd_retrieve.std_stm_status)||'"';
         var_output := var_output||' STMTARG="'||to_char(rcd_retrieve.std_stm_target)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CRTSTM' then
         var_output := '<SELECTION STMCODE="*NEW"';
         var_output := var_output||' STMTEXT=""';
         var_output := var_output||' STMSTAT="1"';
         var_output := var_output||' STMTARG="1"/>';
         pipe row(pts_xml_object(var_output));
      end if;

      /*-*/
      /* Pipe the selection template rules
      /*-*/
      open csr_group;
      loop
         fetch csr_group into rcd_group;
         if csr_group%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<GROUP GRPCDE="'||pts_to_xml(rcd_group.stg_sel_group)||'" GRPTXT="'||pts_to_xml(rcd_group.stg_sel_text)||'" GRPPCT="'||to_char(rcd_group.stg_sel_pcnt)||'"/>'));
         open csr_rule;
         loop
            fetch csr_rule into rcd_rule;
            if csr_rule%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<RULE GRPCDE="'||pts_to_xml(rcd_rule.str_sel_group)||'" TABCDE="'||pts_to_xml(rcd_rule.str_tab_code)||'" FLDCDE="'||to_char(rcd_rule.str_fld_code)||'" FLDTXT="'||pts_to_xml(rcd_rule.sfi_fld_text)||'" INPLEN="'||to_char(rcd_rule.sfi_fld_inp_leng)||'" RULTYP="'||rcd_rule.sfi_fld_rul_type||'" RULCDE="'||rcd_rule.str_rul_code||'"/>'));
            open csr_value;
            loop
               fetch csr_value into rcd_value;
               if csr_value%notfound then
                  exit;
               end if;
               pipe row(pts_xml_object('<VALUE VALCDE="'||to_char(rcd_value.stv_val_code)||'" VALTXT="'||pts_to_xml(rcd_value.stv_val_text)||'" VALPCT="'||to_char(rcd_value.stv_val_pcnt)||'"/>'));
            end loop;
            close csr_value;
         end loop;
         close csr_rule;
      end loop;
      close csr_group;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(pts_xml_object('</PTS_RESPONSE>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_STM_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_data;

   /***************************************************/
   /* This procedure performs the update data routine */
   /***************************************************/
   procedure update_data(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      obj_grp_list xmlDom.domNodeList;
      obj_grp_node xmlDom.domNode;
      obj_rul_list xmlDom.domNodeList;
      obj_rul_node xmlDom.domNode;
      obj_val_list xmlDom.domNodeList;
      obj_val_node xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      rcd_pts_stm_definition pts_stm_definition%rowtype;
      rcd_pts_stm_group pts_stm_group%rowtype;
      rcd_pts_stm_rule pts_stm_rule%rowtype;
      rcd_pts_stm_value pts_stm_value%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check is
         select t01.*
           from pts_stm_definition t01
          where t01.std_stm_code = rcd_pts_stm_definition.std_stm_code;
      rcd_check csr_check%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*STM_DEF',9)) t01
          where t01.val_code = rcd_pts_stm_definition.std_stm_status;
      rcd_sta_code csr_sta_code%rowtype;

      cursor csr_tar_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*STM_DEF',3)) t01
          where t01.val_code = rcd_pts_stm_definition.std_stm_target;
      rcd_tar_code csr_tar_code%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the message data
      /*-*/
      pts_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      if var_action != '*DEFSTM' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_stm_definition.std_stm_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@STMCODE'));
      rcd_pts_stm_definition.std_stm_text := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@STMTEXT'));
      rcd_pts_stm_definition.std_stm_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@STMSTAT'));
      rcd_pts_stm_definition.std_upd_user := upper(par_user);
      rcd_pts_stm_definition.std_upd_date := sysdate;
      rcd_pts_stm_definition.std_stm_target := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@STMTARG'));
      if rcd_pts_stm_definition.std_stm_code is null and not(xslProcessor.valueOf(obj_pts_request,'@STMCODE') = '*NEW') then
         pts_gen_function.add_mesg_data('Selection template code ('||xslProcessor.valueOf(obj_pts_request,'@STMCODE')||') must be a number');
      end if;
      if rcd_pts_stm_definition.std_stm_status is null and not(xslProcessor.valueOf(obj_pts_request,'@STMSTAT') is null) then
         pts_gen_function.add_mesg_data('Selection template status ('||xslProcessor.valueOf(obj_pts_request,'@STMSTAT')||') must be a number');
      end if;
      if rcd_pts_stm_definition.std_stm_target is null and not(xslProcessor.valueOf(obj_pts_request,'@STMTARG') is null) then
         pts_gen_function.add_mesg_data('Selection template target ('||xslProcessor.valueOf(obj_pts_request,'@STMTARG')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_stm_definition.std_stm_text is null then
         pts_gen_function.add_mesg_data('Selection template text must be supplied');
      end if;
      if rcd_pts_stm_definition.std_stm_status is null then
         pts_gen_function.add_mesg_data('Selection template status must be supplied');
      end if;
      if rcd_pts_stm_definition.std_stm_target is null then
         pts_gen_function.add_mesg_data('Selection template target must be supplied');
      end if;
      if rcd_pts_stm_definition.std_upd_user is null then
         pts_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      open csr_sta_code;
      fetch csr_sta_code into rcd_sta_code;
      if csr_sta_code%notfound then
         pts_gen_function.add_mesg_data('Selection template status ('||to_char(rcd_pts_stm_definition.std_stm_status)||') does not exist');
      end if;
      close csr_sta_code;
      open csr_tar_code;
      fetch csr_tar_code into rcd_tar_code;
      if csr_tar_code%notfound then
         pts_gen_function.add_mesg_data('Selection template target ('||to_char(rcd_pts_stm_definition.std_stm_target)||') does not exist');
      end if;
      close csr_tar_code;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and process the selection template definition
      /*-*/
      open csr_check;
      fetch csr_check into rcd_check;
      if csr_check%found then
         var_confirm := 'updated';
         update pts_stm_definition
            set std_stm_text = rcd_pts_stm_definition.std_stm_text,
                std_stm_status = rcd_pts_stm_definition.std_stm_status,
                std_upd_user = rcd_pts_stm_definition.std_upd_user,
                std_upd_date = rcd_pts_stm_definition.std_upd_date,
                std_stm_target = rcd_pts_stm_definition.std_stm_target
          where std_stm_code = rcd_pts_stm_definition.std_stm_code;
         delete from pts_stm_group where stg_stm_code = rcd_pts_stm_definition.std_stm_code;
         delete from pts_stm_rule where str_stm_code = rcd_pts_stm_definition.std_stm_code;
         delete from pts_stm_value where stv_stm_code = rcd_pts_stm_definition.std_stm_code;
      else
         var_confirm := 'created';
         select pts_stm_sequence.nextval into rcd_pts_stm_definition.std_stm_code from dual;
         insert into pts_stm_definition values rcd_pts_stm_definition;
      end if;
      close csr_check;

      /*-*/
      /* Retrieve and insert the selection rule data
      /*-*/
      obj_grp_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/GROUP');
      for idx in 0..xmlDom.getLength(obj_grp_list)-1 loop
         obj_grp_node := xmlDom.item(obj_grp_list,idx);
         obj_rul_list := xslProcessor.selectNodes(obj_grp_node,'RULE');
         if xmlDom.getLength(obj_rul_list) != 0 then
            rcd_pts_stm_group.stg_stm_code := rcd_pts_stm_definition.std_stm_code;
            rcd_pts_stm_group.stg_sel_group := pts_from_xml(xslProcessor.valueOf(obj_grp_node,'@GRPCDE'));
            rcd_pts_stm_group.stg_sel_text := pts_from_xml(xslProcessor.valueOf(obj_grp_node,'@GRPTXT'));
            rcd_pts_stm_group.stg_sel_pcnt := pts_to_number(xslProcessor.valueOf(obj_grp_node,'@GRPPCT'));
            insert into pts_stm_group values rcd_pts_stm_group;
            for idy in 0..xmlDom.getLength(obj_rul_list)-1 loop
               obj_rul_node := xmlDom.item(obj_rul_list,idy);
               rcd_pts_stm_rule.str_stm_code := rcd_pts_stm_group.stg_stm_code;
               rcd_pts_stm_rule.str_sel_group := rcd_pts_stm_group.stg_sel_group;
               rcd_pts_stm_rule.str_tab_code := pts_from_xml(xslProcessor.valueOf(obj_rul_node,'@TABCDE'));
               rcd_pts_stm_rule.str_fld_code := pts_to_number(xslProcessor.valueOf(obj_rul_node,'@FLDCDE'));
               rcd_pts_stm_rule.str_rul_code := pts_from_xml(xslProcessor.valueOf(obj_rul_node,'@RULCDE'));
               insert into pts_stm_rule values rcd_pts_stm_rule;
               obj_val_list := xslProcessor.selectNodes(obj_rul_node,'VALUE');
               for idz in 0..xmlDom.getLength(obj_val_list)-1 loop
                  obj_val_node := xmlDom.item(obj_val_list,idz);
                  rcd_pts_stm_value.stv_stm_code := rcd_pts_stm_rule.str_stm_code;
                  rcd_pts_stm_value.stv_sel_group := rcd_pts_stm_rule.str_sel_group;
                  rcd_pts_stm_value.stv_tab_code := rcd_pts_stm_rule.str_tab_code;
                  rcd_pts_stm_value.stv_fld_code := rcd_pts_stm_rule.str_fld_code;
                  rcd_pts_stm_value.stv_val_code := pts_to_number(xslProcessor.valueOf(obj_val_node,'@VALCDE'));
                  rcd_pts_stm_value.stv_val_text := pts_from_xml(xslProcessor.valueOf(obj_val_node,'@VALTXT'));
                  rcd_pts_stm_value.stv_val_pcnt := null;
                  if rcd_pts_stm_rule.str_rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                     rcd_pts_stm_value.stv_val_pcnt := pts_to_number(xslProcessor.valueOf(obj_val_node,'@VALPCT'));
                  end if;
                  insert into pts_stm_value values rcd_pts_stm_value;
               end loop;
            end loop;
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

      /*-*/
      /* Send the confirm message
      /*-*/
      pts_gen_function.set_cfrm_data('Selection template ('||to_char(rcd_pts_stm_definition.std_stm_code)||') successfully '||var_confirm);

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

         /* Raise an exception to the calling application
         /*-*/
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_STM_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

end pts_stm_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_stm_function for pts_app.pts_stm_function;
grant execute on pts_app.pts_stm_function to public;

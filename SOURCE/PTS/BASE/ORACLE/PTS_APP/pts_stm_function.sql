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
   procedure update_panel;
   function report_panel(par_stm_code in number) return pts_xls_type pipelined;

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

   /*-*/
   /* Private declarations
   /*-*/
   procedure clear_panel(par_stm_code in number, par_req_mem_count in number, par_req_res_count in number);
   procedure select_pet_panel(par_stm_code in number, par_pan_type in varchar2, par_pet_multiple in varchar2);
   procedure select_hou_panel(par_stm_code in number, par_pan_type in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   type rcd_sel_group is record(sel_group varchar2(32 char),
                                str_rule number,
                                end_rule number,
                                req_mem_count number,
                                req_res_count number,
                                sel_mem_count number,
                                sel_res_count number);
   type typ_sel_group is table of rcd_sel_group index by binary_integer;
   tbl_sel_group typ_sel_group;
   type rcd_sel_rule is record(sel_group varchar2(32 char),
                               tab_code varchar2(32 char),
                               fld_code number,
                               rul_code varchar2(32 char),
                               str_value number,
                               end_value number,
                               sel_count number);
   type typ_sel_rule is table of rcd_sel_rule index by binary_integer;
   tbl_sel_rule typ_sel_rule;
   type rcd_sel_value is record(sel_group varchar2(32 char),
                                tab_code varchar2(32 char),
                                fld_code number,
                                val_code number,
                                val_text varchar2(256 char),
                                val_pcnt number,
                                req_mem_count number,
                                req_res_count number,
                                sel_mem_count number,
                                sel_res_count number,
                                sel_count number,
                                fld_count number);
   type typ_sel_value is table of rcd_sel_value index by binary_integer;
   tbl_sel_value typ_sel_value;

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
            rcd_pts_stm_group.stg_req_mem_count := 0;
            rcd_pts_stm_group.stg_req_res_count := 0;
            rcd_pts_stm_group.stg_sel_mem_count := 0;
            rcd_pts_stm_group.stg_sel_res_count := 0;
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
                  rcd_pts_stm_value.stv_req_mem_count := 0;
                  rcd_pts_stm_value.stv_req_res_count := 0;
                  rcd_pts_stm_value.stv_sel_mem_count := 0;
                  rcd_pts_stm_value.stv_sel_res_count := 0;
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

   /****************************************************/
   /* This procedure performs the update panel routine */
   /****************************************************/
   procedure update_panel is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_stm_code number;
      var_req_mem_count number;
      var_req_res_count number;
      var_hou_pet_multi varchar2(32);
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_stm_definition t01
          where t01.std_stm_code = var_stm_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

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
      if var_action != '*TESSTM' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_stm_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@STMCODE'));
      var_req_mem_count := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@MEMCNT'));
      var_req_res_count := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@RESCNT'));
      var_hou_pet_multi := xslProcessor.valueOf(obj_pts_request,'@PETMLT');
      if var_stm_code is null then
         pts_gen_function.add_mesg_data('Selection template code ('||xslProcessor.valueOf(obj_pts_request,'@STMCODE')||') must be a number');
      end if;
      if var_req_mem_count is null or var_req_mem_count < 1 then
         pts_gen_function.add_mesg_data('Member count ('||xslProcessor.valueOf(obj_pts_request,'@MEMCNT')||') must be a number greater than zero');
      end if;
      if var_req_res_count is null or var_req_res_count < 1 then
         pts_gen_function.add_mesg_data('Reserve count ('||xslProcessor.valueOf(obj_pts_request,'@RESCNT')||') must be a number greater than zero');
      end if;
      if var_hou_pet_multi is null or (var_hou_pet_multi != '0' and var_hou_pet_multi != '1') then
         pts_gen_function.add_mesg_data('Allow multiple household pets ('||xslProcessor.valueOf(obj_pts_request,'@PETMLT')||') must be ''0'' or ''1''');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve and lock the existing selection template
      /*-*/
      var_found := false;
      begin
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
      exception
         when others then
            pts_gen_function.add_mesg_data('Selection template ('||to_char(var_stm_code)||') is currently locked');
            return;
      end;
      if var_found = false then
         pts_gen_function.add_mesg_data('Selection template ('||to_char(var_stm_code)||') does not exist');
      end if;

      /*-*/
      /* Clear and select the selection template panel
      /* **note** 1. Autonomous transactions that not impact the test lock
      /*-*/
      clear_panel(rcd_retrieve.std_stm_code, var_req_mem_count, var_req_res_count);
      if rcd_retrieve.std_stm_target = 1 then
         select_pet_panel(rcd_retrieve.std_stm_code, '*MEMBER', nvl(var_hou_pet_multi,'0'));
         select_pet_panel(rcd_retrieve.std_stm_code, '*RESERVE', nvl(var_hou_pet_multi,'0'));
      else
         select_hou_panel(rcd_retrieve.std_stm_code, '*MEMBER');
         select_hou_panel(rcd_retrieve.std_stm_code, '*RESERVE');
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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

         /* Raise an exception to the calling application
         /*-*/
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_STM_FUNCTION - UPDATE_PANEL - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_panel;

   /****************************************************/
   /* This procedure performs the report panel routine */
   /****************************************************/
   function report_panel(par_stm_code in number) return pts_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_stm_code number;
      var_found boolean;
      var_group boolean;
      var_output varchar2(4000 char);
      var_work varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_stm_definition t01
          where t01.std_stm_code = var_stm_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_group is
         select t01.*
           from pts_stm_group t01
          where t01.stg_stm_code = var_stm_code
          order by t01.stg_sel_group asc;
      rcd_group csr_group%rowtype;

      cursor csr_rule is
         select t01.*,
                t02.sfi_fld_text,
                t02.sfi_fld_rul_type
           from pts_stm_rule t01,
                pts_sys_field t02
          where t01.str_tab_code = t02.sfi_tab_code
            and t01.str_fld_code = t02.sfi_fld_code
            and t01.str_stm_code = var_stm_code
            and t01.str_sel_group = rcd_group.stg_sel_group
          order by t01.str_tab_code asc,
                   t01.str_fld_code asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is
         select t01.*
           from pts_stm_value t01
          where t01.stv_stm_code = var_stm_code
            and t01.stv_sel_group = rcd_group.stg_sel_group
            and t01.stv_tab_code = rcd_rule.str_tab_code
            and t01.stv_fld_code = rcd_rule.str_fld_code
          order by t01.stv_val_code asc;
      rcd_value csr_value%rowtype;

      cursor csr_panel is
         select t01.*,
                t02.*,
                t03.*
           from pts_stm_panel t01,
                pts_hou_definition t02,
                pts_pet_definition t03
          where t01.stp_hou_code = t02.hde_hou_code(+)
            and t01.stp_pet_code = t03.pde_pet_code(+)
            and t01.stp_stm_code = var_stm_code
            and t01.stp_sel_group = rcd_group.stg_sel_group
          order by t01.stp_pan_status asc,
                   t01.stp_hou_code asc,
                   t01.stp_pet_code asc;
      rcd_panel csr_panel%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameters
      /*-*/
      var_stm_code := par_stm_code;

      /*-*/
      /* Retrieve the existing selection template
      /*-*/
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         raise_application_error(-20000, 'Selection template code (' || to_char(var_stm_code) || ') does not exist');
      end if;

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<table border=0 cellpadding="0" cellspacing="0">');
      pipe row('<tr><td colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||rcd_retrieve.std_stm_text||'</td></tr>');
      pipe row('<tr>');
      pipe row('<tr><td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;"></td>Type</tr>');
      pipe row('<tr><td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;"></td>Description</tr>');
      pipe row('<tr><td align=right colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;"></td>Requested Members</tr>');
      pipe row('<tr><td align=right colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;"></td>Requested Reserves</tr>');
      pipe row('<tr><td align=right colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;"></td>Selected Members</tr>');
      pipe row('<tr><td align=right colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;"></td>Selected Reserves</tr>');
      pipe row('</tr>');

      /*-*/
      /* Retrieve the report data
      /*-*/
      var_group := false;
      open csr_group;
      loop
         fetch csr_group into rcd_group;
         if csr_group%notfound then
            exit;
         end if;

         /*-*/
         /* Output the group separator
         /*-*/
         if var_group = true then
            pipe row('<tr><td colspan=6></td></tr>');
         end if;
         var_group := true;

         /*-*/
         /* Output the group data
         /*-*/
         var_work := rcd_group.stg_sel_text||' ('||to_char(rcd_group.stg_sel_pcnt)||'%)';
         var_output := '<tr>';
         var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Group</td>';
         var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||var_work||'</td>';
         var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_group.stg_req_mem_count)||'</td>';
         var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_group.stg_req_res_count)||'</td>';
         var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_group.stg_sel_mem_count)||'</td>';
         var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_group.stg_sel_res_count)||'</td>';
         var_output := '</tr>';
         pipe row(var_output);

         /*-*/
         /* Retrieve the rule data
         /*-*/
         open csr_rule;
         loop
            fetch csr_rule into rcd_rule;
            if csr_rule%notfound then
               exit;
            end if;

            /*-*/
            /* Output the rule data
            /*-*/
            var_work := rcd_rule.sfi_fld_text||' ('||rcd_rule.str_rul_code||')';
            var_output := '<tr>';
            var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Rule</td>';
            var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||var_work||'</td>';
            var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
            var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
            var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
            var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
            var_output := '</tr>';
            pipe row(var_output);

            /*-*/
            /* Retrieve the value data
            /*-*/
            open csr_value;
            loop
               fetch csr_value into rcd_value;
               if csr_value%notfound then
                  exit;
               end if;
               if rcd_rule.sfi_fld_rul_type = '*TEXT' or rcd_rule.sfi_fld_rul_type = '*NUMBER' then
                  var_work := rcd_value.stv_val_text;
               else
                  var_work := rcd_value.stv_val_text;
                  if rcd_rule.str_rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                     var_work := rcd_value.stv_val_text||' ('||rcd_value.stv_val_pcnt||'%)';
                  end if;
               end if;
               var_output := '<tr>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Value</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||var_work||'</td>';
               var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_value.stv_req_mem_count)||'</td>';
               var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_value.stv_req_res_count)||'</td>';
               var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_value.stv_sel_mem_count)||'</td>';
               var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_value.stv_sel_res_count)||'</td>';
               var_output := '</tr>';
               pipe row(var_output);
            end loop;
            close csr_value;

         end loop;
         close csr_rule;

         /*-*/
         /* Retrieve the panel data
         /*-*/
         pipe row('<tr><td colspan=6></td></tr>');
         open csr_panel;
         loop
            fetch csr_panel into rcd_panel;
            if csr_panel%notfound then
               exit;
            end if;
            if rcd_retrieve.std_stm_target = 1 then
               var_work := 'Household ('||rcd_panel.stp_hou_code||') '||rcd_panel.hde_con_fullname||', '||rcd_panel.hde_loc_street||', '||rcd_panel.hde_loc_town;
               var_work := var_work||' Pet ('||rcd_panel.stp_pet_code||') '||rcd_panel.pde_pet_name;
            else
               var_work := 'Household ('||rcd_panel.stp_hou_code||') '||rcd_panel.hde_con_fullname||', '||rcd_panel.hde_loc_street||', '||rcd_panel.hde_loc_town;
            end if;
            var_output := '<tr>';
            var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.stp_pan_status||'</td>';
            var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||var_work||'</td>';
            var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
            var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
            var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
            var_output := var_output||'<td align=right style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
            var_output := var_output||'</tr>';
            pipe row(var_output);
         end loop;
         close csr_panel;

      end loop;
      close csr_group;

      /*-*/
      /* End the report
      /*-*/
      pipe row('</table>');

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_STM_FUNCTION - REPORT_PANEL - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_panel;

   /***************************************************/
   /* This procedure performs the clear panel routine */
   /***************************************************/
   procedure clear_panel(par_stm_code in number, par_req_mem_count in number, par_req_res_count in number) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_sel_group varchar2(32);
      var_stg_mem_count number;
      var_stg_res_count number;
      var_stv_mem_count number;
      var_stv_res_count number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_group is
         select t01.*
           from pts_stm_group t01
          where t01.stg_stm_code = par_stm_code
          order by t01.stg_sel_group asc;
      rcd_group csr_group%rowtype;

      cursor csr_rule is
         select t01.*
           from pts_stm_rule t01
          where t01.str_stm_code = par_stm_code
            and t01.str_sel_group = rcd_group.stg_sel_group
          order by t01.str_tab_code asc,
                   t01.str_fld_code asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is
         select t01.*
           from pts_stm_value t01
          where t01.stv_stm_code = par_stm_code
            and t01.stv_sel_group = rcd_group.stg_sel_group
            and t01.stv_tab_code = rcd_rule.str_tab_code
            and t01.stv_fld_code = rcd_rule.str_fld_code
          order by t01.stv_val_code asc;
      rcd_value csr_value%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the work selection temporary tables
      /*-*/
      delete from pts_wor_sel_group;
      delete from pts_wor_sel_rule;
      delete from pts_wor_sel_value;
      tbl_sel_group.delete;
      tbl_sel_rule.delete;
      tbl_sel_value.delete;

      /*-*/
      /* Process the selection groups
      /*-*/
      var_stg_mem_count := 0;
      var_stg_res_count := 0;
      open csr_group;
      loop
         fetch csr_group into rcd_group;
         if csr_group%notfound then
            exit;
         end if;

         /*-*/
         /* Create the work selection group
         /*-*/
         insert into pts_wor_sel_group
            values(rcd_group.stg_sel_group);

         /*-*/
         /* Load the group array
         /*-*/
         tbl_sel_group(tbl_sel_group.count+1).sel_group := rcd_group.stg_sel_group;
         tbl_sel_group(tbl_sel_group.count).str_rule := 0;
         tbl_sel_group(tbl_sel_group.count).end_rule := 0;
         tbl_sel_group(tbl_sel_group.count).req_mem_count := round(par_req_mem_count * nvl(rcd_group.stg_sel_pcnt,0), 0);
         tbl_sel_group(tbl_sel_group.count).req_res_count := round(par_req_res_count * nvl(rcd_group.stg_sel_pcnt,0), 0);
         tbl_sel_group(tbl_sel_group.count).sel_mem_count := 0;
         tbl_sel_group(tbl_sel_group.count).sel_res_count := 0;
         var_stg_mem_count := var_stg_mem_count + tbl_sel_group(tbl_sel_group.count).req_mem_count;
         var_stg_res_count := var_stg_res_count + tbl_sel_group(tbl_sel_group.count).req_res_count;

      end loop;
      close csr_group;

      /*-*/
      /* Complete the group processing when required
      /*-*/
      if tbl_sel_group.count != 0 then

         /*-*/
         /* Adjust the group counts when required
         /* **note** 1. the last group contains any rounding
         /*-*/
         if var_stg_mem_count != par_req_mem_count then
            tbl_sel_group(tbl_sel_group.count).req_mem_count := tbl_sel_group(tbl_sel_group.count).req_mem_count + (par_req_mem_count - var_stg_mem_count);
         end if;
         if var_stg_res_count != par_req_res_count then
            tbl_sel_group(tbl_sel_group.count).req_res_count := tbl_sel_group(tbl_sel_group.count).req_res_count + (par_req_res_count - var_stg_res_count);
         end if;

         /*-*/
         /* Reset the test group panel member and reserve counts
         /*-*/
         for idg in 1..tbl_sel_group.count loop
            update pts_stm_group
               set stg_req_mem_count = tbl_sel_group(idg).req_mem_count,
                   stg_req_res_count = tbl_sel_group(idg).req_res_count,
                   stg_sel_mem_count = 0,
                   stg_sel_res_count = 0
             where stg_stm_code = par_stm_code
               and stg_sel_group = tbl_sel_group(idg).sel_group;
         end loop;

      end if;

      /*-*/
      /* Process the selection group rules
      /*-*/
      for idg in 1..tbl_sel_group.count loop

         /*-*/
         /* Process the selection group rules
         /*-*/
         var_sel_group := tbl_sel_group(idg).sel_group;
         open csr_rule;
         loop
            fetch csr_rule into rcd_rule;
            if csr_rule%notfound then
               exit;
            end if;

            /*-*/
            /* Create the work selection rule
            /*-*/
            insert into pts_wor_sel_rule
               values(rcd_rule.str_sel_group,
                      rcd_rule.str_tab_code,
                      rcd_rule.str_fld_code,
                      rcd_rule.str_rul_code);

            /*-*/
            /* Load the rule array
            /*-*/
            tbl_sel_rule(tbl_sel_rule.count+1).sel_group := rcd_rule.str_sel_group;
            tbl_sel_rule(tbl_sel_rule.count).tab_code := rcd_rule.str_tab_code;
            tbl_sel_rule(tbl_sel_rule.count).fld_code := rcd_rule.str_fld_code;
            tbl_sel_rule(tbl_sel_rule.count).rul_code := rcd_rule.str_rul_code;
            tbl_sel_rule(tbl_sel_rule.count).str_value := 0;
            tbl_sel_rule(tbl_sel_rule.count).end_value := 0;
            tbl_sel_rule(tbl_sel_rule.count).sel_count := 0;
            if tbl_sel_group(idg).str_rule = 0 then
               tbl_sel_group(idg).str_rule := tbl_sel_rule.count;
            end if;
            tbl_sel_group(idg).end_rule := tbl_sel_rule.count;

            /*-*/
            /* Process the selection group rule values
            /*-*/
            var_stv_mem_count := 0;
            var_stv_res_count := 0;
            open csr_value;
            loop
               fetch csr_value into rcd_value;
               if csr_value%notfound then
                  exit;
               end if;

               /*-*/
               /* Create the work selection value
               /*-*/
               insert into pts_wor_sel_value
                  values(rcd_value.stv_sel_group,
                         rcd_value.stv_tab_code,
                         rcd_value.stv_fld_code,
                         rcd_value.stv_val_code,
                         rcd_value.stv_val_text);

               /*-*/
               /* Load the value array
               /*-*/
               tbl_sel_value(tbl_sel_value.count+1).sel_group := rcd_value.stv_sel_group;
               tbl_sel_value(tbl_sel_value.count).tab_code := rcd_value.stv_tab_code;
               tbl_sel_value(tbl_sel_value.count).fld_code := rcd_value.stv_fld_code;
               tbl_sel_value(tbl_sel_value.count).val_code := rcd_value.stv_val_code;
               tbl_sel_value(tbl_sel_value.count).val_text := rcd_value.stv_val_text;
               tbl_sel_value(tbl_sel_value.count).val_pcnt := rcd_value.stv_val_pcnt;
               tbl_sel_value(tbl_sel_value.count).req_mem_count := 0;
               tbl_sel_value(tbl_sel_value.count).req_res_count := 0;
               tbl_sel_value(tbl_sel_value.count).sel_mem_count := 0;
               tbl_sel_value(tbl_sel_value.count).sel_res_count := 0;
               tbl_sel_value(tbl_sel_value.count).sel_count := 0;
               tbl_sel_value(tbl_sel_value.count).fld_count := 0;
               if tbl_sel_rule(tbl_sel_rule.count).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                  tbl_sel_value(tbl_sel_value.count).req_mem_count := round(tbl_sel_group(idg).req_mem_count * nvl(rcd_value.stv_val_pcnt,0), 0);
                  tbl_sel_value(tbl_sel_value.count).req_res_count := round(tbl_sel_group(idg).req_res_count * nvl(rcd_value.stv_val_pcnt,0), 0);
                  var_stv_mem_count := var_stv_mem_count + tbl_sel_value(tbl_sel_value.count).req_mem_count;
                  var_stv_res_count := var_stv_res_count + tbl_sel_value(tbl_sel_value.count).req_res_count;
               end if;
               if tbl_sel_rule(tbl_sel_rule.count).str_value = 0 then
                  tbl_sel_rule(tbl_sel_rule.count).str_value := tbl_sel_value.count;
               end if;
               tbl_sel_rule(tbl_sel_rule.count).end_value := tbl_sel_value.count;

            end loop;
            close csr_value;

            /*-*/
            /* Complete the group rule processing when required
            /*-*/
            if tbl_sel_rule(tbl_sel_rule.count).str_value != 0 then

               /*-*/
               /* Adjust the value counts when required
               /* **note** 1. the last value contains any rounding
               /*-*/
               if tbl_sel_rule(tbl_sel_rule.count).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                  if var_stv_mem_count != tbl_sel_group(idg).req_mem_count then
                     tbl_sel_value(tbl_sel_rule(tbl_sel_rule.count).end_value).req_mem_count := tbl_sel_value(tbl_sel_rule(tbl_sel_rule.count).end_value).req_mem_count + (tbl_sel_group(idg).req_mem_count - var_stv_mem_count);
                  end if;
                  if var_stv_res_count != tbl_sel_group(idg).req_res_count then
                     tbl_sel_value(tbl_sel_rule(tbl_sel_rule.count).end_value).req_res_count := tbl_sel_value(tbl_sel_rule(tbl_sel_rule.count).end_value).req_res_count + (tbl_sel_group(idg).req_res_count - var_stv_res_count);
                  end if;
               end if;

               /*-*/
               /* Reset the group rule value panel member and reserve counts
               /*-*/
               for idv in tbl_sel_rule(tbl_sel_rule.count).str_value..tbl_sel_rule(tbl_sel_rule.count).end_value loop
                  update pts_stm_value
                     set stv_req_mem_count = tbl_sel_value(idv).req_mem_count,
                         stv_req_res_count = tbl_sel_value(idv).req_res_count,
                         stv_sel_mem_count = 0,
                         stv_sel_res_count = 0
                   where stv_stm_code = par_stm_code
                     and stv_sel_group = tbl_sel_value(idv).sel_group
                     and stv_tab_code = tbl_sel_value(idv).tab_code
                     and stv_fld_code = tbl_sel_value(idv).fld_code
                     and stv_val_code = tbl_sel_value(idv).val_code;
               end loop;

            end if;

         end loop;
         close csr_rule;

      end loop;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_STM_FUNCTION - CLEAR_PANEL - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear_panel;

   /********************************************************/
   /* This procedure performs the select pet panel routine */
   /********************************************************/
   procedure select_pet_panel(par_stm_code in number, par_pan_type in varchar2, par_pet_multiple in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      rcd_pts_stm_panel pts_stm_panel%rowtype;
      var_sel_group varchar2(32);
      var_set_tot_count number;
      var_set_sel_count number;
      var_pan_selected boolean;
      var_available boolean;
      type rcd_sel_data is record(tab_code varchar2(32 char),
                                  fld_code number,
                                  val_code number);
      type typ_sel_data is table of rcd_sel_data index by binary_integer;
      tbl_sel_data typ_sel_data;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_panel is
         select t01.pde_pet_code,
                t01.pde_hou_code,
                t01.pde_pet_type,
                (select case when count(*)=0 then 0 when count(*)=1 then 1 else 2 end from pts_hou_pet_type where hpt_hou_code=t01.pde_hou_code) as pde_hou_status,
                (select case when count(*)=0 then 0 when count(*)=1 then 1 else 2 end from pts_hou_pet_type where hpt_hou_code=t01.pde_hou_code and hpt_pet_type=t01.pde_pet_type) as pde_hou_count,
                t02.hde_geo_zone
           from pts_pet_definition t01,
                pts_hou_definition t02
          where t01.pde_hou_code = t02.hde_hou_code
            and t01.pde_pet_code in (select sel_code from table(pts_app.pts_gen_function.get_list_data('*PET',var_sel_group)))
            and t01.pde_pet_status = 1
            and t01.pde_pet_code not in (select nvl(stp_pet_code,-1)
                                           from pts_stm_panel
                                          where stp_stm_code = par_stm_code)
          order by dbms_random.value;
      rcd_panel csr_panel%rowtype;

      cursor csr_classification is
         select t01.*
           from (select t01.hcl_tab_code as tab_code,
                        t01.hcl_fld_code as fld_code,
                        t01.hcl_val_code as val_code
                   from pts_hou_classification t01,
                        pts_sys_field t02
                  where t01.hcl_tab_code = t02.sfi_tab_code
                    and t01.hcl_fld_code = t02.sfi_fld_code
                    and t01.hcl_hou_code = rcd_panel.pde_hou_code
                    and t02.sfi_fld_rul_type = '*LIST'
                 union all
                 select t01.pcl_tab_code as tab_code,
                        t01.pcl_fld_code as fld_code,
                        t01.pcl_val_code as val_code
                   from pts_pet_classification t01,
                        pts_sys_field t02
                  where t01.pcl_tab_code = t02.sfi_tab_code
                    and t01.pcl_fld_code = t02.sfi_fld_code
                    and t01.pcl_pet_code = rcd_panel.pde_pet_code
                    and t02.sfi_fld_rul_type = '*LIST') t01
          order by t01.tab_code asc,
                   t01.fld_code asc,
                   t01.val_code asc;
      rcd_classification csr_classification%rowtype;

      cursor csr_panel_check is
         select stp_pet_code
           from pts_stm_panel t01
          where t01.stp_stm_code = par_stm_code
            and t01.stp_hou_code = rcd_panel.pde_hou_code;
      rcd_panel_check csr_panel_check%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the test selection groups for panel inclusion
      /* **note** 1. Groups are logically ORed and mutually exclusive
      /*          2. The first group to satisfy all group rules will be selected
      /*          3. Percentage mix rules are satisfied by matched selected counts
      /*-*/
      for idg in 1..tbl_sel_group.count loop

         /*-*/
         /* Process the selection group rules
         /*-*/
         var_sel_group := tbl_sel_group(idg).sel_group;

         /*-*/
         /* Retrieve the panel for potential candidates
         /*-*/
         open csr_panel;
         loop
            fetch csr_panel into rcd_panel;
            if csr_panel%notfound then
               exit;
            end if;

            /*-*/
            /* Clear the selection data
            /*-*/
            tbl_sel_data.delete;

            /*-*/
            /* Load the definition data
            /*-*/
            tbl_sel_data(tbl_sel_data.count+1).tab_code := '*PET_DEF';
            tbl_sel_data(tbl_sel_data.count).fld_code := 2;
            tbl_sel_data(tbl_sel_data.count).val_code := rcd_panel.pde_pet_type;

            tbl_sel_data(tbl_sel_data.count+1).tab_code := '*PET_DEF';
            tbl_sel_data(tbl_sel_data.count).fld_code := 9;
            tbl_sel_data(tbl_sel_data.count).val_code := rcd_panel.pde_hou_status;

            tbl_sel_data(tbl_sel_data.count+1).tab_code := '*PET_DEF';
            tbl_sel_data(tbl_sel_data.count).fld_code := 10;
            tbl_sel_data(tbl_sel_data.count).val_code := rcd_panel.pde_hou_count;

            tbl_sel_data(tbl_sel_data.count+1).tab_code := '*HOU_DEF';
            tbl_sel_data(tbl_sel_data.count).fld_code := 2;
            tbl_sel_data(tbl_sel_data.count).val_code := rcd_panel.hde_geo_zone;

            /*-*/
            /* Retrieve and load the classification data (*LIST only)
            /*-*/
            open csr_classification;
            loop
               fetch csr_classification into rcd_classification;
               if csr_classification%notfound then
                  exit;
               end if;
               tbl_sel_data(tbl_sel_data.count+1).tab_code := rcd_classification.tab_code;
               tbl_sel_data(tbl_sel_data.count).fld_code := rcd_classification.fld_code;
               tbl_sel_data(tbl_sel_data.count).val_code := rcd_classification.val_code;
            end loop;
            close csr_classification;

            /*-*/
            /* Process the selection group rules
            /* **note** 1. Rules are logically ANDed
            /*          2. Non percentage mix rules are satisfied in the SQL
            /*          3. Percentage mix rules are satisfied by matched selected counts
            /*-*/
            for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
               tbl_sel_rule(idr).sel_count := 0;
               if tbl_sel_rule(idr).rul_code != '*SELECT_WHEN_EQUAL_MIX' then
                  tbl_sel_rule(idr).sel_count := 1;
               else
                  for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                     tbl_sel_value(idv).sel_count := 0;
                     tbl_sel_value(idv).fld_count := 0;
                     for idc in 1..tbl_sel_data.count loop
                        if (tbl_sel_data(idc).tab_code = tbl_sel_value(idv).tab_code and
                            tbl_sel_data(idc).fld_code = tbl_sel_value(idv).fld_code and
                            tbl_sel_data(idc).val_code = tbl_sel_value(idv).val_code) then
                           tbl_sel_value(idv).fld_count := 1;
                           exit;
                        end if;
                     end loop;
                  end loop;
                  for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                     if upper(par_pan_type) = '*MEMBER' then
                        if tbl_sel_value(idv).req_mem_count > tbl_sel_value(idv).sel_mem_count then
                           if tbl_sel_value(idv).fld_count = 1 then
                              tbl_sel_value(idv).sel_count := 1;
                              tbl_sel_rule(idr).sel_count := 1;
                              exit;
                           end if;
                        end if;
                     else
                        if tbl_sel_value(idv).req_res_count > tbl_sel_value(idv).sel_res_count then
                           if tbl_sel_value(idv).fld_count = 1 then
                              tbl_sel_value(idv).sel_count := 1;
                              tbl_sel_rule(idr).sel_count := 1;
                              exit;
                           end if;
                        end if;
                     end if;
                  end loop;
               end if;
            end loop;

            /*-*/
            /* Reset the panel selection indicator
            /*-*/
            var_pan_selected := false;

            /*-*/
            /* Evaluate the group selection
            /* **note** 1. Compare the rule total count to the rule selected count
            /*          2. All rules must be satisfied (logically ANDed)
            /*-*/
            var_set_tot_count := 0;
            var_set_sel_count := 0;
            for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
               var_set_tot_count := var_set_tot_count + 1;
               if tbl_sel_rule(idr).sel_count = 1 then
                  var_set_sel_count := var_set_sel_count + 1;
               end if;
            end loop;

            /*-*/
            /* Panel satisfies the group selection
            /*-*/
            if var_set_sel_count = var_set_tot_count then

               /*-*/
               /* Set the panel to selected
               /*-*/
               var_pan_selected := true;

               /*-*/
               /* Check for multiple panel pets when required
               /*-*/
               if par_pet_multiple = '0' then
                  open csr_panel_check;
                  fetch csr_panel_check into rcd_panel_check;
                  if csr_panel_check%found then
                     var_pan_selected := false;
                  end if;
                  close csr_panel_check;
               end if;

            end if;

            /*-*/
            /* Process selected panel
            /*-*/
            if var_pan_selected = true then

               /*-*/
               /* Update the internal selection counts
               /*-*/
               if upper(par_pan_type) = '*MEMBER' then
                  tbl_sel_group(idg).sel_mem_count := tbl_sel_group(idg).sel_mem_count + 1;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              tbl_sel_value(idv).sel_mem_count := tbl_sel_value(idv).sel_mem_count + 1;
                           end if;
                        end loop;
                     end if;
                  end loop;
               else
                  tbl_sel_group(idg).sel_res_count := tbl_sel_group(idg).sel_res_count + 1;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              tbl_sel_value(idv).sel_res_count := tbl_sel_value(idv).sel_res_count + 1;
                           end if;
                        end loop;
                     end if;
                  end loop;
               end if;

               /*-*/
               /* Insert the new panel member
               /*-*/
               rcd_pts_stm_panel.stp_stm_code := par_stm_code;
               rcd_pts_stm_panel.stp_sel_group := tbl_sel_group(idg).sel_group;
               rcd_pts_stm_panel.stp_hou_code := rcd_panel.pde_hou_code;
               rcd_pts_stm_panel.stp_pet_code := rcd_panel.pde_pet_code;
               rcd_pts_stm_panel.stp_pan_status := upper(par_pan_type);
               insert into pts_stm_panel values rcd_pts_stm_panel;

               /*-*/
               /* Update the test counts
               /*-*/
               if upper(par_pan_type) = '*MEMBER' then
                  update pts_stm_group
                     set stg_sel_mem_count = stg_sel_mem_count + 1
                   where stg_stm_code = par_stm_code
                     and stg_sel_group = tbl_sel_group(idg).sel_group;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              update pts_stm_value
                                 set stv_sel_mem_count = stv_sel_mem_count + 1
                               where stv_stm_code = par_stm_code
                                 and stv_sel_group = tbl_sel_value(idv).sel_group
                                 and stv_tab_code = tbl_sel_value(idv).tab_code
                                 and stv_fld_code = tbl_sel_value(idv).fld_code
                                 and stv_val_code = tbl_sel_value(idv).val_code;
                           end if;
                        end loop;
                     end if;
                  end loop;
               else
                  update pts_stm_group
                     set stg_sel_res_count = stg_sel_res_count + 1
                   where stg_stm_code = par_stm_code
                     and stg_sel_group = tbl_sel_group(idg).sel_group;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              update pts_stm_value
                                 set stv_sel_res_count = stv_sel_res_count + 1
                               where stv_stm_code = par_stm_code
                                 and stv_sel_group = tbl_sel_value(idv).sel_group
                                 and stv_tab_code = tbl_sel_value(idv).tab_code
                                 and stv_fld_code = tbl_sel_value(idv).fld_code
                                 and stv_val_code = tbl_sel_value(idv).val_code;
                           end if;
                        end loop;
                     end if;
                  end loop;
               end if;

            end if;

            /*-*/
            /* Exit the panel loop when group panel requirements satisfied
            /*-*/
            if upper(par_pan_type) = '*MEMBER' then
               if tbl_sel_group(idg).sel_mem_count >= tbl_sel_group(idg).req_mem_count then
                  exit;
               end if;
            else
               if tbl_sel_group(idg).sel_res_count >= tbl_sel_group(idg).req_res_count then
                  exit;
               end if;
            end if;

         end loop;
         close csr_panel;

      end loop;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_STM_FUNCTION - SELECT_PET_PANEL - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_pet_panel;

   /**************************************************************/
   /* This procedure performs the select household panel routine */
   /**************************************************************/
   procedure select_hou_panel(par_stm_code in number, par_pan_type in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      rcd_pts_stm_panel pts_stm_panel%rowtype;
      var_sel_group varchar2(32);
      var_set_tot_count number;
      var_set_sel_count number;
      var_pan_selected boolean;
      var_available boolean;
      type rcd_sel_data is record(tab_code varchar2(32 char),
                                  fld_code number,
                                  val_code number);
      type typ_sel_data is table of rcd_sel_data index by binary_integer;
      tbl_sel_data typ_sel_data;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_panel is
         select t01.hde_hou_code,
                t01.hde_geo_zone
           from pts_hou_definition t01
          where t01.hde_hou_code in (select sel_code from table(pts_app.pts_gen_function.get_list_data('*HOUSEHOLD',var_sel_group)))
            and t01.hde_hou_status = 1
            and t01.hde_hou_code not in (select nvl(stp_hou_code,-1)
                                           from pts_stm_panel
                                          where stp_stm_code = par_stm_code)
          order by dbms_random.value;
      rcd_panel csr_panel%rowtype;

      cursor csr_classification is
         select t01.*
           from (select t01.hcl_tab_code as tab_code,
                        t01.hcl_fld_code as fld_code,
                        t01.hcl_val_code as val_code
                   from pts_hou_classification t01,
                        pts_sys_field t02
                  where t01.hcl_tab_code = t02.sfi_tab_code
                    and t01.hcl_fld_code = t02.sfi_fld_code
                    and t01.hcl_hou_code = rcd_panel.hde_hou_code
                    and t02.sfi_fld_rul_type = '*LIST') t01
          order by t01.tab_code asc,
                   t01.fld_code asc,
                   t01.val_code asc;
      rcd_classification csr_classification%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the test selection groups for panel inclusion
      /* **note** 1. Groups are logically ORed and mutually exclusive
      /*          2. The first group to satisfy all group rules will be selected
      /*          3. Percentage mix rules are satisfied by matched selected counts
      /*-*/
      for idg in 1..tbl_sel_group.count loop

         /*-*/
         /* Process the selection group rules
         /*-*/
         var_sel_group := tbl_sel_group(idg).sel_group;

         /*-*/
         /* Retrieve the panel for potential candidates
         /*-*/
         open csr_panel;
         loop
            fetch csr_panel into rcd_panel;
            if csr_panel%notfound then
               exit;
            end if;

            /*-*/
            /* Clear the selection data
            /*-*/
            tbl_sel_data.delete;

            /*-*/
            /* Load the definition data
            /*-*/
            tbl_sel_data(tbl_sel_data.count+1).tab_code := '*HOU_DEF';
            tbl_sel_data(tbl_sel_data.count).fld_code := 2;
            tbl_sel_data(tbl_sel_data.count).val_code := rcd_panel.hde_geo_zone;

            /*-*/
            /* Retrieve and load the classification data (*LIST only)
            /*-*/
            open csr_classification;
            loop
               fetch csr_classification into rcd_classification;
               if csr_classification%notfound then
                  exit;
               end if;
               tbl_sel_data(tbl_sel_data.count+1).tab_code := rcd_classification.tab_code;
               tbl_sel_data(tbl_sel_data.count).fld_code := rcd_classification.fld_code;
               tbl_sel_data(tbl_sel_data.count).val_code := rcd_classification.val_code;
            end loop;
            close csr_classification;

            /*-*/
            /* Process the selection group rules
            /* **note** 1. Rules are logically ANDed
            /*          2. Non percentage mix rules are satisfied in the SQL
            /*          3. Percentage mix rules are satisfied by matched selected counts
            /*-*/
            for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
               tbl_sel_rule(idr).sel_count := 0;
               if tbl_sel_rule(idr).rul_code != '*SELECT_WHEN_EQUAL_MIX' then
                  tbl_sel_rule(idr).sel_count := 1;
               else
                  for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                     tbl_sel_value(idv).sel_count := 0;
                     tbl_sel_value(idv).fld_count := 0;
                     for idc in 1..tbl_sel_data.count loop
                        if (tbl_sel_data(idc).tab_code = tbl_sel_value(idv).tab_code and
                            tbl_sel_data(idc).fld_code = tbl_sel_value(idv).fld_code and
                            tbl_sel_data(idc).val_code = tbl_sel_value(idv).val_code) then
                           tbl_sel_value(idv).fld_count := 1;
                           exit;
                        end if;
                     end loop;
                  end loop;
                  for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                     if upper(par_pan_type) = '*MEMBER' then
                        if tbl_sel_value(idv).req_mem_count > tbl_sel_value(idv).sel_mem_count then
                           if tbl_sel_value(idv).fld_count = 1 then
                              tbl_sel_value(idv).sel_count := 1;
                              tbl_sel_rule(idr).sel_count := 1;
                              exit;
                           end if;
                        end if;
                     else
                        if tbl_sel_value(idv).req_res_count > tbl_sel_value(idv).sel_res_count then
                           if tbl_sel_value(idv).fld_count = 1 then
                              tbl_sel_value(idv).sel_count := 1;
                              tbl_sel_rule(idr).sel_count := 1;
                              exit;
                           end if;
                        end if;
                     end if;
                  end loop;
               end if;
            end loop;

            /*-*/
            /* Reset the panel selection indicator
            /*-*/
            var_pan_selected := false;

            /*-*/
            /* Evaluate the group selection
            /* **note** 1. Compare the rule total count to the rule selected count
            /*          2. All rules must be satisfied (logically ANDed)
            /*-*/
            var_set_tot_count := 0;
            var_set_sel_count := 0;
            for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
               var_set_tot_count := var_set_tot_count + 1;
               if tbl_sel_rule(idr).sel_count = 1 then
                  var_set_sel_count := var_set_sel_count + 1;
               end if;
            end loop;

            /*-*/
            /* Panel satisfies the group selection
            /*-*/
            if var_set_sel_count = var_set_tot_count then

               /*-*/
               /* Set the panel to selected
               /*-*/
               var_pan_selected := true;

            end if;

            /*-*/
            /* Process selected panel
            /*-*/
            if var_pan_selected = true then

               /*-*/
               /* Update the internal selection counts
               /*-*/
               if upper(par_pan_type) = '*MEMBER' then
                  tbl_sel_group(idg).sel_mem_count := tbl_sel_group(idg).sel_mem_count + 1;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              tbl_sel_value(idv).sel_mem_count := tbl_sel_value(idv).sel_mem_count + 1;
                           end if;
                        end loop;
                     end if;
                  end loop;
               else
                  tbl_sel_group(idg).sel_res_count := tbl_sel_group(idg).sel_res_count + 1;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              tbl_sel_value(idv).sel_res_count := tbl_sel_value(idv).sel_res_count + 1;
                           end if;
                        end loop;
                     end if;
                  end loop;
               end if;

               /*-*/
               /* Insert the new panel member
               /*-*/
               rcd_pts_stm_panel.stp_stm_code := par_stm_code;
               rcd_pts_stm_panel.stp_sel_group := tbl_sel_group(idg).sel_group;
               rcd_pts_stm_panel.stp_hou_code := rcd_panel.hde_hou_code;
               rcd_pts_stm_panel.stp_pet_code := 0;
               rcd_pts_stm_panel.stp_pan_status := upper(par_pan_type);
               insert into pts_stm_panel values rcd_pts_stm_panel;

               /*-*/
               /* Update the test counts
               /*-*/
               if upper(par_pan_type) = '*MEMBER' then
                  update pts_stm_group
                     set stg_sel_mem_count = stg_sel_mem_count + 1
                   where stg_stm_code = par_stm_code
                     and stg_sel_group = tbl_sel_group(idg).sel_group;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              update pts_stm_value
                                 set stv_sel_mem_count = stv_sel_mem_count + 1
                               where stv_stm_code = par_stm_code
                                 and stv_sel_group = tbl_sel_value(idv).sel_group
                                 and stv_tab_code = tbl_sel_value(idv).tab_code
                                 and stv_fld_code = tbl_sel_value(idv).fld_code
                                 and stv_val_code = tbl_sel_value(idv).val_code;
                           end if;
                        end loop;
                     end if;
                  end loop;
               else
                  update pts_stm_group
                     set stg_sel_res_count = stg_sel_res_count + 1
                   where stg_stm_code = par_stm_code
                     and stg_sel_group = tbl_sel_group(idg).sel_group;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              update pts_stm_value
                                 set stv_sel_res_count = stv_sel_res_count + 1
                               where stv_stm_code = par_stm_code
                                 and stv_sel_group = tbl_sel_value(idv).sel_group
                                 and stv_tab_code = tbl_sel_value(idv).tab_code
                                 and stv_fld_code = tbl_sel_value(idv).fld_code
                                 and stv_val_code = tbl_sel_value(idv).val_code;
                           end if;
                        end loop;
                     end if;
                  end loop;
               end if;

            end if;

            /*-*/
            /* Exit the panel loop when group panel requirements satisfied
            /*-*/
            if upper(par_pan_type) = '*MEMBER' then
               if tbl_sel_group(idg).sel_mem_count >= tbl_sel_group(idg).req_mem_count then
                  exit;
               end if;
            else
               if tbl_sel_group(idg).sel_res_count >= tbl_sel_group(idg).req_res_count then
                  exit;
               end if;
            end if;

         end loop;
         close csr_panel;

      end loop;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_STM_FUNCTION - SELECT_HOU_PANEL - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_hou_panel;

end pts_stm_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_stm_function for pts_app.pts_stm_function;
grant execute on pts_app.pts_stm_function to public;

/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_gen_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_gen_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - General functions

    This package contain the general functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure set_list_data;
   function get_list_from return pts_sel_list_type pipelined;
   function get_list_data(par_ent_code in varchar2, par_sel_group in varchar2) return pts_sel_list_type pipelined;
   function test_list(par_ent_code in varchar2, par_sel_group in varchar2) return pts_xml_type pipelined;
   function list_fld_data return pts_xml_type pipelined;
   function list_rul_data return pts_xml_type pipelined;
   function list_pet_type return pts_cla_list_type pipelined;
   function list_class(par_tab_code in varchar2, par_fld_code in number) return pts_cla_list_type pipelined;
   function list_class(par_pet_type in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_list_type pipelined;

end pts_gen_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_gen_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   pvar_end_code number;

   /*****************************************************/
   /* This procedure performs the set list data routine */
   /*****************************************************/
   procedure set_list_data is

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
      rcd_pts_wor_sel_group pts_wor_sel_group%rowtype;
      rcd_pts_wor_sel_rule pts_wor_sel_rule%rowtype;
      rcd_pts_wor_sel_value pts_wor_sel_value%rowtype;
      var_action varchar2(32);
      var_group boolean;

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
      /* Set the list default
      /*-*/
      pvar_end_code := 0;

      /*-*/
      /* Parse the XML input
      /*-*/
      if dbms_lob.getlength(lics_form.get_clob('PTS_STREAM')) = 0 then
         return;
      end if;
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve and process the stream header
      /*-*/
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      pvar_end_code := nvl(pts_to_number(xslProcessor.valueOf(obj_pts_request,'@ENDCDE')),0);
      if var_action != '*SELDTA' then
         raise_application_error(-20000, 'Invalid request action');
      end if;

      /*-*/
      /* Retrieve and process the stream nodes
      /*-*/
      obj_grp_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/GROUP');
      for idg in 0..xmlDom.getLength(obj_grp_list)-1 loop
         obj_grp_node := xmlDom.item(obj_grp_list,idg);
         var_group := false;
         obj_rul_list := xslProcessor.selectNodes(obj_grp_node,'RULE');
         for idr in 0..xmlDom.getLength(obj_rul_list)-1 loop
            if var_group = false then
               rcd_pts_wor_sel_group.wsg_sel_group := upper(xslProcessor.valueOf(obj_grp_node,'@GRPCDE'));
               insert into pts_wor_sel_group values rcd_pts_wor_sel_group;
               var_group := true;
            end if;
            obj_rul_node := xmlDom.item(obj_rul_list,idr);
            rcd_pts_wor_sel_rule.wsr_sel_group := rcd_pts_wor_sel_group.wsg_sel_group;
            rcd_pts_wor_sel_rule.wsr_tab_code := upper(xslProcessor.valueOf(obj_rul_node,'@TABCDE'));
            rcd_pts_wor_sel_rule.wsr_fld_code := pts_to_number(xslProcessor.valueOf(obj_rul_node,'@FLDCDE'));
            rcd_pts_wor_sel_rule.wsr_rul_code := upper(xslProcessor.valueOf(obj_rul_node,'@RULCDE'));
            insert into pts_wor_sel_rule values rcd_pts_wor_sel_rule;
            obj_val_list := xslProcessor.selectNodes(obj_rul_node,'VALUE');
            for idv in 0..xmlDom.getLength(obj_val_list)-1 loop
               obj_val_node := xmlDom.item(obj_val_list,idv);
               rcd_pts_wor_sel_value.wsv_sel_group := rcd_pts_wor_sel_rule.wsr_sel_group;
               rcd_pts_wor_sel_value.wsv_tab_code := rcd_pts_wor_sel_rule.wsr_tab_code;
               rcd_pts_wor_sel_value.wsv_fld_code := rcd_pts_wor_sel_rule.wsr_fld_code;
               rcd_pts_wor_sel_value.wsv_val_code := pts_to_number(xslProcessor.valueOf(obj_val_node,'@VALCDE'));
               rcd_pts_wor_sel_value.wsv_val_text := xslProcessor.valueOf(obj_val_node,'@VALTXT');
               insert into pts_wor_sel_value values rcd_pts_wor_sel_value;
            end loop;
         end loop;
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
         raise_application_error(-20000, 'PTS_GEN_FUNCTION - SET_LIST_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_list_data;

   /*****************************************************/
   /* This procedure performs the get list from routine */
   /*****************************************************/
   function get_list_from return pts_sel_list_type pipelined is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Pipe the list from code
      /*-*/
      pipe row(pts_sel_list_object(pvar_end_code));
      return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_list_from;

   /*****************************************************/
   /* This procedure performs the get list data routine */
   /*****************************************************/
   function get_list_data(par_ent_code in varchar2, par_sel_group in varchar2) return pts_sel_list_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_group_found boolean;
      var_rule_found boolean;
      var_value_found boolean;
      var_sel_code number;
      var_str_test varchar2(32);
      var_query varchar2(32767);
      type typ_dynamic_cursor is ref cursor;
      var_dynamic_cursor typ_dynamic_cursor;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_entity is
         select t01.sen_ent_sel_sql
           from pts_sys_entity t01
          where t01.sen_ent_code = upper(par_ent_code);
      rcd_entity csr_entity%rowtype;

      cursor csr_group is
         select t01.wsg_sel_group
           from pts_wor_sel_group t01
          where (par_sel_group is null or t01.wsg_sel_group = upper(par_sel_group))
          order by t01.wsg_sel_group;
      rcd_group csr_group%rowtype;

      cursor csr_rule is
         select t01.wsr_sel_group,
                t01.wsr_tab_code,
                t01.wsr_fld_code,
                t02.sfi_fld_rul_type,
                t02.sfi_fld_rul_tes_sql,
                t03.sru_rul_cond,
                t03.sru_rul_test,
                t03.sru_rul_lnot
           from pts_wor_sel_rule t01,
                pts_sys_field t02,
                pts_sys_rule t03
          where t01.wsr_tab_code = t02.sfi_tab_code
            and t01.wsr_fld_code = t02.sfi_fld_code
            and t01.wsr_rul_code = t03.sru_rul_code
            and t01.wsr_sel_group = rcd_group.wsg_sel_group
          order by t01.wsr_tab_code asc,
                   t01.wsr_fld_code asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is
         select t01.wsv_val_code,
                t01.wsv_val_text
           from pts_wor_sel_value t01
          where t01.wsv_sel_group = rcd_rule.wsr_sel_group
            and t01.wsv_tab_code = rcd_rule.wsr_tab_code
            and t01.wsv_fld_code = rcd_rule.wsr_fld_code
          order by t01.wsv_val_code;
      rcd_value csr_value%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Initialise the select query
      /*-*/
      var_query := null;
      open csr_entity;
      fetch csr_entity into rcd_entity;
      if csr_entity%found then
         var_query := rcd_entity.sen_ent_sel_sql;
      end if;
      close csr_entity;
      var_str_test := 'where';
      if instr(upper(var_query),'WHERE') != 0 then
         var_str_test := 'and';
      end if;

      /*-*/
      /* Process the selection groups
      /*-*/
      var_group_found := false;
      open csr_group;
      loop
         fetch csr_group into rcd_group;
         if csr_group%notfound then
            exit;
         end if;

         /*-*/
         /* Start the group
         /*-*/
         if var_group_found = false then
            var_query := var_query||' '||var_str_test||' ((';
         else
            var_query := var_query||' or (';
         end if;
         var_group_found := true;

         /*-*/
         /* Process the selection group rules
         /*-*/
         var_rule_found := false;
         open csr_rule;
         loop
            fetch csr_rule into rcd_rule;
            if csr_rule%notfound then
               exit;
            end if;

            /*-*/
            /* Start the rule
            /*-*/
            if var_rule_found = false then
               var_query := var_query||'(';
            else
               var_query := var_query||' and (';
            end if;
            var_rule_found := true;

            /*-*/
            /* Build the rule logical not test
            /*-*/
            if rcd_rule.sru_rul_lnot = '1' then
               var_query := var_query||'not(';
            end if;

            /*-*/
            /* Process the selection group rule values
            /*-*/
            var_value_found := false;
            open csr_value;
            loop
               fetch csr_value into rcd_value;
               if csr_value%notfound then
                  exit;
               end if;
               if var_value_found = true then
                  var_query := var_query||rcd_rule.sru_rul_cond;
               end if;
               var_value_found := true;
               if upper(rcd_rule.sfi_fld_rul_type) = '*LIST' then
                  var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_tes_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>',rcd_value.wsv_val_code);
               elsif upper(rcd_rule.sfi_fld_rul_type) = '*TEXT' then
                  if upper(trim(rcd_rule.sru_rul_test)) = 'LIKE' then
                     var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_tes_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>','upper(''%'||rcd_value.wsv_val_text||'%'')');
                  else
                     var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_tes_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>',''''||rcd_value.wsv_val_text||'''');
                  end if;
               elsif upper(rcd_rule.sfi_fld_rul_type) = '*NUMBER' then
                  var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_tes_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>',rcd_value.wsv_val_text);
               end if;
            end loop;
            close csr_value;

            /*-*/
            /* End the rule
            /*-*/
            if rcd_rule.sru_rul_lnot = '1' then
               var_query := var_query||')';
            end if;
            var_query := var_query||')';

         end loop;
         close csr_rule;

         /*-*/
         /* End the group
         /*-*/
         var_query := var_query||')';

      end loop;
      close csr_group;

      /*-*/
      /* End the list query when required
      /*-*/
      if var_group_found = true then
         var_query := var_query||')';
      end if;

      /*-*/
      /* Open the query and pipe the results
      /*-*/
      open var_dynamic_cursor for var_query;
      loop
         fetch var_dynamic_cursor into var_sel_code;
         if var_dynamic_cursor%notfound then
            exit;
         end if;
         pipe row(pts_sel_list_object(var_sel_code));
      end loop;
      close var_dynamic_cursor;

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
         raise_application_error(-20000, 'PTS_GEN_FUNCTION - GET_LIST_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_list_data;

   /*************************************************/
   /* This procedure performs the test list routine */
   /*************************************************/
   function test_list(par_ent_code in varchar2, par_sel_group in varchar2) return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_group_found boolean;
      var_rule_found boolean;
      var_value_found boolean;
      var_sel_code number;
      var_str_test varchar2(32);
      var_query varchar2(32767);
      var_idx number;
      var_len number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_entity is
         select t01.sen_ent_sel_sql
           from pts_sys_entity t01
          where t01.sen_ent_code = upper(par_ent_code);
      rcd_entity csr_entity%rowtype;

      cursor csr_group is
         select t01.wsg_sel_group
           from pts_wor_sel_group t01
          where (par_sel_group is null or t01.wsg_sel_group = upper(par_sel_group))
          order by t01.wsg_sel_group;
      rcd_group csr_group%rowtype;

      cursor csr_rule is
         select t01.wsr_sel_group,
                t01.wsr_tab_code,
                t01.wsr_fld_code,
                t02.sfi_fld_rul_type,
                t02.sfi_fld_rul_tes_sql,
                t03.sru_rul_cond,
                t03.sru_rul_test,
                t03.sru_rul_lnot
           from pts_wor_sel_rule t01,
                pts_sys_field t02,
                pts_sys_rule t03
          where t01.wsr_tab_code = t02.sfi_tab_code
            and t01.wsr_fld_code = t02.sfi_fld_code
            and t01.wsr_rul_code = t03.sru_rul_code
            and t01.wsr_sel_group = rcd_group.wsg_sel_group
          order by t01.wsr_tab_code asc,
                   t01.wsr_fld_code asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is
         select t01.wsv_val_code,
                t01.wsv_val_text
           from pts_wor_sel_value t01
          where t01.wsv_sel_group = rcd_rule.wsr_sel_group
            and t01.wsv_tab_code = rcd_rule.wsr_tab_code
            and t01.wsv_fld_code = rcd_rule.wsr_fld_code
          order by t01.wsv_val_code;
      rcd_value csr_value%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Initialise the select query
      /*-*/
      var_query := null;
      open csr_entity;
      fetch csr_entity into rcd_entity;
      if csr_entity%found then
         var_query := rcd_entity.sen_ent_sel_sql;
      end if;
      close csr_entity;
      var_str_test := 'where';
      if instr(upper(var_query),'WHERE') != 0 then
         var_str_test := 'and';
      end if;

      /*-*/
      /* Process the selection groups
      /*-*/
      var_group_found := false;
      open csr_group;
      loop
         fetch csr_group into rcd_group;
         if csr_group%notfound then
            exit;
         end if;

         /*-*/
         /* Start the group
         /*-*/
         if var_group_found = false then
            var_query := var_query||' '||var_str_test||' ((';
         else
            var_query := var_query||' or (';
         end if;
         var_group_found := true;

         /*-*/
         /* Process the selection group rules
         /*-*/
         var_rule_found := false;
         open csr_rule;
         loop
            fetch csr_rule into rcd_rule;
            if csr_rule%notfound then
               exit;
            end if;

            /*-*/
            /* Start the rule
            /*-*/
            if var_rule_found = false then
               var_query := var_query||'(';
            else
               var_query := var_query||' and (';
            end if;
            var_rule_found := true;

            /*-*/
            /* Build the rule logical not test
            /*-*/
            if rcd_rule.sru_rul_lnot = '1' then
               var_query := var_query||'not(';
            end if;

            /*-*/
            /* Process the selection group rule values
            /*-*/
            var_value_found := false;
            open csr_value;
            loop
               fetch csr_value into rcd_value;
               if csr_value%notfound then
                  exit;
               end if;
               if var_value_found = true then
                  var_query := var_query||rcd_rule.sru_rul_cond;
               end if;
               var_value_found := true;
               if upper(rcd_rule.sfi_fld_rul_type) = '*LIST' then
                  var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_tes_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>',rcd_value.wsv_val_code);
               elsif upper(rcd_rule.sfi_fld_rul_type) = '*TEXT' then
                  if upper(trim(rcd_rule.sru_rul_test)) = 'LIKE' then
                     var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_tes_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>','upper(''%'||rcd_value.wsv_val_text||'%'')');
                  else
                     var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_tes_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>',''''||rcd_value.wsv_val_text||'''');
                  end if;
               elsif upper(rcd_rule.sfi_fld_rul_type) = '*NUMBER' then
                  var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_tes_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>',rcd_value.wsv_val_text);
               end if;
            end loop;
            close csr_value;

            /*-*/
            /* End the rule
            /*-*/
            if rcd_rule.sru_rul_lnot = '1' then
               var_query := var_query||')';
            end if;
            var_query := var_query||')';

         end loop;
         close csr_rule;

         /*-*/
         /* End the group
         /*-*/
         var_query := var_query||')';

      end loop;
      close csr_group;

      /*-*/
      /* End the list query when required
      /*-*/
      if var_group_found = true then
         var_query := var_query||')';
      end if;

      /*-*/
      /* Pipe the query result
      /*-*/
      var_idx := 1;
      var_len := 2000;
      if not(var_query is null) then
         loop
            pipe row(pts_xml_object(substr(var_query,var_idx,var_len)));
            var_idx := var_idx + var_len;
            if var_idx > length(var_query) then
               exit;
            end if;
         end loop;
      end if;

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
         raise_application_error(-20000, 'PTS_GEN_FUNCTION - TEST_LIST - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end test_list;

   /*******************************************************/
   /* This procedure performs the list field data routine */
   /*******************************************************/
   function list_fld_data return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_ent_code varchar2(32);
      var_tes_flag varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_field is
         select t02.sfi_tab_code,
                t02.sfi_fld_code,
                t02.sfi_fld_text,
                t02.sfi_fld_inp_leng,
                t02.sfi_fld_rul_type
           from pts_sys_table t01,
                pts_sys_field t02
          where t01.sta_tab_code = t02.sfi_tab_code
            and t01.sta_ent_code = var_ent_code
            and (var_tes_flag != '1' or (var_tes_flag = '1' and t02.sfi_fld_tes_rule = '1'))
            and t02.sfi_fld_status = '1'
          order by t02.sfi_tab_code asc,
                   t02.sfi_fld_code asc;
      rcd_field csr_field%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

-- TAKE INTO ACCOUNT THE DISPLAY GROUPING AND SEQUENCE

      /*-*/
      /* Parse the XML input
      /*-*/
      if dbms_lob.getlength(lics_form.get_clob('PTS_STREAM')) = 0 then
         return;
      end if;
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      var_ent_code := upper(xslProcessor.valueOf(obj_pts_request,'@ENTCDE'));
      var_tes_flag := upper(xslProcessor.valueOf(obj_pts_request,'@TESFLG'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*LSTFLD' then
         raise_application_error(-20000, 'Invalid request action');
      end if;

      /*-*/
      /* Pipe the system field XML
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));
      open csr_field;
      loop
         fetch csr_field into rcd_field;
         if csr_field%notfound then
            exit;
         end if;
         var_output := '<FIELD TABCDE="'||rcd_field.sfi_tab_code||'"';
         var_output := var_output||' FLDCDE="'||to_char(rcd_field.sfi_fld_code)||'"';
         var_output := var_output||' FLDTXT="'||pts_to_xml(rcd_field.sfi_fld_text)||'"';
         var_output := var_output||' INPLEN="'||to_char(rcd_field.sfi_fld_inp_leng)||'"';
         var_output := var_output||' RULTYP="'||rcd_field.sfi_fld_rul_type||'"/>';
         pipe row(pts_xml_object(var_output));
      end loop;
      close csr_field;

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
         raise_application_error(-20000, 'PTS_GEN_FUNCTION - LIST_FLD_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_fld_data;

   /******************************************************/
   /* This procedure performs the list rule data routine */
   /******************************************************/
   function list_rul_data return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tab_code varchar2(32);
      var_fld_code number;
      var_val_code number;
      var_val_text varchar2(256);
      type typ_dynamic_cursor is ref cursor;
      var_dynamic_cursor typ_dynamic_cursor;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_field is
         select t01.sfi_fld_inp_leng,
                t01.sfi_fld_rul_sel_sql
           from pts_sys_field t01
          where t01.sfi_tab_code = var_tab_code
            and t01.sfi_fld_code = var_fld_code;
      rcd_field csr_field%rowtype;

      cursor csr_rule is
         select t02.sru_rul_code,
                t02.sru_rul_cond
           from pts_sys_select t01,
                pts_sys_rule t02
          where t01.sse_sel_code = t02.sru_rul_code
            and t01.sse_tab_code = var_tab_code
            and t01.sse_fld_code = var_fld_code
          order by t02.sru_rul_code asc;
      rcd_rule csr_rule%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Parse the XML input
      /*-*/
      if dbms_lob.getlength(lics_form.get_clob('PTS_STREAM')) = 0 then
         return;
      end if;
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      var_tab_code := upper(xslProcessor.valueOf(obj_pts_request,'@TABCDE'));
      var_fld_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@FLDCDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*LSTRUL' then
         raise_application_error(-20000, 'Invalid request action');
      end if;

      /*-*/
      /* Retrieve the field definition
      /*-*/
      open csr_field;
      fetch csr_field into rcd_field;
      if csr_field%notfound then
         raise_application_error(-20000, 'Field table('||var_tab_code||') field('||to_char(var_fld_code)||') does not exist');
      end if;
      close csr_field;

      /*-*/
      /* Pipe the system field rule XML
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));
      open csr_rule;
      loop
         fetch csr_rule into rcd_rule;
         if csr_rule%notfound then
            exit;
         end if;
         var_output := '<RULE RULCDE="'||rcd_rule.sru_rul_code||'" RULCND="'||rcd_rule.sru_rul_cond||'"/>';
         pipe row(pts_xml_object(var_output));
      end loop;
      close csr_rule;

      /*-*/
      /* Pipe the system field rule value XML
      /*-*/
      if not(rcd_field.sfi_fld_rul_sel_sql is null) then
         open var_dynamic_cursor for rcd_field.sfi_fld_rul_sel_sql;
         loop
            fetch var_dynamic_cursor into var_val_code, var_val_text;
            if var_dynamic_cursor%notfound then
               exit;
            end if;
            var_output := '<VALUE VALCDE="'||var_val_code||'" VALTXT="'||pts_to_xml(var_val_text)||'"/>';
            pipe row(pts_xml_object(var_output));
         end loop;
         close var_dynamic_cursor;
      end if;

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
         raise_application_error(-20000, 'PTS_GEN_FUNCTION - LIST_RUL_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_rul_data;

   /*****************************************************/
   /* This procedure performs the list pet type routine */
   /*****************************************************/
   function list_pet_type return pts_cla_list_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_pet_type is
         select t01.pty_pet_type,
                t01.pty_typ_text
           from pts_pet_type t01
          where t01.pty_typ_status = '1'
          order by t01.pty_pet_type asc;
      rcd_pet_type csr_pet_type%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the pet type values
      /*-*/
      open csr_pet_type;
      loop
         fetch csr_pet_type into rcd_pet_type;
         if csr_pet_type%notfound then
            exit;
         end if;
         pipe row(pts_cla_list_object(rcd_pet_type.pty_pet_type,'('||rcd_pet_type.pty_pet_type||') '||rcd_pet_type.pty_typ_text));
      end loop;
      close csr_pet_type;

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
         raise_application_error(-20000, 'PTS_GEN_FUNCTION - LIST_PET_TYPE - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_pet_type;

   /***********************************************************/
   /* This procedure performs the list classification routine */
   /***********************************************************/
   function list_class(par_tab_code in varchar2, par_fld_code in number) return pts_cla_list_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_system_all is
         select t01.sva_val_code,
                t01.sva_val_text
           from pts_sys_value t01
          where t01.sva_tab_code = upper(par_tab_code)
            and t01.sva_fld_code = par_fld_code
          order by t01.sva_val_code asc;
      rcd_system_all csr_system_all%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the pet system values
      /*-*/
      open csr_system_all;
      loop
         fetch csr_system_all into rcd_system_all;
         if csr_system_all%notfound then
            exit;
         end if;
         pipe row(pts_cla_list_object(rcd_system_all.sva_val_code,'('||rcd_system_all.sva_val_code||') '||rcd_system_all.sva_val_text));
      end loop;
      close csr_system_all;

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
         raise_application_error(-20000, 'PTS_GEN_FUNCTION - LIST_CLASS - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_class;

   /***********************************************************/
   /* This procedure performs the list classification routine */
   /***********************************************************/
   function list_class(par_pet_type in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_list_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_system_field is
         select t01.*
           from pts_pty_sys_field t01
          where t01.psf_pet_type = par_pet_type
            and t01.psf_tab_code = upper(par_tab_code)
            and t01.psf_fld_code = par_fld_code;
      rcd_system_field csr_system_field%rowtype;

      cursor csr_system_all is
         select t01.sva_val_code,
                t01.sva_val_text
           from pts_sys_value t01
          where t01.sva_tab_code = upper(par_tab_code)
            and t01.sva_fld_code = par_fld_code
          order by t01.sva_val_code asc;
      rcd_system_all csr_system_all%rowtype;

      cursor csr_system_select is
         select t01.sva_val_code,
                t01.sva_val_text
           from pts_sys_value t01
          where t01.sva_tab_code = upper(par_tab_code)
            and t01.sva_fld_code = par_fld_code
            and t01.sva_val_code in (select psv_val_code
                                       from pts_pty_sys_value
                                      where psv_pet_type = par_pet_type
                                        and psv_tab_code = upper(par_tab_code)
                                        and psv_fld_code = par_fld_code)
          order by t01.sva_val_code asc;
      rcd_system_select csr_system_select%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the pet type system field
      /*-*/
      open csr_system_field;
      fetch csr_system_field into rcd_system_field;
      if csr_system_field%notfound then
         return;
      end if;
      close csr_system_field;

      /*-*/
      /* Retrieve the pet type system values
      /*-*/
      if upper(rcd_system_field.psf_val_type) = '*ALL' then
         open csr_system_all;
         loop
            fetch csr_system_all into rcd_system_all;
            if csr_system_all%notfound then
               exit;
            end if;
            pipe row(pts_cla_list_object(rcd_system_all.sva_val_code,'('||rcd_system_all.sva_val_code||') '||rcd_system_all.sva_val_text));
         end loop;
         close csr_system_all;
      elsif upper(rcd_system_field.psf_val_type) = '*SELECT' then
         open csr_system_select;
         loop
            fetch csr_system_select into rcd_system_select;
            if csr_system_select%notfound then
               exit;
            end if;
            pipe row(pts_cla_list_object(rcd_system_select.sva_val_code,'('||rcd_system_select.sva_val_code||') '||rcd_system_select.sva_val_text));
         end loop;
         close csr_system_select;
      else
         return;
      end if;

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
         raise_application_error(-20000, 'PTS_GEN_FUNCTION - LIST_CLASS - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_class;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package variables
   /*-*/
   pvar_end_code := 0;

end pts_gen_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_gen_function for pts_app.pts_gen_function;
grant execute on pts_app.pts_gen_function to public;

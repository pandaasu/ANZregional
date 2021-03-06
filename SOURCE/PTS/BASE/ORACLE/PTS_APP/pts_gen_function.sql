/******************/
/* Package Header */
/******************/
create or replace
package         pts_gen_function as

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
    2010/10   Steve Gregan   Modified to allow more allocation days than samples
    2014/09   Peter Tylee    Added support for logical OR groups
   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure clear_mesg_data;
   function get_mesg_count return number;
   procedure add_mesg_data(par_message in varchar2);
   function get_mesg_data return pts_xml_type pipelined;
   procedure set_cfrm_data(par_confirm in varchar2);
   procedure set_list_data;
   function get_list_from return pts_sel_list_type pipelined;
   function get_list_data(par_ent_code in varchar2, par_sel_group in varchar2) return pts_sel_list_type pipelined;
   procedure set_field_data;
   function list_fld_data return pts_xml_type pipelined;
   function list_rul_data return pts_xml_type pipelined;
   function list_sel_data return pts_xml_type pipelined;
   function list_geo_zone(par_geo_type in number) return pts_geo_list_type pipelined;
   function list_pet_type return pts_pty_list_type pipelined;
   function list_tes_type return pts_tty_list_type pipelined;
   function list_class(par_tab_code in varchar2, par_fld_code in number) return pts_cla_list_type pipelined;
   function randomize_allocation(par_sam_count in number, par_pan_count in number, par_use_count in number) return pts_ran_type pipelined;
   function calculate_factorial(par_value in integer) return integer;

end pts_gen_function;
/

/****************/
/* Package Body */
/****************/
create or replace
package body         pts_gen_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   pvar_end_code number;
   pvar_cfrm varchar2(2000 char);
   type ptyp_mesg is table of varchar2(2000 char) index by binary_integer;
   ptbl_mesg ptyp_mesg;

   /**********************************************************/
   /* This procedure performs the clear message data routine */
   /**********************************************************/
   procedure clear_mesg_data is

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
      ptbl_mesg.delete;
      pvar_cfrm := null;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_GEN_FUNCTION - CLEAR_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear_mesg_data;

   /*********************************************************/
   /* This procedure performs the get message count routine */
   /*********************************************************/
   function get_mesg_count return number is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Return the message data count
      /*-*/
      return ptbl_mesg.count;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_GEN_FUNCTION - GET_MESG_COUNT - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_mesg_count;

   /********************************************************/
   /* This procedure performs the add message data routine */
   /********************************************************/
   procedure add_mesg_data(par_message in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Add the message data
      /*-*/
      ptbl_mesg(ptbl_mesg.count+1) := par_message;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_GEN_FUNCTION - ADD_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_mesg_data;

   /********************************************************/
   /* This procedure performs the get message data routine */
   /********************************************************/
   function get_mesg_data return pts_xml_type pipelined is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Pipe the message data when required
      /*-*/
      if ptbl_mesg.count != 0 or not(pvar_cfrm is null) then
         pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));
      end if;
      for idx in 1..ptbl_mesg.count loop
         pipe row(pts_xml_object('<ERROR ERRTXT="'||pts_to_xml(ptbl_mesg(idx))||'"/>'));
      end loop;
      if not(pvar_cfrm is null) then
         pipe row(pts_xml_object('<CONFIRM CONTXT="'||pts_to_xml(pvar_cfrm)||'"/>'));
      end if;
      if ptbl_mesg.count != 0 or not(pvar_cfrm is null) then
         pipe row(pts_xml_object('</PTS_RESPONSE>'));
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
         raise_application_error(-20000, 'FATAL ERROR - PTS_GEN_FUNCTION - GET_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_mesg_data;

   /********************************************************/
   /* This procedure performs the set confirm data routine */
   /********************************************************/
   procedure set_cfrm_data(par_confirm in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Set the confirm data
      /*-*/
      pvar_cfrm := par_confirm;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_GEN_FUNCTION - SET_CFRM_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_cfrm_data;

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

      /*-*/
      /* Retrieve and process the stream header
      /*-*/
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      pvar_end_code := nvl(pts_to_number(xslProcessor.valueOf(obj_pts_request,'@ENDCDE')),0);
      if var_action != '*SELDTA' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
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
            rcd_pts_wor_sel_rule.wsr_or_link_code := upper(xslProcessor.valueOf(obj_rul_node,'@LNKCDE'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEN_FUNCTION - SET_LIST_DATA - ' || substr(SQLERRM, 1, 1536));

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
      var_or_group varchar2(32);
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
                t01.wsr_or_link_code,
                t02.sfi_fld_rul_type,
                t02.sfi_fld_rul_sql,
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
          order by t01.wsr_or_link_code asc,
                   t01.wsr_tab_code asc,
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
         var_or_group := '*NONE';

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
            /* End the previous OR group, if required
            /*-*/
            if var_rule_found = true and nvl(rcd_rule.wsr_or_link_code,'*NONE') <> var_or_group then
              var_query := var_query||')';
            end if;

            /*-*/
            /* Start an OR group, if required
            /*-*/
            if nvl(rcd_rule.wsr_or_link_code,'*NONE') <> '*NONE' and nvl(rcd_rule.wsr_or_link_code,'*NONE') <> var_or_group then
              var_query := var_query||'(';
            end if;

            /*-*/
            /* Start the rule
            /*-*/
            if var_rule_found = false then
               var_query := var_query||'(';
            elsif nvl(rcd_rule.wsr_or_link_code,'*NONE') = var_or_group and var_or_group <> '*NONE' then
              var_query := var_query||' or (';
            else
               var_query := var_query||' and (';
            end if;
            var_rule_found := true;
            var_or_group := nvl(rcd_rule.wsr_or_link_code,'*NONE');

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
               if upper(rcd_rule.sfi_fld_rul_type) = '*TEXT' then
                  if upper(trim(rcd_rule.sru_rul_test)) = 'LIKE' then
                     var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>','upper(''%'||rcd_value.wsv_val_text||'%'')');
                  else
                     var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>',''''||rcd_value.wsv_val_text||'''');
                  end if;
               elsif upper(rcd_rule.sfi_fld_rul_type) = '*NUMBER' then
                  var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>',rcd_value.wsv_val_text);
               else
                  var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>',rcd_value.wsv_val_code);
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
         /* Add an extra closing bracket to close the last OR group, if required
         /*-*/
         if var_or_group <> '*NONE' then
            var_query := var_query||')';
         end if;

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

   /******************************************************/
   /* This procedure performs the set field data routine */
   /******************************************************/
   procedure set_field_data is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      obj_fld_list xmlDom.domNodeList;
      obj_fld_node xmlDom.domNode;
      rcd_pts_wor_tab_field pts_wor_tab_field%rowtype;
      var_action varchar2(32);

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
      delete from pts_wor_tab_field;

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
      if var_action != '*SETFLD' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve and load the table fields
      /*-*/
      obj_fld_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/FIELD');
      for idx in 0..xmlDom.getLength(obj_fld_list)-1 loop
         obj_fld_node := xmlDom.item(obj_fld_list,idx);
         rcd_pts_wor_tab_field.wtf_tab_code := upper(pts_from_xml(xslProcessor.valueOf(obj_fld_node,'@TABCDE')));
         rcd_pts_wor_tab_field.wtf_fld_code := pts_to_number(xslProcessor.valueOf(obj_fld_node,'@FLDCDE'));
         insert into pts_wor_tab_field values rcd_pts_wor_tab_field;
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEN_FUNCTION - SET_FIELD_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_field_data;

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
      var_tab_flag boolean;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_table is
         select t02.sta_tab_code,
                t02.sta_tab_text
           from pts_sys_link t01,
                pts_sys_table t02
          where t01.sli_tab_code = t02.sta_tab_code
            and t01.sli_ent_code = var_ent_code
          order by t02.sta_tab_text asc;
      rcd_table csr_table%rowtype;

      cursor csr_field is
         select t01.sfi_fld_code,
                t01.sfi_fld_text,
                t01.sfi_fld_inp_leng,
                t01.sfi_fld_rul_type
           from pts_sys_field t01
          where t01.sfi_tab_code = rcd_table.sta_tab_code
            and (var_tes_flag = '0' or (var_tes_flag = '1' and t01.sfi_fld_tes_rule = '1'))
            and t01.sfi_fld_status = '1'
          order by t01.sfi_fld_dsp_seqn asc,
                   t01.sfi_fld_text asc;
      rcd_field csr_field%rowtype;

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
      var_ent_code := upper(xslProcessor.valueOf(obj_pts_request,'@ENTCDE'));
      var_tes_flag := upper(xslProcessor.valueOf(obj_pts_request,'@TESFLG'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*LSTFLD' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Pipe the system field XML
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));
      open csr_table;
      loop
         fetch csr_table into rcd_table;
         if csr_table%notfound then
            exit;
         end if;
         var_tab_flag := false;
         open csr_field;
         loop
            fetch csr_field into rcd_field;
            if csr_field%notfound then
               exit;
            end if;
            if var_tab_flag = false then
               var_tab_flag := true;
               pipe row(pts_xml_object('<TABLE TABCDE="'||rcd_table.sta_tab_code||'" TABTXT="'||pts_to_xml(rcd_table.sta_tab_text)||'"/>'));
            end if;
            var_output := '<FIELD FLDCDE="'||to_char(rcd_field.sfi_fld_code)||'"';
            var_output := var_output||' FLDTXT="'||pts_to_xml(rcd_field.sfi_fld_text)||'"';
            var_output := var_output||' INPLEN="'||to_char(rcd_field.sfi_fld_inp_leng)||'"';
            var_output := var_output||' RULTYP="'||rcd_field.sfi_fld_rul_type||'"/>';
            pipe row(pts_xml_object(var_output));
         end loop;
         close csr_field;
      end loop;
      close csr_table;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEN_FUNCTION - LIST_FLD_DATA - ' || substr(SQLERRM, 1, 1536));

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
      var_tes_flag varchar2(32);
      var_tab_code varchar2(32);
      var_fld_code number;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_field is
         select t01.sfi_fld_rul_type
           from pts_sys_field t01
          where t01.sfi_tab_code = var_tab_code
            and t01.sfi_fld_code = var_fld_code;
      rcd_field csr_field%rowtype;

      cursor csr_rule is
         select t02.sru_rul_code
           from pts_sys_select t01,
                pts_sys_rule t02
          where t01.sse_rul_code = t02.sru_rul_code
            and t01.sse_tab_code = var_tab_code
            and t01.sse_fld_code = var_fld_code
            and (t02.sru_rul_tflg = '0' or (var_tes_flag = '1' and t02.sru_rul_tflg = '1'))
          order by t02.sru_rul_code asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is
         select t01.sva_val_code,
                t01.sva_val_text
           from pts_sys_value t01
          where t01.sva_tab_code = var_tab_code
            and t01.sva_fld_code = var_fld_code
          order by t01.sva_val_code asc;
      rcd_value csr_value%rowtype;

      cursor csr_hou_zone is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = 40
          order by t01.gzo_geo_zone asc;
      rcd_hou_zone csr_hou_zone%rowtype;

      cursor csr_pet_type is
         select t01.*
           from pts_pet_type t01
          order by t01.pty_pet_type asc;
      rcd_pet_type csr_pet_type%rowtype;

      cursor csr_tes_type is
         select t01.*
           from pts_tes_type t01
          order by t01.tty_tes_type asc;
      rcd_tes_type csr_tes_type%rowtype;

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
      var_tes_flag := upper(xslProcessor.valueOf(obj_pts_request,'@TESFLG'));
      var_tab_code := upper(xslProcessor.valueOf(obj_pts_request,'@TABCDE'));
      var_fld_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@FLDCDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*LSTRUL' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the field definition
      /*-*/
      open csr_field;
      fetch csr_field into rcd_field;
      if csr_field%notfound then
         pts_gen_function.add_mesg_data('Field table('||var_tab_code||') field('||to_char(var_fld_code)||') does not exist');
         return;
      end if;
      close csr_field;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the system field rule XML
      /*-*/
      open csr_rule;
      loop
         fetch csr_rule into rcd_rule;
         if csr_rule%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<RULE RULCDE="'||rcd_rule.sru_rul_code||'"/>'));
      end loop;
      close csr_rule;

      /*-*/
      /* Pipe the system field rule value XML when required
      /*-*/
      if upper(rcd_field.sfi_fld_rul_type) = '*LIST' then
         open csr_value;
         loop
            fetch csr_value into rcd_value;
            if csr_value%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<VALUE VALCDE="'||to_char(rcd_value.sva_val_code)||'" VALTXT="'||pts_to_xml('('||to_char(rcd_value.sva_val_code)||') '||rcd_value.sva_val_text)||'"/>'));
         end loop;
         close csr_value;
      elsif upper(rcd_field.sfi_fld_rul_type) = '*HOU_ZONE' then
         open csr_hou_zone;
         loop
            fetch csr_hou_zone into rcd_hou_zone;
            if csr_hou_zone%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<VALUE VALCDE="'||to_char(rcd_hou_zone.gzo_geo_zone)||'" VALTXT="'||pts_to_xml('('||to_char(rcd_hou_zone.gzo_geo_zone)||') '||rcd_hou_zone.gzo_zon_text)||'"/>'));
         end loop;
         close csr_hou_zone;
      elsif upper(rcd_field.sfi_fld_rul_type) = '*PET_TYPE' then
         open csr_pet_type;
         loop
            fetch csr_pet_type into rcd_pet_type;
            if csr_pet_type%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<VALUE VALCDE="'||to_char(rcd_pet_type.pty_pet_type)||'" VALTXT="'||pts_to_xml('('||to_char(rcd_pet_type.pty_pet_type)||') '||rcd_pet_type.pty_typ_text)||'"/>'));
         end loop;
         close csr_pet_type;
      elsif upper(rcd_field.sfi_fld_rul_type) = '*TES_TYPE' then
         open csr_tes_type;
         loop
            fetch csr_tes_type into rcd_tes_type;
            if csr_tes_type%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<VALUE VALCDE="'||to_char(rcd_tes_type.tty_tes_type)||'" VALTXT="'||pts_to_xml('('||to_char(rcd_tes_type.tty_tes_type)||') '||rcd_tes_type.tty_typ_text)||'"/>'));
         end loop;
         close csr_tes_type;
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEN_FUNCTION - LIST_RUL_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_rul_data;

   /***********************************************************/
   /* This procedure performs the list selection data routine */
   /***********************************************************/
   function list_sel_data return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tab_code varchar2(32);
      var_fld_code number;
      var_pet_type number;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_field is
         select t01.sfi_fld_sel_type,
                nvl(t01.sfi_fld_val_type,'*ALL') as sfi_fld_val_type
           from pts_sys_field t01
          where t01.sfi_tab_code = var_tab_code
            and t01.sfi_fld_code = var_fld_code;
      rcd_field csr_field%rowtype;

      cursor csr_value_all is
         select t01.sva_val_code,
                t01.sva_val_text
           from pts_sys_value t01
          where t01.sva_tab_code = var_tab_code
            and t01.sva_fld_code = var_fld_code
          order by t01.sva_val_code asc;
      rcd_value_all csr_value_all%rowtype;

      cursor csr_value_select is
         select t01.sva_val_code,
                t01.sva_val_text
           from pts_sys_value t01
          where t01.sva_tab_code = var_tab_code
            and t01.sva_fld_code = var_fld_code
            and t01.sva_val_code in (select psv_val_code
                                       from pts_pty_sys_value
                                      where psv_pet_type = var_pet_type
                                        and psv_tab_code = var_tab_code
                                        and psv_fld_code = var_fld_code)
          order by t01.sva_val_code asc;
      rcd_value_select csr_value_select%rowtype;

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
      var_tab_code := upper(xslProcessor.valueOf(obj_pts_request,'@TABCDE'));
      var_fld_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@FLDCDE'));
      var_pet_type := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PETTYPE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*LSTSEL' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the field definition
      /*-*/
      open csr_field;
      fetch csr_field into rcd_field;
      if csr_field%notfound then
         pts_gen_function.add_mesg_data('Field table('||var_tab_code||') field('||to_char(var_fld_code)||') does not exist');
         return;
      end if;
      close csr_field;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the *NONE XML when required
      /*-*/
      if rcd_field.sfi_fld_sel_type = '*OPT_SINGLE_LIST' then
         pipe row(pts_xml_object('<VALUE VALCDE="" VALTXT="** NONE **"/>'));
      end if;

      /*-*/
      /* Pipe the system selection value XML when required
      /*-*/
      if upper(rcd_field.sfi_fld_val_type) = '*SELECT' then
         open csr_value_select;
         loop
            fetch csr_value_select into rcd_value_select;
            if csr_value_select%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<VALUE VALCDE="'||to_char(rcd_value_select.sva_val_code)||'" VALTXT="'||pts_to_xml('('||to_char(rcd_value_select.sva_val_code)||') '||rcd_value_select.sva_val_text)||'"/>'));
         end loop;
         close csr_value_select;
      else
         open csr_value_all;
         loop
            fetch csr_value_all into rcd_value_all;
            if csr_value_all%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<VALUE VALCDE="'||to_char(rcd_value_all.sva_val_code)||'" VALTXT="'||pts_to_xml('('||to_char(rcd_value_all.sva_val_code)||') '||rcd_value_all.sva_val_text)||'"/>'));
         end loop;
         close csr_value_all;
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEN_FUNCTION - LIST_SEL_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_sel_data;

   /************************************************************/
   /* This procedure performs the list geographic zone routine */
   /************************************************************/
   function list_geo_zone(par_geo_type in number) return pts_geo_list_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_geo_zone is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = par_geo_type
          order by t01.gzo_geo_zone asc;
      rcd_geo_zone csr_geo_zone%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the geographic zone values
      /*-*/
      open csr_geo_zone;
      loop
         fetch csr_geo_zone into rcd_geo_zone;
         if csr_geo_zone%notfound then
            exit;
         end if;
         pipe row(pts_geo_list_object(rcd_geo_zone.gzo_geo_zone,'('||to_char(rcd_geo_zone.gzo_geo_zone)||') '||rcd_geo_zone.gzo_zon_text,rcd_geo_zone.gzo_zon_status));
      end loop;
      close csr_geo_zone;

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
         raise_application_error(-20000, 'PTS_GEN_FUNCTION - LIST_GEO_ZONE - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_geo_zone;

   /*****************************************************/
   /* This procedure performs the list pet type routine */
   /*****************************************************/
   function list_pet_type return pts_pty_list_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_pet_type is
         select t01.*
           from pts_pet_type t01
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
         pipe row(pts_pty_list_object(rcd_pet_type.pty_pet_type,'('||to_char(rcd_pet_type.pty_pet_type)||') '||rcd_pet_type.pty_typ_text,rcd_pet_type.pty_typ_status));
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

   /******************************************************/
   /* This procedure performs the list test type routine */
   /******************************************************/
   function list_tes_type return pts_tty_list_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_tes_type is
         select t01.*
           from pts_tes_type t01
          order by t01.tty_tes_type asc;
      rcd_tes_type csr_tes_type%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the test type values
      /*-*/
      open csr_tes_type;
      loop
         fetch csr_tes_type into rcd_tes_type;
         if csr_tes_type%notfound then
            exit;
         end if;
         pipe row(pts_tty_list_object(rcd_tes_type.tty_tes_type,'('||to_char(rcd_tes_type.tty_tes_type)||') '||rcd_tes_type.tty_typ_text,rcd_tes_type.tty_typ_status,rcd_tes_type.tty_typ_target,rcd_tes_type.tty_sam_count,rcd_tes_type.tty_alc_proc));
      end loop;
      close csr_tes_type;

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
         raise_application_error(-20000, 'PTS_GEN_FUNCTION - LIST_TES_TYPE - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_tes_type;

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

   /************************************************************/
   /* This procedure performs the randomize allocation routine */
   /************************************************************/
   function randomize_allocation(par_sam_count in number, par_pan_count in number, par_use_count in number) return pts_ran_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_key_code varchar2(36);
      var_found boolean;
      var_count integer;
      var_index integer;
      var_key_table pts_ran_type := pts_ran_type();
      type typ_ckey is table of varchar2(1) index by binary_integer;
      tbl_ckey typ_ckey;
      type typ_skey is table of varchar2(72) index by binary_integer;
      tbl_skey typ_skey;
      type typ_wkey is table of varchar2(72) index by binary_integer;
      tbl_wkey typ_wkey;

      /*-*/
      /* Local constants
      /*-*/
      con_split constant integer := 8;
      con_key_map constant varchar2(36) := '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_key_list is
         select combo
           from (select distinct(substr(combo,1,var_count)) as combo
                   from (select replace(sys_connect_by_path(slot,'/'),'/') combo
                           from (select level lvlnum,
                                        substr(var_key_code, level, 1) slot
                                   from dual
                                connect by level <= length(var_key_code))
                          where level = length(var_key_code)
                        connect by nocycle lvlnum != prior lvlnum)
                  order by dbms_random.value)
          where rownum <= par_pan_count;

      cursor csr_key_test is
         select column_value as key_code
           from table(cast(var_key_table as pts_ran_type))
          order by dbms_random.value;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the function parameters
      /*-*/
      if par_sam_count <= 0 then
         raise_application_error(-20000, 'Minimum sample count must be 1');
      end if;
      if par_sam_count > 36 then
         raise_application_error(-20000, 'Maximum sample count must be 36');
      end if;
      if par_pan_count <= 0 then
         raise_application_error(-20000, 'Minimum panel count must be 1');
      end if;
      if par_pan_count > 9999 then
         raise_application_error(-20000, 'Maximum panel count must be 9999');
      end if;
      if par_use_count < par_sam_count then
         raise_application_error(-20000, 'Minimum usage count must greater than or equal to the sample count');
      end if;
      if par_use_count > (par_sam_count * 2) then
         raise_application_error(-20000, 'Maximum usage count must be twice the sample count');
      end if;

      /*-*/
      /* Load the sample key array
      /*-*/
      tbl_skey.delete;
      if par_sam_count <= con_split then
         var_key_code := null;
         for idx in 1..par_sam_count loop
            var_key_code := var_key_code||substr(con_key_map,idx,1);
         end loop;
         var_count := par_sam_count;
         tbl_wkey.delete;
         open csr_key_list;
         fetch csr_key_list bulk collect into tbl_wkey;
         close csr_key_list;
         for idx in 1..tbl_wkey.count loop
            tbl_skey(idx) := tbl_wkey(idx);
         end loop;
         if (par_use_count - par_sam_count) > 0 then
            var_count := par_use_count - par_sam_count;
            tbl_wkey.delete;
            open csr_key_list;
            fetch csr_key_list bulk collect into tbl_wkey;
            close csr_key_list;
            var_index := 1;
            for idx in 1..tbl_skey.count loop
               tbl_skey(idx) := tbl_skey(idx) || tbl_wkey(var_index);
               var_index := var_index + 1;
               if var_index > tbl_wkey.count then
                  var_index := 1;
               end if;
            end loop;
         end if;
      else
         var_key_table.delete;
         for idx in 1..par_sam_count loop
            var_key_table.extend;
            var_key_table(var_key_table.last) := substr(con_key_map,idx,1);
         end loop;
         for idxpan in 1..par_pan_count loop
            loop
               open csr_key_test;
               fetch csr_key_test bulk collect into tbl_ckey;
               close csr_key_test;
               var_key_code := null;
               for idx in 1..par_sam_count loop
                  var_key_code := var_key_code||tbl_ckey(idx);
               end loop;
               var_found := false;
               for idx in 1..tbl_skey.count loop
                  if tbl_skey(idx) = var_key_code then
                     var_found := true;
                     exit;
                  end if;
               end loop;
               if var_found = false then
                  tbl_skey(idxpan) := var_key_code;
                  exit;
               end if;
            end loop;
         end loop;
         if (par_use_count - par_sam_count) > 0 then
            var_count := par_use_count - par_sam_count;
            tbl_wkey.delete;
            for idx in 1..par_sam_count loop
               if (idx + (var_count-1)) <= par_sam_count then
                  tbl_wkey(tbl_wkey.count+1) := substr(con_key_map,idx,var_count);
               else
                  tbl_wkey(tbl_wkey.count+1) := substr(con_key_map,idx,((par_sam_count+1)-idx));
                  tbl_wkey(tbl_wkey.count) := tbl_wkey(tbl_wkey.count) || substr(con_key_map,1,var_count-((par_sam_count+1)-idx));
               end if;
            end loop;
            var_index := 1;
            for idx in 1..tbl_skey.count loop
               var_key_table.delete;
               for idw in 1..length(tbl_wkey(var_index)) loop
                  var_key_table.extend;
                  var_key_table(var_key_table.last) := substr(tbl_wkey(var_index),idw,1);
               end loop;
               open csr_key_test;
               fetch csr_key_test bulk collect into tbl_ckey;
               close csr_key_test;
               var_key_code := null;
               for idw in 1..tbl_ckey.count loop
                  var_key_code := var_key_code||tbl_ckey(idw);
               end loop;
               tbl_skey(idx) := tbl_skey(idx) || var_key_code;
               var_index := var_index + 1;
               if var_index > tbl_wkey.count then
                  var_index := 1;
               end if;
            end loop;
         end if;
      end if;

      /*-*/
      /* Pipe the key permutations to the consumer
      /*-*/
      for idx in 1..tbl_skey.count loop
         pipe row(tbl_skey(idx));
      end loop;

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
         raise_application_error(-20000, 'PTS_GEN_FUNCTION - RANDOMIZE_ALLOCATION - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end randomize_allocation;

   /***********************************************************/
   /* This procedure performs the calculate factorial routine */
   /***********************************************************/
   function calculate_factorial(par_value in integer) return integer is

      /*-*/
      /* Local definitions
      /*-*/
      var_return integer;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Calculate the factorial
      /*-*/
      var_return := 1;
      for idx in 2..par_value loop
         var_return := var_return * idx;
      end loop;
      return var_return;

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
         raise_application_error(-20000, 'PTS_GEN_FUNCTION - CALCULATE_FACTORIAL - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end calculate_factorial;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package variables
   /*-*/
   ptbl_mesg.delete;
   pvar_end_code := 0;

end pts_gen_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_gen_function for pts_app.pts_gen_function;
grant execute on pts_app.pts_gen_function to public;

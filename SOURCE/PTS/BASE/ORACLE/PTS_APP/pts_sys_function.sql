/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_sys_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_sys_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - System Function

    This package contain the system functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function retrieve_sort return pts_xml_type pipelined;
   function retrieve_field return pts_xml_type pipelined;
   function retrieve_value return pts_xml_type pipelined;
   procedure update_sort;
   procedure update_field;
   procedure update_value;

end pts_sys_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_sys_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*****************************************************/
   /* This procedure performs the retrieve sort routine */
   /*****************************************************/
   function retrieve_sort return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tab_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*
           from pts_sys_field t01
          where t01.sfi_tab_code = var_tab_code
            and t01.sfi_fld_status = '1'
          order by t01.sfi_fld_dsp_seqn asc;
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
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      var_tab_code := xslProcessor.valueOf(obj_pts_request,'@TABCDE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*RTVSRT' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Retrieve the table field information
      /*-*/
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<FIELD FLDCDE="'||to_char(rcd_list.sfi_fld_code)||'" FLDTXT="'||pts_to_xml(rcd_list.sfi_fld_text)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_SYS_FUNCTION - RETRIEVE_SORT - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_sort;

   /******************************************************/
   /* This procedure performs the retrieve field routine */
   /******************************************************/
   function retrieve_field return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tab_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*
           from pts_sys_field t01
          where t01.sfi_tab_code = var_tab_code
          order by t01.sfi_fld_dsp_seqn asc;
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
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      var_tab_code := xslProcessor.valueOf(obj_pts_request,'@TABCDE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*RTVFLD' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Retrieve the table field information
      /*-*/
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<FIELD FLDCDE="'||to_char(rcd_list.sfi_fld_code)||'" FLDTXT="'||pts_to_xml(rcd_list.sfi_fld_text)||'" FLDTYP="'||pts_to_xml(rcd_list.sfi_fld_rul_type)||'" FLDUPD="'||pts_to_xml(rcd_list.sfi_fld_upd_user)||'" FLDSTS="'||pts_to_xml(rcd_list.sfi_fld_status)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_SYS_FUNCTION - RETRIEVE_FIELD - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_field;

   /******************************************************/
   /* This procedure performs the retrieve value routine */
   /******************************************************/
   function retrieve_value return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tab_code varchar2(32);
      var_fld_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*
           from pts_sys_value t01
          where t01.sva_tab_code = var_tab_code
            and t01.sva_fld_code = pts_to_number(var_fld_code)
          order by t01.sva_val_code asc;
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
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      var_tab_code := xslProcessor.valueOf(obj_pts_request,'@TABCDE');
      var_fld_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@FLDCDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*RTVVAL' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Retrieve the field value information
      /*-*/
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<VALUE VALCDE="'||to_char(rcd_list.sva_val_code)||'" VALTXT="'||pts_to_xml(rcd_list.sva_val_text)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_SYS_FUNCTION - RETRIEVE_VALUE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_value;

   /***************************************************/
   /* This procedure performs the update sort routine */
   /***************************************************/
   procedure update_sort is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      obj_fld_list xmlDom.domNodeList;
      obj_fld_node xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      rcd_pts_sys_field pts_sys_field%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_sys_table t01
          where t01.sta_tab_code = rcd_pts_sys_field.sfi_tab_code
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
      if var_action != '*UPDSRT' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_sys_field.sfi_tab_code := xslProcessor.valueOf(obj_pts_request,'@TABCDE');
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_sys_field.sfi_tab_code is null then
         pts_gen_function.add_mesg_data('Table code must be supplied');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the system table
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
            pts_gen_function.add_mesg_data('System table ('||rcd_pts_sys_field.sfi_tab_code||') is currently locked');
            return;
      end;
      if var_found = false then
         pts_gen_function.add_mesg_data('System table ('||rcd_pts_sys_field.sfi_tab_code||') does not exist');
      end if;

      /*-*/
      /* Retrieve and update the sorted field data
      /*-*/
      obj_fld_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/FIELD');
      for idx in 0..xmlDom.getLength(obj_fld_list)-1 loop
         obj_fld_node := xmlDom.item(obj_fld_list,idx);
         rcd_pts_sys_field.sfi_fld_code := pts_to_number(xslProcessor.valueOf(obj_fld_node,'@FLDCDE'));
         update pts_sys_field
            set sfi_fld_dsp_seqn = idx + 1
          where sfi_tab_code = rcd_pts_sys_field.sfi_tab_code
            and sfi_fld_code = rcd_pts_sys_field.sfi_fld_code;
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_SYS_FUNCTION - UPDATE_SORT - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_sort;

   /****************************************************/
   /* This procedure performs the update field routine */
   /****************************************************/
   procedure update_field is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      rcd_pts_sys_field pts_sys_field%rowtype;

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
      if var_action != '*UPDFLD' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_sys_field.sfi_tab_code := xslProcessor.valueOf(obj_pts_request,'@TABCDE');
      rcd_pts_sys_field.sfi_fld_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@FLDCDE'));
      rcd_pts_sys_field.sfi_fld_text := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@FLDTXT'));
      rcd_pts_sys_field.sfi_fld_status := xslProcessor.valueOf(obj_pts_request,'@FLDSTS');

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_sys_field.sfi_tab_code is null then
         pts_gen_function.add_mesg_data('Table code must be supplied');
      end if;
      if rcd_pts_sys_field.sfi_fld_code is null then
         pts_gen_function.add_mesg_data('Field code must be supplied');
      end if;
      if rcd_pts_sys_field.sfi_fld_text is null then
         pts_gen_function.add_mesg_data('Field text must be supplied');
      end if;
      if rcd_pts_sys_field.sfi_fld_status is null then
         pts_gen_function.add_mesg_data('Field status must be supplied');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Update the system field
      /*-*/
      update pts_sys_field
         set sfi_fld_text = rcd_pts_sys_field.sfi_fld_text,
             sfi_fld_status = rcd_pts_sys_field.sfi_fld_status
       where sfi_tab_code = rcd_pts_sys_field.sfi_tab_code
         and sfi_fld_code = rcd_pts_sys_field.sfi_fld_code;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_SYS_FUNCTION - UPDATE_FIELD - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_field;

   /****************************************************/
   /* This procedure performs the update value routine */
   /****************************************************/
   procedure update_value is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      rcd_pts_sys_value pts_sys_value%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_sys_field t01
          where t01.sfi_tab_code = rcd_pts_sys_value.sva_tab_code
            and t01.sfi_fld_code = rcd_pts_sys_value.sva_fld_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_check is
         select max(t01.sva_val_code) as max_code
           from pts_sys_value t01
          where t01.sva_tab_code = rcd_pts_sys_value.sva_tab_code
            and t01.sva_fld_code = rcd_pts_sys_value.sva_fld_code;
      rcd_check csr_check%rowtype;

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
      if var_action != '*UPDVAL' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_sys_value.sva_tab_code := xslProcessor.valueOf(obj_pts_request,'@TABCDE');
      rcd_pts_sys_value.sva_fld_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@FLDCDE'));
      rcd_pts_sys_value.sva_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      rcd_pts_sys_value.sva_val_text := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@VALTXT'));

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_sys_value.sva_tab_code is null then
         pts_gen_function.add_mesg_data('Table code must be supplied');
      end if;
      if rcd_pts_sys_value.sva_fld_code is null then
         pts_gen_function.add_mesg_data('Field code must be supplied');
      end if;
      if rcd_pts_sys_value.sva_val_text is null then
         pts_gen_function.add_mesg_data('Value text must be supplied');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the system field
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
            pts_gen_function.add_mesg_data('System field ('||rcd_pts_sys_value.sva_tab_code||'/'||to_char(rcd_pts_sys_value.sva_fld_code)||') is currently locked');
            return;
      end;
      if var_found = false then
         pts_gen_function.add_mesg_data('System field ('||rcd_pts_sys_value.sva_tab_code||'/'||to_char(rcd_pts_sys_value.sva_fld_code)||') does not exist');
      end if;

      /*-*/
      /* Update/insert the system field value
      /*-*/
      if not(rcd_pts_sys_value.sva_val_code is null) then
         update pts_sys_value
            set sva_val_text = rcd_pts_sys_value.sva_val_text
          where sva_tab_code = rcd_pts_sys_value.sva_tab_code
            and sva_fld_code = rcd_pts_sys_value.sva_fld_code
            and sva_val_code = rcd_pts_sys_value.sva_val_code;
      else
         open csr_check;
         fetch csr_check into rcd_check;
         if csr_check%found then
            rcd_pts_sys_value.sva_val_code := rcd_check.max_code + 1;
         else
            rcd_pts_sys_value.sva_val_code := 1;
         end if;
         close csr_check;
         insert into pts_sys_value values rcd_pts_sys_value;
      end if;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_SYS_FUNCTION - UPDATE_VALUE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_value;

end pts_sys_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_sys_function for pts_app.pts_sys_function;
grant execute on pts_app.pts_sys_function to public;

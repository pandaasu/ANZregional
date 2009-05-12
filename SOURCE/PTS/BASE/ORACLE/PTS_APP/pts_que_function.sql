/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_que_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_que_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Question Function

    This package contain the question functions and procedures.

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

end pts_que_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_que_function as

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
         select t01.qde_que_code,
                t01.qde_que_text,
                nvl((select sva_val_text from pts_sys_value where sva_tab_code = '*QUE_DEF' and sva_fld_code = 9 and sva_val_code = t01.qde_que_status),'*UNKNOWN') as qde_que_status
           from pts_que_definition t01
          where t01.qde_que_code in (select sel_code from table(pts_app.pts_gen_function.get_list_data('*QUESTION',null)))
            and t01.qde_que_code > (select sel_code from table(pts_app.pts_gen_function.get_list_from))
          order by t01.qde_que_code asc;
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
      /* Retrieve the question list and pipe the results
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
            pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.qde_que_code)||'" SELTXT="'||pts_to_xml('('||to_char(rcd_list.qde_que_code)||') '||rcd_list.qde_que_text)||'" COL1="'||pts_to_xml('('||to_char(rcd_list.qde_que_code)||') '||rcd_list.qde_que_text)||'" COL2="'||pts_to_xml(rcd_list.qde_que_status)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_QUE_FUNCTION - RETRIEVE_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_que_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_que_definition t01
          where t01.qde_que_code = pts_to_number(var_que_code);
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*QUE_DEF',9)) t01;
      rcd_sta_code csr_sta_code%rowtype;

      cursor csr_typ_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*QUE_DEF',3)) t01;
      rcd_typ_code csr_typ_code%rowtype;

      cursor csr_rsp_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*QUE_DEF',4)) t01;
      rcd_rsp_code csr_rsp_code%rowtype;

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
      var_que_code := xslProcessor.valueOf(obj_pts_request,'@QUECODE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDQUE' and var_action != '*CRTQUE' and var_action != '*CPYQUE' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing question when required
      /*-*/
      if var_action = '*UPDQUE' or var_action = '*CPYQUE' then
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            pts_gen_function.add_mesg_data('Question ('||var_que_code||') does not exist');
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
         pipe row(pts_xml_object('<STA_LIST VALCDE="'||to_char(rcd_sta_code.val_code)||'" VALTXT="'||pts_to_xml(rcd_sta_code.val_text)||'"/>'));
      end loop;
      close csr_sta_code;

      /*-*/
      /* Pipe the question type XML
      /*-*/
      open csr_typ_code;
      loop
         fetch csr_typ_code into rcd_typ_code;
         if csr_typ_code%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<TYP_LIST VALCDE="'||rcd_typ_code.val_code||'" VALTXT="'||pts_to_xml(rcd_typ_code.val_text)||'"/>'));
      end loop;
      close csr_typ_code;

      /*-*/
      /* Pipe the response type XML
      /*-*/
      open csr_rsp_code;
      loop
         fetch csr_rsp_code into rcd_rsp_code;
         if csr_rsp_code%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<rsp_LIST VALCDE="'||rcd_rsp_code.val_code||'" VALTXT="'||pts_to_xml(rcd_rsp_code.val_text)||'"/>'));
      end loop;
      close csr_rsp_code;

      /*-*/
      /* Pipe the sample XML
      /*-*/
      if var_action = '*UPDQUE' then
         var_output := '<SAMPLE QUECODE="'||to_char(rcd_retrieve.qde_que_code)||'"';
         var_output := var_output||' QUETEXT="'||pts_to_xml(rcd_retrieve.qde_que_text)||'"';
         var_output := var_output||' QUESTAT="'||rcd_retrieve.qde_que_status||'"';
         var_output := var_output||' QUETYPE="'||to_char(rcd_retrieve.qde_que_type)||'"';
         var_output := var_output||' RESTYPE="'||to_char(rcd_retrieve.qde_rsp_type)||'"';
         var_output := var_output||' RESSRAN="'||to_char(rcd_retrieve.qde_rsp_str_range)||'"';
         var_output := var_output||' RESERAN="'||to_char(rcd_retrieve.qde_rsp_end_range)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYQUE' then
         var_output := '<SAMPLE SAMCODE="*NEW"';
         var_output := var_output||' QUETEXT="'||pts_to_xml(rcd_retrieve.qde_que_text)||'"';
         var_output := var_output||' QUESTAT="'||rcd_retrieve.qde_que_status||'"';
         var_output := var_output||' QUETYPE="'||to_char(rcd_retrieve.qde_que_type)||'"';
         var_output := var_output||' RESTYPE="'||to_char(rcd_retrieve.qde_rsp_type)||'"';
         var_output := var_output||' RESSRAN="'||to_char(rcd_retrieve.qde_rsp_str_range)||'"';
         var_output := var_output||' RESERAN="'||to_char(rcd_retrieve.qde_rsp_end_range)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CRTQUE' then
         var_output := '<SAMPLE SAMCODE="*NEW"';
         var_output := var_output||' QUETEXT=""';
         var_output := var_output||' QUESTAT="1"';
         var_output := var_output||' QUETYPE="1"';
         var_output := var_output||' RESTYPE="1"';
         var_output := var_output||' RESSRAN=""';
         var_output := var_output||' RESERAN=""/>';
         pipe row(pts_xml_object(var_output));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_QUE_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      var_action varchar2(32);
      rcd_pts_que_definition pts_que_definition%rowtype;
      type typ_dynamic_cursor is ref cursor;
      var_dynamic_cursor typ_dynamic_cursor;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check is
         select t01.*
           from pts_que_definition t01
          where t01.qde_que_code = rcd_pts_que_definition.qde_que_code;
      rcd_check csr_check%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*QUE_DEF',9)) t01
          where t01.val_code = rcd_pts_que_definition.qde_que_status;
      rcd_sta_code csr_sta_code%rowtype;

      cursor csr_typ_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*QUE_DEF',3)) t01
          where t01.val_code = rcd_pts_que_definition.qde_que_type;
      rcd_typ_code csr_typ_code%rowtype;

      cursor csr_rsp_type is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*QUE_DEF',4)) t01
          where t01.val_code = rcd_pts_que_definition.qde_rsp_type;
      rcd_rsp_type csr_rsp_type%rowtype;

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
      if var_action != '*DEFSAM' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_que_definition.qde_que_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@QUECODE'));
      rcd_pts_que_definition.qde_que_text := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@QUETEXT'));
      rcd_pts_que_definition.qde_que_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@QUESTAT'));
      rcd_pts_que_definition.qde_upd_user := upper(par_user);
      rcd_pts_que_definition.qde_upd_date := sysdate;
      rcd_pts_que_definition.qde_que_type := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@QUETYPE'));
      rcd_pts_que_definition.qde_rsp_type := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@RESTYPE'));
      rcd_pts_que_definition.qde_rsp_str_range := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@RESSRAN'));
      rcd_pts_que_definition.qde_rsp_end_range := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@RESERAN'));
      if rcd_pts_que_definition.qde_que_code is null and not(xslProcessor.valueOf(obj_pts_request,'@QUECODE') = '*NEW') then
         pts_gen_function.add_mesg_data('Question code ('||xslProcessor.valueOf(obj_pts_request,'@QUECODE')||') must be a number');
      end if;
      if rcd_pts_que_definition.qde_que_status is null and not(xslProcessor.valueOf(obj_pts_request,'@QUESTAT') is null) then
         pts_gen_function.add_mesg_data('Question status ('||xslProcessor.valueOf(obj_pts_request,'@QUESTAT')||') must be a number');
      end if;
      if rcd_pts_que_definition.qde_que_type is null and not(xslProcessor.valueOf(obj_pts_request,'@QUETYPE') is null) then
         pts_gen_function.add_mesg_data('Question type ('||xslProcessor.valueOf(obj_pts_request,'@QUETYPE')||') must be a number');
      end if;
      if rcd_pts_que_definition.qde_rsp_type is null and not(xslProcessor.valueOf(obj_pts_request,'@RESTYPE') is null) then
         pts_gen_function.add_mesg_data('Response type ('||xslProcessor.valueOf(obj_pts_request,'@RESTYPE')||') must be a number');
      end if;
      xmlDom.freeDocument(obj_xml_document);
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_que_definition.qde_que_text is null then
         pts_gen_function.add_mesg_data('Question text must be supplied');
      end if;
      if rcd_pts_que_definition.qde_que_status is null then
         pts_gen_function.add_mesg_data('Question status must be supplied');
      end if;
      if rcd_pts_que_definition.qde_que_type is null then
         pts_gen_function.add_mesg_data('Question type must be supplied');
      end if;
      if rcd_pts_que_definition.qde_rsp_type is null then
         pts_gen_function.add_mesg_data('Response type must be supplied');
      end if;
      if rcd_pts_que_definition.qde_upd_user is null then
         pts_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      open csr_sta_code;
      fetch csr_sta_code into rcd_sta_code;
      if csr_sta_code%notfound then
         pts_gen_function.add_mesg_data('Question status ('||to_char(rcd_pts_que_definition.qde_que_status)||') does not exist');
      end if;
      close csr_sta_code;
      open csr_typ_code;
      fetch csr_typ_code into rcd_typ_code;
      if csr_typ_code%notfound then
         pts_gen_function.add_mesg_data('Question type ('||to_char(rcd_pts_que_definition.qde_que_type)||') does not exist');
      end if;
      close csr_typ_code;
      open csr_rsp_type;
      fetch csr_rsp_type into rcd_rsp_type;
      if csr_rsp_type%notfound then
         pts_gen_function.add_mesg_data('Response type ('||to_char(rcd_pts_que_definition.qde_rsp_type)||') does not exist');
      end if;
      close csr_rsp_type;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
     
      /*-*/
      /* Retrieve and process the question definition
      /*-*/
      open csr_check;
      fetch csr_check into rcd_check;
      if csr_check%found then
         update pts_que_definition
            set qde_que_text = rcd_pts_que_definition.qde_que_text,
                qde_que_status = rcd_pts_que_definition.qde_que_status,
                qde_upd_user = rcd_pts_que_definition.qde_upd_user,
                qde_upd_date = rcd_pts_que_definition.qde_upd_date,
                qde_que_type = rcd_pts_que_definition.qde_que_type,
                qde_rsp_type = rcd_pts_que_definition.qde_rsp_type,
                qde_rsp_str_range = rcd_pts_que_definition.qde_rsp_str_range,
                qde_rsp_end_range = rcd_pts_que_definition.qde_rsp_end_range
          where qde_que_code = rcd_pts_que_definition.qde_que_code;
      else
         select pts_que_sequence.nextval into rcd_pts_que_definition.qde_que_code from dual;
         insert into pts_que_definition values rcd_pts_que_definition;
      end if;
      close csr_check;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_SAM_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

end pts_que_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_que_function for pts_app.pts_que_function;
grant execute on pts_app.pts_que_function to public;

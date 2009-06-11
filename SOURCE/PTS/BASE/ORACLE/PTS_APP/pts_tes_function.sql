/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_tes_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_tes_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Test Function

    This package contain the procedures and functions for product test.

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
   function response_load return pts_xml_type pipelined;
   function response_list return pts_xml_type pipelined;
   function response_retrieve return pts_xml_type pipelined;
   procedure update_response;
   procedure update_panel;
   function report_panel(par_tes_code in number) return pts_xls_type pipelined;

end pts_tes_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_tes_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure clear_panel(par_tes_code in number, par_req_mem_count in number, par_req_res_count in number);
   procedure select_pet_panel(par_tes_code in number, par_pan_type in varchar2, par_pet_multiple in varchar2);
   procedure select_hou_panel(par_tes_code in number, par_pan_type in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   type rcd_sel_group is record(sel_group varchar2(32 char),
                                tru_rule number,
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
                               tru_value number,
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

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.tde_tes_code,
                t01.tde_tes_title,
                nvl((select sva_val_text from pts_sys_value where sva_tab_code = '*TES_DEF' and sva_fld_code = 9 and sva_val_code = t01.tde_tes_status),'*UNKNOWN') as tde_tes_status
           from pts_tes_definition t01
          where t01.tde_tes_code in (select sel_code from table(pts_app.pts_gen_function.get_list_data('*TEST',null)))
            and t01.tde_tes_code > (select sel_code from table(pts_app.pts_gen_function.get_list_from))
          order by t01.tde_tes_code asc;
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
      pipe row(pts_xml_object('<LSTCTL COLCNT="2" HED1="'||pts_to_xml('Test')||'" HED2="'||pts_to_xml('Test Status')||'"/>'));

      /*-*/
      /* Retrieve the pet list and pipe the results
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
            pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.tde_tes_code)||'" SELTXT="'||pts_to_xml('('||to_char(rcd_list.tde_tes_code)||') '||rcd_list.tde_tes_title)||'" COL1="'||pts_to_xml('('||to_char(rcd_list.tde_tes_code)||') '||rcd_list.tde_tes_title)||'" COL2="'||pts_to_xml(rcd_list.tde_tes_status)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RETRIEVE_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_tes_code varchar2(32);
      var_tab_flag boolean;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = pts_to_number(var_tes_code);
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*TES_DEF',9)) t01;
      rcd_sta_code csr_sta_code%rowtype;

      cursor csr_glo_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*TES_DEF',5)) t01;
      rcd_glo_code csr_glo_code%rowtype;

      cursor csr_tes_type is
         select t01.*
           from table(pts_app.pts_gen_function.list_tes_type) t01
          where t01.tty_status = 1;
      rcd_tes_type csr_tes_type%rowtype;

      cursor csr_tar_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*TES_DEF',3)) t01;
      rcd_tar_code csr_tar_code%rowtype;

      cursor csr_keyword is
         select t01.*
           from pts_tes_keyword t01
          where t01.tke_tes_code = pts_to_number(var_tes_code)
          order by t01.tke_key_word;
      rcd_keyword csr_keyword%rowtype;

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
      var_tes_code := xslProcessor.valueOf(obj_pts_request,'@TESCODE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDTES' and var_action != '*CRTTES' and var_action != '*CPYTES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing test when required
      /*-*/
      if var_action = '*UPDTES' or var_action = '*CPYTES' then
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            pts_gen_function.add_mesg_data('Test ('||var_tes_code||') does not exist');
            return;
         end if;
         close csr_retrieve;
      end if;

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
      /* Pipe the GloPal status type XML
      /*-*/
      open csr_glo_code;
      loop
         fetch csr_glo_code into rcd_glo_code;
         if csr_glo_code%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<GLO_LIST VALCDE="'||rcd_glo_code.val_code||'" VALTXT="'||pts_to_xml(rcd_glo_code.val_text)||'"/>'));
      end loop;
      close csr_glo_code;

      /*-*/
      /* Pipe the test type XML
      /*-*/
      open csr_tes_type;
      loop
         fetch csr_tes_type into rcd_tes_type;
         if csr_tes_type%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<TYP_LIST VALCDE="'||rcd_tes_type.tty_code||'" VALTXT="'||pts_to_xml(rcd_tes_type.tty_text)||'"/>'));
      end loop;
      close csr_tes_type;

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
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test XML
      /*-*/
      if var_action = '*UPDTES' then
         pipe row(pts_xml_object('<TEST TESCDE="'||to_char(rcd_retrieve.tde_tes_code)||'"'));
         pipe row(pts_xml_object(' TESTIT="'||pts_to_xml(rcd_retrieve.tde_tes_title)||'"'));
         pipe row(pts_xml_object(' TESSTA="'||to_char(rcd_retrieve.tde_tes_status)||'"'));
         pipe row(pts_xml_object(' GLOSTA="'||to_char(rcd_retrieve.tde_glo_status)||'"'));
         pipe row(pts_xml_object(' TESTYP="'||to_char(rcd_retrieve.tde_tes_type)||'"'));
         pipe row(pts_xml_object(' TESTRG="'||to_char(rcd_retrieve.tde_tes_target)||'"'));
         pipe row(pts_xml_object(' TESREQ="'||pts_to_xml(rcd_retrieve.tde_tes_requestor)||'"'));
         pipe row(pts_xml_object(' TESAIM="'||pts_to_xml(rcd_retrieve.tde_tes_aim)||'"'));
         pipe row(pts_xml_object(' TESREA="'||pts_to_xml(rcd_retrieve.tde_tes_reason)||'"'));
         pipe row(pts_xml_object(' TESPRE="'||pts_to_xml(rcd_retrieve.tde_tes_prediction)||'"'));
         pipe row(pts_xml_object(' TESCOM="'||pts_to_xml(rcd_retrieve.tde_tes_comment)||'"'));
         pipe row(pts_xml_object(' TESSDT="'||to_char(rcd_retrieve.tde_tes_str_date,'dd/mm/yyyy')||'"'));
         pipe row(pts_xml_object(' TESPDT="'||to_char(rcd_retrieve.tde_tes_pan_date,'dd/mm/yyyy')||'"'));
         pipe row(pts_xml_object(' TESFWK="'||to_char(rcd_retrieve.tde_tes_fld_week)||'"'));
         pipe row(pts_xml_object(' TESMML="'||to_char(rcd_retrieve.tde_tes_min_meal)||'"'));
         pipe row(pts_xml_object(' TESMTM="'||to_char(rcd_retrieve.tde_tes_max_temp)||'"'));
         pipe row(pts_xml_object(' TESDAY="'||to_char(rcd_retrieve.tde_tes_day_count)||'"/>'));
      elsif var_action = '*CPYTES' then
         pipe row(pts_xml_object('<TEST TESCDE="*NEW"'));
         pipe row(pts_xml_object(' TESTIT="'||pts_to_xml(rcd_retrieve.tde_tes_title)||'"'));
         pipe row(pts_xml_object(' TESSTA="'||to_char(rcd_retrieve.tde_tes_status)||'"'));
         pipe row(pts_xml_object(' GLOSTA="'||to_char(rcd_retrieve.tde_glo_status)||'"'));
         pipe row(pts_xml_object(' TESTYP="'||to_char(rcd_retrieve.tde_tes_type)||'"'));
         pipe row(pts_xml_object(' TESTRG="'||to_char(rcd_retrieve.tde_tes_target)||'"'));
         pipe row(pts_xml_object(' TESREQ="'||pts_to_xml(rcd_retrieve.tde_tes_requestor)||'"'));
         pipe row(pts_xml_object(' TESAIM="'||pts_to_xml(rcd_retrieve.tde_tes_aim)||'"'));
         pipe row(pts_xml_object(' TESREA="'||pts_to_xml(rcd_retrieve.tde_tes_reason)||'"'));
         pipe row(pts_xml_object(' TESPRE="'||pts_to_xml(rcd_retrieve.tde_tes_prediction)||'"'));
         pipe row(pts_xml_object(' TESCOM="'||pts_to_xml(rcd_retrieve.tde_tes_comment)||'"'));
         pipe row(pts_xml_object(' TESSDT="'||to_char(rcd_retrieve.tde_tes_str_date,'dd/mm/yyyy')||'"'));
         pipe row(pts_xml_object(' TESPDT="'||to_char(rcd_retrieve.tde_tes_pan_date,'dd/mm/yyyy')||'"'));
         pipe row(pts_xml_object(' TESFWK="'||to_char(rcd_retrieve.tde_tes_fld_week)||'"'));
         pipe row(pts_xml_object(' TESMML="'||to_char(rcd_retrieve.tde_tes_min_meal)||'"'));
         pipe row(pts_xml_object(' TESMTM="'||to_char(rcd_retrieve.tde_tes_max_temp)||'"'));
         pipe row(pts_xml_object(' TESDAY="'||to_char(rcd_retrieve.tde_tes_day_count)||'"/>'));
      elsif var_action = '*CRTTES' then
         pipe row(pts_xml_object('<TEST TESCDE="*NEW"'));
         pipe row(pts_xml_object(' TESTIT=""'));
         pipe row(pts_xml_object(' TESSTA="1"'));
         pipe row(pts_xml_object(' GLOSTA="2"'));
         pipe row(pts_xml_object(' TESTYP="1"'));
         pipe row(pts_xml_object(' TESTRG="1"'));
         pipe row(pts_xml_object(' TESREQ=""'));
         pipe row(pts_xml_object(' TESAIM=""'));
         pipe row(pts_xml_object(' TESREA=""'));
         pipe row(pts_xml_object(' TESPRE=""'));
         pipe row(pts_xml_object(' TESCOM=""'));
         pipe row(pts_xml_object(' TESSDT=""'));
         pipe row(pts_xml_object(' TESPDT=""'));
         pipe row(pts_xml_object(' TESFWK=""'));
         pipe row(pts_xml_object(' TESMML=""'));
         pipe row(pts_xml_object(' TESMTM=""'));
         pipe row(pts_xml_object(' TESDAY=""/>'));
      end if;

      /*-*/
      /* Pipe the keyword XML when required
      /*-*/
      if var_action != '*CRTTES' then
         open csr_keyword;
         loop
            fetch csr_keyword into rcd_keyword;
            if csr_keyword%notfound then
               exit;
             end if;
            pipe row(pts_xml_object('<KEYWORD KEYWRD "'||pts_to_xml(rcd_keyword.tke_key_word)||'"/>'));
         end loop;
         close csr_keyword;
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      obj_key_list xmlDom.domNodeList;
      obj_key_node xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      rcd_pts_tes_definition pts_tes_definition%rowtype;
      rcd_pts_tes_keyword pts_tes_keyword%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = rcd_pts_tes_definition.tde_tes_code;
      rcd_check csr_check%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*TES_DEF',9)) t01
          where t01.val_code = rcd_pts_tes_definition.tde_tes_status;
      rcd_sta_code csr_sta_code%rowtype;

      cursor csr_glo_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*TES_DEF',5)) t01
          where t01.val_code = rcd_pts_tes_definition.tde_glo_status;
      rcd_glo_code csr_glo_code%rowtype;

      cursor csr_tes_type is
         select t01.*
           from table(pts_app.pts_gen_function.list_tes_type) t01
          where t01.tty_code = rcd_pts_tes_definition.tde_tes_type;
      rcd_tes_type csr_tes_type%rowtype;

      cursor csr_tar_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*TES_DEF',3)) t01
          where t01.val_code = rcd_pts_tes_definition.tde_tes_target;
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
      if var_action != '*DEFTES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_tes_definition.tde_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCDE'));
      rcd_pts_tes_definition.tde_tes_title := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@TESTIT'));
      rcd_pts_tes_definition.tde_tes_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESSTA'));
      rcd_pts_tes_definition.tde_glo_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESGLO'));
      rcd_pts_tes_definition.tde_com_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@COMCDE'));
      rcd_pts_tes_definition.tde_upd_user := upper(par_user);
      rcd_pts_tes_definition.tde_upd_date := sysdate;
      rcd_pts_tes_definition.tde_tes_type := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESTYP'));
      rcd_pts_tes_definition.tde_tes_target := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESTRG'));
      rcd_pts_tes_definition.tde_tes_requestor := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@TESREQ'));
      rcd_pts_tes_definition.tde_tes_aim := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@TESAIM'));
      rcd_pts_tes_definition.tde_tes_reason := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@TESREA'));
      rcd_pts_tes_definition.tde_tes_prediction := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@TESPRE'));
      rcd_pts_tes_definition.tde_tes_comment := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@TESCOM'));
      rcd_pts_tes_definition.tde_tes_str_date := pts_to_date(xslProcessor.valueOf(obj_pts_request,'@STRDAT'),'dd/mm/yyyy');
      rcd_pts_tes_definition.tde_tes_pan_date := pts_to_date(xslProcessor.valueOf(obj_pts_request,'@PANDAT'),'dd/mm/yyyy');
      rcd_pts_tes_definition.tde_tes_fld_week := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCOM'));
      rcd_pts_tes_definition.tde_tes_min_meal := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCOM'));
      rcd_pts_tes_definition.tde_tes_max_temp := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCOM'));
      rcd_pts_tes_definition.tde_tes_day_count := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCOM'));
      rcd_pts_tes_definition.tde_tes_sam_count := 0;
      rcd_pts_tes_definition.tde_req_mem_count := 0;
      rcd_pts_tes_definition.tde_req_res_count := 0;
      rcd_pts_tes_definition.tde_hou_pet_multi := '0';
      if rcd_pts_tes_definition.tde_tes_code is null and not(xslProcessor.valueOf(obj_pts_request,'@TESCDE') = '*NEW') then
         pts_gen_function.add_mesg_data('Test code ('||xslProcessor.valueOf(obj_pts_request,'@TESCDE')||') must be a number');
      end if;
      if rcd_pts_tes_definition.tde_tes_status is null and not(xslProcessor.valueOf(obj_pts_request,'@TESSTA') is null) then
         pts_gen_function.add_mesg_data('Test status ('||xslProcessor.valueOf(obj_pts_request,'@TESSTA')||') must be a number');
      end if;
      if rcd_pts_tes_definition.tde_glo_status is null and not(xslProcessor.valueOf(obj_pts_request,'@GLOSTA') is null) then
         pts_gen_function.add_mesg_data('Test GloPal status ('||xslProcessor.valueOf(obj_pts_request,'@GLOSTA')||') must be a number');
      end if;
      if rcd_pts_tes_definition.tde_tes_type is null and not(xslProcessor.valueOf(obj_pts_request,'@TESTYP') is null) then
         pts_gen_function.add_mesg_data('Test type ('||xslProcessor.valueOf(obj_pts_request,'@TESTYP')||') must be a number');
      end if;
      if rcd_pts_tes_definition.tde_tes_target is null and not(xslProcessor.valueOf(obj_pts_request,'@TESTRG') is null) then
         pts_gen_function.add_mesg_data('Test target ('||xslProcessor.valueOf(obj_pts_request,'@TESTRG')||') must be a number');
      end if;
      if rcd_pts_tes_definition.tde_tes_str_date is null and not(xslProcessor.valueOf(obj_pts_request,'@STRDAT') is null) then
         pts_gen_function.add_mesg_data('Test start date ('||xslProcessor.valueOf(obj_pts_request,'@STRDAT')||') must be a date in format DD/MM/YYYY');
      end if;
      if rcd_pts_tes_definition.tde_tes_fld_week is null and not(xslProcessor.valueOf(obj_pts_request,'@FLDWEK') is null) then
         pts_gen_function.add_mesg_data('Test in field week ('||xslProcessor.valueOf(obj_pts_request,'@FLDWEK')||') must be a number in format YYYYWW');
      end if;
      if rcd_pts_tes_definition.tde_tes_min_meal is null and not(xslProcessor.valueOf(obj_pts_request,'@MINMEL') is null) then
         pts_gen_function.add_mesg_data('Test meal minutes ('||xslProcessor.valueOf(obj_pts_request,'@MINMEL')||') must be a number');
      end if;
      if rcd_pts_tes_definition.tde_tes_max_temp is null and not(xslProcessor.valueOf(obj_pts_request,'@MAXTEM') is null) then
         pts_gen_function.add_mesg_data('Test maximum temperature ('||xslProcessor.valueOf(obj_pts_request,'@MAXTEM')||') must be a number');
      end if;
      if rcd_pts_tes_definition.tde_tes_day_count is null and not(xslProcessor.valueOf(obj_pts_request,'@DAYCNT') is null) then
         pts_gen_function.add_mesg_data('Test day count ('||xslProcessor.valueOf(obj_pts_request,'@DAYCNT')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_tes_definition.tde_tes_title is null then
         pts_gen_function.add_mesg_data('Test title must be supplied');
      end if;
      if rcd_pts_tes_definition.tde_tes_status is null then
         pts_gen_function.add_mesg_data('Test status must be supplied');
      end if;
      if rcd_pts_tes_definition.tde_glo_status is null then
         pts_gen_function.add_mesg_data('Test GloPal status must be supplied');
      end if;
      if rcd_pts_tes_definition.tde_tes_type is null then
         pts_gen_function.add_mesg_data('Test type must be supplied');
      end if;
      if rcd_pts_tes_definition.tde_tes_target is null then
         pts_gen_function.add_mesg_data('Test target must be supplied');
      end if;
      if rcd_pts_tes_definition.tde_upd_user is null then
         pts_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      open csr_sta_code;
      fetch csr_sta_code into rcd_sta_code;
      if csr_sta_code%notfound then
         pts_gen_function.add_mesg_data('Test status ('||to_char(rcd_pts_tes_definition.tde_tes_status)||') does not exist');
      end if;
      close csr_sta_code;
      open csr_glo_code;
      fetch csr_glo_code into rcd_glo_code;
      if csr_glo_code%notfound then
         pts_gen_function.add_mesg_data('Test GloPal status ('||to_char(rcd_pts_tes_definition.tde_glo_status)||') does not exist');
      end if;
      close csr_glo_code;
      open csr_tes_type;
      fetch csr_tes_type into rcd_tes_type;
      if csr_tes_type%notfound then
         pts_gen_function.add_mesg_data('Test type ('||to_char(rcd_pts_tes_definition.tde_tes_type)||') does not exist');
      else
         if rcd_tes_type.tty_status != 1 then
            pts_gen_function.add_mesg_data('Test type ('||to_char(rcd_pts_tes_definition.tde_tes_type)||') is not active');
         end if;
         rcd_pts_tes_definition.tde_tes_sam_count := rcd_tes_type.tty_sam_count;
      end if;
      close csr_tes_type;
      open csr_tar_code;
      fetch csr_tar_code into rcd_tar_code;
      if csr_tar_code%notfound then
         pts_gen_function.add_mesg_data('Test target ('||to_char(rcd_pts_tes_definition.tde_tes_target)||') does not exist');
      end if;
      close csr_tar_code;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and process the test definition
      /*-*/
      open csr_check;
      fetch csr_check into rcd_check;
      if csr_check%found then
         var_confirm := 'updated';
         update pts_tes_definition
            set tde_tes_title = rcd_pts_tes_definition.tde_tes_title,
                tde_tes_status = rcd_pts_tes_definition.tde_tes_status,
                tde_glo_status = rcd_pts_tes_definition.tde_glo_status,
                tde_com_code = rcd_pts_tes_definition.tde_com_code,
                tde_upd_user = rcd_pts_tes_definition.tde_upd_user,
                tde_upd_date = rcd_pts_tes_definition.tde_upd_date,
                tde_tes_type = rcd_pts_tes_definition.tde_tes_type,
                tde_tes_target = rcd_pts_tes_definition.tde_tes_target,
                tde_tes_requestor = rcd_pts_tes_definition.tde_tes_requestor,
                tde_tes_aim = rcd_pts_tes_definition.tde_tes_aim,
                tde_tes_reason = rcd_pts_tes_definition.tde_tes_reason,
                tde_tes_prediction = rcd_pts_tes_definition.tde_tes_prediction,
                tde_tes_comment = rcd_pts_tes_definition.tde_tes_comment,
                tde_tes_str_date = rcd_pts_tes_definition.tde_tes_str_date,
                tde_tes_pan_date = rcd_pts_tes_definition.tde_tes_pan_date,
                tde_tes_fld_week = rcd_pts_tes_definition.tde_tes_fld_week,
                tde_tes_min_meal = rcd_pts_tes_definition.tde_tes_min_meal,
                tde_tes_max_temp = rcd_pts_tes_definition.tde_tes_max_temp,
                tde_tes_day_count = rcd_pts_tes_definition.tde_tes_day_count,
                tde_tes_sam_count = rcd_pts_tes_definition.tde_tes_sam_count,
                tde_req_mem_count = rcd_pts_tes_definition.tde_req_mem_count,
                tde_req_res_count = rcd_pts_tes_definition.tde_req_res_count,
                tde_hou_pet_multi = rcd_pts_tes_definition.tde_hou_pet_multi
          where tde_tes_code = rcd_pts_tes_definition.tde_tes_code;
         delete from pts_tes_keyword where tke_tes_code = rcd_pts_tes_definition.tde_tes_code;
      else
         var_confirm := 'created';
         select pts_tes_sequence.nextval into rcd_pts_tes_definition.tde_tes_code from dual;
         insert into pts_tes_definition values rcd_pts_tes_definition;
      end if;
      close csr_check;

      /*-*/
      /* Retrieve and insert the keyword data
      /*-*/
      obj_key_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/KEYWORD');
      for idx in 0..xmlDom.getLength(obj_key_list)-1 loop
         obj_key_node := xmlDom.item(obj_key_list,idx);
         rcd_pts_tes_keyword.tke_tes_code := rcd_pts_tes_definition.tde_tes_code;
         rcd_pts_tes_keyword.tke_key_word := pts_from_xml(xslProcessor.valueOf(obj_key_node,'@KEYWRD'));
         insert into pts_tes_keyword values rcd_pts_tes_keyword;
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
      pts_gen_function.set_cfrm_data('Test ('||to_char(rcd_pts_tes_definition.tde_tes_code)||') successfully '||var_confirm);

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

   /*****************************************************/
   /* This procedure performs the response load routine */
   /*****************************************************/
   function response_load return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tes_code number;
      var_day_code number;
      var_target varchar2(64);
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_question is
         select t01.*,
                t02.qde_que_text
           from pts_tes_question t01,
                pts_que_definition t02
          where t01.tqu_que_code = t02.qde_que_code(+)
            and t01.tqu_tes_code = var_tes_code
            and t01.tqu_day_code = var_day_code
          order by t01.tqu_dsp_seqn asc;
      rcd_question csr_question%rowtype;

      cursor csr_panel_pet is
         select t01.*,
                t02.*,
                t03.*,
                decode(t04.tre_pan_code,null,'0','1') as res_status
           from pts_tes_panel t01,
                pts_hou_definition t02,
                pts_pet_definition t03,
                (select distinct(t01.tre_pan_code) as tre_pan_code
                        from pts_tes_response t01
                       where t01.tre_tes_code = var_tes_code) t04
          where t01.tpa_hou_code = t02.hde_hou_code(+)
            and t01.tpa_pan_code = t03.pde_pet_code(+)
            and t01.tpa_pan_code = t04.tre_pan_code
            and t01.tpa_tes_code = var_tes_code
          order by t02.hde_geo_zone asc,
                   t01.tpa_pan_status asc,
                   t01.tpa_pan_code asc;
      rcd_panel_pet csr_panel_pet%rowtype;

      cursor csr_panel_hou is
         select t01.*,
                t02.*,
                decode(t03.tre_pan_code,null,'0','1') as res_status
           from pts_tes_panel t01,
                pts_hou_definition t02,
                (select distinct(t01.tre_pan_code) as tre_pan_code
                        from pts_tes_response t01
                       where t01.tre_tes_code = var_tes_code) t03
          where t01.tpa_pan_code = t02.hde_hou_code(+)
            and t01.tpa_pan_code = t03.tre_pan_code
            and t01.tpa_tes_code = var_tes_code
          order by t02.hde_geo_zone asc,
                   t01.tpa_pan_status asc,
                   t01.tpa_pan_code asc;
      rcd_panel_hou csr_panel_hou%rowtype;

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
      if var_action != '*LODRES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCDE'));
      if var_tes_code is null then
         pts_gen_function.add_mesg_data('Test code ('||xslProcessor.valueOf(obj_pts_request,'@TESCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the test
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||') does not exist');
      end if;
    --  if rcd_retrieve.tde_tes_status != 2 and
    --     rcd_retrieve.tde_tes_status != 3 then
    --     pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') must be status (Questionnaires Printed or Results Entered) - response update not allowed');
    --  end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test xml
      /*-*/
      if rcd_retrieve.tde_tes_target = 1 then
         var_target := 'Pet';
      elsif rcd_retrieve.tde_tes_target = 2 then
         var_target := 'Household';
      else
         var_target := '*UNKNOWN';
      end if;
      pipe row(pts_xml_object('<TEST TESTXT="('||to_char(rcd_retrieve.tde_tes_code)||') '||pts_to_xml(rcd_retrieve.tde_tes_title)||'" TESTRG="'||pts_to_xml(var_target)||'" TESSAM="'||to_char(rcd_retrieve.tde_tes_sam_count)||'"/>'));

      /*-*/
      /* Pipe the test response meta xml
      /*-*/
      for idx in 1..rcd_retrieve.tde_tes_day_count loop
         var_day_code := idx;
         pipe row(pts_xml_object('<METD DAYCDE="'||to_char(var_day_code)||'" DAYTXT="Day '||to_char(var_day_code)||'"/>'));
         open csr_question;
         loop
            fetch csr_question into rcd_question;
            if csr_question%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<METQ DAYCDE="'||to_char(var_day_code)||'" QUECDE="'||to_char(rcd_question.tqu_que_code)||'" QUETXT="Que '||to_char(rcd_question.tqu_dsp_seqn)||'" QUETYP="'||pts_to_xml(rcd_question.tqu_que_type)||'" QUENAM="'||pts_to_xml(rcd_question.qde_que_text)||'"/>'));
         end loop;
         close csr_question;
      end loop;

      /*-*/
      /* Pipe the test panel data xml
      /*-*/
      if rcd_retrieve.tde_tes_target = 1 then
         open csr_panel_pet;
         loop
            fetch csr_panel_pet into rcd_panel_pet;
            if csr_panel_pet%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<PANEL PANCDE="'||to_char(rcd_panel_pet.tpa_pan_code)||'" PANSTS="'||pts_to_xml(rcd_panel_pet.tpa_pan_status)||'" PANTXT="'||pts_to_xml('('||to_char(rcd_panel_pet.tpa_pan_code)||') '||rcd_panel_pet.pde_pet_name||' - Household ('||rcd_panel_pet.tpa_hou_code||') '||rcd_panel_pet.hde_con_fullname||', '||rcd_panel_pet.hde_loc_street||', '||rcd_panel_pet.hde_loc_town)||'" RESSTS="'||pts_to_xml(rcd_panel_pet.res_status)||'"/>'));
         end loop;
         close csr_panel_pet;
      else
         open csr_panel_hou;
         loop
            fetch csr_panel_hou into rcd_panel_hou;
            if csr_panel_hou%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<PANEL PANCDE="'||to_char(rcd_panel_hou.tpa_pan_code)||'" PANSTS="'||pts_to_xml(rcd_panel_pet.tpa_pan_status)||'" PANTXT="'||pts_to_xml('('||to_char(rcd_panel_hou.tpa_pan_code)||') '||rcd_panel_hou.hde_con_fullname||', '||rcd_panel_hou.hde_loc_street||', '||rcd_panel_hou.hde_loc_town)||'" RESSTS="'||pts_to_xml(rcd_panel_hou.res_status)||'"/>'));
         end loop;
         close csr_panel_hou;
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RESPONSE_LOAD - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end response_load;

   /*****************************************************/
   /* This procedure performs the response list routine */
   /*****************************************************/
   function response_list return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tes_code number;
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_panel_pet is
         select t01.*,
                t02.*,
                t03.*,
                decode(t04.tre_pan_code,null,'0','1') as res_status
           from pts_tes_panel t01,
                pts_hou_definition t02,
                pts_pet_definition t03,
                (select distinct(t01.tre_pan_code) as tre_pan_code
                        from pts_tes_response t01
                       where t01.tre_tes_code = var_tes_code) t04
          where t01.tpa_hou_code = t02.hde_hou_code(+)
            and t01.tpa_pan_code = t03.pde_pet_code(+)
            and t01.tpa_pan_code = t04.tre_pan_code
            and t01.tpa_tes_code = var_tes_code
          order by t02.hde_geo_zone asc,
                   t01.tpa_pan_status asc,
                   t01.tpa_pan_code asc;
      rcd_panel_pet csr_panel_pet%rowtype;

      cursor csr_panel_hou is
         select t01.*,
                t02.*,
                decode(t03.tre_pan_code,null,'0','1') as res_status
           from pts_tes_panel t01,
                pts_hou_definition t02,
                (select distinct(t01.tre_pan_code) as tre_pan_code
                        from pts_tes_response t01
                       where t01.tre_tes_code = var_tes_code) t03
          where t01.tpa_pan_code = t02.hde_hou_code(+)
            and t01.tpa_pan_code = t03.tre_pan_code
            and t01.tpa_tes_code = var_tes_code
          order by t02.hde_geo_zone asc,
                   t01.tpa_pan_status asc,
                   t01.tpa_pan_code asc;
      rcd_panel_hou csr_panel_hou%rowtype;

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
      if var_action != '*LSTRES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCDE'));
      if var_tes_code is null then
         pts_gen_function.add_mesg_data('Test code ('||xslProcessor.valueOf(obj_pts_request,'@TESCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the test
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||') does not exist');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test panel data xml
      /*-*/
      if rcd_retrieve.tde_tes_target = 1 then
         open csr_panel_pet;
         loop
            fetch csr_panel_pet into rcd_panel_pet;
            if csr_panel_pet%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<PANEL PANCDE="'||to_char(rcd_panel_pet.tpa_pan_code)||'" PANSTS="'||pts_to_xml(rcd_panel_pet.tpa_pan_status)||'" PANTXT="'||pts_to_xml('('||to_char(rcd_panel_pet.tpa_pan_code)||') '||rcd_panel_pet.pde_pet_name||' - Household ('||rcd_panel_pet.tpa_hou_code||') '||rcd_panel_pet.hde_con_fullname||', '||rcd_panel_pet.hde_loc_street||', '||rcd_panel_pet.hde_loc_town)||'" RESSTS="'||pts_to_xml(rcd_panel_pet.res_status)||'"/>'));
         end loop;
         close csr_panel_pet;
      else
         open csr_panel_hou;
         loop
            fetch csr_panel_hou into rcd_panel_hou;
            if csr_panel_hou%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<PANEL PANCDE="'||to_char(rcd_panel_hou.tpa_pan_code)||'" PANSTS="'||pts_to_xml(rcd_panel_pet.tpa_pan_status)||'" PANTXT="'||pts_to_xml('('||to_char(rcd_panel_hou.tpa_pan_code)||') '||rcd_panel_hou.hde_con_fullname||', '||rcd_panel_hou.hde_loc_street||', '||rcd_panel_hou.hde_loc_town)||'" RESSTS="'||pts_to_xml(rcd_panel_hou.res_status)||'"/>'));
         end loop;
         close csr_panel_hou;
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RESPONSE_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end response_list;

   /*********************************************************/
   /* This procedure performs the response retrieve routine */
   /*********************************************************/
   function response_retrieve return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tes_code number;
      var_pan_code number;
      var_day_code number;
      var_que_code number;
      var_seq_numb number;
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_allocation is
         select t01.*,
                t02.tsa_mkt_code
           from pts_tes_allocation t01,
                pts_tes_sample t02
          where t01.tal_tes_code = t02.tsa_tes_code
            and t01.tal_sam_code = t02.tsa_sam_code
            and t01.tal_tes_code = var_tes_code
            and t01.tal_pan_code = var_pan_code
            and t01.tal_day_code = var_day_code
          order by t01.tal_seq_numb asc;
      rcd_allocation csr_allocation%rowtype;

      cursor csr_response is
         select t01.*,
                nvl(t02.tal_seq_numb,0) as tal_seq_numb
           from pts_tes_response t01,
                pts_tes_allocation t02
          where t01.tre_tes_code = t02.tal_tes_code(+)
            and t01.tre_pan_code = t02.tal_pan_code(+)
            and t01.tre_day_code = t02.tal_day_code(+)
            and t01.tre_sam_code = t02.tal_sam_code(+)
            and t01.tre_tes_code = var_tes_code
            and t01.tre_pan_code = var_pan_code
            and t01.tre_day_code = var_day_code
          order by t01.tre_que_code asc,
                   tal_seq_numb asc;
      rcd_response csr_response%rowtype;

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
      var_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCDE'));
      var_pan_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PANCDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SELRES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the test
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||') does not exist');
      end if;
    --  if rcd_retrieve.tde_tes_status != 2 and
    --     rcd_retrieve.tde_tes_status != 3 then
    --     pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') must be status (Questionnaires Printed or Results Entered) - response update not allowed');
    --  end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test panel response xml
      /*-*/
      for idx in 1..rcd_retrieve.tde_tes_day_count loop
         var_day_code := idx;
         var_seq_numb := 0;
         open csr_allocation;
         loop
            fetch csr_allocation into rcd_allocation;
            if csr_allocation%notfound then
               exit;
            end if;
            var_seq_numb := var_seq_numb + 1;
            pipe row(pts_xml_object('<RESD DAYCDE="'||to_char(var_day_code)||'" RESSEQ="'||to_char(var_seq_numb)||'" MKTCDE="'||pts_to_xml(rcd_allocation.tsa_mkt_code)||'"/>'));
         end loop;
         close csr_allocation;
         var_que_code := 0;
         var_seq_numb := 0;
         open csr_response;
         loop
            fetch csr_response into rcd_response;
            if csr_response%notfound then
               exit;
            end if;
            if var_que_code != rcd_response.tre_que_code then
               var_que_code := rcd_response.tre_que_code;
               var_seq_numb := 0;
            end if;
            var_seq_numb := var_seq_numb + 1;
            pipe row(pts_xml_object('<RESQ DAYCDE="'||to_char(var_day_code)||'" QUECDE="'||to_char(rcd_response.tre_que_code)||'" RESSEQ="'||to_char(var_seq_numb)||'" RESVAL="'||to_char(rcd_response.tre_res_value)||'"/>'));
         end loop;
         close csr_response;
      end loop;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RESPONSE_RETRIEVE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end response_retrieve;

   /*******************************************************/
   /* This procedure performs the update response routine */
   /*******************************************************/
   procedure update_response is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      obj_res_list xmlDom.domNodeList;
      obj_res_node xmlDom.domNode;
      var_action varchar2(32);
      var_tes_code number;
      var_pan_code number;
      var_day_code number;
      var_mkt_code varchar2(10);
      var_sam_cod1 number;
      var_sam_cod2 number;
      var_seq_numb number;
      var_que_code number;
      var_res_value number;
      var_typ_code varchar2(10 char);
      var_found boolean;
      var_message boolean;
      rcd_pts_tes_panel pts_tes_panel%rowtype;
      rcd_pts_tes_allocation pts_tes_allocation%rowtype;
      rcd_pts_tes_response pts_tes_response%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = var_tes_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_panel is
         select t01.*
           from pts_tes_panel t01
          where t01.tpa_tes_code = var_tes_code
            and t01.tpa_pan_code = var_pan_code;
      rcd_panel csr_panel%rowtype;

      cursor csr_pet is
         select t01.*
           from pts_pet_definition t01
          where t01.pde_pet_code = var_pan_code;
      rcd_pet csr_pet%rowtype;

      cursor csr_household is
         select t01.*
           from pts_hou_definition t01
          where t01.hde_hou_code = var_pan_code;
      rcd_household csr_household%rowtype;

      cursor csr_allocation is
         select t01.*
           from pts_tes_allocation t01
          where t01.tal_tes_code = var_tes_code
            and t01.tal_pan_code = var_pan_code
            and t01.tal_day_code = var_day_code
            and t01.tal_seq_numb = var_seq_numb;
      rcd_allocation csr_allocation%rowtype;

      cursor csr_sample is
         select t01.*
           from pts_tes_sample t01
          where t01.tsa_tes_code = var_tes_code
            and t01.tsa_mkt_code = var_mkt_code;
      rcd_sample csr_sample%rowtype;

      cursor csr_question is
         select t01.*
           from pts_que_definition t01
          where t01.qde_que_code  = var_que_code;
      rcd_question csr_question%rowtype;

      cursor csr_response is
         select t01.*
           from pts_que_response t01
          where t01.qre_que_code = var_que_code
            and t01.qre_res_code = var_res_value;
      rcd_response csr_response%rowtype;

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
      if var_action != '*UPDRES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCDE'));
      var_pan_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PANCDE'));
      if var_tes_code is null then
         pts_gen_function.add_mesg_data('Test code ('||xslProcessor.valueOf(obj_pts_request,'@TESCDE')||') must be a number');
      end if;
      if var_pan_code is null then
         pts_gen_function.add_mesg_data('Panel code ('||xslProcessor.valueOf(obj_pts_request,'@PANCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the existing test
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
            pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||') is currently locked');
            return;
      end;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||') does not exist');
      end if;
    --  if rcd_retrieve.tde_tes_status != 2 and
    --     rcd_retrieve.tde_tes_status != 3 then
    --     pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') must be status (Questionnaires Printed or Results Entered) - response update not allowed');
    --  end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing panel member
      /* **notes** 1. Create a recruited panel when not found
      /*-*/
      var_found := false;
      open csr_panel;
      fetch csr_panel into rcd_panel;
      if csr_panel%found then
         var_found := true;
      end if;
      close csr_panel;
      if var_found = false then
         rcd_pts_tes_panel.tpa_tes_code := var_tes_code;
         rcd_pts_tes_panel.tpa_pan_code := var_pan_code;
         rcd_pts_tes_panel.tpa_pan_status := '*RECRUITED';
         rcd_pts_tes_panel.tpa_sel_group := '*RECRUITED';
         if rcd_retrieve.tde_tes_target = 1 then
            open csr_pet;
            fetch csr_pet into rcd_pet;
            if csr_pet%notfound then
               pts_gen_function.add_mesg_data('Pet ('||to_char(var_pan_code)||') does not exist');
            else
               if rcd_pet.pde_pet_status != 1 then
                  pts_gen_function.add_mesg_data('Pet ('||to_char(var_pan_code)||') is not available');
               end if;
               rcd_pts_tes_panel.tpa_hou_code := rcd_pet.pde_hou_code;
            end if;
            close csr_pet;
         else
            open csr_household;
            fetch csr_household into rcd_household;
            if csr_household%notfound then
               pts_gen_function.add_mesg_data('Household ('||to_char(var_pan_code)||') does not exist');
            else
               if rcd_household.hde_hou_status != 1 then
                  pts_gen_function.add_mesg_data('Household ('||to_char(var_pan_code)||') is not available');
               end if;
               rcd_pts_tes_panel.tpa_hou_code := var_pan_code;
            end if;
            close csr_household;
         end if;
         if pts_gen_function.get_mesg_count = 0 then
            insert into pts_tes_panel values rcd_pts_tes_panel;
         end if;
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Clear the existing response data
      /*-*/
      delete from pts_tes_response
       where tre_tes_code = var_tes_code
         and tre_pan_code = var_pan_code;

      /*-*/
      /* Retrieve and insert the response data
      /*-*/
      rcd_pts_tes_response.tre_tes_code := var_tes_code;
      rcd_pts_tes_response.tre_pan_code := var_pan_code;
      obj_res_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/RESP');
      for idx in 0..xmlDom.getLength(obj_res_list)-1 loop
         obj_res_node := xmlDom.item(obj_res_list,idx);
         var_typ_code := upper(xslProcessor.valueOf(obj_res_node,'@TYPCDE'));
         if var_typ_code = 'D' then
            var_message := false;
            var_day_code := pts_to_number(xslProcessor.valueOf(obj_res_node,'@DAYCDE'));
            var_sam_cod1 := null;
            var_sam_cod2 := null;
            var_mkt_code := upper(xslProcessor.valueOf(obj_res_node,'@MKTCD1'));
            if var_mkt_code is null then
               var_seq_numb := var_day_code;
               if rcd_retrieve.tde_tes_sam_count = 2 then
                  var_seq_numb := 1;
               end if;
               open csr_allocation;
               fetch csr_allocation into rcd_allocation;
               if csr_allocation%notfound then
                  pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code one allocation does not exist for this test - must be specified');
                  var_message := true;
               else
                  var_sam_cod1 := rcd_allocation.tal_sam_code;
               end if;
               close csr_allocation;
            else
               open csr_sample;
               fetch csr_sample into rcd_sample;
               if csr_sample%notfound then
                  pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') does not exist for this test');
                  var_message := true;
               else
                  var_sam_cod1 := rcd_sample.tsa_sam_code;
                  var_seq_numb := var_day_code;
                  if rcd_retrieve.tde_tes_sam_count = 2 then
                     var_seq_numb := 1;
                  end if;
                  update pts_tes_allocation
                     set tal_seq_numb = var_seq_numb
                   where tal_tes_code = var_tes_code
                     and tal_pan_code = var_pan_code
                     and tal_day_code = var_day_code
                     and tal_sam_code = var_sam_cod1;
                  if sql%notfound then
                     rcd_pts_tes_allocation.tal_tes_code := var_tes_code;
                     rcd_pts_tes_allocation.tal_pan_code := var_pan_code;
                     rcd_pts_tes_allocation.tal_day_code := var_day_code;
                     rcd_pts_tes_allocation.tal_sam_code := var_sam_cod1;
                     rcd_pts_tes_allocation.tal_seq_numb := var_seq_numb;
                     insert into pts_tes_allocation values rcd_pts_tes_allocation;
                  end if;
               end if;
               close csr_sample;
            end if;
            if rcd_retrieve.tde_tes_sam_count = 2 then
               var_mkt_code := upper(xslProcessor.valueOf(obj_res_node,'@MKTCD2'));
               if var_mkt_code is null then
                  var_seq_numb := var_day_code;
                  if rcd_retrieve.tde_tes_sam_count = 2 then
                     var_seq_numb := 2;
                  end if;
                  open csr_allocation;
                  fetch csr_allocation into rcd_allocation;
                  if csr_allocation%notfound then
                     pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code two allocation does not exist for this test - must be specified');
                     var_message := true;
                  else
                     var_sam_cod2 := rcd_allocation.tal_sam_code;
                  end if;
                  close csr_allocation;
               else
                  open csr_sample;
                  fetch csr_sample into rcd_sample;
                  if csr_sample%notfound then
                     pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') does not exist for this test');
                     var_message := true;
                  else
                     var_sam_cod2 := rcd_sample.tsa_sam_code;
                     var_seq_numb := var_day_code;
                     if rcd_retrieve.tde_tes_sam_count = 2 then
                        var_seq_numb := 2;
                     end if;
                     update pts_tes_allocation
                        set tal_seq_numb = var_seq_numb
                      where tal_tes_code = var_tes_code
                        and tal_pan_code = var_pan_code
                        and tal_day_code = var_day_code
                        and tal_sam_code = var_sam_cod2;
                     if sql%notfound then
                        rcd_pts_tes_allocation.tal_tes_code := var_tes_code;
                        rcd_pts_tes_allocation.tal_pan_code := var_pan_code;
                        rcd_pts_tes_allocation.tal_day_code := var_day_code;
                        rcd_pts_tes_allocation.tal_sam_code := var_sam_cod1;
                        rcd_pts_tes_allocation.tal_seq_numb := var_seq_numb;
                        insert into pts_tes_allocation values rcd_pts_tes_allocation;
                     end if;
                  end if;
                  close csr_sample;
               end if;
            end if;
         end if;
         if var_typ_code = 'Q' then
            if not(xslProcessor.valueOf(obj_res_node,'@RESVAL') is null) then
               var_que_code := pts_to_number(xslProcessor.valueOf(obj_res_node,'@QUECDE'));
               var_res_value := pts_to_number(xslProcessor.valueOf(obj_res_node,'@RESVAL'));
               open csr_question;
               fetch csr_question into rcd_question;
               if csr_question%notfound then
                  pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') question ('||to_char(var_que_code)||') does not exist for this test');
                  var_message := true;
               else
                  if rcd_question.qde_rsp_type = 1 then
                     open csr_response;
                     fetch csr_response into rcd_response;
                     if csr_response%notfound then
                        pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') question ('||to_char(var_que_code)||') response value ('||to_char(var_res_value)||') does not exist for question');
                        var_message := true;
                     end if;
                     close csr_response;
                  elsif rcd_question.qde_rsp_type = 2 then
                     if var_res_value < rcd_question.qde_rsp_str_range or var_res_value > rcd_question.qde_rsp_end_range then
                        pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') question ('||to_char(var_que_code)||') response value ('||to_char(var_res_value)||') is not within the defined range ('||to_char(rcd_question.qde_rsp_str_range)||' to '||to_char(rcd_question.qde_rsp_end_range)||')');
                        var_message := true;
                     end if;
                  else
                     pts_gen_function.add_mesg_data('Question has invalid response type');
                     var_message := true;
                  end if;
               end if;
               close csr_question;
               if var_message = false then
                  rcd_pts_tes_response.tre_day_code := var_day_code;
                  rcd_pts_tes_response.tre_que_code := var_que_code;
                  rcd_pts_tes_response.tre_sam_code := 0;
                  if xslProcessor.valueOf(obj_res_node,'@RESSEQ') = '1' then
                     rcd_pts_tes_response.tre_sam_code := var_sam_cod1;
                  elsif xslProcessor.valueOf(obj_res_node,'@RESSEQ') = '2' then
                     rcd_pts_tes_response.tre_sam_code := var_sam_cod2;
                  end if;
                  rcd_pts_tes_response.tre_res_value := var_res_value;
                  insert into pts_tes_response values rcd_pts_tes_response;
               end if;
            end if;
         end if;
      end loop;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - UPDATE_RESPONSE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_response;

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
      var_found boolean;
      rcd_pts_tes_definition pts_tes_definition%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = rcd_pts_tes_definition.tde_tes_code
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
      if var_action != '*TESPAN' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_tes_definition.tde_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCODE'));
      rcd_pts_tes_definition.tde_req_mem_count := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@MEMCNT'));
      rcd_pts_tes_definition.tde_req_res_count := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@RESCNT'));
      rcd_pts_tes_definition.tde_hou_pet_multi := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@PETMLT'));
   --   rcd_pts_tes_definition.tde_upd_user := upper(par_user);
      rcd_pts_tes_definition.tde_upd_date := sysdate;
      if rcd_pts_tes_definition.tde_tes_code is null then
         pts_gen_function.add_mesg_data('Test code ('||xslProcessor.valueOf(obj_pts_request,'@TESCODE')||') must be a number');
      end if;
      if rcd_pts_tes_definition.tde_req_mem_count is null or rcd_pts_tes_definition.tde_req_mem_count < 1 then
         pts_gen_function.add_mesg_data('Member count ('||xslProcessor.valueOf(obj_pts_request,'@MEMCNT')||') must be a number greater than zero');
      end if;
      if rcd_pts_tes_definition.tde_req_res_count is null or rcd_pts_tes_definition.tde_req_res_count < 1 then
         rcd_pts_tes_definition.tde_req_res_count := 0;
      end if;
      if rcd_pts_tes_definition.tde_hou_pet_multi is null or (rcd_pts_tes_definition.tde_hou_pet_multi != '0' and rcd_pts_tes_definition.tde_hou_pet_multi != '1') then
         pts_gen_function.add_mesg_data('Allow multiple household pets ('||xslProcessor.valueOf(obj_pts_request,'@PETMLT')||') must be ''0'' or ''1''');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve and lock the existing test
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
            pts_gen_function.add_mesg_data('Test ('||to_char(rcd_pts_tes_definition.tde_tes_code)||') is currently locked');
            return;
      end;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test ('||to_char(rcd_pts_tes_definition.tde_tes_code)||') does not exist');
      end if;
      if rcd_retrieve.tde_tes_status != 1 and
         rcd_retrieve.tde_tes_status != 5 then
         raise_application_error(-20000, 'Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') must be status (Raised or Errored) - panel selection not allowed');
      end if;

      /*-*/
      /* Clear and select the test panel
      /* **note** 1. Autonomous transactions that not impact the test lock
      /*-*/
      clear_panel( rcd_pts_tes_definition.tde_tes_code, rcd_pts_tes_definition.tde_req_mem_count, rcd_pts_tes_definition.tde_req_res_count);
      if rcd_retrieve.tde_tes_target = 1 then
         select_pet_panel(rcd_retrieve.tde_tes_code, '*MEMBER', rcd_pts_tes_definition.tde_hou_pet_multi);
         if rcd_pts_tes_definition.tde_req_res_count != 0 then
            select_pet_panel(rcd_retrieve.tde_tes_code, '*RESERVE', rcd_pts_tes_definition.tde_hou_pet_multi);
         end if;
      else
         select_hou_panel(rcd_retrieve.tde_tes_code, '*MEMBER');
         if rcd_pts_tes_definition.tde_req_res_count != 0 then
            select_hou_panel(rcd_retrieve.tde_tes_code, '*RESERVE');
         end if;
      end if;

      /*-*/
      /* Update the test definition
      /*-*/
      update pts_tes_definition
         set tde_tes_pan_date = sysdate,
             tde_upd_user = rcd_pts_tes_definition.tde_upd_user,
             tde_upd_date = rcd_pts_tes_definition.tde_upd_date,
             tde_req_mem_count = rcd_pts_tes_definition.tde_req_mem_count,
             tde_req_res_count = rcd_pts_tes_definition.tde_req_res_count,
             tde_hou_pet_multi = rcd_pts_tes_definition.tde_hou_pet_multi
       where tde_tes_code =  rcd_pts_tes_definition.tde_tes_code;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - UPDATE_PANEL - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_panel;

   /****************************************************/
   /* This procedure performs the report panel routine */
   /****************************************************/
   function report_panel(par_tes_code in number) return pts_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_tes_code number;
      var_found boolean;
      var_group boolean;
      var_output varchar2(4000 char);
      var_work varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_group is
         select t01.*
           from pts_tes_group t01
          where t01.tgr_tes_code = var_tes_code
          order by t01.tgr_sel_group asc;
      rcd_group csr_group%rowtype;

      cursor csr_rule is
         select t01.*,
                t02.sfi_fld_text,
                t02.sfi_fld_rul_type
           from pts_tes_rule t01,
                pts_sys_field t02
          where t01.tru_tab_code = t02.sfi_tab_code
            and t01.tru_fld_code = t02.sfi_fld_code
            and t01.tru_tes_code = var_tes_code
            and t01.tru_sel_group = rcd_group.tgr_sel_group
          order by t01.tru_tab_code asc,
                   t01.tru_fld_code asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is
         select t01.*
           from pts_tes_value t01
          where t01.tva_tes_code = var_tes_code
            and t01.tva_sel_group = rcd_group.tgr_sel_group
            and t01.tva_tab_code = rcd_rule.tru_tab_code
            and t01.tva_fld_code = rcd_rule.tru_fld_code
          order by t01.tva_val_code asc;
      rcd_value csr_value%rowtype;

      cursor csr_panel_pet is
         select t01.*,
                t02.*,
                t03.*
           from pts_tes_panel t01,
                pts_hou_definition t02,
                pts_pet_definition t03
          where t01.tpa_hou_code = t02.hde_hou_code(+)
            and t01.tpa_pan_code = t03.pde_pet_code(+)
            and t01.tpa_tes_code = var_tes_code
            and t01.tpa_sel_group = rcd_group.tgr_sel_group
          order by t01.tpa_pan_status asc,
                   t01.tpa_pan_code asc;
      rcd_panel_pet csr_panel_pet%rowtype;

      cursor csr_panel_hou is
         select t01.*,
                t02.*
           from pts_tes_panel t01,
                pts_hou_definition t02
          where t01.tpa_pan_code = t02.hde_hou_code(+)
            and t01.tpa_tes_code = var_tes_code
            and t01.tpa_sel_group = rcd_group.tgr_sel_group
          order by t01.tpa_pan_status asc,
                   t01.tpa_pan_code asc;
      rcd_panel_hou csr_panel_hou%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameters
      /*-*/
      var_tes_code := par_tes_code;

      /*-*/
      /* Retrieve the existing test
      /*-*/
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') does not exist');
      end if;

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<table border=1>');
      pipe row('<tr><td align=center colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">('||rcd_retrieve.tde_tes_code||') '||rcd_retrieve.tde_tes_title||'</td></tr>');
      pipe row('<tr>');
      pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Type</td>');
      pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Description</td>');
      pipe row('</tr>');
      pipe row('<tr><td align=center colspan=2></td></tr>');

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
            pipe row('<tr><td align=center colspan=2></td></tr>');
         end if;
         var_group := true;

         /*-*/
         /* Output the group data
         /*-*/
         var_work := rcd_group.tgr_sel_text||' ('||to_char(rcd_group.tgr_sel_pcnt)||'%)';
         var_work := var_work||' - Requested/Selected Members ('||to_char(rcd_group.tgr_req_mem_count)||'/'||to_char(rcd_group.tgr_sel_mem_count)||')';
         var_work := var_work||' - Requested/Selected Reserves ('||to_char(rcd_group.tgr_req_res_count)||'/'||to_char(rcd_group.tgr_sel_res_count)||')';
         var_output := '<tr>';
         var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Group</td>';
         var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;" nowrap>'||var_work||'</td>';
         var_output := var_output||'</tr>';
         pipe row(var_output);
         pipe row('<tr><td align=center colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Rules</td></tr>');

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
            var_work := rcd_rule.sfi_fld_text||' ('||rcd_rule.tru_rul_code||')';
            var_output := '<tr>';
            var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Rule</td>';
            var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td>';
            var_output := var_output||'</tr>';
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
                  var_work := rcd_value.tva_val_text;
               else
                  var_work := rcd_value.tva_val_text;
                  if rcd_rule.tru_rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                     var_work := rcd_value.tva_val_text||' ('||rcd_value.tva_val_pcnt||'%)';
                     var_work := var_work||' - Requested/Selected Members ('||to_char(rcd_value.tva_req_mem_count)||'/'||to_char(rcd_value.tva_sel_mem_count)||')';
                     var_work := var_work||' - Requested/Selected Reserves ('||to_char(rcd_value.tva_req_res_count)||'/'||to_char(rcd_value.tva_sel_res_count)||')';
                  end if;
               end if;
               var_output := '<tr>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td>';
               var_output := var_output||'</tr>';
               pipe row(var_output);
            end loop;
            close csr_value;

         end loop;
         close csr_rule;

         /*-*/
         /* Retrieve the panel data
         /*-*/
         if rcd_retrieve.tde_tes_target = 1 then
            pipe row('<tr><td align=center colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Panel</td></tr>');
            open csr_panel_pet;
            loop
               fetch csr_panel_pet into rcd_panel_pet;
               if csr_panel_pet%notfound then
                  exit;
               end if;
               var_work := 'Household ('||rcd_panel_pet.tpa_hou_code||') '||rcd_panel_pet.hde_con_fullname||', '||rcd_panel_pet.hde_loc_street||', '||rcd_panel_pet.hde_loc_town;
               var_work := var_work||' - Pet ('||rcd_panel_pet.tpa_pan_code||') '||rcd_panel_pet.pde_pet_name;
               var_output := '<tr>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel_pet.tpa_pan_status||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td>';
               var_output := var_output||'</tr>';
               pipe row(var_output);
            end loop;
            close csr_panel_pet;
         else
            pipe row('<tr><td align=center colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Panel</td></tr>');
            open csr_panel_hou;
            loop
               fetch csr_panel_hou into rcd_panel_hou;
               if csr_panel_hou%notfound then
                  exit;
               end if;
               var_work := 'Household ('||rcd_panel_hou.tpa_pan_code||') '||rcd_panel_hou.hde_con_fullname||', '||rcd_panel_hou.hde_loc_street||', '||rcd_panel_hou.hde_loc_town;
               var_output := '<tr>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel_hou.tpa_pan_status||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td>';
               var_output := var_output||'</tr>';
               pipe row(var_output);
            end loop;
            close csr_panel_hou;
         end if;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_TES_FUNCTION - REPORT_PANEL - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_panel;

   /***************************************************/
   /* This procedure performs the clear panel routine */
   /***************************************************/
   procedure clear_panel(par_tes_code in number, par_req_mem_count in number, par_req_res_count in number) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_sel_group varchar2(32);
      var_tgr_mem_count number;
      var_tgr_res_count number;
      var_tva_mem_count number;
      var_tva_res_count number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_group is
         select t01.*
           from pts_tes_group t01
          where t01.tgr_tes_code = par_tes_code
          order by t01.tgr_sel_group asc;
      rcd_group csr_group%rowtype;

      cursor csr_rule is
         select t01.*
           from pts_tes_rule t01
          where t01.tru_tes_code = par_tes_code
            and t01.tru_sel_group = var_sel_group
          order by t01.tru_tab_code asc,
                   t01.tru_fld_code asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is
         select t01.*
           from pts_tes_value t01
          where t01.tva_tes_code = par_tes_code
            and t01.tva_sel_group = var_sel_group
            and t01.tva_tab_code = rcd_rule.tru_tab_code
            and t01.tva_fld_code = rcd_rule.tru_fld_code
          order by t01.tva_val_code asc;
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
      var_tgr_mem_count := 0;
      var_tgr_res_count := 0;
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
            values(rcd_group.tgr_sel_group);

         /*-*/
         /* Load the group array
         /*-*/
         tbl_sel_group(tbl_sel_group.count+1).sel_group := rcd_group.tgr_sel_group;
         tbl_sel_group(tbl_sel_group.count).tru_rule := 0;
         tbl_sel_group(tbl_sel_group.count).end_rule := 0;
         tbl_sel_group(tbl_sel_group.count).req_mem_count := round(par_req_mem_count * (nvl(rcd_group.tgr_sel_pcnt,0)/100), 0);
         tbl_sel_group(tbl_sel_group.count).req_res_count := round(par_req_res_count * (nvl(rcd_group.tgr_sel_pcnt,0)/100), 0);
         tbl_sel_group(tbl_sel_group.count).sel_mem_count := 0;
         tbl_sel_group(tbl_sel_group.count).sel_res_count := 0;
         var_tgr_mem_count := var_tgr_mem_count + tbl_sel_group(tbl_sel_group.count).req_mem_count;
         var_tgr_res_count := var_tgr_res_count + tbl_sel_group(tbl_sel_group.count).req_res_count;

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
         if var_tgr_mem_count != par_req_mem_count then
            tbl_sel_group(tbl_sel_group.count).req_mem_count := tbl_sel_group(tbl_sel_group.count).req_mem_count + (par_req_mem_count - var_tgr_mem_count);
         end if;
         if var_tgr_res_count != par_req_res_count then
            tbl_sel_group(tbl_sel_group.count).req_res_count := tbl_sel_group(tbl_sel_group.count).req_res_count + (par_req_res_count - var_tgr_res_count);
         end if;

         /*-*/
         /* Reset the test group panel member and reserve counts
         /*-*/
         for idg in 1..tbl_sel_group.count loop
            update pts_tes_group
               set tgr_req_mem_count = tbl_sel_group(idg).req_mem_count,
                   tgr_req_res_count = tbl_sel_group(idg).req_res_count,
                   tgr_sel_mem_count = 0,
                   tgr_sel_res_count = 0
             where tgr_tes_code = par_tes_code
               and tgr_sel_group = tbl_sel_group(idg).sel_group;
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
               values(rcd_rule.tru_sel_group,
                      rcd_rule.tru_tab_code,
                      rcd_rule.tru_fld_code,
                      rcd_rule.tru_rul_code);

            /*-*/
            /* Load the rule array
            /*-*/
            tbl_sel_rule(tbl_sel_rule.count+1).sel_group := rcd_rule.tru_sel_group;
            tbl_sel_rule(tbl_sel_rule.count).tab_code := rcd_rule.tru_tab_code;
            tbl_sel_rule(tbl_sel_rule.count).fld_code := rcd_rule.tru_fld_code;
            tbl_sel_rule(tbl_sel_rule.count).rul_code := rcd_rule.tru_rul_code;
            tbl_sel_rule(tbl_sel_rule.count).tru_value := 0;
            tbl_sel_rule(tbl_sel_rule.count).end_value := 0;
            tbl_sel_rule(tbl_sel_rule.count).sel_count := 0;
            if tbl_sel_group(idg).tru_rule = 0 then
               tbl_sel_group(idg).tru_rule := tbl_sel_rule.count;
            end if;
            tbl_sel_group(idg).end_rule := tbl_sel_rule.count;

            /*-*/
            /* Process the selection group rule values
            /*-*/
            var_tva_mem_count := 0;
            var_tva_res_count := 0;
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
                  values(rcd_value.tva_sel_group,
                         rcd_value.tva_tab_code,
                         rcd_value.tva_fld_code,
                         rcd_value.tva_val_code,
                         rcd_value.tva_val_text);

               /*-*/
               /* Load the value array
               /*-*/
               tbl_sel_value(tbl_sel_value.count+1).sel_group := rcd_value.tva_sel_group;
               tbl_sel_value(tbl_sel_value.count).tab_code := rcd_value.tva_tab_code;
               tbl_sel_value(tbl_sel_value.count).fld_code := rcd_value.tva_fld_code;
               tbl_sel_value(tbl_sel_value.count).val_code := rcd_value.tva_val_code;
               tbl_sel_value(tbl_sel_value.count).val_text := rcd_value.tva_val_text;
               tbl_sel_value(tbl_sel_value.count).val_pcnt := rcd_value.tva_val_pcnt;
               tbl_sel_value(tbl_sel_value.count).req_mem_count := 0;
               tbl_sel_value(tbl_sel_value.count).req_res_count := 0;
               tbl_sel_value(tbl_sel_value.count).sel_mem_count := 0;
               tbl_sel_value(tbl_sel_value.count).sel_res_count := 0;
               tbl_sel_value(tbl_sel_value.count).sel_count := 0;
               tbl_sel_value(tbl_sel_value.count).fld_count := 0;
               if tbl_sel_rule(tbl_sel_rule.count).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                  tbl_sel_value(tbl_sel_value.count).req_mem_count := round(tbl_sel_group(idg).req_mem_count * (nvl(rcd_value.tva_val_pcnt,0)/100), 0);
                  tbl_sel_value(tbl_sel_value.count).req_res_count := round(tbl_sel_group(idg).req_res_count * (nvl(rcd_value.tva_val_pcnt,0)/100), 0);
                  var_tva_mem_count := var_tva_mem_count + tbl_sel_value(tbl_sel_value.count).req_mem_count;
                  var_tva_res_count := var_tva_res_count + tbl_sel_value(tbl_sel_value.count).req_res_count;
               end if;
               if tbl_sel_rule(tbl_sel_rule.count).tru_value = 0 then
                  tbl_sel_rule(tbl_sel_rule.count).tru_value := tbl_sel_value.count;
               end if;
               tbl_sel_rule(tbl_sel_rule.count).end_value := tbl_sel_value.count;

            end loop;
            close csr_value;

            /*-*/
            /* Complete the group rule processing when required
            /*-*/
            if tbl_sel_rule(tbl_sel_rule.count).tru_value != 0 then

               /*-*/
               /* Adjust the value counts when required
               /* **note** 1. the last value contains any rounding
               /*-*/
               if tbl_sel_rule(tbl_sel_rule.count).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                  if var_tva_mem_count != tbl_sel_group(idg).req_mem_count then
                     tbl_sel_value(tbl_sel_rule(tbl_sel_rule.count).end_value).req_mem_count := tbl_sel_value(tbl_sel_rule(tbl_sel_rule.count).end_value).req_mem_count + (tbl_sel_group(idg).req_mem_count - var_tva_mem_count);
                  end if;
                  if var_tva_res_count != tbl_sel_group(idg).req_res_count then
                     tbl_sel_value(tbl_sel_rule(tbl_sel_rule.count).end_value).req_res_count := tbl_sel_value(tbl_sel_rule(tbl_sel_rule.count).end_value).req_res_count + (tbl_sel_group(idg).req_res_count - var_tva_res_count);
                  end if;
               end if;

               /*-*/
               /* Reset the group rule value panel member and reserve counts
               /*-*/
               for idv in tbl_sel_rule(tbl_sel_rule.count).tru_value..tbl_sel_rule(tbl_sel_rule.count).end_value loop
                  update pts_tes_value
                     set tva_req_mem_count = tbl_sel_value(idv).req_mem_count,
                         tva_req_res_count = tbl_sel_value(idv).req_res_count,
                         tva_sel_mem_count = 0,
                         tva_sel_res_count = 0
                   where tva_tes_code = par_tes_code
                     and tva_sel_group = tbl_sel_value(idv).sel_group
                     and tva_tab_code = tbl_sel_value(idv).tab_code
                     and tva_fld_code = tbl_sel_value(idv).fld_code
                     and tva_val_code = tbl_sel_value(idv).val_code;
               end loop;

            end if;

         end loop;
         close csr_rule;

      end loop;

      /*-*/
      /* Delete the existing panel data
      /*-*/
      delete from pts_tes_panel
       where tpa_tes_code = par_tes_code;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_TES_FUNCTION - CLEAR_PANEL - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear_panel;

   /********************************************************/
   /* This procedure performs the select pet panel routine */
   /********************************************************/
   procedure select_pet_panel(par_tes_code in number, par_pan_type in varchar2, par_pet_multiple in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      rcd_pts_tes_panel pts_tes_panel%rowtype;
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
                (to_number(to_char(sysdate,'yyyy'))-nvl(t01.pde_birth_year,0)) as pde_pet_age,
                (select case when count(*)=0 then 0 when count(*)=1 then 1 else 2 end from pts_hou_pet_type where hpt_hou_code=t01.pde_hou_code) as pde_hou_status,
                (select case when count(*)=0 then 0 when count(*)=1 then 1 else 2 end from pts_hou_pet_type where hpt_hou_code=t01.pde_hou_code and hpt_pet_type=t01.pde_pet_type) as pde_hou_count,
                t02.hde_geo_zone
           from pts_pet_definition t01,
                pts_hou_definition t02
          where t01.pde_hou_code = t02.hde_hou_code
            and t01.pde_pet_code in (select sel_code from table(pts_app.pts_gen_function.get_list_data('*PET',var_sel_group)))
            and t01.pde_pet_status = 1
            and t01.pde_pet_code not in (select nvl(tpa_pan_code,-1)
                                           from pts_tes_panel
                                          where tpa_tes_code = par_tes_code)
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

      cursor csr_pet_update is
         select t01.*
           from pts_pet_definition t01
          where t01.pde_pet_code = rcd_panel.pde_pet_code
                for update wait 10;
      rcd_pet_update csr_pet_update%rowtype;

      cursor csr_panel_check is
         select tpa_pan_code
           from pts_tes_panel t01
          where t01.tpa_tes_code = par_tes_code
            and t01.tpa_hou_code = rcd_panel.pde_hou_code;
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

            tbl_sel_data(tbl_sel_data.count+1).tab_code := '*PET_DEF';
            tbl_sel_data(tbl_sel_data.count).fld_code := 6;
            tbl_sel_data(tbl_sel_data.count).val_code := rcd_panel.pde_pet_age;

            tbl_sel_data(tbl_sel_data.count+1).tab_code := '*PET_DEF';
            tbl_sel_data(tbl_sel_data.count).fld_code := 11;
            tbl_sel_data(tbl_sel_data.count).val_code := rcd_panel.pde_pet_age;

            tbl_sel_data(tbl_sel_data.count+1).tab_code := '*PET_DEF';
            tbl_sel_data(tbl_sel_data.count).fld_code := 12;
            tbl_sel_data(tbl_sel_data.count).val_code := rcd_panel.pde_pet_age;

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
            for idr in tbl_sel_group(idg).tru_rule..tbl_sel_group(idg).end_rule loop
               tbl_sel_rule(idr).sel_count := 0;
               if tbl_sel_rule(idr).rul_code != '*SELECT_WHEN_EQUAL_MIX' then
                  tbl_sel_rule(idr).sel_count := 1;
               else
                  for idv in tbl_sel_rule(idr).tru_value..tbl_sel_rule(idr).end_value loop
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
                  for idv in tbl_sel_rule(idr).tru_value..tbl_sel_rule(idr).end_value loop
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
            for idr in tbl_sel_group(idg).tru_rule..tbl_sel_group(idg).end_rule loop
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

               /*-*/
               /* Attempt to lock the pet definition for update
               /* **notes** 1. Must exist
               /*           2. Must be status available
               /*           3. must not be locked
               /*-*/
               if var_pan_selected = true then
                  var_available := true;
                  begin
                     open csr_pet_update;
                     fetch csr_pet_update into rcd_pet_update;
                     if csr_pet_update%notfound then
                        var_available := false;
                     else
                        if rcd_pet_update.pde_pet_status != 1 then
                           var_available := false;
                        end if;
                     end if;
                  exception
                     when others then
                        var_available := false;
                  end;
                  if csr_pet_update%isopen then
                     close csr_pet_update;
                  end if;
                  if var_available = false then
                     var_pan_selected := false;
                  end if;
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
                  for idr in tbl_sel_group(idg).tru_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).tru_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              tbl_sel_value(idv).sel_mem_count := tbl_sel_value(idv).sel_mem_count + 1;
                           end if;
                        end loop;
                     end if;
                  end loop;
               else
                  tbl_sel_group(idg).sel_res_count := tbl_sel_group(idg).sel_res_count + 1;
                  for idr in tbl_sel_group(idg).tru_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).tru_value..tbl_sel_rule(idr).end_value loop
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
               rcd_pts_tes_panel.tpa_tes_code := par_tes_code;
               rcd_pts_tes_panel.tpa_pan_code := rcd_panel.pde_pet_code;
               rcd_pts_tes_panel.tpa_pan_status := upper(par_pan_type);
               rcd_pts_tes_panel.tpa_hou_code := rcd_panel.pde_hou_code;
               rcd_pts_tes_panel.tpa_sel_group := tbl_sel_group(idg).sel_group;
               insert into pts_tes_panel values rcd_pts_tes_panel;

               /*-*/
               /* Update the pet status
               /*-*/
               update pts_pet_definition
                  set pde_pet_status = 2
                where pde_pet_code = rcd_panel.pde_pet_code;

               /*-*/
               /* Update the test counts
               /*-*/
               if upper(par_pan_type) = '*MEMBER' then
                  update pts_tes_group
                     set tgr_sel_mem_count = tgr_sel_mem_count + 1
                   where tgr_tes_code = par_tes_code
                     and tgr_sel_group = tbl_sel_group(idg).sel_group;
                  for idr in tbl_sel_group(idg).tru_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).tru_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              update pts_tes_value
                                 set tva_sel_mem_count = tva_sel_mem_count + 1
                               where tva_tes_code = par_tes_code
                                 and tva_sel_group = tbl_sel_value(idv).sel_group
                                 and tva_tab_code = tbl_sel_value(idv).tab_code
                                 and tva_fld_code = tbl_sel_value(idv).fld_code
                                 and tva_val_code = tbl_sel_value(idv).val_code;
                           end if;
                        end loop;
                     end if;
                  end loop;
               else
                  update pts_tes_group
                     set tgr_sel_res_count = tgr_sel_res_count + 1
                   where tgr_tes_code = par_tes_code
                     and tgr_sel_group = tbl_sel_group(idg).sel_group;
                  for idr in tbl_sel_group(idg).tru_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).tru_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              update pts_tes_value
                                 set tva_sel_res_count = tva_sel_res_count + 1
                               where tva_tes_code = par_tes_code
                                 and tva_sel_group = tbl_sel_value(idv).sel_group
                                 and tva_tab_code = tbl_sel_value(idv).tab_code
                                 and tva_fld_code = tbl_sel_value(idv).fld_code
                                 and tva_val_code = tbl_sel_value(idv).val_code;
                           end if;
                        end loop;
                     end if;
                  end loop;
               end if;

               /*-*/
               /* Commit the database
               /*-*/
               commit;

            else

               /*-*/
               /* Rollback the database to release update lock
               /*-*/
               rollback;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_TES_FUNCTION - SELECT_PET_PANEL - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_pet_panel;

   /**************************************************************/
   /* This procedure performs the select household panel routine */
   /**************************************************************/
   procedure select_hou_panel(par_tes_code in number, par_pan_type in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      rcd_pts_tes_panel pts_tes_panel%rowtype;
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
            and t01.hde_hou_code not in (select nvl(tpa_pan_code,-1)
                                           from pts_tes_panel
                                          where tpa_tes_code = par_tes_code)
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

      cursor csr_hou_update is
         select t01.*
           from pts_hou_definition t01
          where t01.hde_hou_code = rcd_panel.hde_hou_code
                for update wait 10;
      rcd_hou_update csr_hou_update%rowtype;

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
            for idr in tbl_sel_group(idg).tru_rule..tbl_sel_group(idg).end_rule loop
               tbl_sel_rule(idr).sel_count := 0;
               if tbl_sel_rule(idr).rul_code != '*SELECT_WHEN_EQUAL_MIX' then
                  tbl_sel_rule(idr).sel_count := 1;
               else
                  for idv in tbl_sel_rule(idr).tru_value..tbl_sel_rule(idr).end_value loop
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
                  for idv in tbl_sel_rule(idr).tru_value..tbl_sel_rule(idr).end_value loop
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
            for idr in tbl_sel_group(idg).tru_rule..tbl_sel_group(idg).end_rule loop
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
               /* Attempt to lock the household definition for update
               /* **notes** 1. Must exist
               /*           2. Must be status available
               /*           3. must not be locked
               /*-*/
               if var_pan_selected = true then
                  var_available := true;
                  begin
                     open csr_hou_update;
                     fetch csr_hou_update into rcd_hou_update;
                     if csr_hou_update%notfound then
                        var_available := false;
                     else
                        if rcd_hou_update.hde_hou_status != 1 then
                           var_available := false;
                        end if;
                     end if;
                  exception
                     when others then
                        var_available := false;
                  end;
                  if csr_hou_update%isopen then
                     close csr_hou_update;
                  end if;
                  if var_available = false then
                     var_pan_selected := false;
                  end if;
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
                  for idr in tbl_sel_group(idg).tru_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).tru_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              tbl_sel_value(idv).sel_mem_count := tbl_sel_value(idv).sel_mem_count + 1;
                           end if;
                        end loop;
                     end if;
                  end loop;
               else
                  tbl_sel_group(idg).sel_res_count := tbl_sel_group(idg).sel_res_count + 1;
                  for idr in tbl_sel_group(idg).tru_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).tru_value..tbl_sel_rule(idr).end_value loop
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
               rcd_pts_tes_panel.tpa_tes_code := par_tes_code;
               rcd_pts_tes_panel.tpa_pan_code := rcd_panel.hde_hou_code;
               rcd_pts_tes_panel.tpa_pan_status := upper(par_pan_type);
               rcd_pts_tes_panel.tpa_hou_code := rcd_panel.hde_hou_code;
               rcd_pts_tes_panel.tpa_sel_group := tbl_sel_group(idg).sel_group;
               insert into pts_tes_panel values rcd_pts_tes_panel;

               /*-*/
               /* Update the household status
               /*-*/
               update pts_hou_definition
                  set hde_hou_status = 2
                where hde_hou_code = rcd_panel.hde_hou_code;

               /*-*/
               /* Update the test counts
               /*-*/
               if upper(par_pan_type) = '*MEMBER' then
                  update pts_tes_group
                     set tgr_sel_mem_count = tgr_sel_mem_count + 1
                   where tgr_tes_code = par_tes_code
                     and tgr_sel_group = tbl_sel_group(idg).sel_group;
                  for idr in tbl_sel_group(idg).tru_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).tru_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              update pts_tes_value
                                 set tva_sel_mem_count = tva_sel_mem_count + 1
                               where tva_tes_code = par_tes_code
                                 and tva_sel_group = tbl_sel_value(idv).sel_group
                                 and tva_tab_code = tbl_sel_value(idv).tab_code
                                 and tva_fld_code = tbl_sel_value(idv).fld_code
                                 and tva_val_code = tbl_sel_value(idv).val_code;
                           end if;
                        end loop;
                     end if;
                  end loop;
               else
                  update pts_tes_group
                     set tgr_sel_res_count = tgr_sel_res_count + 1
                   where tgr_tes_code = par_tes_code
                     and tgr_sel_group = tbl_sel_group(idg).sel_group;
                  for idr in tbl_sel_group(idg).tru_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).tru_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              update pts_tes_value
                                 set tva_sel_res_count = tva_sel_res_count + 1
                               where tva_tes_code = par_tes_code
                                 and tva_sel_group = tbl_sel_value(idv).sel_group
                                 and tva_tab_code = tbl_sel_value(idv).tab_code
                                 and tva_fld_code = tbl_sel_value(idv).fld_code
                                 and tva_val_code = tbl_sel_value(idv).val_code;
                           end if;
                        end loop;
                     end if;
                  end loop;
               end if;

               /*-*/
               /* Commit the database
               /*-*/
               commit;

            else

               /*-*/
               /* Rollback the database to release update lock
               /*-*/
               rollback;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_TES_FUNCTION - SELECT_HOU_PANEL - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_hou_panel;

end pts_tes_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_tes_function for pts_app.pts_tes_function;
grant execute on pts_app.pts_tes_function to public;

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
    Product Testing System - Pet Test Function

    This package contain the procedures and functions for product test.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created
    2010/10   Steve Gregan   Modified to allow more allocation days than samples
                             Modified to enter response data by market and alias codes

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function retrieve_list return pts_xml_type pipelined;
   function retrieve_data return pts_xml_type pipelined;
   procedure update_data(par_user in varchar2);
   function retrieve_preview return pts_xml_type pipelined;
   function retrieve_question return pts_xml_type pipelined;
   function select_question return pts_xml_type pipelined;
   procedure update_question(par_user in varchar2);
   function retrieve_sample return pts_xml_type pipelined;
   function select_sample return pts_xml_type pipelined;
   procedure update_sample(par_user in varchar2);
   function retrieve_panel return pts_xml_type pipelined;
   function retrieve_template return pts_xml_type pipelined;
   procedure update_panel(par_user in varchar2);
   function report_panel(par_tes_code in number) return pts_xls_type pipelined;
   function retrieve_allocation return pts_xml_type pipelined;
   procedure update_allocation(par_user in varchar2);
   function report_allocation(par_tes_code in number) return pts_xls_type pipelined;
   function retrieve_release return pts_xml_type pipelined;
   procedure update_release(par_user in varchar2);
   function report_questionnaire(par_tes_code in number) return pts_xls_type pipelined;
   function report_selection(par_tes_code in number) return pts_xls_type pipelined;
   function retrieve_report_fields return pts_xml_type pipelined;
   function report_results(par_tes_code in number) return pts_xls_type pipelined;
   function response_load return pts_xml_type pipelined;
   function response_list return pts_xml_type pipelined;
   function response_retrieve return pts_xml_type pipelined;
   procedure update_response;

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
   procedure clear_panel(par_tes_code in number, par_sel_type in varchar2, par_req_mem_count in number, par_req_res_count in number);
   procedure select_panel(par_tes_code in number, par_sel_type in varchar2, par_pan_type in varchar2, par_pet_multiple in varchar2, par_req_mem_count in number, par_req_res_count in number);

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
                nvl((select sva_val_text from pts_sys_value where sva_tab_code = '*TES_DEF' and sva_fld_code = 9 and sva_val_code = t01.tde_tes_status),'*UNKNOWN') as tde_tes_status,
                t01.tde_tes_req_name as tde_tes_req_name,
                substr(t01.tde_tes_aim,1,120) as tde_tes_aim
           from pts_tes_definition t01
          where t01.tde_tes_code in (select sel_code from table(pts_app.pts_gen_function.get_list_data('*TEST',null)))
            and t01.tde_tes_code > (select sel_code from table(pts_app.pts_gen_function.get_list_from))
          order by t01.tde_tes_code desc;
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
      pipe row(pts_xml_object('<LSTCTL COLCNT="4" HED1="'||pts_to_xml('Test')||'" HED2="'||pts_to_xml('Status')||'" HED3="'||pts_to_xml('Requestor')||'" HED4="'||pts_to_xml('Aim')||'"/>'));

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
            pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.tde_tes_code)||'" SELTXT="'||pts_to_xml('('||to_char(rcd_list.tde_tes_code)||') '||rcd_list.tde_tes_title)||'" COL1="'||pts_to_xml('('||to_char(rcd_list.tde_tes_code)||') '||rcd_list.tde_tes_title)||'" COL2="'||pts_to_xml(rcd_list.tde_tes_status)||'" COL3="'||pts_to_xml(rcd_list.tde_tes_req_name)||'" COL4="'||pts_to_xml(rcd_list.tde_tes_aim)||'"/>'));
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
      var_tes_code number;
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                t02.tty_typ_target
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_company is
         select to_char(t01.cde_com_code) as val_code,
                '('||to_char(t01.cde_com_code)||') '||t01.cde_com_name as val_text
           from pts_com_definition t01
          order by val_code asc;
      rcd_company csr_company%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*TES_DEF',9)) t01
          where var_action = '*UPDTES' or val_code = 1;
      rcd_sta_code csr_sta_code%rowtype;

      cursor csr_glo_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*TES_DEF',5)) t01;
      rcd_glo_code csr_glo_code%rowtype;

      cursor csr_tes_type is
         select t01.*
           from table(pts_app.pts_gen_function.list_tes_type) t01
          where t01.tty_status = 1
            and t01.tty_target = 1;
      rcd_tes_type csr_tes_type%rowtype;

      cursor csr_keyword is
         select t01.*
           from pts_tes_keyword t01
          where t01.tke_tes_code = var_tes_code
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
      if var_action != '*UPDTES' and var_action != '*CRTTES' and var_action != '*CPYTES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCDE'));
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the existing test when required
      /*-*/
      if var_action = '*UPDTES' or var_action = '*CPYTES' then
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
         if rcd_retrieve.tty_typ_target != 1 then
            pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') target must be *PET - update not allowed');
         end if;
         if pts_gen_function.get_mesg_count != 0 then
            return;
         end if;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the company XML
      /*-*/
      open csr_company;
      loop
         fetch csr_company into rcd_company;
         if csr_company%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<COM_LIST VALCDE="'||rcd_company.val_code||'" VALTXT="'||pts_to_xml(rcd_company.val_text)||'"/>'));
      end loop;
      close csr_company;

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
      /* Pipe the test XML
      /*-*/
      if var_action = '*UPDTES' then
         pipe row(pts_xml_object('<TEST TESCDE="'||to_char(rcd_retrieve.tde_tes_code)||'"'));
         pipe row(pts_xml_object(' TESTIT="'||pts_to_xml(rcd_retrieve.tde_tes_title)||'"'));
         pipe row(pts_xml_object(' TESCOM="'||to_char(rcd_retrieve.tde_com_code)||'"'));
         pipe row(pts_xml_object(' TESSTA="'||to_char(rcd_retrieve.tde_tes_status)||'"'));
         pipe row(pts_xml_object(' TESGLO="'||to_char(rcd_retrieve.tde_glo_status)||'"'));
         pipe row(pts_xml_object(' TESTYP="'||to_char(rcd_retrieve.tde_tes_type)||'"'));
         pipe row(pts_xml_object(' REQNAM="'||pts_to_xml(rcd_retrieve.tde_tes_req_name)||'"'));
         pipe row(pts_xml_object(' REQMID="'||pts_to_xml(rcd_retrieve.tde_tes_req_miden)||'"'));
         pipe row(pts_xml_object(' AIMTXT="'||pts_to_xml(rcd_retrieve.tde_tes_aim)||'"'));
         pipe row(pts_xml_object(' REATXT="'||pts_to_xml(rcd_retrieve.tde_tes_reason)||'"'));
         pipe row(pts_xml_object(' PRETXT="'||pts_to_xml(rcd_retrieve.tde_tes_prediction)||'"'));
         pipe row(pts_xml_object(' COMTXT="'||pts_to_xml(rcd_retrieve.tde_tes_comment)||'"'));
         pipe row(pts_xml_object(' STRDAT="'||to_char(rcd_retrieve.tde_tes_str_date,'dd/mm/yyyy')||'"'));
         pipe row(pts_xml_object(' FLDWEK="'||to_char(rcd_retrieve.tde_tes_fld_week)||'"'));
         pipe row(pts_xml_object(' MEALEN="'||to_char(rcd_retrieve.tde_tes_len_meal)||'"'));
         pipe row(pts_xml_object(' MAXTEM="'||to_char(rcd_retrieve.tde_tes_max_temp)||'"'));
         pipe row(pts_xml_object(' DAYCNT="'||to_char(rcd_retrieve.tde_tes_day_count)||'"/>'));
      elsif var_action = '*CPYTES' then
         pipe row(pts_xml_object('<TEST TESCDE="*NEW"'));
         pipe row(pts_xml_object(' TESTIT="'||pts_to_xml(rcd_retrieve.tde_tes_title)||'"'));
         pipe row(pts_xml_object(' TESCOM="'||to_char(rcd_retrieve.tde_com_code)||'"'));
         pipe row(pts_xml_object(' TESSTA="1"'));
         pipe row(pts_xml_object(' TESGLO="2"'));
         pipe row(pts_xml_object(' TESTYP="'||to_char(rcd_retrieve.tde_tes_type)||'"'));
         pipe row(pts_xml_object(' REQNAM="'||pts_to_xml(rcd_retrieve.tde_tes_req_name)||'"'));
         pipe row(pts_xml_object(' REQMID="'||pts_to_xml(rcd_retrieve.tde_tes_req_miden)||'"'));
         pipe row(pts_xml_object(' AIMTXT="'||pts_to_xml(rcd_retrieve.tde_tes_aim)||'"'));
         pipe row(pts_xml_object(' REATXT="'||pts_to_xml(rcd_retrieve.tde_tes_reason)||'"'));
         pipe row(pts_xml_object(' PRETXT="'||pts_to_xml(rcd_retrieve.tde_tes_prediction)||'"'));
         pipe row(pts_xml_object(' COMTXT="'||pts_to_xml(rcd_retrieve.tde_tes_comment)||'"'));
         pipe row(pts_xml_object(' STRDAT="'||to_char(rcd_retrieve.tde_tes_str_date,'dd/mm/yyyy')||'"'));
         pipe row(pts_xml_object(' FLDWEK="'||to_char(rcd_retrieve.tde_tes_fld_week)||'"'));
         pipe row(pts_xml_object(' MEALEN="'||to_char(rcd_retrieve.tde_tes_len_meal)||'"'));
         pipe row(pts_xml_object(' MAXTEM="'||to_char(rcd_retrieve.tde_tes_max_temp)||'"'));
         pipe row(pts_xml_object(' DAYCNT="'||to_char(rcd_retrieve.tde_tes_day_count)||'"/>'));
      elsif var_action = '*CRTTES' then
         pipe row(pts_xml_object('<TEST TESCDE="*NEW"'));
         pipe row(pts_xml_object(' TESTIT=""'));
         pipe row(pts_xml_object(' TESCOM="1"'));
         pipe row(pts_xml_object(' TESSTA="1"'));
         pipe row(pts_xml_object(' TESGLO="2"'));
         pipe row(pts_xml_object(' TESTYP="1"'));
         pipe row(pts_xml_object(' REQNAM=""'));
         pipe row(pts_xml_object(' REQMID=""'));
         pipe row(pts_xml_object(' AIMTXT=""'));
         pipe row(pts_xml_object(' REATXT=""'));
         pipe row(pts_xml_object(' PRETXT=""'));
         pipe row(pts_xml_object(' COMTXT=""'));
         pipe row(pts_xml_object(' STRDAT=""'));
         pipe row(pts_xml_object(' FLDWEK=""'));
         pipe row(pts_xml_object(' MEALEN=""'));
         pipe row(pts_xml_object(' MAXTEM=""'));
         pipe row(pts_xml_object(' DAYCNT=""/>'));
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
            pipe row(pts_xml_object('<KEYWORD KEYWRD ="'||pts_to_xml(rcd_keyword.tke_key_word)||'"/>'));
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
      var_locked boolean;
      var_question boolean;
      var_sample boolean;
      var_panel boolean;
      var_allocation boolean;
      var_cpy_code number;
      rcd_pts_tes_definition pts_tes_definition%rowtype;
      rcd_pts_tes_keyword pts_tes_keyword%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = rcd_pts_tes_definition.tde_tes_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_copy is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = var_cpy_code;
      rcd_copy csr_copy%rowtype;

      cursor csr_company is
         select t01.*
           from pts_com_definition t01
          where t01.cde_com_code = rcd_pts_tes_definition.tde_com_code;
      rcd_company csr_company%rowtype;

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
           from pts_tes_type t01
          where t01.tty_tes_type = rcd_pts_tes_definition.tde_tes_type;
      rcd_tes_type csr_tes_type%rowtype;

      cursor csr_question is
         select t01.*
           from pts_tes_question t01
          where t01.tqu_tes_code = rcd_pts_tes_definition.tde_tes_code;
      rcd_question csr_question%rowtype;

      cursor csr_sample is
         select t01.*
           from pts_tes_sample t01
          where t01.tsa_tes_code = rcd_pts_tes_definition.tde_tes_code;
      rcd_sample csr_sample%rowtype;

      cursor csr_panel is
         select t01.*
           from pts_tes_panel t01
          where t01.tpa_tes_code = rcd_pts_tes_definition.tde_tes_code;
      rcd_panel csr_panel%rowtype;

      cursor csr_allocation is
         select t01.*
           from pts_tes_allocation t01
          where t01.tal_tes_code = rcd_pts_tes_definition.tde_tes_code;
      rcd_allocation csr_allocation%rowtype;

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
      var_cpy_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@CPYCDE'));
      rcd_pts_tes_definition.tde_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCDE'));
      rcd_pts_tes_definition.tde_tes_title := upper(pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@TESTIT')));
      rcd_pts_tes_definition.tde_com_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCOM'));
      rcd_pts_tes_definition.tde_tes_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESSTA'));
      rcd_pts_tes_definition.tde_glo_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESGLO'));
      rcd_pts_tes_definition.tde_tes_type := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESTYP'));
      rcd_pts_tes_definition.tde_upd_user := upper(par_user);
      rcd_pts_tes_definition.tde_upd_date := sysdate;
      rcd_pts_tes_definition.tde_tes_req_name := upper(pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@REQNAM')));
      rcd_pts_tes_definition.tde_tes_req_miden := upper(pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@REQMID')));
      rcd_pts_tes_definition.tde_tes_aim := upper(pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@AIMTXT')));
      rcd_pts_tes_definition.tde_tes_reason := upper(pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@REATXT')));
      rcd_pts_tes_definition.tde_tes_prediction := upper(pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@PRETXT')));
      rcd_pts_tes_definition.tde_tes_comment := upper(pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@COMTXT')));
      rcd_pts_tes_definition.tde_tes_str_date := pts_to_date(xslProcessor.valueOf(obj_pts_request,'@STRDAT'),'dd/mm/yyyy');
      rcd_pts_tes_definition.tde_tes_fld_week := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@FLDWEK'));
      rcd_pts_tes_definition.tde_tes_len_meal := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@MEALEN'));
      rcd_pts_tes_definition.tde_tes_max_temp := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@MAXTEM'));
      rcd_pts_tes_definition.tde_tes_day_count := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@DAYCNT'));
      rcd_pts_tes_definition.tde_tes_sam_count := 0;
      rcd_pts_tes_definition.tde_req_mem_count := 0;
      rcd_pts_tes_definition.tde_req_res_count := 0;
      rcd_pts_tes_definition.tde_hou_pet_multi := '0';
      rcd_pts_tes_definition.tde_wgt_que_calc := '0';
      rcd_pts_tes_definition.tde_wgt_que_bowl := null;
      rcd_pts_tes_definition.tde_wgt_que_offer := null;
      rcd_pts_tes_definition.tde_wgt_que_remain := null;
      if rcd_pts_tes_definition.tde_tes_code is null and not(xslProcessor.valueOf(obj_pts_request,'@TESCDE') = '*NEW') then
         pts_gen_function.add_mesg_data('Test code ('||xslProcessor.valueOf(obj_pts_request,'@TESCDE')||') must be a number');
      end if;
      if rcd_pts_tes_definition.tde_com_code is null and not(xslProcessor.valueOf(obj_pts_request,'@TESCOM') is null) then
         pts_gen_function.add_mesg_data('Company code ('||xslProcessor.valueOf(obj_pts_request,'@TESCOM')||') must be a number');
      end if;
      if rcd_pts_tes_definition.tde_tes_status is null and not(xslProcessor.valueOf(obj_pts_request,'@TESSTA') is null) then
         pts_gen_function.add_mesg_data('Test status ('||xslProcessor.valueOf(obj_pts_request,'@TESSTA')||') must be a number');
      end if;
      if rcd_pts_tes_definition.tde_glo_status is null and not(xslProcessor.valueOf(obj_pts_request,'@TESGLO') is null) then
         pts_gen_function.add_mesg_data('Test GloPal status ('||xslProcessor.valueOf(obj_pts_request,'@TESGLO')||') must be a number');
      end if;
      if rcd_pts_tes_definition.tde_tes_type is null and not(xslProcessor.valueOf(obj_pts_request,'@TESTYP') is null) then
         pts_gen_function.add_mesg_data('Test type ('||xslProcessor.valueOf(obj_pts_request,'@TESTYP')||') must be a number');
      end if;
      if rcd_pts_tes_definition.tde_tes_str_date is null and not(xslProcessor.valueOf(obj_pts_request,'@STRDAT') is null) then
         pts_gen_function.add_mesg_data('Test start date ('||xslProcessor.valueOf(obj_pts_request,'@STRDAT')||') must be a date in format DD/MM/YYYY');
      end if;
      if rcd_pts_tes_definition.tde_tes_fld_week is null and not(xslProcessor.valueOf(obj_pts_request,'@FLDWEK') is null) then
         pts_gen_function.add_mesg_data('Test field week ('||xslProcessor.valueOf(obj_pts_request,'@FLDWEK')||') must be a number in format YYYYWW');
      end if;
      if rcd_pts_tes_definition.tde_tes_len_meal is null and not(xslProcessor.valueOf(obj_pts_request,'@MEALEN') is null) then
         pts_gen_function.add_mesg_data('Test meal length ('||xslProcessor.valueOf(obj_pts_request,'@MEALEN')||') must be a number');
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
      /* Retrieve and lock the existing test when required
      /*-*/
      var_locked := false;
      begin
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_locked := true;
         end if;
         close csr_retrieve;
      exception
         when others then
            pts_gen_function.add_mesg_data('Test ('||to_char(rcd_pts_tes_definition.tde_tes_code)||') is currently locked');
      end;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the test question
      /*-*/
      var_question := false;
      open csr_question;
      fetch csr_question into rcd_question;
      if csr_question%found then
         var_question := true;
      end if;
      close csr_question;

      /*-*/
      /* Retrieve the test sample
      /*-*/
      var_sample := false;
      open csr_sample;
      fetch csr_sample into rcd_sample;
      if csr_sample%found then
         var_sample := true;
      end if;
      close csr_sample;

      /*-*/
      /* Retrieve the test panel
      /*-*/
      var_panel := false;
      open csr_panel;
      fetch csr_panel into rcd_panel;
      if csr_panel%found then
         var_panel := true;
      end if;
      close csr_panel;

      /*-*/
      /* Retrieve the test allocation
      /*-*/
      var_allocation := false;
      open csr_allocation;
      fetch csr_allocation into rcd_allocation;
      if csr_allocation%found then
         var_allocation := true;
      end if;
      close csr_allocation;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_tes_definition.tde_tes_title is null then
         pts_gen_function.add_mesg_data('Test title must be supplied');
      end if;
      if rcd_pts_tes_definition.tde_com_code is null then
         pts_gen_function.add_mesg_data('Test company code must be supplied');
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
      if rcd_pts_tes_definition.tde_upd_user is null then
         pts_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if rcd_pts_tes_definition.tde_tes_day_count is null or rcd_pts_tes_definition.tde_tes_day_count <= 0 then
         pts_gen_function.add_mesg_data('Day count must be supplied and greater than zero');
      end if;
      open csr_company;
      fetch csr_company into rcd_company;
      if csr_company%notfound then
         pts_gen_function.add_mesg_data('Company ('||to_char(rcd_pts_tes_definition.tde_com_code)||') does not exist');
      end if;
      close csr_company;
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
         if rcd_tes_type.tty_typ_status != 1 then
            pts_gen_function.add_mesg_data('Test type ('||to_char(rcd_pts_tes_definition.tde_tes_type)||') is not active');
         end if;
         if rcd_tes_type.tty_typ_target != 1 then
            pts_gen_function.add_mesg_data('Test type ('||to_char(rcd_pts_tes_definition.tde_tes_type)||') target must be *PET');
         end if;
         rcd_pts_tes_definition.tde_tes_sam_count := rcd_tes_type.tty_sam_count;
      end if;
      close csr_tes_type;
      if var_locked = true then
         if rcd_retrieve.tde_tes_status = 1 and (rcd_pts_tes_definition.tde_tes_status != 1 and rcd_pts_tes_definition.tde_tes_status != 2 and rcd_pts_tes_definition.tde_tes_status != 9) then
            pts_gen_function.add_mesg_data('Current status is Raised - new status must be Raised, Allocation Completed or Cancelled');
         end if;
         if rcd_retrieve.tde_tes_status = 2 and (rcd_pts_tes_definition.tde_tes_status != 1 and rcd_pts_tes_definition.tde_tes_status != 2 and rcd_pts_tes_definition.tde_tes_status != 4 and rcd_pts_tes_definition.tde_tes_status != 9) then
            pts_gen_function.add_mesg_data('Current status is Allocation Completed - new status must be Raised, Allocation Completed, Closed or Cancelled');
         end if;
         if rcd_retrieve.tde_tes_status = 3 and (rcd_pts_tes_definition.tde_tes_status != 1 and rcd_pts_tes_definition.tde_tes_status != 3 and rcd_pts_tes_definition.tde_tes_status != 4 and rcd_pts_tes_definition.tde_tes_status != 9) then
            pts_gen_function.add_mesg_data('Current status is Results Entered - new status must be Raised, Results Entered, Closed or Cancelled');
         end if;
         if rcd_retrieve.tde_tes_status = 4 and (rcd_pts_tes_definition.tde_tes_status != 2 and rcd_pts_tes_definition.tde_tes_status != 4) then
            pts_gen_function.add_mesg_data('Current status is Closed - new status must be Allocation Completed or Closed');
         end if;
         if rcd_retrieve.tde_tes_status = 9 then
            pts_gen_function.add_mesg_data('Current status is Cancelled - update not allowed');
         end if;
         if rcd_pts_tes_definition.tde_tes_status = 2 or rcd_pts_tes_definition.tde_tes_status = 3 or rcd_pts_tes_definition.tde_tes_status = 4 then
            if var_question = false then
                pts_gen_function.add_mesg_data('Test status is Allocation Completed, Results Entered or Closed and no questions defined - update not allowed');
            end if;
            if var_sample = false then
                pts_gen_function.add_mesg_data('Test status is Allocation Completed, Results Entered or Closed and no samples defined - update not allowed');
            end if;
            if var_panel = false then
                pts_gen_function.add_mesg_data('Test status is Allocation Completed, Results Entered or Closed and no panel selected - update not allowed');
            end if;
            if var_allocation = false then
                pts_gen_function.add_mesg_data('Test status is Allocation Completed, Results Entered or Closed and no allocation - update not allowed');
            end if;
         end if;
         if rcd_pts_tes_definition.tde_tes_status = 2 or rcd_pts_tes_definition.tde_tes_status = 3 or rcd_pts_tes_definition.tde_tes_status = 4 then
            if rcd_retrieve.tde_tes_type != rcd_pts_tes_definition.tde_tes_type then
                pts_gen_function.add_mesg_data('Test status is Allocation Completed, Results Entered or Closed and test type changed - update not allowed');
            end if;
            if rcd_retrieve.tde_tes_day_count != rcd_pts_tes_definition.tde_tes_day_count then
                pts_gen_function.add_mesg_data('Test status is Allocation Completed, Results Entered or Closed and number of days changed - update not allowed');
            end if;
         end if;
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Copy the test weight data when required
      /*-*/
      if not(var_cpy_code is null) then
         open csr_copy;
         fetch csr_copy into rcd_copy;
         if csr_copy%found then
            rcd_pts_tes_definition.tde_wgt_que_calc := rcd_copy.tde_wgt_que_calc;
            rcd_pts_tes_definition.tde_wgt_que_bowl := rcd_copy.tde_wgt_que_bowl;
            rcd_pts_tes_definition.tde_wgt_que_offer := rcd_copy.tde_wgt_que_offer;
            rcd_pts_tes_definition.tde_wgt_que_remain := rcd_copy.tde_wgt_que_remain;
         end if;
         close csr_copy;
      end if;

      /*-*/
      /* Process the test definition
      /*-*/
      if var_locked = true then

         /*-*/
         /* Update the test
         /*-*/
         var_confirm := 'updated';
         update pts_tes_definition
            set tde_tes_title = rcd_pts_tes_definition.tde_tes_title,
                tde_com_code = rcd_pts_tes_definition.tde_com_code,
                tde_tes_status = rcd_pts_tes_definition.tde_tes_status,
                tde_glo_status = rcd_pts_tes_definition.tde_glo_status,
                tde_tes_type = rcd_pts_tes_definition.tde_tes_type,
                tde_upd_user = rcd_pts_tes_definition.tde_upd_user,
                tde_upd_date = rcd_pts_tes_definition.tde_upd_date,
                tde_tes_req_name = rcd_pts_tes_definition.tde_tes_req_name,
                tde_tes_req_miden = rcd_pts_tes_definition.tde_tes_req_miden,
                tde_tes_aim = rcd_pts_tes_definition.tde_tes_aim,
                tde_tes_reason = rcd_pts_tes_definition.tde_tes_reason,
                tde_tes_prediction = rcd_pts_tes_definition.tde_tes_prediction,
                tde_tes_comment = rcd_pts_tes_definition.tde_tes_comment,
                tde_tes_str_date = rcd_pts_tes_definition.tde_tes_str_date,
                tde_tes_fld_week = rcd_pts_tes_definition.tde_tes_fld_week,
                tde_tes_len_meal = rcd_pts_tes_definition.tde_tes_len_meal,
                tde_tes_max_temp = rcd_pts_tes_definition.tde_tes_max_temp,
                tde_tes_day_count = rcd_pts_tes_definition.tde_tes_day_count,
                tde_tes_sam_count = rcd_pts_tes_definition.tde_tes_sam_count
          where tde_tes_code = rcd_pts_tes_definition.tde_tes_code;
         delete from pts_tes_keyword where tke_tes_code = rcd_pts_tes_definition.tde_tes_code;

         /*-*/
         /* Remove response data when required
         /*-*/
         if rcd_pts_tes_definition.tde_tes_status = 1 or
            rcd_retrieve.tde_tes_type != rcd_pts_tes_definition.tde_tes_type then
            delete from pts_tes_response where tre_tes_code = rcd_pts_tes_definition.tde_tes_code;
         end if;

         /*-*/
         /* Remove allocation data when required
         /*-*/
         if rcd_retrieve.tde_tes_type != rcd_pts_tes_definition.tde_tes_type then
            delete from pts_tes_allocation where tal_tes_code = rcd_pts_tes_definition.tde_tes_code;
         end if;

         /*-*/
         /* Remove excess question data when required
         /*-*/
         if rcd_retrieve.tde_tes_day_count > rcd_pts_tes_definition.tde_tes_day_count then
            delete from pts_tes_question where tqu_tes_code = rcd_pts_tes_definition.tde_tes_code and tqu_day_code > rcd_pts_tes_definition.tde_tes_day_count;
         end if;

         /*-*/
         /* Release any test panel members when required
         /*-*/
         if rcd_pts_tes_definition.tde_tes_status = 4 or rcd_pts_tes_definition.tde_tes_status = 9 then
            update pts_pet_definition
               set pde_pet_status = decode(pde_pet_status,2,1,5,3,1),
                   pde_tes_code = null
             where pde_tes_code = rcd_pts_tes_definition.tde_tes_code;
            update pts_hou_definition
               set hde_hou_status = decode(hde_hou_status,2,1,5,3,1),
                   hde_tes_code = null
             where hde_tes_code = rcd_pts_tes_definition.tde_tes_code;
         end if;

      else

         /*-*/
         /* Create the test
         /*-*/
         var_confirm := 'created';
         select pts_tes_sequence.nextval into rcd_pts_tes_definition.tde_tes_code from dual;
         insert into pts_tes_definition values rcd_pts_tes_definition;

      end if;

      /*-*/
      /* Retrieve and insert the keyword data
      /*-*/
      obj_key_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/KEYWORD');
      for idx in 0..xmlDom.getLength(obj_key_list)-1 loop
         obj_key_node := xmlDom.item(obj_key_list,idx);
         rcd_pts_tes_keyword.tke_tes_code := rcd_pts_tes_definition.tde_tes_code;
         rcd_pts_tes_keyword.tke_key_word := upper(pts_from_xml(xslProcessor.valueOf(obj_key_node,'@KEYWRD')));
         insert into pts_tes_keyword values rcd_pts_tes_keyword;
      end loop;

      /*-*/
      /* Copy the test data when required
      /*-*/
      if not(var_cpy_code is null) and var_confirm = 'created' then
         insert into pts_tes_question
            select rcd_pts_tes_definition.tde_tes_code,
                   tqu_day_code,
                   tqu_que_code,
                   tqu_que_type,
                   tqu_dsp_seqn
              from pts_tes_question
             where tqu_tes_code = var_cpy_code
               and tqu_day_code <= rcd_pts_tes_definition.tde_tes_day_count;
         insert into pts_tes_sample
            select rcd_pts_tes_definition.tde_tes_code,
                   tsa_sam_code,
                   tsa_rpt_code,
                   tsa_mkt_code,
                   tsa_mkt_acde,
                   tsa_sam_iden
              from pts_tes_sample
             where tsa_tes_code = var_cpy_code;
         insert into pts_tes_feeding
            select rcd_pts_tes_definition.tde_tes_code,
                   tfe_sam_code,
                   tfe_pet_size,
                   tfe_fed_qnty,
                   tfe_fed_text
              from pts_tes_feeding
             where tfe_tes_code = var_cpy_code;
         insert into pts_tes_group
            select rcd_pts_tes_definition.tde_tes_code,
                   tgr_sel_group,
                   tgr_sel_text,
                   tgr_sel_pcnt,
                   0,
                   0,
                   0,
                   0
              from pts_tes_group
             where tgr_tes_code = var_cpy_code;
         insert into pts_tes_rule
            select rcd_pts_tes_definition.tde_tes_code,
                   tru_sel_group,
                   tru_tab_code,
                   tru_fld_code,
                   tru_rul_code
              from pts_tes_rule
             where tru_tes_code = var_cpy_code;
         insert into pts_tes_value
            select rcd_pts_tes_definition.tde_tes_code,
                   tva_sel_group,
                   tva_tab_code,
                   tva_fld_code,
                   tva_val_code,
                   tva_val_text,
                   tva_val_pcnt,
                   0,
                   0,
                   0,
                   0
              from pts_tes_value
             where tva_tes_code = var_cpy_code;
      end if;

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

   /********************************************************/
   /* This procedure performs the retrieve preview routine */
   /********************************************************/
   function retrieve_preview return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tes_code number;
      var_day_code number;
      var_found boolean;
      var_status varchar2(128);
      var_question varchar2(1);
      var_sample varchar2(1);
      var_panel varchar2(1);
      var_allocation varchar2(1);
      var_response varchar2(1);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                t02.tty_typ_target
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_question is
         select t01.*
           from pts_tes_question t01
          where t01.tqu_tes_code = rcd_retrieve.tde_tes_code;
      rcd_question csr_question%rowtype;

      cursor csr_sample is
         select t01.*
           from pts_tes_sample t01
          where t01.tsa_tes_code = rcd_retrieve.tde_tes_code;
      rcd_sample csr_sample%rowtype;

      cursor csr_panel is
         select t01.*
           from pts_tes_panel t01
          where t01.tpa_tes_code = rcd_retrieve.tde_tes_code;
      rcd_panel csr_panel%rowtype;

      cursor csr_allocation is
         select t01.*
           from pts_tes_allocation t01
          where t01.tal_tes_code = rcd_retrieve.tde_tes_code;
      rcd_allocation csr_allocation%rowtype;

      cursor csr_response is
         select t01.*
           from pts_tes_response t01
          where t01.tre_tes_code = rcd_retrieve.tde_tes_code;
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
      if var_action != '*RTVPVW' then
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
      if rcd_retrieve.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') target must be *PET - question preview not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_status := ' - (*UNKNOWN)';
      if rcd_retrieve.tde_tes_status = 1 then
         var_status := ' - (Raised)';
      elsif rcd_retrieve.tde_tes_status = 2 then
         var_status := ' - (Allocation Completed)';
      elsif rcd_retrieve.tde_tes_status = 3 then
         var_status := ' - (Results Entered)';
      elsif rcd_retrieve.tde_tes_status = 4 then
         var_status := ' - (Closed)';
      elsif rcd_retrieve.tde_tes_status = 9 then
         var_status := ' - (Cancelled)';
      end if;

      /*-*/
      /* Retrieve the test question
      /*-*/
      var_question := '0';
      open csr_question;
      fetch csr_question into rcd_question;
      if csr_question%found then
         var_question := '1';
      end if;
      close csr_question;

      /*-*/
      /* Retrieve the test sample
      /*-*/
      var_sample := '0';
      open csr_sample;
      fetch csr_sample into rcd_sample;
      if csr_sample%found then
         var_sample := '1';
      end if;
      close csr_sample;

      /*-*/
      /* Retrieve the test panel
      /*-*/
      var_panel := '0';
      open csr_panel;
      fetch csr_panel into rcd_panel;
      if csr_panel%found then
         var_panel := '1';
      end if;
      close csr_panel;

      /*-*/
      /* Retrieve the test allocation
      /*-*/
      var_allocation := '0';
      open csr_allocation;
      fetch csr_allocation into rcd_allocation;
      if csr_allocation%found then
         var_allocation := '1';
      end if;
      close csr_allocation;

      /*-*/
      /* Retrieve the test response
      /*-*/
      var_response := '0';
      open csr_response;
      fetch csr_response into rcd_response;
      if csr_response%found then
         var_response := '1';
      end if;
      close csr_response;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test xml
      /*-*/
      pipe row(pts_xml_object('<TEST TESTXT="('||to_char(rcd_retrieve.tde_tes_code)||') '||pts_to_xml(rcd_retrieve.tde_tes_title)||pts_to_xml(var_status)||'" QUEDTA="'||var_question||'" SAMDTA="'||var_sample||'" PANDTA="'||var_panel||'" ALCDTA="'||var_allocation||'" RESDTA="'||var_response||'"/>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RETRIEVE_PREVIEW - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_preview;

   /*********************************************************/
   /* This procedure performs the retrieve question routine */
   /*********************************************************/
   function retrieve_question return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tes_code number;
      var_day_code number;
      var_found boolean;
      var_status varchar2(128);
      var_response varchar2(1);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                t02.tty_typ_target
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_question is
         select t01.*,
                t02.qde_que_text
           from pts_tes_question t01,
                pts_que_definition t02
          where t01.tqu_que_code = t02.qde_que_code
            and t01.tqu_tes_code = var_tes_code
            and t01.tqu_day_code = var_day_code
          order by t01.tqu_dsp_seqn asc;
      rcd_question csr_question%rowtype;

      cursor csr_response is
         select t01.*
           from pts_tes_response t01
          where t01.tre_tes_code = rcd_retrieve.tde_tes_code;
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
      if var_action != '*RTVQUE' then
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
      if rcd_retrieve.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') target must be *PET - question update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_status := ' - (*UNKNOWN)';
      if rcd_retrieve.tde_tes_status = 1 then
         var_status := ' - (Raised)';
      elsif rcd_retrieve.tde_tes_status = 2 then
         var_status := ' - (Allocation Completed)';
      elsif rcd_retrieve.tde_tes_status = 3 then
         var_status := ' - (Results Entered)';
      elsif rcd_retrieve.tde_tes_status = 4 then
         var_status := ' - (Closed)';
      elsif rcd_retrieve.tde_tes_status = 9 then
         var_status := ' - (Cancelled)';
      end if;

      /*-*/
      /* Retrieve the test response
      /*-*/
      var_response := '0';
      open csr_response;
      fetch csr_response into rcd_response;
      if csr_response%found then
         var_response := '1';
      end if;
      close csr_response;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test xml
      /*-*/
      pipe row(pts_xml_object('<TEST TESTXT="('||to_char(rcd_retrieve.tde_tes_code)||') '||pts_to_xml(rcd_retrieve.tde_tes_title)||pts_to_xml(var_status)||'" TESSTA="'||to_char(rcd_retrieve.tde_tes_status)||'" RESDTA="'||var_response||'" DAYCNT="'||to_char(rcd_retrieve.tde_tes_day_count)||'" WEICAL="'||pts_to_xml(nvl(rcd_retrieve.tde_wgt_que_calc,'0'))||'" WEIBOL="'||to_char(rcd_retrieve.tde_wgt_que_bowl)||'" WEIOFF="'||to_char(rcd_retrieve.tde_wgt_que_offer)||'" WEIREM="'||to_char(rcd_retrieve.tde_wgt_que_remain)||'"/>'));

      /*-*/
      /* Pipe the test question xml
      /*-*/
      for idx in 1..rcd_retrieve.tde_tes_day_count loop
         var_day_code := idx;
         pipe row(pts_xml_object('<DAY DAYCDE="'||to_char(var_day_code)||'"/>'));
         open csr_question;
         loop
            fetch csr_question into rcd_question;
            if csr_question%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<QUESTION QUECDE="'||to_char(rcd_question.tqu_que_code)||'" QUETYP="'||pts_to_xml(rcd_question.tqu_que_type)||'" QUETXT="('||to_char(rcd_question.tqu_que_code)||') '||pts_to_xml(rcd_question.qde_que_text)||'"/>'));
         end loop;
         close csr_question;
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RETRIEVE_QUESTION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_question;

   /*******************************************************/
   /* This procedure performs the select question routine */
   /*******************************************************/
   function select_question return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_que_code number;
      var_que_type varchar2(1);
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_question is
         select t01.*
           from pts_que_definition t01
          where t01.qde_que_code = var_que_code;
      rcd_question csr_question%rowtype;

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
      if var_action != '*SELQUE' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_que_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@QUECDE'));
      var_que_type := pts_to_xml(xslProcessor.valueOf(obj_pts_request,'@QUETYP'));
      if var_que_code is null then
         pts_gen_function.add_mesg_data('Question code ('||xslProcessor.valueOf(obj_pts_request,'@QUECDE')||') must be a number');
      end if;
      if var_que_type is null then
         pts_gen_function.add_mesg_data('Question type ('||xslProcessor.valueOf(obj_pts_request,'@QUETYP')||') must be a specified');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the question
      /*-*/
      var_found := false;
      open csr_question;
      fetch csr_question into rcd_question;
      if csr_question%found then
         var_found := true;
      end if;
      close csr_question;
      if var_found = false then
         pts_gen_function.add_mesg_data('Question ('||to_char(var_que_code)||') does not exist');
      end if;
      if rcd_question.qde_que_status != 1 then
         pts_gen_function.add_mesg_data('Question code (' || to_char(var_que_code) || ') must be active');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the question xml
      /*-*/
      pipe row(pts_xml_object('<QUESTION QUECDE="'||to_char(rcd_question.qde_que_code)||'" QUETYP="'||pts_to_xml(var_que_type)||'" QUETXT="('||to_char(rcd_question.qde_que_code)||') '||pts_to_xml(rcd_question.qde_que_text)||'"/>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - SELECT_QUESTION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_question;

   /*******************************************************/
   /* This procedure performs the update question routine */
   /*******************************************************/
   procedure update_question(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      obj_day_list xmlDom.domNodeList;
      obj_day_node xmlDom.domNode;
      obj_que_list xmlDom.domNodeList;
      obj_que_node xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_bowl boolean;
      var_offer boolean;
      var_remain boolean;
      var_que_code number;
      rcd_pts_tes_definition pts_tes_definition%rowtype;
      rcd_pts_tes_question pts_tes_question%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = rcd_pts_tes_definition.tde_tes_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_target is
         select t01.*
           from pts_tes_type t01
          where t01.tty_tes_type = rcd_retrieve.tde_tes_type;
      rcd_target csr_target%rowtype;

      cursor csr_question is
         select t01.*
           from pts_que_definition t01
          where t01.qde_que_code = var_que_code;
      rcd_question csr_question%rowtype;

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
      if var_action != '*UPDQUE' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_tes_definition.tde_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCDE'));
      rcd_pts_tes_definition.tde_wgt_que_calc := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@WEICAL'));
      rcd_pts_tes_definition.tde_wgt_que_bowl := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@WEIBOL'));
      rcd_pts_tes_definition.tde_wgt_que_offer := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@WEIOFF'));
      rcd_pts_tes_definition.tde_wgt_que_remain := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@WEIREM'));
      rcd_pts_tes_definition.tde_upd_user := upper(par_user);
      rcd_pts_tes_definition.tde_upd_date := sysdate;
      if rcd_pts_tes_definition.tde_tes_code is null then
         pts_gen_function.add_mesg_data('Test code ('||xslProcessor.valueOf(obj_pts_request,'@TESCDE')||') must be a number');
      end if;
      if rcd_pts_tes_definition.tde_wgt_que_calc is null or (rcd_pts_tes_definition.tde_wgt_que_calc != '0' and rcd_pts_tes_definition.tde_wgt_que_calc != '1') then
         pts_gen_function.add_mesg_data('Perform weight calculations ('||xslProcessor.valueOf(obj_pts_request,'@WEICAL')||') must be ''0'' or ''1''');
      end if;
      if rcd_pts_tes_definition.tde_wgt_que_calc = '1' then
         if rcd_pts_tes_definition.tde_wgt_que_bowl is null then
            pts_gen_function.add_mesg_data('Weight bowl question ('||xslProcessor.valueOf(obj_pts_request,'@WEIBOL')||') must be a number greater than zero when weight calculation required');
         end if;
         if rcd_pts_tes_definition.tde_wgt_que_offer is null then
            pts_gen_function.add_mesg_data('Weight offered question ('||xslProcessor.valueOf(obj_pts_request,'@WEIOFF')||') must be a number greater than zero when weight calculation required');
         end if;
         if rcd_pts_tes_definition.tde_wgt_que_remain is null then
            pts_gen_function.add_mesg_data('Weight remaining question ('||xslProcessor.valueOf(obj_pts_request,'@WEIREM')||') must be a number greater than zero when weight calculation required');
         end if;
      else
         if not(rcd_pts_tes_definition.tde_wgt_que_bowl is null) then
            pts_gen_function.add_mesg_data('Weight bowl question ('||xslProcessor.valueOf(obj_pts_request,'@WEIBOL')||') must not be supplied when weight calculation not required');
         end if;
         if not(rcd_pts_tes_definition.tde_wgt_que_offer is null) then
            pts_gen_function.add_mesg_data('Weight offered question ('||xslProcessor.valueOf(obj_pts_request,'@WEIOFF')||') must not be supplied when weight calculation not required');
         end if;
         if not(rcd_pts_tes_definition.tde_wgt_que_remain is null) then
            pts_gen_function.add_mesg_data('Weight remaining question ('||xslProcessor.valueOf(obj_pts_request,'@WEIREM')||') must not be supplied when weight calculation not required');
         end if;
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
            pts_gen_function.add_mesg_data('Test ('||to_char(rcd_pts_tes_definition.tde_tes_code)||') is currently locked');
            return;
      end;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test ('||to_char(rcd_pts_tes_definition.tde_tes_code)||') does not exist');
      end if;
      if rcd_retrieve.tde_tes_status != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') must be status Raised - question update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the test target
      /*-*/
      var_found := false;
      open csr_target;
      fetch csr_target into rcd_target;
      if csr_target%found then
         var_found := true;
      end if;
      close csr_target;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test type ('||to_char(rcd_retrieve.tde_tes_type)||') does not exist');
      end if;
      if rcd_target.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') target must be *PET - question update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Validate the test data
      /*-*/
      if rcd_pts_tes_definition.tde_wgt_que_calc = '1' then
         var_que_code := rcd_pts_tes_definition.tde_wgt_que_bowl;
         open csr_question;
         fetch csr_question into rcd_question;
         if csr_question%notfound then
            pts_gen_function.add_mesg_data('Weight bowl question ('||to_char(var_que_code)||') does not exist');
         else
            if rcd_question.qde_que_status != 1 then
               pts_gen_function.add_mesg_data('Weight bowl question ('||to_char(var_que_code)||') is not active');
            end if;
            if rcd_question.qde_rsp_type != 2 then
               pts_gen_function.add_mesg_data('Weight bowl question ('||to_char(var_que_code)||') must be a range response');
            end if;
         end if;
         close csr_question;
         var_que_code := rcd_pts_tes_definition.tde_wgt_que_offer;
         open csr_question;
         fetch csr_question into rcd_question;
         if csr_question%notfound then
            pts_gen_function.add_mesg_data('Weight offered question ('||to_char(var_que_code)||') does not exist');
         else
            if rcd_question.qde_que_status != 1 then
               pts_gen_function.add_mesg_data('Weight offered question ('||to_char(var_que_code)||') is not active');
            end if;
            if rcd_question.qde_rsp_type != 2 then
               pts_gen_function.add_mesg_data('Weight offered question ('||to_char(var_que_code)||') must be a range response');
            end if;
         end if;
         close csr_question;
         var_que_code := rcd_pts_tes_definition.tde_wgt_que_remain;
         open csr_question;
         fetch csr_question into rcd_question;
         if csr_question%notfound then
            pts_gen_function.add_mesg_data('Weight remaining question ('||to_char(var_que_code)||') does not exist');
         else
            if rcd_question.qde_que_status != 1 then
               pts_gen_function.add_mesg_data('Weight remaining question ('||to_char(var_que_code)||') is not active');
            end if;
            if rcd_question.qde_rsp_type != 2 then
               pts_gen_function.add_mesg_data('Weight remaining question ('||to_char(var_que_code)||') must be a range response');
            end if;
         end if;
         close csr_question;
      end if;

      /*-*/
      /* Retrieve and validate the question data
      /*-*/
      obj_day_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/DAY');
      for idx in 0..xmlDom.getLength(obj_day_list)-1 loop
         obj_day_node := xmlDom.item(obj_day_list,idx);
         if rcd_pts_tes_definition.tde_wgt_que_calc = '1' then
            var_bowl := false;
            var_offer := false;
            var_remain := false;
         end if;
         obj_que_list := xslProcessor.selectNodes(obj_day_node,'QUESTION');
         for idy in 0..xmlDom.getLength(obj_que_list)-1 loop
            obj_que_node := xmlDom.item(obj_que_list,idy);
            var_que_code := pts_to_number(xslProcessor.valueOf(obj_que_node,'@QUECDE'));
            open csr_question;
            fetch csr_question into rcd_question;
            if csr_question%notfound then
               pts_gen_function.add_mesg_data('Question ('||to_char(var_que_code)||') does not exist');
            else
               if rcd_question.qde_que_status != 1 then
                  pts_gen_function.add_mesg_data('Question ('||to_char(var_que_code)||') is not active');
               end if;
            end if;
            close csr_question;
            if var_que_code = rcd_pts_tes_definition.tde_wgt_que_bowl then
               var_bowl := true;
            elsif var_que_code = rcd_pts_tes_definition.tde_wgt_que_offer then
               var_offer := true;
            elsif var_que_code = rcd_pts_tes_definition.tde_wgt_que_remain then
               var_remain := true;
            end if;
         end loop;
         if rcd_pts_tes_definition.tde_wgt_que_calc = '1' and
            (var_bowl = false or var_offer = false or var_remain = false) then
            pts_gen_function.add_mesg_data('Weight calculation required - Day (' || xslProcessor.valueOf(obj_day_node,'@DAYCDE') || ') does not have all weight questions');
         end if;
      end loop;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Update the test definition
      /*-*/
      update pts_tes_definition
         set tde_upd_user = rcd_pts_tes_definition.tde_upd_user,
             tde_upd_date = rcd_pts_tes_definition.tde_upd_date,
             tde_wgt_que_calc = rcd_pts_tes_definition.tde_wgt_que_calc,
             tde_wgt_que_bowl = rcd_pts_tes_definition.tde_wgt_que_bowl,
             tde_wgt_que_offer = rcd_pts_tes_definition.tde_wgt_que_offer,
             tde_wgt_que_remain = rcd_pts_tes_definition.tde_wgt_que_remain
       where tde_tes_code = rcd_pts_tes_definition.tde_tes_code;

      /*-*/
      /* Delete the existing question data
      /*-*/
      delete from pts_tes_response where tre_tes_code = rcd_pts_tes_definition.tde_tes_code;
      delete from pts_tes_question where tqu_tes_code = rcd_pts_tes_definition.tde_tes_code;

      /*-*/
      /* Retrieve and insert the question data
      /*-*/
      obj_day_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/DAY');
      for idx in 0..xmlDom.getLength(obj_day_list)-1 loop
         obj_day_node := xmlDom.item(obj_day_list,idx);
         rcd_pts_tes_question.tqu_dsp_seqn := 0;
         obj_que_list := xslProcessor.selectNodes(obj_day_node,'QUESTION');
         for idy in 0..xmlDom.getLength(obj_que_list)-1 loop
            obj_que_node := xmlDom.item(obj_que_list,idy);
            rcd_pts_tes_question.tqu_tes_code := rcd_pts_tes_definition.tde_tes_code;
            rcd_pts_tes_question.tqu_day_code := pts_to_number(xslProcessor.valueOf(obj_day_node,'@DAYCDE'));
            rcd_pts_tes_question.tqu_que_code := pts_to_number(xslProcessor.valueOf(obj_que_node,'@QUECDE'));
            rcd_pts_tes_question.tqu_que_type := pts_from_xml(xslProcessor.valueOf(obj_que_node,'@QUETYP'));
            rcd_pts_tes_question.tqu_dsp_seqn := rcd_pts_tes_question.tqu_dsp_seqn + 1;
            insert into pts_tes_question values rcd_pts_tes_question;
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

         /* Raise an exception to the calling application
         /*-*/
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - UPDATE_QUESTION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_question;

   /*******************************************************/
   /* This procedure performs the retrieve sample routine */
   /*******************************************************/
   function retrieve_sample return pts_xml_type pipelined is

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
      var_status varchar2(128);
      var_allocation varchar2(1);
      var_response varchar2(1);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                t02.tty_typ_target
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_sample is
         select t01.*,
                t02.sde_sam_text,
                t02.sde_uom_size,
                t03.sva_val_text as uom_text
           from pts_tes_sample t01,
                pts_sam_definition t02,
                pts_sys_value t03
          where t01.tsa_sam_code = t02.sde_sam_code
            and t02.sde_uom_code = t03.sva_val_code
            and t01.tsa_tes_code = var_tes_code
            and t03.sva_tab_code = upper('*SAM_DEF')
            and t03.sva_fld_code = 4
          order by t01.tsa_sam_code asc;
      rcd_sample csr_sample%rowtype;

      cursor csr_size is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*PET_CLA',8)) t01
          order by t01.val_code asc;
      rcd_size csr_size%rowtype;

      cursor csr_feeding is
         select t01.*
           from pts_tes_feeding t01
          where t01.tfe_tes_code = var_tes_code
            and t01.tfe_sam_code = rcd_sample.tsa_sam_code
            and t01.tfe_pet_size = rcd_size.val_code;
      rcd_feeding csr_feeding%rowtype;

      cursor csr_allocation is
         select t01.*
           from pts_tes_allocation t01
          where t01.tal_tes_code = rcd_retrieve.tde_tes_code;
      rcd_allocation csr_allocation%rowtype;

      cursor csr_response is
         select t01.*
           from pts_tes_response t01
          where t01.tre_tes_code = rcd_retrieve.tde_tes_code;
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
      if var_action != '*RTVSAM' then
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
      if rcd_retrieve.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') target must be *PET - panel update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_status := ' - (*UNKNOWN)';
      if rcd_retrieve.tde_tes_status = 1 then
         var_status := ' - (Raised)';
      elsif rcd_retrieve.tde_tes_status = 2 then
         var_status := ' - (Allocation Completed)';
      elsif rcd_retrieve.tde_tes_status = 3 then
         var_status := ' - (Results Entered)';
      elsif rcd_retrieve.tde_tes_status = 4 then
         var_status := ' - (Closed)';
      elsif rcd_retrieve.tde_tes_status = 9 then
         var_status := ' - (Cancelled)';
      end if;

      /*-*/
      /* Retrieve the test allocation
      /*-*/
      var_allocation := '0';
      open csr_allocation;
      fetch csr_allocation into rcd_allocation;
      if csr_allocation%found then
         var_allocation := '1';
      end if;
      close csr_allocation;

      /*-*/
      /* Retrieve the test response
      /*-*/
      var_response := '0';
      open csr_response;
      fetch csr_response into rcd_response;
      if csr_response%found then
         var_response := '1';
      end if;
      close csr_response;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test xml
      /*-*/
      pipe row(pts_xml_object('<TEST TESTXT="('||to_char(rcd_retrieve.tde_tes_code)||') '||pts_to_xml(rcd_retrieve.tde_tes_title)||pts_to_xml(var_status)||'" TESSTA="'||to_char(rcd_retrieve.tde_tes_status)||'" ALCDTA="'||var_allocation||'" RESDTA="'||var_response||'"/>'));

      /*-*/
      /* Pipe the test sample xml
      /*-*/
      open csr_sample;
      loop
         fetch csr_sample into rcd_sample;
         if csr_sample%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<SAMPLE SAMCDE="'||to_char(rcd_sample.tsa_sam_code)||'" SAMTXT="('||to_char(rcd_sample.tsa_sam_code)||') '||pts_to_xml(rcd_sample.sde_sam_text||' - '||to_char(rcd_sample.sde_uom_size)||' '||rcd_sample.uom_text)||'" RPTCDE="'||pts_to_xml(rcd_sample.tsa_rpt_code)||'" MKTCDE="'||pts_to_xml(rcd_sample.tsa_mkt_code)||'" ALSCDE="'||pts_to_xml(rcd_sample.tsa_mkt_acde)||'"/>'));
         open csr_size;
         loop
            fetch csr_size into rcd_size;
            if csr_size%notfound then
               exit;
            end if;
            open csr_feeding;
            fetch csr_feeding into rcd_feeding;
            if csr_feeding%notfound then
               rcd_feeding.tfe_fed_qnty := null;
               rcd_feeding.tfe_fed_text := null;
            end if;
            close csr_feeding;
            pipe row(pts_xml_object('<FEEDING SIZCDE="'||to_char(rcd_size.val_code)||'" SIZTXT="'||pts_to_xml(rcd_size.val_text)||'" FEDQTY="'||to_char(rcd_feeding.tfe_fed_qnty)||'" FEDTXT="'||pts_to_xml(rcd_feeding.tfe_fed_text)||'"/>'));
         end loop;
         close csr_size;
      end loop;
      close csr_sample;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RETRIEVE_SAMPLE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_sample;

   /*****************************************************/
   /* This procedure performs the select sample routine */
   /*****************************************************/
   function select_sample return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_sam_code number;
      var_rpt_code varchar2(32);
      var_mkt_code varchar2(32);
      var_als_code varchar2(32);
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sample is
         select t01.*,
                t02.sva_val_text as uom_text
           from pts_sam_definition t01,
                pts_sys_value t02
          where t01.sde_uom_code = t02.sva_val_code(+)
            and t01.sde_sam_code = var_sam_code
            and t02.sva_tab_code = upper('*SAM_DEF')
            and t02.sva_fld_code = 4;
      rcd_sample csr_sample%rowtype;

      cursor csr_size is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*PET_CLA',8)) t01
          order by t01.val_code asc;
      rcd_size csr_size%rowtype;

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
      if var_action != '*SELSAM' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_sam_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@SAMCDE'));
      var_rpt_code := upper(trim(pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@RPTCDE'))));
      var_mkt_code := upper(trim(pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@MKTCDE'))));
      var_als_code := upper(trim(pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@ALSCDE'))));
      if var_sam_code is null then
         pts_gen_function.add_mesg_data('Sample code ('||xslProcessor.valueOf(obj_pts_request,'@SAMCDE')||') must be a number');
      end if;
      if var_rpt_code is null then
         pts_gen_function.add_mesg_data('Report code must be a entered');
      end if;
      if var_mkt_code is null then
         pts_gen_function.add_mesg_data('Market research code must be a entered');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the sample
      /*-*/
      var_found := false;
      open csr_sample;
      fetch csr_sample into rcd_sample;
      if csr_sample%found then
         var_found := true;
      end if;
      close csr_sample;
      if var_found = false then
         pts_gen_function.add_mesg_data('Sample ('||to_char(var_sam_code)||') does not exist');
      end if;
      if rcd_sample.sde_sam_status != 1 then
         pts_gen_function.add_mesg_data('Question code (' || to_char(var_sam_code) || ') must be active');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the sample xml
      /*-*/
      pipe row(pts_xml_object('<SAMPLE SAMCDE="'||to_char(rcd_sample.sde_sam_code)||'" SAMTXT="('||to_char(rcd_sample.sde_sam_code)||') '||pts_to_xml(rcd_sample.sde_sam_text||' - '||to_char(rcd_sample.sde_uom_size)||' '||rcd_sample.uom_text)||'" RPTCDE="'||pts_to_xml(var_rpt_code)||'" MKTCDE="'||pts_to_xml(var_mkt_code)||'" ALSCDE="'||pts_to_xml(var_als_code)||'"/>'));
      open csr_size;
      loop
         fetch csr_size into rcd_size;
         if csr_size%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<FEEDING SIZCDE="'||to_char(rcd_size.val_code)||'" SIZTXT="'||pts_to_xml(rcd_size.val_text)||'" FEDQTY="" FEDTXT=""/>'));
      end loop;
      close csr_size;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - SELECT_SAMPLE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_sample;

   /*****************************************************/
   /* This procedure performs the update sample routine */
   /*****************************************************/
   procedure update_sample(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      obj_sam_list xmlDom.domNodeList;
      obj_sam_node xmlDom.domNode;
      obj_fed_list xmlDom.domNodeList;
      obj_fed_node xmlDom.domNode;
      var_action varchar2(32);
      var_sam_code number;
      var_found boolean;
      var_error boolean;
      rcd_pts_tes_definition pts_tes_definition%rowtype;
      rcd_pts_tes_sample pts_tes_sample%rowtype;
      rcd_pts_tes_feeding pts_tes_feeding%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = rcd_pts_tes_definition.tde_tes_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_target is
         select t01.*
           from pts_tes_type t01
          where t01.tty_tes_type = rcd_retrieve.tde_tes_type;
      rcd_target csr_target%rowtype;

      cursor csr_sample is
         select t01.*
           from pts_sam_definition t01
          where t01.sde_sam_code = var_sam_code;
      rcd_sample csr_sample%rowtype;

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
      if var_action != '*UPDSAM' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_tes_definition.tde_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCDE'));
      rcd_pts_tes_definition.tde_upd_user := upper(par_user);
      rcd_pts_tes_definition.tde_upd_date := sysdate;
      if rcd_pts_tes_definition.tde_tes_code is null then
         pts_gen_function.add_mesg_data('Test code ('||xslProcessor.valueOf(obj_pts_request,'@TESCDE')||') must be a number');
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
            pts_gen_function.add_mesg_data('Test ('||to_char(rcd_pts_tes_definition.tde_tes_code)||') is currently locked');
            return;
      end;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test ('||to_char(rcd_pts_tes_definition.tde_tes_code)||') does not exist');
      end if;
      if rcd_retrieve.tde_tes_status != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') must be status Raised - sample update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the test target
      /*-*/
      var_found := false;
      open csr_target;
      fetch csr_target into rcd_target;
      if csr_target%found then
         var_found := true;
      end if;
      close csr_target;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test type ('||to_char(rcd_retrieve.tde_tes_type)||') does not exist');
      end if;
      if rcd_target.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_retrieve.tde_tes_code) || ') target must be *PET - sample update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve and validate the sample data
      /*-*/
      obj_sam_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/SAMPLE');
      for idx in 0..xmlDom.getLength(obj_sam_list)-1 loop
         obj_sam_node := xmlDom.item(obj_sam_list,idx);
         var_sam_code := pts_to_number(xslProcessor.valueOf(obj_sam_node,'@SAMCDE'));
         open csr_sample;
         fetch csr_sample into rcd_sample;
         if csr_sample%notfound then
            pts_gen_function.add_mesg_data('Sample ('||to_char(var_sam_code)||') does not exist');
         else
            if rcd_sample.sde_sam_status != 1 then
               pts_gen_function.add_mesg_data('Sample ('||to_char(var_sam_code)||') is not active');
            end if;
         end if;
         close csr_sample;
      end loop;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Update the test definition
      /*-*/
      update pts_tes_definition
         set tde_upd_user = rcd_pts_tes_definition.tde_upd_user,
             tde_upd_date = rcd_pts_tes_definition.tde_upd_date
       where tde_tes_code = rcd_pts_tes_definition.tde_tes_code;

      /*-*/
      /* Delete the existing relevant test data
      /*-*/
      delete from pts_tes_response where tre_tes_code = rcd_retrieve.tde_tes_code;
      delete from pts_tes_allocation where tal_tes_code = rcd_retrieve.tde_tes_code;
      delete from pts_tes_feeding where tfe_tes_code = rcd_retrieve.tde_tes_code;
      delete from pts_tes_sample where tsa_tes_code = rcd_retrieve.tde_tes_code;

      /*-*/
      /* Retrieve and insert the sample data
      /*-*/
      obj_sam_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/SAMPLE');
      for idx in 0..xmlDom.getLength(obj_sam_list)-1 loop
         obj_sam_node := xmlDom.item(obj_sam_list,idx);
         rcd_pts_tes_sample.tsa_tes_code := rcd_retrieve.tde_tes_code;
         rcd_pts_tes_sample.tsa_sam_code := pts_to_number(xslProcessor.valueOf(obj_sam_node,'@SAMCDE'));
         rcd_pts_tes_sample.tsa_rpt_code := upper(trim(pts_from_xml(xslProcessor.valueOf(obj_sam_node,'@RPTCDE'))));
         rcd_pts_tes_sample.tsa_mkt_code := upper(trim(pts_from_xml(xslProcessor.valueOf(obj_sam_node,'@MKTCDE'))));
         rcd_pts_tes_sample.tsa_mkt_acde := upper(trim(pts_from_xml(xslProcessor.valueOf(obj_sam_node,'@ALSCDE'))));
         rcd_pts_tes_sample.tsa_sam_iden := 'UBA'||to_char(rcd_pts_tes_sample.tsa_sam_code,'fm000000')||rcd_pts_tes_sample.tsa_mkt_code;
         if rcd_pts_tes_sample.tsa_mkt_acde is null then
            rcd_pts_tes_sample.tsa_mkt_acde := rcd_pts_tes_sample.tsa_mkt_code;
         end if;
         insert into pts_tes_sample values rcd_pts_tes_sample;
         obj_fed_list := xslProcessor.selectNodes(obj_sam_node,'FEEDING');
         for idz in 0..xmlDom.getLength(obj_fed_list)-1 loop
            obj_fed_node := xmlDom.item(obj_fed_list,idz);
            if not(xslProcessor.valueOf(obj_fed_node,'@FEDQTY') is null) then
               rcd_pts_tes_feeding.tfe_tes_code := rcd_pts_tes_sample.tsa_tes_code;
               rcd_pts_tes_feeding.tfe_sam_code := rcd_pts_tes_sample.tsa_sam_code;
               rcd_pts_tes_feeding.tfe_pet_size := pts_to_number(xslProcessor.valueOf(obj_fed_node,'@SIZCDE'));
               rcd_pts_tes_feeding.tfe_fed_qnty := pts_to_number(xslProcessor.valueOf(obj_fed_node,'@FEDQTY'));
               rcd_pts_tes_feeding.tfe_fed_text := pts_from_xml(xslProcessor.valueOf(obj_fed_node,'@FEDTXT'));
               insert into pts_tes_feeding values rcd_pts_tes_feeding;
            end if;
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

         /* Raise an exception to the calling application
         /*-*/
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - UPDATE_SAMPLE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_sample;

   /******************************************************/
   /* This procedure performs the retrieve panel routine */
   /******************************************************/
   function retrieve_panel return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tes_code number;
      var_found boolean;
      var_status varchar2(128);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                t02.tty_typ_target,
                decode(nvl(t03.pan_count,0),0,'0','1') as pan_done
           from pts_tes_definition t01,
                pts_tes_type t02,
                (select tpa_tes_code, count(*) as pan_count from pts_tes_panel where tpa_tes_code = var_tes_code group by tpa_tes_code) t03
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = t03.tpa_tes_code(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_template is
         select t01.*
           from pts_stm_definition t01
          where t01.std_stm_target = rcd_retrieve.tty_typ_target
            and t01.std_stm_status = 1
          order by t01.std_stm_code asc;
      rcd_template csr_template%rowtype;

      cursor csr_group is
         select t01.*
           from pts_tes_group t01
          where t01.tgr_tes_code = rcd_retrieve.tde_tes_code
          order by t01.tgr_sel_group asc;
      rcd_group csr_group%rowtype;

      cursor csr_rule is
         select t01.*,
                t02.sfi_fld_text,
                t02.sfi_fld_rul_type,
                t02.sfi_fld_inp_leng
           from pts_tes_rule t01,
                pts_sys_field t02
          where t01.tru_tab_code = t02.sfi_tab_code
            and t01.tru_fld_code = t02.sfi_fld_code
            and t01.tru_tes_code = rcd_retrieve.tde_tes_code
            and t01.tru_sel_group = rcd_group.tgr_sel_group
          order by t01.tru_tab_code asc,
                   t01.tru_fld_code asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is
         select t01.*
           from pts_tes_value t01
          where t01.tva_tes_code = rcd_retrieve.tde_tes_code
            and t01.tva_sel_group = rcd_group.tgr_sel_group
            and t01.tva_tab_code = rcd_rule.tru_tab_code
            and t01.tva_fld_code = rcd_rule.tru_fld_code
          order by t01.tva_val_code asc;
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
      if var_action != '*RTVPAN' then
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
      if rcd_retrieve.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') target must be *PET - panel update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_status := ' - (*UNKNOWN)';
      if rcd_retrieve.tde_tes_status = 1 then
         var_status := ' - (Raised)';
      elsif rcd_retrieve.tde_tes_status = 2 then
         var_status := ' - (Allocation Completed)';
      elsif rcd_retrieve.tde_tes_status = 3 then
         var_status := ' - (Results Entered)';
      elsif rcd_retrieve.tde_tes_status = 4 then
         var_status := ' - (Closed)';
      elsif rcd_retrieve.tde_tes_status = 9 then
         var_status := ' - (Cancelled)';
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test xml
      /*-*/
      pipe row(pts_xml_object('<TEST TESTXT="('||to_char(rcd_retrieve.tde_tes_code)||') '||pts_to_xml(rcd_retrieve.tde_tes_title)||pts_to_xml(var_status)||'" TESSTA="'||to_char(rcd_retrieve.tde_tes_status)||'" SELTYP="'||pts_to_xml(rcd_retrieve.tde_pan_sel_type)||'" PANDON="'||pts_to_xml(rcd_retrieve.pan_done)||'" MEMCNT="'||to_char(rcd_retrieve.tde_req_mem_count)||'" RESCNT="'||to_char(rcd_retrieve.tde_req_res_count)||'" PETMLT="'||pts_to_xml(rcd_retrieve.tde_hou_pet_multi)||'"/>'));

      /*-*/
      /* Pipe the selection template XML
      /*-*/
      pipe row(pts_xml_object('<TEM_LIST VALCDE="*NONE" VALTXT="** Template Selection **"/>'));
      open csr_template;
      loop
         fetch csr_template into rcd_template;
         if csr_template%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<TEM_LIST VALCDE="'||to_char(rcd_template.std_stm_code)||'" VALTXT="('||to_char(rcd_template.std_stm_code)||') '||pts_to_xml(rcd_template.std_stm_text)||'"/>'));
      end loop;
      close csr_template;

      /*-*/
      /* Pipe the test rules
      /*-*/
      open csr_group;
      loop
         fetch csr_group into rcd_group;
         if csr_group%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<GROUP GRPCDE="'||pts_to_xml(rcd_group.tgr_sel_group)||'" GRPTXT="'||pts_to_xml(rcd_group.tgr_sel_text)||'" GRPPCT="'||to_char(rcd_group.tgr_sel_pcnt)||'"/>'));
         open csr_rule;
         loop
            fetch csr_rule into rcd_rule;
            if csr_rule%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<RULE GRPCDE="'||pts_to_xml(rcd_rule.tru_sel_group)||'" TABCDE="'||pts_to_xml(rcd_rule.tru_tab_code)||'" FLDCDE="'||to_char(rcd_rule.tru_fld_code)||'" FLDTXT="'||pts_to_xml(rcd_rule.sfi_fld_text)||'" INPLEN="'||to_char(rcd_rule.sfi_fld_inp_leng)||'" RULTYP="'||rcd_rule.sfi_fld_rul_type||'" RULCDE="'||rcd_rule.tru_rul_code||'"/>'));
            open csr_value;
            loop
               fetch csr_value into rcd_value;
               if csr_value%notfound then
                  exit;
               end if;
               pipe row(pts_xml_object('<VALUE VALCDE="'||to_char(rcd_value.tva_val_code)||'" VALTXT="'||pts_to_xml(rcd_value.tva_val_text)||'" VALPCT="'||to_char(rcd_value.tva_val_pcnt)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RETRIEVE_PANEL - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_panel;

   /*********************************************************/
   /* This procedure performs the retrieve template routine */
   /*********************************************************/
   function retrieve_template return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_stm_code number;
      var_found boolean;

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
      if var_action != '*RTVTEM' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_stm_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@STMCDE'));
      if var_stm_code is null then
         pts_gen_function.add_mesg_data('Selection template code ('||xslProcessor.valueOf(obj_pts_request,'@STMCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the selection template
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         pts_gen_function.add_mesg_data('Selection template ('||to_char(var_stm_code)||') does not exist');
      end if;
      if rcd_retrieve.std_stm_target != 1 then
         pts_gen_function.add_mesg_data('Selection template (' || to_char(var_stm_code) || ') target must be *PET - selection template not allowed');
      end if;
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
      pipe row(pts_xml_object('<TEMPLATE SELTYP="'||pts_to_xml(rcd_retrieve.std_sel_type)||'"/>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RETRIEVE_TEMPLATE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_template;

   /****************************************************/
   /* This procedure performs the update panel routine */
   /****************************************************/
   procedure update_panel(par_user in varchar2) is

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
      var_found boolean;
      rcd_pts_tes_definition pts_tes_definition%rowtype;
      rcd_pts_tes_group pts_tes_group%rowtype;
      rcd_pts_tes_rule pts_tes_rule%rowtype;
      rcd_pts_tes_value pts_tes_value%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = rcd_pts_tes_definition.tde_tes_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_target is
         select t01.*
           from pts_tes_type t01
          where t01.tty_tes_type = rcd_retrieve.tde_tes_type;
      rcd_target csr_target%rowtype;

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
      if var_action != '*UPDPAN' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_tes_definition.tde_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCDE'));
      rcd_pts_tes_definition.tde_req_mem_count := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@MEMCNT'));
      rcd_pts_tes_definition.tde_req_res_count := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@RESCNT'));
      rcd_pts_tes_definition.tde_hou_pet_multi := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@PETMLT'));
      rcd_pts_tes_definition.tde_pan_sel_type := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@SELTYP'));
      rcd_pts_tes_definition.tde_upd_user := upper(par_user);
      rcd_pts_tes_definition.tde_upd_date := sysdate;
      if rcd_pts_tes_definition.tde_tes_code is null then
         pts_gen_function.add_mesg_data('Test code ('||xslProcessor.valueOf(obj_pts_request,'@TESCDE')||') must be a number');
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
      if rcd_pts_tes_definition.tde_pan_sel_type is null then
         pts_gen_function.add_mesg_data('Selection type must be supplied');
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
            pts_gen_function.add_mesg_data('Test ('||to_char(rcd_pts_tes_definition.tde_tes_code)||') is currently locked');
            return;
      end;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test ('||to_char(rcd_pts_tes_definition.tde_tes_code)||') does not exist');
      end if;
      if rcd_retrieve.tde_tes_status != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') must be status Raised - panel update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the test target
      /*-*/
      var_found := false;
      open csr_target;
      fetch csr_target into rcd_target;
      if csr_target%found then
         var_found := true;
      end if;
      close csr_target;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test type ('||to_char(rcd_retrieve.tde_tes_type)||') does not exist');
      end if;
      if rcd_target.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') target must be *PET - panel update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Release any test panel members
      /*-*/
      update pts_pet_definition
         set pde_pet_status = decode(pde_pet_status,2,1,5,3,1),
             pde_tes_code = null
       where pde_tes_code = rcd_pts_tes_definition.tde_tes_code;
      update pts_hou_definition
         set hde_hou_status = decode(hde_hou_status,2,1,5,3,1),
             hde_tes_code = null
       where hde_tes_code = rcd_pts_tes_definition.tde_tes_code;

      /*-*/
      /* Delete the existing relevant test data
      /*-*/
      delete from pts_tes_response where tre_tes_code = rcd_pts_tes_definition.tde_tes_code;
      delete from pts_tes_allocation where tal_tes_code = rcd_pts_tes_definition.tde_tes_code;
      delete from pts_tes_classification where tcl_tes_code = rcd_pts_tes_definition.tde_tes_code;
      delete from pts_tes_statistic where tst_tes_code = rcd_pts_tes_definition.tde_tes_code;
      delete from pts_tes_panel where tpa_tes_code = rcd_pts_tes_definition.tde_tes_code;
      delete from pts_tes_value where tva_tes_code = rcd_pts_tes_definition.tde_tes_code;
      delete from pts_tes_rule where tru_tes_code = rcd_pts_tes_definition.tde_tes_code;
      delete from pts_tes_group where tgr_tes_code = rcd_pts_tes_definition.tde_tes_code;

      /*-*/
      /* Retrieve and insert the test rule data
      /*-*/
      obj_grp_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/GROUP');
      for idx in 0..xmlDom.getLength(obj_grp_list)-1 loop
         obj_grp_node := xmlDom.item(obj_grp_list,idx);
         obj_rul_list := xslProcessor.selectNodes(obj_grp_node,'RULE');
         if xmlDom.getLength(obj_rul_list) != 0 then
            rcd_pts_tes_group.tgr_tes_code := rcd_pts_tes_definition.tde_tes_code;
            rcd_pts_tes_group.tgr_sel_group := pts_from_xml(xslProcessor.valueOf(obj_grp_node,'@GRPCDE'));
            rcd_pts_tes_group.tgr_sel_text := pts_from_xml(xslProcessor.valueOf(obj_grp_node,'@GRPTXT'));
            rcd_pts_tes_group.tgr_sel_pcnt := pts_to_number(xslProcessor.valueOf(obj_grp_node,'@GRPPCT'));
            rcd_pts_tes_group.tgr_req_mem_count := 0;
            rcd_pts_tes_group.tgr_req_res_count := 0;
            rcd_pts_tes_group.tgr_sel_mem_count := 0;
            rcd_pts_tes_group.tgr_sel_res_count := 0;
            insert into pts_tes_group values rcd_pts_tes_group;
            for idy in 0..xmlDom.getLength(obj_rul_list)-1 loop
               obj_rul_node := xmlDom.item(obj_rul_list,idy);
               rcd_pts_tes_rule.tru_tes_code := rcd_pts_tes_group.tgr_tes_code;
               rcd_pts_tes_rule.tru_sel_group := rcd_pts_tes_group.tgr_sel_group;
               rcd_pts_tes_rule.tru_tab_code := pts_from_xml(xslProcessor.valueOf(obj_rul_node,'@TABCDE'));
               rcd_pts_tes_rule.tru_fld_code := pts_to_number(xslProcessor.valueOf(obj_rul_node,'@FLDCDE'));
               rcd_pts_tes_rule.tru_rul_code := pts_from_xml(xslProcessor.valueOf(obj_rul_node,'@RULCDE'));
               insert into pts_tes_rule values rcd_pts_tes_rule;
               obj_val_list := xslProcessor.selectNodes(obj_rul_node,'VALUE');
               for idz in 0..xmlDom.getLength(obj_val_list)-1 loop
                  obj_val_node := xmlDom.item(obj_val_list,idz);
                  rcd_pts_tes_value.tva_tes_code := rcd_pts_tes_rule.tru_tes_code;
                  rcd_pts_tes_value.tva_sel_group := rcd_pts_tes_rule.tru_sel_group;
                  rcd_pts_tes_value.tva_tab_code := rcd_pts_tes_rule.tru_tab_code;
                  rcd_pts_tes_value.tva_fld_code := rcd_pts_tes_rule.tru_fld_code;
                  rcd_pts_tes_value.tva_val_code := pts_to_number(xslProcessor.valueOf(obj_val_node,'@VALCDE'));
                  rcd_pts_tes_value.tva_val_text := pts_from_xml(xslProcessor.valueOf(obj_val_node,'@VALTXT'));
                  rcd_pts_tes_value.tva_val_pcnt := null;
                  if rcd_pts_tes_rule.tru_rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                     rcd_pts_tes_value.tva_val_pcnt := pts_to_number(xslProcessor.valueOf(obj_val_node,'@VALPCT'));
                  end if;
                  rcd_pts_tes_value.tva_req_mem_count := 0;
                  rcd_pts_tes_value.tva_req_res_count := 0;
                  rcd_pts_tes_value.tva_sel_mem_count := 0;
                  rcd_pts_tes_value.tva_sel_res_count := 0;
                  insert into pts_tes_value values rcd_pts_tes_value;
               end loop;
            end loop;
         end if;
      end loop;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Clear the test panel
      /*-*/
      clear_panel(rcd_pts_tes_definition.tde_tes_code, rcd_pts_tes_definition.tde_pan_sel_type, rcd_pts_tes_definition.tde_req_mem_count, rcd_pts_tes_definition.tde_req_res_count);

      /*-*/
      /* Update the test definition
      /*-*/
      update pts_tes_definition
         set tde_upd_user = rcd_pts_tes_definition.tde_upd_user,
             tde_upd_date = rcd_pts_tes_definition.tde_upd_date,
             tde_pan_sel_type = rcd_pts_tes_definition.tde_pan_sel_type,
             tde_req_mem_count = rcd_pts_tes_definition.tde_req_mem_count,
             tde_req_res_count = rcd_pts_tes_definition.tde_req_res_count,
             tde_hou_pet_multi = rcd_pts_tes_definition.tde_hou_pet_multi
       where tde_tes_code = rcd_pts_tes_definition.tde_tes_code;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Relock the test
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
      if rcd_retrieve.tde_tes_status != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') must be status (Raised) - panel update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Select the test panel
      /* **note** 1. Select panel is an autonomous transaction that not impact the test lock
      /*-*/
      select_panel(rcd_retrieve.tde_tes_code, rcd_retrieve.tde_pan_sel_type, '*MEMBER', rcd_retrieve.tde_hou_pet_multi, rcd_retrieve.tde_req_mem_count, rcd_retrieve.tde_req_res_count);
      if rcd_pts_tes_definition.tde_req_res_count != 0 then
         select_panel(rcd_retrieve.tde_tes_code, rcd_retrieve.tde_pan_sel_type, '*RESERVE', rcd_retrieve.tde_hou_pet_multi, rcd_retrieve.tde_req_mem_count, rcd_retrieve.tde_req_res_count);
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
         select t01.*,
                t02.tty_typ_target
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_group is
         select t01.*
           from pts_tes_group t01
          where t01.tgr_tes_code = rcd_retrieve.tde_tes_code
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
            and t01.tru_tes_code = rcd_retrieve.tde_tes_code
            and t01.tru_sel_group = rcd_group.tgr_sel_group
          order by t01.tru_tab_code asc,
                   t01.tru_fld_code asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is
         select t01.*
           from pts_tes_value t01
          where t01.tva_tes_code = rcd_retrieve.tde_tes_code
            and t01.tva_sel_group = rcd_group.tgr_sel_group
            and t01.tva_tab_code = rcd_rule.tru_tab_code
            and t01.tva_fld_code = rcd_rule.tru_fld_code
          order by t01.tva_val_code asc;
      rcd_value csr_value%rowtype;

      cursor csr_panel is
         select t01.*,
                decode(t02.pty_pet_type,null,'*UNKNOWN','('||t02.pty_pet_type||') '||t02.pty_typ_text) as type_text,
                decode(t03.tcl_val_code,null,'*UNKNOWN','('||t03.tcl_val_code||') '||t03.size_text) as size_text,
                decode(t04.gzo_geo_zone,null,'*UNKNOWN','('||t04.gzo_geo_zone||') '||t04.gzo_zon_text) as zone_text
           from pts_tes_panel t01,
                pts_pet_type t02,
                (select t01.tcl_pan_code,
                        t01.tcl_val_code,
                        nvl(t02.sva_val_text,'*UNKNOWN') as size_text
                   from pts_tes_classification t01,
                        (select t01.sva_val_code,
                                t01.sva_val_text
                           from pts_sys_value t01
                          where t01.sva_tab_code = '*PET_CLA'
                            and t01.sva_fld_code = 8) t02
                  where t01.tcl_val_code = t02.sva_val_code(+)
                    and t01.tcl_tes_code = rcd_retrieve.tde_tes_code
                    and t01.tcl_tab_code = '*PET_CLA'
                    and t01.tcl_fld_code = 8) t03,
                pts_geo_zone t04
          where t01.tpa_pet_type = t02.pty_pet_type(+)
            and t01.tpa_pan_code = t03.tcl_pan_code(+)
            and t01.tpa_geo_type = t04.gzo_geo_type(+)
            and t01.tpa_geo_zone = t04.gzo_geo_zone(+)
            and t01.tpa_tes_code = rcd_retrieve.tde_tes_code
            and t01.tpa_sel_group = rcd_group.tgr_sel_group
          order by t01.tpa_geo_zone asc,
                   t01.tpa_pan_status asc,
                   t01.tpa_hou_code asc,
                   t01.tpa_pan_code asc;
      rcd_panel csr_panel%rowtype;

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
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') does not exist');
      end if;
      if rcd_retrieve.tty_typ_target != 1 then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') target must be *PET - panel report not allowed');
      end if;

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<table border=1>');
      pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet Test Panel - ('||rcd_retrieve.tde_tes_code||') '||rcd_retrieve.tde_tes_title||' - Type ('||upper(rcd_retrieve.tde_pan_sel_type)||')</td></tr>');
      pipe row('<tr>');
      pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Type</td>');
      pipe row('<td align=left colspan=5 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Description</td>');
      pipe row('</tr>');
      pipe row('<tr><td align=center colspan=6></td></tr>');

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
            pipe row('<tr><td align=center colspan=6></td></tr>');
         end if;
         var_group := true;

         /*-*/
         /* Output the group data
         /*-*/
         var_work := rcd_group.tgr_sel_text||' ('||to_char(rcd_group.tgr_sel_pcnt)||'%)';
         var_work := var_work||' - Requested/Selected Members ('||to_char(rcd_group.tgr_req_mem_count)||'/'||to_char(rcd_group.tgr_sel_mem_count)||')';
         var_work := var_work||' - Requested/Selected Reserves ('||to_char(rcd_group.tgr_req_res_count)||'/'||to_char(rcd_group.tgr_sel_res_count)||')';
         var_output := '<tr>';
         var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Group</td>';
         var_output := var_output||'<td align=left colspan=5 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;" nowrap>'||var_work||'</td>';
         var_output := var_output||'</tr>';
         pipe row(var_output);
         pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Rules</td></tr>');

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
            var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Rule</td>';
            var_output := var_output||'<td align=left colspan=5 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td>';
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
               var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left colspan=5 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td>';
               var_output := var_output||'</tr>';
               pipe row(var_output);
            end loop;
            close csr_value;

         end loop;
         close csr_rule;

         /*-*/
         /* Retrieve the panel data
         /*-*/
         pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Panel</td></tr>');
         var_output := '<tr>';
         var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Status</td>';
         var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Area</td>';
         var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Household</td>';
         var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Pet</td>';
         var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Type</td>';
         var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Size</td>';
         var_output := var_output||'</tr>';
         pipe row(var_output);
         open csr_panel;
         loop
            fetch csr_panel into rcd_panel;
            if csr_panel%notfound then
               exit;
            end if;
            var_output := '<tr>';
            var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.tpa_pan_status||'</td>';
            var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_panel.zone_text||'</td>';
            var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>('||rcd_panel.tpa_hou_code||') '||rcd_panel.tpa_con_fullname||', '||rcd_panel.tpa_loc_street||', '||rcd_panel.tpa_loc_town||'</td>';
            var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>('||rcd_panel.tpa_pan_code||') '||rcd_panel.tpa_pet_name||'</td>';
            var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_panel.type_text||'</td>';
            var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_panel.size_text||'</td>';
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
         raise_application_error(-20000, 'FATAL ERROR - PTS_TES_FUNCTION - REPORT_PANEL - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_panel;

   /***********************************************************/
   /* This procedure performs the retrieve allocation routine */
   /***********************************************************/
   function retrieve_allocation return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tes_code number;
      var_found boolean;
      var_status varchar2(128);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                t02.tty_typ_target,
                decode(nvl(t03.allocation_count,0),0,'0','1') as allocation_done
           from pts_tes_definition t01,
                pts_tes_type t02,
                (select tal_tes_code, count(*) as allocation_count from pts_tes_allocation where tal_tes_code = var_tes_code group by tal_tes_code) t03
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = t03.tal_tes_code(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

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
      if var_action != '*RTVALC' then
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
      if rcd_retrieve.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') target must be *PET - allocation update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_status := ' - (*UNKNOWN)';
      if rcd_retrieve.tde_tes_status = 1 then
         var_status := ' - (Raised)';
      elsif rcd_retrieve.tde_tes_status = 2 then
         var_status := ' - (Allocation Completed)';
      elsif rcd_retrieve.tde_tes_status = 3 then
         var_status := ' - (Results Entered)';
      elsif rcd_retrieve.tde_tes_status = 4 then
         var_status := ' - (Closed)';
      elsif rcd_retrieve.tde_tes_status = 9 then
         var_status := ' - (Cancelled)';
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test xml
      /*-*/
      pipe row(pts_xml_object('<TEST TESTXT="('||to_char(rcd_retrieve.tde_tes_code)||') '||pts_to_xml(rcd_retrieve.tde_tes_title)||pts_to_xml(var_status)||'" TESSTA="'||to_char(rcd_retrieve.tde_tes_status)||'" ALCDON="'||pts_to_xml(rcd_retrieve.allocation_done)||'"/>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RETRIEVE_ALLOCATION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_allocation;

   /*********************************************************/
   /* This procedure performs the update allocation routine */
   /*********************************************************/
   procedure update_allocation(par_user in varchar2) is

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

      cursor csr_target is
         select t01.*
           from pts_tes_type t01
          where t01.tty_tes_type = rcd_retrieve.tde_tes_type;
      rcd_target csr_target%rowtype;

      cursor csr_sample is
         select t01.*
           from pts_tes_sample t01
          where t01.tsa_tes_code = rcd_pts_tes_definition.tde_tes_code;
      rcd_sample csr_sample%rowtype;

      cursor csr_panel is
         select t01.*
           from pts_tes_panel t01
          where t01.tpa_tes_code = rcd_pts_tes_definition.tde_tes_code;
      rcd_panel csr_panel%rowtype;

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
      if var_action != '*UPDALC' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_tes_definition.tde_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCDE'));
      rcd_pts_tes_definition.tde_upd_user := upper(par_user);
      rcd_pts_tes_definition.tde_upd_date := sysdate;
      if rcd_pts_tes_definition.tde_tes_code is null then
         pts_gen_function.add_mesg_data('Test code ('||xslProcessor.valueOf(obj_pts_request,'@TESCDE')||') must be a number');
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
      if rcd_retrieve.tde_tes_status != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') must be status Raised - allocation update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the test target
      /*-*/
      var_found := false;
      open csr_target;
      fetch csr_target into rcd_target;
      if csr_target%found then
         var_found := true;
      end if;
      close csr_target;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test type ('||to_char(rcd_retrieve.tde_tes_type)||') does not exist');
      end if;
      if rcd_target.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') target must be *PET - allocation update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the test sample and panel
      /*-*/
      var_found := false;
      open csr_sample;
      fetch csr_sample into rcd_sample;
      if csr_sample%found then
         var_found := true;
      end if;
      close csr_sample;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') does not have samples defined - allocation update not allowed');
      end if;
      var_found := false;
      open csr_panel;
      fetch csr_panel into rcd_panel;
      if csr_panel%found then
         var_found := true;
      end if;
      close csr_panel;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') does not have a panel selected - allocation update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Delete the existing test allocation
      /*-*/
      delete from pts_tes_response where tre_tes_code = rcd_pts_tes_definition.tde_tes_code;
      delete from pts_tes_allocation where tal_tes_code = rcd_pts_tes_definition.tde_tes_code;

      /*-*/
      /* Perform the pet allocation routine
      /*-*/
      begin
         pts_pet_allocation.perform_allocation(rcd_pts_tes_definition.tde_tes_code);
      exception
         when others then
         pts_gen_function.add_mesg_data(substr(SQLERRM, 1, 2000));
         rollback;
         return;
      end;

      /*-*/
      /* Update the test definition
      /*-*/
      update pts_tes_definition
         set tde_upd_user = rcd_pts_tes_definition.tde_upd_user,
             tde_upd_date = rcd_pts_tes_definition.tde_upd_date
       where tde_tes_code = rcd_pts_tes_definition.tde_tes_code;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Send the confirm message
      /*-*/
      pts_gen_function.set_cfrm_data('Test ('||to_char(rcd_pts_tes_definition.tde_tes_code)||') allocation completed successfully');

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - UPDATE_ALLOCATION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_allocation;

   /*********************************************************/
   /* This procedure performs the report allocation routine */
   /*********************************************************/
   function report_allocation(par_tes_code in number) return pts_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_tes_code number;
      var_found boolean;
      var_panel boolean;
      var_first boolean;
      var_day number;
      var_output varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                t02.tty_typ_target
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_panel is
         select t01.*,
                decode(t02.pty_pet_type,null,'*UNKNOWN','('||t02.pty_pet_type||') '||t02.pty_typ_text) as type_text,
                decode(t03.tcl_val_code,null,'*UNKNOWN','('||t03.tcl_val_code||') '||t03.size_text) as size_text,
                decode(t04.gzo_geo_zone,null,'*UNKNOWN','('||t04.gzo_geo_zone||') '||t04.gzo_zon_text) as zone_text
           from pts_tes_panel t01,
                pts_pet_type t02,
                (select t01.tcl_pan_code,
                        t01.tcl_val_code,
                        nvl(t02.sva_val_text,'*UNKNOWN') as size_text
                   from pts_tes_classification t01,
                        (select t01.sva_val_code,
                                t01.sva_val_text
                           from pts_sys_value t01
                          where t01.sva_tab_code = '*PET_CLA'
                            and t01.sva_fld_code = 8) t02
                  where t01.tcl_val_code = t02.sva_val_code(+)
                    and t01.tcl_tes_code = rcd_retrieve.tde_tes_code
                    and t01.tcl_tab_code = '*PET_CLA'
                    and t01.tcl_fld_code = 8) t03,
                pts_geo_zone t04
          where t01.tpa_pet_type = t02.pty_pet_type(+)
            and t01.tpa_pan_code = t03.tcl_pan_code(+)
            and t01.tpa_geo_type = t04.gzo_geo_type(+)
            and t01.tpa_geo_zone = t04.gzo_geo_zone(+)
            and t01.tpa_tes_code = rcd_retrieve.tde_tes_code
          order by t01.tpa_geo_zone asc,
                   t01.tpa_pan_status asc,
                   t01.tpa_pan_code asc;
      rcd_panel csr_panel%rowtype;

      cursor csr_allocation is
         select t01.tal_day_code,
                t01.tal_seq_numb,
                t01.tal_mkt_code,
                t02.tsa_rpt_code,
                t02.tsa_mkt_code,
                t02.tsa_mkt_acde,
                '('||t01.tal_sam_code||') '||nvl(t03.sde_sam_text,'*UNKNOWN') as sample_text
           from pts_tes_allocation t01,
                pts_tes_sample t02,
                pts_sam_definition t03
          where t01.tal_tes_code = t02.tsa_tes_code(+)
            and t01.tal_sam_code = t02.tsa_sam_code(+)
            and t02.tsa_sam_code = t03.sde_sam_code(+)
            and t01.tal_tes_code = rcd_panel.tpa_tes_code
            and t01.tal_pan_code = rcd_panel.tpa_pan_code
          order by t01.tal_day_code asc,
                   t01.tal_seq_numb asc;
      rcd_allocation csr_allocation%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameters
      /*-*/
      var_tes_code := par_tes_code;

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
         raise_application_error(-20000, 'Test code ('||to_char(var_tes_code)||') does not exist');
      end if;
      if rcd_retrieve.tty_typ_target != 1 then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') target must be *PET - allocation report not allowed');
      end if;

      /*-*/
      /* Start the report
      /*-*/
      if rcd_retrieve.tde_tes_sam_count = 1 then
         pipe row('<table border=1>');
         pipe row('<tr><td align=center colspan=11 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet Test Allocation - ('||rcd_retrieve.tde_tes_code||') '||rcd_retrieve.tde_tes_title||'</td></tr>');
         pipe row('<tr>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Status</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Area</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Type</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Size</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Household</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Day</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Report Code</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Market Code</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Market Alias</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Sample</td>');
         pipe row('</tr>');
         pipe row('<tr><td align=center colspan=11></td></tr>');
      else
         pipe row('<table border=1>');
         pipe row('<tr><td align=center colspan=12 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet Test Allocation - ('||rcd_retrieve.tde_tes_code||') '||rcd_retrieve.tde_tes_title||'</td></tr>');
         pipe row('<tr>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Status</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Area</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Type</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Size</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Household</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Day</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Seq</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Report Code</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Market Code</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Market Alias</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Sample</td>');
         pipe row('</tr>');
         pipe row('<tr><td align=center colspan=12></td></tr>');
      end if;

      /*-*/
      /* Retrieve the test panel
      /*-*/
      var_panel := false;
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         /*-*/
         /* Panel found
         /*-*/
         var_panel := true;

         /*-*/
         /* Retrieve the test panel allocation
         /*-*/
         var_first := true;
         var_day := 0;
         open csr_allocation;
         loop
            fetch csr_allocation into rcd_allocation;
            if csr_allocation%notfound then
               exit;
            end if;
            var_output := '<tr>';
            if var_first = true then
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.tpa_pan_status||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_panel.zone_text||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_panel.type_text||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_panel.size_text||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>('||rcd_panel.tpa_pan_code||') '||rcd_panel.tpa_pet_name||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>('||rcd_panel.tpa_hou_code||') '||rcd_panel.tpa_con_fullname||', '||rcd_panel.tpa_loc_street||', '||rcd_panel.tpa_loc_town||'</td>';
            else
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
            end if;
            var_first := false;
            if rcd_retrieve.tde_tes_sam_count = 1 then
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tal_day_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tsa_rpt_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tsa_mkt_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tsa_mkt_acde)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.sample_text)||'</td>';
               var_output := var_output||'</tr>';
            else
               if rcd_allocation.tal_day_code != var_day then
                  var_day := rcd_allocation.tal_day_code;
                  var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tal_day_code)||'</td>';
               else
                  var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               end if;
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tal_seq_numb)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tsa_rpt_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tsa_mkt_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tsa_mkt_acde)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.sample_text)||'</td>';
               var_output := var_output||'</tr>';
            end if;
            pipe row(var_output);
         end loop;
         close csr_allocation;

      end loop;
      close csr_panel;

      /*-*/
      /* No Panel selection
      /*-*/
      if var_panel = false then
         if rcd_retrieve.tde_tes_sam_count = 1 then
            pipe row('<tr><td align=center colspan=11 style="FONT-WEIGHT:bold;">NO PANEL</td></tr>');
         else
            pipe row('<tr><td align=center colspan=12 style="FONT-WEIGHT:bold;">NO PANEL</td></tr>');
         end if;
      end if;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_TES_ALLOCATION - REPORT_ALLOCATION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_allocation;

   /********************************************************/
   /* This procedure performs the retrieve release routine */
   /********************************************************/
   function retrieve_release return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tes_code number;
      var_found boolean;
      var_status varchar2(128);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                t02.tty_typ_target
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

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
      if var_action != '*RTVREL' then
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
      if rcd_retrieve.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') target must be *PET - release update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_status := ' - (*UNKNOWN)';
      if rcd_retrieve.tde_tes_status = 1 then
         var_status := ' - (Raised)';
      elsif rcd_retrieve.tde_tes_status = 2 then
         var_status := ' - (Allocation Completed)';
      elsif rcd_retrieve.tde_tes_status = 3 then
         var_status := ' - (Results Entered)';
      elsif rcd_retrieve.tde_tes_status = 4 then
         var_status := ' - (Closed)';
      elsif rcd_retrieve.tde_tes_status = 9 then
         var_status := ' - (Cancelled)';
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test xml
      /*-*/
      pipe row(pts_xml_object('<TEST TESTXT="('||to_char(rcd_retrieve.tde_tes_code)||') '||pts_to_xml(rcd_retrieve.tde_tes_title)||pts_to_xml(var_status)||'" TESSTA="'||to_char(rcd_retrieve.tde_tes_status)||'"/>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RETRIEVE_RELEASE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_release;

   /******************************************************/
   /* This procedure performs the update release routine */
   /******************************************************/
   procedure update_release(par_user in varchar2) is

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

      cursor csr_target is
         select t01.*
           from pts_tes_type t01
          where t01.tty_tes_type = rcd_retrieve.tde_tes_type;
      rcd_target csr_target%rowtype;

      cursor csr_panel is
         select t01.*
           from pts_tes_panel t01
          where t01.tpa_tes_code = rcd_pts_tes_definition.tde_tes_code;
      rcd_panel csr_panel%rowtype;

      cursor csr_pet is
         select t01.*
           from pts_pet_definition t01
          where t01.pde_tes_code = rcd_pts_tes_definition.tde_tes_code;
      rcd_pet csr_pet%rowtype;

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
      if var_action != '*UPDREL' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_tes_definition.tde_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCDE'));
      rcd_pts_tes_definition.tde_upd_user := upper(par_user);
      rcd_pts_tes_definition.tde_upd_date := sysdate;
      if rcd_pts_tes_definition.tde_tes_code is null then
         pts_gen_function.add_mesg_data('Test code ('||xslProcessor.valueOf(obj_pts_request,'@TESCDE')||') must be a number');
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
      if rcd_retrieve.tde_tes_status != 2 and
         rcd_retrieve.tde_tes_status != 3 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') must be status Allocation Completed or Results Entered - panel release not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the test target
      /*-*/
      var_found := false;
      open csr_target;
      fetch csr_target into rcd_target;
      if csr_target%found then
         var_found := true;
      end if;
      close csr_target;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test type ('||to_char(rcd_retrieve.tde_tes_type)||') does not exist');
      end if;
      if rcd_target.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') target must be *PET - panel release not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the test panel and pets
      /*-*/
      var_found := false;
      open csr_panel;
      fetch csr_panel into rcd_panel;
      if csr_panel%found then
         var_found := true;
      end if;
      close csr_panel;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') does not have a panel selected - panel release not allowed');
      end if;
      var_found := false;
      open csr_pet;
      fetch csr_pet into rcd_pet;
      if csr_pet%found then
         var_found := true;
      end if;
      close csr_pet;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_pts_tes_definition.tde_tes_code) || ') panel has already been released - panel release not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Release any test panel members
      /*-*/
      update pts_pet_definition
         set pde_pet_status = decode(pde_pet_status,2,1,5,3,1),
             pde_tes_code = null
       where pde_tes_code = rcd_pts_tes_definition.tde_tes_code;
      update pts_hou_definition
         set hde_hou_status = decode(hde_hou_status,2,1,5,3,1),
             hde_tes_code = null
       where hde_tes_code = rcd_pts_tes_definition.tde_tes_code;

      /*-*/
      /* Update the test definition
      /*-*/
      update pts_tes_definition
         set tde_upd_user = rcd_pts_tes_definition.tde_upd_user,
             tde_upd_date = rcd_pts_tes_definition.tde_upd_date
       where tde_tes_code = rcd_pts_tes_definition.tde_tes_code;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Send the confirm message
      /*-*/
      pts_gen_function.set_cfrm_data('Test ('||to_char(rcd_pts_tes_definition.tde_tes_code)||') panel households and pets released successfully');

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - UPDATE_RELEASE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_release;

   /************************************************************/
   /* This procedure performs the report questionnaire routine */
   /************************************************************/
   function report_questionnaire(par_tes_code in number) return pts_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_tes_code number;
      var_found boolean;
      var_day_code number;
      var_sam_count number;
      var_output varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                t02.tty_typ_target,
                t02.tty_alc_proc
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_count is
         select count(*) as sam_count
           from pts_tes_sample t01
          where t01.tsa_tes_code = var_tes_code;
      rcd_count csr_count%rowtype;

      cursor csr_panel is
         select t01.*,
                decode(t01.tpa_pan_status,'*MEMBER','1','2') as pan_status,
                nvl(t02.tcl_val_code,0) as pet_size
           from pts_tes_panel t01,
                (select t01.tcl_pan_code,
                        t01.tcl_val_code
                   from pts_tes_classification t01,
                        (select t01.sva_val_code,
                                t01.sva_val_text
                           from pts_sys_value t01
                          where t01.sva_tab_code = '*PET_CLA'
                            and t01.sva_fld_code = 8) t02
                  where t01.tcl_val_code = t02.sva_val_code(+)
                    and t01.tcl_tes_code = rcd_retrieve.tde_tes_code
                    and t01.tcl_tab_code = '*PET_CLA'
                    and t01.tcl_fld_code = 8) t02
          where t01.tpa_pan_code = t02.tcl_pan_code(+)
            and t01.tpa_tes_code = rcd_retrieve.tde_tes_code
          order by t01.tpa_geo_zone asc,
                   t01.tpa_pan_status asc,
                   t01.tpa_pan_code asc;
      rcd_panel csr_panel%rowtype;

      cursor csr_allocation is
         select t01.*,
                nvl(t02.tsa_mkt_code,'*') as tsa_mkt_code,
                nvl(t02.tsa_mkt_acde,'*') as tsa_mkt_acde,
                to_char(nvl(t03.tfe_fed_qnty,0)) as tfe_fed_qnty,
                t03.tfe_fed_text,
                to_char(nvl(t04.sde_uom_size,0))||' '||nvl(t05.sva_val_text,'*UNKNOWN') as size_text
           from pts_tes_allocation t01,
                pts_tes_sample t02,
                (select t01.*
                   from pts_tes_feeding t01
                  where t01.tfe_tes_code = rcd_panel.tpa_tes_code
                    and t01.tfe_pet_size = rcd_panel.pet_size) t03,
                pts_sam_definition t04,
                (select t01.sva_val_code,
                        t01.sva_val_text
                   from pts_sys_value t01
                  where t01.sva_tab_code = '*SAM_DEF'
                    and t01.sva_fld_code = 4) t05
          where t01.tal_tes_code = t02.tsa_tes_code(+)
            and t01.tal_sam_code = t02.tsa_sam_code(+)
            and t02.tsa_tes_code = t03.tfe_tes_code(+)
            and t02.tsa_sam_code = t03.tfe_sam_code(+)
            and t02.tsa_sam_code = t04.sde_sam_code(+)
            and t04.sde_uom_code = t05.sva_val_code(+)
            and t01.tal_tes_code = rcd_panel.tpa_tes_code
            and t01.tal_pan_code = rcd_panel.tpa_pan_code
            and t01.tal_day_code = var_day_code
          order by t01.tal_seq_numb asc;
      rcd_allocation csr_allocation%rowtype;

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
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') does not exist');
      end if;
      if rcd_retrieve.tty_typ_target != 1 then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') target must be *PET - questionnaire report not allowed');
      end if;

      /*-*/
      /* Retrieve the test sample count
      /*-*/
      var_sam_count := 0;
      open csr_count;
      fetch csr_count into rcd_count;
      if csr_count%found then
         var_sam_count := rcd_count.sam_count;
      end if;
      close csr_count;

      /*-*/
      /* Start the report
      /*-*/
      var_output := '"'||'TESTCODE'||'"';
      var_output := var_output||',"'||'TESTTITLE'||'"';
      var_output := var_output||',"'||'AREA'||'"';
      var_output := var_output||',"'||'PETCODE'||'"';
      var_output := var_output||',"'||'PETNAME'||'"';
      var_output := var_output||',"'||'PETSTATUS'||'"';
      var_output := var_output||',"'||'PARTICIPANTNAME'||'"';
      var_output := var_output||',"'||'STREET'||'"';
      var_output := var_output||',"'||'CITYPOSTCODE'||'"';
      var_output := var_output||',"'||'COUNTRY'||'"';
      for idx in 1..rcd_retrieve.tde_tes_day_count loop
         var_output := var_output||',"'||'DAY'||to_char(idx)||'"';
         for idy in 1..rcd_retrieve.tde_tes_sam_count loop
            var_output := var_output||',"'||'D'||to_char(idx)||'MR'||to_char(idy)||'"';
            var_output := var_output||',"'||'D'||to_char(idx)||'QTY'||to_char(idy)||'"';
            var_output := var_output||',"'||'D'||to_char(idx)||'OFF'||to_char(idy)||'"';
            var_output := var_output||',"'||'D'||to_char(idx)||'SIZE'||to_char(idy)||'"';
         end loop;
      end loop;
      pipe row(var_output);

      /*-*/
      /* Retrieve the panel
      /*-*/
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         /*-*/
         /* Output the panel data
         /*-*/
         var_output := '"'||to_char(rcd_retrieve.tde_tes_code)||'"';
         var_output := var_output||',"'||replace(rcd_retrieve.tde_tes_title,'"','""')||'"';
         var_output := var_output||',"'||to_char(rcd_panel.tpa_geo_zone)||'"';
         var_output := var_output||',"'||to_char(rcd_panel.tpa_pet_code)||'"';
         var_output := var_output||',"'||replace(rcd_panel.tpa_pet_name,'"','""')||'"';
         var_output := var_output||',"'||rcd_panel.pan_status||'"';
         var_output := var_output||',"'||replace(rcd_panel.tpa_con_fullname,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_panel.tpa_loc_street,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_panel.tpa_loc_town||' '||rcd_panel.tpa_loc_postcode,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_panel.tpa_loc_country,'"','""')||'"';
         for idx in 1..rcd_retrieve.tde_tes_day_count loop
            var_day_code := idx;
            var_output := var_output||',"'||'Day'||to_char(var_day_code)||'"';
            open csr_allocation;
            loop
               fetch csr_allocation into rcd_allocation;
               if csr_allocation%notfound then
                  exit;
               end if;
               if rcd_panel.tpa_pan_status = '*MEMBER' then
                  var_output := var_output||',"'||replace(rcd_allocation.tal_mkt_code,'"','""')||'"';
               else
                  var_output := var_output||',""';
               end if;
               var_output := var_output||',"'||to_char(rcd_allocation.tfe_fed_qnty)||'"';
               var_output := var_output||',"'||replace(rcd_allocation.tfe_fed_text,'"','""')||'"';
               var_output := var_output||',"'||replace(rcd_allocation.size_text,'"','""')||'"';
            end loop;
            close csr_allocation;
         end loop;
         pipe row(var_output);

      end loop;
      close csr_panel;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_TES_FUNCTION - REPORT_QUESTIONNAIRE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_questionnaire;

   /********************************************************/
   /* This procedure performs the report selection routine */
   /********************************************************/
   function report_selection(par_tes_code in number) return pts_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_tes_code number;
      var_found boolean;
      var_panel boolean;
      var_geo_zone number;
      var_index number;
      var_sam_count number;
      var_output varchar2(4000 char);

      /*-*/
      /* Local arrays
      /*-*/
      type rcd_sdta is record(mkt_code varchar2(1 char),
                              sam_iden varchar2(20 char),
                              pan_seqn number,
                              pan_qnty number,
                              ara_qnty number,
                              tot_qnty number);
      type typ_sdta is table of rcd_sdta index by binary_integer;
      tbl_sdta typ_sdta;
      type typ_pdta is table of integer index by binary_integer;
      tbl_pdta typ_pdta;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                t02.tty_typ_target,
                t02.tty_alc_proc
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_sample is
         select nvl(t01.tsa_mkt_code,'*') as tsa_mkt_code,
                nvl(t01.tsa_mkt_acde,'*') as tsa_mkt_acde,
                nvl(t01.tsa_sam_iden,'*') as tsa_sam_iden
           from pts_tes_sample t01
          where t01.tsa_tes_code = rcd_retrieve.tde_tes_code
          order by t01.tsa_mkt_code asc;
      rcd_sample csr_sample%rowtype;

      cursor csr_check_allocation is
         select t01.*
           from pts_tes_allocation t01
          where t01.tal_tes_code = rcd_retrieve.tde_tes_code;
      rcd_check_allocation csr_check_allocation%rowtype;

      cursor csr_panel is
         select t01.*,
                decode(t02.pty_pet_type,null,'*UNKNOWN',t02.pty_typ_text) as type_text,
                decode(t03.tcl_val_code,null,'*UNKNOWN',t03.size_text) as size_text,
                nvl(t03.tcl_val_code,0) as pet_size
           from pts_tes_panel t01,
                pts_pet_type t02,
                (select t01.tcl_pan_code,
                        t01.tcl_val_code,
                        nvl(t02.sva_val_text,'*UNKNOWN') as size_text
                   from pts_tes_classification t01,
                        (select t01.sva_val_code,
                                t01.sva_val_text
                           from pts_sys_value t01
                          where t01.sva_tab_code = '*PET_CLA'
                            and t01.sva_fld_code = 8) t02
                  where t01.tcl_val_code = t02.sva_val_code(+)
                    and t01.tcl_tes_code = rcd_retrieve.tde_tes_code
                    and t01.tcl_tab_code = '*PET_CLA'
                    and t01.tcl_fld_code = 8) t03
          where t01.tpa_pet_type = t02.pty_pet_type(+)
            and t01.tpa_pan_code = t03.tcl_pan_code(+)
            and t01.tpa_tes_code = rcd_retrieve.tde_tes_code
          order by t01.tpa_geo_zone asc,
                   t01.tpa_pan_status asc,
                   t01.tpa_hou_code asc,
                   t01.tpa_pan_code asc;
      rcd_panel csr_panel%rowtype;

      cursor csr_allocation is
         select t01.tal_day_code,
                t01.tal_mkt_code,
                nvl(t02.tsa_mkt_code,'*') as tsa_mkt_code,
                nvl(t02.tsa_mkt_acde,'*') as tsa_mkt_acde,
                nvl(t02.tsa_sam_iden,'*') as tsa_sam_iden,
                nvl(t03.tfe_fed_qnty,0) as tfe_fed_qnty
           from pts_tes_allocation t01,
                pts_tes_sample t02,
                (select t01.*
                   from pts_tes_feeding t01
                  where t01.tfe_tes_code = rcd_panel.tpa_tes_code
                    and t01.tfe_pet_size = rcd_panel.pet_size) t03
          where t01.tal_tes_code = t02.tsa_tes_code(+)
            and t01.tal_sam_code = t02.tsa_sam_code(+)
            and t02.tsa_tes_code = t03.tfe_tes_code(+)
            and t02.tsa_sam_code = t03.tfe_sam_code(+)
            and t01.tal_tes_code = rcd_panel.tpa_tes_code
            and t01.tal_pan_code = rcd_panel.tpa_pan_code
          order by t01.tal_day_code asc,
                   t01.tal_seq_numb asc;
      rcd_allocation csr_allocation%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameters
      /*-*/
      var_tes_code := par_tes_code;

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
         raise_application_error(-20000, 'Test code ('||to_char(var_tes_code)||') does not exist');
      end if;
      if rcd_retrieve.tty_typ_target != 1 then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') target must be *PET - selection report not allowed');
      end if;

      /*-*/
      /* Check for allocation
      /*-*/
      var_found := false;
      open csr_check_allocation;
      fetch csr_check_allocation into rcd_check_allocation;
      if csr_check_allocation%found then
         var_found := true;
      end if;
      close csr_check_allocation;
      if var_found = false then
         pipe row('<table border=1>');
         pipe row('<tr><td align=center colspan=6></td></tr>');
         pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet Test Selection - ('||rcd_retrieve.tde_tes_code||') '||rcd_retrieve.tde_tes_title||'</td></tr>');
         pipe row('<tr><td align=center colspan=6></td></tr>');
         pipe row('<tr><td align=center colspan=6 style="FONT-WEIGHT:bold;">NO ALLOCATION</td></tr>');
         pipe row('</table>');
         return;
      end if;

      /*-*/
      /* Load the sample array
      /*-*/
      tbl_sdta.delete;
      open csr_sample;
      loop
         fetch csr_sample into rcd_sample;
         if csr_sample%notfound then
            exit;
         end if;
         tbl_sdta(tbl_sdta.count+1).mkt_code := rcd_sample.tsa_mkt_code;
         tbl_sdta(tbl_sdta.count).sam_iden := rcd_sample.tsa_sam_iden;
         tbl_sdta(tbl_sdta.count).pan_seqn := 0;
         tbl_sdta(tbl_sdta.count).pan_qnty := 0;
         tbl_sdta(tbl_sdta.count).ara_qnty := 0;
         tbl_sdta(tbl_sdta.count).tot_qnty := 0;
      end loop;
      close csr_sample;
      var_sam_count := tbl_sdta.count;
      if rcd_retrieve.tde_tes_sam_count = 2 or (upper(rcd_retrieve.tty_alc_proc) = 'RANKING' and rcd_retrieve.tde_tes_day_count > var_sam_count) then
         open csr_sample;
         loop
            fetch csr_sample into rcd_sample;
            if csr_sample%notfound then
               exit;
            end if;
            tbl_sdta(tbl_sdta.count+1).mkt_code := rcd_sample.tsa_mkt_acde;
            tbl_sdta(tbl_sdta.count).sam_iden := rcd_sample.tsa_sam_iden;
            tbl_sdta(tbl_sdta.count).pan_seqn := 0;
            tbl_sdta(tbl_sdta.count).pan_qnty := 0;
            tbl_sdta(tbl_sdta.count).ara_qnty := 0;
            tbl_sdta(tbl_sdta.count).tot_qnty := 0;
         end loop;
         close csr_sample;
      end if;

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<table border=1>');

      /*-*/
      /* Retrieve the test panel
      /*-*/
      var_panel := false;
      var_geo_zone := -1;
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         /*-*/
         /* Panel found
         /*-*/
         var_panel := true;

         /*-*/
         /* Area change
         /*-*/
         if rcd_panel.tpa_geo_zone != var_geo_zone then

            /*-*/
            /* Process area total when required
            /*-*/
            if var_geo_zone != -1 then
               pipe row('<tr><td align=center colspan=6></td></tr>');
               pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Area - ('||var_geo_zone||') Sample Totals</td></tr>');
               for idx in 1..tbl_sdta.count loop
                  pipe row('<tr>');
                  pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
                  pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||tbl_sdta(idx).mkt_code||'</td>');
                  pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(tbl_sdta(idx).ara_qnty)||'</td>');
                  pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
                  pipe row('</tr>');
               end loop;
               pipe row('<tr><td align=center colspan=6></td></tr>');
            end if;
            var_geo_zone := rcd_panel.tpa_geo_zone;

            /*-*/
            /* Output the new area heading
            /*-*/
            pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet Test Selection - ('||rcd_retrieve.tde_tes_code||') '||rcd_retrieve.tde_tes_title||'</td></tr>');
            pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Area - ('||rcd_panel.tpa_geo_zone||')</td></tr>');
            pipe row('<tr>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet</td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Name</td>');
            pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">MR/Qty</td>');
            pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Household</td>');
            pipe row('</tr>');

            /*-*/
            /* Reset the area totals
            /*-*/
            for idx in 1..tbl_sdta.count loop
               tbl_sdta(idx).ara_qnty := 0;
            end loop;

         end if;

         /*-*/
         /* Clear the panel array
         /*-*/
         for idx in 1..tbl_sdta.count loop
            tbl_sdta(idx).pan_seqn := 0;
            tbl_sdta(idx).pan_qnty := 0;
         end loop;

         /*-*/
         /* Process member allocation only
         /*-*/
         if rcd_panel.tpa_pan_status = '*MEMBER' then

            /*-*/
            /* Retrieve the test panel allocation
            /*-*/
            var_index := 0;
            open csr_allocation;
            loop
               fetch csr_allocation into rcd_allocation;
               if csr_allocation%notfound then
                  exit;
               end if;
               for idx in 1..tbl_sdta.count loop
                  if tbl_sdta(idx).mkt_code = rcd_allocation.tal_mkt_code then
                     if tbl_sdta(idx).pan_seqn = 0 then
                        var_index := var_index + 1;
                        tbl_sdta(idx).pan_seqn := var_index;
                     end if;
                     tbl_sdta(idx).pan_qnty := tbl_sdta(idx).pan_qnty + rcd_allocation.tfe_fed_qnty;
                     tbl_sdta(idx).ara_qnty := tbl_sdta(idx).ara_qnty + rcd_allocation.tfe_fed_qnty;
                     tbl_sdta(idx).tot_qnty := tbl_sdta(idx).tot_qnty + rcd_allocation.tfe_fed_qnty;
                  end if;
               end loop;
            end loop;
            close csr_allocation;

            /*-*/
            /* Sort the panel data
            /*-*/
            tbl_pdta.delete;
            for idx in 1..tbl_sdta.count loop
               if tbl_sdta(idx).pan_seqn != 0 then
                  tbl_pdta(tbl_sdta(idx).pan_seqn) := idx;
               end if;
            end loop;

         end if;

         /*-*/
         /* Output the panel line 1
         /*-*/
         pipe row('<tr><td align=center colspan=6></td></tr>');
         pipe row('<tr>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_panel.tpa_pan_code)||'</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.tpa_pet_name||'</td>');
         if rcd_panel.tpa_pan_status = '*MEMBER' and tbl_pdta.count >= 1 then
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||tbl_sdta(tbl_pdta(1)).mkt_code||'</td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(tbl_sdta(tbl_pdta(1)).pan_qnty)||'</td>');
         else
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
         end if;
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_panel.tpa_hou_code)||'</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.tpa_con_fullname||'</td>');
         pipe row('</tr>');

         /*-*/
         /* Output the panel line 2
         /*-*/
         pipe row('<tr>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.tpa_pan_status||'</td>');
         if rcd_panel.tpa_pan_status = '*MEMBER' and tbl_pdta.count >= 2 then
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||tbl_sdta(tbl_pdta(2)).mkt_code||'</td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(tbl_sdta(tbl_pdta(2)).pan_qnty)||'</td>');
         else
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
         end if;
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.tpa_loc_street||'</td>');
         pipe row('</tr>');

         /*-*/
         /* Output the panel line 3
         /*-*/
         pipe row('<tr>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.size_text||'</td>');
         if rcd_panel.tpa_pan_status = '*MEMBER' and tbl_pdta.count >= 3 then
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||tbl_sdta(tbl_pdta(3)).mkt_code||'</td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(tbl_sdta(tbl_pdta(3)).pan_qnty)||'</td>');
         else
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
         end if;
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.tpa_loc_town||' '||rcd_panel.tpa_loc_postcode||'</td>');
         pipe row('</tr>');

         /*-*/
         /* Output the panel line 4
         /*-*/
         pipe row('<tr>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
         if rcd_panel.tpa_pan_status = '*MEMBER' and tbl_pdta.count >= 4 then
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||tbl_sdta(tbl_pdta(4)).mkt_code||'</td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(tbl_sdta(tbl_pdta(4)).pan_qnty)||'</td>');
         else
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
         end if;
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.tpa_tel_number||'</td>');
         pipe row('</tr>');

         /*-*/
         /* Output the additional panel line data
         /*-*/
         if rcd_panel.tpa_pan_status = '*MEMBER' and tbl_pdta.count > 4 then
            for idx in 5..tbl_pdta.count loop
               pipe row('<tr>');
               pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
               pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
               pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||tbl_sdta(tbl_pdta(idx)).mkt_code||'</td>');
               pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(tbl_sdta(tbl_pdta(idx)).pan_qnty)||'</td>');
               pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
               pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
               pipe row('</tr>');
            end loop;
         end if;

      end loop;
      close csr_panel;

      /*-*/
      /* Panel selection
      /*-*/
      if var_panel = true then

         /*-*/
         /* Process area total when required
         /*-*/
         pipe row('<tr><td align=center colspan=6></td></tr>');
         pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Area - ('||var_geo_zone||') Sample Totals</td></tr>');
         for idx in 1..tbl_sdta.count loop
            pipe row('<tr>');
            pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||tbl_sdta(idx).mkt_code||'</td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(tbl_sdta(idx).ara_qnty)||'</td>');
            pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            pipe row('</tr>');
         end loop;

         /*-*/
         /* Process grand total
         /*-*/
         pipe row('<tr><td align=center colspan=6></td></tr>');
         pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Grand Totals</td></tr>');
         for idx in 1..tbl_sdta.count loop
            pipe row('<tr>');
            pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||tbl_sdta(idx).mkt_code||'</td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(tbl_sdta(idx).tot_qnty)||'</td>');
            pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            pipe row('</tr>');
         end loop;

      end if;

      /*-*/
      /* No Panel selection
      /*-*/
      if var_panel = false then
         pipe row('<tr><td align=center colspan=6></td></tr>');
         pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet Test Selection - ('||rcd_retrieve.tde_tes_code||') '||rcd_retrieve.tde_tes_title||'</td></tr>');
         pipe row('<tr><td align=center colspan=6></td></tr>');
         pipe row('<tr><td align=center colspan=6 style="FONT-WEIGHT:bold;">NO PANEL SELECTION</td></tr>');
      end if;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_TES_ALLOCATION - REPORT_SELECTION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_selection;

   /**************************************************************/
   /* This procedure performs the retrieve report fields routine */
   /**************************************************************/
   function retrieve_report_fields return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_tes_code number;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                t02.tty_typ_target
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_field is
         select t01.sfi_tab_code,
                t01.sfi_fld_code,
                t01.sfi_fld_text
           from pts_sys_field t01
          where t01.sfi_tab_code = '*PET_CLA'
            and t01.sfi_fld_status = '1'
            and t01.sfi_fld_sel_type in ('*OPT_SINGLE_LIST','*MAN_SINGLE_LIST')
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
      if var_action != '*GETFLD' then
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
      if rcd_retrieve.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') target must be *PET - report field retrieve not allowed');
      end if;
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
      pipe row(pts_xml_object('<TEST TESTXT="('||to_char(rcd_retrieve.tde_tes_code)||') '||pts_to_xml(rcd_retrieve.tde_tes_title)||'"/>'));

      /*-*/
      /* Pipe the pet classification XML
      /*-*/
      open csr_field;
      loop
         fetch csr_field into rcd_field;
         if csr_field%notfound then
         exit;
         end if;
         pipe row(pts_xml_object('<FIELD TABCDE="'||rcd_field.sfi_tab_code||'" FLDCDE="'||to_char(rcd_field.sfi_fld_code)||'" FLDTXT="'||pts_to_xml(rcd_field.sfi_fld_text)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RETRIEVE_REPORT_FIELDS - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_report_fields;

   /******************************************************/
   /* This procedure performs the report results routine */
   /******************************************************/
   function report_results(par_tes_code in number) return pts_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_tes_code number;
      var_found boolean;
      var_day_code number;
      var_wgt_bowl number;
      var_wgt_offer number;
      var_wgt_remain number;
      var_wgt_eaten number;
      var_per_eaten number;
      var_per_refuse number;
      var_output varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                t02.tty_typ_target,
                t02.tty_alc_proc
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_question is
         select t01.tqu_que_code,
                max(t02.qde_rsp_type) as qde_rsp_type,
                0 as tre_res_value,
                max(qde_que_text) as qre_res_text
           from pts_tes_question t01,
                pts_que_definition t02
          where t01.tqu_que_code = t02.qde_que_code(+)
            and t01.tqu_tes_code = rcd_retrieve.tde_tes_code
          group by t01.tqu_que_code
          order by t01.tqu_que_code asc;

      cursor csr_classification is
         select t01.sfi_tab_code,
                t01.sfi_fld_code,
                t01.sfi_fld_text,
                t01.sfi_fld_text as val_text
           from pts_sys_field t01
          where (t01.sfi_tab_code, t01.sfi_fld_code) in (select wtf_tab_code, wtf_fld_code from pts_wor_tab_field)
          order by t01.sfi_fld_text asc;

      cursor csr_panel is
         select t01.*,
                nvl(t02.gzo_zon_text,'*UNKNOWN') as gzo_zon_text,
                nvl(t03.pty_typ_text,'*UNKNOWN') pty_typ_text,
                nvl(t04.tcl_val_code,0) as pet_size
           from pts_tes_panel t01,
                pts_geo_zone t02,
                pts_pet_type t03,
                (select t01.tcl_pan_code,
                        t01.tcl_val_code
                   from pts_tes_classification t01,
                        (select t01.sva_val_code,
                                t01.sva_val_text
                           from pts_sys_value t01
                          where t01.sva_tab_code = '*PET_CLA'
                            and t01.sva_fld_code = 8) t02
                  where t01.tcl_val_code = t02.sva_val_code(+)
                    and t01.tcl_tes_code = rcd_retrieve.tde_tes_code
                    and t01.tcl_tab_code = '*PET_CLA'
                    and t01.tcl_fld_code = 8) t04
          where t01.tpa_geo_type = t02.gzo_geo_type(+)
            and t01.tpa_geo_zone = t02.gzo_geo_zone(+)
            and t01.tpa_pet_type = t03.pty_pet_type(+)
            and t01.tpa_pan_code = t04.tcl_pan_code(+)
            and t01.tpa_tes_code = rcd_retrieve.tde_tes_code
          order by t01.tpa_geo_zone asc,
                   t01.tpa_pan_code asc;
      rcd_panel csr_panel%rowtype;

      cursor csr_panel_classification is
         select t01.tcl_tab_code,
                t01.tcl_fld_code,
                 nvl(t02.sva_val_text,t01.tcl_val_text) as val_text
           from pts_tes_classification t01,
                pts_sys_value t02
          where t01.tcl_tab_code = t02.sva_tab_code(+)
            and t01.tcl_fld_code = t02.sva_fld_code(+)
            and t01.tcl_val_code = t02.sva_val_code(+)
            and t01.tcl_tes_code = rcd_panel.tpa_tes_code
            and t01.tcl_pan_code = rcd_panel.tpa_pan_code
            and (t01.tcl_tab_code,t01.tcl_fld_code) in (select wtf_tab_code, wtf_fld_code from pts_wor_tab_field)
          order by t01.tcl_tab_code asc,
                   t01.tcl_fld_code asc;
      rcd_panel_classification csr_panel_classification%rowtype;

      cursor csr_allocation is
         select t01.*,
                nvl(t02.tsa_rpt_code,'***') as tsa_rpt_code,
                to_char(nvl(t03.tfe_fed_qnty,0)) as tfe_fed_qnty
           from pts_tes_allocation t01,
                pts_tes_sample t02,
                (select t01.*
                   from pts_tes_feeding t01
                  where t01.tfe_tes_code = rcd_panel.tpa_tes_code
                    and t01.tfe_pet_size = rcd_panel.pet_size) t03
          where t01.tal_tes_code = t02.tsa_tes_code(+)
            and t01.tal_sam_code = t02.tsa_sam_code(+)
            and t02.tsa_tes_code = t03.tfe_tes_code(+)
            and t02.tsa_sam_code = t03.tfe_sam_code(+)
            and t01.tal_tes_code = rcd_panel.tpa_tes_code
            and t01.tal_pan_code = rcd_panel.tpa_pan_code
            and t01.tal_day_code = var_day_code
          order by t01.tal_seq_numb asc;
      rcd_allocation csr_allocation%rowtype;

      cursor csr_response is
         select t01.tre_que_code,
                t01.tre_res_value,
                t02.qre_res_text
           from pts_tes_response t01,
                pts_que_response t02
          where t01.tre_que_code = t02.qre_que_code(+)
            and t01.tre_res_value = t02.qre_res_code(+)
            and t01.tre_tes_code = rcd_allocation.tal_tes_code
            and t01.tre_pan_code = rcd_allocation.tal_pan_code
            and t01.tre_day_code = rcd_allocation.tal_day_code
            and (t01.tre_sam_code = 0 or t01.tre_sam_code = rcd_allocation.tal_sam_code)
          order by t01.tre_que_code asc;
      rcd_response csr_response%rowtype;

      /*-*/
      /* Local arrays
      /*-*/
      type typ_qary is table of csr_question%rowtype index by binary_integer;
      tbl_qary typ_qary;
      type typ_cary is table of csr_classification%rowtype index by binary_integer;
      tbl_cary typ_cary;

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
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') does not exist');
      end if;
      if rcd_retrieve.tty_typ_target != 1 then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') target must be *PET - results report not allowed');
      end if;

      /*-*/
      /* Retrieve and load the discreet question array
      /*-*/
      tbl_qary.delete;
      open csr_question;
      fetch csr_question bulk collect into tbl_qary;
      close csr_question;

      /*-*/
      /* Retrieve and load the classification array
      /*-*/
      tbl_cary.delete;
      open csr_classification;
      fetch csr_classification bulk collect into tbl_cary;
      close csr_classification;

      /*-*/
      /* Start the report
      /*-*/
      var_output := '"'||'Test'||'"';
      var_output := var_output||',"'||'Pet'||'"';
      var_output := var_output||',"'||'Sample'||'"';
      var_output := var_output||',"'||'Sequence'||'"';
      var_output := var_output||',"'||'Day'||'"';
      var_output := var_output||',"'||'Offered Qty'||'"';
      for idx in 1..tbl_qary.count loop
         var_output := var_output||',"'||'Q'||to_char(tbl_qary(idx).tqu_que_code)||'"';
      end loop;
      if rcd_retrieve.tde_wgt_que_calc = '1' then
         var_output := var_output||',"'||'Weight Eaten'||'"';
         var_output := var_output||',"'||'% Eaten'||'"';
         if upper(trim(rcd_retrieve.tty_alc_proc)) != 'DIFFERENCE' then
            var_output := var_output||',"'||'<=5% Refusals'||'"';
         end if;
      end if;
      var_output := var_output||',"'||'Area'||'"';
      var_output := var_output||',"'||'Pet Type'||'"';
      for idx in 1..tbl_cary.count loop
         var_output := var_output||',"'||tbl_cary(idx).sfi_fld_text||'"';
      end loop;
      pipe row(var_output);

      /*-*/
      /* Retrieve the panel
      /*-*/
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         /*-*/
         /* Set the classification array text
         /*-*/
         for idx in 1..tbl_cary.count loop
            tbl_cary(idx).val_text := null;
         end loop;
         open csr_panel_classification;
         loop
            fetch csr_panel_classification into rcd_panel_classification;
            if csr_panel_classification%notfound then
               exit;
            end if;
            for idx in 1..tbl_cary.count loop
               if (tbl_cary(idx).sfi_tab_code = rcd_panel_classification.tcl_tab_code and
                   tbl_cary(idx).sfi_fld_code = rcd_panel_classification.tcl_fld_code) then
                  tbl_cary(idx).val_text := rcd_panel_classification.val_text;
                  exit;
               end if;
            end loop;
         end loop;
         close csr_panel_classification;

         /*-*/
         /* Output the panel data
         /*-*/
         for idx in 1..rcd_retrieve.tde_tes_day_count loop
            var_day_code := idx;
            open csr_allocation;
            loop
               fetch csr_allocation into rcd_allocation;
               if csr_allocation%notfound then
                  exit;
               end if;
               var_output := '"'||to_char(rcd_retrieve.tde_tes_code)||'"';
               var_output := var_output||',"'||to_char(rcd_panel.tpa_pet_code)||'"';
               var_output := var_output||',"'||replace(rcd_allocation.tsa_rpt_code,'"','""')||'"';
               var_output := var_output||',"'||to_char(rcd_allocation.tal_seq_numb)||'"';
               var_output := var_output||',"'||to_char(var_day_code)||'"';
               var_output := var_output||',"'||to_char(rcd_allocation.tfe_fed_qnty)||'"';
               if rcd_retrieve.tde_wgt_que_calc = '1' then
                  var_wgt_bowl := null;
                  var_wgt_offer := null;
                  var_wgt_remain := null;
               end if;
               for idy in 1..tbl_qary.count loop
                  tbl_qary(idy).tre_res_value := null;
                  tbl_qary(idy).qre_res_text := null;
               end loop;
               open csr_response;
               loop
                  fetch csr_response into rcd_response;
                  if csr_response%notfound then
                     exit;
                  end if;
                  if rcd_retrieve.tde_wgt_que_calc = '1' then
                     if rcd_response.tre_que_code = rcd_retrieve.tde_wgt_que_bowl then
                        var_wgt_bowl := nvl(rcd_response.tre_res_value,0);
                     elsif rcd_response.tre_que_code = rcd_retrieve.tde_wgt_que_offer then
                        var_wgt_offer := nvl(rcd_response.tre_res_value,0);
                     elsif rcd_response.tre_que_code = rcd_retrieve.tde_wgt_que_remain then
                        var_wgt_remain := nvl(rcd_response.tre_res_value,0);
                     end if;
                  end if;
                  for idy in 1..tbl_qary.count loop
                     if tbl_qary(idy).tqu_que_code = rcd_response.tre_que_code then
                        tbl_qary(idy).tre_res_value := rcd_response.tre_res_value;
                        tbl_qary(idy).qre_res_text := rcd_response.qre_res_text;
                        exit;
                     end if;
                  end loop;
               end loop;
               close csr_response;
               for idy in 1..tbl_qary.count loop
                  if tbl_qary(idy).qde_rsp_type = 1 then
                     var_output := var_output||',"'||nvl(tbl_qary(idy).qre_res_text,'n/a')||'"';
                  else
                     var_output := var_output||',"'||nvl(to_char(tbl_qary(idy).tre_res_value),'n/a')||'"';
                  end if;
               end loop;
               if rcd_retrieve.tde_wgt_que_calc = '1' then
                  if var_wgt_bowl is null or var_wgt_offer is null or var_wgt_remain is null then
                     var_output := var_output||',"n/a"';
                     var_output := var_output||',"n/a"';
                     if upper(trim(rcd_retrieve.tty_alc_proc)) != 'DIFFERENCE' then
                        var_output := var_output||',"n/a"';
                     end if;
                  else
                     var_wgt_eaten := (var_wgt_bowl + var_wgt_offer) - var_wgt_remain;
                     var_per_eaten := 0;
                     if var_wgt_offer != 0 then
                        var_per_eaten := round((var_wgt_eaten / var_wgt_offer) * 100,0);
                     end if;
                     var_per_refuse := 0;
                     if var_per_eaten <= 5 then
                        var_per_refuse := 100;
                     end if;
                     var_output := var_output||',"'||to_char(var_wgt_eaten)||'"';
                     var_output := var_output||',"'||to_char(var_per_eaten)||'"';
                     if upper(trim(rcd_retrieve.tty_alc_proc)) != 'DIFFERENCE' then
                        var_output := var_output||',"'||to_char(var_per_refuse)||'"';
                     end if;
                  end if;
               end if;
               var_output := var_output||',"'||replace(rcd_panel.gzo_zon_text,'"','""')||'"';
               var_output := var_output||',"'||replace(rcd_panel.pty_typ_text,'"','""')||'"';
               for idy in 1..tbl_cary.count loop
                  var_output := var_output||',"'||replace(tbl_cary(idy).val_text,'"','""')||'"';
               end loop;
               pipe row(var_output);
            end loop;
            close csr_allocation;
         end loop;

      end loop;
      close csr_panel;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_TES_FUNCTION - REPORT_RESULTS - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_results;

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
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                t02.tty_typ_target
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = var_tes_code;
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

      cursor csr_panel is
         select t01.*,
                decode(t02.tre_pan_code,null,'0','1') as res_status
           from pts_tes_panel t01,
                (select distinct(t01.tre_pan_code) as tre_pan_code
                        from pts_tes_response t01
                       where t01.tre_tes_code = var_tes_code) t02
          where t01.tpa_pan_code = t02.tre_pan_code
            and t01.tpa_tes_code = var_tes_code
          order by t01.tpa_geo_zone asc,
                   t01.tpa_pan_status asc,
                   t01.tpa_pan_code asc;
      rcd_panel csr_panel%rowtype;

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
      if rcd_retrieve.tde_tes_status != 2 and
         rcd_retrieve.tde_tes_status != 3 and
         rcd_retrieve.tde_tes_status != 4 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') must be status Allocation Completed, Results Entered or Closed - response update not allowed');
      end if;
      if rcd_retrieve.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') target must be *PET - response update not allowed');
      end if;
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
      pipe row(pts_xml_object('<TEST TESTXT="('||to_char(rcd_retrieve.tde_tes_code)||') '||pts_to_xml(rcd_retrieve.tde_tes_title)||'" TESSAM="'||to_char(rcd_retrieve.tde_tes_sam_count)||'"/>'));

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
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<PANEL PANCDE="'||to_char(rcd_panel.tpa_pan_code)||'" PANSTS="'||pts_to_xml(rcd_panel.tpa_pan_status)||'" PANTXT="'||pts_to_xml('('||to_char(rcd_panel.tpa_pan_code)||') '||rcd_panel.tpa_pet_name||' - Household ('||rcd_panel.tpa_hou_code||') '||rcd_panel.tpa_con_fullname||', '||rcd_panel.tpa_loc_street||', '||rcd_panel.tpa_loc_town)||'" RESSTS="'||pts_to_xml(rcd_panel.res_status)||'"/>'));
      end loop;
      close csr_panel;

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
         select t01.*,
                t02.tty_typ_target
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_panel is
         select t01.*,
                decode(t02.tre_pan_code,null,'0','1') as res_status
           from pts_tes_panel t01,
                (select distinct(t01.tre_pan_code) as tre_pan_code
                        from pts_tes_response t01
                       where t01.tre_tes_code = var_tes_code) t02
          where t01.tpa_pan_code = t02.tre_pan_code
            and t01.tpa_tes_code = var_tes_code
          order by t01.tpa_geo_zone asc,
                   t01.tpa_pan_status asc,
                   t01.tpa_pan_code asc;
      rcd_panel csr_panel%rowtype;

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
      if rcd_retrieve.tde_tes_status != 2 and
         rcd_retrieve.tde_tes_status != 3 and
         rcd_retrieve.tde_tes_status != 4 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') must be status Allocation Completed, Results Entered or Closed - response update not allowed');
      end if;
      if rcd_retrieve.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') target must be *PET - response update not allowed');
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
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<PANEL PANCDE="'||to_char(rcd_panel.tpa_pan_code)||'" PANSTS="'||pts_to_xml(rcd_panel.tpa_pan_status)||'" PANTXT="'||pts_to_xml('('||to_char(rcd_panel.tpa_pan_code)||') '||rcd_panel.tpa_pet_name||' - Household ('||rcd_panel.tpa_hou_code||') '||rcd_panel.tpa_con_fullname||', '||rcd_panel.tpa_loc_street||', '||rcd_panel.tpa_loc_town)||'" RESSTS="'||pts_to_xml(rcd_panel.res_status)||'"/>'));
      end loop;
      close csr_panel;

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
         select t01.*,
                t02.tty_typ_target
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_allocation is
         select t01.*
           from pts_tes_allocation t01
          where t01.tal_tes_code = var_tes_code
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
      if rcd_retrieve.tde_tes_status != 2 and
         rcd_retrieve.tde_tes_status != 3 and
         rcd_retrieve.tde_tes_status != 4 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') must be status Allocation Completed, Results Entered or Closed - response update not allowed');
      end if;
      if rcd_retrieve.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') target must be *PET - response update not allowed');
      end if;
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
            pipe row(pts_xml_object('<RESD DAYCDE="'||to_char(var_day_code)||'" RESSEQ="'||to_char(var_seq_numb)||'" MKTCDE="'||pts_to_xml(rcd_allocation.tal_mkt_code)||'"/>'));
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
      var_sam_count number;
      var_mon_count number;
      var_wrk_count number;
      var_tes_code number;
      var_pan_code number;
      var_day_code number;
      var_mkt_code varchar2(10);
      var_sam_cod1 number;
      var_sam_cod2 number;
      var_seq_numb number;
      var_que_code number;
      var_res_value number;
      var_wgt_bowl1 number;
      var_wgt_offer1 number;
      var_wgt_remain1 number;
      var_wgt_bowl2 number;
      var_wgt_offer2 number;
      var_wgt_remain2 number;
      var_typ_code varchar2(10 char);
      var_found boolean;
      var_message boolean;
      var_exists boolean;
      var_member boolean;
      type typ_mktcde is table of varchar2(10) index by binary_integer;
      tbl_mktcde typ_mktcde;
      type rcd_alcdat is record(day_code number,
                                seq_numb number,
                                sam_code number,
                                mkt_code varchar2(10));
      type typ_alcdat is table of rcd_alcdat index by binary_integer;
      tbl_alcdat typ_alcdat;
      rcd_pts_tes_panel pts_tes_panel%rowtype;
      rcd_pts_tes_statistic pts_tes_statistic%rowtype;
      rcd_pts_tes_classification pts_tes_classification%rowtype;
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

      cursor csr_target is
         select t01.*
           from pts_tes_type t01
          where t01.tty_tes_type = rcd_retrieve.tde_tes_type;
      rcd_target csr_target%rowtype;

      cursor csr_count is
         select count(*) as sam_count
           from pts_tes_sample t01
          where t01.tsa_tes_code = var_tes_code;
      rcd_count csr_count%rowtype;

      cursor csr_panel is
         select t01.*
           from pts_tes_panel t01
          where t01.tpa_tes_code = var_tes_code
            and t01.tpa_pan_code = var_pan_code;
      rcd_panel csr_panel%rowtype;

      cursor csr_pet is
         select t01.*,
                t02.*
           from pts_pet_definition t01,
                pts_hou_definition t02
          where t01.pde_hou_code = t02.hde_hou_code
            and t01.pde_pet_code = var_pan_code;
      rcd_pet csr_pet%rowtype;

      cursor csr_pet_stat is
         select t01.pde_pet_type,
                count(*) as typ_count
           from pts_pet_definition t01
          where t01.pde_hou_code = rcd_pet.pde_hou_code
            and not(t01.pde_pet_status in (4,9))
          group by t01.pde_pet_type;
      rcd_pet_stat csr_pet_stat%rowtype;

      cursor csr_pet_class is
         select t01.*
           from pts_pet_classification t01
          where t01.pcl_pet_code = var_pan_code;
      rcd_pet_class csr_pet_class%rowtype;

      cursor csr_allocation is
         select t01.*
           from pts_tes_allocation t01
          where t01.tal_tes_code = var_tes_code
            and t01.tal_pan_code = var_pan_code
          order by t01.tal_day_code asc,
                   t01.tal_seq_numb asc;
      rcd_allocation csr_allocation%rowtype;

      cursor csr_sample is
         select t01.*
           from pts_tes_sample t01
          where t01.tsa_tes_code = var_tes_code
            and (t01.tsa_mkt_code = var_mkt_code or t01.tsa_mkt_acde = var_mkt_code);
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
      if rcd_retrieve.tde_tes_status != 2 and
         rcd_retrieve.tde_tes_status != 3 and
         rcd_retrieve.tde_tes_status != 4 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') must be status Allocation Completed, Results Entered or Closed - response update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the test target
      /*-*/
      var_found := false;
      open csr_target;
      fetch csr_target into rcd_target;
      if csr_target%found then
         var_found := true;
      end if;
      close csr_target;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test type ('||to_char(rcd_retrieve.tde_tes_type)||') does not exist');
      end if;
      if rcd_target.tty_typ_target != 1 then
         pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_retrieve.tde_tes_code) || ') target must be *PET - response update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the test sample count
      /*-*/
      var_mon_count := 1;
      var_sam_count := 0;
      open csr_count;
      fetch csr_count into rcd_count;
      if csr_count%found then
         var_sam_count := rcd_count.sam_count;
      end if;
      close csr_count;
      if upper(rcd_target.tty_alc_proc) = 'MONOTONY' then
         if var_sam_count != 0 then
            var_mon_count := rcd_retrieve.tde_tes_day_count / var_sam_count;
         end if;
      end if;

      /*-*/
      /* Update the test definition
      /*-*/
      update pts_tes_definition
         set tde_tes_status = 3
       where tde_tes_code = rcd_retrieve.tde_tes_code;

      /*-*/
      /* Retrieve the existing panel member
      /* **notes** 1. Create a recruited panel when not found regardless of status
      /*-*/
      var_found := false;
      var_member := false;
      open csr_panel;
      fetch csr_panel into rcd_panel;
      if csr_panel%found then
         var_found := true;
         if rcd_panel.tpa_pan_status = '*MEMBER' then
            var_member := true;
         end if;
      end if;
      close csr_panel;
      if var_found = false then
         open csr_pet;
         fetch csr_pet into rcd_pet;
         if csr_pet%notfound then
            pts_gen_function.add_mesg_data('Pet ('||to_char(var_pan_code)||') does not exist');
         else
            rcd_pts_tes_panel.tpa_tes_code := var_tes_code;
            rcd_pts_tes_panel.tpa_pan_code := var_pan_code;
            rcd_pts_tes_panel.tpa_pan_status := '*RECRUITED';
            rcd_pts_tes_panel.tpa_sel_group := '*RECRUITED';
            rcd_pts_tes_panel.tpa_pet_code := rcd_pet.pde_pet_code;
            rcd_pts_tes_panel.tpa_pet_status := rcd_pet.pde_pet_status;
            rcd_pts_tes_panel.tpa_pet_name := rcd_pet.pde_pet_name;
            rcd_pts_tes_panel.tpa_pet_type := rcd_pet.pde_pet_type;
            rcd_pts_tes_panel.tpa_birth_year := rcd_pet.pde_birth_year;
            rcd_pts_tes_panel.tpa_feed_comment := rcd_pet.pde_feed_comment;
            rcd_pts_tes_panel.tpa_health_comment := rcd_pet.pde_health_comment;
            rcd_pts_tes_panel.tpa_hou_code := rcd_pet.hde_hou_code;
            rcd_pts_tes_panel.tpa_hou_status := rcd_pet.hde_hou_status;
            rcd_pts_tes_panel.tpa_geo_type := rcd_pet.hde_geo_type;
            rcd_pts_tes_panel.tpa_geo_zone := rcd_pet.hde_geo_zone;
            rcd_pts_tes_panel.tpa_loc_street := rcd_pet.hde_loc_street;
            rcd_pts_tes_panel.tpa_loc_town := rcd_pet.hde_loc_town;
            rcd_pts_tes_panel.tpa_loc_postcode := rcd_pet.hde_loc_postcode;
            rcd_pts_tes_panel.tpa_loc_country := rcd_pet.hde_loc_country;
            rcd_pts_tes_panel.tpa_tel_areacode := rcd_pet.hde_tel_areacode;
            rcd_pts_tes_panel.tpa_tel_number := rcd_pet.hde_tel_number;
            rcd_pts_tes_panel.tpa_con_surname := rcd_pet.hde_con_surname;
            rcd_pts_tes_panel.tpa_con_fullname := rcd_pet.hde_con_fullname;
            rcd_pts_tes_panel.tpa_con_birth_year := rcd_pet.hde_con_birth_year;
            insert into pts_tes_panel values rcd_pts_tes_panel;
            open csr_pet_stat;
            loop
               fetch csr_pet_stat into rcd_pet_stat;
               if csr_pet_stat%notfound then
                  exit;
               end if;
               rcd_pts_tes_statistic.tst_tes_code := var_tes_code;
               rcd_pts_tes_statistic.tst_pan_code := var_pan_code;
               rcd_pts_tes_statistic.tst_pet_type := rcd_pet_stat.pde_pet_type;
               rcd_pts_tes_statistic.tst_pet_count := rcd_pet_stat.typ_count;
               insert into pts_tes_statistic values rcd_pts_tes_statistic;
            end loop;
            close csr_pet_stat;
            open csr_pet_class;
            loop
               fetch csr_pet_class into rcd_pet_class;
               if csr_pet_class%notfound then
                  exit;
               end if;
               rcd_pts_tes_classification.tcl_tes_code := var_tes_code;
               rcd_pts_tes_classification.tcl_pan_code := var_pan_code;
               rcd_pts_tes_classification.tcl_tab_code := rcd_pet_class.pcl_tab_code;
               rcd_pts_tes_classification.tcl_fld_code := rcd_pet_class.pcl_fld_code;
               rcd_pts_tes_classification.tcl_val_code := rcd_pet_class.pcl_val_code;
               rcd_pts_tes_classification.tcl_val_text := rcd_pet_class.pcl_val_text;
               insert into pts_tes_classification values rcd_pts_tes_classification;
            end loop;
            close csr_pet_class;
         end if;
         close csr_pet;
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Save the existing allocation data
      /*-*/
      tbl_alcdat.delete;
      if var_member = true then
         open csr_allocation;
         loop
            fetch csr_allocation into rcd_allocation;
            if csr_allocation%notfound then
               exit;
            end if;
            tbl_alcdat(tbl_alcdat.count+1).day_code := rcd_allocation.tal_day_code;
            tbl_alcdat(tbl_alcdat.count).seq_numb := rcd_allocation.tal_seq_numb;
            tbl_alcdat(tbl_alcdat.count).sam_code := rcd_allocation.tal_sam_code;
            tbl_alcdat(tbl_alcdat.count).mkt_code := rcd_allocation.tal_mkt_code;
          end loop;
          close csr_allocation;
      end if;

      /*-*/
      /* Clear the existing response data
      /*-*/
      delete from pts_tes_allocation
       where tal_tes_code = var_tes_code
         and tal_pan_code = var_pan_code;
      delete from pts_tes_response
       where tre_tes_code = var_tes_code
         and tre_pan_code = var_pan_code;

      /*-*/
      /* Retrieve and insert the response data
      /* **notes** 1. Update the allocation when supplied
      /*           2. Use current allocation when not supplied
      /*           3. Perform the weight validation when required
      /*-*/
      tbl_mktcde.delete;
      var_day_code := null;
      var_sam_cod1 := null;
      var_sam_cod2 := null;
      var_wrk_count := 0;
      obj_res_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/RESP');
      for idx in 0..xmlDom.getLength(obj_res_list)-1 loop
         obj_res_node := xmlDom.item(obj_res_list,idx);
         var_typ_code := upper(xslProcessor.valueOf(obj_res_node,'@TYPCDE'));
         if var_typ_code = 'D' then
            if rcd_retrieve.tde_wgt_que_calc = '1' then
               if not(var_day_code is null) then
                  if ((var_wgt_bowl1 + var_wgt_offer1) - var_wgt_remain1) > var_wgt_offer1 then
                     pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code one weight eaten is greater than offered');
                  end if;
                  if var_wgt_remain1 > (var_wgt_bowl1 + var_wgt_offer1) then
                     pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code one weight remaining is greater than offered');
                  end if;
                  if ((var_wgt_bowl2 + var_wgt_offer2) - var_wgt_remain2) > var_wgt_offer2 then
                     pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code two weight eaten is greater than offered');
                  end if;
                  if var_wgt_remain2 > (var_wgt_bowl2 + var_wgt_offer2) then
                     pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code two weight remaining is greater than offered');
                  end if;
               end if;
               var_wgt_bowl1 := 0;
               var_wgt_offer1 := 0;
               var_wgt_remain1 := 0;
               var_wgt_bowl2 := 0;
               var_wgt_offer2 := 0;
               var_wgt_remain2 := 0;
            end if;
            var_message := false;
            var_day_code := pts_to_number(xslProcessor.valueOf(obj_res_node,'@DAYCDE'));
            if upper(rcd_target.tty_alc_proc) = 'MONOTONY' then
               var_wrk_count := var_wrk_count + 1;
            else
               var_sam_cod1 := null;
               var_sam_cod2 := null;
            end if;
            if upper(rcd_target.tty_alc_proc) = 'DIFFERENCE' then
               tbl_mktcde.delete;
            end if;
            var_mkt_code := upper(trim(xslProcessor.valueOf(obj_res_node,'@MKTCD1')));
            if var_mkt_code is null then
               var_seq_numb := var_day_code;
               if upper(rcd_target.tty_alc_proc) = 'DIFFERENCE' then
                  var_seq_numb := 1;
               end if;
               var_exists := false;
               for idx in 1..tbl_alcdat.count loop
                  if tbl_alcdat(idx).day_code = var_day_code and
                     tbl_alcdat(idx).seq_numb = var_seq_numb then
                     var_sam_cod1 := tbl_alcdat(idx).sam_code;
                     var_mkt_code := tbl_alcdat(idx).mkt_code;
                     var_exists := true;
                     exit;
                  end if;
               end loop;
               if var_exists = false then
                  pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') sample allocation does not exist for this test member - market research code one must be specified');
                  var_message := true;
               else
                  var_exists := false;
                  for idx in 1..tbl_mktcde.count loop
                     if tbl_mktcde(idx) = var_mkt_code then
                        var_exists := true;
                        exit;
                     end if;
                  end loop;
                  if upper(rcd_target.tty_alc_proc) = 'MONOTONY' then
                     if tbl_mktcde.count != 0 then
                        if var_exists = false then
                           pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') must be the same for each day in the sample group');
                           var_message := true;
                        end if;
                     else
                        tbl_mktcde(tbl_mktcde.count+1) := var_mkt_code;
                     end if;
                  else
                     if var_exists = true then
                        pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') already used');
                        var_message := true;
                     else
                        tbl_mktcde(tbl_mktcde.count+1) := var_mkt_code;
                     end if;
                  end if;
               end if;
            else
               var_exists := false;
               for idx in 1..tbl_mktcde.count loop
                  if tbl_mktcde(idx) = var_mkt_code then
                     var_exists := true;
                     exit;
                  end if;
               end loop;
               if upper(rcd_target.tty_alc_proc) = 'MONOTONY' then
                  if tbl_mktcde.count != 0 then
                     if var_exists = false then
                        pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') must be the same for each day in the sample group');
                        var_message := true;
                     end if;
                     var_seq_numb := var_day_code;
                  else
                     tbl_mktcde(tbl_mktcde.count+1) := var_mkt_code;
                     open csr_sample;
                     fetch csr_sample into rcd_sample;
                     if csr_sample%notfound then
                        pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') does not exist for this test');
                        var_message := true;
                     else
                        var_sam_cod1 := rcd_sample.tsa_sam_code;
                        var_seq_numb := var_day_code;
                        if var_member = true then
                           var_exists := false;
                           for idx in 1..tbl_alcdat.count loop
                              if tbl_alcdat(idx).sam_code = var_sam_cod1 then
                                 var_exists := true;
                                 exit;
                              end if;
                           end loop;
                           if var_exists = false then
                              pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') is not allocated for this test member');
                              var_message := true;
                           end if;
                        end if;
                     end if;
                     close csr_sample;
                  end if;
               else
                  if var_exists = true then
                     pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') already used');
                     var_message := true;
                  else
                     tbl_mktcde(tbl_mktcde.count+1) := var_mkt_code;
                     open csr_sample;
                     fetch csr_sample into rcd_sample;
                     if csr_sample%notfound then
                        pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') does not exist for this test');
                        var_message := true;
                     else
                        var_sam_cod1 := rcd_sample.tsa_sam_code;
                        var_seq_numb := var_day_code;
                        if upper(rcd_target.tty_alc_proc) = 'DIFFERENCE' then
                           var_seq_numb := 1;
                        end if;
                        if var_member = true then
                           var_exists := false;
                           for idx in 1..tbl_alcdat.count loop
                              if tbl_alcdat(idx).sam_code = var_sam_cod1 then
                                 var_exists := true;
                                 exit;
                              end if;
                           end loop;
                           if var_exists = false then
                              pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') is not allocated for this test member');
                              var_message := true;
                           end if;
                        end if;
                     end if;
                     close csr_sample;
                  end if;
               end if;
            end if;
            if var_message = false then
               rcd_pts_tes_allocation.tal_tes_code := var_tes_code;
               rcd_pts_tes_allocation.tal_pan_code := var_pan_code;
               rcd_pts_tes_allocation.tal_day_code := var_day_code;
               rcd_pts_tes_allocation.tal_sam_code := var_sam_cod1;
               rcd_pts_tes_allocation.tal_seq_numb := var_seq_numb;
               rcd_pts_tes_allocation.tal_mkt_code := var_mkt_code;
               insert into pts_tes_allocation values rcd_pts_tes_allocation;
            end if;
            if upper(rcd_target.tty_alc_proc) = 'DIFFERENCE' then
               var_mkt_code := upper(trim(xslProcessor.valueOf(obj_res_node,'@MKTCD2')));
               if var_mkt_code is null then
                  var_seq_numb := var_day_code;
                  if upper(rcd_target.tty_alc_proc) = 'DIFFERENCE' then
                     var_seq_numb := 2;
                  end if;
                  var_exists := false;
                  for idx in 1..tbl_alcdat.count loop
                     if tbl_alcdat(idx).day_code = var_day_code and
                        tbl_alcdat(idx).seq_numb = var_seq_numb then
                        var_sam_cod2 := tbl_alcdat(idx).sam_code;
                        var_mkt_code := tbl_alcdat(idx).mkt_code;
                        var_exists := true;
                        exit;
                     end if;
                  end loop;
                  if var_exists = false then
                     pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') sample allocation does not exist for this test member - market research code two must be specified');
                     var_message := true;
                  else
                     var_exists := false;
                     for idx in 1..tbl_mktcde.count loop
                        if tbl_mktcde(idx) = var_mkt_code then
                           var_exists := true;
                           exit;
                        end if;
                     end loop;
                     if var_exists = true then
                        pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') already used');
                        var_message := true;
                     else
                        tbl_mktcde(tbl_mktcde.count+1) := var_mkt_code;
                     end if;
                  end if;
               else
                  var_exists := false;
                  for idx in 1..tbl_mktcde.count loop
                     if tbl_mktcde(idx) = var_mkt_code then
                        var_exists := true;
                        exit;
                     end if;
                  end loop;
                  if var_exists = true then
                     pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') already used');
                     var_message := true;
                  else
                     tbl_mktcde(tbl_mktcde.count+1) := var_mkt_code;
                     open csr_sample;
                     fetch csr_sample into rcd_sample;
                     if csr_sample%notfound then
                        pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') does not exist for this test');
                        var_message := true;
                     else
                        var_sam_cod2 := rcd_sample.tsa_sam_code;
                        var_seq_numb := var_day_code;
                        if upper(rcd_target.tty_alc_proc) = 'DIFFERENCE' then
                           var_seq_numb := 2;
                        end if;
                        if var_member = true then
                           var_exists := false;
                           for idx in 1..tbl_alcdat.count loop
                              if tbl_alcdat(idx).sam_code = var_sam_cod1 then
                                 var_exists := true;
                                 exit;
                              end if;
                           end loop;
                           if var_exists = false then
                              pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') is not allocated for this test member');
                              var_message := true;
                           end if;
                        end if;
                     end if;
                     close csr_sample;
                  end if;
               end if;
               if var_message = false then
                  rcd_pts_tes_allocation.tal_tes_code := var_tes_code;
                  rcd_pts_tes_allocation.tal_pan_code := var_pan_code;
                  rcd_pts_tes_allocation.tal_day_code := var_day_code;
                  rcd_pts_tes_allocation.tal_sam_code := var_sam_cod2;
                  rcd_pts_tes_allocation.tal_seq_numb := var_seq_numb;
                  rcd_pts_tes_allocation.tal_mkt_code := var_mkt_code;
                  insert into pts_tes_allocation values rcd_pts_tes_allocation;
               end if;
            end if;
            if upper(rcd_target.tty_alc_proc) = 'MONOTONY' then
               if var_wrk_count = var_mon_count then
                  var_wrk_count := 0;
                  tbl_mktcde.delete;
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
                  if rcd_retrieve.tde_wgt_que_calc = '1' then
                     if xslProcessor.valueOf(obj_res_node,'@RESSEQ') = '1' then
                        if var_que_code = rcd_retrieve.tde_wgt_que_bowl then
                           var_wgt_bowl1 := nvl(var_res_value,0);
                        elsif var_que_code = rcd_retrieve.tde_wgt_que_offer then
                           var_wgt_offer1 := nvl(var_res_value,0);
                        elsif var_que_code = rcd_retrieve.tde_wgt_que_remain then
                           var_wgt_remain1 := nvl(var_res_value,0);
                        end if;
                     elsif xslProcessor.valueOf(obj_res_node,'@RESSEQ') = '2' then
                        if var_que_code = rcd_retrieve.tde_wgt_que_bowl then
                           var_wgt_bowl2 := nvl(var_res_value,0);
                        elsif var_que_code = rcd_retrieve.tde_wgt_que_offer then
                           var_wgt_offer2 := nvl(var_res_value,0);
                        elsif var_que_code = rcd_retrieve.tde_wgt_que_remain then
                           var_wgt_remain2 := nvl(var_res_value,0);
                        end if;
                     end if;
                  end if;
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
                  rcd_pts_tes_response.tre_tes_code := var_tes_code;
                  rcd_pts_tes_response.tre_pan_code := var_pan_code;
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
      if rcd_retrieve.tde_wgt_que_calc = '1' then
         if not(var_day_code is null) then
            if ((var_wgt_bowl1 + var_wgt_offer1) - var_wgt_remain1) > var_wgt_offer1 then
               pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code one weight eaten is greater than offered');
            end if;
            if var_wgt_remain1 > (var_wgt_bowl1 + var_wgt_offer1) then
               pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code one weight remaining is greater than offered');
            end if;
            if ((var_wgt_bowl2 + var_wgt_offer2) - var_wgt_remain2) > var_wgt_offer2 then
               pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code two weight eaten is greater than offered');
            end if;
            if var_wgt_remain2 > (var_wgt_bowl2 + var_wgt_offer2) then
               pts_gen_function.add_mesg_data('Day ('||to_char(var_day_code)||') market research code two weight remaining is greater than offered');
            end if;
         end if;
      end if;
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

   /***************************************************/
   /* This procedure performs the clear panel routine */
   /***************************************************/
   procedure clear_panel(par_tes_code in number, par_sel_type in varchar2, par_req_mem_count in number, par_req_res_count in number) is

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

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

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
         if upper(par_sel_type) = '*PERCENT' then
            var_tgr_mem_count := var_tgr_mem_count + tbl_sel_group(tbl_sel_group.count).req_mem_count;
            var_tgr_res_count := var_tgr_res_count + tbl_sel_group(tbl_sel_group.count).req_res_count;
         end if;

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
         if upper(par_sel_type) = '*PERCENT' then
            if var_tgr_mem_count != par_req_mem_count then
               tbl_sel_group(tbl_sel_group.count).req_mem_count := tbl_sel_group(tbl_sel_group.count).req_mem_count + (par_req_mem_count - var_tgr_mem_count);
            end if;
            if var_tgr_res_count != par_req_res_count then
               tbl_sel_group(tbl_sel_group.count).req_res_count := tbl_sel_group(tbl_sel_group.count).req_res_count + (par_req_res_count - var_tgr_res_count);
            end if;
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

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear_panel;

   /****************************************************/
   /* This procedure performs the select panel routine */
   /****************************************************/
   procedure select_panel(par_tes_code in number, par_sel_type in varchar2, par_pan_type in varchar2, par_pet_multiple in varchar2, par_req_mem_count in number, par_req_res_count in number) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      rcd_pts_tes_panel pts_tes_panel%rowtype;
      rcd_pts_tes_statistic pts_tes_statistic%rowtype;
      rcd_pts_tes_classification pts_tes_classification%rowtype;
      var_sel_group varchar2(32);
      var_tot_req_mem_count number;
      var_tot_req_res_count number;
      var_tot_sel_mem_count number;
      var_tot_sel_res_count number;
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
         select t01.*,
                t02.*,
                (to_number(to_char(sysdate,'yyyy'))-nvl(t01.pde_birth_year,0)) as pde_pet_age,
                (select case when count(*)=0 then 0 when count(*)=1 then 1 else 2 end from pts_pet_definition where pde_hou_code=t01.pde_hou_code and not(pde_pet_status in (4,9))) as pde_hou_status,
                (select case when count(*)=0 then 0 when count(*)=1 then 1 else 2 end from pts_pet_definition where pde_hou_code=t01.pde_hou_code and pde_pet_type=t01.pde_pet_type and not(pde_pet_status in (4,9))) as pde_hou_count
           from pts_pet_definition t01,
                pts_hou_definition t02
          where t01.pde_hou_code = t02.hde_hou_code
            and t01.pde_pet_code in (select sel_code from table(pts_app.pts_gen_function.get_list_data('*PET',var_sel_group)))
            and t01.pde_pet_status = 1
            and (t02.hde_hou_status = 1 or t02.hde_tes_code = par_tes_code)
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

      cursor csr_hou_update is
         select t01.*
           from pts_hou_definition t01
          where t01.hde_hou_code = rcd_panel.hde_hou_code
                for update wait 20;
      rcd_hou_update csr_hou_update%rowtype;

      cursor csr_pet_update is
         select t01.*
           from pts_pet_definition t01
          where t01.pde_pet_code = rcd_panel.pde_pet_code
                for update wait 20;
      rcd_pet_update csr_pet_update%rowtype;

      cursor csr_panel_stat is
         select t01.pde_pet_type,
                count(*) as typ_count
           from pts_pet_definition t01
          where t01.pde_hou_code = rcd_panel.pde_hou_code
            and not(t01.pde_pet_status in (4,9))
          group by t01.pde_pet_type;
      rcd_panel_stat csr_panel_stat%rowtype;

      cursor csr_panel_class is
         select t01.*
           from pts_pet_classification t01
          where t01.pcl_pet_code = rcd_panel.pde_pet_code;
      rcd_panel_class csr_panel_class%rowtype;

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

      /*------------------------------------------*/
      /* NOTE - This is an autonomous transaction */
      /*------------------------------------------*/

      /*-*/
      /* Set the total count variables
      /*-*/
      var_tot_req_mem_count := par_req_mem_count;
      var_tot_req_res_count := par_req_res_count;
      var_tot_sel_mem_count := 0;
      var_tot_sel_res_count := 0;

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
               /* Attempt to lock the household definition for update
               /* **notes** 1. Must exist
               /*           2. Must be status available or on same test
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
                        if not(rcd_hou_update.hde_tes_code is null) then
                           if rcd_hou_update.hde_tes_code != par_tes_code then
                              var_available := false;
                           end if;
                        else
                           if rcd_hou_update.hde_hou_status != 1 then
                              var_available := false;
                           end if;
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
                  var_tot_sel_mem_count := var_tot_sel_mem_count + 1;
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
                  var_tot_sel_res_count := var_tot_sel_res_count + 1;
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
               /* Insert the new panel member data
               /*-*/
               rcd_pts_tes_panel.tpa_tes_code := par_tes_code;
               rcd_pts_tes_panel.tpa_pan_code := rcd_panel.pde_pet_code;
               rcd_pts_tes_panel.tpa_pan_status := upper(par_pan_type);
               rcd_pts_tes_panel.tpa_sel_group := tbl_sel_group(idg).sel_group;
               rcd_pts_tes_panel.tpa_pet_code := rcd_panel.pde_pet_code;
               rcd_pts_tes_panel.tpa_pet_status := rcd_panel.pde_pet_status;
               rcd_pts_tes_panel.tpa_pet_name := rcd_panel.pde_pet_name;
               rcd_pts_tes_panel.tpa_pet_type := rcd_panel.pde_pet_type;
               rcd_pts_tes_panel.tpa_birth_year := rcd_panel.pde_birth_year;
               rcd_pts_tes_panel.tpa_feed_comment := rcd_panel.pde_feed_comment;
               rcd_pts_tes_panel.tpa_health_comment := rcd_panel.pde_health_comment;
               rcd_pts_tes_panel.tpa_hou_code := rcd_panel.hde_hou_code;
               rcd_pts_tes_panel.tpa_hou_status := rcd_panel.hde_hou_status;
               rcd_pts_tes_panel.tpa_geo_type := rcd_panel.hde_geo_type;
               rcd_pts_tes_panel.tpa_geo_zone := rcd_panel.hde_geo_zone;
               rcd_pts_tes_panel.tpa_loc_street := rcd_panel.hde_loc_street;
               rcd_pts_tes_panel.tpa_loc_town := rcd_panel.hde_loc_town;
               rcd_pts_tes_panel.tpa_loc_postcode := rcd_panel.hde_loc_postcode;
               rcd_pts_tes_panel.tpa_loc_country := rcd_panel.hde_loc_country;
               rcd_pts_tes_panel.tpa_tel_areacode := rcd_panel.hde_tel_areacode;
               rcd_pts_tes_panel.tpa_tel_number := rcd_panel.hde_tel_number;
               rcd_pts_tes_panel.tpa_con_surname := rcd_panel.hde_con_surname;
               rcd_pts_tes_panel.tpa_con_fullname := rcd_panel.hde_con_fullname;
               rcd_pts_tes_panel.tpa_con_birth_year := rcd_panel.hde_con_birth_year;
               insert into pts_tes_panel values rcd_pts_tes_panel;
               open csr_panel_stat;
               loop
                  fetch csr_panel_stat into rcd_panel_stat;
                  if csr_panel_stat%notfound then
                     exit;
                  end if;
                  rcd_pts_tes_statistic.tst_tes_code := par_tes_code;
                  rcd_pts_tes_statistic.tst_pan_code := rcd_panel.pde_pet_code;
                  rcd_pts_tes_statistic.tst_pet_type := rcd_panel_stat.pde_pet_type;
                  rcd_pts_tes_statistic.tst_pet_count := rcd_panel_stat.typ_count;
                  insert into pts_tes_statistic values rcd_pts_tes_statistic;
               end loop;
               close csr_panel_stat;
               open csr_panel_class;
               loop
                  fetch csr_panel_class into rcd_panel_class;
                  if csr_panel_class%notfound then
                     exit;
                  end if;
                  rcd_pts_tes_classification.tcl_tes_code := par_tes_code;
                  rcd_pts_tes_classification.tcl_pan_code := rcd_panel.pde_pet_code;
                  rcd_pts_tes_classification.tcl_tab_code := rcd_panel_class.pcl_tab_code;
                  rcd_pts_tes_classification.tcl_fld_code := rcd_panel_class.pcl_fld_code;
                  rcd_pts_tes_classification.tcl_val_code := rcd_panel_class.pcl_val_code;
                  rcd_pts_tes_classification.tcl_val_text := rcd_panel_class.pcl_val_text;
                  insert into pts_tes_classification values rcd_pts_tes_classification;
               end loop;
               close csr_panel_class;

               /*-*/
               /* Update the pet status
               /*-*/
               update pts_pet_definition
                  set pde_pet_status = 2,
                      pde_tes_code = par_tes_code
                where pde_pet_code = rcd_panel.pde_pet_code;

               /*-*/
               /* Update the household status
               /*-*/
               update pts_hou_definition
                  set hde_hou_status = 2,
                      hde_tes_code = par_tes_code
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

            /*-*/
            /* Exit the panel loop when total panel requirements satisfied
            /*-*/
            if upper(par_sel_type) != '*PERCENT' then
               if upper(par_pan_type) = '*MEMBER' then
                  if var_tot_sel_mem_count >= var_tot_req_mem_count then
                     exit;
                  end if;
               else
                  if var_tot_sel_res_count >= var_tot_req_res_count then
                     exit;
                  end if;
               end if;
            end if;

         end loop;
         close csr_panel;

         /*-*/
         /* Exit the group loop when total panel requirements satisfied
         /*-*/
         if upper(par_sel_type) != '*PERCENT' then
            if upper(par_pan_type) = '*MEMBER' then
               if var_tot_sel_mem_count >= var_tot_req_mem_count then
                  exit;
               end if;
            else
               if var_tot_sel_res_count >= var_tot_req_res_count then
                  exit;
               end if;
            end if;
         end if;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_TES_FUNCTION - SELECT_PANEL - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_panel;

end pts_tes_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_tes_function for pts_app.pts_tes_function;
grant execute on pts_app.pts_tes_function to public;

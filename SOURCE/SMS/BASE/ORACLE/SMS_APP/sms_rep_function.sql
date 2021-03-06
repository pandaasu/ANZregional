/******************/
/* Package Header */
/******************/
create or replace package sms_app.sms_rep_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : sms_rep_function
    Owner   : sms_app

    Description
    -----------
    SMS Reporting System - Report functions

    This package contain the report functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/07   Steve Gregan   Created
    2009/09   Steve Gregan   Added profile, message and filter codes to report message
    2009/09   Trevor Keon    Update output date to show previous period on first day of period
    2009/09   Steve Gregan   Modified to move generation to the SMS poller

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function select_enquiry return sms_xml_type pipelined;
   function retrieve_report return sms_xml_type pipelined;
   function retrieve_message return sms_xml_type pipelined;
   function retrieve_recipient return sms_xml_type pipelined;
   function select_execution return sms_xml_type pipelined;
   function retrieve_execution return sms_xml_type pipelined;
   procedure update_execution(par_user in varchar2);
   procedure generate(par_qry_code in varchar2, par_qry_date in varchar2, par_exe_status in varchar2);

end sms_rep_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body sms_app.sms_rep_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure send_sms(par_smtp_target in varchar2,
                      par_smtp_host in varchar2,
                      par_smtp_port in varchar2,
                      par_qry_code in varchar2,
                      par_qry_date in varchar2,
                      par_exe_seqn in number,
                      par_msg_seqn in number,
                      par_subject in varchar2,
                      par_content in varchar2);
   function convert_value(par_value in varchar2, par_round in number) return varchar2;

   /*-*/
   /* Private definitions
   /*-*/
   pvar_end_code number;
   pvar_cfrm varchar2(2000 char);
   type ptyp_mesg is table of varchar2(2000 char) index by binary_integer;
   ptbl_mesg ptyp_mesg;

   /******************************************************/
   /* This procedure performs the select enquiry routine */
   /******************************************************/
   function select_enquiry return sms_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_sms_request xmlDom.domNode;
      var_action varchar2(32);
      var_str_code varchar2(64);
      var_end_code varchar2(64);
      var_output varchar2(2000 char);
      var_pag_size number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_slct is
         select t01.*
           from (select t01.que_qry_code,
                        t01.que_qry_name,
                        decode(t01.que_status,'0','Inactive','1','Active','*UNKNOWN') as que_status
                   from sms_query t01
                  where (var_str_code is null or t01.que_qry_code >= var_str_code)
                  order by t01.que_qry_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.que_qry_code,
                        t01.que_qry_name,
                        decode(t01.que_status,'0','Inactive','1','Active','*UNKNOWN') as que_status
                   from sms_query t01
                  where (var_action = '*NXTQRY' and (var_end_code is null or t01.que_qry_code > var_end_code)) or
                        (var_action = '*PRVQRY')
                  order by t01.que_qry_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.que_qry_code,
                        t01.que_qry_name,
                        decode(t01.que_status,'0','Inactive','1','Active','*UNKNOWN') as que_status
                   from sms_query t01
                  where (var_action = '*PRVQRY' and (var_str_code is null or t01.que_qry_code < var_str_code)) or
                        (var_action = '*NXTQRY')
                  order by t01.que_qry_code desc) t01
          where rownum <= var_pag_size;

      /*-*/
      /* Local arrays
      /*-*/
      type typ_list is table of csr_slct%rowtype index by binary_integer;
      tbl_list typ_list;

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
      sms_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('SMS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_sms_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/SMS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_sms_request,'@ACTION'));
      var_str_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@STRCDE'));
      var_end_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@ENDCDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SELQRY' and var_action != '*PRVQRY' and var_action != '*NXTQRY' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(sms_xml_object('<?xml version="1.0" encoding="UTF-8"?><SMS_RESPONSE>'));

      /*-*/
      /* Retrieve the query list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELQRY' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW QRYCDE="'||to_char(tbl_list(idx).que_qry_code)||'" QRYNAM="'||sms_to_xml(tbl_list(idx).que_qry_name)||'" QRYSTS="'||sms_to_xml(tbl_list(idx).que_status)||'"/>'));
         end loop;
      elsif var_action = '*NXTQRY' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(sms_xml_object('<LSTROW QRYCDE="'||to_char(tbl_list(idx).que_qry_code)||'" QRYNAM="'||sms_to_xml(tbl_list(idx).que_qry_name)||'" QRYSTS="'||sms_to_xml(tbl_list(idx).que_status)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(sms_xml_object('<LSTROW QRYCDE="'||to_char(tbl_list(idx).que_qry_code)||'" QRYNAM="'||sms_to_xml(tbl_list(idx).que_qry_name)||'" QRYSTS="'||sms_to_xml(tbl_list(idx).que_status)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVQRY' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(sms_xml_object('<LSTROW QRYCDE="'||to_char(tbl_list(idx).que_qry_code)||'" QRYNAM="'||sms_to_xml(tbl_list(idx).que_qry_name)||'" QRYSTS="'||sms_to_xml(tbl_list(idx).que_status)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(sms_xml_object('<LSTROW QRYCDE="'||to_char(tbl_list(idx).que_qry_code)||'" QRYNAM="'||sms_to_xml(tbl_list(idx).que_qry_name)||'" QRYSTS="'||sms_to_xml(tbl_list(idx).que_status)||'"/>'));
            end loop;
         end if;
      end if;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(sms_xml_object('</SMS_RESPONSE>'));

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_REP_FUNCTION - SELECT_ENQUIRY - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_enquiry;

   /*******************************************************/
   /* This procedure performs the retrieve report routine */
   /*******************************************************/
   function retrieve_report return sms_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_sms_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_qry_code varchar2(64);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_query t01
          where t01.que_qry_code = var_qry_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_report is
         select t02.rex_qry_date,
                to_char(t02.rex_exe_seqn) as rex_exe_seqn,
                to_char(to_date(t02.rex_qry_date,'yyyymmddhh24miss'),'yyyy/mm/dd hh24:mi:ss') as exe_qry_date,
                to_char(to_date(t01.rhe_rpt_date,'yyyymmdd'),'yyyy/mm/dd') as exe_rpt_date,
                t02.rex_exe_user as exe_user,
                to_char(t02.rex_exe_date,'yyyy/mm/dd hh24:mi:ss') as exe_date,
                decode(t02.rex_status,'1','Automatic','2','Submitted','*UNKNOWN') as exe_status
           from sms_rpt_header t01,
                sms_rpt_execution t02
          where t01.rhe_qry_code = t02.rex_qry_code
            and t01.rhe_qry_date = t02.rex_qry_date
            and t01.rhe_qry_code = rcd_retrieve.que_qry_code
          order by t02.rex_qry_date desc,
                   t02.rex_exe_seqn desc;
      rcd_report csr_report%rowtype;

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
      sms_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('SMS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_sms_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/SMS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_sms_request,'@ACTION'));
      var_qry_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYCDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*RTVRPT' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing query
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         sms_gen_function.add_mesg_data('Query ('||var_qry_code||') does not exist');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(sms_xml_object('<?xml version="1.0" encoding="UTF-8"?><SMS_RESPONSE>'));

      /*-*/
      /* Retrieve the report list and pipe the results
      /*-*/
      open csr_report;
      loop
         fetch csr_report into rcd_report;
         if csr_report%notfound then
            exit;
         end if;
         pipe row(sms_xml_object('<REPORT QRYDTE="'||sms_to_xml(rcd_report.rex_qry_date)||'" EXESEQ="'||sms_to_xml(rcd_report.rex_exe_seqn)||'" EXQDTE="'||sms_to_xml(rcd_report.exe_qry_date)||'" EXRDTE="'||sms_to_xml(rcd_report.exe_rpt_date)||'" EXEUSR="'||sms_to_xml(rcd_report.exe_user)||'" EXEDTE="'||sms_to_xml(rcd_report.exe_date)||'" EXESTS="'||sms_to_xml(rcd_report.exe_status)||'"/>'));
      end loop;
      close csr_report;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(sms_xml_object('</SMS_RESPONSE>'));

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_REP_FUNCTION - RETRIEVE_REPORT - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_report;

   /********************************************************/
   /* This procedure performs the retrieve message routine */
   /********************************************************/
   function retrieve_message return sms_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_sms_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_qry_code varchar2(64);
      var_qry_date varchar2(14);
      var_exe_seqn number;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_query t01
          where t01.que_qry_code = var_qry_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_message is
         select to_char(t01.rme_msg_seqn) as rme_msg_seqn,
                t01.rme_msg_text,
                to_char(t01.rme_msg_time,'yyyy/mm/dd hh24:mi:ss') as rme_msg_time,
                decode(t01.rme_msg_status,'1','Created','2','Sent','3','Error','*UNKNOWN') as rme_msg_status,
                t01.rme_prf_code,
                t01.rme_msg_code,
                t01.rme_flt_code
           from sms_rpt_message t01
          where t01.rme_qry_code = var_qry_code
            and t01.rme_qry_date = var_qry_date
            and t01.rme_exe_seqn = var_exe_seqn
          order by t01.rme_msg_seqn asc;
      rcd_message csr_message%rowtype;

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
      sms_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('SMS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_sms_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/SMS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_sms_request,'@ACTION'));
      var_qry_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYCDE'));
      var_qry_date := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYDTE'));
      var_exe_seqn := sms_to_number(xslProcessor.valueOf(obj_sms_request,'@EXESEQ'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*RTVMSG' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing query
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         sms_gen_function.add_mesg_data('Query ('||var_qry_code||') does not exist');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(sms_xml_object('<?xml version="1.0" encoding="UTF-8"?><SMS_RESPONSE>'));

      /*-*/
      /* Retrieve the message list and pipe the results
      /*-*/
      open csr_message;
      loop
         fetch csr_message into rcd_message;
         if csr_message%notfound then
            exit;
         end if;
         pipe row(sms_xml_object('<MESSAGE MSGSEQ="'||sms_to_xml(rcd_message.rme_msg_seqn)||'" MSGTXT="'||sms_to_xml(rcd_message.rme_msg_text)||'" MSGTIM="'||sms_to_xml(rcd_message.rme_msg_time)||'" MSGSTS="'||sms_to_xml(rcd_message.rme_msg_status)||'" PRFCDE="'||sms_to_xml(rcd_message.rme_prf_code)||'" MSGCDE="'||sms_to_xml(rcd_message.rme_msg_code)||'" FLTCDE="'||sms_to_xml(rcd_message.rme_flt_code)||'"/>'));
      end loop;
      close csr_message;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(sms_xml_object('</SMS_RESPONSE>'));

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_REP_FUNCTION - RETRIEVE_MESSAGE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_message;

   /**********************************************************/
   /* This procedure performs the retrieve recipient routine */
   /**********************************************************/
   function retrieve_recipient return sms_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_sms_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_qry_code varchar2(64);
      var_qry_date varchar2(14);
      var_exe_seqn number;
      var_msg_seqn number;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_recipient is
         select t01.rre_rcp_code,
                t01.rre_rcp_name,
                t01.rre_rcp_mobile
           from sms_rpt_recipient t01
          where t01.rre_qry_code = var_qry_code
            and t01.rre_qry_date = var_qry_date
            and t01.rre_exe_seqn = var_exe_seqn
            and t01.rre_msg_seqn = var_msg_seqn
          order by t01.rre_rcp_code asc;
      rcd_recipient csr_recipient%rowtype;

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
      sms_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('SMS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_sms_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/SMS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_sms_request,'@ACTION'));
      var_qry_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYCDE'));
      var_qry_date := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYDTE'));
      var_exe_seqn := sms_to_number(xslProcessor.valueOf(obj_sms_request,'@EXESEQ'));
      var_msg_seqn := sms_to_number(xslProcessor.valueOf(obj_sms_request,'@MSGSEQ'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*RTVRCP' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(sms_xml_object('<?xml version="1.0" encoding="UTF-8"?><SMS_RESPONSE>'));

      /*-*/
      /* Pipe the recipient line XML
      /*-*/
      open csr_recipient;
      loop
         fetch csr_recipient into rcd_recipient;
         if csr_recipient%notfound then
            exit;
          end if;
         pipe row(sms_xml_object('<RECIPIENT RCPCDE="'||to_char(rcd_recipient.rre_rcp_code)||'" RCPNAM="'||sms_to_xml(rcd_recipient.rre_rcp_name)||'" RCPMOB="'||sms_to_xml(rcd_recipient.rre_rcp_mobile)||'"/>'));
      end loop;
      close csr_recipient;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(sms_xml_object('</SMS_RESPONSE>'));

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_REP_FUNCTION - RETRIEVE_RECIPIENT - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_recipient;

   /********************************************************/
   /* This procedure performs the select execution routine */
   /********************************************************/
   function select_execution return sms_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_sms_request xmlDom.domNode;
      var_action varchar2(32);
      var_str_code varchar2(64);
      var_end_code varchar2(64);
      var_output varchar2(2000 char);
      var_pag_size number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_slct is
         select t01.*
           from (select t01.que_qry_code,
                        t01.que_qry_name,
                        decode(t01.que_status,'0','Inactive','1','Active','*UNKNOWN') as que_status
                   from sms_query t01
                  where (var_str_code is null or t01.que_qry_code >= var_str_code)
                    and t01.que_status = '1'
                  order by t01.que_qry_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.que_qry_code,
                        t01.que_qry_name,
                        decode(t01.que_status,'0','Inactive','1','Active','*UNKNOWN') as que_status
                   from sms_query t01
                  where (var_action = '*NXTQRY' and (var_end_code is null or t01.que_qry_code > var_end_code)) or
                        (var_action = '*PRVQRY')
                    and t01.que_status = '1'
                  order by t01.que_qry_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.que_qry_code,
                        t01.que_qry_name,
                        decode(t01.que_status,'0','Inactive','1','Active','*UNKNOWN') as que_status
                   from sms_query t01
                  where (var_action = '*PRVQRY' and (var_str_code is null or t01.que_qry_code < var_str_code)) or
                        (var_action = '*NXTQRY')
                    and t01.que_status = '1'
                  order by t01.que_qry_code desc) t01
          where rownum <= var_pag_size;

      /*-*/
      /* Local arrays
      /*-*/
      type typ_list is table of csr_slct%rowtype index by binary_integer;
      tbl_list typ_list;

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
      sms_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('SMS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_sms_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/SMS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_sms_request,'@ACTION'));
      var_str_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@STRCDE'));
      var_end_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@ENDCDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SELQRY' and var_action != '*PRVQRY' and var_action != '*NXTQRY' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(sms_xml_object('<?xml version="1.0" encoding="UTF-8"?><SMS_RESPONSE>'));

      /*-*/
      /* Retrieve the query list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELQRY' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW QRYCDE="'||to_char(tbl_list(idx).que_qry_code)||'" QRYNAM="'||sms_to_xml(tbl_list(idx).que_qry_name)||'" QRYSTS="'||sms_to_xml(tbl_list(idx).que_status)||'"/>'));
         end loop;
      elsif var_action = '*NXTQRY' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(sms_xml_object('<LSTROW QRYCDE="'||to_char(tbl_list(idx).que_qry_code)||'" QRYNAM="'||sms_to_xml(tbl_list(idx).que_qry_name)||'" QRYSTS="'||sms_to_xml(tbl_list(idx).que_status)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(sms_xml_object('<LSTROW QRYCDE="'||to_char(tbl_list(idx).que_qry_code)||'" QRYNAM="'||sms_to_xml(tbl_list(idx).que_qry_name)||'" QRYSTS="'||sms_to_xml(tbl_list(idx).que_status)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVQRY' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(sms_xml_object('<LSTROW QRYCDE="'||to_char(tbl_list(idx).que_qry_code)||'" QRYNAM="'||sms_to_xml(tbl_list(idx).que_qry_name)||'" QRYSTS="'||sms_to_xml(tbl_list(idx).que_status)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(sms_xml_object('<LSTROW QRYCDE="'||to_char(tbl_list(idx).que_qry_code)||'" QRYNAM="'||sms_to_xml(tbl_list(idx).que_qry_name)||'" QRYSTS="'||sms_to_xml(tbl_list(idx).que_status)||'"/>'));
            end loop;
         end if;
      end if;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(sms_xml_object('</SMS_RESPONSE>'));

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_REP_FUNCTION - SELECT_EXECUTION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_execution;

   /**********************************************************/
   /* This procedure performs the retrieve execution routine */
   /**********************************************************/
   function retrieve_execution return sms_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_sms_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_qry_code varchar2(64);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_query t01
          where t01.que_qry_code = var_qry_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_report is
         select t01.*,
                to_char(to_date(t01.rhe_qry_date,'yyyymmddhh24miss'),'yyyy/mm/dd hh24:mi:ss') as rpt_rpt_date,
                nvl(t02.exe_date,'NOT EXECUTED') as rpt_exe_date,
                decode(t01.rhe_status,'1','Loaded','2','Processed','3','Resent','4','Cancelled','5','Submitted','6','Executing','*UNKNOWN') as rpt_status
           from sms_rpt_header t01,
                (select rex_qry_code,
                        rex_qry_date,
                        to_char(max(rex_exe_date),'yyyy/mm/dd hh24:mi:ss') as exe_date
                   from sms_rpt_execution
                  group by rex_qry_code,
                           rex_qry_date) t02
          where t01.rhe_qry_code = t02.rex_qry_code(+)
            and t01.rhe_qry_date = t02.rex_qry_date(+)
            and t01.rhe_qry_code = rcd_retrieve.que_qry_code
            and (t01.rhe_status = '2' or t01.rhe_status = '3')
          order by t01.rhe_qry_date desc;
      rcd_report csr_report%rowtype;

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
      sms_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('SMS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_sms_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/SMS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_sms_request,'@ACTION'));
      var_qry_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYCDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SELRPT' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing query
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         sms_gen_function.add_mesg_data('Query ('||var_qry_code||') does not exist');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the latest report
      /*-*/
      open csr_report;
      fetch csr_report into rcd_report;
      if csr_report%notfound then
         sms_gen_function.add_mesg_data('Query ('||var_qry_code||') does not have any reports to process');
      end if;
      close csr_report;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(sms_xml_object('<?xml version="1.0" encoding="UTF-8"?><SMS_RESPONSE>'));

      /*-*/
      /* Pipe the report XML
      /*-*/
      pipe row(sms_xml_object('<REPORT QRYDTE="'||sms_to_xml(rcd_report.rhe_qry_date)||'" RPTDTE="'||sms_to_xml(rcd_report.rpt_rpt_date)||'" EXEDTE="'||sms_to_xml(rcd_report.rpt_exe_date)||'" RPTSTS="'||sms_to_xml(rcd_report.rpt_status)||'"/>'));

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(sms_xml_object('</SMS_RESPONSE>'));

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_REP_FUNCTION - RETRIEVE_EXECUTION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_execution;

   /********************************************************/
   /* This procedure performs the update execution routine */
   /********************************************************/
   procedure update_execution(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_sms_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_qry_code varchar2(64);
      var_qry_date varchar2(14);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_rpt_header t01
          where t01.rhe_qry_code = var_qry_code
            and t01.rhe_qry_date = var_qry_date
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the message data
      /*-*/
      sms_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('SMS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_sms_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/SMS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_sms_request,'@ACTION'));
      var_qry_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYCDE'));
      var_qry_date := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYDTE'));
      if var_action != '*EXERPT' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;
 
      /*-*/
      /* Retrieve the existing report
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
            var_found := true;
            sms_gen_function.add_mesg_data('Report ('||var_qry_code||' - '||var_qry_date||') is currently locked');
      end;
      if var_found = false then
         sms_gen_function.add_mesg_data('Report ('||var_qry_code||' - '||var_qry_date||') does not exist');
      else
         if rcd_retrieve.rhe_status != '2' and rcd_retrieve.rhe_status != '3' then
            sms_gen_function.add_mesg_data('Report ('||var_qry_code||' - '||var_qry_date||') must be status processed or resent');
         end if;
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Update the report header to submitted
      /*-*/
      update sms_rpt_header
         set rhe_upd_user = par_user,
             rhe_upd_date = sysdate,
             rhe_status = '5'
       where rhe_qry_code = rcd_retrieve.rhe_qry_code
         and rhe_qry_date = rcd_retrieve.rhe_qry_date;

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
      sms_gen_function.set_cfrm_data('Report ('||rcd_retrieve.rhe_qry_code||' - '||rcd_retrieve.rhe_qry_date||') successfully submitted for execution');

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_REP_FUNCTION - UPDATE_EXECUTION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_execution;

   /************************************************/
   /* This procedure performs the generate routine */
   /************************************************/
   procedure generate(par_qry_code in varchar2, par_qry_date in varchar2, par_exe_status in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_errors boolean;
      var_warnings boolean;
      var_found boolean;
      var_process boolean;
      var_sent boolean;
      var_sta_text varchar2(32);
      var_smtp_target varchar2(256);
      var_smtp_host varchar2(256);
      var_smtp_port varchar2(256);
      var_subject varchar2(64);
      var_rec_count number;
      var_out_day varchar2(64);
      var_day_number number;
      var_level varchar2(64);
      var_detail varchar2(64);
      var_total varchar2(64);
      var_sav_val01 varchar2(256);
      var_sav_val02 varchar2(256);
      var_sav_val03 varchar2(256);
      var_sav_val04 varchar2(256);
      var_sav_val05 varchar2(256);
      var_sav_val06 varchar2(256);
      var_sav_val07 varchar2(256);
      var_sav_val08 varchar2(256);
      var_sav_val09 varchar2(256);
      var_sms_text varchar2(32767);
      var_sms_work varchar2(32767);
      rcd_sms_rpt_execution sms_rpt_execution%rowtype;
      rcd_sms_rpt_message sms_rpt_message%rowtype;
      rcd_sms_rpt_recipient sms_rpt_recipient%rowtype;
      type typ_count is table of integer index by binary_integer;
      tbl_dcnt typ_count;
      type typ_mlin is table of sms_mes_line%rowtype index by binary_integer;
      tbl_mlin typ_mlin;
      type typ_data is table of sms_rpt_data%rowtype index by binary_integer;
      tbl_data typ_data;
      type typ_text is table of varchar2(2000 char) index by binary_integer;
      tbl_text typ_text;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'SMS Report Generation';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_report is
         select t01.*
           from sms_rpt_header t01
          where t01.rhe_qry_code = par_qry_code
            and t01.rhe_qry_date = par_qry_date
            for update nowait;
      rcd_report csr_report%rowtype;

      cursor csr_execution is
         select nvl(max(rex_exe_seqn),0) as max_exe_seqn
           from sms_rpt_execution t01
          where t01.rex_qry_code = par_qry_code
            and t01.rex_qry_date = par_qry_date;
      rcd_execution csr_execution%rowtype;

      cursor csr_query is
         select t01.*
           from sms_query t01
          where t01.que_qry_code = par_qry_code;
      rcd_query csr_query%rowtype;

      cursor csr_profile is
         select t01.*
           from sms_profile t01
          where t01.pro_qry_code = par_qry_code
            and t01.pro_status = '1'
          order by t01.pro_prf_code asc;
      rcd_profile csr_profile%rowtype;

      cursor csr_pro_message is
         select t02.*
           from sms_pro_message t01,
                sms_message t02
          where t01.pme_msg_code = t02.mes_msg_code
            and t01.pme_prf_code = rcd_profile.pro_prf_code
            and t02.mes_status = '1'
          order by t02.mes_msg_code asc;
      rcd_pro_message csr_pro_message%rowtype;

      cursor csr_mes_line is
         select t01.mli_msg_code,
                t01.mli_msg_line,
                nvl(t01.mli_det_text,'*NONE') as mli_det_text,
                nvl(t01.mli_tot_text,'*NONE') as mli_tot_text,
                t01.mli_tot_child
           from sms_mes_line t01
          where t01.mli_msg_code = rcd_pro_message.mes_msg_code
          order by t01.mli_msg_line asc;
      rcd_mes_line csr_mes_line%rowtype;

      cursor csr_pro_filter is
         select t02.*
           from sms_pro_filter t01,
                sms_filter t02
          where t01.pfi_flt_code = t02.fil_flt_code
            and t01.pfi_prf_code = rcd_profile.pro_prf_code
            and t02.fil_status = '1'
          order by t02.fil_flt_code asc;
      rcd_pro_filter csr_pro_filter%rowtype;

      cursor csr_pro_recipient is
         select t02.*
           from sms_pro_recipient t01,
                sms_recipient t02
          where t01.pre_rcp_code = t02.rec_rcp_code
            and t01.pre_prf_code = rcd_profile.pro_prf_code
            and t02.rec_status = '1'
          order by t02.rec_rcp_code asc;
      rcd_pro_recipient csr_pro_recipient%rowtype;

      cursor csr_rpt_data is
         select t01.rda_qry_code,
                t01.rda_qry_date,
                t01.rda_dat_seqn,
                nvl(t01.rda_dim_cod01,'*NONE') as rda_dim_cod01,
                nvl(t01.rda_dim_cod02,'*NONE') as rda_dim_cod02,
                nvl(t01.rda_dim_cod03,'*NONE') as rda_dim_cod03,
                nvl(t01.rda_dim_cod04,'*NONE') as rda_dim_cod04,
                nvl(t01.rda_dim_cod05,'*NONE') as rda_dim_cod05,
                nvl(t01.rda_dim_cod06,'*NONE') as rda_dim_cod06,
                nvl(t01.rda_dim_cod07,'*NONE') as rda_dim_cod07,
                nvl(t01.rda_dim_cod08,'*NONE') as rda_dim_cod08,
                nvl(t01.rda_dim_cod09,'*NONE') as rda_dim_cod09,
                nvl(t01.rda_dim_val01,'*NONE') as rda_dim_val01,
                nvl(t01.rda_dim_val02,'*NONE') as rda_dim_val02,
                nvl(t01.rda_dim_val03,'*NONE') as rda_dim_val03,
                nvl(t01.rda_dim_val04,'*NONE') as rda_dim_val04,
                nvl(t01.rda_dim_val05,'*NONE') as rda_dim_val05,
                nvl(t01.rda_dim_val06,'*NONE') as rda_dim_val06,
                nvl(t01.rda_dim_val07,'*NONE') as rda_dim_val07,
                nvl(t01.rda_dim_val08,'*NONE') as rda_dim_val08,
                nvl(t01.rda_dim_val09,'*NONE') as rda_dim_val09,
                nvl(t01.rda_val_code,'*NONE') as rda_val_code,
                nvl(t01.rda_val_data,'*NONE') as rda_val_data
           from sms_rpt_data t01
          where t01.rda_qry_code = par_qry_code
            and t01.rda_qry_date = par_qry_date
            and (nvl(rcd_pro_filter.fil_dim_val01,'*ALL') = '*ALL' or nvl(t01.rda_dim_val01,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val01,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val02,'*ALL') = '*ALL' or nvl(t01.rda_dim_val02,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val02,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val03,'*ALL') = '*ALL' or nvl(t01.rda_dim_val03,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val03,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val04,'*ALL') = '*ALL' or nvl(t01.rda_dim_val04,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val04,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val05,'*ALL') = '*ALL' or nvl(t01.rda_dim_val05,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val05,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val06,'*ALL') = '*ALL' or nvl(t01.rda_dim_val06,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val06,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val07,'*ALL') = '*ALL' or nvl(t01.rda_dim_val07,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val07,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val08,'*ALL') = '*ALL' or nvl(t01.rda_dim_val08,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val08,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val09,'*ALL') = '*ALL' or nvl(t01.rda_dim_val09,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val09,'*ALL'),'*TOTAL'))
          order by t01.rda_dat_seqn asc;
      rcd_rpt_data csr_rpt_data%rowtype;

      cursor csr_rpt_message is
         select t01.*
           from sms_rpt_message t01
          where t01.rme_qry_code = rcd_sms_rpt_execution.rex_qry_code
            and t01.rme_qry_date = rcd_sms_rpt_execution.rex_qry_date
            and t01.rme_exe_seqn = rcd_sms_rpt_execution.rex_exe_seqn
          order by t01.rme_msg_seqn asc;
      rcd_rpt_message csr_rpt_message%rowtype;

      cursor csr_rcp_count is
         select count(*) as rec_count
           from sms_rpt_recipient t01
          where t01.rre_qry_code = rcd_sms_rpt_execution.rex_qry_code
            and t01.rre_qry_date = rcd_sms_rpt_execution.rex_qry_date
            and t01.rre_exe_seqn = rcd_sms_rpt_execution.rex_exe_seqn
            and t01.rre_msg_seqn = rcd_rpt_message.rme_msg_seqn;
      rcd_rcp_count csr_rcp_count%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'SMS - REPORT_GENERATION';
      var_log_search := 'SMS_REPORT_GENERATION';
      var_alert := sms_gen_function.retrieve_system_value('REPORT_GENERATION_ALERT');
      var_email := sms_gen_function.retrieve_system_value('REPORT_GENERATION_EMAIL_GROUP');
      var_errors := false;
      var_warnings := false;
      var_sta_text := '*AUTOMATIC';
      if var_sta_text = '2' then
         var_sta_text := '*SUBMITTED';
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SMS Report Generation - Parameters('||par_qry_code||' + '||par_qry_date||' + '||var_sta_text||')');

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('#-> Validating Parameters');

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_qry_code is null then
         raise_application_error(-20000, 'Query code must be supplied');
      end if;
      if par_qry_date is null then
         raise_application_error(-20000, 'Query date must be supplied');
      end if;

      /*-*/
      /* Retrieve SMTP server values
      /*-*/
      var_smtp_target := sms_gen_function.retrieve_system_value('SMTP_TARGET');
      var_smtp_host := sms_gen_function.retrieve_system_value('SMTP_HOST');
      var_smtp_port := sms_gen_function.retrieve_system_value('SMTP_PORT');
      if trim(var_smtp_target) is null or trim(upper(var_smtp_target)) = '*NONE' then
         raise_application_error(-20000, 'SMTP target system value has not been specified');
      end if;
      if trim(var_smtp_host) is null or trim(upper(var_smtp_host)) = '*NONE' then
         raise_application_error(-20000, 'SMTP host system value has not been specified');
      end if;
      if trim(var_smtp_port) is null or trim(upper(var_smtp_port)) = '*NONE' then
         raise_application_error(-20000, 'SMTP port system value has not been specified');
      end if;

      /*-*/
      /* Retrieve and lock the report
      /*-*/
      var_found := false;
      begin
         open csr_report;
         fetch csr_report into rcd_report;
         if csr_report%found then
            var_found := true;
         end if;
         close csr_report;
      exception
         when others then
            raise_application_error(-20000, 'Report ('||par_qry_code||' / '||par_qry_date||') is currently locked');
      end;
      if var_found = false then
         raise_application_error(-20000, 'Report ('||par_qry_code||' / '||par_qry_date||') not found on the report header table');
      end if;
      if rcd_report.rhe_status != '6' then
         raise_application_error(-20000, 'Report ('||par_qry_code||' / '||par_qry_date||') must be status executing');
      end if;

      /*-*/
      /* Retrieve the report execution sequence
      /*-*/
      open csr_execution;
      fetch csr_execution into rcd_execution;
      if csr_execution%notfound then
         rcd_execution.max_exe_seqn := 0;
      end if;
      close csr_execution;
      rcd_execution.max_exe_seqn := rcd_execution.max_exe_seqn + 1;

      /*-*/
      /* Retrieve the related query
      /*-*/
      var_found := false;
      open csr_query;
      fetch csr_query into rcd_query;
      if csr_query%found then
         var_found := true;
      end if;
      close csr_query;
      if var_found = false then
         raise_application_error(-20000, 'Query ('||par_qry_code||') not found on the query table');
      end if;
      if rcd_query.que_status != '1' then
         raise_application_error(-20000, 'Query ('||par_qry_code||') must be status active');
      end if;
      var_subject := rcd_query.que_ema_subject;

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('#-> Processing SMS query - '||par_qry_code);

      /*-*/
      /* Initialise the output day
      /*-*/
      if (to_number(substr(to_char(rcd_report.rhe_crt_yyyyppw,'fm0000000'),7,1)) = 1 and
          to_number(trim(to_char(to_date(rcd_report.rhe_crt_date,'yyyymmdd'),'D')))-2 = 0) then         
         if (to_number(substr(to_char(rcd_report.rhe_crt_yyyypp,'fm000000'),5,2)) = 1) then
            var_out_day := 'P13W4D5';
         else
            var_out_day := 'P'||to_char(to_number(substr(to_char(rcd_report.rhe_crt_yyyypp,'fm000000'),5,2)-1),'fm90')||
                           'W4D5';
         end if;
      else
         var_out_day := 'P'||to_char(to_number(substr(to_char(rcd_report.rhe_crt_yyyypp,'fm000000'),5,2)),'fm90')||
                        'W'||substr(to_char(rcd_report.rhe_crt_yyyyppw,'fm0000000'),7,1)||
                        'D'||to_char(to_number(trim(to_char(to_date(rcd_report.rhe_crt_date,'yyyymmdd'),'D')))-2);
      end if;
      var_day_number := to_number(trim(to_char(to_date(rcd_report.rhe_crt_date,'yyyymmdd'),'D')));

      /*-*/
      /* Insert the report execution
      /*-*/
      rcd_sms_rpt_execution.rex_qry_code := rcd_report.rhe_qry_code;
      rcd_sms_rpt_execution.rex_qry_date := rcd_report.rhe_qry_date;
      rcd_sms_rpt_execution.rex_exe_seqn := rcd_execution.max_exe_seqn;
      rcd_sms_rpt_execution.rex_exe_user := rcd_report.rhe_upd_user;
      rcd_sms_rpt_execution.rex_exe_date := sysdate;
      rcd_sms_rpt_execution.rex_status := par_exe_status;
      insert into sms_rpt_execution values rcd_sms_rpt_execution;

      /*-*/
      /* Initialise the report message data
      /*-*/
      rcd_sms_rpt_message.rme_qry_code := rcd_report.rhe_qry_code;
      rcd_sms_rpt_message.rme_qry_date := rcd_report.rhe_qry_date;
      rcd_sms_rpt_message.rme_exe_seqn := rcd_execution.max_exe_seqn;
      rcd_sms_rpt_message.rme_msg_seqn := 0;

      /*-*/
      /* Initialise the report recipient data
      /*-*/
      rcd_sms_rpt_recipient.rre_qry_code := rcd_report.rhe_qry_code;
      rcd_sms_rpt_recipient.rre_qry_date := rcd_report.rhe_qry_date;
      rcd_sms_rpt_recipient.rre_exe_seqn := rcd_execution.max_exe_seqn;

      /*-*/
      /* Retrieve the report query profiles
      /*-*/
      open csr_profile;
      loop
         fetch csr_profile into rcd_profile;
         if csr_profile%notfound then
            exit;
         end if;

         /*-*/
         /* Check the profile processing status
         /*-*/
         var_process := false;
         if var_day_number = 1 and rcd_profile.pro_snd_day01 = '1' then
            var_process := true;
         elsif var_day_number = 2 and rcd_profile.pro_snd_day02 = '1' then
            var_process := true;
         elsif var_day_number = 3 and rcd_profile.pro_snd_day03 = '1' then
            var_process := true;
         elsif var_day_number = 4 and rcd_profile.pro_snd_day04 = '1' then
            var_process := true;
         elsif var_day_number = 5 and rcd_profile.pro_snd_day05 = '1' then
            var_process := true;
         elsif var_day_number = 6 and rcd_profile.pro_snd_day06 = '1' then
            var_process := true;
         elsif var_day_number = 7 and rcd_profile.pro_snd_day07 = '1' then
            var_process := true;
         end if;
         if var_process = false then

            /*-*/
            /* Log the event
            /*-*/
            lics_logging.write_log('#---> SMS profile - ('||rcd_profile.pro_prf_code||') '||rcd_profile.pro_prf_name||' - not processesed on '||to_char(to_date(rcd_report.rhe_crt_date,'yyyymmdd'),'yyyy/mm/dd'));

         else

            /*-*/
            /* Log the event
            /*-*/
            lics_logging.write_log('#---> Processing SMS profile - ('||rcd_profile.pro_prf_code||') '||rcd_profile.pro_prf_name);

            /*-*/
            /* Retrieve the report query profile messages
            /*-*/
            open csr_pro_message;
            loop
               fetch csr_pro_message into rcd_pro_message;
               if csr_pro_message%notfound then
                  exit;
               end if;

               /*-*/
               /* Log the event
               /*-*/
               lics_logging.write_log('#-----> Processing SMS message - ('||rcd_pro_message.mes_msg_code||') '||rcd_pro_message.mes_msg_name);

               /*-*/
               /* Retrieve and load the related message line data
               /*-*/
               tbl_mlin.delete;
               tbl_text.delete;
               open csr_mes_line;
               fetch csr_mes_line bulk collect into tbl_mlin;
               close csr_mes_line;

               /*-*/
               /* Retrieve the report query profile filters
               /*-*/
               open csr_pro_filter;
               loop
                  fetch csr_pro_filter into rcd_pro_filter;
                  if csr_pro_filter%notfound then
                     exit;
                  end if;

                  /*-*/
                  /* Log the event
                  /*-*/
                  lics_logging.write_log('#-------> Processing SMS filter - ('||rcd_pro_filter.fil_flt_code||') '||rcd_pro_filter.fil_flt_name);

                  /*-*/
                  /* Initialise the message instance
                  /*-*/
                  tbl_text.delete;

                  /*-*/
                  /* Retrieve and load the report data based on the related filter
                  /*-*/
                  tbl_data.delete;
                  open csr_rpt_data;
                  fetch csr_rpt_data bulk collect into tbl_data;
                  close csr_rpt_data;

                  /*-*/
                  /* Initialise the data control variables
                  /*-*/
                  var_sav_val01 := '*START';
                  var_sav_val02 := '*START';
                  var_sav_val03 := '*START';
                  var_sav_val04 := '*START';
                  var_sav_val05 := '*START';
                  var_sav_val06 := '*START';
                  var_sav_val07 := '*START';
                  var_sav_val08 := '*START';
                  var_sav_val09 := '*START';
                  for idy in 1..tbl_mlin.count loop
                     tbl_dcnt(idy) := 0;
                  end loop;

                  /*-*/
                  /* Process the report data
                  /*-*/
                  for idx in 1..tbl_data.count loop

                     /*-*/
                     /* Change in repprt data dimensions
                     /*-*/
                     if tbl_data(idx).rda_dim_val01 != var_sav_val01 or
                        tbl_data(idx).rda_dim_val02 != var_sav_val02 or
                        tbl_data(idx).rda_dim_val03 != var_sav_val03 or
                        tbl_data(idx).rda_dim_val04 != var_sav_val04 or
                        tbl_data(idx).rda_dim_val05 != var_sav_val05 or
                        tbl_data(idx).rda_dim_val06 != var_sav_val06 or
                        tbl_data(idx).rda_dim_val07 != var_sav_val07 or
                        tbl_data(idx).rda_dim_val08 != var_sav_val08 or
                        tbl_data(idx).rda_dim_val09 != var_sav_val09 then

                        /*-*/
                        /* Determine the highest change level
                        /*-*/
                        var_level := '*NONE';
                        if tbl_data(idx).rda_dim_val01 != var_sav_val01 then
                           var_level := '*LVL01';
                        elsif tbl_data(idx).rda_dim_val02 != var_sav_val02 then
                           var_level := '*LVL02';
                        elsif tbl_data(idx).rda_dim_val03 != var_sav_val03 then
                           var_level := '*LVL03';
                        elsif tbl_data(idx).rda_dim_val04 != var_sav_val04 then
                           var_level := '*LVL04';
                        elsif tbl_data(idx).rda_dim_val05 != var_sav_val05 then
                           var_level := '*LVL05';
                        elsif tbl_data(idx).rda_dim_val06 != var_sav_val06 then
                           var_level := '*LVL06';
                        elsif tbl_data(idx).rda_dim_val07 != var_sav_val07 then
                           var_level := '*LVL07';
                        elsif tbl_data(idx).rda_dim_val08 != var_sav_val08 then
                           var_level := '*LVL08';
                        elsif tbl_data(idx).rda_dim_val09 != var_sav_val09 then
                           var_level := '*LVL09';
                        end if;

                        /*-*/
                        /* Determine the detail level
                        /*-*/
                        var_detail := '*NONE';
                        if tbl_data(idx).rda_dim_val01 != '*NONE' then
                           var_detail := '*LVL01';
                        end if;
                        if tbl_data(idx).rda_dim_val02 != '*NONE' then
                           var_detail := '*LVL02';
                        end if;
                        if tbl_data(idx).rda_dim_val03 != '*NONE' then
                           var_detail := '*LVL03';
                        end if;
                        if tbl_data(idx).rda_dim_val04 != '*NONE' then
                           var_detail := '*LVL04';
                        end if;
                        if tbl_data(idx).rda_dim_val05 != '*NONE' then
                           var_detail := '*LVL05';
                        end if;
                        if tbl_data(idx).rda_dim_val06 != '*NONE' then
                           var_detail := '*LVL06';
                        end if;
                        if tbl_data(idx).rda_dim_val07 != '*NONE' then
                           var_detail := '*LVL07';
                        end if;
                        if tbl_data(idx).rda_dim_val08 != '*NONE' then
                           var_detail := '*LVL08';
                        end if;
                        if tbl_data(idx).rda_dim_val09 != '*NONE' then
                           var_detail := '*LVL09';
                        end if;

                        /*-*/
                        /* Determine the total level
                        /*-*/
                        var_total := '*NONE';
                        if tbl_data(idx).rda_dim_val02 = '*TOTAL' then
                           var_total := '*LVL01';
                        elsif tbl_data(idx).rda_dim_val03 = '*TOTAL' then
                           var_total := '*LVL02';
                        elsif tbl_data(idx).rda_dim_val04 = '*TOTAL' then
                           var_total := '*LVL03';
                        elsif tbl_data(idx).rda_dim_val05 = '*TOTAL' then
                           var_total := '*LVL04';
                        elsif tbl_data(idx).rda_dim_val06 = '*TOTAL' then
                           var_total := '*LVL05';
                        elsif tbl_data(idx).rda_dim_val07 = '*TOTAL' then
                           var_total := '*LVL06';
                        elsif tbl_data(idx).rda_dim_val08 = '*TOTAL' then
                           var_total := '*LVL07';
                        elsif tbl_data(idx).rda_dim_val09 = '*TOTAL' then
                           var_total := '*LVL08';
                        end if;

                        /*-*/
                        /* Save the current dimension values
                        /*-*/
                        var_sav_val01 := tbl_data(idx).rda_dim_val01;
                        var_sav_val02 := tbl_data(idx).rda_dim_val02;
                        var_sav_val03 := tbl_data(idx).rda_dim_val03;
                        var_sav_val04 := tbl_data(idx).rda_dim_val04;
                        var_sav_val05 := tbl_data(idx).rda_dim_val05;
                        var_sav_val06 := tbl_data(idx).rda_dim_val06;
                        var_sav_val07 := tbl_data(idx).rda_dim_val07;
                        var_sav_val08 := tbl_data(idx).rda_dim_val08;
                        var_sav_val09 := tbl_data(idx).rda_dim_val09;

                        /*-*/
                        /* Update the heading data as required
                        /*-*/
                        if var_total = '*NONE' then
                           for idy in 1..tbl_mlin.count loop
                              if upper(tbl_mlin(idy).mli_msg_line) >= var_level then
                                 tbl_dcnt(idy) := 0;
                              end if;
                           end loop;
                           if var_level = var_detail then
                              for idy in 1..tbl_mlin.count loop
                                 if upper(tbl_mlin(idy).mli_msg_line) < var_detail then
                                    tbl_dcnt(idy) := tbl_dcnt(idy) + 1;
                                 end if;
                              end loop;
                           end if;
                           for idy in 1..tbl_mlin.count loop
                              if (upper(tbl_mlin(idy).mli_msg_line) >= var_level and
                                  upper(tbl_mlin(idy).mli_msg_line) <= var_detail and
                                  upper(tbl_mlin(idy).mli_det_text) != '*NONE') then
                                 var_sms_work := tbl_mlin(idy).mli_det_text;
                                 var_sms_work := replace(var_sms_work,'<MARS_DAY>',var_out_day);
                                 if upper(tbl_mlin(idy).mli_msg_line) = '*LVL01' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val01));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL02' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val02));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL03' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val03));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL04' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val04));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL05' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val05));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL06' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val06));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL07' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val07));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL08' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val08));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL09' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val09));
                                 end if;
                                 tbl_text(tbl_text.count+1) := var_sms_work;
                              end if;
                           end loop;
                        else
                           for idy in 1..tbl_mlin.count loop
                              if (upper(tbl_mlin(idy).mli_msg_line) = var_total and
                                  upper(tbl_mlin(idy).mli_tot_text) != '*NONE' and
                                  (tbl_mlin(idy).mli_tot_child = '1' or (tbl_mlin(idy).mli_tot_child = '2' and tbl_dcnt(idy) > 1))) then
                                 var_sms_work := tbl_mlin(idy).mli_tot_text;
                                 var_sms_work := replace(var_sms_work,'<MARS_DAY>',var_out_day);
                                 if upper(tbl_mlin(idy).mli_msg_line) = '*LVL01' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val01));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL02' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val02));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL03' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val03));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL04' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val04));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL05' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val05));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL06' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val06));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL07' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val07));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL08' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val08));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL09' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val09));
                                 end if;
                                 tbl_text(tbl_text.count+1) := var_sms_work;
                              end if;
                           end loop;
                        end if;

                     end if;

                     /*-*/
                     /* Update the detail and total lines as required
                     /*-*/
                     if var_total = '*NONE' then
                        for idy in 1..tbl_mlin.count loop
                           if (upper(tbl_mlin(idy).mli_msg_line) = var_detail and
                               upper(tbl_mlin(idy).mli_det_text) != '*NONE') then
                              var_sms_work := tbl_text(tbl_text.count);
                              if upper(tbl_mlin(idy).mli_msg_line) = '*LVL01' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL02' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL03' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL04' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL05' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL06' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL07' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL08' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL09' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              end if;
                              tbl_text(tbl_text.count) := var_sms_work;
                           end if;
                        end loop;
                     else
                        for idy in 1..tbl_mlin.count loop
                           if (upper(tbl_mlin(idy).mli_msg_line) = var_total and
                               upper(tbl_mlin(idy).mli_tot_text) != '*NONE' and
                               (tbl_mlin(idy).mli_tot_child = '1' or (tbl_mlin(idy).mli_tot_child = '2' and tbl_dcnt(idy) > 1))) then
                              var_sms_work := tbl_text(tbl_text.count);
                              if upper(tbl_mlin(idy).mli_msg_line) = '*LVL01' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL02' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL03' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL04' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL05' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL06' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL07' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL08' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL09' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              end if;
                              tbl_text(tbl_text.count) := var_sms_work;
                           end if;
                        end loop;
                     end if;

                  end loop;

                  /*-*/
                  /* Process the message when report data found
                  /*-*/
                  if tbl_data.count != 0 then

                     /*-*/
                     /* Build the report message
                     /*-*/
                     var_sms_text := null;
                     for idt in 1..tbl_text.count loop
                        if not(var_sms_text is null) then
                           var_sms_text := var_sms_text || utl_tcp.CRLF;
                        end if;
                        var_sms_text := var_sms_text || tbl_text(idt);
                     end loop;

                     /*-*/
                     /* Process the message when required
                     /*-*/
                     if not(var_sms_text is null) then

                        /*-*/
                        /* Insert the report message
                        /*-*/
                        rcd_sms_rpt_message.rme_msg_seqn := rcd_sms_rpt_message.rme_msg_seqn + 1;
                        rcd_sms_rpt_message.rme_msg_text := substr(var_sms_text,1,2000);
                        rcd_sms_rpt_message.rme_msg_time := sysdate;
                        rcd_sms_rpt_message.rme_msg_status := '1';
                        rcd_sms_rpt_message.rme_prf_code := rcd_profile.pro_prf_code;
                        rcd_sms_rpt_message.rme_msg_code := rcd_pro_message.mes_msg_code;
                        rcd_sms_rpt_message.rme_flt_code := rcd_pro_filter.fil_flt_code;
                        insert into sms_rpt_message values rcd_sms_rpt_message;

                        /*-*/
                        /* Retrieve and attached all profile recipients
                        /*-*/
                        var_rec_count := 0;
                        open csr_pro_recipient;
                        loop
                           fetch csr_pro_recipient into rcd_pro_recipient;
                           if csr_pro_recipient%notfound then
                              exit;
                           end if;
                           var_rec_count := var_rec_count + 1;
                           rcd_sms_rpt_recipient.rre_msg_seqn := rcd_sms_rpt_message.rme_msg_seqn;
                           rcd_sms_rpt_recipient.rre_rcp_code := rcd_pro_recipient.rec_rcp_code;
                           rcd_sms_rpt_recipient.rre_rcp_name := rcd_pro_recipient.rec_rcp_name;
                           rcd_sms_rpt_recipient.rre_rcp_mobile := rcd_pro_recipient.rec_rcp_mobile;
                           rcd_sms_rpt_recipient.rre_rcp_email := rcd_pro_recipient.rec_rcp_email;
                           insert into sms_rpt_recipient values rcd_sms_rpt_recipient;
                        end loop;
                        close csr_pro_recipient;

                        /*-*/
                        /* Log the event
                        /*-*/
                        lics_logging.write_log('#---------> Message constructed and attached to '||to_char(var_rec_count)||' recipient(s)');

                     else

                        /*-*/
                        /* Log the event
                        /*-*/
                        lics_logging.write_log('#---------> Report data found for the filter dimensions but no message text generated');

                     end if;

                  else

                     /*-*/
                     /* Log the event
                     /*-*/
                     lics_logging.write_log('#---------> No report data found for the filter dimensions');

                  end if;

               end loop;
               close csr_pro_filter;

            end loop;
            close csr_pro_message;

         end if;

      end loop;
      close csr_profile;

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('#-> Sending SMS messages to recipients');

      /*-*/
      /* Send the report messages
      /*-*/
      open csr_rpt_message;
      loop
         fetch csr_rpt_message into rcd_rpt_message;
         if csr_rpt_message%notfound then
            exit;
         end if;
         var_sent := true;
         open csr_rcp_count;
         fetch csr_rcp_count into rcd_rcp_count;
         if csr_rcp_count%notfound then
            rcd_rcp_count.rec_count := 0;
         end if;
         close csr_rcp_count;
         if rcd_rcp_count.rec_count != 0 then
            begin
               send_sms(var_smtp_target,
                        var_smtp_host,
                        var_smtp_port,
                        rcd_rpt_message.rme_qry_code,
                        rcd_rpt_message.rme_qry_date,
                        rcd_rpt_message.rme_exe_seqn,
                        rcd_rpt_message.rme_msg_seqn,
                        var_subject,
                        rcd_rpt_message.rme_msg_text);
            exception
               when others then
                  var_warnings := true;
                  var_sent := false;
                  lics_logging.write_log('#---> **WARNING** - SMS message ('||to_char(rcd_rpt_message.rme_msg_seqn)||') send failed - '||substr(sqlerrm, 1, 2000));
            end;
         else
            var_warnings := true;
            var_sent := false;
            lics_logging.write_log('#---> **WARNING** - SMS message ('||to_char(rcd_rpt_message.rme_msg_seqn)||') not sent - no recipients attached');
         end if;
         if var_sent = true then
            update sms_rpt_message
               set rme_msg_status = '2'
             where rme_qry_code = rcd_rpt_message.rme_qry_code
               and rme_qry_date = rcd_rpt_message.rme_qry_date
               and rme_exe_seqn = rcd_rpt_message.rme_exe_seqn
               and rme_msg_seqn = rcd_rpt_message.rme_msg_seqn;
         else
            update sms_rpt_message
               set rme_msg_status = '3'
             where rme_qry_code = rcd_rpt_message.rme_qry_code
               and rme_qry_date = rcd_rpt_message.rme_qry_date
               and rme_exe_seqn = rcd_rpt_message.rme_exe_seqn
               and rme_msg_seqn = rcd_rpt_message.rme_msg_seqn;
         end if;

      end loop;
      close csr_rpt_message;

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('#-> Updating the report status');

      /*-*/
      /* Update the report header to processed
      /*-*/
      update sms_rpt_header
         set rhe_status = '2'
       where rhe_qry_code = par_qry_code
         and rhe_qry_date = par_qry_date;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SMS Report Generation');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Warnings
      /*-*/
      if var_warnings = true then

         /*-*/
         /* Email
         /*-*/
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(sms_parameter.system_code,
                                         sms_parameter.system_unit,
                                         sms_parameter.system_environment,
                                         con_function||' - **WARNING**',
                                         'SMS_REPORT_GENERATION',
                                         var_email,
                                         'SMS message warnings occurred during the SMS Report Generation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

      end if;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then

         /*-*/
         /* Alert and email
         /*-*/
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(sms_parameter.system_code,
                                         sms_parameter.system_unit,
                                         sms_parameter.system_environment,
                                         con_function||' - **ERROR**',
                                         'SMS_REPORT_GENERATION',
                                         var_email,
                                         'One or more errors occurred during the SMS Report Generation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

      end if;

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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         end if;

         /*-*/
         /* Alert and email
         /*-*/
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(sms_parameter.system_code,
                                         sms_parameter.system_unit,
                                         sms_parameter.system_environment,
                                         con_function||' - **ERROR**',
                                         'SMS_REPORT_GENERATION',
                                         var_email,
                                         'A fatal error occurred during the SMS Report Generation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end generate;

   /************************************************/
   /* This procedure performs the send SMS routine */
   /************************************************/
   procedure send_sms(par_smtp_target in varchar2,
                      par_smtp_host in varchar2,
                      par_smtp_port in varchar2,
                      par_qry_code in varchar2,
                      par_qry_date in varchar2,
                      par_exe_seqn in number,
                      par_msg_seqn in number,
                      par_subject in varchar2,
                      par_content in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      con_max_length constant number := 160;
      var_connection utl_smtp.connection;
      var_indx number;
      var_part number;
      type typ_line is table of varchar2(256) index by binary_integer;
      tbl_line typ_line;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_rpt_recipient is
         select t01.*
           from sms_rpt_recipient t01
          where t01.rre_qry_code = par_qry_code
            and t01.rre_qry_date = par_qry_date
            and t01.rre_exe_seqn = par_exe_seqn
            and t01.rre_msg_seqn = par_msg_seqn
          order by t01.rre_rcp_code asc;
      rcd_rpt_recipient csr_rpt_recipient%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message parts
      /*-*/
      tbl_line.delete;
      if length(par_content) <= con_max_length then
         tbl_line(tbl_line.count+1) := par_content;
      else
         var_part := 1;
         var_indx := con_max_length;
         for idx in 1..length(par_content) loop
            if var_indx >= con_max_length then
               tbl_line(tbl_line.count+1) := 'M'||to_char(par_msg_seqn)||'P'||to_char(var_part)||' ';
               var_part := var_part + 1;
               var_indx := length('M'||to_char(par_msg_seqn)||'P'||to_char(var_part)||' ');
            end if;
            tbl_line(tbl_line.count) := tbl_line(tbl_line.count)||substr(par_content,idx,1);
            var_indx := var_indx + 1;
         end loop;
      end if;

      /*-*/
      /* Initialise the email environment
      /*-*/
      var_connection := utl_smtp.open_connection(par_smtp_host, par_smtp_port);
      utl_smtp.helo(var_connection, par_smtp_host);

      /*-*/
      /* Send all SMS message parts
      /*-*/
      for idx in 1..tbl_line.count loop

         /*-*/
         /* Initialise the email
         /*-*/
         utl_smtp.mail(var_connection, 'MCH.BW@MCH');

         /*-*/
         /* Set the recipient(s)
         /*-*/
         open csr_rpt_recipient;
         loop
            fetch csr_rpt_recipient into rcd_rpt_recipient;
            if csr_rpt_recipient%notfound then
               exit;
            end if;
            utl_smtp.rcpt(var_connection, rcd_rpt_recipient.rre_rcp_mobile||'@'||par_smtp_target);
         end loop;
         close csr_rpt_recipient;

         /*-*/
         /* Load the email message
         /*-*/
         utl_smtp.open_data(var_connection);
         utl_smtp.write_data(var_connection, 'Subject: ' || par_subject || utl_tcp.CRLF);
         utl_smtp.write_data(var_connection, utl_tcp.CRLF || tbl_line(idx));

         /*-*/
         /* Close the data stream
         /*-*/
         utl_smtp.close_data(var_connection);

      end loop;

      /*-*/
      /* Close the data stream and quit the connection
      /*-*/
      utl_smtp.quit(var_connection);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_sms;

   /************************************************/
   /* This procedure performs the convert routine */
   /************************************************/
   function convert_value(par_value in varchar2, par_round in number) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(256 char);
      var_number number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the convert value
      /*-*/
      var_return := par_value;
      begin
         if substr(par_value,length(par_value),1) = '-' then
            var_number := to_number('-' || substr(par_value,1,length(par_value) - 1));
         else
            var_number := to_number(par_value);
         end if;
         var_return := to_char(var_number);
         if par_round != -1 then
            var_return := to_char(round(var_number,par_round));
         end if;
      exception
         when others then
            var_return := par_value;
      end;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end convert_value;

end sms_rep_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym sms_rep_function for sms_app.sms_rep_function;
grant execute on sms_app.sms_rep_function to public;

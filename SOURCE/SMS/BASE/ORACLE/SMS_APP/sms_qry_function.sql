/******************/
/* Package Header */
/******************/
create or replace package sms_app.sms_qry_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : sms_qry_function
    Owner   : sms_app

    Description
    -----------
    SMS Reporting System - Query Function

    This package contain the query functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/07   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function select_list return sms_xml_type pipelined;
   function retrieve_data return sms_xml_type pipelined;
   procedure update_data(par_user in varchar2);

end sms_qry_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body sms_app.sms_qry_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***************************************************/
   /* This procedure performs the select list routine */
   /***************************************************/
   function select_list return sms_xml_type pipelined is

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
      var_pag_more boolean;
      var_str_list varchar2(1);
      var_end_list varchar2(1);

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
          where rownum <= var_pag_size + 1;

      cursor csr_next is
         select t01.*
           from (select t01.que_qry_code,
                        t01.que_qry_name,
                        decode(t01.que_status,'0','Inactive','1','Active','*UNKNOWN') as que_status
                   from sms_query t01
                  where (var_end_code is null or t01.que_qry_code > var_end_code)
                  order by t01.que_qry_code asc) t01
          where rownum <= var_pag_size + 1;

      cursor csr_prev is
         select t01.*
           from (select t01.que_qry_code,
                        t01.que_qry_name,
                        decode(t01.que_status,'0','Inactive','1','Active','*UNKNOWN') as que_status
                   from sms_query t01
                  where (var_str_code is null or t01.que_qry_code < var_str_code)
                  order by t01.que_qry_code desc) t01
          where rownum <= var_pag_size + 1;

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
      var_str_code := xslProcessor.valueOf(obj_sms_request,'@STRCDE');
      var_end_code := xslProcessor.valueOf(obj_sms_request,'@ENDCDE');
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
      var_pag_more := false;
      if var_action = '*SELQRY' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW QRYCDE="'||to_char(tbl_list(idx).que_qry_code)||'" QRYNAM="'||sms_to_xml(tbl_list(idx).que_qry_name)||'" QRYSTS="'||sms_to_xml(tbl_list(idx).que_status)||'"/>'));
         end loop;
         if tbl_list.count > var_pag_size then
            var_pag_more := true;
         end if;
      elsif var_action = '*NXTQRY' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         for idx in 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW QRYCDE="'||to_char(tbl_list(idx).que_qry_code)||'" QRYNAM="'||sms_to_xml(tbl_list(idx).que_qry_name)||'" QRYSTS="'||sms_to_xml(tbl_list(idx).que_status)||'"/>'));
         end loop;
         if tbl_list.count > var_pag_size then
            var_pag_more := true;
         end if;
      elsif var_action = '*PRVQRY' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         for idx in reverse 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW QRYCDE="'||to_char(tbl_list(idx).que_qry_code)||'" QRYNAM="'||sms_to_xml(tbl_list(idx).que_qry_name)||'" QRYSTS="'||sms_to_xml(tbl_list(idx).que_status)||'"/>'));
         end loop;
         if tbl_list.count > var_pag_size then
            var_pag_more := true;
         end if;
      end if;

      /*-*/
      /* Set and pipe the list control values
      /*-*/
      var_str_list := '1';
      var_end_list := '1';
      if var_action = '*SELQRY' then
         var_str_list := '1';
         var_end_list := '1';
         if var_pag_more = true then
            var_end_list := '0';
         end if;
      elsif var_action = '*NXTQRY' then
         var_str_list := '0';
         var_end_list := '1';
         if var_pag_more = true then
            var_end_list := '0';
         end if;
      elsif var_action = '*PRVQRY' then
         var_str_list := '1';
         var_end_list := '0';
         if var_pag_more = true then
            var_str_list := '0';
         end if;
      end if;
      pipe row(sms_xml_object('<LSTCTL STRLST="'||var_str_list||'" ENDLST="'||var_end_list||'"/>'));

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_QRY_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_list;

   /*****************************************************/
   /* This procedure performs the retrieve data routine */
   /*****************************************************/
   function retrieve_data return sms_xml_type pipelined is

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
      var_qry_code := xslProcessor.valueOf(obj_sms_request,'@QRYCDE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDQRY' and var_action != '*CRTQRY' and var_action != '*CPYQRY' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing query when required
      /*-*/
      if var_action = '*UPDQRY' or var_action = '*CPYQRY' then
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
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(sms_xml_object('<?xml version="1.0" encoding="UTF-8"?><SMS_RESPONSE>'));

      /*-*/
      /* Pipe the query XML
      /*-*/
      if var_action = '*UPDQRY' then
         var_output := '<QUERY QRYCDE="'||sms_to_xml(rcd_retrieve.que_qry_code)||'"';
         var_output := var_output||' QRYNAM="'||sms_to_xml(rcd_retrieve.que_qry_name)||'"';
         var_output := var_output||' QRYSTS="'||sms_to_xml(rcd_retrieve.que_status)||'"';
         var_output := var_output||' EMASUB="'||sms_to_xml(rcd_retrieve.que_ema_subject)||'"';
         var_output := var_output||' RCVD01="'||sms_to_xml(rcd_retrieve.que_rcv_day01)||'"';
         var_output := var_output||' RCVD02="'||sms_to_xml(rcd_retrieve.que_rcv_day02)||'"';
         var_output := var_output||' RCVD03="'||sms_to_xml(rcd_retrieve.que_rcv_day03)||'"';
         var_output := var_output||' RCVD04="'||sms_to_xml(rcd_retrieve.que_rcv_day04)||'"';
         var_output := var_output||' RCVD05="'||sms_to_xml(rcd_retrieve.que_rcv_day05)||'"';
         var_output := var_output||' RCVD06="'||sms_to_xml(rcd_retrieve.que_rcv_day06)||'"';
         var_output := var_output||' RCVD07="'||sms_to_xml(rcd_retrieve.que_rcv_day07)||'"';
         var_output := var_output||' DIMDEP="'||to_char(rcd_retrieve.que_dim_depth)||'"';
         var_output := var_output||' DIMC01="'||sms_to_xml(rcd_retrieve.que_dim_cod01)||'"';
         var_output := var_output||' DIMC02="'||sms_to_xml(rcd_retrieve.que_dim_cod02)||'"';
         var_output := var_output||' DIMC03="'||sms_to_xml(rcd_retrieve.que_dim_cod03)||'"';
         var_output := var_output||' DIMC04="'||sms_to_xml(rcd_retrieve.que_dim_cod04)||'"';
         var_output := var_output||' DIMC05="'||sms_to_xml(rcd_retrieve.que_dim_cod05)||'"';
         var_output := var_output||' DIMC06="'||sms_to_xml(rcd_retrieve.que_dim_cod06)||'"';
         var_output := var_output||' DIMC07="'||sms_to_xml(rcd_retrieve.que_dim_cod07)||'"';
         var_output := var_output||' DIMC08="'||sms_to_xml(rcd_retrieve.que_dim_cod08)||'"';
         var_output := var_output||' DIMC09="'||sms_to_xml(rcd_retrieve.que_dim_cod09)||'"/>';
         pipe row(sms_xml_object(var_output));
      elsif var_action = '*CPYQRY' then
         var_output := '<QUERY QRYCDE=""';
         var_output := var_output||' QRYNAM="'||sms_to_xml(rcd_retrieve.que_qry_name)||'"';
         var_output := var_output||' QRYSTS="'||sms_to_xml(rcd_retrieve.que_status)||'"';
         var_output := var_output||' EMASUB="'||sms_to_xml(rcd_retrieve.que_ema_subject)||'"';
         var_output := var_output||' RCVD01="'||sms_to_xml(rcd_retrieve.que_rcv_day01)||'"';
         var_output := var_output||' RCVD02="'||sms_to_xml(rcd_retrieve.que_rcv_day02)||'"';
         var_output := var_output||' RCVD03="'||sms_to_xml(rcd_retrieve.que_rcv_day03)||'"';
         var_output := var_output||' RCVD04="'||sms_to_xml(rcd_retrieve.que_rcv_day04)||'"';
         var_output := var_output||' RCVD05="'||sms_to_xml(rcd_retrieve.que_rcv_day05)||'"';
         var_output := var_output||' RCVD06="'||sms_to_xml(rcd_retrieve.que_rcv_day06)||'"';
         var_output := var_output||' RCVD07="'||sms_to_xml(rcd_retrieve.que_rcv_day07)||'"';
         var_output := var_output||' DIMDEP="'||to_char(rcd_retrieve.que_dim_depth)||'"';
         var_output := var_output||' DIMC01="'||sms_to_xml(rcd_retrieve.que_dim_cod01)||'"';
         var_output := var_output||' DIMC02="'||sms_to_xml(rcd_retrieve.que_dim_cod02)||'"';
         var_output := var_output||' DIMC03="'||sms_to_xml(rcd_retrieve.que_dim_cod03)||'"';
         var_output := var_output||' DIMC04="'||sms_to_xml(rcd_retrieve.que_dim_cod04)||'"';
         var_output := var_output||' DIMC05="'||sms_to_xml(rcd_retrieve.que_dim_cod05)||'"';
         var_output := var_output||' DIMC06="'||sms_to_xml(rcd_retrieve.que_dim_cod06)||'"';
         var_output := var_output||' DIMC07="'||sms_to_xml(rcd_retrieve.que_dim_cod07)||'"';
         var_output := var_output||' DIMC08="'||sms_to_xml(rcd_retrieve.que_dim_cod08)||'"';
         var_output := var_output||' DIMC09="'||sms_to_xml(rcd_retrieve.que_dim_cod09)||'"/>';
         pipe row(sms_xml_object(var_output));
      elsif var_action = '*CRTQRY' then
         var_output := '<QUERY QRYCDE=""';
         var_output := var_output||' QRYNAM=""';
         var_output := var_output||' QRYSTS="1"';
         var_output := var_output||' EMASUB=""';
         var_output := var_output||' RCVD01="0"';
         var_output := var_output||' RCVD02="0"';
         var_output := var_output||' RCVD03="0"';
         var_output := var_output||' RCVD04="0"';
         var_output := var_output||' RCVD05="0"';
         var_output := var_output||' RCVD06="0"';
         var_output := var_output||' RCVD07="0"';
         var_output := var_output||' DIMDEP="0"';
         var_output := var_output||' DIMC01=""';
         var_output := var_output||' DIMC02=""';
         var_output := var_output||' DIMC03=""';
         var_output := var_output||' DIMC04=""';
         var_output := var_output||' DIMC05=""';
         var_output := var_output||' DIMC06=""';
         var_output := var_output||' DIMC07=""';
         var_output := var_output||' DIMC08=""';
         var_output := var_output||' DIMC09=""/>';
         pipe row(sms_xml_object(var_output));
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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_QRY_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      obj_sms_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      rcd_sms_query sms_query%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_query t01
          where t01.que_qry_code = rcd_sms_query.que_qry_code
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
      if var_action != '*UPDQRY' and var_action != '*CRTQRY' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_sms_query.que_qry_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYCDE'));
      rcd_sms_query.que_qry_name := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYNAM'));
      rcd_sms_query.que_status := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYSTS'));
      rcd_sms_query.que_upd_user := upper(par_user);
      rcd_sms_query.que_upd_date := sysdate;
      rcd_sms_query.que_ema_subject := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@EMASUB'));
      rcd_sms_query.que_rcv_day01 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@RCVD01'));
      rcd_sms_query.que_rcv_day02 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@RCVD02'));
      rcd_sms_query.que_rcv_day03 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@RCVD03'));
      rcd_sms_query.que_rcv_day04 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@RCVD04'));
      rcd_sms_query.que_rcv_day05 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@RCVD05'));
      rcd_sms_query.que_rcv_day06 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@RCVD06'));
      rcd_sms_query.que_rcv_day07 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@RCVD07'));
      rcd_sms_query.que_dim_depth := sms_to_number(xslProcessor.valueOf(obj_sms_request,'@DIMDEP'));
      rcd_sms_query.que_dim_cod01 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMC01'));
      rcd_sms_query.que_dim_cod02 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMC02'));
      rcd_sms_query.que_dim_cod03 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMC03'));
      rcd_sms_query.que_dim_cod04 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMC04'));
      rcd_sms_query.que_dim_cod05 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMC05'));
      rcd_sms_query.que_dim_cod06 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMC06'));
      rcd_sms_query.que_dim_cod07 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMC07'));
      rcd_sms_query.que_dim_cod08 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMC08'));
      rcd_sms_query.que_dim_cod09 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMC09'));
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_sms_query.que_qry_code is null then
         sms_gen_function.add_mesg_data('Query code must be supplied');
      end if;
      if rcd_sms_query.que_qry_name is null then
         sms_gen_function.add_mesg_data('Query name must be supplied');
      end if;
      if rcd_sms_query.que_status is null or (rcd_sms_query.que_status != '0' and rcd_sms_query.que_status != '1') then
         sms_gen_function.add_mesg_data('Query status must be (0)inactive or (1)active');
      end if;
      if rcd_sms_query.que_upd_user is null then
         sms_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if rcd_sms_query.que_ema_subject is null then
         sms_gen_function.add_mesg_data('Query SMS subject must be supplied');
      end if;
      if rcd_sms_query.que_rcv_day01 is null or (rcd_sms_query.que_rcv_day01 != '0' and rcd_sms_query.que_rcv_day01 != '1') then
         sms_gen_function.add_mesg_data('Query receive on sunday must be (0)no or (1)yes');
      end if;
      if rcd_sms_query.que_rcv_day02 is null or (rcd_sms_query.que_rcv_day02 != '0' and rcd_sms_query.que_rcv_day02 != '1') then
         sms_gen_function.add_mesg_data('Query receive on monday must be (0)no or (1)yes');
      end if;
      if rcd_sms_query.que_rcv_day03 is null or (rcd_sms_query.que_rcv_day03 != '0' and rcd_sms_query.que_rcv_day03 != '1') then
         sms_gen_function.add_mesg_data('Query receive on tuesday must be (0)no or (1)yes');
      end if;
      if rcd_sms_query.que_rcv_day04 is null or (rcd_sms_query.que_rcv_day04 != '0' and rcd_sms_query.que_rcv_day04 != '1') then
         sms_gen_function.add_mesg_data('Query receive on wednesday must be (0)no or (1)yes');
      end if;
      if rcd_sms_query.que_rcv_day05 is null or (rcd_sms_query.que_rcv_day05 != '0' and rcd_sms_query.que_rcv_day05 != '1') then
         sms_gen_function.add_mesg_data('Query receive on thursday must be (0)no or (1)yes');
      end if;
      if rcd_sms_query.que_rcv_day06 is null or (rcd_sms_query.que_rcv_day06 != '0' and rcd_sms_query.que_rcv_day06 != '1') then
         sms_gen_function.add_mesg_data('Query receive on friday must be (0)no or (1)yes');
      end if;
      if rcd_sms_query.que_rcv_day07 is null or (rcd_sms_query.que_rcv_day07 != '0' and rcd_sms_query.que_rcv_day07 != '1') then
         sms_gen_function.add_mesg_data('Query receive on saturday must be (0)no or (1)yes');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) < 1 or nvl(rcd_sms_query.que_dim_depth,0) > 9 then
         sms_gen_function.add_mesg_data('Query dimension depth must be in range 1 to 9');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) >= 1 and rcd_sms_query.que_dim_cod01 is null then
         sms_gen_function.add_mesg_data('Query dimension level 1 name must be supplied');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) >= 2 and rcd_sms_query.que_dim_cod02 is null then
         sms_gen_function.add_mesg_data('Query dimension level 2 name must be supplied');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) >= 3 and rcd_sms_query.que_dim_cod03 is null then
         sms_gen_function.add_mesg_data('Query dimension level 3 name must be supplied');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) >= 4 and rcd_sms_query.que_dim_cod04 is null then
         sms_gen_function.add_mesg_data('Query dimension level 4 name must be supplied');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) >= 5 and rcd_sms_query.que_dim_cod05 is null then
         sms_gen_function.add_mesg_data('Query dimension level 5 name must be supplied');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) >= 6 and rcd_sms_query.que_dim_cod06 is null then
         sms_gen_function.add_mesg_data('Query dimension level 6 name must be supplied');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) >= 7 and rcd_sms_query.que_dim_cod07 is null then
         sms_gen_function.add_mesg_data('Query dimension level 7 name must be supplied');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) >= 8 and rcd_sms_query.que_dim_cod08 is null then
         sms_gen_function.add_mesg_data('Query dimension level 8 name must be supplied');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) >= 9 and rcd_sms_query.que_dim_cod09 is null then
         sms_gen_function.add_mesg_data('Query dimension level 9 name must be supplied');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) < 1 and not(rcd_sms_query.que_dim_cod01 is null) then
         sms_gen_function.add_mesg_data('Query dimension level 1 name must be empty');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) < 2 and not(rcd_sms_query.que_dim_cod02 is null) then
         sms_gen_function.add_mesg_data('Query dimension level 2 name must be empty');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) < 3 and not(rcd_sms_query.que_dim_cod03 is null) then
         sms_gen_function.add_mesg_data('Query dimension level 3 name must be empty');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) < 4 and not(rcd_sms_query.que_dim_cod04 is null) then
         sms_gen_function.add_mesg_data('Query dimension level 4 name must be empty');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) < 5 and not(rcd_sms_query.que_dim_cod05 is null) then
         sms_gen_function.add_mesg_data('Query dimension level 5 name must be empty');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) < 6 and not(rcd_sms_query.que_dim_cod06 is null) then
         sms_gen_function.add_mesg_data('Query dimension level 6 name must be empty');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) < 7 and not(rcd_sms_query.que_dim_cod07 is null) then
         sms_gen_function.add_mesg_data('Query dimension level 7 name must be empty');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) < 8 and not(rcd_sms_query.que_dim_cod08 is null) then
         sms_gen_function.add_mesg_data('Query dimension level 8 name must be empty');
      end if;
      if nvl(rcd_sms_query.que_dim_depth,0) < 9 and not(rcd_sms_query.que_dim_cod09 is null) then
         sms_gen_function.add_mesg_data('Query dimension level 9 name must be empty');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the query definition
      /*-*/
      if var_action = '*UPDQRY' then
         var_confirm := 'updated';
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
               sms_gen_function.add_mesg_data('Query code ('||rcd_sms_query.que_qry_code||') is currently locked');
         end;
         if var_found = false then
            sms_gen_function.add_mesg_data('Query code ('||rcd_sms_query.que_qry_code||') does not exist');
         end if;
         if sms_gen_function.get_mesg_count = 0 then
            update sms_query
               set que_qry_name = rcd_sms_query.que_qry_name,
                   que_status = rcd_sms_query.que_status,
                   que_upd_user = rcd_sms_query.que_upd_user,
                   que_upd_date = rcd_sms_query.que_upd_date,
                   que_ema_subject = rcd_sms_query.que_ema_subject,
                   que_rcv_day01 = rcd_sms_query.que_rcv_day01,
                   que_rcv_day02 = rcd_sms_query.que_rcv_day02,
                   que_rcv_day03 = rcd_sms_query.que_rcv_day03,
                   que_rcv_day04 = rcd_sms_query.que_rcv_day04,
                   que_rcv_day05 = rcd_sms_query.que_rcv_day05,
                   que_rcv_day06 = rcd_sms_query.que_rcv_day06,
                   que_rcv_day07 = rcd_sms_query.que_rcv_day07,
                   que_dim_depth = rcd_sms_query.que_dim_depth,
                   que_dim_cod01 = rcd_sms_query.que_dim_cod01,
                   que_dim_cod02 = rcd_sms_query.que_dim_cod02,
                   que_dim_cod03 = rcd_sms_query.que_dim_cod03,
                   que_dim_cod04 = rcd_sms_query.que_dim_cod04,
                   que_dim_cod05 = rcd_sms_query.que_dim_cod05,
                   que_dim_cod06 = rcd_sms_query.que_dim_cod06,
                   que_dim_cod07 = rcd_sms_query.que_dim_cod07,
                   que_dim_cod08 = rcd_sms_query.que_dim_cod08,
                   que_dim_cod09 = rcd_sms_query.que_dim_cod09
             where que_qry_code = rcd_sms_query.que_qry_code;
         end if;
      elsif var_action = '*CRTQRY' then
         var_confirm := 'created';
         begin
            insert into sms_query values rcd_sms_query;
         exception
            when dup_val_on_index then
               sms_gen_function.add_mesg_data('Query code ('||rcd_sms_query.que_qry_code||') already exists - unable to create');
         end;
      end if;
      if sms_gen_function.get_mesg_count != 0 then
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

      /*-*/
      /* Send the confirm message
      /*-*/
      sms_gen_function.set_cfrm_data('Query ('||to_char(rcd_sms_query.que_qry_code)||') successfully '||var_confirm);

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_QRY_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

end sms_qry_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym sms_qry_function for sms_app.sms_qry_function;
grant execute on sms_app.sms_qry_function to public;

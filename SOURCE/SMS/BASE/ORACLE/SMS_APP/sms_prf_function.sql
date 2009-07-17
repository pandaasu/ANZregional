/******************/
/* Package Header */
/******************/
create or replace package sms_app.sms_prf_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : sms_prf_function
    Owner   : sms_app

    Description
    -----------
    SMS Reporting System - Profile Function

    This package contain the profile functions and procedures.

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

end sms_prf_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body sms_app.sms_prf_function as

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
           from (select t01.pro_prf_code,
                        t01.pro_prf_name,
                        decode(t01.pro_status,'0','Inactive','1','Active','*UNKNOWN') as pro_status
                   from sms_profile t01
                  where (var_str_code is null or t01.pro_prf_code >= var_str_code)
                  order by t01.pro_prf_code asc) t01
          where rownum <= var_pag_size + 1;

      cursor csr_next is
         select t01.*
           from (select t01.pro_prf_code,
                        t01.pro_prf_name,
                        decode(t01.pro_status,'0','Inactive','1','Active','*UNKNOWN') as pro_status
                   from sms_profile t01
                  where (var_end_code is null or t01.pro_prf_code > var_end_code)
                  order by t01.pro_prf_code asc) t01
          where rownum <= var_pag_size + 1;

      cursor csr_prev is
         select t01.*
           from (select t01.pro_prf_code,
                        t01.pro_prf_name,
                        decode(t01.pro_status,'0','Inactive','1','Active','*UNKNOWN') as pro_status
                   from sms_profile t01
                  where (var_str_code is null or t01.pro_prf_code < var_str_code)
                  order by t01.pro_prf_code desc) t01
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
      if var_action != '*SELPRF' and var_action != '*PRVPRF' and var_action != '*NXTPRF' then
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
      /* Retrieve the profile list and pipe the results
      /*-*/
      var_pag_size := 20;
      var_pag_more := false;
      if var_action = '*SELPRF' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW PRFCDE="'||to_char(tbl_list(idx).pro_prf_code)||'" PRFNAM="'||sms_to_xml(tbl_list(idx).pro_prf_name)||'" PRFSTS="'||sms_to_xml(tbl_list(idx).pro_status)||'"/>'));
         end loop;
         if tbl_list.count > var_pag_size then
            var_pag_more := true;
         end if;
      elsif var_action = '*NXTPRF' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         for idx in 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW PRFCDE="'||to_char(tbl_list(idx).pro_prf_code)||'" PRFNAM="'||sms_to_xml(tbl_list(idx).pro_prf_name)||'" PRFSTS="'||sms_to_xml(tbl_list(idx).pro_status)||'"/>'));
         end loop;
         if tbl_list.count > var_pag_size then
            var_pag_more := true;
         end if;
      elsif var_action = '*PRVPRF' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         for idx in reverse 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW PRFCDE="'||to_char(tbl_list(idx).pro_prf_code)||'" PRFNAM="'||sms_to_xml(tbl_list(idx).pro_prf_name)||'" PRFSTS="'||sms_to_xml(tbl_list(idx).pro_status)||'"/>'));
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
      if var_action = '*SELPRF' then
         var_str_list := '1';
         var_end_list := '1';
         if var_pag_more = true then
            var_end_list := '0';
         end if;
      elsif var_action = '*NXTPRF' then
         var_str_list := '0';
         var_end_list := '1';
         if var_pag_more = true then
            var_end_list := '0';
         end if;
      elsif var_action = '*PRVPRF' then
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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_PRF_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_prf_code varchar2(64);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_profile t01
          where t01.pro_prf_code = var_prf_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_query is
         select t01.*
           from sms_query t01
          order by t01.que_qry_code asc;
      rcd_query csr_query%rowtype;

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
      var_prf_code := xslProcessor.valueOf(obj_sms_request,'@PRFCDE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*PRFPRF' and var_action != '*PRFPRF' and var_action != '*PRFPRF' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing profile when required
      /*-*/
      if var_action = '*UPDPRF' or var_action = '*CPYPRF' then
         var_found := false;
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
         if var_found = false then
            sms_gen_function.add_mesg_data('Profile ('||var_prf_code||') does not exist');
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
      open csr_query;
      loop
         fetch csr_query into rcd_query;
         if csr_query%notfound then
            exit;
         end if;
         pipe row(sms_xml_object('<QRY_LIST QRYCDE="'||sms_to_xml(rcd_query.que_qry_code)||'" QRYNAM="'||sms_to_xml(rcd_query.que_qry_name)||'"/>'));
      end loop;
      close csr_query;

      /*-*/
      /* Pipe the profile XML
      /*-*/
      if var_action = '*UPDPRF' then
         var_output := '<PROFILE PRFCDE="'||sms_to_xml(rcd_retrieve.pro_prf_code)||'"';
         var_output := var_output||' PRFNAM="'||sms_to_xml(rcd_retrieve.pro_prf_name)||'"';
         var_output := var_output||' PRFSTS="'||sms_to_xml(rcd_retrieve.pro_status)||'"';
         var_output := var_output||' QRYCDE="'||sms_to_xml(rcd_retrieve.pro_qry_code)||'"';
         var_output := var_output||' SNDD01="'||sms_to_xml(rcd_retrieve.pro_snd_day01)||'"';
         var_output := var_output||' SNDD02="'||sms_to_xml(rcd_retrieve.pro_snd_day02)||'"';
         var_output := var_output||' SNDD03="'||sms_to_xml(rcd_retrieve.pro_snd_day03)||'"';
         var_output := var_output||' SNDD04="'||sms_to_xml(rcd_retrieve.pro_snd_day04)||'"';
         var_output := var_output||' SNDD05="'||sms_to_xml(rcd_retrieve.pro_snd_day05)||'"';
         var_output := var_output||' SNDD06="'||sms_to_xml(rcd_retrieve.pro_snd_day06)||'"';
         var_output := var_output||' SNDD07="'||sms_to_xml(rcd_retrieve.pro_snd_day07)||'"/>';
         pipe row(sms_xml_object(var_output));
      elsif var_action = '*CPYPRF' then
         var_output := '<PROFILE PRFCDE=""';
         var_output := var_output||' PRFNAM="'||sms_to_xml(rcd_retrieve.pro_prf_name)||'"';
         var_output := var_output||' PRFSTS="'||sms_to_xml(rcd_retrieve.pro_status)||'"';
         var_output := var_output||' QRYCDE="'||sms_to_xml(rcd_retrieve.pro_qry_code)||'"';
         var_output := var_output||' SNDD01="'||sms_to_xml(rcd_retrieve.pro_snd_day01)||'"';
         var_output := var_output||' SNDD02="'||sms_to_xml(rcd_retrieve.pro_snd_day02)||'"';
         var_output := var_output||' SNDD03="'||sms_to_xml(rcd_retrieve.pro_snd_day03)||'"';
         var_output := var_output||' SNDD04="'||sms_to_xml(rcd_retrieve.pro_snd_day04)||'"';
         var_output := var_output||' SNDD05="'||sms_to_xml(rcd_retrieve.pro_snd_day05)||'"';
         var_output := var_output||' SNDD06="'||sms_to_xml(rcd_retrieve.pro_snd_day06)||'"';
         var_output := var_output||' SNDD07="'||sms_to_xml(rcd_retrieve.pro_snd_day07)||'"/>';
         pipe row(sms_xml_object(var_output));
      elsif var_action = '*CRTPRF' then
         var_output := '<PROFILE PRFCDE=""';
         var_output := var_output||' PRFNAM=""';
         var_output := var_output||' PRFSTS="1"';
         var_output := var_output||' QRYCDE=""';
         var_output := var_output||' SNDD01="0"';
         var_output := var_output||' SNDD02="0"';
         var_output := var_output||' SNDD03="0"';
         var_output := var_output||' SNDD04="0"';
         var_output := var_output||' SNDD05="0"';
         var_output := var_output||' SNDD06="0"';
         var_output := var_output||' SNDD07="0"/>';
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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_PRF_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      rcd_sms_profile sms_profile%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_profile t01
          where t01.pro_prf_code = rcd_sms_profile.pro_prf_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_query is
         select t01.*
           from sms_query t01
          where t01.que_qry_code = rcd_sms_profile.pro_qry_code;
      rcd_query csr_query%rowtype;

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
      if var_action != '*UPDPRF' and var_action != '*CRTPRF' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_sms_profile.pro_prf_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@PRFCDE'));
      rcd_sms_profile.pro_prf_name := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@PRFNAM'));
      rcd_sms_profile.pro_status := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@PRFSTS'));
      rcd_sms_profile.pro_upd_user := upper(par_user);
      rcd_sms_profile.pro_upd_date := sysdate;
      rcd_sms_profile.pro_qry_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYCDE'));
      rcd_sms_profile.pro_snd_day01 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@SNDD01'));
      rcd_sms_profile.pro_snd_day02 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@SNDD02'));
      rcd_sms_profile.pro_snd_day03 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@SNDD03'));
      rcd_sms_profile.pro_snd_day04 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@SNDD04'));
      rcd_sms_profile.pro_snd_day05 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@SNDD05'));
      rcd_sms_profile.pro_snd_day06 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@SNDD06'));
      rcd_sms_profile.pro_snd_day07 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@SNDD07'));
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_sms_profile.pro_prf_code is null then
         sms_gen_function.add_mesg_data('Profile code must be supplied');
      end if;
      if rcd_sms_profile.pro_prf_name is null then
         sms_gen_function.add_mesg_data('Profile name must be supplied');
      end if;
      if rcd_sms_profile.pro_status is null or (rcd_sms_profile.pro_status != '0' and rcd_sms_profile.pro_status != '1') then
         sms_gen_function.add_mesg_data('Profile status must be (0)inactive or (1)active');
      end if;
      if rcd_sms_profile.pro_upd_user is null then
         sms_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if rcd_sms_profile.pro_qry_code is null then
         sms_gen_function.add_mesg_data('Query code must be supplied');
      end if;
      if rcd_sms_profile.pro_snd_day01 is null or (rcd_sms_profile.pro_snd_day01 != '0' and rcd_sms_profile.pro_snd_day01 != '1') then
         sms_gen_function.add_mesg_data('Profile receive on sunday must be (0)no or (1)yes');
      end if;
      if rcd_sms_profile.pro_snd_day02 is null or (rcd_sms_profile.pro_snd_day02 != '0' and rcd_sms_profile.pro_snd_day02 != '1') then
         sms_gen_function.add_mesg_data('Profile receive on monday must be (0)no or (1)yes');
      end if;
      if rcd_sms_profile.pro_snd_day03 is null or (rcd_sms_profile.pro_snd_day03 != '0' and rcd_sms_profile.pro_snd_day03 != '1') then
         sms_gen_function.add_mesg_data('Profile receive on tuesday must be (0)no or (1)yes');
      end if;
      if rcd_sms_profile.pro_snd_day04 is null or (rcd_sms_profile.pro_snd_day04 != '0' and rcd_sms_profile.pro_snd_day04 != '1') then
         sms_gen_function.add_mesg_data('Profile receive on wednesday must be (0)no or (1)yes');
      end if;
      if rcd_sms_profile.pro_snd_day05 is null or (rcd_sms_profile.pro_snd_day05 != '0' and rcd_sms_profile.pro_snd_day05 != '1') then
         sms_gen_function.add_mesg_data('Profile receive on thursday must be (0)no or (1)yes');
      end if;
      if rcd_sms_profile.pro_snd_day06 is null or (rcd_sms_profile.pro_snd_day06 != '0' and rcd_sms_profile.pro_snd_day06 != '1') then
         sms_gen_function.add_mesg_data('Profile receive on friday must be (0)no or (1)yes');
      end if;
      if rcd_sms_profile.pro_snd_day07 is null or (rcd_sms_profile.pro_snd_day07 != '0' and rcd_sms_profile.pro_snd_day07 != '1') then
         sms_gen_function.add_mesg_data('Profile receive on saturday must be (0)no or (1)yes');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the relationships
      /*-*/
      open csr_query;
      fetch csr_query into rcd_query;
      if csr_query%notfound then
         sms_gen_function.add_mesg_data('Query code ('||rcd_sms_profile.pro_qry_code||') does not exist');
      end if;
      close csr_query;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the profile definition
      /*-*/
      if var_action = '*UPDPRF' then
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
               sms_gen_function.add_mesg_data('Profile code ('||rcd_sms_profile.pro_prf_code||') is currently locked');
         end;
         if var_found = false then
            sms_gen_function.add_mesg_data('Profile code ('||rcd_sms_profile.pro_prf_code||') does not exist');
         end if;
         if sms_gen_function.get_mesg_count = 0 then
            update sms_profile
               set pro_prf_name = rcd_sms_profile.pro_prf_name,
                   pro_status = rcd_sms_profile.pro_status,
                   pro_upd_user = rcd_sms_profile.pro_upd_user,
                   pro_upd_date = rcd_sms_profile.pro_upd_date,
                   pro_qry_code = rcd_sms_profile.pro_qry_code,
                   pro_snd_day01 = rcd_sms_profile.pro_snd_day01,
                   pro_snd_day02 = rcd_sms_profile.pro_snd_day02,
                   pro_snd_day03 = rcd_sms_profile.pro_snd_day03,
                   pro_snd_day04 = rcd_sms_profile.pro_snd_day04,
                   pro_snd_day05 = rcd_sms_profile.pro_snd_day05,
                   pro_snd_day06 = rcd_sms_profile.pro_snd_day06,
                   pro_snd_day07 = rcd_sms_profile.pro_snd_day07
             where pro_prf_code = rcd_sms_profile.pro_prf_code;
         end if;
      elsif var_action = '*CRTPRF' then
         var_confirm := 'created';
         begin
            insert into sms_profile values rcd_sms_profile;
         exception
            when dup_val_on_index then
               sms_gen_function.add_mesg_data('Profile code ('||rcd_sms_profile.pro_prf_code||') already exists - unable to create');
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
      sms_gen_function.set_cfrm_data('Profile ('||to_char(rcd_sms_profile.pro_prf_code)||') successfully '||var_confirm);

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_PRF_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

end sms_prf_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym sms_prf_function for sms_app.sms_prf_function;
grant execute on sms_app.sms_prf_function to public;

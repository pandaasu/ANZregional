/******************/
/* Package Header */
/******************/
create or replace package sms_app.sms_rcp_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : sms_rcp_function
    Owner   : sms_app

    Description
    -----------
    SMS Reporting System - Recipient Function

    This package contain the recipient functions and procedures.

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

end sms_rcp_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body sms_app.sms_rcp_function as

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
           from (select t01.rec_rcp_code,
                        t01.rec_rcp_name,
                        decode(t01.rec_status,'0','Inactive','1','Active','*UNKNOWN') as rec_status
                   from sms_recipient t01
                  where (var_str_code is null or t01.rec_rcp_code >= var_str_code)
                  order by t01.rec_rcp_code asc) t01
          where rownum <= var_pag_size + 1;

      cursor csr_next is
         select t01.*
           from (select t01.rec_rcp_code,
                        t01.rec_rcp_name,
                        decode(t01.rec_status,'0','Inactive','1','Active','*UNKNOWN') as rec_status
                   from sms_recipient t01
                  where (var_end_code is null or t01.rec_rcp_code > var_end_code)
                  order by t01.rec_rcp_code asc) t01
          where rownum <= var_pag_size + 1;

      cursor csr_prev is
         select t01.*
           from (select t01.rec_rcp_code,
                        t01.rec_rcp_name,
                        decode(t01.rec_status,'0','Inactive','1','Active','*UNKNOWN') as rec_status
                   from sms_recipient t01
                  where (var_str_code is null or t01.rec_rcp_code < var_str_code)
                  order by t01.rec_rcp_code desc) t01
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
      if var_action != '*SELRCP' and var_action != '*PRVRCP' and var_action != '*NXTRCP' then
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
      /* Retrieve the recipient list and pipe the results
      /*-*/
      var_pag_size := 20;
      var_pag_more := false;
      if var_action = '*SELRCP' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW RCPCDE="'||to_char(tbl_list(idx).rec_rcp_code)||'" RCPNAM="'||sms_to_xml(tbl_list(idx).rec_rcp_name)||'" RCPSTS="'||sms_to_xml(tbl_list(idx).rec_status)||'"/>'));
         end loop;
         if tbl_list.count > var_pag_size then
            var_pag_more := true;
         end if;
      elsif var_action = '*NXTRCP' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         for idx in 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW RCPCDE="'||to_char(tbl_list(idx).rec_rcp_code)||'" RCPNAM="'||sms_to_xml(tbl_list(idx).rec_rcp_name)||'" RCPSTS="'||sms_to_xml(tbl_list(idx).rec_status)||'"/>'));
         end loop;
         if tbl_list.count > var_pag_size then
            var_pag_more := true;
         end if;
      elsif var_action = '*PRVRCP' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         for idx in reverse 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW RCPCDE="'||to_char(tbl_list(idx).rec_rcp_code)||'" RCPNAM="'||sms_to_xml(tbl_list(idx).rec_rcp_name)||'" RCPSTS="'||sms_to_xml(tbl_list(idx).rec_status)||'"/>'));
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
      if var_action = '*SELRCP' then
         var_str_list := '1';
         var_end_list := '1';
         if var_pag_more = true then
            var_end_list := '0';
         end if;
      elsif var_action = '*NXTRCP' then
         var_str_list := '0';
         var_end_list := '1';
         if var_pag_more = true then
            var_end_list := '0';
         end if;
      elsif var_action = '*PRVRCP' then
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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_RCP_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_rcp_code varchar2(64);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_recipient t01
          where t01.rec_rcp_code = var_rcp_code;
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
      var_rcp_code := xslProcessor.valueOf(obj_sms_request,'@RCPCDE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDRCP' and var_action != '*CRTRCP' and var_action != '*CPYRCP' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing recipient when required
      /*-*/
      if var_action = '*UPDRCP' or var_action = '*CPYRCP' then
         var_found := false;
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
         if var_found = false then
            sms_gen_function.add_mesg_data('Recipient ('||var_rcp_code||') does not exist');
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
      /* Pipe the filter XML
      /*-*/
      if var_action = '*UPDRCP' then
         var_output := '<RECIPIENT RCPCDE="'||sms_to_xml(rcd_retrieve.rec_rcp_code)||'"';
         var_output := var_output||' RCPNAM="'||sms_to_xml(rcd_retrieve.rec_rcp_name)||'"';
         var_output := var_output||' RCPMOB="'||sms_to_xml(rcd_retrieve.rec_rcp_mobile)||'"';
         var_output := var_output||' RCPEMA="'||sms_to_xml(rcd_retrieve.rec_rcp_email)||'"';
         var_output := var_output||' RCPSTS="'||sms_to_xml(rcd_retrieve.rec_status)||'"/>';
         pipe row(sms_xml_object(var_output));
      elsif var_action = '*CPYRCP' then
         var_output := '<RECIPIENT RCPCDE=""';
         var_output := var_output||' RCPNAM="'||sms_to_xml(rcd_retrieve.rec_rcp_name)||'"';
         var_output := var_output||' RCPMOB="'||sms_to_xml(rcd_retrieve.rec_rcp_mobile)||'"';
         var_output := var_output||' RCPEMA="'||sms_to_xml(rcd_retrieve.rec_rcp_email)||'"';
         var_output := var_output||' RCPSTS="'||sms_to_xml(rcd_retrieve.rec_status)||'"/>';
         pipe row(sms_xml_object(var_output));
      elsif var_action = '*CRTRCP' then
         var_output := '<RECIPIENT RCPCDE=""';
         var_output := var_output||' RCPNAM=""';
         var_output := var_output||' RCPMOB=""';
         var_output := var_output||' RCPEMA=""';
         var_output := var_output||' RCPSTS="1"/>';
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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_RCP_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      rcd_sms_recipient sms_recipient%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_recipient t01
          where t01.rec_rcp_code = rcd_sms_recipient.rec_rcp_code
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
      if var_action != '*UPDRCP' and var_action != '*CRTRCP' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_sms_recipient.rec_rcp_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@RCPCDE'));
      rcd_sms_recipient.rec_rcp_name := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@RCPNAM'));
      rcd_sms_recipient.rec_rcp_mobile := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@RCPMOB'));
      rcd_sms_recipient.rec_rcp_email := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@RCPEMA'));
      rcd_sms_recipient.rec_status := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@RCPSTS'));
      rcd_sms_recipient.rec_upd_user := upper(par_user);
      rcd_sms_recipient.rec_upd_date := sysdate;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_sms_recipient.rec_rcp_code is null then
         sms_gen_function.add_mesg_data('Recipient code must be supplied');
      end if;
      if rcd_sms_recipient.rec_rcp_name is null then
         sms_gen_function.add_mesg_data('Recipient name must be supplied');
      end if;
      if rcd_sms_recipient.rec_rcp_mobile is null then
         sms_gen_function.add_mesg_data('Recipient mobile must be supplied');
      end if;
      if rcd_sms_recipient.rec_rcp_email is null then
         sms_gen_function.add_mesg_data('Recipient email must be supplied');
      end if;
      if rcd_sms_recipient.rec_status is null or (rcd_sms_recipient.rec_status != '0' and rcd_sms_recipient.rec_status != '1') then
         sms_gen_function.add_mesg_data('Recipient status must be (0)inactive or (1)active');
      end if;
      if rcd_sms_recipient.rec_upd_user is null then
         sms_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the recipient definition
      /*-*/
      if var_action = '*UPDRCP' then
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
               sms_gen_function.add_mesg_data('Recipient code ('||rcd_sms_recipient.rec_rcp_code||') is currently locked');
         end;
         if var_found = false then
            sms_gen_function.add_mesg_data('Recipient code ('||rcd_sms_recipient.rec_rcp_code||') does not exist');
         end if;
         if sms_gen_function.get_mesg_count = 0 then
            update sms_recipient
               set rec_rcp_name = rcd_sms_recipient.rec_rcp_name,
                   rec_rcp_mobile = rcd_sms_recipient.rec_rcp_mobile,
                   rec_rcp_email = rcd_sms_recipient.rec_rcp_email,
                   rec_status = rcd_sms_recipient.rec_status,
                   rec_upd_user = rcd_sms_recipient.rec_upd_user,
                   rec_upd_date = rcd_sms_recipient.rec_upd_date
             where rec_rcp_code = rcd_sms_recipient.rec_rcp_code;
         end if;
      elsif var_action = '*CRTRCP' then
         var_confirm := 'created';
         begin
            insert into sms_recipient values rcd_sms_recipient;
         exception
            when dup_val_on_index then
               sms_gen_function.add_mesg_data('Recipient code ('||rcd_sms_recipient.rec_rcp_code||') already exists - unable to create');
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
      sms_gen_function.set_cfrm_data('Recipient ('||to_char(rcd_sms_recipient.rec_rcp_code)||') successfully '||var_confirm);

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_RCP_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

end sms_rcp_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym sms_rcp_function for sms_app.sms_rcp_function;
grant execute on sms_app.sms_rcp_function to public;

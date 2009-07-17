/******************/
/* Package Header */
/******************/
create or replace package sms_app.sms_msg_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : sms_msg_function
    Owner   : sms_app

    Description
    -----------
    SMS Reporting System - Message Function

    This package contain the message functions and procedures.

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

end sms_msg_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body sms_app.sms_msg_function as

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

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_slct is
         select t01.*
           from (select t01.mes_msg_code,
                        t01.mes_msg_name,
                        decode(t01.mes_status,'0','Inactive','1','Active','*UNKNOWN') as mes_status
                   from sms_message t01
                  where (var_str_code is null or t01.mes_msg_code >= var_str_code)
                  order by t01.mes_msg_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.mes_msg_code,
                        t01.mes_msg_name,
                        decode(t01.mes_status,'0','Inactive','1','Active','*UNKNOWN') as mes_status
                   from sms_message t01
                  where (var_action = '*NXTMSG' and (var_end_code is null or t01.mes_msg_code > var_end_code)) or
                        (var_action = '*PRVMSG')
                  order by t01.mes_msg_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.mes_msg_code,
                        t01.mes_msg_name,
                        decode(t01.mes_status,'0','Inactive','1','Active','*UNKNOWN') as mes_status
                   from sms_message t01
                  where (var_action = '*PRVMSG' and (var_str_code is null or t01.mes_msg_code < var_str_code)) or
                        (var_action = '*NXTMSG')
                  order by t01.mes_msg_code desc) t01
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
      var_str_code := xslProcessor.valueOf(obj_sms_request,'@STRCDE');
      var_end_code := xslProcessor.valueOf(obj_sms_request,'@ENDCDE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SELMSG' and var_action != '*PRVMSG' and var_action != '*NXTMSG' then
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
      /* Retrieve the message list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELMSG' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW MSGCDE="'||to_char(tbl_list(idx).mes_msg_code)||'" MSGNAM="'||sms_to_xml(tbl_list(idx).mes_msg_name)||'" MSGSTS="'||sms_to_xml(tbl_list(idx).mes_status)||'"/>'));
         end loop;
      elsif var_action = '*NXTMSG' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(sms_xml_object('<LSTROW MSGCDE="'||to_char(tbl_list(idx).mes_msg_code)||'" MSGNAM="'||sms_to_xml(tbl_list(idx).mes_msg_name)||'" MSGSTS="'||sms_to_xml(tbl_list(idx).mes_status)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(sms_xml_object('<LSTROW MSGCDE="'||to_char(tbl_list(idx).mes_msg_code)||'" MSGNAM="'||sms_to_xml(tbl_list(idx).mes_msg_name)||'" MSGSTS="'||sms_to_xml(tbl_list(idx).mes_status)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVMSG' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(sms_xml_object('<LSTROW MSGCDE="'||to_char(tbl_list(idx).mes_msg_code)||'" MSGNAM="'||sms_to_xml(tbl_list(idx).mes_msg_name)||'" MSGSTS="'||sms_to_xml(tbl_list(idx).mes_status)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(sms_xml_object('<LSTROW MSGCDE="'||to_char(tbl_list(idx).mes_msg_code)||'" MSGNAM="'||sms_to_xml(tbl_list(idx).mes_msg_name)||'" MSGSTS="'||sms_to_xml(tbl_list(idx).mes_status)||'"/>'));
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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_MSG_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_msg_code varchar2(64);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_message t01
          where t01.mes_msg_code = var_msg_code;
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
      var_msg_code := xslProcessor.valueOf(obj_sms_request,'@MSGCDE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDMSG' and var_action != '*CRTMSG' and var_action != '*CPYMSG' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing mesage when required
      /*-*/
      if var_action = '*UPDMSG' or var_action = '*CPYMSG' then
         var_found := false;
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
         if var_found = false then
            sms_gen_function.add_mesg_data('Message ('||var_msg_code||') does not exist');
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
      /* Pipe the message XML
      /*-*/
      if var_action = '*UPDMSG' then
         var_output := '<MESSAGE MSGCDE="'||sms_to_xml(rcd_retrieve.mes_msg_code)||'"';
         var_output := var_output||' MSGNAM="'||sms_to_xml(rcd_retrieve.mes_msg_name)||'"';
         var_output := var_output||' MSGSTS="'||sms_to_xml(rcd_retrieve.mes_status)||'"';
         var_output := var_output||' QRYCDE="'||sms_to_xml(rcd_retrieve.mes_qry_code)||'"/>';
         pipe row(sms_xml_object(var_output));
      elsif var_action = '*CPYMSG' then
         var_output := '<MESSAGE MSGCDE=""';
         var_output := var_output||' MSGNAM="'||sms_to_xml(rcd_retrieve.mes_msg_name)||'"';
         var_output := var_output||' MSGSTS="'||sms_to_xml(rcd_retrieve.mes_status)||'"';
         var_output := var_output||' QRYCDE="'||sms_to_xml(rcd_retrieve.mes_qry_code)||'"/>';
         pipe row(sms_xml_object(var_output));
      elsif var_action = '*CRTMSG' then
         var_output := '<MESSAGE MSGCDE=""';
         var_output := var_output||' MSGNAM=""';
         var_output := var_output||' MSGSTS="1"';
         var_output := var_output||' QRYCDE=""/>';
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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_MSG_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      rcd_sms_message sms_message%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_message t01
          where t01.mes_msg_code = rcd_sms_message.mes_msg_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_query is
         select t01.*
           from sms_query t01
          where t01.que_qry_code = rcd_sms_message.mes_qry_code;
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
      if var_action != '*UPDMSG' and var_action != '*CRTMSG' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_sms_message.mes_msg_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@MSGCDE'));
      rcd_sms_message.mes_msg_name := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@MSGNAM'));
      rcd_sms_message.mes_status := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@MSGSTS'));
      rcd_sms_message.mes_upd_user := upper(par_user);
      rcd_sms_message.mes_upd_date := sysdate;
      rcd_sms_message.mes_qry_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYCDE'));
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_sms_message.mes_msg_code is null then
         sms_gen_function.add_mesg_data('Message code must be supplied');
      end if;
      if rcd_sms_message.mes_msg_name is null then
         sms_gen_function.add_mesg_data('Message name must be supplied');
      end if;
      if rcd_sms_message.mes_status is null or (rcd_sms_message.mes_status != '0' and rcd_sms_message.mes_status != '1') then
         sms_gen_function.add_mesg_data('Message status must be (0)inactive or (1)active');
      end if;
      if rcd_sms_message.mes_upd_user is null then
         sms_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if rcd_sms_message.mes_qry_code is null then
         sms_gen_function.add_mesg_data('Query code must be supplied');
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
         sms_gen_function.add_mesg_data('Query code ('||rcd_sms_message.mes_qry_code||') does not exist');
      end if;
      close csr_query;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the message definition
      /*-*/
      if var_action = '*UPDMSG' then
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
               sms_gen_function.add_mesg_data('Message code ('||rcd_sms_message.mes_msg_code||') is currently locked');
         end;
         if var_found = false then
            sms_gen_function.add_mesg_data('Message code ('||rcd_sms_message.mes_msg_code||') does not exist');
         end if;
         if sms_gen_function.get_mesg_count = 0 then
            update sms_message
               set mes_msg_name = rcd_sms_message.mes_msg_name,
                   mes_status = rcd_sms_message.mes_status,
                   mes_upd_user = rcd_sms_message.mes_upd_user,
                   mes_upd_date = rcd_sms_message.mes_upd_date,
                   mes_qry_code = rcd_sms_message.mes_qry_code
             where mes_msg_code = rcd_sms_message.mes_msg_code;
         end if;
      elsif var_action = '*CRTMSG' then
         var_confirm := 'created';
         begin
            insert into sms_message values rcd_sms_message;
         exception
            when dup_val_on_index then
               sms_gen_function.add_mesg_data('Message code ('||rcd_sms_message.mes_msg_code||') already exists - unable to create');
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
      sms_gen_function.set_cfrm_data('Message ('||to_char(rcd_sms_message.mes_msg_code)||') successfully '||var_confirm);

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_MSG_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

end sms_msg_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym sms_msg_function for sms_app.sms_msg_function;
grant execute on sms_app.sms_msg_function to public;

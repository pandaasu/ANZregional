/******************/
/* Package Header */
/******************/
create or replace package sms_app.sms_flt_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : sms_flt_function
    Owner   : sms_app

    Description
    -----------
    SMS Reporting System - Filter Function

    This package contain the filter functions and procedures.

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

end sms_flt_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body sms_app.sms_flt_function as

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
           from (select t01.fil_flt_code,
                        t01.fil_flt_name,
                        decode(t01.fil_status,'0','Inactive','1','Active','*UNKNOWN') as fil_status
                   from sms_filter t01
                  where (var_str_code is null or t01.fil_flt_code >= var_str_code)
                  order by t01.fil_flt_code asc) t01
          where rownum <= var_pag_size + 1;

      cursor csr_next is
         select t01.*
           from (select t01.fil_flt_code,
                        t01.fil_flt_name,
                        decode(t01.fil_status,'0','Inactive','1','Active','*UNKNOWN') as fil_status
                   from sms_filter t01
                  where (var_end_code is null or t01.fil_flt_code > var_end_code)
                  order by t01.fil_flt_code asc) t01
          where rownum <= var_pag_size + 1;

      cursor csr_prev is
         select t01.*
           from (select t01.fil_flt_code,
                        t01.fil_flt_name,
                        decode(t01.fil_status,'0','Inactive','1','Active','*UNKNOWN') as fil_status
                   from sms_filter t01
                  where (var_str_code is null or t01.fil_flt_code < var_str_code)
                  order by t01.fil_flt_code desc) t01
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
      if var_action != '*SELFLT' and var_action != '*PRVFLT' and var_action != '*NXTFLT' then
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
      /* Retrieve the filter list and pipe the results
      /*-*/
      var_pag_size := 20;
      var_pag_more := false;
      if var_action = '*SELFLT' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW FLTCDE="'||to_char(tbl_list(idx).fil_flt_code)||'" FLTNAM="'||sms_to_xml(tbl_list(idx).fil_flt_name)||'" FLTSTS="'||sms_to_xml(tbl_list(idx).fil_status)||'"/>'));
         end loop;
         if tbl_list.count > var_pag_size then
            var_pag_more := true;
         end if;
      elsif var_action = '*NXTFLT' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         for idx in 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW FLTCDE="'||to_char(tbl_list(idx).fil_flt_code)||'" FLTNAM="'||sms_to_xml(tbl_list(idx).fil_flt_name)||'" FLTSTS="'||sms_to_xml(tbl_list(idx).fil_status)||'"/>'));
         end loop;
         if tbl_list.count > var_pag_size then
            var_pag_more := true;
         end if;
      elsif var_action = '*PRVFLT' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         for idx in reverse 1..tbl_list.count loop
            pipe row(sms_xml_object('<LSTROW FLTCDE="'||to_char(tbl_list(idx).fil_flt_code)||'" FLTNAM="'||sms_to_xml(tbl_list(idx).fil_flt_name)||'" FLTSTS="'||sms_to_xml(tbl_list(idx).fil_status)||'"/>'));
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
      if var_action = '*SELFLT' then
         var_str_list := '1';
         var_end_list := '1';
         if var_pag_more = true then
            var_end_list := '0';
         end if;
      elsif var_action = '*NXTFLT' then
         var_str_list := '0';
         var_end_list := '1';
         if var_pag_more = true then
            var_end_list := '0';
         end if;
      elsif var_action = '*PRVFLT' then
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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_FLT_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_flt_code varchar2(64);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_filter t01
          where t01.fil_flt_code = var_flt_code;
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
      var_flt_code := xslProcessor.valueOf(obj_sms_request,'@FLTCDE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDFLT' and var_action != '*CRTFLT' and var_action != '*CPYFLT' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing filter when required
      /*-*/
      if var_action = '*UPDFLT' or var_action = '*CPYFLT' then
         var_found := false;
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
         if var_found = false then
            sms_gen_function.add_mesg_data('Filter ('||var_flt_code||') does not exist');
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
      if var_action = '*UPDFLT' then
         var_output := '<FILTER FLTCDE="'||sms_to_xml(rcd_retrieve.fil_flt_code)||'"';
         var_output := var_output||' FLTNAM="'||sms_to_xml(rcd_retrieve.fil_flt_name)||'"';
         var_output := var_output||' FLTSTS="'||sms_to_xml(rcd_retrieve.fil_status)||'"';
         var_output := var_output||' QRYCDE="'||sms_to_xml(rcd_retrieve.fil_qry_code)||'"';
         var_output := var_output||' DIMV01="'||sms_to_xml(rcd_retrieve.fil_dim_val01)||'"';
         var_output := var_output||' DIMV02="'||sms_to_xml(rcd_retrieve.fil_dim_val02)||'"';
         var_output := var_output||' DIMV03="'||sms_to_xml(rcd_retrieve.fil_dim_val03)||'"';
         var_output := var_output||' DIMV04="'||sms_to_xml(rcd_retrieve.fil_dim_val04)||'"';
         var_output := var_output||' DIMV05="'||sms_to_xml(rcd_retrieve.fil_dim_val05)||'"';
         var_output := var_output||' DIMV06="'||sms_to_xml(rcd_retrieve.fil_dim_val06)||'"';
         var_output := var_output||' DIMV07="'||sms_to_xml(rcd_retrieve.fil_dim_val07)||'"';
         var_output := var_output||' DIMV08="'||sms_to_xml(rcd_retrieve.fil_dim_val08)||'"';
         var_output := var_output||' DIMV09="'||sms_to_xml(rcd_retrieve.fil_dim_val09)||'"/>';
         pipe row(sms_xml_object(var_output));
      elsif var_action = '*CPYFLT' then
         var_output := '<FILTER FLTCDE=""';
         var_output := var_output||' FLTNAM="'||sms_to_xml(rcd_retrieve.fil_flt_name)||'"';
         var_output := var_output||' FLTSTS="'||sms_to_xml(rcd_retrieve.fil_status)||'"';
         var_output := var_output||' QRYCDE="'||sms_to_xml(rcd_retrieve.fil_qry_code)||'"';
         var_output := var_output||' DIMV01="'||sms_to_xml(rcd_retrieve.fil_dim_val01)||'"';
         var_output := var_output||' DIMV02="'||sms_to_xml(rcd_retrieve.fil_dim_val02)||'"';
         var_output := var_output||' DIMV03="'||sms_to_xml(rcd_retrieve.fil_dim_val03)||'"';
         var_output := var_output||' DIMV04="'||sms_to_xml(rcd_retrieve.fil_dim_val04)||'"';
         var_output := var_output||' DIMV05="'||sms_to_xml(rcd_retrieve.fil_dim_val05)||'"';
         var_output := var_output||' DIMV06="'||sms_to_xml(rcd_retrieve.fil_dim_val06)||'"';
         var_output := var_output||' DIMV07="'||sms_to_xml(rcd_retrieve.fil_dim_val07)||'"';
         var_output := var_output||' DIMV08="'||sms_to_xml(rcd_retrieve.fil_dim_val08)||'"';
         var_output := var_output||' DIMV09="'||sms_to_xml(rcd_retrieve.fil_dim_val09)||'"/>';
         pipe row(sms_xml_object(var_output));
      elsif var_action = '*CRTFLT' then
         var_output := '<FILTER FLTCDE=""';
         var_output := var_output||' FLTNAM=""';
         var_output := var_output||' FLTSTS="1"';
         var_output := var_output||' QRYCDE=""';
         var_output := var_output||' DIMV01=""';
         var_output := var_output||' DIMV02=""';
         var_output := var_output||' DIMV03=""';
         var_output := var_output||' DIMV04=""';
         var_output := var_output||' DIMV05=""';
         var_output := var_output||' DIMV06=""';
         var_output := var_output||' DIMV07=""';
         var_output := var_output||' DIMV08=""';
         var_output := var_output||' DIMV09=""/>';
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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_FLT_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      rcd_sms_filter sms_filter%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_filter t01
          where t01.fil_flt_code = rcd_sms_filter.fil_flt_code
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
      if var_action != '*UPDFLT' and var_action != '*CRTFLT' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_sms_filter.fil_flt_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@FLTCDE'));
      rcd_sms_filter.fil_flt_name := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@FLTNAM'));
      rcd_sms_filter.fil_status := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@FLTSTS'));
      rcd_sms_filter.fil_upd_user := upper(par_user);
      rcd_sms_filter.fil_upd_date := sysdate;
      rcd_sms_filter.fil_qry_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYCDE'));
      rcd_sms_filter.fil_dim_val01 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMV01'));
      rcd_sms_filter.fil_dim_val02 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMV02'));
      rcd_sms_filter.fil_dim_val03 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMV03'));
      rcd_sms_filter.fil_dim_val04 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMV04'));
      rcd_sms_filter.fil_dim_val05 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMV05'));
      rcd_sms_filter.fil_dim_val06 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMV06'));
      rcd_sms_filter.fil_dim_val07 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMV07'));
      rcd_sms_filter.fil_dim_val08 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMV08'));
      rcd_sms_filter.fil_dim_val09 := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@DIMV09'));
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_sms_filter.fil_flt_code is null then
         sms_gen_function.add_mesg_data('Filter code must be supplied');
      end if;
      if rcd_sms_filter.fil_flt_name is null then
         sms_gen_function.add_mesg_data('Filter name must be supplied');
      end if;
      if rcd_sms_filter.fil_status is null or (rcd_sms_filter.fil_status != '0' and rcd_sms_filter.fil_status != '1') then
         sms_gen_function.add_mesg_data('Filter status must be (0)inactive or (1)active');
      end if;
      if rcd_sms_filter.fil_upd_user is null then
         sms_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if rcd_sms_filter.fil_qry_code is null then
         sms_gen_function.add_mesg_data('Query code must be supplied');
      end if;
    --  if nvl(rcd_sms_filter.fil_dim_depth,0) >= 1 and rcd_sms_filter.fil_dim_val01 is null then
    --     sms_gen_function.add_mesg_data('Filter dimension value 1 name must be supplied');
    --  end if;
    --  if nvl(rcd_sms_filter.fil_dim_depth,0) < 1 and not(rcd_sms_filter.fil_dim_val01 is null) then
    --     sms_gen_function.add_mesg_data('Filter dimension value 1 name must be empty');
    --  end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the filter definition
      /*-*/
      if var_action = '*UPDFLT' then
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
               sms_gen_function.add_mesg_data('Filter code ('||rcd_sms_filter.fil_flt_code||') is currently locked');
         end;
         if var_found = false then
            sms_gen_function.add_mesg_data('Filter code ('||rcd_sms_filter.fil_flt_code||') does not exist');
         end if;
         if sms_gen_function.get_mesg_count = 0 then
            update sms_filter
               set fil_flt_name = rcd_sms_filter.fil_flt_name,
                   fil_status = rcd_sms_filter.fil_status,
                   fil_upd_user = rcd_sms_filter.fil_upd_user,
                   fil_upd_date = rcd_sms_filter.fil_upd_date,
                   fil_qry_code = rcd_sms_filter.fil_qry_code,
                   fil_dim_val01 = rcd_sms_filter.fil_dim_val01,
                   fil_dim_val02 = rcd_sms_filter.fil_dim_val02,
                   fil_dim_val03 = rcd_sms_filter.fil_dim_val03,
                   fil_dim_val04 = rcd_sms_filter.fil_dim_val04,
                   fil_dim_val05 = rcd_sms_filter.fil_dim_val05,
                   fil_dim_val06 = rcd_sms_filter.fil_dim_val06,
                   fil_dim_val07 = rcd_sms_filter.fil_dim_val07,
                   fil_dim_val08 = rcd_sms_filter.fil_dim_val08,
                   fil_dim_val09 = rcd_sms_filter.fil_dim_val09
             where fil_flt_code = rcd_sms_filter.fil_flt_code;
         end if;
      elsif var_action = '*CRTFLT' then
         var_confirm := 'created';
         begin
            insert into sms_filter values rcd_sms_filter;
         exception
            when dup_val_on_index then
               sms_gen_function.add_mesg_data('Filter code ('||rcd_sms_filter.fil_flt_code||') already exists - unable to create');
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
      sms_gen_function.set_cfrm_data('Filter ('||to_char(rcd_sms_filter.fil_flt_code)||') successfully '||var_confirm);

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_FLT_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

end sms_flt_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym sms_flt_function for sms_app.sms_flt_function;
grant execute on sms_app.sms_flt_function to public;

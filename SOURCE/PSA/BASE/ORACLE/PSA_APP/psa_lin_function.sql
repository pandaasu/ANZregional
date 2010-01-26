/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_lin_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_lin_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - Line Function

    This package contain the line functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function select_list return psa_xml_type pipelined;
   function retrieve_data return psa_xml_type pipelined;
   procedure update_data(par_user in varchar2);
   procedure delete_data;

end psa_lin_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_lin_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***************************************************/
   /* This procedure performs the select list routine */
   /***************************************************/
   function select_list return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_prd_type varchar2(32);
      var_str_code varchar2(32);
      var_end_code varchar2(32);
      var_output varchar2(2000 char);
      var_pag_size number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_slct is
         select t01.*
           from (select t01.lde_lin_code,
                        t01.lde_lin_name,
                        decode(t01.lde_lin_status,'0','Inactive','1','Active','*UNKNOWN') as lde_lin_status,
                        t01.lde_prd_type
                   from psa_lin_defn t01
                  where (var_str_code is null or t01.lde_lin_code >= var_str_code)
                    and (var_prd_type is null or t01.lde_prd_type = var_prd_type)
                  order by t01.lde_lin_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.lde_lin_code,
                        t01.lde_lin_name,
                        decode(t01.lde_lin_status,'0','Inactive','1','Active','*UNKNOWN') as lde_lin_status,
                        t01.lde_prd_type
                   from psa_lin_defn t01
                  where ((var_action = '*NXTDEF' and (var_end_code is null or t01.lde_lin_code > var_end_code)) or
                         (var_action = '*PRVDEF'))
                    and (var_prd_type is null or t01.lde_prd_type = var_prd_type)
                  order by t01.lde_lin_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.lde_lin_code,
                        t01.lde_lin_name,
                        decode(t01.lde_lin_status,'0','Inactive','1','Active','*UNKNOWN') as lde_lin_status,
                        t01.lde_prd_type
                   from psa_lin_defn t01
                  where ((var_action = '*PRVDEF' and (var_str_code is null or t01.lde_lin_code < var_str_code)) or
                         (var_action = '*NXTDEF'))
                    and (var_prd_type is null or t01.lde_prd_type = var_prd_type)
                  order by t01.lde_lin_code desc) t01
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
      psa_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PSA_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_psa_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_psa_request,'@ACTION'));
      var_prd_type := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      var_str_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@STRCDE')));
      var_end_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@ENDCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SELDEF' and var_action != '*PRVDEF' and var_action != '*NXTDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(psa_xml_object('<?xml version="1.0" encoding="UTF-8"?><PSA_RESPONSE>'));

      /*-*/
      /* Retrieve the line list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELDEF' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(psa_xml_object('<LSTROW LINCDE="'||to_char(tbl_list(idx).lde_lin_code)||'" LINNAM="'||psa_to_xml(tbl_list(idx).lde_lin_name)||'" LINSTS="'||psa_to_xml(tbl_list(idx).lde_lin_status)||'" PTYCDE="'||psa_to_xml(tbl_list(idx).lde_prd_type)||'"/>'));
         end loop;
      elsif var_action = '*NXTDEF' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW LINCDE="'||to_char(tbl_list(idx).lde_lin_code)||'" LINNAM="'||psa_to_xml(tbl_list(idx).lde_lin_name)||'" LINSTS="'||psa_to_xml(tbl_list(idx).lde_lin_status)||'" PTYCDE="'||psa_to_xml(tbl_list(idx).lde_prd_type)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW LINCDE="'||to_char(tbl_list(idx).lde_lin_code)||'" LINNAM="'||psa_to_xml(tbl_list(idx).lde_lin_name)||'" LINSTS="'||psa_to_xml(tbl_list(idx).lde_lin_status)||'" PTYCDE="'||psa_to_xml(tbl_list(idx).lde_prd_type)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVDEF' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW LINCDE="'||to_char(tbl_list(idx).lde_lin_code)||'" LINNAM="'||psa_to_xml(tbl_list(idx).lde_lin_name)||'" LINSTS="'||psa_to_xml(tbl_list(idx).lde_lin_status)||'" PTYCDE="'||psa_to_xml(tbl_list(idx).lde_prd_type)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW LINCDE="'||to_char(tbl_list(idx).lde_lin_code)||'" LINNAM="'||psa_to_xml(tbl_list(idx).lde_lin_name)||'" LINSTS="'||psa_to_xml(tbl_list(idx).lde_lin_status)||'" PTYCDE="'||psa_to_xml(tbl_list(idx).lde_prd_type)||'"/>'));
            end loop;
         end if;
      end if;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(psa_xml_object('</PSA_RESPONSE>'));

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_LIN_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_list;

   /*****************************************************/
   /* This procedure performs the retrieve data routine */
   /*****************************************************/
   function retrieve_data return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_prd_type varchar2(32);
      var_lin_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_prdtype is
         select t01.*
           from psa_prd_type t01
          where t01.pty_prd_type = var_prd_type;
      rcd_prdtype csr_prdtype%rowtype;

      cursor csr_retrieve is
         select t01.*
           from psa_lin_defn t01
          where t01.lde_lin_code = var_lin_code;
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
      psa_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PSA_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_psa_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_psa_request,'@ACTION'));
      var_prd_type := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' and var_action != '*CPYDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the type
      /*-*/
      var_found := false;
      open csr_prdtype;
      fetch csr_prdtype into rcd_prdtype;
      if csr_prdtype%found then
         var_found := true;
      end if;
      close csr_prdtype;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production type ('||var_prd_type||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing line when required
      /*-*/
      if var_action = '*UPDDEF' or var_action = '*CPYDEF' then
         var_found := false;
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
         if var_found = false then
            psa_gen_function.add_mesg_data('Line ('||var_lin_code||') does not exist');
         end if;
         if psa_gen_function.get_mesg_count != 0 then
            return;
         end if;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(psa_xml_object('<?xml version="1.0" encoding="UTF-8"?><PSA_RESPONSE>'));

      /*-*/
      /* Pipe the line XML
      /*-*/
      if var_action = '*UPDDEF' then
         var_output := '<LINDFN LINCDE="'||psa_to_xml(rcd_retrieve.lde_lin_code||' - (Last updated by '||rcd_retrieve.lde_upd_user||' on '||to_char(rcd_retrieve.lde_upd_date,'yyyy/mm/dd')||')')||'"';
         var_output := var_output||' LINNAM="'||psa_to_xml(rcd_retrieve.lde_lin_name)||'"';
         var_output := var_output||' LINWAS="'||to_char(rcd_retrieve.lde_lin_wastage,'fm990.00')||'"';
         var_output := var_output||' LINEVT="'||psa_to_xml(rcd_retrieve.lde_lin_events)||'"';
         var_output := var_output||' LINSTS="'||psa_to_xml(rcd_retrieve.lde_lin_status)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CPYDEF' then
         var_output := '<LINDFN LINCDE=""';
         var_output := var_output||' LINNAM="'||psa_to_xml(rcd_retrieve.lde_lin_name)||'"';
         var_output := var_output||' LINWAS="'||to_char(rcd_retrieve.lde_lin_wastage,'fm990.00')||'"';
         var_output := var_output||' LINEVT="'||psa_to_xml(rcd_retrieve.lde_lin_events)||'"';
         var_output := var_output||' LINSTS="'||psa_to_xml(rcd_retrieve.lde_lin_status)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CRTDEF' then
         var_output := '<LINDFN LINCDE=""';
         var_output := var_output||' LINNAM=""';
         var_output := var_output||' LINWAS="0.00"';
         var_output := var_output||' LINEVT="0"';
         var_output := var_output||' LINSTS="1"/>';
         pipe row(psa_xml_object(var_output));
      end if;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(psa_xml_object('</PSA_RESPONSE>'));

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_LIN_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      rcd_psa_lin_defn psa_lin_defn%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_lin_defn t01
          where t01.lde_lin_code = rcd_psa_lin_defn.lde_lin_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_prdtype is
         select t01.*
           from psa_prd_type t01
          where t01.pty_prd_type = rcd_psa_lin_defn.lde_prd_type;
      rcd_prdtype csr_prdtype%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the message data
      /*-*/
      psa_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PSA_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_psa_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_psa_request,'@ACTION'));
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_psa_lin_defn.lde_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
      rcd_psa_lin_defn.lde_lin_name := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINNAM'));
      rcd_psa_lin_defn.lde_lin_wastage := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@LINWAS'));
      rcd_psa_lin_defn.lde_lin_events := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINEVT'));
      rcd_psa_lin_defn.lde_lin_status := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINSTS'));
      rcd_psa_lin_defn.lde_prd_type := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      rcd_psa_lin_defn.lde_upd_user := upper(par_user);
      rcd_psa_lin_defn.lde_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_psa_lin_defn.lde_lin_code is null then
         psa_gen_function.add_mesg_data('Line code must be supplied');
      end if;
      if rcd_psa_lin_defn.lde_lin_name is null then
         psa_gen_function.add_mesg_data('Line name must be supplied');
      end if;
      if rcd_psa_lin_defn.lde_lin_wastage is null or (rcd_psa_lin_defn.lde_lin_wastage < 1 or rcd_psa_lin_defn.lde_lin_wastage > 100) then
         psa_gen_function.add_mesg_data('Line wastage must be in range 1 to 100');
      end if;
      if rcd_psa_lin_defn.lde_lin_events is null or (rcd_psa_lin_defn.lde_lin_events != '0' and rcd_psa_lin_defn.lde_lin_events != '1') then
         psa_gen_function.add_mesg_data('Line auto generate product change events must be (0)no or (1)yes');
      end if;
      if rcd_psa_lin_defn.lde_lin_status is null or (rcd_psa_lin_defn.lde_lin_status != '0' and rcd_psa_lin_defn.lde_lin_status != '1') then
         psa_gen_function.add_mesg_data('Line status must be (0)inactive or (1)active');
      end if;
      if rcd_psa_lin_defn.lde_upd_user is null then
         psa_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the parent relationships
      /*-*/
      open csr_prdtype;
      fetch csr_prdtype into rcd_prdtype;
      if csr_prdtype%notfound then
         psa_gen_function.add_mesg_data('Production type code ('||rcd_psa_lin_defn.lde_prd_type||') does not exist');
      else
         if rcd_psa_lin_defn.lde_lin_status = '1' and rcd_prdtype.pty_prd_status != '1' then
            psa_gen_function.add_mesg_data('Production type code ('||rcd_psa_lin_defn.lde_prd_type||') status must be active for an active line');
         end if;
         if rcd_prdtype.pty_prd_lin_usage != '1' then
            psa_gen_function.add_mesg_data('Production type code ('||rcd_psa_lin_defn.lde_prd_type||') must be flagged for line usage');
         end if;
         if rcd_prdtype.pty_prd_lin_wastage = '1' then
            if rcd_psa_lin_defn.lde_lin_wastage < 0 or rcd_psa_lin_defn.lde_lin_wastage > 100 then
               psa_gen_function.add_mesg_data('Line wastage must be in range 0 to 100');
            end if;
         else
            if rcd_psa_lin_defn.lde_lin_wastage != 0 then
               psa_gen_function.add_mesg_data('Line wastage must be 0');
            end if;
         end if;
      end if;
      close csr_prdtype;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the line definition
      /*-*/
      if var_action = '*UPDDEF' then
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
               psa_gen_function.add_mesg_data('Line code ('||rcd_psa_lin_defn.lde_lin_code||') is currently locked');
         end;
         if var_found = false then
            psa_gen_function.add_mesg_data('Line code ('||rcd_psa_lin_defn.lde_lin_code||') does not exist');
         end if;
         if psa_gen_function.get_mesg_count = 0 then
            update psa_lin_defn
               set lde_lin_name = rcd_psa_lin_defn.lde_lin_name,
                   lde_lin_wastage = rcd_psa_lin_defn.lde_lin_wastage,
                   lde_lin_events = rcd_psa_lin_defn.lde_lin_events,
                   lde_lin_status = rcd_psa_lin_defn.lde_lin_status,
                   lde_upd_user = rcd_psa_lin_defn.lde_upd_user,
                   lde_upd_date = rcd_psa_lin_defn.lde_upd_date
             where lde_lin_code = rcd_psa_lin_defn.lde_lin_code;
         end if;
      elsif var_action = '*CRTDEF' then
         var_confirm := 'created';
         begin
            insert into psa_lin_defn values rcd_psa_lin_defn;
         exception
            when dup_val_on_index then
               psa_gen_function.add_mesg_data('Line code ('||rcd_psa_lin_defn.lde_lin_code||') already exists - unable to create');
         end;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
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
      psa_gen_function.set_cfrm_data('Line ('||to_char(rcd_psa_lin_defn.lde_lin_code)||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_LIN_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

   /***************************************************/
   /* This procedure performs the delete data routine */
   /***************************************************/
   procedure delete_data is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      var_lin_code varchar2(32);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the message data
      /*-*/
      psa_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PSA_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_psa_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_psa_request,'@ACTION'));
      if var_action != '*DLTDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the line definition
      /*-*/
      var_confirm := 'deleted';
      delete from psa_lin_filler where lfi_lin_code = var_lin_code;
      delete from psa_lin_rate where lra_lin_code = var_lin_code;
      delete from psa_lin_config where lco_lin_code = var_lin_code;
      delete from psa_lin_defn where lde_lin_code = var_lin_code;

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
      psa_gen_function.set_cfrm_data('Line ('||var_lin_code||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_LIN_FUNCTION - DELETE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_data;

end psa_lin_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_lin_function for psa_app.psa_lin_function;
grant execute on psa_app.psa_lin_function to public;

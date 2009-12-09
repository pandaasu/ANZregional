/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_rra_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_rra_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - Run Rate Function

    This package contain the run rate functions and procedures.

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

end psa_rra_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_rra_function as

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
      var_str_code varchar2(64);
      var_end_code varchar2(64);
      var_output varchar2(2000 char);
      var_pag_size number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_slct is
         select t01.*
           from (select t01.rra_run_code,
                        t01.rra_run_name,
                        decode(t01.rra_run_status,'0','Inactive','1','Active','*UNKNOWN') as rra_run_status
                   from psa_run_rate t01
                  where (var_str_code is null or t01.rra_run_code >= var_str_code)
                  order by t01.rra_run_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.rra_run_code,
                        t01.rra_run_name,
                        decode(t01.rra_run_status,'0','Inactive','1','Active','*UNKNOWN') as rra_run_status
                   from psa_run_rate t01
                  where (var_action = '*NXTRRA' and (var_end_code is null or t01.rra_run_code > var_end_code)) or
                        (var_action = '*PRVRRA')
                  order by t01.rra_run_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.rra_run_code,
                        t01.rra_run_name,
                        decode(t01.rra_run_status,'0','Inactive','1','Active','*UNKNOWN') as rra_run_status
                   from psa_run_rate t01
                  where (var_action = '*PRVRRA' and (var_str_code is null or t01.rra_run_code < var_str_code)) or
                        (var_action = '*NXTRRA')
                  order by t01.rra_run_code desc) t01
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
      var_str_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@STRCDE'));
      var_end_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@ENDCDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SELRRA' and var_action != '*PRVRRA' and var_action != '*NXTRRA' then
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
      /* Retrieve the run rate list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELRRA' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(psa_xml_object('<LSTROW RRACDE="'||to_char(tbl_list(idx).rra_run_code)||'" RRANAM="'||psa_to_xml(tbl_list(idx).rra_run_name)||'" RRASTS="'||psa_to_xml(tbl_list(idx).rra_run_status)||'"/>'));
         end loop;
      elsif var_action = '*NXTRRA' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW RRACDE="'||to_char(tbl_list(idx).rra_run_code)||'" RRANAM="'||psa_to_xml(tbl_list(idx).rra_run_name)||'" RRASTS="'||psa_to_xml(tbl_list(idx).rra_run_status)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW RRACDE="'||to_char(tbl_list(idx).rra_run_code)||'" RRANAM="'||psa_to_xml(tbl_list(idx).rra_run_name)||'" RRASTS="'||psa_to_xml(tbl_list(idx).rra_run_status)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVRRA' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW RRACDE="'||to_char(tbl_list(idx).rra_run_code)||'" RRANAM="'||psa_to_xml(tbl_list(idx).rra_run_name)||'" RRASTS="'||psa_to_xml(tbl_list(idx).rra_run_status)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW RRACDE="'||to_char(tbl_list(idx).rra_run_code)||'" RRANAM="'||psa_to_xml(tbl_list(idx).rra_run_name)||'" RRASTS="'||psa_to_xml(tbl_list(idx).rra_run_status)||'"/>'));
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_RRA_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_run_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_run_rate t01
          where t01.rra_run_code = var_run_code;
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
      var_run_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@RRACDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDRRA' and var_action != '*CRTRRA' and var_action != '*CPYRRA' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing run rate when required
      /*-*/
      if var_action = '*UPDRRA' or var_action = '*CPYRRA' then
         var_found := false;
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
         if var_found = false then
            psa_gen_function.add_mesg_data('Run rate ('||var_run_code||') does not exist');
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
      /* Pipe the run rate XML
      /*-*/
      if var_action = '*UPDRRA' then
         var_output := '<RUNRATE RRACDE="'||psa_to_xml(rcd_retrieve.rra_run_code)||'"';
         var_output := var_output||' RRANAM="'||psa_to_xml(rcd_retrieve.rra_run_name)||'"';
         var_output := var_output||' RRASTS="'||psa_to_xml(rcd_retrieve.rra_run_status)||'"';
         var_output := var_output||' DIMV09="'||psa_to_xml(rcd_retrieve.rra_dim_val09)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CPYRRA' then
         var_output := '<RUNRATE RRACDE=""';
         var_output := var_output||' RRANAM="'||psa_to_xml(rcd_retrieve.rra_run_name)||'"';
         var_output := var_output||' RRASTS="'||psa_to_xml(rcd_retrieve.rra_run_status)||'"';
         var_output := var_output||' DIMV09="'||psa_to_xml(rcd_retrieve.rra_dim_val09)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CRTRRA' then
         var_output := '<RUNRATE RRACDE=""';
         var_output := var_output||' RRANAM=""';
         var_output := var_output||' RRASTS="1"';
         var_output := var_output||' DIMV09=""/>';
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_RRA_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      rcd_psa_run_rate psa_run_rate%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_run_rate t01
          where t01.rra_run_code = rcd_psa_run_rate.rra_run_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

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
      if var_action != '*UPDRRA' and var_action != '*CRTRRA' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_psa_run_rate.rra_run_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@RRACDE'));
      rcd_psa_run_rate.rra_run_name := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@RRANAM'));
      rcd_psa_run_rate.rra_run_status := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@RRASTS'));
      rcd_psa_run_rate.rra_upd_user := upper(par_user);
      rcd_psa_run_rate.rra_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_psa_run_rate.rra_run_code is null then
         psa_gen_function.add_mesg_data('Run rate code must be supplied');
      end if;
      if rcd_psa_run_rate.rra_run_name is null then
         psa_gen_function.add_mesg_data('Run rate name must be supplied');
      end if;
      if rcd_psa_run_rate.rra_run_status is null or (rcd_psa_run_rate.rra_run_status != '0' and rcd_psa_run_rate.rra_run_status != '1') then
         psa_gen_function.add_mesg_data('Run rate status must be (0)inactive or (1)active');
      end if;
      if rcd_psa_run_rate.rra_upd_user is null then
         psa_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the run rate definition
      /*-*/
      if var_action = '*UPDRRA' then
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
               psa_gen_function.add_mesg_data('Run rate code ('||rcd_psa_run_rate.rra_run_code||') is currently locked');
         end;
         if var_found = false then
            psa_gen_function.add_mesg_data('Run rate code ('||rcd_psa_run_rate.rra_run_code||') does not exist');
         end if;
         if psa_gen_function.get_mesg_count = 0 then
            update psa_run_rate
               set rra_run_name = rcd_psa_run_rate.rra_run_name,
                   rra_run_status = rcd_psa_run_rate.rra_run_status,
                   rra_upd_user = rcd_psa_run_rate.rra_upd_user,
                   rra_upd_date = rcd_psa_run_rate.rra_upd_date
             where rra_run_code = rcd_psa_run_rate.rra_run_code;
         end if;
      elsif var_action = '*CRTRRA' then
         var_confirm := 'created';
         begin
            insert into psa_run_rate values rcd_psa_run_rate;
         exception
            when dup_val_on_index then
               psa_gen_function.add_mesg_data('Run rate code ('||rcd_psa_run_rate.rra_run_code||') already exists - unable to create');
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
      psa_gen_function.set_cfrm_data('Run rate ('||to_char(rcd_psa_run_rate.rra_run_code)||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_RRA_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

end psa_rra_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_rra_function for psa_app.psa_rra_function;
grant execute on psa_app.psa_rra_function to public;

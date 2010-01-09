/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_pty_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_pty_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - Production Type Function

    This package contain the production type functions and procedures.

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

end psa_pty_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_pty_function as

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
      var_str_code varchar2(32);
      var_end_code varchar2(32);
      var_mat_flag varchar2(1);
      var_lin_flag varchar2(1);
      var_run_flag varchar2(1);
      var_res_flag varchar2(1);
      var_cre_flag varchar2(1);
      var_output varchar2(2000 char);
      var_pag_size number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_slct is
         select t01.*
           from (select t01.pty_prd_type,
                        t01.pty_prd_name,
                        decode(t01.pty_prd_status,'0','Inactive','1','Active','*UNKNOWN') as pty_prd_status
                   from psa_prd_type t01
                  where (var_str_code is null or t01.pty_prd_type >= var_str_code)
                    and (var_mat_flag is null or pty_prd_mat_usage = '1')
                    and (var_lin_flag is null or pty_prd_lin_usage = '1')
                    and (var_run_flag is null or pty_prd_run_usage = '1')
                    and (var_res_flag is null or pty_prd_res_usage = '1')
                    and (var_cre_flag is null or pty_prd_cre_usage = '1')
                  order by t01.pty_prd_type asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.pty_prd_type,
                        t01.pty_prd_name,
                        decode(t01.pty_prd_status,'0','Inactive','1','Active','*UNKNOWN') as pty_prd_status
                   from psa_prd_type t01
                  where ((var_action = '*NXTDEF' and (var_end_code is null or t01.pty_prd_type > var_end_code)) or
                         (var_action = '*PRVDEF'))
                    and (var_mat_flag is null or pty_prd_mat_usage = '1')
                    and (var_lin_flag is null or pty_prd_lin_usage = '1')
                    and (var_run_flag is null or pty_prd_run_usage = '1')
                    and (var_res_flag is null or pty_prd_res_usage = '1')
                    and (var_cre_flag is null or pty_prd_cre_usage = '1')
                  order by t01.pty_prd_type asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.pty_prd_type,
                        t01.pty_prd_name,
                        decode(t01.pty_prd_status,'0','Inactive','1','Active','*UNKNOWN') as pty_prd_status
                   from psa_prd_type t01
                  where ((var_action = '*PRVDEF' and (var_str_code is null or t01.pty_prd_type < var_str_code)) or
                         (var_action = '*NXTDEF'))
                    and (var_mat_flag is null or pty_prd_mat_usage = '1')
                    and (var_lin_flag is null or pty_prd_lin_usage = '1')
                    and (var_run_flag is null or pty_prd_run_usage = '1')
                    and (var_res_flag is null or pty_prd_res_usage = '1')
                    and (var_cre_flag is null or pty_prd_cre_usage = '1')
                  order by t01.pty_prd_type desc) t01
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
      var_str_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@STRCDE')));
      var_end_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@ENDCDE')));
      var_mat_flag := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@MATFLG')));
      var_lin_flag := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINFLG')));
      var_run_flag := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@RUNFLG')));
      var_res_flag := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@RESFLG')));
      var_cre_flag := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CREFLG')));
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
      /* Retrieve the production type list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELDEF' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(psa_xml_object('<LSTROW PRDTYP="'||to_char(tbl_list(idx).pty_prd_type)||'" PRDNAM="'||psa_to_xml(tbl_list(idx).pty_prd_name)||'" PRDSTS="'||psa_to_xml(tbl_list(idx).pty_prd_status)||'"/>'));
         end loop;
      elsif var_action = '*NXTDEF' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW PRDTYP="'||to_char(tbl_list(idx).pty_prd_type)||'" PRDNAM="'||psa_to_xml(tbl_list(idx).pty_prd_name)||'" PRDSTS="'||psa_to_xml(tbl_list(idx).pty_prd_status)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW PRDTYP="'||to_char(tbl_list(idx).pty_prd_type)||'" PRDNAM="'||psa_to_xml(tbl_list(idx).pty_prd_name)||'" PRDSTS="'||psa_to_xml(tbl_list(idx).pty_prd_status)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVDEF' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW PRDTYP="'||to_char(tbl_list(idx).pty_prd_type)||'" PRDNAM="'||psa_to_xml(tbl_list(idx).pty_prd_name)||'" PRDSTS="'||psa_to_xml(tbl_list(idx).pty_prd_status)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW PRDTYP="'||to_char(tbl_list(idx).pty_prd_type)||'" PRDNAM="'||psa_to_xml(tbl_list(idx).pty_prd_name)||'" PRDSTS="'||psa_to_xml(tbl_list(idx).pty_prd_status)||'"/>'));
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PTY_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_prd_type t01
          where t01.pty_prd_type = var_prd_type;
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
      var_prd_type := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PRDTYP')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' and var_action != '*CPYDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing production type when required
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
            psa_gen_function.add_mesg_data('Production type ('||var_prd_type||') does not exist');
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
      /* Pipe the production type XML
      /*-*/
      if var_action = '*UPDDEF' then
         var_output := '<PRDTYPE PRDTYP="'||psa_to_xml(rcd_retrieve.pty_prd_type||' - (Last updated by '||rcd_retrieve.pty_upd_user||' on '||to_char(rcd_retrieve.pty_upd_date,'yyyy/mm/dd')||')')||'"';
         var_output := var_output||' PRDNAM="'||psa_to_xml(rcd_retrieve.pty_prd_name)||'"';
         var_output := var_output||' PRDSTS="'||psa_to_xml(rcd_retrieve.pty_prd_status)||'"';
         var_output := var_output||' MATUSG="'||psa_to_xml(rcd_retrieve.pty_prd_mat_usage)||'"';
         var_output := var_output||' LINUSG="'||psa_to_xml(rcd_retrieve.pty_prd_lin_usage)||'"';
         var_output := var_output||' RUNUSG="'||psa_to_xml(rcd_retrieve.pty_prd_run_usage)||'"';
         var_output := var_output||' RESUSG="'||psa_to_xml(rcd_retrieve.pty_prd_res_usage)||'"';
         var_output := var_output||' CREUSG="'||psa_to_xml(rcd_retrieve.pty_prd_cre_usage)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CPYDEF' then
         var_output := '<PRDTYPE PRDTYP=""';
         var_output := var_output||' PRDNAM="'||psa_to_xml(rcd_retrieve.pty_prd_name)||'"';
         var_output := var_output||' PRDSTS="'||psa_to_xml(rcd_retrieve.pty_prd_status)||'"';
         var_output := var_output||' MATUSG="'||psa_to_xml(rcd_retrieve.pty_prd_mat_usage)||'"';
         var_output := var_output||' LINUSG="'||psa_to_xml(rcd_retrieve.pty_prd_lin_usage)||'"';
         var_output := var_output||' RUNUSG="'||psa_to_xml(rcd_retrieve.pty_prd_run_usage)||'"';
         var_output := var_output||' RESUSG="'||psa_to_xml(rcd_retrieve.pty_prd_res_usage)||'"';
         var_output := var_output||' CREUSG="'||psa_to_xml(rcd_retrieve.pty_prd_cre_usage)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CRTDEF' then
         var_output := '<PRDTYPE PRDTYP=""';
         var_output := var_output||' PRDNAM=""';
         var_output := var_output||' PRDSTS="1"';
         var_output := var_output||' MATUSG="0"';
         var_output := var_output||' LINUSG="0"';
         var_output := var_output||' RUNUSG="0"';
         var_output := var_output||' RESUSG="0"';
         var_output := var_output||' CREUSG="0"/>';
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PTY_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      rcd_psa_prd_type psa_prd_type%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_prd_type t01
          where t01.pty_prd_type = rcd_psa_prd_type.pty_prd_type
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
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_psa_prd_type.pty_prd_type := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PRDTYP')));
      rcd_psa_prd_type.pty_prd_name := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PRDNAM'));
      rcd_psa_prd_type.pty_prd_status := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PRDSTS'));
      rcd_psa_prd_type.pty_prd_mat_usage := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@MATUSG'));
      rcd_psa_prd_type.pty_prd_lin_usage := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINUSG'));
      rcd_psa_prd_type.pty_prd_run_usage := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@RUNUSG'));
      rcd_psa_prd_type.pty_prd_res_usage := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@RESUSG'));
      rcd_psa_prd_type.pty_prd_cre_usage := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CREUSG'));
      rcd_psa_prd_type.pty_upd_user := upper(par_user);
      rcd_psa_prd_type.pty_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_psa_prd_type.pty_prd_type is null then
         psa_gen_function.add_mesg_data('Production type code must be supplied');
      end if;
      if rcd_psa_prd_type.pty_prd_name is null then
         psa_gen_function.add_mesg_data('Production type name must be supplied');
      end if;
      if rcd_psa_prd_type.pty_prd_status is null or (rcd_psa_prd_type.pty_prd_status != '0' and rcd_psa_prd_type.pty_prd_status != '1') then
         psa_gen_function.add_mesg_data('Production type status must be (0)inactive or (1)active');
      end if;
      if rcd_psa_prd_type.pty_prd_mat_usage is null or (rcd_psa_prd_type.pty_prd_mat_usage != '0' and rcd_psa_prd_type.pty_prd_mat_usage != '1') then
         psa_gen_function.add_mesg_data('Production type material usage must be (0)no or (1)yes');
      end if;
      if rcd_psa_prd_type.pty_prd_lin_usage is null or (rcd_psa_prd_type.pty_prd_lin_usage != '0' and rcd_psa_prd_type.pty_prd_lin_usage != '1') then
         psa_gen_function.add_mesg_data('Production type line usage must be (0)no or (1)yes');
      end if;
      if rcd_psa_prd_type.pty_prd_run_usage is null or (rcd_psa_prd_type.pty_prd_run_usage != '0' and rcd_psa_prd_type.pty_prd_run_usage != '1') then
         psa_gen_function.add_mesg_data('Production type run rate usage must be (0)no or (1)yes');
      end if;
      if rcd_psa_prd_type.pty_prd_res_usage is null or (rcd_psa_prd_type.pty_prd_res_usage != '0' and rcd_psa_prd_type.pty_prd_res_usage != '1') then
         psa_gen_function.add_mesg_data('Production type resource must be (0)no or (1)yes');
      end if;
      if rcd_psa_prd_type.pty_prd_cre_usage is null or (rcd_psa_prd_type.pty_prd_cre_usage != '0' and rcd_psa_prd_type.pty_prd_cre_usage != '1') then
         psa_gen_function.add_mesg_data('Production type crew model must be (0)no or (1)yes');
      end if;
      if rcd_psa_prd_type.pty_upd_user is null then
         psa_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the production type definition
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
               psa_gen_function.add_mesg_data('Production type code ('||rcd_psa_prd_type.pty_prd_type||') is currently locked');
         end;
         if var_found = false then
            psa_gen_function.add_mesg_data('Production type code ('||rcd_psa_prd_type.pty_prd_type||') does not exist');
         end if;
         if psa_gen_function.get_mesg_count = 0 then
            update psa_prd_type
               set pty_prd_name = rcd_psa_prd_type.pty_prd_name,
                   pty_prd_status = rcd_psa_prd_type.pty_prd_status,
                   pty_prd_mat_usage = rcd_psa_prd_type.pty_prd_mat_usage,
                   pty_prd_lin_usage = rcd_psa_prd_type.pty_prd_lin_usage,
                   pty_prd_run_usage = rcd_psa_prd_type.pty_prd_run_usage,
                   pty_prd_res_usage = rcd_psa_prd_type.pty_prd_res_usage,
                   pty_prd_cre_usage = rcd_psa_prd_type.pty_prd_cre_usage,
                   pty_upd_user = rcd_psa_prd_type.pty_upd_user,
                   pty_upd_date = rcd_psa_prd_type.pty_upd_date
             where pty_prd_type = rcd_psa_prd_type.pty_prd_type;
         end if;
      elsif var_action = '*CRTDEF' then
         var_confirm := 'created';
         begin
            insert into psa_prd_type values rcd_psa_prd_type;
         exception
            when dup_val_on_index then
               psa_gen_function.add_mesg_data('Production type code ('||rcd_psa_prd_type.pty_prd_type||') already exists - unable to create');
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
      psa_gen_function.set_cfrm_data('Production type ('||to_char(rcd_psa_prd_type.pty_prd_type)||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PTY_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

end psa_pty_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_pty_function for psa_app.psa_pty_function;
grant execute on psa_app.psa_pty_function to public;

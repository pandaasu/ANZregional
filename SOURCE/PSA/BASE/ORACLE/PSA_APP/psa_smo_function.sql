/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_smo_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_smo_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - Shift Model Function

    This package contain the shift model functions and procedures.

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

end psa_smo_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_smo_function as

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
      var_output varchar2(2000 char);
      var_pag_size number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_slct is
         select t01.*
           from (select t01.smd_smo_code,
                        t01.smd_smo_name,
                        decode(t01.smd_smo_status,'0','Inactive','1','Active','*UNKNOWN') as smd_smo_status
                   from psa_smo_defn t01
                  where (var_str_code is null or t01.smd_smo_code >= var_str_code)
                  order by t01.smd_smo_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.smd_smo_code,
                        t01.smd_smo_name,
                        decode(t01.smd_smo_status,'0','Inactive','1','Active','*UNKNOWN') as smd_smo_status
                   from psa_smo_defn t01
                  where (var_action = '*NXTDEF' and (var_end_code is null or t01.smd_smo_code > var_end_code)) or
                        (var_action = '*PRVDEF')
                  order by t01.smd_smo_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.smd_smo_code,
                        t01.smd_smo_name,
                        decode(t01.smd_smo_status,'0','Inactive','1','Active','*UNKNOWN') as smd_smo_status
                   from psa_smo_defn t01
                  where (var_action = '*PRVDEF' and (var_str_code is null or t01.smd_smo_code < var_str_code)) or
                        (var_action = '*NXTDEF')
                  order by t01.smd_smo_code desc) t01
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
      /* Retrieve the shift model list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELDEF' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(psa_xml_object('<LSTROW SMOCDE="'||to_char(tbl_list(idx).smd_smo_code)||'" SMONAM="'||psa_to_xml(tbl_list(idx).smd_smo_name)||'" SMOSTS="'||psa_to_xml(tbl_list(idx).smd_smo_status)||'"/>'));
         end loop;
      elsif var_action = '*NXTDEF' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW SMOCDE="'||to_char(tbl_list(idx).smd_smo_code)||'" SMONAM="'||psa_to_xml(tbl_list(idx).smd_smo_name)||'" SMOSTS="'||psa_to_xml(tbl_list(idx).smd_smo_status)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW SMOCDE="'||to_char(tbl_list(idx).smd_smo_code)||'" SMONAM="'||psa_to_xml(tbl_list(idx).smd_smo_name)||'" SMOSTS="'||psa_to_xml(tbl_list(idx).smd_smo_status)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVDEF' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW SMOCDE="'||to_char(tbl_list(idx).smd_smo_code)||'" SMONAM="'||psa_to_xml(tbl_list(idx).smd_smo_name)||'" SMOSTS="'||psa_to_xml(tbl_list(idx).smd_smo_status)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW SMOCDE="'||to_char(tbl_list(idx).smd_smo_code)||'" SMONAM="'||psa_to_xml(tbl_list(idx).smd_smo_name)||'" SMOSTS="'||psa_to_xml(tbl_list(idx).smd_smo_status)||'"/>'));
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_SMO_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_smo_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_smo_defn t01
          where t01.smd_smo_code = var_smo_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_smo_shift is
         select t01.*,
                t02.*
           from psa_smo_shift t01,
                psa_shf_defn t02
          where t01.sms_shf_code = t02.sde_shf_code
            and t01.sms_smo_code = rcd_retrieve.smd_smo_code
            and t02.sde_shf_status = '1'
          order by t01.sms_smo_seqn asc;
      rcd_smo_shift csr_smo_shift%rowtype;

      cursor csr_shift is
         select t01.*
           from psa_shf_defn t01
          where t01.sde_shf_status = '1'
          order by t01.sde_shf_code asc;
      rcd_shift csr_shift%rowtype;

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
      var_smo_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SMOCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' and var_action != '*CPYDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing shift model when required
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
            psa_gen_function.add_mesg_data('Shift ('||var_smo_code||') does not exist');
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
      /* Pipe the shift model XML
      /*-*/
      if var_action = '*UPDDEF' then
         var_output := '<SMODFN SMOCDE="'||psa_to_xml(rcd_retrieve.smd_smo_code||' - (Last updated by '||rcd_retrieve.smd_upd_user||' on '||to_char(rcd_retrieve.smd_upd_date,'yyyy/mm/dd')||')')||'"';
         var_output := var_output||' SMONAM="'||psa_to_xml(rcd_retrieve.smd_smo_name)||'"';
         var_output := var_output||' SMOSTS="'||psa_to_xml(rcd_retrieve.smd_smo_status)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CPYDEF' then
         var_output := '<SMODFN SMOCDE=""';
         var_output := var_output||' SMONAM="'||psa_to_xml(rcd_retrieve.smd_smo_name)||'"';
         var_output := var_output||' SMOSTS="'||psa_to_xml(rcd_retrieve.smd_smo_status)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CRTDEF' then
         var_output := '<SMODFN SMOCDE=""';
         var_output := var_output||' SMONAM=""';
         var_output := var_output||' SMOSTS="1"/>';
         pipe row(psa_xml_object(var_output));
      end if;

      /*-*/
      /* Pipe the model shift data XML
      /*-*/
      open csr_smo_shift;
      loop
         fetch csr_smo_shift into rcd_smo_shift;
         if csr_smo_shift%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<SMOSHF SHFCDE="'||psa_to_xml(rcd_smo_shift.sde_shf_code)||'" SHFNAM="'||psa_to_xml('('||rcd_smo_shift.sde_shf_code||') '||rcd_smo_shift.sde_shf_name)||'" SHFSTR="'||to_char(rcd_smo_shift.sde_shf_start)||'" SHFDUR="'||to_char(rcd_smo_shift.sde_shf_duration)||'"/>'));
      end loop;
      close csr_smo_shift;

      /*-*/
      /* Pipe the shift data XML
      /*-*/
      open csr_shift;
      loop
         fetch csr_shift into rcd_shift;
         if csr_shift%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<SHFDFN SHFCDE="'||psa_to_xml(rcd_shift.sde_shf_code)||'" SHFNAM="'||psa_to_xml('('||rcd_shift.sde_shf_code||') '||rcd_shift.sde_shf_name)||'" SHFSTR="'||to_char(rcd_shift.sde_shf_start)||'" SHFDUR="'||to_char(rcd_shift.sde_shf_duration)||'"/>'));
      end loop;
      close csr_shift;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_SMO_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      obj_shf_list xmlDom.domNodeList;
      obj_shf_node xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      var_shf_code varchar2(32);
      rcd_psa_smo_defn psa_smo_defn%rowtype;
      rcd_psa_smo_shift psa_smo_shift%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_smo_defn t01
          where t01.smd_smo_code = rcd_psa_smo_defn.smd_smo_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_shift is
         select t01.*
           from psa_shf_defn t01
          where t01.sde_shf_code = var_shf_code;
      rcd_shift csr_shift%rowtype;

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
      rcd_psa_smo_defn.smd_smo_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SMOCDE')));
      rcd_psa_smo_defn.smd_smo_name := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SMONAM'));
      rcd_psa_smo_defn.smd_smo_status := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SMOSTS'));
      rcd_psa_smo_defn.smd_upd_user := upper(par_user);
      rcd_psa_smo_defn.smd_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_psa_smo_defn.smd_smo_code is null then
         psa_gen_function.add_mesg_data('Shift model code must be supplied');
      end if;
      if rcd_psa_smo_defn.smd_smo_name is null then
         psa_gen_function.add_mesg_data('Shift model name must be supplied');
      end if;
      if rcd_psa_smo_defn.smd_smo_status is null or (rcd_psa_smo_defn.smd_smo_status != '0' and rcd_psa_smo_defn.smd_smo_status != '1') then
         psa_gen_function.add_mesg_data('Shift model status must be (0)inactive or (1)active');
      end if;
      if rcd_psa_smo_defn.smd_upd_user is null then
         psa_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the relationships
      /*-*/
      obj_shf_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/SMOSHF');
      for idx in 0..xmlDom.getLength(obj_shf_list)-1 loop
         obj_shf_node := xmlDom.item(obj_shf_list,idx);
         var_shf_code := psa_from_xml(xslProcessor.valueOf(obj_shf_node,'@SHFCDE'));
         open csr_shift;
         fetch csr_shift into rcd_shift;
         if csr_shift%notfound then
            psa_gen_function.add_mesg_data('Shift code ('||var_shf_code||') does not exist');
         else
            if rcd_shift.sde_shf_status != '1' then
               psa_gen_function.add_mesg_data('Shift code ('||var_shf_code||') status must be (1)active');
            end if;
         end if;
         close csr_shift;
      end loop;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the shift model definition
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
               psa_gen_function.add_mesg_data('Shift model code ('||rcd_psa_smo_defn.smd_smo_code||') is currently locked');
         end;
         if var_found = false then
            psa_gen_function.add_mesg_data('Shift model code ('||rcd_psa_smo_defn.smd_smo_code||') does not exist');
         end if;
         if psa_gen_function.get_mesg_count = 0 then
            update psa_smo_defn
               set smd_smo_name = rcd_psa_smo_defn.smd_smo_name,
                   smd_smo_status = rcd_psa_smo_defn.smd_smo_status,
                   smd_upd_user = rcd_psa_smo_defn.smd_upd_user,
                   smd_upd_date = rcd_psa_smo_defn.smd_upd_date
             where smd_smo_code = rcd_psa_smo_defn.smd_smo_code;
            delete from psa_smo_shift where sms_smo_code = rcd_psa_smo_defn.smd_smo_code;
         end if;
      elsif var_action = '*CRTDEF' then
         var_confirm := 'created';
         begin
            insert into psa_smo_defn values rcd_psa_smo_defn;
         exception
            when dup_val_on_index then
               psa_gen_function.add_mesg_data('Shift model code ('||rcd_psa_smo_defn.smd_smo_code||') already exists - unable to create');
         end;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve and insert the shift model shift data
      /*-*/
      rcd_psa_smo_shift.sms_smo_code := rcd_psa_smo_defn.smd_smo_code;
      obj_shf_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/SMOSHF');
      for idx in 0..xmlDom.getLength(obj_shf_list)-1 loop
         obj_shf_node := xmlDom.item(obj_shf_list,idx);
         rcd_psa_smo_shift.sms_smo_seqn := idx + 1;
         rcd_psa_smo_shift.sms_shf_code := psa_from_xml(xslProcessor.valueOf(obj_shf_node,'@SHFCDE'));
         insert into psa_smo_shift values rcd_psa_smo_shift;
      end loop;

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
      psa_gen_function.set_cfrm_data('Shift model ('||rcd_psa_smo_defn.smd_smo_code||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_SMO_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      var_smo_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      -- child cursors

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
      var_smo_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SMOCDE')));
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the relationships
      /*-*/
      -- must not be used

      /*-*/
      /* Process the shift model definition
      /*-*/
      var_confirm := 'deleted';
      delete from psa_smo_shift where sms_smo_code = var_smo_code;
      delete from psa_smo_defn where smd_smo_code = var_smo_code;

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
      psa_gen_function.set_cfrm_data('Shift model ('||var_smo_code||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_SMO_FUNCTION - DELETE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_data;

end psa_smo_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_smo_function for psa_app.psa_smo_function;
grant execute on psa_app.psa_smo_function to public;
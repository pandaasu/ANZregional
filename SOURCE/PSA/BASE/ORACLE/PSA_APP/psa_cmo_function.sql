/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_cmo_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_cmo_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - Crew Model Function

    This package contain the crew model functions and procedures.

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

end psa_cmo_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_cmo_function as

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
           from (select t01.cmd_cmo_code,
                        t01.cmd_cmo_name,
                        decode(t01.cmd_cmo_status,'0','Inactive','1','Active','*UNKNOWN') as cmd_cmo_status
                   from psa_cmo_defn t01
                  where (var_str_code is null or t01.cmd_cmo_code >= var_str_code)
                    and t01.cmd_prd_type = var_prd_type
                  order by t01.cmd_cmo_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.cmd_cmo_code,
                        t01.cmd_cmo_name,
                        decode(t01.cmd_cmo_status,'0','Inactive','1','Active','*UNKNOWN') as cmd_cmo_status
                   from psa_cmo_defn t01
                  where ((var_action = '*NXTDEF' and (var_end_code is null or t01.cmd_cmo_code > var_end_code)) or
                         (var_action = '*PRVDEF'))
                    and t01.cmd_prd_type = var_prd_type
                  order by t01.cmd_cmo_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.cmd_cmo_code,
                        t01.cmd_cmo_name,
                        decode(t01.cmd_cmo_status,'0','Inactive','1','Active','*UNKNOWN') as cmd_cmo_status
                   from psa_cmo_defn t01
                  where ((var_action = '*PRVDEF' and (var_str_code is null or t01.cmd_cmo_code < var_str_code)) or
                         (var_action = '*NXTDEF'))
                    and t01.cmd_prd_type = var_prd_type
                  order by t01.cmd_cmo_code desc) t01
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
      /* Retrieve the crew model list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELDEF' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(psa_xml_object('<LSTROW CMOCDE="'||to_char(tbl_list(idx).cmd_cmo_code)||'" CMONAM="'||psa_to_xml(tbl_list(idx).cmd_cmo_name)||'" CMOSTS="'||psa_to_xml(tbl_list(idx).cmd_cmo_status)||'"/>'));
         end loop;
      elsif var_action = '*NXTDEF' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW CMOCDE="'||to_char(tbl_list(idx).cmd_cmo_code)||'" CMONAM="'||psa_to_xml(tbl_list(idx).cmd_cmo_name)||'" CMOSTS="'||psa_to_xml(tbl_list(idx).cmd_cmo_status)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW CMOCDE="'||to_char(tbl_list(idx).cmd_cmo_code)||'" CMONAM="'||psa_to_xml(tbl_list(idx).cmd_cmo_name)||'" CMOSTS="'||psa_to_xml(tbl_list(idx).cmd_cmo_status)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVDEF' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW CMOCDE="'||to_char(tbl_list(idx).cmd_cmo_code)||'" CMONAM="'||psa_to_xml(tbl_list(idx).cmd_cmo_name)||'" CMOSTS="'||psa_to_xml(tbl_list(idx).cmd_cmo_status)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW CMOCDE="'||to_char(tbl_list(idx).cmd_cmo_code)||'" CMONAM="'||psa_to_xml(tbl_list(idx).cmd_cmo_name)||'" CMOSTS="'||psa_to_xml(tbl_list(idx).cmd_cmo_status)||'"/>'));
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_CMO_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_cmo_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_cmo_defn t01
          where t01.cmd_cmo_code = var_cmo_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_resource is
         select t01.*,
                nvl(t02.cmr_res_qnty,0) as cmr_res_qnty
           from psa_res_defn t01,
                psa_cmo_resource t02
          where t01.rde_res_code = t02.cmr_res_code(+)
            and rcd_retrieve.cmd_cmo_code = t02.cmr_cmo_code(+)
            and t01.rde_res_status = '1'
          order by t01.rde_res_name asc;
      rcd_resource csr_resource%rowtype;

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
      var_cmo_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CMOCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' and var_action != '*CPYDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing crew model when required
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
            psa_gen_function.add_mesg_data('Crew model ('||var_cmo_code||') does not exist');
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
      /* Pipe the crew model XML
      /*-*/
      if var_action = '*UPDDEF' then
         var_output := '<CMODFN CMOCDE="'||psa_to_xml(rcd_retrieve.cmd_cmo_code||' - (Last updated by '||rcd_retrieve.cmd_upd_user||' on '||to_char(rcd_retrieve.cmd_upd_date,'yyyy/mm/dd')||')')||'"';
         var_output := var_output||' CMONAM="'||psa_to_xml(rcd_retrieve.cmd_cmo_name)||'"';
         var_output := var_output||' CMOSTS="'||psa_to_xml(rcd_retrieve.cmd_cmo_status)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CPYDEF' then
         var_output := '<CMODFN CMOCDE=""';
         var_output := var_output||' CMONAM="'||psa_to_xml(rcd_retrieve.cmd_cmo_name)||'"';
         var_output := var_output||' CMOSTS="'||psa_to_xml(rcd_retrieve.cmd_cmo_status)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CRTDEF' then
         var_output := '<CMODFN CMOCDE=""';
         var_output := var_output||' CMONAM=""';
         var_output := var_output||' CMOSTS="1"/>';
         pipe row(psa_xml_object(var_output));
      end if;

      /*-*/
      /* Pipe the model resource data XML
      /*-*/
      open csr_resource;
      loop
         fetch csr_resource into rcd_resource;
         if csr_resource%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<CMORES RESCDE="'||psa_to_xml(rcd_resource.rde_res_code)||'" RESNAM="'||psa_to_xml('('||rcd_resource.rde_res_code||') '||rcd_resource.rde_res_name)||'" RESQTY="'||to_char(rcd_resource.cmr_res_qnty)||'"/>'));
      end loop;
      close csr_resource;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_CMO_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      obj_res_list xmlDom.domNodeList;
      obj_res_node xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      var_res_code varchar2(32);
      rcd_psa_cmo_defn psa_cmo_defn%rowtype;
      rcd_psa_cmo_resource psa_cmo_resource%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_cmo_defn t01
          where t01.cmd_cmo_code = rcd_psa_cmo_defn.cmd_cmo_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_resource is
         select t01.*
           from psa_res_defn t01
          where t01.rde_res_code = var_res_code;
      rcd_resource csr_resource%rowtype;

      cursor csr_prdtype is
         select t01.*
           from psa_prd_type t01
          where t01.pty_prd_type = rcd_psa_cmo_defn.cmd_prd_type;
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
      rcd_psa_cmo_defn.cmd_cmo_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CMOCDE')));
      rcd_psa_cmo_defn.cmd_cmo_name := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CMONAM'));
      rcd_psa_cmo_defn.cmd_cmo_status := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CMOSTS'));
      rcd_psa_cmo_defn.cmd_prd_type := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      rcd_psa_cmo_defn.cmd_upd_user := upper(par_user);
      rcd_psa_cmo_defn.cmd_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_psa_cmo_defn.cmd_cmo_code is null then
         psa_gen_function.add_mesg_data('Crew model code must be supplied');
      end if;
      if rcd_psa_cmo_defn.cmd_cmo_name is null then
         psa_gen_function.add_mesg_data('Crew model name must be supplied');
      end if;
      if rcd_psa_cmo_defn.cmd_cmo_status is null or (rcd_psa_cmo_defn.cmd_cmo_status != '0' and rcd_psa_cmo_defn.cmd_cmo_status != '1') then
         psa_gen_function.add_mesg_data('Crew model status must be (0)inactive or (1)active');
      end if;
      if rcd_psa_cmo_defn.cmd_upd_user is null then
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
         psa_gen_function.add_mesg_data('Production type code ('||rcd_psa_cmo_defn.cmd_prd_type||') does not exist');
      else
         if rcd_psa_cmo_defn.cmd_cmo_status = '1' and rcd_prdtype.pty_prd_status != '1' then
            psa_gen_function.add_mesg_data('Production type code ('||rcd_psa_cmo_defn.cmd_prd_type||') status must be (1)active for and active crew model');
         end if;
         if rcd_psa_cmo_defn.cmd_cmo_status = '1' and rcd_prdtype.pty_prd_cre_usage != '1' then
            psa_gen_function.add_mesg_data('Production type code ('||rcd_psa_cmo_defn.cmd_prd_type||') must be flagged for crew usage');
         end if;
      end if;
      close csr_prdtype;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the relationships
      /*-*/
      obj_res_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/CMORES');
      for idx in 0..xmlDom.getLength(obj_res_list)-1 loop
         obj_res_node := xmlDom.item(obj_res_list,idx);
         var_res_code := upper(psa_from_xml(xslProcessor.valueOf(obj_res_node,'@RESCDE')));
         open csr_resource;
         fetch csr_resource into rcd_resource;
         if csr_resource%notfound then
            psa_gen_function.add_mesg_data('Resource code ('||var_res_code||') does not exist');
         else
            if rcd_resource.rde_res_status != '1' then
               psa_gen_function.add_mesg_data('Resource code ('||var_res_code||') status must be (1)active');
            end if;
         end if;
         close csr_resource;
      end loop;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the crew model definition
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
               psa_gen_function.add_mesg_data('Crew model code ('||rcd_psa_cmo_defn.cmd_cmo_code||') is currently locked');
         end;
         if var_found = false then
            psa_gen_function.add_mesg_data('Crew model code ('||rcd_psa_cmo_defn.cmd_cmo_code||') does not exist');
         end if;
         if psa_gen_function.get_mesg_count = 0 then
            update psa_cmo_defn
               set cmd_cmo_name = rcd_psa_cmo_defn.cmd_cmo_name,
                   cmd_cmo_status = rcd_psa_cmo_defn.cmd_cmo_status,
                   cmd_upd_user = rcd_psa_cmo_defn.cmd_upd_user,
                   cmd_upd_date = rcd_psa_cmo_defn.cmd_upd_date
             where cmd_cmo_code = rcd_psa_cmo_defn.cmd_cmo_code;
            delete from psa_cmo_resource where cmr_cmo_code = rcd_psa_cmo_defn.cmd_cmo_code;
         end if;
      elsif var_action = '*CRTDEF' then
         var_confirm := 'created';
         begin
            insert into psa_cmo_defn values rcd_psa_cmo_defn;
         exception
            when dup_val_on_index then
               psa_gen_function.add_mesg_data('Crew model code ('||rcd_psa_cmo_defn.cmd_cmo_code||') already exists - unable to create');
         end;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve and insert the crew model crew data
      /*-*/
      rcd_psa_cmo_resource.cmr_cmo_code := rcd_psa_cmo_defn.cmd_cmo_code;
      obj_res_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/CMORES');
      for idx in 0..xmlDom.getLength(obj_res_list)-1 loop
         obj_res_node := xmlDom.item(obj_res_list,idx);
         if nvl(psa_to_number(xslProcessor.valueOf(obj_res_node,'@RESQTY')),0) > 0 then
            rcd_psa_cmo_resource.cmr_res_code := upper(psa_from_xml(xslProcessor.valueOf(obj_res_node,'@RESCDE')));
            rcd_psa_cmo_resource.cmr_res_qnty := psa_to_number(xslProcessor.valueOf(obj_res_node,'@RESQTY'));
            insert into psa_cmo_resource values rcd_psa_cmo_resource;
         end if;
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
      psa_gen_function.set_cfrm_data('Crew model ('||rcd_psa_cmo_defn.cmd_cmo_code||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_CMO_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      var_cmo_code varchar2(32);

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
      var_cmo_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CMOCDE')));
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the relationships
      /*-*/
      -- must not be used

      /*-*/
      /* Process the crew model definition
      /*-*/
      var_confirm := 'deleted';
      delete from psa_cmo_resource where cmr_cmo_code = var_cmo_code;
      delete from psa_cmo_defn where cmd_cmo_code = var_cmo_code;

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
      psa_gen_function.set_cfrm_data('Crew model ('||var_cmo_code||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_CMO_FUNCTION - DELETE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_data;

end psa_cmo_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_cmo_function for psa_app.psa_cmo_function;
grant execute on psa_app.psa_cmo_function to public;

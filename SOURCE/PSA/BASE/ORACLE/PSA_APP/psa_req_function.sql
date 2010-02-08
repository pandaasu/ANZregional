/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_req_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_req_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - Requirement Function

    This package contain the requirement functions and procedures.

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

end psa_req_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_req_function as

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
           from (select t01.rhe_req_code,
                        t01.rhe_req_name
                   from psa_req_header t01
                  where (var_str_code is null or t01.rhe_req_code >= var_str_code)
                  order by t01.rhe_req_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.rhe_req_code,
                        t01.rhe_req_name
                   from psa_req_header t01
                  where ((var_action = '*NXTDEF' and (var_end_code is null or t01.rhe_req_code > var_end_code)) or
                         (var_action = '*PRVDEF'))
                  order by t01.rhe_req_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.rhe_req_code,
                        t01.rhe_req_name
                   from psa_req_header t01
                  where ((var_action = '*PRVDEF' and (var_str_code is null or t01.rhe_req_code < var_str_code)) or
                         (var_action = '*NXTDEF'))
                  order by t01.rhe_req_code desc) t01
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
      /* Retrieve the requirement list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELDEF' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(psa_xml_object('<LSTROW REQCDE="'||to_char(tbl_list(idx).rhe_req_code)||'" REQNAM="'||psa_to_xml(tbl_list(idx).rhe_req_name)||'"/>'));
         end loop;
      elsif var_action = '*NXTDEF' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW REQCDE="'||to_char(tbl_list(idx).rhe_req_code)||'" REQNAM="'||psa_to_xml(tbl_list(idx).rhe_req_name)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW REQCDE="'||to_char(tbl_list(idx).rhe_req_code)||'" REQNAM="'||psa_to_xml(tbl_list(idx).rhe_req_name)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVDEF' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW REQCDE="'||to_char(tbl_list(idx).rhe_req_code)||'" REQNAM="'||psa_to_xml(tbl_list(idx).rhe_req_name)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW REQCDE="'||to_char(tbl_list(idx).rhe_req_code)||'" REQNAM="'||psa_to_xml(tbl_list(idx).rhe_req_name)||'"/>'));
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_REQ_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_output varchar2(2000 char);

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
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*CRTDEF' then
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
      /* Pipe the requirement XML
      /*-*/
      var_output := '<REQDFN REQNAM="" REQDTE=""/>';
      pipe row(psa_xml_object(var_output));

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_REQ_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      obj_det_list xmlDom.domNodeList;
      obj_det_node xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      var_det_data varchar2(2000);
      var_det_char varchar2(1);
      var_det_valu varchar2(2000);
      var_det_indx number;
      var_det_mesg boolean;
      var_det_code varchar2(32);
      var_det_qnty number;
      type typ_detl is table of psa_req_detail%rowtype index by binary_integer;
      tbl_detl typ_detl;
      rcd_psa_req_header psa_req_header%rowtype;
      rcd_psa_req_detail psa_req_detail%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_week is
         select t01.mars_week
           from mars_date t01
          where t01.calendar_date = rcd_psa_req_header.rhe_str_date;
      rcd_week csr_week%rowtype;

      cursor csr_material is
         select t01.*
           from psa_mat_defn t01
          where t01.mde_mat_code = var_det_code;
      rcd_material csr_material%rowtype;

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
      rcd_psa_req_header.rhe_req_name := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@REQNAM'));
      rcd_psa_req_header.rhe_str_date := psa_to_date(xslProcessor.valueOf(obj_psa_request,'@REQDTE'),'dd/mm/yyyy');
      rcd_psa_req_header.rhe_upd_user := upper(par_user);
      rcd_psa_req_header.rhe_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_psa_req_header.rhe_req_name is null then
         psa_gen_function.add_mesg_data('Requirement name must be supplied');
      end if;
      if rcd_psa_req_header.rhe_str_date is null then
         psa_gen_function.add_mesg_data('Requirement start date must be supplied in format DD/MM/YYYY');
      end if;
      if rcd_psa_req_header.rhe_upd_user is null then
         psa_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Set the fields
      /*-*/
      rcd_psa_req_header.rhe_req_code := rcd_psa_req_header.rhe_str_week||'_'||to_char(sysdate,'yyyymmddhhmiss');

      /*-*/
      /* Retrieve the end week
      /*-*/
      var_found := false;
      open csr_week;
      fetch csr_week into rcd_week;
      if csr_week%found then
         var_found := true;
      end if;
      close csr_week;
      if var_found = false then
         psa_gen_function.add_mesg_data('Requirement start date not found on MARS_DATE table');
         return;
      end if;
      rcd_psa_req_header.rhe_str_week := rcd_week.mars_week;

      /*-*/
      /* Retrieve the file text stream
      /*-*/
      tbl_detl.delete;
      obj_det_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/TXTSTREAM/XR');
      for idx in 0..xmlDom.getLength(obj_det_list)-1 loop
         obj_det_node := xmlDom.item(obj_det_list,idx);
         var_det_data := rtrim(ltrim(xslProcessor.valueOf(obj_det_node,'/text()'),'['),']');
         if not(var_det_data is null) then
            var_det_mesg := false;
            var_det_valu := null;
            var_det_indx := 0;
            for idx in 1..length(var_det_data) loop
               var_det_char := substr(var_det_data,idx,1);
               if var_det_char = chr(9) then
                  if var_det_indx = 1 then
                     var_det_code := var_det_valu;
                     open csr_material;
                     fetch csr_material into rcd_material;
                     if csr_material%notfound then
                        psa_gen_function.add_mesg_data('SAP material code ('||var_det_code||') - data row '||to_char((idx+1))||' column '||to_char(var_det_indx)||' -  does not exist');
                        var_det_mesg := true;
                     else
                        if rcd_material.mde_mat_status = '*INACTIVE' then
                           psa_gen_function.add_mesg_data('SAP material code ('||var_det_code||') - data row '||to_char((idx+1))||' column '||to_char(var_det_indx)||' -  is inactive');
                           var_det_mesg := true;
                        end if;
                     end if;
                     close csr_material;
                  elsif var_det_indx = 2 then
                     var_det_qnty := null;
                     if not(var_det_valu is null) then
                        begin
                           if substr(var_det_valu,length(var_det_valu),1) = '-' then
                              var_det_qnty := to_number('-' || substr(var_det_valu,1,length(var_det_valu) - 1));
                           else
                              var_det_qnty := to_number(var_det_valu);
                           end if;
                        exception
                           when others then
                              null;
                        end;
                     end if;
                     if var_det_qnty is null then
                        psa_gen_function.add_mesg_data('SAP material quantity - data row '||to_char((idx+1))||' column '||to_char(var_det_indx)||' - invalid number ('||var_det_valu||')');
                        var_det_mesg := true;
                     elsif var_det_qnty <= 0 then
                        psa_gen_function.add_mesg_data('SAP material quantity - data row '||to_char((idx+1))||' column '||to_char(var_det_indx)||' - must be greater than zero');
                        var_det_mesg := true;
                     end if;
                  end if;
                  var_det_indx := var_det_indx + 1;
                  var_det_valu := null;
               else
                  var_det_valu := var_det_valu||var_det_char;
               end if;
            end loop;
            if var_det_mesg = false then
               tbl_detl(tbl_detl.count+1).rde_req_code := rcd_psa_req_header.rhe_req_code;
               tbl_detl(tbl_detl.count).rde_mat_code := var_det_code;
               tbl_detl(tbl_detl.count).rde_mat_qnty := var_det_qnty;
            elsif psa_gen_function.get_mesg_count > 40 then
               psa_gen_function.add_mesg_data('Maximum file errors exceeded (unable to show)');
               exit;
            end if;
         end if;
      end loop;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the requirement
      /*-*/
      var_confirm := 'created';
      begin
         insert into psa_req_header values rcd_psa_req_header;
      exception
         when dup_val_on_index then
            psa_gen_function.add_mesg_data('Requirement ('||rcd_psa_req_header.rhe_req_code||') already exists - unable to create');
      end;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve and insert the detail data when required
      /*-*/
      for idx in 1..tbl_detl.count loop
         rcd_psa_req_detail.rde_req_code := tbl_detl(idx).rde_req_code;
         rcd_psa_req_detail.rde_mat_code := tbl_detl(idx).rde_mat_code;
         rcd_psa_req_detail.rde_mat_qnty := tbl_detl(idx).rde_mat_qnty;
         insert into psa_req_detail values rcd_psa_req_detail;
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
      psa_gen_function.set_cfrm_data('Requirement ('||rcd_psa_req_header.rhe_req_code||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_REQ_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      var_req_code varchar2(32);

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
      var_req_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@REQCDE')));
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the requirement
      /*-*/
      var_confirm := 'deleted';
      delete from psa_req_detail where rde_req_code = var_req_code;
      delete from psa_req_header where rhe_req_code = var_req_code;

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
      psa_gen_function.set_cfrm_data('Requirement ('||var_req_code||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_REQ_FUNCTION - DELETE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_data;

end psa_req_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_req_function for psa_app.psa_req_function;
grant execute on psa_app.psa_req_function to public;

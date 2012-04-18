/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_das_maintenance as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_das_maintenance
    Owner   : qv_app

    Description
    -----------
    QlikView Interfacing - Dashboard Maintenance

    This package contain the dashboard maintenance functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function select_list return qvi_xml_type pipelined;
   function retrieve_data return qvi_xml_type pipelined;
   procedure update_data(par_user in varchar2);
   procedure delete_data;

end qvi_das_maintenance;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_das_maintenance as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***************************************************/
   /* This procedure performs the select list routine */
   /***************************************************/
   function select_list return qvi_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_qvi_request xmlDom.domNode;
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
           from (select t01.qdd_das_code,
                        t01.qdd_das_name,
                        decode(t01.qdd_das_status,'0','Inactive','1','Active','*UNKNOWN') as qdd_das_status
                   from qvi_das_defn t01
                  where (var_str_code is null or t01.qdd_das_code >= var_str_code)
                  order by t01.qdd_das_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.qdd_das_code,
                        t01.qdd_das_name,
                        decode(t01.qdd_das_status,'0','Inactive','1','Active','*UNKNOWN') as qdd_das_status
                   from qvi_das_defn t01
                  where (var_action = '*NXTDEF' and (var_end_code is null or t01.qdd_das_code > var_end_code)) or
                        (var_action = '*PRVDEF')
                  order by t01.qdd_das_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.qdd_das_code,
                        t01.qdd_das_name,
                        decode(t01.qdd_das_status,'0','Inactive','1','Active','*UNKNOWN') as qdd_das_status
                   from qvi_das_defn t01
                  where (var_action = '*PRVDEF' and (var_str_code is null or t01.qdd_das_code < var_str_code)) or
                        (var_action = '*NXTDEF')
                  order by t01.qdd_das_code desc) t01
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
      qvi_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('QVI_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_qvi_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/QVI_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_qvi_request,'@ACTION'));
      var_str_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@STRCDE')));
      var_end_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@ENDCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SELDEF' and var_action != '*PRVDEF' and var_action != '*NXTDEF' then
         qvi_gen_function.add_mesg_data('Invalid request action');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(qvi_xml_object('<?xml version="1.0" encoding="UTF-8"?><QVI_RESPONSE>'));

      /*-*/
      /* Retrieve the dashboard list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELDEF' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(qvi_xml_object('<LSTROW DASCDE="'||qvi_to_xml(tbl_list(idx).qdd_das_code)||'" DASNAM="'||qvi_to_xml(tbl_list(idx).qdd_das_name)||'" DASSTS="'||qvi_to_xml(tbl_list(idx).qdd_das_status)||'"/>'));
         end loop;
      elsif var_action = '*NXTDEF' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(qvi_xml_object('<LSTROW DASCDE="'||qvi_to_xml(tbl_list(idx).qdd_das_code)||'" DASNAM="'||qvi_to_xml(tbl_list(idx).qdd_das_name)||'" DASSTS="'||qvi_to_xml(tbl_list(idx).qdd_das_status)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(qvi_xml_object('<LSTROW DASCDE="'||qvi_to_xml(tbl_list(idx).qdd_das_code)||'" DASNAM="'||qvi_to_xml(tbl_list(idx).qdd_das_name)||'" DASSTS="'||qvi_to_xml(tbl_list(idx).qdd_das_status)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVDEF' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(qvi_xml_object('<LSTROW DASCDE="'||qvi_to_xml(tbl_list(idx).qdd_das_code)||'" DASNAM="'||qvi_to_xml(tbl_list(idx).qdd_das_name)||'" DASSTS="'||qvi_to_xml(tbl_list(idx).qdd_das_status)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(qvi_xml_object('<LSTROW DASCDE="'||qvi_to_xml(tbl_list(idx).qdd_das_code)||'" DASNAM="'||qvi_to_xml(tbl_list(idx).qdd_das_name)||'" DASSTS="'||qvi_to_xml(tbl_list(idx).qdd_das_status)||'"/>'));
            end loop;
         end if;
      end if;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(qvi_xml_object('</QVI_RESPONSE>'));

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_MAINTENANCE - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_list;

   /*****************************************************/
   /* This procedure performs the retrieve data routine */
   /*****************************************************/
   function retrieve_data return qvi_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_qvi_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_das_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from qvi_das_defn t01
          where t01.qdd_das_code = var_das_code;
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
      qvi_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('QVI_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_qvi_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/QVI_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_qvi_request,'@ACTION'));
      var_das_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DASCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' then
         qvi_gen_function.add_mesg_data('Invalid request action');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing dashboard when required
      /*-*/
      if var_action = '*UPDDEF' then
         var_found := false;
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
         if var_found = false then
            qvi_gen_function.add_mesg_data('Dashboard ('||var_das_code||') does not exist');
         end if;
         if qvi_gen_function.get_mesg_count != 0 then
            return;
         end if;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(qvi_xml_object('<?xml version="1.0" encoding="UTF-8"?><QVI_RESPONSE>'));

      /*-*/
      /* Pipe the dashboard XML
      /*-*/
      if var_action = '*UPDDEF' then
         var_output := '<DASDFN DASCDE="'||qvi_to_xml(rcd_retrieve.qdd_das_code||' - (Last updated by '||rcd_retrieve.qdd_upd_user||' on '||to_char(rcd_retrieve.qdd_upd_date,'yyyy/mm/dd')||')')||'"';
         var_output := var_output||' DASNAM="'||qvi_to_xml(rcd_retrieve.qdd_das_name)||'"';
         var_output := var_output||' DASSTS="'||qvi_to_xml(rcd_retrieve.qdd_das_status)||'"/>';
         pipe row(qvi_xml_object(var_output));
      elsif var_action = '*CRTDEF' then
         var_output := '<DASDFN DASCDE=""';
         var_output := var_output||' DASNAM=""';
         var_output := var_output||' DASSTS="1"/>';
         pipe row(qvi_xml_object(var_output));
      end if;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(qvi_xml_object('</QVI_RESPONSE>'));

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_MAINTENANCE - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      obj_qvi_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      rcd_qvi_das_defn qvi_das_defn%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from qvi_das_defn t01
          where t01.qdd_das_code = rcd_qvi_das_defn.qdd_das_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the message data
      /*-*/
      qvi_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('QVI_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_qvi_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/QVI_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_qvi_request,'@ACTION'));
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' then
         qvi_gen_function.add_mesg_data('Invalid request action');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_qvi_das_defn.qdd_das_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DASCDE')));
      rcd_qvi_das_defn.qdd_das_name := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DASNAM'));
      rcd_qvi_das_defn.qdd_das_status := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DASSTS'));
      rcd_qvi_das_defn.qdd_upd_user := upper(par_user);
      rcd_qvi_das_defn.qdd_upd_date := sysdate;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_qvi_das_defn.qdd_das_code is null then
         qvi_gen_function.add_mesg_data('Dashboard code must be supplied');
      end if;
      if rcd_qvi_das_defn.qdd_das_name is null then
         qvi_gen_function.add_mesg_data('Dashboard name must be supplied');
      end if;
      if rcd_qvi_das_defn.qdd_das_status is null or (rcd_qvi_das_defn.qdd_das_status != '0' and rcd_qvi_das_defn.qdd_das_status != '1') then
         qvi_gen_function.add_mesg_data('Dashboard status must be (0)inactive or (1)active');
      end if;
      if rcd_qvi_das_defn.qdd_upd_user is null then
         qvi_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the dashboard definition
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
               qvi_gen_function.add_mesg_data('Dashboard code ('||rcd_qvi_das_defn.qdd_das_code||') is currently locked');
         end;
         if var_found = false then
            qvi_gen_function.add_mesg_data('Dashboard code ('||rcd_qvi_das_defn.qdd_das_code||') does not exist');
         end if;
         if qvi_gen_function.get_mesg_count = 0 then
            update qvi_das_defn
               set qdd_das_name = rcd_qvi_das_defn.qdd_das_name,
                   qdd_das_status = rcd_qvi_das_defn.qdd_das_status,
                   qdd_upd_user = rcd_qvi_das_defn.qdd_upd_user,
                   qdd_upd_date = rcd_qvi_das_defn.qdd_upd_date
             where qdd_das_code = rcd_qvi_das_defn.qdd_das_code;
         end if;
      elsif var_action = '*CRTDEF' then
         var_confirm := 'created';
         begin
            insert into qvi_das_defn values rcd_qvi_das_defn;
         exception
            when dup_val_on_index then
               qvi_gen_function.add_mesg_data('Dashboard code ('||rcd_qvi_das_defn.qdd_das_code||') already exists - unable to create');
         end;
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
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
      qvi_gen_function.set_cfrm_data('Dashboard ('||to_char(rcd_qvi_das_defn.qdd_das_code)||') successfully '||var_confirm);

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_MAINTENANCE - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      obj_qvi_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      var_das_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from qvi_das_defn t01
          where t01.qdd_das_code = var_das_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_fact is
         select t01.*
           from qvi_fac_defn t01
          where t01.qfd_das_code = var_das_code;
      rcd_fact csr_fact%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the message data
      /*-*/
      qvi_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('QVI_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_qvi_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/QVI_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_qvi_request,'@ACTION'));
      if var_action != '*DLTDEF' then
         qvi_gen_function.add_mesg_data('Invalid request action');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_das_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DASCDE')));
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the dashboard definition
      /*-*/
      var_confirm := 'deleted';
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
            qvi_gen_function.add_mesg_data('Dashboard code ('||var_das_code||') is currently locked');
      end;
      if var_found = false then
         qvi_gen_function.add_mesg_data('Dashboard code ('||var_das_code||') does not exist');
      else
         var_found := false;
         open csr_fact;
         fetch csr_fact into rcd_fact;
         if csr_fact%found then
            var_found := true;
         end if;
         close csr_fact;
         if var_found = true then
            qvi_gen_function.add_mesg_data('Dashboard code ('||var_das_code||') has facts defined - unable to delete');
         end if;
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Delete the data
      /*-*/
      delete from qvi_src_data where qsd_das_code = var_das_code;
      delete from qvi_src_hedr where qsh_das_code = var_das_code;
      delete from qvi_fac_data where qfd_das_code = var_das_code;
      delete from qvi_fac_hedr where qfh_das_code = var_das_code;
      delete from qvi_fac_time where qft_das_code = var_das_code;
      delete from qvi_fac_part where qfp_das_code = var_das_code;
      delete from qvi_fac_defn where qfd_das_code = var_das_code;
      delete from qvi_das_defn where qdd_das_code = var_das_code;

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
      qvi_gen_function.set_cfrm_data('Dashboard ('||var_das_code||') successfully '||var_confirm);

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_MAINTENANCE - DELETE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_data;

end qvi_das_maintenance;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qvi_das_maintenance for qv_app.qvi_das_maintenance;
grant execute on qv_app.qvi_das_maintenance to public;

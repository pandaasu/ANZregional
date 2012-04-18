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
   function select_fact_list return qvi_xml_type pipelined;
   function retrieve_fact_data return qvi_xml_type pipelined;
   procedure update_fact_data(par_user in varchar2);
   procedure delete_fact_data;
   function select_part_list return qvi_xml_type pipelined;
   function retrieve_part_data return qvi_xml_type pipelined;
   procedure update_part_data(par_user in varchar2);
   procedure delete_part_data;

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

   /********************************************************/
   /* This procedure performs the select fact list routine */
   /********************************************************/
   function select_fact_list return qvi_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_qvi_request xmlDom.domNode;
      var_das_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_slct is
         select t01.qfd_fac_code,
                t01.qfd_fac_name,
                decode(t01.qfd_fac_status,'0','Inactive','1','Active','*UNKNOWN') as qfd_fac_status
           from qvi_fac_defn t01
          where t01.qfd_das_code = var_das_code
          order by t01.qfd_fac_code asc;

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
      var_das_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DASCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(qvi_xml_object('<?xml version="1.0" encoding="UTF-8"?><QVI_RESPONSE>'));

      /*-*/
      /* Retrieve the fact list and pipe the results
      /*-*/
      tbl_list.delete;
      open csr_slct;
      fetch csr_slct bulk collect into tbl_list;
      close csr_slct;
      for idx in 1..tbl_list.count loop
         pipe row(qvi_xml_object('<LSTROW FACCDE="'||qvi_to_xml(tbl_list(idx).qfd_fac_code)||'" FACNAM="'||qvi_to_xml(tbl_list(idx).qfd_fac_name)||'" FACSTS="'||qvi_to_xml(tbl_list(idx).qfd_fac_status)||'"/>'));
      end loop;

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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_MAINTENANCE - SELECT_FACT_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_fact_list;

   /**********************************************************/
   /* This procedure performs the retrieve fact data routine */
   /**********************************************************/
   function retrieve_fact_data return qvi_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_qvi_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_das_code varchar2(32);
      var_fac_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from qvi_fac_defn t01
          where t01.qfd_das_code = var_das_code
            and t01.qfd_fac_code = var_fac_code;
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
      var_fac_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FACCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' then
         qvi_gen_function.add_mesg_data('Invalid request action');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing fact when required
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
            qvi_gen_function.add_mesg_data('Dashboard/Fact ('||var_das_code||'/'||var_fac_code||') does not exist');
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
      /* Pipe the fact XML
      /*-*/
      if var_action = '*UPDDEF' then
         var_output := '<FACDFN FACCDE="'||qvi_to_xml(rcd_retrieve.qfd_fac_code||' - (Last updated by '||rcd_retrieve.qfd_upd_user||' on '||to_char(rcd_retrieve.qfd_upd_date,'yyyy/mm/dd')||')')||'"';
         var_output := var_output||' FACNAM="'||qvi_to_xml(rcd_retrieve.qfd_fac_name)||'"';
         var_output := var_output||' FACSTS="'||qvi_to_xml(rcd_retrieve.qfd_fac_status)||'"';
         var_output := var_output||' FACBLD="'||qvi_to_xml(rcd_retrieve.qfd_fac_build)||'"';
         var_output := var_output||' FACTAB="'||qvi_to_xml(rcd_retrieve.qfd_fac_table)||'"';
         var_output := var_output||' FACTYP="'||qvi_to_xml(rcd_retrieve.qfd_fac_type)||'"';
         var_output := var_output||' JOBGRP="'||qvi_to_xml(rcd_retrieve.qfd_job_group)||'"';
         var_output := var_output||' EMAGRP="'||qvi_to_xml(rcd_retrieve.qfd_ema_group)||'"';
         var_output := var_output||' POLFLG="'||qvi_to_xml(rcd_retrieve.qfd_pol_flag)||'"';
         var_output := var_output||' FLGINT="'||qvi_to_xml(rcd_retrieve.qfd_flg_iface)||'"';
         var_output := var_output||' FLGMSG="'||qvi_to_xml(rcd_retrieve.qfd_flg_mname)||'"/>';
         pipe row(qvi_xml_object(var_output));
      elsif var_action = '*CRTDEF' then
         var_output := '<FACDFN FACCDE=""';
         var_output := var_output||' FACNAM=""';
         var_output := var_output||' FACSTS="1"';
         var_output := var_output||' FACBLD=""';
         var_output := var_output||' FACTAB=""';
         var_output := var_output||' FACTYP=""';
         var_output := var_output||' JOBGRP=""';
         var_output := var_output||' EMAGRP=""';
         var_output := var_output||' POLFLG="0"';
         var_output := var_output||' FLGINT=""';
         var_output := var_output||' FLGMSG=""/>';
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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_MAINTENANCE - RETRIEVE_FACT_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_fact_data;

   /********************************************************/
   /* This procedure performs the update fact data routine */
   /********************************************************/
   procedure update_fact_data(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_qvi_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      rcd_qvi_fac_defn qvi_fac_defn%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from qvi_fac_defn t01
          where t01.qfd_das_code = rcd_qvi_fac_defn.qfd_das_code
            and t01.qfd_fac_code = rcd_qvi_fac_defn.qfd_fac_code
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
      rcd_qvi_fac_defn.qfd_das_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DASCDE')));
      rcd_qvi_fac_defn.qfd_fac_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FACCDE')));
      rcd_qvi_fac_defn.qfd_fac_name := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FACNAM'));
      rcd_qvi_fac_defn.qfd_fac_status := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FACSTS'));
      rcd_qvi_fac_defn.qfd_fac_build := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FACBLD'));
      rcd_qvi_fac_defn.qfd_fac_table := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FACTAB'));
      rcd_qvi_fac_defn.qfd_fac_type := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FACTYP'));
      rcd_qvi_fac_defn.qfd_job_group := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@JOBGRP'));
      rcd_qvi_fac_defn.qfd_ema_group := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@EMAGRP'));
      rcd_qvi_fac_defn.qfd_pol_flag := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@POLFLG'));
      rcd_qvi_fac_defn.qfd_flg_iface := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FLGINT'));
      rcd_qvi_fac_defn.qfd_flg_mname := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FLGMSG'));
      rcd_qvi_fac_defn.qfd_upd_user := upper(par_user);
      rcd_qvi_fac_defn.qfd_upd_date := sysdate;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_qvi_fac_defn.qfd_das_code is null then
         qvi_gen_function.add_mesg_data('Dashboard code must be supplied');
      end if;
      if rcd_qvi_fac_defn.qfd_fac_code is null then
         qvi_gen_function.add_mesg_data('Fact code must be supplied');
      end if;
      if rcd_qvi_fac_defn.qfd_fac_name is null then
         qvi_gen_function.add_mesg_data('Fact name must be supplied');
      end if;
      if rcd_qvi_fac_defn.qfd_fac_status is null or (rcd_qvi_fac_defn.qfd_fac_status != '0' and rcd_qvi_fac_defn.qfd_fac_status != '1') then
         qvi_gen_function.add_mesg_data('Fact status must be (0)inactive or (1)active');
      end if;
      if rcd_qvi_fac_defn.qfd_fac_build is null then
         qvi_gen_function.add_mesg_data('Fact build procedure must be supplied');
      end if;
      if rcd_qvi_fac_defn.qfd_fac_table is null then
         qvi_gen_function.add_mesg_data('Fact retrieve table function must be supplied');
      end if;
      if rcd_qvi_fac_defn.qfd_fac_type is null then
         qvi_gen_function.add_mesg_data('Fact storage type must be supplied');
      end if;
      if rcd_qvi_fac_defn.qfd_job_group is null then
         qvi_gen_function.add_mesg_data('Fact processing job group must be supplied');
      end if;
      if rcd_qvi_fac_defn.qfd_ema_group is null then
         qvi_gen_function.add_mesg_data('Fact processing email group must be supplied');
      end if;
      if rcd_qvi_fac_defn.qfd_pol_flag is null or (rcd_qvi_fac_defn.qfd_pol_flag != '0' and rcd_qvi_fac_defn.qfd_pol_flag != '1') then
         qvi_gen_function.add_mesg_data('Fact retrieval type must be (0)flag or (1)batch');
      else
         if rcd_qvi_fac_defn.qfd_pol_flag = '0' then
            if rcd_qvi_fac_defn.qfd_flg_iface is null then
               qvi_gen_function.add_mesg_data('Fact flag file interface must be supplied for retrieval type (0)flag');
            end if;
            if rcd_qvi_fac_defn.qfd_flg_mname is null then
               qvi_gen_function.add_mesg_data('Fact flag file message name must be supplied for retrieval type (0)flag');
            end if;
         else
            if not(rcd_qvi_fac_defn.qfd_flg_iface) is null then
               qvi_gen_function.add_mesg_data('Fact flag file interface must be null for retrieval type (1)batch');
            end if;
            if not(rcd_qvi_fac_defn.qfd_flg_mname) is null then
               qvi_gen_function.add_mesg_data('Fact flag file message name must be null for retrieval type (1)batch');
            end if;
         end if;
      end if;
      if rcd_qvi_fac_defn.qfd_upd_user is null then
         qvi_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the fact definition
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
               qvi_gen_function.add_mesg_data('Dashboard/Fact code ('||rcd_qvi_fac_defn.qfd_das_code||'/'||rcd_qvi_fac_defn.qfd_fac_code||') is currently locked');
         end;
         if var_found = false then
            qvi_gen_function.add_mesg_data('Dashboard/Fact code ('||rcd_qvi_fac_defn.qfd_das_code||'/'||rcd_qvi_fac_defn.qfd_fac_code||') does not exist');
         end if;
         if qvi_gen_function.get_mesg_count = 0 then
            update qvi_fac_defn
               set qfd_fac_name = rcd_qvi_fac_defn.qfd_fac_name,
                   qfd_fac_status = rcd_qvi_fac_defn.qfd_fac_status,
                   qfd_fac_build = rcd_qvi_fac_defn.qfd_fac_build,
                   qfd_fac_table = rcd_qvi_fac_defn.qfd_fac_table,
                   qfd_fac_type = rcd_qvi_fac_defn.qfd_fac_type,
                   qfd_job_group = rcd_qvi_fac_defn.qfd_job_group,
                   qfd_ema_group = rcd_qvi_fac_defn.qfd_ema_group,
                   qfd_pol_flag = rcd_qvi_fac_defn.qfd_pol_flag,
                   qfd_flg_iface = rcd_qvi_fac_defn.qfd_flg_iface,
                   qfd_flg_mname = rcd_qvi_fac_defn.qfd_flg_mname,
                   qfd_upd_user = rcd_qvi_fac_defn.qfd_upd_user,
                   qfd_upd_date = rcd_qvi_fac_defn.qfd_upd_date
             where qfd_das_code = rcd_qvi_fac_defn.qfd_das_code
               and qfd_fac_code = rcd_qvi_fac_defn.qfd_fac_code;
         end if;
      elsif var_action = '*CRTDEF' then
         var_confirm := 'created';
         begin
            insert into qvi_fac_defn values rcd_qvi_fac_defn;
         exception
            when dup_val_on_index then
               qvi_gen_function.add_mesg_data('Dashboard/Fact code ('||rcd_qvi_fac_defn.qfd_das_code||'/'||rcd_qvi_fac_defn.qfd_fac_code||') already exists - unable to create');
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
      qvi_gen_function.set_cfrm_data('Dashboard/Fact code ('||rcd_qvi_fac_defn.qfd_das_code||'/'||rcd_qvi_fac_defn.qfd_fac_code||') successfully '||var_confirm);

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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_MAINTENANCE - UPDATE_FACT_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_fact_data;

   /********************************************************/
   /* This procedure performs the delete fact data routine */
   /********************************************************/
   procedure delete_fact_data is

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
      var_fac_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from qvi_fac_defn t01
          where t01.qfd_das_code = var_das_code
            and t01.qfd_fac_code = var_fac_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_part is
         select t01.*
           from qvi_fac_part t01
          where t01.qfp_das_code = var_das_code
            and t01.qfp_fac_code = var_fac_code;
      rcd_part csr_part%rowtype;

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
      var_fac_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FACCDE')));
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the fact definition
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
            qvi_gen_function.add_mesg_data('Dashboard/Fact code ('||var_das_code||'/'||var_fac_code||') is currently locked');
      end;
      if var_found = false then
         qvi_gen_function.add_mesg_data('Dashboard/Fact code ('||var_das_code||'/'||var_fac_code||') does not exist');
      else
         var_found := false;
         open csr_part;
         fetch csr_part into rcd_part;
         if csr_part%found then
            var_found := true;
         end if;
         close csr_part;
         if var_found = true then
            qvi_gen_function.add_mesg_data('Dashboard/Fact code ('||var_das_code||'/'||var_fac_code||') has fact parts defined - unable to delete');
         end if;
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Delete the data
      /*-*/
      delete from qvi_src_data where qsd_das_code = var_das_code and qsd_fac_code = var_fac_code;
      delete from qvi_src_hedr where qsh_das_code = var_das_code and qsh_fac_code = var_fac_code;
      delete from qvi_fac_data where qfd_das_code = var_das_code and qfd_fac_code = var_fac_code;
      delete from qvi_fac_hedr where qfh_das_code = var_das_code and qfh_fac_code = var_fac_code;
      delete from qvi_fac_part where qfp_das_code = var_das_code and qfp_fac_code = var_fac_code;
      delete from qvi_fac_time where qft_das_code = var_das_code and qft_fac_code = var_fac_code;
      delete from qvi_fac_defn where qfd_das_code = var_das_code and qfd_fac_code = var_fac_code;

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
      qvi_gen_function.set_cfrm_data('Dashboard/Fact code ('||var_das_code||'/'||var_fac_code||') successfully '||var_confirm);

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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_MAINTENANCE - DELETE_FACT_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_fact_data;

   /********************************************************/
   /* This procedure performs the select part list routine */
   /********************************************************/
   function select_part_list return qvi_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_qvi_request xmlDom.domNode;
      var_das_code varchar2(32);
      var_fac_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_slct is
         select t01.qfp_par_code,
                t01.qfp_par_name,
                decode(t01.qfp_par_status,'0','Inactive','1','Active','*UNKNOWN') as qfp_par_status
           from qvi_fac_part t01
          where t01.qfp_das_code = var_das_code
            and t01.qfp_fac_code = var_fac_code
          order by t01.qfp_par_code asc;

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
      var_das_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DASCDE')));
      var_fac_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FACCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(qvi_xml_object('<?xml version="1.0" encoding="UTF-8"?><QVI_RESPONSE>'));

      /*-*/
      /* Retrieve the fact part list and pipe the results
      /*-*/
      tbl_list.delete;
      open csr_slct;
      fetch csr_slct bulk collect into tbl_list;
      close csr_slct;
      for idx in 1..tbl_list.count loop
         pipe row(qvi_xml_object('<LSTROW PARCDE="'||qvi_to_xml(tbl_list(idx).qfp_par_code)||'" PARNAM="'||qvi_to_xml(tbl_list(idx).qfp_par_name)||'" PARSTS="'||qvi_to_xml(tbl_list(idx).qfp_par_status)||'"/>'));
      end loop;

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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_MAINTENANCE - SELECT_PART_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_part_list;

   /**********************************************************/
   /* This procedure performs the retrieve part data routine */
   /**********************************************************/
   function retrieve_part_data return qvi_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_qvi_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_das_code varchar2(32);
      var_fac_code varchar2(32);
      var_par_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from qvi_fac_part t01
          where t01.qfp_das_code = var_das_code
            and t01.qfp_fac_code = var_fac_code
            and t01.qfp_par_code = var_par_code;
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
      var_fac_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FACCDE')));
      var_par_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@PARCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' then
         qvi_gen_function.add_mesg_data('Invalid request action');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing fact part when required
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
            qvi_gen_function.add_mesg_data('Dashboard/Fact/Part ('||var_das_code||'/'||var_fac_code||'/'||var_par_code||') does not exist');
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
      /* Pipe the fact XML
      /*-*/
      if var_action = '*UPDDEF' then
         var_output := '<PARDFN PARCDE="'||qvi_to_xml(rcd_retrieve.qfp_par_code||' - (Last updated by '||rcd_retrieve.qfp_upd_user||' on '||to_char(rcd_retrieve.qfp_upd_date,'yyyy/mm/dd')||')')||'"';
         var_output := var_output||' PARNAM="'||qvi_to_xml(rcd_retrieve.qfp_par_name)||'"';
         var_output := var_output||' PARSTS="'||qvi_to_xml(rcd_retrieve.qfp_par_status)||'"';
         var_output := var_output||' SRCTAB="'||qvi_to_xml(rcd_retrieve.qfp_src_table)||'"';
         var_output := var_output||' SRCTYP="'||qvi_to_xml(rcd_retrieve.qfp_src_type)||'"/>';
         pipe row(qvi_xml_object(var_output));
      elsif var_action = '*CRTDEF' then
         var_output := '<PARDFN PARCDE=""';
         var_output := var_output||' PARNAM=""';
         var_output := var_output||' PARSTS="1"';
         var_output := var_output||' SRCTAB=""';
         var_output := var_output||' SRCTYP=""/>';
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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_MAINTENANCE - RETRIEVE_PART_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_part_data;

   /********************************************************/
   /* This procedure performs the update part data routine */
   /********************************************************/
   procedure update_part_data(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_qvi_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      rcd_qvi_fac_part qvi_fac_part%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from qvi_fac_part t01
          where t01.qfp_das_code = rcd_qvi_fac_part.qfp_das_code
            and t01.qfp_fac_code = rcd_qvi_fac_part.qfp_fac_code
            and t01.qfp_par_code = rcd_qvi_fac_part.qfp_par_code
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
      rcd_qvi_fac_part.qfp_das_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DASCDE')));
      rcd_qvi_fac_part.qfp_fac_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FACCDE')));
      rcd_qvi_fac_part.qfp_par_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@PARCDE')));
      rcd_qvi_fac_part.qfp_par_name := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@PARNAM'));
      rcd_qvi_fac_part.qfp_par_status := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@PARSTS'));
      rcd_qvi_fac_part.qfp_src_table := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@SRCTAB'));
      rcd_qvi_fac_part.qfp_src_type := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@SRCTYP'));
      rcd_qvi_fac_part.qfp_upd_user := upper(par_user);
      rcd_qvi_fac_part.qfp_upd_date := sysdate;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_qvi_fac_part.qfp_das_code is null then
         qvi_gen_function.add_mesg_data('Dashboard code must be supplied');
      end if;
      if rcd_qvi_fac_part.qfp_fac_code is null then
         qvi_gen_function.add_mesg_data('Fact code must be supplied');
      end if;
      if rcd_qvi_fac_part.qfp_par_code is null then
         qvi_gen_function.add_mesg_data('Part code must be supplied');
      end if;
      if rcd_qvi_fac_part.qfp_par_name is null then
         qvi_gen_function.add_mesg_data('Part name must be supplied');
      end if;
      if rcd_qvi_fac_part.qfp_par_status is null or (rcd_qvi_fac_part.qfp_par_status != '0' and rcd_qvi_fac_part.qfp_par_status != '1') then
         qvi_gen_function.add_mesg_data('Part status must be (0)inactive or (1)active');
      end if;
      if rcd_qvi_fac_part.qfp_src_table is null then
         qvi_gen_function.add_mesg_data('Part source retrieval table function must be supplied');
      end if;
      if rcd_qvi_fac_part.qfp_src_type is null then
         qvi_gen_function.add_mesg_data('Part source storage type must be supplied');
      end if;
      if rcd_qvi_fac_part.qfp_upd_user is null then
         qvi_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the fact part
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
               qvi_gen_function.add_mesg_data('Dashboard/Fact/Part code ('||rcd_qvi_fac_part.qfp_das_code||'/'||rcd_qvi_fac_part.qfp_fac_code||'/'||rcd_qvi_fac_part.qfp_par_code||') is currently locked');
         end;
         if var_found = false then
            qvi_gen_function.add_mesg_data('Dashboard/Fact/Part code ('||rcd_qvi_fac_part.qfp_das_code||'/'||rcd_qvi_fac_part.qfp_fac_code||'/'||rcd_qvi_fac_part.qfp_par_code||') does not exist');
         end if;
         if qvi_gen_function.get_mesg_count = 0 then
            update qvi_fac_part
               set qfp_par_name = rcd_qvi_fac_part.qfp_par_name,
                   qfp_par_status = rcd_qvi_fac_part.qfp_par_status,
                   qfp_src_table = rcd_qvi_fac_part.qfp_src_table,
                   qfp_src_type = rcd_qvi_fac_part.qfp_src_type,
                   qfp_upd_user = rcd_qvi_fac_part.qfp_upd_user,
                   qfp_upd_date = rcd_qvi_fac_part.qfp_upd_date
             where qfp_das_code = rcd_qvi_fac_part.qfp_das_code
               and qfp_fac_code = rcd_qvi_fac_part.qfp_fac_code
               and qfp_par_code = rcd_qvi_fac_part.qfp_par_code;
         end if;
      elsif var_action = '*CRTDEF' then
         var_confirm := 'created';
         begin
            insert into qvi_fac_part values rcd_qvi_fac_part;
         exception
            when dup_val_on_index then
               qvi_gen_function.add_mesg_data('Dashboard/Fact/Part code ('||rcd_qvi_fac_part.qfp_das_code||'/'||rcd_qvi_fac_part.qfp_fac_code||'/'||rcd_qvi_fac_part.qfp_par_code||') already exists - unable to create');
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
      qvi_gen_function.set_cfrm_data('Dashboard/Fact/Part code ('||rcd_qvi_fac_part.qfp_das_code||'/'||rcd_qvi_fac_part.qfp_fac_code||'/'||rcd_qvi_fac_part.qfp_par_code||') successfully '||var_confirm);

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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_MAINTENANCE - UPDATE_PART_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_part_data;

   /********************************************************/
   /* This procedure performs the delete part data routine */
   /********************************************************/
   procedure delete_part_data is

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
      var_fac_code varchar2(32);
      var_par_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from qvi_fac_part t01
          where t01.qfp_das_code = var_das_code
            and t01.qfp_fac_code = var_fac_code
            and t01.qfp_par_code = var_par_code
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
      if var_action != '*DLTDEF' then
         qvi_gen_function.add_mesg_data('Invalid request action');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_das_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DASCDE')));
      var_fac_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FACCDE')));
      var_par_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@PARCDE')));
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the fact part
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
            qvi_gen_function.add_mesg_data('Dashboard/Fact code ('||var_das_code||'/'||var_fac_code||') is currently locked');
      end;
      if var_found = false then
         qvi_gen_function.add_mesg_data('Dashboard/Fact code ('||var_das_code||'/'||var_fac_code||') does not exist');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Delete the data
      /*-*/
      delete from qvi_src_data where qsd_das_code = var_das_code and qsd_fac_code = var_fac_code and qsd_par_code = var_par_code;
      delete from qvi_src_hedr where qsh_das_code = var_das_code and qsh_fac_code = var_fac_code and qsh_par_code = var_par_code;
      delete from qvi_fac_part where qfp_das_code = var_das_code and qfp_fac_code = var_fac_code and qfp_par_code = var_par_code;

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
      qvi_gen_function.set_cfrm_data('Dashboard/Fact code ('||var_das_code||'/'||var_fac_code||') successfully '||var_confirm);

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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_MAINTENANCE - DELETE_PART_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_part_data;

end qvi_das_maintenance;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qvi_das_maintenance for qv_app.qvi_das_maintenance;
grant execute on qv_app.qvi_das_maintenance to public;

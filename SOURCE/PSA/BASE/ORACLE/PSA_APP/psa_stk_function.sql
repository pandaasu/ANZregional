/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_stk_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_stk_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - Stocktake Function

    This package contain the stocktake functions and procedures.

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
   function detail_data return psa_xml_type pipelined;

end psa_stk_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_stk_function as

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
           from (select t01.sth_stk_code,
                        t01.sth_stk_name,
                        t01.sth_stk_time,
                        t01.sth_upd_user
                   from psa_stk_header t01
                  where (var_str_code is null or t01.sth_stk_code >= var_str_code)
                  order by t01.sth_stk_code desc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.sth_stk_code,
                        t01.sth_stk_name,
                        t01.sth_stk_time,
                        t01.sth_upd_user
                   from psa_stk_header t01
                  where ((var_action = '*NXTDEF' and (var_end_code is null or t01.sth_stk_code < var_end_code)) or
                         (var_action = '*PRVDEF'))
                  order by t01.sth_stk_code desc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.sth_stk_code,
                        t01.sth_stk_name,
                        t01.sth_stk_time,
                        t01.sth_upd_user
                   from psa_stk_header t01
                  where ((var_action = '*PRVDEF' and (var_str_code is null or t01.sth_stk_code > var_str_code)) or
                         (var_action = '*NXTDEF'))
                  order by t01.sth_stk_code asc) t01
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
      /* Retrieve the stocktake list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELDEF' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(psa_xml_object('<LSTROW STKCDE="'||to_char(tbl_list(idx).sth_stk_code)||'" STKNAM="'||psa_to_xml(tbl_list(idx).sth_stk_name)||'" STKTIM="'||psa_to_xml(tbl_list(idx).sth_stk_time)||'" STKUSR="'||psa_to_xml(tbl_list(idx).sth_upd_user)||'"/>'));
         end loop;
      elsif var_action = '*NXTDEF' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW STKCDE="'||to_char(tbl_list(idx).sth_stk_code)||'" STKNAM="'||psa_to_xml(tbl_list(idx).sth_stk_name)||'" STKTIM="'||psa_to_xml(tbl_list(idx).sth_stk_time)||'" STKUSR="'||psa_to_xml(tbl_list(idx).sth_upd_user)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW STKCDE="'||to_char(tbl_list(idx).sth_stk_code)||'" STKNAM="'||psa_to_xml(tbl_list(idx).sth_stk_name)||'" STKTIM="'||psa_to_xml(tbl_list(idx).sth_stk_time)||'" STKUSR="'||psa_to_xml(tbl_list(idx).sth_upd_user)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVDEF' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW STKCDE="'||to_char(tbl_list(idx).sth_stk_code)||'" STKNAM="'||psa_to_xml(tbl_list(idx).sth_stk_name)||'" STKTIM="'||psa_to_xml(tbl_list(idx).sth_stk_time)||'" STKUSR="'||psa_to_xml(tbl_list(idx).sth_upd_user)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW STKCDE="'||to_char(tbl_list(idx).sth_stk_code)||'" STKNAM="'||psa_to_xml(tbl_list(idx).sth_stk_name)||'" STKTIM="'||psa_to_xml(tbl_list(idx).sth_stk_time)||'" STKUSR="'||psa_to_xml(tbl_list(idx).sth_upd_user)||'"/>'));
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_STK_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

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

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_detail is
         select t01.*
           from psa_mat_defn t01
          where t01.mde_mat_usage in ('MPO','PCH','RLS')
            and t01.mde_mat_status in ('*ADD','*CHG','*DEL','*ACTIVE')
          order by t01.mde_mat_code asc;
      rcd_detail csr_detail%rowtype;

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
      /* Pipe the stocktake XML
      /*-*/
      var_output := '<STKHDR STKCDE="STOCKTAKE_'||psa_to_xml(to_char(sysdate,'yyyymmddhh24miss'))||'" STKNAM="" STKTIM="'||psa_to_xml(to_char(sysdate,'yyyy/mm/dd hh24:mi'))||'"/>';
      pipe row(psa_xml_object(var_output));

      /*-*/
      /* Pipe the detail data XML
      /*-*/
      open csr_detail;
      loop
         fetch csr_detail into rcd_detail;
         if csr_detail%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<STKDET MATCDE="'||psa_to_xml(rcd_detail.mde_mat_code)||'" MATNAM="'||psa_to_xml(rcd_detail.mde_mat_name)||'" MATTYP="'||psa_to_xml(rcd_detail.mde_mat_type)||'" MATUSG="'||psa_to_xml(rcd_detail.mde_mat_usage)||'" MATQTY=""/>'));
      end loop;
      close csr_detail;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_STK_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      var_det_code varchar2(32);
      var_det_qnty number;
      rcd_psa_stk_header psa_stk_header%rowtype;
      rcd_psa_stk_detail psa_stk_detail%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
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
      rcd_psa_stk_header.sth_stk_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@STKCDE'));
      rcd_psa_stk_header.sth_stk_name := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@STKNAM'));
      rcd_psa_stk_header.sth_stk_time := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@STKTIM'));
      rcd_psa_stk_header.sth_upd_user := upper(par_user);
      rcd_psa_stk_header.sth_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_psa_stk_header.sth_stk_name is null then
         psa_gen_function.add_mesg_data('Stocktake name must be supplied');
      end if;
      if rcd_psa_stk_header.sth_stk_time is null then
         psa_gen_function.add_mesg_data('Stocktake as at time must be supplied');
      else
         if psa_to_date(rcd_psa_stk_header.sth_stk_time,'yyyy/mm/dd hh24:mi') is null then
            psa_gen_function.add_mesg_data('Stocktake as at time must be supplied in format YYYY/MM/DD HH24:MI');
         end if;
      end if;
      if rcd_psa_stk_header.sth_upd_user is null then
         psa_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the stocktake details
      /*-*/
      obj_det_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/STKDET');
      for idx in 0..xmlDom.getLength(obj_det_list)-1 loop
         obj_det_node := xmlDom.item(obj_det_list,idx);
         var_det_code := psa_from_xml(xslProcessor.valueOf(obj_det_node,'@MATCDE'));
         var_det_qnty := psa_to_number(xslProcessor.valueOf(obj_det_node,'@MATQTY'));
         open csr_material;
         fetch csr_material into rcd_material;
         if csr_material%notfound then
            psa_gen_function.add_mesg_data('Material code ('||var_det_code||') does not exist');
         else
            if rcd_material.mde_mat_status != '*ADD' and rcd_material.mde_mat_status != '*CHG' and rcd_material.mde_mat_usage != '*DEL' and rcd_material.mde_mat_usage != '*ACTIVE' then
               psa_gen_function.add_mesg_data('Material code ('||var_det_code||') status must be *CHG, *DEL or *ACTIVE');
            end if;
         end if;
         close csr_material;
         if var_det_qnty is null or var_det_qnty < 0 then
            psa_gen_function.add_mesg_data('Material quantity ('||xslProcessor.valueOf(obj_det_node,'@MATQTY')||') must be a number greater than or equal to zero');
         end if;
      end loop;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the stocktake
      /*-*/
      var_confirm := 'created';
      begin
         insert into psa_stk_header values rcd_psa_stk_header;
      exception
         when dup_val_on_index then
            psa_gen_function.add_mesg_data('Stocktake ('||rcd_psa_stk_header.sth_stk_code||') already exists - unable to create');
      end;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve and insert the stocktake detail data
      /*-*/
      obj_det_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/STKDET');
      for idx in 0..xmlDom.getLength(obj_det_list)-1 loop
         obj_det_node := xmlDom.item(obj_det_list,idx);
         rcd_psa_stk_detail.std_stk_code := rcd_psa_stk_header.sth_stk_code;
         rcd_psa_stk_detail.std_mat_code := psa_from_xml(xslProcessor.valueOf(obj_det_node,'@MATCDE'));
         rcd_psa_stk_detail.std_mat_qnty := psa_to_number(xslProcessor.valueOf(obj_det_node,'@MATQTY'));
         if rcd_psa_stk_detail.std_mat_qnty > 0 then
            insert into psa_stk_detail values rcd_psa_stk_detail;
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
      psa_gen_function.set_cfrm_data('Stocktake ('||rcd_psa_stk_header.sth_stk_code||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_STK_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      var_stk_code varchar2(32);

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
      var_stk_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@STKCDE')));
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the stocktake
      /*-*/
      var_confirm := 'deleted';
      delete from psa_stk_detail where std_stk_code = var_stk_code;
      delete from psa_stk_header where sth_stk_code = var_stk_code;

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
      psa_gen_function.set_cfrm_data('Stocktake ('||var_stk_code||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_STK_FUNCTION - DELETE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_data;

   /***************************************************/
   /* This procedure performs the detail data routine */
   /***************************************************/
   function detail_data return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_output varchar2(2000 char);
      var_stk_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_stk_header t01
          where t01.sth_stk_code = var_stk_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_detail is
         select t01.*,
                nvl(t02.mde_mat_name,'*UNKNOWN') as mde_mat_name,
                nvl(t02.mde_mat_type,'*NONE') as mde_mat_type,
                nvl(t02.mde_mat_usage,'*NONE') as mde_mat_usage
           from psa_stk_detail t01,
                psa_mat_defn t02
          where t01.std_mat_code = t02.mde_mat_code(+)
            and t01.std_stk_code = var_stk_code
          order by t01.std_mat_code;
      rcd_detail csr_detail%rowtype;

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
      var_stk_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@STKCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*DETDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing stocktake
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         psa_gen_function.add_mesg_data('Stocktake ('||var_stk_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(psa_xml_object('<?xml version="1.0" encoding="UTF-8"?><PSA_RESPONSE>'));

      /*-*/
      /* Pipe the stocktake XML
      /*-*/
      var_output := '<STKHDR STKCDE="'||psa_to_xml(rcd_retrieve.sth_stk_code||' - (Created by '||rcd_retrieve.sth_upd_user||' on '||to_char(rcd_retrieve.sth_upd_date,'yyyy/mm/dd')||')')||'"';
      var_output := var_output||' STKNAM="'||psa_to_xml(rcd_retrieve.sth_stk_name)||'"';
      var_output := var_output||' STKTIM="'||psa_to_xml(rcd_retrieve.sth_stk_time)||'"/>';
      pipe row(psa_xml_object(var_output));

      /*-*/
      /* Pipe the stocktake detail data XML
      /*-*/
      open csr_detail;
      loop
         fetch csr_detail into rcd_detail;
         if csr_detail%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<STKDET MATCDE="'||psa_to_xml(rcd_detail.std_mat_code)||'" MATNAM="'||psa_to_xml(rcd_detail.mde_mat_name)||'" MATTYP="'||psa_to_xml(rcd_detail.mde_mat_type)||'" MATUSG="'||psa_to_xml(rcd_detail.mde_mat_usage)||'" MATQTY="'||psa_to_xml(to_char(rcd_detail.std_mat_qnty))||'"/>'));
      end loop;
      close csr_detail;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_STK_FUNCTION - DETAIL_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end detail_data;

end psa_stk_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_stk_function for psa_app.psa_stk_function;
grant execute on psa_app.psa_stk_function to public;
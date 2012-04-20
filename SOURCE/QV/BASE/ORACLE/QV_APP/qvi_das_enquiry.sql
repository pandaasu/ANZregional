/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_das_enquiry as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_das_enquiry
    Owner   : qv_app

    Description
    -----------
    QlikView Interfacing - Dashboard Maintenance

    This package contain the dashboard enquiry functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function select_list return qvi_xml_type pipelined;
   function select_fact_list return qvi_xml_type pipelined;
   function select_time_list return qvi_xml_type pipelined;
   function select_part_list return qvi_xml_type pipelined;

end qvi_das_enquiry;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_das_enquiry as

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
            pipe row(qvi_xml_object('<LSTROW DASCDE="'||qvi_to_xml(tbl_list(idx).qdd_das_code)||
                                          '" DASNAM="'||qvi_to_xml(tbl_list(idx).qdd_das_name)||
                                          '" DASSTS="'||qvi_to_xml(tbl_list(idx).qdd_das_status)||'"/>'));
         end loop;
      elsif var_action = '*NXTDEF' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(qvi_xml_object('<LSTROW DASCDE="'||qvi_to_xml(tbl_list(idx).qdd_das_code)||
                                             '" DASNAM="'||qvi_to_xml(tbl_list(idx).qdd_das_name)||
                                             '" DASSTS="'||qvi_to_xml(tbl_list(idx).qdd_das_status)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(qvi_xml_object('<LSTROW DASCDE="'||qvi_to_xml(tbl_list(idx).qdd_das_code)||
                                             '" DASNAM="'||qvi_to_xml(tbl_list(idx).qdd_das_name)||
                                             '" DASSTS="'||qvi_to_xml(tbl_list(idx).qdd_das_status)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVDEF' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(qvi_xml_object('<LSTROW DASCDE="'||qvi_to_xml(tbl_list(idx).qdd_das_code)||
                                             '" DASNAM="'||qvi_to_xml(tbl_list(idx).qdd_das_name)||
                                            '" DASSTS="'||qvi_to_xml(tbl_list(idx).qdd_das_status)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(qvi_xml_object('<LSTROW DASCDE="'||qvi_to_xml(tbl_list(idx).qdd_das_code)||
                                             '" DASNAM="'||qvi_to_xml(tbl_list(idx).qdd_das_name)||
                                             '" DASSTS="'||qvi_to_xml(tbl_list(idx).qdd_das_status)||'"/>'));
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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_ENQUIRY - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_list;

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
         pipe row(qvi_xml_object('<LSTROW FACCDE="'||qvi_to_xml(tbl_list(idx).qfd_fac_code)||
                                       '" FACNAM="'||qvi_to_xml(tbl_list(idx).qfd_fac_name)||
                                       '" FACSTS="'||qvi_to_xml(tbl_list(idx).qfd_fac_status)||'"/>'));
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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_ENQUIRY - SELECT_FACT_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_fact_list;

   /********************************************************/
   /* This procedure performs the select time list routine */
   /********************************************************/
   function select_time_list return qvi_xml_type pipelined is

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
         select t01.qft_tim_code,
                decode(t01.qft_tim_status,'1','Opened','2','Submitted','3','Completed','*UNKNOWN') as qft_tim_status
           from qvi_fac_time t01
          where t01.qft_das_code = var_das_code
            and t01.qft_fac_code = var_fac_code
          order by t01.qft_tim_code desc;

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
      /* Retrieve the fact time list and pipe the results
      /*-*/
      tbl_list.delete;
      open csr_slct;
      fetch csr_slct bulk collect into tbl_list;
      close csr_slct;
      for idx in 1..tbl_list.count loop
         pipe row(qvi_xml_object('<LSTROW TIMCDE="'||qvi_to_xml(tbl_list(idx).qft_tim_code)||
                                       '" TIMSTS="'||qvi_to_xml(tbl_list(idx).qft_tim_status)||'"/>'));
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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_ENQUIRY - SELECT_TIME_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_time_list;

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
      var_tim_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_slct is
         select t01.qft_par_code,
                nvl(t02.qfp_par_name,'*UNKNOWN') as qfp_par_name,
                nvl(t03.qsh_lod_status,'No Source Received') as qsh_lod_status,
                t03.qsh_str_date,
                t03.qsh_end_date
           from qvi_fac_tpar t01,
                qvi_fac_part t02,
                (select t11.qsh_par_code,
                        decode(t11.qsh_lod_status,'0','Empty','1','Loading','2','Loaded','*UNKNOWN') as qsh_lod_status,
                        decode(t11.qsh_lod_status,'0','Empty',to_char(t11.qsh_str_date, 'yyyy/mm/dd hh24:mi:ss')) as qsh_str_date,
                        decode(t11.qsh_lod_status,'0','Empty','1','In Progress',to_char(t11.qsh_end_date, 'yyyy/mm/dd hh24:mi:ss')) as qsh_end_date
                   from qvi_src_hedr t11
                  where t11.qsh_das_code = var_das_code
                    and t11.qsh_fac_code = var_fac_code
                    and t11.qsh_tim_code = var_tim_code) t03
          where t01.qft_par_code = t02.qfp_par_code(+)
            and t01.qft_par_code = t03.qsh_par_code(+)
            and t01.qft_das_code = var_das_code
            and t01.qft_fac_code = var_fac_code
            and t01.qft_tim_code = var_tim_code
          order by t01.qft_par_code asc;

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
      var_tim_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@TIMCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(qvi_xml_object('<?xml version="1.0" encoding="UTF-8"?><QVI_RESPONSE>'));

      /*-*/
      /* Retrieve the fact time part list and pipe the results
      /*-*/
      tbl_list.delete;
      open csr_slct;
      fetch csr_slct bulk collect into tbl_list;
      close csr_slct;
      for idx in 1..tbl_list.count loop
         pipe row(qvi_xml_object('<LSTROW PARCDE="'||qvi_to_xml(tbl_list(idx).qft_par_code)||
                                       '" PARNAM="'||qvi_to_xml(tbl_list(idx).qfp_par_name)||
                                       '" LODSTS="'||qvi_to_xml(tbl_list(idx).qsh_lod_status)||
                                       '" LODSTR="'||qvi_to_xml(tbl_list(idx).qsh_str_date)||
                                       '" LODEND="'||qvi_to_xml(tbl_list(idx).qsh_end_date)||'"/>'));
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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DAS_ENQUIRY - SELECT_PART_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_part_list;

end qvi_das_enquiry;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qvi_das_enquiry for qv_app.qvi_das_enquiry;
grant execute on qv_app.qvi_das_enquiry to public;

/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_psc_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_psc_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - Production Schedule Function

    This package contain the production schedule functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function select_list return psa_xml_type pipelined;
   function select_week return psa_xml_type pipelined;
   function retrieve_data return psa_xml_type pipelined;
   function retrieve_week return psa_xml_type pipelined;
   function retrieve_type return psa_xml_type pipelined;
   procedure update_week(par_user in varchar2);
   procedure delete_data;

end psa_psc_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_psc_function as

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
           from (select t01.psh_psc_code,
                        t01.psh_psc_name,
                        t01.psh_psc_status
                   from psa_psc_hedr t01
                  where (var_str_code is null or t01.psh_psc_code >= var_str_code)
                  order by t01.psh_psc_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.psh_psc_code,
                        t01.psh_psc_name,
                        t01.psh_psc_status
                   from psa_psc_hedr t01
                  where (var_action = '*NXTDEF' and (var_end_code is null or t01.psh_psc_code > var_end_code)) or
                        (var_action = '*PRVDEF')
                  order by t01.psh_psc_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.psh_psc_code,
                        t01.psh_psc_name,
                        t01.psh_psc_status
                   from psa_psc_hedr t01
                  where (var_action = '*PRVDEF' and (var_str_code is null or t01.psh_psc_code < var_str_code)) or
                        (var_action = '*NXTDEF')
                  order by t01.psh_psc_code desc) t01
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
      /* Retrieve the production schedule list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELDEF' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(psa_xml_object('<LSTROW PSCCDE="'||to_char(tbl_list(idx).psh_psc_code)||'" PSCNAM="'||psa_to_xml(tbl_list(idx).psh_psc_name)||'" PSCSTS="'||psa_to_xml(tbl_list(idx).psh_psc_status)||'"/>'));
         end loop;
      elsif var_action = '*NXTDEF' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW PSCCDE="'||to_char(tbl_list(idx).psh_psc_code)||'" PSCNAM="'||psa_to_xml(tbl_list(idx).psh_psc_name)||'" PSCSTS="'||psa_to_xml(tbl_list(idx).psh_psc_status)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW PSCCDE="'||to_char(tbl_list(idx).psh_psc_code)||'" PSCNAM="'||psa_to_xml(tbl_list(idx).psh_psc_name)||'" PSCSTS="'||psa_to_xml(tbl_list(idx).psh_psc_status)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVDEF' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW PSCCDE="'||to_char(tbl_list(idx).psh_psc_code)||'" PSCNAM="'||psa_to_xml(tbl_list(idx).psh_psc_name)||'" PSCSTS="'||psa_to_xml(tbl_list(idx).psh_psc_status)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW PSCCDE="'||to_char(tbl_list(idx).psh_psc_code)||'" PSCNAM="'||psa_to_xml(tbl_list(idx).psh_psc_name)||'" PSCSTS="'||psa_to_xml(tbl_list(idx).psh_psc_status)||'"/>'));
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_list;

   /***************************************************/
   /* This procedure performs the select week routine */
   /***************************************************/
   function select_week return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_psc_code varchar2(32);
      var_output varchar2(2000 char);
      var_sltsts varchar2(1);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_week_now is
         select max(t01.mars_week) as mars_week
           from mars_date t01
          where t01.mars_week = (select mars_week from mars_date where trunc(calendar_date) = trunc(sysdate));
      rcd_week_now csr_week_now%rowtype;

      cursor csr_week is
         select t01.*
           from psa_psc_week t01
          where t01.psw_psc_code = var_psc_code
          order by t01.psw_psc_week desc;
      rcd_week csr_week%rowtype;

      cursor csr_prod is
         select t01.*,
                t02.pty_prd_name
           from psa_psc_prod t01,
                psa_prd_type t02
          where t01.psp_prd_type = t02.pty_prd_type
            and t01.psp_psc_code = rcd_week.psw_psc_code
            and t01.psp_psc_week = rcd_week.psw_psc_week
          order by decode(t01.psp_prd_type,'*FILL',1,'*PACK',2,'*FORM',3) asc;
      rcd_prod csr_prod%rowtype;

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
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*WEKLST' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the current MARS week
      /*-*/
      open csr_week_now;
      fetch csr_week_now into rcd_week_now;
      if csr_week_now%notfound or rcd_week_now.mars_week is null then
         psa_gen_function.add_mesg_data('Current MARS week does not exist');
      end if;
      close csr_week_now;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(psa_xml_object('<?xml version="1.0" encoding="UTF-8"?><PSA_RESPONSE>'));

      /*-*/
      /* Retrieve the production schedule weeks and pipe the results
      /*-*/
      open csr_week;
      loop
         fetch csr_week into rcd_week;
         if csr_week%notfound then
            exit;
         end if;

         /*-*/
         /* Set the selection status
         /*-*/
         var_sltsts := '1';
         if rcd_week.psw_psc_week < to_char(rcd_week_now.mars_week,'fm0000000') then
            var_sltsts := '0';
         end if;

         /*-*/
         /* Pipe the production schedule week types
         /*-*/
         pipe row(psa_xml_object('<LSTROW SLTTYP="'||psa_to_xml('*WEEK')||'"'||
                                        ' SLTCDE="'||psa_to_xml(rcd_week.psw_psc_week)||'"'||
                                        ' SLTTXT="'||psa_to_xml('Y'||substr(rcd_week.psw_psc_week,1,4)||' P'||substr(rcd_week.psw_psc_week,5,2)||' W'||substr(rcd_week.psw_psc_week,7,1))||'"'||
                                        ' SLTUPD="'||psa_to_xml('Last updated by '||rcd_week.psw_upd_user||' on '||to_char(rcd_week.psw_upd_date,'yyyy/mm/dd'))||'"'||
                                        ' SLTSTS="'||psa_to_xml(var_sltsts)||'"/>'));

         /*-*/
         /* Retrieve the production schedule week types and pipe the results
         /*-*/
         open csr_prod;
         loop
            fetch csr_prod into rcd_prod;
            if csr_prod%notfound then
               exit;
            end if;
            pipe row(psa_xml_object('<LSTROW SLTTYP="'||psa_to_xml('*TYPE')||'"'||
                                           ' SLTWEK="'||psa_to_xml(rcd_week.psw_psc_week)||'"'||
                                           ' SLTCDE="'||psa_to_xml(rcd_prod.psp_prd_type)||'"'||
                                           ' SLTTXT="'||psa_to_xml(rcd_prod.pty_prd_name)||'"'||
                                           ' SLTUPD="'||psa_to_xml('Last updated by '||rcd_prod.psp_upd_user||' on '||to_char(rcd_prod.psp_upd_date,'yyyy/mm/dd'))||'"'||
                                           ' SLTSTS="'||psa_to_xml(var_sltsts)||'"/>'));
         end loop;
         close csr_prod;

      end loop;
      close csr_week;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - SELECT_WEEK - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_week;

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
      var_psc_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = var_psc_code;
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
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' and var_action != '*CPYDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing production schedule when required
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
            psa_gen_function.add_mesg_data('Production Schedule ('||var_psc_code||') does not exist');
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
      /* Pipe the production schedule XML
      /*-*/
      if var_action = '*UPDDEF' then
         var_output := '<PSCDFN PSCCDE="'||psa_to_xml(rcd_retrieve.psh_psc_code||' - (Last updated by '||rcd_retrieve.psh_upd_user||' on '||to_char(rcd_retrieve.psh_upd_date,'yyyy/mm/dd')||')')||'"';
         var_output := var_output||' PSCNAM="'||psa_to_xml(rcd_retrieve.psh_psc_name)||'"';
         var_output := var_output||' PSCSTS="'||psa_to_xml(rcd_retrieve.psh_psc_status)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CPYDEF' then
         var_output := '<PSCDFN PSCCDE=""';
         var_output := var_output||' PSCNAM="'||psa_to_xml(rcd_retrieve.psh_psc_name)||'"';
         var_output := var_output||' PSCSTS="'||psa_to_xml(rcd_retrieve.psh_psc_status)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CRTDEF' then
         var_output := '<PSCDFN PSCCDE=""';
         var_output := var_output||' PSCNAM=""';
         var_output := var_output||' PSCSTS="*WORK"/>';
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_data;

   /*****************************************************/
   /* This procedure performs the retrieve week routine */
   /*****************************************************/
   function retrieve_week return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_output varchar2(2000 char);
      var_mars_week number;
      var_req_code varchar2(32);
      var_wrk_code varchar2(32);
      var_fil_name varchar2(800);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = var_psc_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_week_now is
         select max(t01.mars_week) as mars_week
           from mars_date t01
          where t01.mars_week = (select mars_week from mars_date where trunc(calendar_date) = trunc(sysdate));
      rcd_week_now csr_week_now%rowtype;

      cursor csr_week_max is
         select max(t01.psw_psc_week) as psw_psc_week
           from psa_psc_week t01
          where t01.psw_psc_code = var_psc_code;
      rcd_week_max csr_week_max%rowtype;

      cursor csr_week_nxt is
         select min(t01.mars_week) as mars_week
           from mars_date t01
          where t01.mars_week > var_mars_week;
      rcd_week_nxt csr_week_nxt%rowtype;

      cursor csr_week_new is
         select min(t01.mars_week) as mars_week
           from mars_date t01
          where t01.mars_week = (select mars_week from mars_date where trunc(calendar_date) = trunc(sysdate));
      rcd_week_new csr_week_new%rowtype;

      cursor csr_week_old is
         select t01.psw_psc_week,
                t01.psw_req_code,
                t01.psw_upd_user,
                t01.psw_upd_date
           from psa_psc_week t01
          where t01.psw_psc_code = var_psc_code
            and t01.psw_psc_week = var_wek_code;
      rcd_week_old csr_week_old%rowtype;

      cursor csr_week is
         select to_char(t01.mars_week,'fm0000000') as wek_code,
                'Y'||substr(to_char(t01.mars_week,'fm0000000'),1,4)||' P'||substr(to_char(t01.mars_week,'fm0000000'),5,2)||' W'||substr(to_char(t01.mars_week,'fm0000000'),7,1) as wek_name,
                to_char(t01.calendar_date,'yyyy/mm/dd') as day_code,
                to_char(t01.calendar_date,'dy') as day_name
           from mars_date t01
          where t01.mars_week = var_mars_week
          order by t01.calendar_date asc;
      rcd_week csr_week%rowtype;

      cursor csr_preq is
         select t01.rhe_req_code,
                t01.rhe_req_name
           from psa_req_header t01
          where t01.rhe_req_status = '*LOADED'
            and t01.rhe_str_week = to_char(var_mars_week,'fm0000000')
          order by t01.rhe_req_code asc;
      rcd_preq csr_preq%rowtype;

      cursor csr_smod is
         select t01.smd_smo_code,
                t01.smd_smo_name,
                t03.sde_shf_code,
                t03.sde_shf_name,
                to_char(t03.sde_shf_start,'fm9990') as sde_shf_start,
                to_char(t03.sde_shf_duration) as sde_shf_duration
           from psa_smo_defn t01,
                psa_smo_shift t02,
                psa_shf_defn t03
          where t01.smd_smo_code = t02.sms_smo_code
            and t02.sms_shf_code = t03.sde_shf_code
            and t01.smd_smo_status = '1'
          order by t01.smd_smo_code asc,
                   t02.sms_smo_seqn asc;
      rcd_smod csr_smod%rowtype;

      cursor csr_ptyp is
         select t01.pty_prd_type,
                t01.pty_prd_name,
                nvl((select '1' from psa_psc_prod where psp_psc_code = var_psc_code and psp_psc_week = to_char(var_mars_week,'fm0000000') and psp_prd_type = t01.pty_prd_type),'0') as pty_used
           from psa_prd_type t01
          where t01.pty_prd_status = '1'
            and t01.pty_prd_type in ('*FILL','*PACK','*FORM')
          order by decode(t01.pty_prd_type,'*FILL',1,'*PACK',2,'*FORM',3) asc;
      rcd_ptyp csr_ptyp%rowtype;

      cursor csr_cmod is
         select t01.cmd_cmo_code,
                t01.cmd_cmo_name
           from psa_cmo_defn t01
          where t01.cmd_cmo_status = '1'
            and t01.cmd_prd_type = rcd_ptyp.pty_prd_type
          order by t01.cmd_cmo_code asc;
      rcd_cmod csr_cmod%rowtype;

      cursor csr_lcon is
         select t01.lde_lin_code,
                t01.lde_lin_name,
                t02.lco_con_code,
                t02.lco_con_name,
                nvl((select psl_smo_code from psa_psc_line where psl_psc_code = var_psc_code and psl_psc_week = to_char(var_mars_week,'fm0000000') and psl_prd_type = t01.lde_prd_type and psl_lin_code = t01.lde_lin_code and psl_con_code = t02.lco_con_code),'*NONE') as smo_code
           from psa_lin_defn t01,
                psa_lin_config t02
          where t01.lde_lin_code = t02.lco_lin_code
            and t01.lde_lin_status = '1'
            and t01.lde_prd_type = rcd_ptyp.pty_prd_type
            and t02.lco_con_status = '1'
          order by t01.lde_lin_code asc,
                   t02.lco_con_code asc;
      rcd_lcon csr_lcon%rowtype;

      cursor csr_shft is
         select to_char(t01.sms_smo_seqn) as sms_smo_seqn,
                nvl((select pss_cmo_code from psa_psc_shft where pss_psc_code = var_psc_code and pss_psc_week = to_char(var_mars_week,'fm0000000') and pss_prd_type = rcd_ptyp.pty_prd_type and pss_lin_code = rcd_lcon.lde_lin_code and pss_con_code = rcd_lcon.lco_con_code and pss_smo_seqn = t01.sms_smo_seqn and pss_shf_code = t01.sms_shf_code),'*NONE') as pss_cmo_code
           from psa_smo_shift t01
          where t01.sms_smo_code = rcd_lcon.smo_code
          order by t01.sms_smo_seqn asc;
      rcd_shft csr_shft%rowtype;

      cursor csr_fill is
         select t01.lfi_fil_code
           from psa_lin_filler t01
          where t01.lfi_lin_code = rcd_lcon.lde_lin_code
            and t01.lfi_con_code = rcd_lcon.lco_con_code
          order by t01.lfi_fil_code asc;

      /*-*/
      /* Local arrays
      /*-*/
      type typ_fill is table of csr_fill%rowtype index by binary_integer;
      tbl_fill typ_fill;

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
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*CRTWEK' and var_action != '*UPDWEK' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing production schedule
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production Schedule ('||var_psc_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the current MARS week
      /*-*/
      open csr_week_now;
      fetch csr_week_now into rcd_week_now;
      if csr_week_now%notfound or rcd_week_now.mars_week is null then
         psa_gen_function.add_mesg_data('Current MARS week does not exist');
      end if;
      close csr_week_now;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the week data as required
      /*-*/
      if var_action = '*CRTWEK' then
         open csr_week_max;
         fetch csr_week_max into rcd_week_max;
         if csr_week_max%found then
            if not(rcd_week_max.psw_psc_week is null) then
               var_mars_week := to_number(rcd_week_max.psw_psc_week);
               open csr_week_nxt;
               fetch csr_week_nxt into rcd_week_nxt;
               if csr_week_nxt%notfound or rcd_week_nxt.mars_week is null then
                  psa_gen_function.add_mesg_data('Production Schedule ('||var_psc_code||') future MARS week does not exist');
               else
                  var_mars_week := rcd_week_nxt.mars_week;
               end if;
               close csr_week_nxt;
            else
               open csr_week_new;
               fetch csr_week_new into rcd_week_new;
               if csr_week_new%notfound or rcd_week_new.mars_week is null then
                  psa_gen_function.add_mesg_data('Production Schedule ('||var_psc_code||') future MARS week does not exist');
               else
                  var_mars_week := rcd_week_new.mars_week;
               end if;
               close csr_week_new;
            end if;
         end if;
         close csr_week_max;
         var_req_code := '*NONE';
      else
         open csr_week_old;
         fetch csr_week_old into rcd_week_old;
         if csr_week_old%notfound then
            psa_gen_function.add_mesg_data('Production Schedule ('||var_psc_code||') MARS week ('||var_wek_code||') does not exist');
         else
            var_mars_week := to_number(rcd_week_old.psw_psc_week);
            var_req_code := rcd_week_old.psw_req_code;
         end if;
         close csr_week_old;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
   ----   if var_mars_week < rcd_week_now.mars_week then
   ----      psa_gen_function.add_mesg_data('Production Schedule ('||var_psc_code||') MARS week ('||to_char(var_mars_week,'fm0000000')||') is in the past - unable to update');
   ----   end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(psa_xml_object('<?xml version="1.0" encoding="UTF-8"?><PSA_RESPONSE>'));

      /*-*/
      /* Pipe the week data XML
      /*-*/
      var_wek_code := '*NULL';
      open csr_week;
      loop
         fetch csr_week into rcd_week;
         if csr_week%notfound then
            exit;
         end if;
         if rcd_week.wek_code != var_wek_code then
            var_wek_code := rcd_week.wek_code;
            pipe row(psa_xml_object('<WEKDFN WEKCDE="'||psa_to_xml(rcd_week.wek_code)||'"'||
                                           ' WEKNAM="'||psa_to_xml(rcd_week.wek_name)||'"'||
                                           ' REQCDE="'||psa_to_xml(var_req_code)||'"/>'));
         end if;
         pipe row(psa_xml_object('<DAYDFN DAYCDE="'||psa_to_xml(rcd_week.day_code)||'"'||
                                        ' DAYNAM="'||psa_to_xml(rcd_week.day_name)||'"/>'));
      end loop;
      close csr_week;

      /*-*/
      /* Pipe the production requirements data XML
      /*-*/
      open csr_preq;
      loop
         fetch csr_preq into rcd_preq;
         if csr_preq%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<REQDFN REQCDE="'||psa_to_xml(rcd_preq.rhe_req_code)||'"'||
                                        ' REQNAM="'||psa_to_xml(rcd_preq.rhe_req_name)||'"/>'));
      end loop;
      close csr_preq;

      /*-*/
      /* Pipe the shift model data XML
      /*-*/
      var_wrk_code := '*NULL';
      open csr_smod;
      loop
         fetch csr_smod into rcd_smod;
         if csr_smod%notfound then
            exit;
         end if;
         if rcd_smod.smd_smo_code != var_wrk_code then
            var_wrk_code := rcd_smod.smd_smo_code;
            pipe row(psa_xml_object('<SMODFN SMOCDE="'||psa_to_xml(rcd_smod.smd_smo_code)||'"'||
                                           ' SMONAM="'||psa_to_xml(rcd_smod.smd_smo_name)||'"/>'));
         end if;
         pipe row(psa_xml_object('<SHFDFN SHFCDE="'||psa_to_xml(rcd_smod.sde_shf_code)||'"'||
                                        ' SHFNAM="'||psa_to_xml(rcd_smod.sde_shf_name)||'"'||
                                        ' SHFSTR="'||psa_to_xml(rcd_smod.sde_shf_start)||'"'||
                                        ' SHFDUR="'||psa_to_xml(rcd_smod.sde_shf_duration)||'"/>'));
      end loop;
      close csr_smod;

      /*-*/
      /* Pipe the production type data XML
      /*-*/
      open csr_ptyp;
      loop
         fetch csr_ptyp into rcd_ptyp;
         if csr_ptyp%notfound then
            exit;
         end if;

         /*-*/
         /* Pipe the production type data XML
         /*-*/
         pipe row(psa_xml_object('<PTYDFN PTYCDE="'||psa_to_xml(rcd_ptyp.pty_prd_type)||'"'||
                                        ' PTYNAM="'||psa_to_xml(rcd_ptyp.pty_prd_name)||'"'||
                                        ' PTYUSD="'||psa_to_xml(rcd_ptyp.pty_used)||'"/>'));

         /*-*/
         /* Pipe the crew model data XML
         /*-*/
         open csr_cmod;
         loop
            fetch csr_cmod into rcd_cmod;
            if csr_cmod%notfound then
               exit;
            end if;
            pipe row(psa_xml_object('<CMODFN CMOCDE="'||psa_to_xml(rcd_cmod.cmd_cmo_code)||'"'||
                                           ' CMONAM="'||psa_to_xml(rcd_cmod.cmd_cmo_name)||'"/>'));
         end loop;
         close csr_cmod;

         /*-*/
         /* Pipe the line configuration data XML
         /*-*/
         open csr_lcon;
         loop
            fetch csr_lcon into rcd_lcon;
            if csr_lcon%notfound then
               exit;
            end if;

            /*-*/
            /* Retrieve the line configuration filler name
            /*-*/
            var_fil_name := null;
            tbl_fill.delete;
            open csr_fill;
            fetch csr_fill bulk collect into tbl_fill;
            close csr_fill;
            for idx in 1..tbl_fill.count loop
               if var_fil_name is null then
                  var_fil_name := '(';
               else
                  var_fil_name := var_fil_name||',';
               end if;
               var_fil_name := var_fil_name||tbl_fill(idx).lfi_fil_code;
            end loop;
            if not(var_fil_name is null) then
               var_fil_name := var_fil_name||')';
            end if;

            /*-*/
            /* Pipe the line configuration data XML
            /*-*/
            pipe row(psa_xml_object('<LCODFN LINCDE="'||psa_to_xml(rcd_lcon.lde_lin_code)||'"'||
                                           ' LINNAM="'||psa_to_xml(rcd_lcon.lde_lin_name)||'"'||
                                           ' LCOCDE="'||psa_to_xml(rcd_lcon.lco_con_code)||'"'||
                                           ' LCONAM="'||psa_to_xml(rcd_lcon.lco_con_name)||'"'||
                                           ' SMOCDE="'||psa_to_xml(rcd_lcon.smo_code)||'"'||
                                           ' FILNAM="'||psa_to_xml(var_fil_name)||'"/>'));

            /*-*/
            /* Pipe the shift link data XML when required
            /*-*/
            if rcd_lcon.smo_code != '*NONE' then
               open csr_shft;
               loop
                  fetch csr_shft into rcd_shft;
                  if csr_shft%notfound then
                     exit;
                  end if;
                  pipe row(psa_xml_object('<SHFLNK SMOSEQ="'||psa_to_xml(rcd_shft.sms_smo_seqn)||'"'||
                                                 ' CMOCDE="'||psa_to_xml(rcd_shft.pss_cmo_code)||'"/>'));
               end loop;
               close csr_shft;
            end if;

         end loop;
         close csr_lcon;

      end loop;
      close csr_ptyp;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - RETRIEVE_WEEK - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_week;

   /*****************************************************/
   /* This procedure performs the retrieve type routine */
   /*****************************************************/
   function retrieve_type return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_pty_code varchar2(32);
      var_output varchar2(2000 char);
      var_fil_name varchar2(800);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                nvl(t02.pty_prd_name,'*UNKNOWN') as pty_prd_name
           from psa_psc_prod t01,
                psa_prd_type t02
          where t01.psp_prd_type = t02.pty_prd_type(+)
            and t01.psp_psc_code = var_psc_code
            and t01.psp_psc_week = var_wek_code
            and t01.psp_prd_type = var_pty_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_date is
         select to_char(t01.psd_day_date,'yyyy/mm/dd') as psd_day_date,
                t01.psd_day_name as psd_day_name
           from psa_psc_date t01
          where t01.psd_psc_code = rcd_retrieve.psp_psc_code
            and t01.psd_psc_week = rcd_retrieve.psp_psc_week
          order by t01.psd_day_date asc;
      rcd_date csr_date%rowtype;

      cursor csr_line is
         select t01.psl_lin_code,
                nvl(t02.lde_lin_name,'*UNKNOWN') as lde_lin_name,
                t01.psl_con_code,
                nvl(t03.lco_con_name,'*UNKNOWN') as lco_con_name
           from psa_psc_line t01,
                psa_lin_defn t02,
                psa_lin_config t03
          where t01.psl_lin_code = t02.lde_lin_code(+)
            and t01.psl_lin_code = t03.lco_lin_code(+)
            and t01.psl_con_code = t03.lco_con_code(+)
            and t01.psl_psc_code = rcd_retrieve.psp_psc_code
            and t01.psl_psc_week = rcd_retrieve.psp_psc_week
            and t01.psl_prd_type = rcd_retrieve.psp_prd_type
          order by t01.psl_lin_code asc,
                   t01.psl_con_code asc;
      rcd_line csr_line%rowtype;

      cursor csr_shft is
         select to_char(t01.pss_smo_seqn) as pss_smo_seqn,
                t01.pss_shf_code,
                nvl(t02.sde_shf_name,'*UNKNOWN') as sde_shf_name,
                to_char(t01.pss_shf_date,'yyyy/mm/dd') as pss_shf_date,
                to_char(t01.pss_shf_start,'fm9990') as pss_shf_start,
                to_char(t01.pss_shf_duration) as pss_shf_duration,
                t01.pss_cmo_code,
                t01.pss_win_flag,
                to_char(t01.pss_str_bar) as pss_str_bar,
                to_char(t01.pss_end_bar) as pss_end_bar
           from psa_psc_shft t01,
                psa_shf_defn t02
          where t01.pss_shf_code = t02.sde_shf_code(+)
            and t01.pss_psc_code = rcd_retrieve.psp_psc_code
            and t01.pss_psc_week = rcd_retrieve.psp_psc_week
            and t01.pss_prd_type = rcd_retrieve.psp_prd_type
            and t01.pss_lin_code = rcd_line.psl_lin_code
            and t01.pss_con_code = rcd_line.psl_con_code
          order by t01.pss_smo_seqn asc;
      rcd_shft csr_shft%rowtype;

      cursor csr_fill is
         select t01.lfi_fil_code
           from psa_lin_filler t01
          where t01.lfi_lin_code = rcd_line.psl_lin_code
            and t01.lfi_con_code = rcd_line.psl_con_code
          order by t01.lfi_fil_code asc;

      /*-*/
      /* Local arrays
      /*-*/
      type typ_fill is table of csr_fill%rowtype index by binary_integer;
      tbl_fill typ_fill;

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
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      var_pty_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*GETTYP' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing production schedule
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production schedule week production type ('||var_psc_code||' / '||var_wek_code||' / '||var_pty_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(psa_xml_object('<?xml version="1.0" encoding="UTF-8"?><PSA_RESPONSE>'));

      /*-*/
      /* Pipe the production type data XML
      /*-*/
      pipe row(psa_xml_object('<PTYDFN PTYCDE="'||psa_to_xml(rcd_retrieve.psp_prd_type)||'"'||
                                     ' PTYNAM="'||psa_to_xml(rcd_retrieve.pty_prd_name)||'"'||
                                     ' WEKNAM="'||psa_to_xml('Y'||substr(var_wek_code,1,4)||' P'||substr(var_wek_code,5,2)||' W'||substr(var_wek_code,7,1))||'"/>'));

      /*-*/
      /* Pipe the date data XML
      /*-*/
      open csr_date;
      loop
         fetch csr_date into rcd_date;
         if csr_date%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<DAYDFN DAYCDE="'||psa_to_xml(rcd_date.psd_day_date)||'"'||
                                        ' DAYNAM="'||psa_to_xml(rcd_date.psd_day_name)||'"/>'));
      end loop;
      close csr_date;

      /*-*/
      /* Pipe the line configuration data XML
      /*-*/
      open csr_line;
      loop
         fetch csr_line into rcd_line;
         if csr_line%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve the line configuration filler name
         /*-*/
         var_fil_name := null;
         tbl_fill.delete;
         open csr_fill;
         fetch csr_fill bulk collect into tbl_fill;
         close csr_fill;
         for idx in 1..tbl_fill.count loop
            if var_fil_name is null then
               var_fil_name := '(';
            else
               var_fil_name := var_fil_name||',';
            end if;
            var_fil_name := var_fil_name||tbl_fill(idx).lfi_fil_code;
         end loop;
         if not(var_fil_name is null) then
            var_fil_name := var_fil_name||')';
         end if;

         /*-*/
         /* Pipe the line configuration data XML
         /*-*/
         pipe row(psa_xml_object('<LINDFN LINCDE="'||psa_to_xml(rcd_line.psl_lin_code)||'"'||
                                        ' LINNAM="'||psa_to_xml(rcd_line.lde_lin_name)||'"'||
                                        ' LCOCDE="'||psa_to_xml(rcd_line.psl_con_code)||'"'||
                                        ' LCONAM="'||psa_to_xml(rcd_line.lco_con_name)||'"'||
                                        ' FILNAM="'||psa_to_xml(var_fil_name)||'"/>'));

         /*-*/
         /* Pipe the shift data XML when required
         /*-*/
         open csr_shft;
         loop
            fetch csr_shft into rcd_shft;
            if csr_shft%notfound then
               exit;
            end if;
            pipe row(psa_xml_object('<SHFDFN SMOSEQ="'||psa_to_xml(rcd_shft.pss_smo_seqn)||'"'||
                                           ' SHFCDE="'||psa_to_xml(rcd_shft.pss_shf_code)||'"'||
                                           ' SHFNAM="'||psa_to_xml(rcd_shft.sde_shf_name)||'"'||
                                           ' SHFDTE="'||psa_to_xml(rcd_shft.pss_shf_date)||'"'||
                                           ' SHFSTR="'||psa_to_xml(rcd_shft.pss_shf_start)||'"'||
                                           ' SHFDUR="'||psa_to_xml(rcd_shft.pss_shf_duration)||'"'||
                                           ' CMOCDE="'||psa_to_xml(rcd_shft.pss_cmo_code)||'"'||
                                           ' WINFLG="'||psa_to_xml(rcd_shft.pss_win_flag)||'"'||
                                           ' STRBAR="'||psa_to_xml(rcd_shft.pss_str_bar)||'"'||
                                           ' ENDBAR="'||psa_to_xml(rcd_shft.pss_end_bar)||'"/>'));
         end loop;
         close csr_shft;

      end loop;
      close csr_line;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - RETRIEVE_TYPE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_type;

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
      rcd_psa_psc_hedr psa_psc_hedr%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = rcd_psa_psc_hedr.psh_psc_code
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
      rcd_psa_psc_hedr.psh_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      rcd_psa_psc_hedr.psh_psc_name := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCNAM'));
      rcd_psa_psc_hedr.psh_psc_status := '*ACTIVE';
      rcd_psa_psc_hedr.psh_upd_user := upper(par_user);
      rcd_psa_psc_hedr.psh_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_psa_psc_hedr.psh_psc_code is null then
         psa_gen_function.add_mesg_data('Production schedule code must be supplied');
      end if;
      if rcd_psa_psc_hedr.psh_psc_name is null then
         psa_gen_function.add_mesg_data('Schedule activity name must be supplied');
      end if;
      if rcd_psa_psc_hedr.psh_upd_user is null then
         psa_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the production schedule definition
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
               psa_gen_function.add_mesg_data('Production schedule code ('||rcd_psa_psc_hedr.psh_psc_code||') is currently locked');
         end;
         if var_found = false then
            psa_gen_function.add_mesg_data('Production schedule code ('||rcd_psa_psc_hedr.psh_psc_code||') does not exist');
         end if;
         if psa_gen_function.get_mesg_count = 0 then
            update psa_psc_hedr
               set psh_psc_name = rcd_psa_psc_hedr.psh_psc_name,
                   psh_psc_status = rcd_psa_psc_hedr.psh_psc_status,
                   psh_upd_user = rcd_psa_psc_hedr.psh_upd_user,
                   psh_upd_date = rcd_psa_psc_hedr.psh_upd_date
             where psh_psc_code = rcd_psa_psc_hedr.psh_psc_code;
         end if;
      elsif var_action = '*CRTDEF' then
         var_confirm := 'created';
         begin
            insert into psa_psc_hedr values rcd_psa_psc_hedr;
         exception
            when dup_val_on_index then
               psa_gen_function.add_mesg_data('Production schedule code ('||rcd_psa_psc_hedr.psh_psc_code||') already exists - unable to create');
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
      psa_gen_function.set_cfrm_data('Production schedule ('||rcd_psa_psc_hedr.psh_psc_code||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

   /***************************************************/
   /* This procedure performs the update week routine */
   /***************************************************/
   procedure update_week(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      obj_pty_list xmlDom.domNodeList;
      obj_pty_node xmlDom.domNode;
      obj_lco_list xmlDom.domNodeList;
      obj_lco_node xmlDom.domNode;
      obj_shf_list xmlDom.domNodeList;
      obj_shf_node xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      var_pty_code varchar2(32);
      var_shf_code varchar2(32);
      var_cmo_code varchar2(32);
      var_lin_code varchar2(32);
      var_con_code varchar2(32);
      var_smo_code varchar2(32);
      var_win_code varchar2(32);
      var_mat_code varchar2(32);
      var_day_indx integer;
      var_sav_date date;
      var_day_date date;
      var_wrk_date date;
      var_bar_numb integer;
      rcd_psa_psc_week psa_psc_week%rowtype;
      rcd_psa_psc_date psa_psc_date%rowtype;
      rcd_psa_psc_prod psa_psc_prod%rowtype;
      rcd_psa_psc_line psa_psc_line%rowtype;
      rcd_psa_psc_shft psa_psc_shft%rowtype;
      rcd_psa_psc_reso psa_psc_reso%rowtype;
      rcd_psa_psc_actv psa_psc_actv%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_week t01
          where t01.psw_psc_code = rcd_psa_psc_week.psw_psc_code
            and t01.psw_psc_week = rcd_psa_psc_week.psw_psc_week
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_reqh is
         select t01.*
           from psa_req_header t01
          where t01.rhe_req_code = rcd_psa_psc_week.psw_req_code;
      rcd_reqh csr_reqh%rowtype;

      cursor csr_ptyp is
         select t01.*
           from psa_prd_type t01
          where t01.pty_prd_type = var_pty_code;
      rcd_ptyp csr_ptyp%rowtype;

      cursor csr_smod is
         select t01.*
           from psa_smo_defn t01
          where t01.smd_smo_code = var_smo_code;
      rcd_smod csr_smod%rowtype;

      cursor csr_cmod is
         select t01.*
           from psa_cmo_defn t01
          where t01.cmd_cmo_code = var_cmo_code;
      rcd_cmod csr_cmod%rowtype;

      cursor csr_lcon is
         select t01.*
           from psa_lin_config t01
          where t01.lco_lin_code = var_lin_code
            and t01.lco_con_code = var_con_code;
      rcd_lcon csr_lcon%rowtype;

      cursor csr_reso is
         select t01.*
           from psa_cmo_resource t01
          where t01.cmr_cmo_code = rcd_psa_psc_shft.pss_cmo_code
          order by t01.cmr_res_code asc;
      rcd_reso csr_reso%rowtype;

      cursor csr_date is
         select t01.calendar_date as day_date,
                to_char(t01.calendar_date,'dy') as day_name
           from mars_date t01
          where t01.mars_week >= to_number(rcd_psa_psc_week.psw_psc_week)
          order by t01.calendar_date asc;
      rcd_date csr_date%rowtype;

      cursor csr_reqd is
         select t01.*,
                t02.mde_mat_code,
                t02.mde_mat_name,
                t02.mde_mat_type,
                t02.mde_mat_usage,
                t02.mde_mat_uom,
                t02.mde_gro_weight,
                t02.mde_net_weight,
                t02.mde_unt_case,
                t03.mpr_prd_type,
                t03.mpr_sch_priority,
                t03.mpr_cas_pallet,
                t03.mpr_bch_quantity,
                t03.mpr_yld_percent,
                t03.mpr_yld_value,
                t03.mpr_pck_percent,
                t03.mpr_pck_weight,
                t03.mpr_bch_weight
           from psa_req_detail t01,
                psa_mat_defn t02,
                psa_mat_prod t03
          where t01.rde_mat_code = t02.mde_mat_code
            and t02.mde_mat_code = t03.mpr_mat_code
            and t01.rde_req_code = rcd_psa_psc_week.psw_req_code
            and t01.rde_mat_emsg is null
          order by t02.mde_mat_code asc,
                   t03.mpr_prd_type asc;
      rcd_reqd csr_reqd%rowtype;

      cursor csr_pact is
         select t01.*
           from psa_psc_actv t01
          where t01.psa_psc_code = rcd_psa_psc_week.psw_psc_code
            and t01.psa_psc_week = rcd_psa_psc_week.psw_psc_week
            and t01.psa_act_type = 'P'
          order by t01.psa_mat_code asc,
                   t01.psa_prd_type asc,
                   t01.psa_act_code asc;
      rcd_pact csr_pact%rowtype;

      cursor csr_mlin is
         select t01.mli_lin_code,
                t01.mli_con_code,
                t01.mli_dft_flag,
                t01.mli_rra_code,
                t01.mli_rra_efficiency,
                t01.mli_rra_wastage,
                t02.rrd_rra_units
           from psa_mat_line t01,
                psa_rra_defn t02,
                psa_psc_line t03
          where t01.mli_rra_code = t02.rrd_rra_code
            and t01.mli_prd_type = t03.psl_prd_type
            and t01.mli_lin_code = t03.psl_lin_code
            and t01.mli_con_code = t03.psl_con_code
            and t01.mli_mat_code = rcd_pact.psa_mat_code
            and t01.mli_prd_type = rcd_pact.psa_prd_type
            and t03.psl_psc_code = rcd_psa_psc_week.psw_psc_code
            and t03.psl_psc_week = rcd_psa_psc_week.psw_psc_week
          order by t01.mli_dft_flag desc,
                   t01.mli_lin_code asc,
                   t01.mli_con_code asc;
      rcd_mlin csr_mlin%rowtype;

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
      if var_action != '*UPDWEK' and var_action != '*CRTWEK' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_psa_psc_week.psw_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      rcd_psa_psc_week.psw_psc_week := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      rcd_psa_psc_week.psw_req_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@REQCDE'));
      rcd_psa_psc_week.psw_upd_user := upper(par_user);
      rcd_psa_psc_week.psw_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the existing production schedule week when required
      /*-*/
      if var_action = '*UPDWEK' then
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
                psa_gen_function.add_mesg_data('Production schedule week ('||rcd_psa_psc_week.psw_psc_code||' / '||rcd_psa_psc_week.psw_psc_week||') is currently locked');
         end;
         if var_found = false then
            psa_gen_function.add_mesg_data('Production schedule week ('||rcd_psa_psc_week.psw_psc_code||' / '||rcd_psa_psc_week.psw_psc_week||') does not exist');
         end if;
         if psa_gen_function.get_mesg_count != 0 then
            rollback;
            return;
         end if;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_psa_psc_week.psw_psc_code is null then
         psa_gen_function.add_mesg_data('Production schedule code must be supplied');
      end if;
      if rcd_psa_psc_week.psw_psc_week is null then
         psa_gen_function.add_mesg_data('Production schedule week must be supplied');
      end if;
      if rcd_psa_psc_week.psw_req_code is null then
         psa_gen_function.add_mesg_data('Production requirements must be supplied');
      end if;
      if rcd_psa_psc_week.psw_upd_user is null then
         psa_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Validate the parent relationships
      /*-*/
      var_found := false;
      open csr_reqh;
      fetch csr_reqh into rcd_reqh;
      if csr_reqh%found then
         var_found := true;
      end if;
      close csr_reqh;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production requirements ('||rcd_psa_psc_week.psw_req_code||') does not exist');
      else
         if var_action = '*CRTWEK' and rcd_reqh.rhe_req_status != '*LOADED' then
            psa_gen_function.add_mesg_data('Production requirements ('||rcd_psa_psc_week.psw_req_code||') must be status *LOADED to create a production schedule week');
         end if;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Validate the child relationships
      /*-*/
      obj_pty_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/PSCPTY');
      for idx in 0..xmlDom.getLength(obj_pty_list)-1 loop
         obj_pty_node := xmlDom.item(obj_pty_list,idx);
         var_pty_code := upper(psa_from_xml(xslProcessor.valueOf(obj_pty_node,'@PTYCDE')));
         var_found := false;
         open csr_ptyp;
         fetch csr_ptyp into rcd_ptyp;
         if csr_ptyp%found then
            var_found := true;
         end if;
         close csr_ptyp;
         if var_found = false then
            psa_gen_function.add_mesg_data('Production type ('||var_pty_code||') does not exist');
         else
            if var_action = '*CRTWEK' and rcd_ptyp.pty_prd_status != '1' then
               psa_gen_function.add_mesg_data('Production type ('||var_pty_code||') must be status active to create a production schedule week');
            end if;
         end if;
         obj_lco_list := xslProcessor.selectNodes(obj_pty_node,'PSCLCO');
         for idy in 0..xmlDom.getLength(obj_lco_list)-1 loop
            obj_lco_node := xmlDom.item(obj_lco_list,idy);
            var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_lco_node,'@LINCDE')));
            var_con_code := upper(psa_from_xml(xslProcessor.valueOf(obj_lco_node,'@LCOCDE')));
            var_smo_code := upper(psa_from_xml(xslProcessor.valueOf(obj_lco_node,'@SMOCDE')));
            var_found := false;
            open csr_lcon;
            fetch csr_lcon into rcd_lcon;
            if csr_lcon%found then
               var_found := true;
            end if;
            close csr_lcon;
            if var_found = false then
               psa_gen_function.add_mesg_data('Line configuration ('||var_lin_code||' / '||var_con_code||') does not exist');
            else
               if var_action = '*CRTWEK' and rcd_lcon.lco_con_status != '1' then
                  psa_gen_function.add_mesg_data('Line configuration ('||var_lin_code||' / '||var_con_code||') must be status active to create a production schedule week');
               end if;
            end if;
            open csr_smod;
            fetch csr_smod into rcd_smod;
            if csr_smod%found then
               var_found := true;
            end if;
            close csr_smod;
            if var_found = false then
               psa_gen_function.add_mesg_data('Shift model ('||var_smo_code||') does not exist');
            else
               if var_action = '*CRTWEK' and rcd_smod.smd_smo_status != '1' then
                  psa_gen_function.add_mesg_data('Shift model ('||var_smo_code||') must be status active to create a production schedule week');
               end if;
            end if;
            obj_shf_list := xslProcessor.selectNodes(obj_lco_node,'PSCSHF');
            for idz in 0..xmlDom.getLength(obj_shf_list)-1 loop
               obj_shf_node := xmlDom.item(obj_shf_list,idz);
               var_shf_code := upper(psa_from_xml(xslProcessor.valueOf(obj_shf_node,'@SHFCDE')));
               var_cmo_code := upper(psa_from_xml(xslProcessor.valueOf(obj_shf_node,'@CMOCDE')));
               if var_cmo_code != '*NONE' then
                  var_found := false;
                  open csr_cmod;
                  fetch csr_cmod into rcd_cmod;
                  if csr_cmod%found then
                     var_found := true;
                  end if;
                  close csr_cmod;
                  if var_found = false then
                     psa_gen_function.add_mesg_data('Crew model ('||var_cmo_code||') does not exist');
                  else
                     if var_action = '*CRTWEK' and rcd_cmod.cmd_cmo_status != '1' then
                        psa_gen_function.add_mesg_data('Crew model ('||var_cmo_code||') must be status active to create a production schedule week');
                     end if;
                  end if;
               end if;
            end loop;
         end loop;
      end loop;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Process the production schedule definition
      /*-*/
      if var_action = '*UPDWEK' then
         var_confirm := 'updated';
         update psa_psc_week
            set psw_req_code = rcd_psa_psc_week.psw_req_code,
                psw_upd_user = rcd_psa_psc_week.psw_upd_user,
                psw_upd_date = rcd_psa_psc_week.psw_upd_date
          where psw_psc_code = rcd_psa_psc_week.psw_psc_code
            and psw_psc_code = rcd_psa_psc_week.psw_psc_code;
         delete from psa_psc_date where psd_psc_code = rcd_psa_psc_week.psw_psc_code and psd_psc_week = rcd_psa_psc_week.psw_psc_week;
         delete from psa_psc_line where psl_psc_code = rcd_psa_psc_week.psw_psc_code and psl_psc_week = rcd_psa_psc_week.psw_psc_week;
         delete from psa_psc_reso where psr_psc_code = rcd_psa_psc_week.psw_psc_code and psr_psc_week = rcd_psa_psc_week.psw_psc_week;
         delete from psa_psc_shft where pss_psc_code = rcd_psa_psc_week.psw_psc_code and pss_psc_week = rcd_psa_psc_week.psw_psc_week;
         delete from psa_psc_prod where psp_psc_code = rcd_psa_psc_week.psw_psc_code and psp_psc_week = rcd_psa_psc_week.psw_psc_week;
      elsif var_action = '*CRTWEK' then
         var_confirm := 'created';
         begin
            insert into psa_psc_week values rcd_psa_psc_week;
         exception
            when dup_val_on_index then
               psa_gen_function.add_mesg_data('Production schedule code ('||rcd_psa_psc_week.psw_psc_code||' / '||rcd_psa_psc_week.psw_psc_week||') already exists - unable to create');
               rollback;
               return;
         end;
      end if;

      /*-*/
      /* Retrieve and insert the production date data
      /*-*/
      var_day_indx := 0;
      var_sav_date := null;
      var_day_date := null;
      var_wrk_date := null;
      open csr_date;
      loop
         fetch csr_date into rcd_date;
         if csr_date%notfound then
            exit;
         end if;
         if var_day_indx >= 8 then
            exit;
         end if;
         var_day_indx := var_day_indx + 1;
         rcd_psa_psc_date.psd_psc_code := rcd_psa_psc_week.psw_psc_code;
         rcd_psa_psc_date.psd_psc_week := rcd_psa_psc_week.psw_psc_week;
         rcd_psa_psc_date.psd_day_date := trunc(rcd_date.day_date);
         rcd_psa_psc_date.psd_day_name := rcd_date.day_name;
         insert into psa_psc_date values rcd_psa_psc_date;
         if var_day_indx = 1 then
            var_sav_date := rcd_psa_psc_date.psd_day_date;
            var_day_date := rcd_psa_psc_date.psd_day_date;
            var_wrk_date := rcd_psa_psc_date.psd_day_date;
         end if;
      end loop;
      close csr_date;

      /*-*/
      /* Retrieve and insert the production type data
      /*-*/
      obj_pty_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/PSCPTY');
      for idx in 0..xmlDom.getLength(obj_pty_list)-1 loop
         obj_pty_node := xmlDom.item(obj_pty_list,idx);
         rcd_psa_psc_prod.psp_psc_code := rcd_psa_psc_week.psw_psc_code;
         rcd_psa_psc_prod.psp_psc_week := rcd_psa_psc_week.psw_psc_week;
         rcd_psa_psc_prod.psp_prd_type := upper(psa_from_xml(xslProcessor.valueOf(obj_pty_node,'@PTYCDE')));
         rcd_psa_psc_prod.psp_upd_user := rcd_psa_psc_week.psw_upd_user;
         rcd_psa_psc_prod.psp_upd_date := rcd_psa_psc_week.psw_upd_date;
         insert into psa_psc_prod values rcd_psa_psc_prod;

         /*-*/
         /* Retrieve and insert the line configuration data
         /*-*/
         obj_lco_list := xslProcessor.selectNodes(obj_pty_node,'PSCLCO');
         for idy in 0..xmlDom.getLength(obj_lco_list)-1 loop
            obj_lco_node := xmlDom.item(obj_lco_list,idy);
            rcd_psa_psc_line.psl_psc_code := rcd_psa_psc_week.psw_psc_code;
            rcd_psa_psc_line.psl_psc_week := rcd_psa_psc_week.psw_psc_week;
            rcd_psa_psc_line.psl_prd_type := rcd_psa_psc_prod.psp_prd_type;
            rcd_psa_psc_line.psl_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_lco_node,'@LINCDE')));
            rcd_psa_psc_line.psl_con_code := upper(psa_from_xml(xslProcessor.valueOf(obj_lco_node,'@LCOCDE')));
            rcd_psa_psc_line.psl_smo_code := upper(psa_from_xml(xslProcessor.valueOf(obj_lco_node,'@SMOCDE')));
            insert into psa_psc_line values rcd_psa_psc_line;

            /*-*/
            /* Retrieve and insert the shift data
            /*-*/
            var_day_date := var_sav_date;
            var_wrk_date := var_sav_date;
            var_win_code := '*NONE';
            obj_shf_list := xslProcessor.selectNodes(obj_lco_node,'PSCSHF');
            for idz in 0..xmlDom.getLength(obj_shf_list)-1 loop
               obj_shf_node := xmlDom.item(obj_shf_list,idz);
               rcd_psa_psc_shft.pss_psc_code := rcd_psa_psc_week.psw_psc_code;
               rcd_psa_psc_shft.pss_psc_week := rcd_psa_psc_week.psw_psc_week;
               rcd_psa_psc_shft.pss_prd_type := rcd_psa_psc_prod.psp_prd_type;
               rcd_psa_psc_shft.pss_lin_code := rcd_psa_psc_line.psl_lin_code;
               rcd_psa_psc_shft.pss_con_code := rcd_psa_psc_line.psl_con_code;
               rcd_psa_psc_shft.pss_smo_seqn := idz + 1;
               rcd_psa_psc_shft.pss_shf_code := upper(psa_from_xml(xslProcessor.valueOf(obj_shf_node,'@SHFCDE')));
               rcd_psa_psc_shft.pss_shf_date := var_day_date;
               rcd_psa_psc_shft.pss_shf_start := psa_to_number(xslProcessor.valueOf(obj_shf_node,'@SHFSTR'));
               rcd_psa_psc_shft.pss_shf_duration := psa_to_number(xslProcessor.valueOf(obj_shf_node,'@SHFDUR'));
               rcd_psa_psc_shft.pss_cmo_code := upper(psa_from_xml(xslProcessor.valueOf(obj_shf_node,'@CMOCDE')));
               rcd_psa_psc_shft.pss_win_flag := '0';
               if rcd_psa_psc_shft.pss_cmo_code != '*NONE' then
                  if var_win_code = '*NONE' then
                     rcd_psa_psc_shft.pss_win_flag := '1';
                  else
                     rcd_psa_psc_shft.pss_win_flag := '2';
                  end if;
               end if;
               var_win_code := rcd_psa_psc_shft.pss_cmo_code;
               var_bar_numb := (rcd_psa_psc_shft.pss_shf_duration / 60) * 4;
               if idz = 0 then
                  rcd_psa_psc_shft.pss_str_bar := ((trunc(rcd_psa_psc_shft.pss_shf_start / 100) + (mod(rcd_psa_psc_shft.pss_shf_start,100) / 60)) * 4) + 1;
                  rcd_psa_psc_shft.pss_end_bar := rcd_psa_psc_shft.pss_str_bar + var_bar_numb - 1;
               else
                  rcd_psa_psc_shft.pss_str_bar := rcd_psa_psc_shft.pss_end_bar + 1;
                  rcd_psa_psc_shft.pss_end_bar := rcd_psa_psc_shft.pss_str_bar + var_bar_numb - 1;
               end if;
               insert into psa_psc_shft values rcd_psa_psc_shft;
               var_wrk_date := round(var_wrk_date,'MI') + (rcd_psa_psc_shft.pss_shf_duration / 60 / 24);
               var_day_date := trunc(var_wrk_date);
               if rcd_psa_psc_shft.pss_cmo_code != '*NONE' then
                  open csr_reso;
                  loop
                     fetch csr_reso into rcd_reso;
                     if csr_reso%notfound then
                        exit;
                     end if;
                     rcd_psa_psc_reso.psr_psc_code := rcd_psa_psc_week.psw_psc_code;
                     rcd_psa_psc_reso.psr_psc_week := rcd_psa_psc_week.psw_psc_week;
                     rcd_psa_psc_reso.psr_prd_type := rcd_psa_psc_prod.psp_prd_type;
                     rcd_psa_psc_reso.psr_lin_code := rcd_psa_psc_shft.pss_lin_code;
                     rcd_psa_psc_reso.psr_con_code := rcd_psa_psc_shft.pss_con_code;
                     rcd_psa_psc_reso.psr_smo_seqn := rcd_psa_psc_shft.pss_smo_seqn;
                     rcd_psa_psc_reso.psr_res_code := rcd_reso.cmr_res_code;
                     rcd_psa_psc_reso.psr_res_qnty := rcd_reso.cmr_res_qnty;
                     insert into psa_psc_reso values rcd_psa_psc_reso;
                  end loop;
                  close csr_reso;
               end if;
            end loop;

         end loop;

      end loop;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve and load the production requirements when required
      /*-*/
      if var_action = '*CRTWEK' or (var_action = '*UPDWEK' and rcd_retrieve.psw_req_code != rcd_psa_psc_week.psw_req_code) then

         /*-*/
         /* Delete any existing production activities for the scheduled week
         /*-*/
         if var_action = '*UPDWEK' then
            delete from psa_psc_actv
             where psa_psc_code = rcd_psa_psc_week.psw_psc_code
               and psa_psc_week = rcd_psa_psc_week.psw_psc_week;
         end if;

         /*-*/
         /* Load the production activities for the scheduled week from the requirements
         /*-*/
         var_mat_code := '*NONE';
         open csr_reqd;
         loop
            fetch csr_reqd into rcd_reqd;
            if csr_reqd%notfound then
               exit;
            end if;
            if rcd_reqd.mde_mat_code != var_mat_code then
               var_mat_code := rcd_reqd.mde_mat_code;
               select psa_act_sequence.nextval into rcd_psa_psc_actv.psa_act_code from dual;
               rcd_psa_psc_actv.psa_psc_code := rcd_psa_psc_week.psw_psc_code;
               rcd_psa_psc_actv.psa_psc_week := rcd_psa_psc_week.psw_psc_week;
               rcd_psa_psc_actv.psa_prd_type := rcd_reqd.mpr_prd_type;
               rcd_psa_psc_actv.psa_act_text := 'Production';
               rcd_psa_psc_actv.psa_act_type := 'P';
               rcd_psa_psc_actv.psa_act_used := '0';
               rcd_psa_psc_actv.psa_str_week := null;
               rcd_psa_psc_actv.psa_end_week := null;
               rcd_psa_psc_actv.psa_str_smos := null;
               rcd_psa_psc_actv.psa_end_smos := null;
               rcd_psa_psc_actv.psa_str_time := null;
               rcd_psa_psc_actv.psa_end_time := null;
               rcd_psa_psc_actv.psa_str_barn := null;
               rcd_psa_psc_actv.psa_end_barn := null;
               rcd_psa_psc_actv.psa_mat_code := rcd_reqd.mde_mat_code;
               rcd_psa_psc_actv.psa_mat_gro_weight := rcd_reqd.mde_gro_weight;
               rcd_psa_psc_actv.psa_mat_net_weight := rcd_reqd.mde_net_weight;
               rcd_psa_psc_actv.psa_mat_unt_case := rcd_reqd.mde_unt_case;
               rcd_psa_psc_actv.psa_mat_sch_priority := rcd_reqd.mpr_sch_priority;
               rcd_psa_psc_actv.psa_mat_cas_pallet := rcd_reqd.mpr_cas_pallet;
               rcd_psa_psc_actv.psa_mat_bch_quantity := rcd_reqd.mpr_bch_quantity;
               rcd_psa_psc_actv.psa_mat_yld_percent := rcd_reqd.mpr_yld_percent;
               rcd_psa_psc_actv.psa_mat_yld_value := rcd_reqd.mpr_yld_value;
               rcd_psa_psc_actv.psa_mat_pck_percent := rcd_reqd.mpr_pck_percent;
               rcd_psa_psc_actv.psa_mat_pck_weight := rcd_reqd.mpr_pck_weight;
               rcd_psa_psc_actv.psa_mat_bch_weight := rcd_reqd.mpr_bch_weight;
               rcd_psa_psc_actv.psa_mat_req_qty := rcd_reqd.rde_mat_qnty;
               rcd_psa_psc_actv.psa_lin_code := null;
               rcd_psa_psc_actv.psa_con_code := null;
               rcd_psa_psc_actv.psa_dft_flag := null;
               rcd_psa_psc_actv.psa_rra_code := null;
               rcd_psa_psc_actv.psa_def_rra_unt := null;
               rcd_psa_psc_actv.psa_def_rra_eff := null;
               rcd_psa_psc_actv.psa_def_rra_was := null;
               rcd_psa_psc_actv.psa_act_rra_unt := null;
               rcd_psa_psc_actv.psa_act_rra_eff := null;
               rcd_psa_psc_actv.psa_act_rra_was := null;
               rcd_psa_psc_actv.psa_req_plt_qty := null;
               rcd_psa_psc_actv.psa_req_cas_qty := null;
               rcd_psa_psc_actv.psa_req_pch_qty := null;
               rcd_psa_psc_actv.psa_req_mix_qty := null;
               rcd_psa_psc_actv.psa_req_ton_qty := null;
               rcd_psa_psc_actv.psa_req_dur_min := null;
               rcd_psa_psc_actv.psa_cal_plt_qty := null;
               rcd_psa_psc_actv.psa_cal_cas_qty := null;
               rcd_psa_psc_actv.psa_cal_pch_qty := null;
               rcd_psa_psc_actv.psa_cal_mix_qty := null;
               rcd_psa_psc_actv.psa_cal_ton_qty := null;
               rcd_psa_psc_actv.psa_cal_dur_min := null;
               rcd_psa_psc_actv.psa_sch_plt_qty := null;
               rcd_psa_psc_actv.psa_sch_cas_qty := null;
               rcd_psa_psc_actv.psa_sch_pch_qty := null;
               rcd_psa_psc_actv.psa_sch_mix_qty := null;
               rcd_psa_psc_actv.psa_sch_ton_qty := null;
               rcd_psa_psc_actv.psa_sch_dur_min := null;
               rcd_psa_psc_actv.psa_act_plt_qty := null;
               rcd_psa_psc_actv.psa_act_cas_qty := null;
               rcd_psa_psc_actv.psa_act_pch_qty := null;
               rcd_psa_psc_actv.psa_act_mix_qty := null;
               rcd_psa_psc_actv.psa_act_ton_qty := null;
               rcd_psa_psc_actv.psa_act_dur_min := null;
               rcd_psa_psc_actv.psa_var_plt_qty := null;
               rcd_psa_psc_actv.psa_var_cas_qty := null;
               rcd_psa_psc_actv.psa_var_pch_qty := null;
               rcd_psa_psc_actv.psa_var_mix_qty := null;
               rcd_psa_psc_actv.psa_var_ton_qty := null;
               rcd_psa_psc_actv.psa_var_dur_min := null;
               insert into psa_psc_actv values rcd_psa_psc_actv;
            end if;
         end loop;
         close csr_reqd;

         /*-*/
         /* Assign the production activities to production schedule week lines where possible
         /*-*/
         open csr_pact;
         loop
            fetch csr_pact into rcd_pact;
            if csr_pact%notfound then
               exit;
            end if;

            /*-*/
            /* Find the schedule production line
            /* **note** 1. Use the default line configuration when available
            /*          2. Use the first material line configuration that is avialable
            /*-*/
            open csr_mlin;
            fetch csr_mlin into rcd_mlin;
            if csr_mlin%found then
               rcd_psa_psc_actv.psa_lin_code := rcd_mlin.mli_lin_code;
               rcd_psa_psc_actv.psa_con_code := rcd_mlin.mli_con_code;
               rcd_psa_psc_actv.psa_dft_flag := rcd_mlin.mli_dft_flag;
               rcd_psa_psc_actv.psa_rra_code := rcd_mlin.mli_rra_code;
               rcd_psa_psc_actv.psa_def_rra_unt := rcd_mlin.rrd_rra_units;
               rcd_psa_psc_actv.psa_def_rra_eff := rcd_mlin.mli_rra_efficiency;
               rcd_psa_psc_actv.psa_def_rra_was := rcd_mlin.mli_rra_wastage;
               rcd_psa_psc_actv.psa_act_rra_unt := rcd_mlin.rrd_rra_units;
               rcd_psa_psc_actv.psa_act_rra_eff := rcd_mlin.mli_rra_efficiency;
               rcd_psa_psc_actv.psa_act_rra_was := rcd_mlin.mli_rra_wastage;
               rcd_psa_psc_actv.psa_req_plt_qty := 0;
               rcd_psa_psc_actv.psa_req_cas_qty := 0;
               rcd_psa_psc_actv.psa_req_pch_qty := 0;
               rcd_psa_psc_actv.psa_req_mix_qty := 0;
               rcd_psa_psc_actv.psa_req_ton_qty := 0;
               rcd_psa_psc_actv.psa_req_dur_min := 0;
               rcd_psa_psc_actv.psa_cal_plt_qty := 0;
               rcd_psa_psc_actv.psa_cal_cas_qty := 0;
               rcd_psa_psc_actv.psa_cal_pch_qty := 0;
               rcd_psa_psc_actv.psa_cal_mix_qty := 0;
               rcd_psa_psc_actv.psa_cal_ton_qty := 0;
               rcd_psa_psc_actv.psa_cal_dur_min := 0;
               if rcd_pact.psa_prd_type = '*FILL' then
                  rcd_psa_psc_actv.psa_req_plt_qty := 0;
                  rcd_psa_psc_actv.psa_req_cas_qty := rcd_pact.psa_mat_req_qty;
                  rcd_psa_psc_actv.psa_req_pch_qty := rcd_psa_psc_actv.psa_req_cas_qty * rcd_psa_psc_actv.psa_mat_unt_case;
                  rcd_psa_psc_actv.psa_req_mix_qty := rcd_psa_psc_actv.psa_req_pch_qty / nvl(rcd_psa_psc_actv.psa_mat_yld_value,1);
                  rcd_psa_psc_actv.psa_req_ton_qty := rcd_psa_psc_actv.psa_req_cas_qty * rcd_psa_psc_actv.psa_mat_net_weight;
                  rcd_psa_psc_actv.psa_req_dur_min := rcd_psa_psc_actv.psa_req_cas_qty / (rcd_psa_psc_actv.psa_def_rra_unt * (rcd_psa_psc_actv.psa_def_rra_eff / 100));
                  rcd_psa_psc_actv.psa_cal_plt_qty := 0;
                  rcd_psa_psc_actv.psa_cal_cas_qty := rcd_pact.psa_mat_req_qty + (rcd_pact.psa_mat_req_qty * (rcd_psa_psc_actv.psa_def_rra_was / 100));
                  rcd_psa_psc_actv.psa_cal_pch_qty := rcd_psa_psc_actv.psa_cal_cas_qty * rcd_psa_psc_actv.psa_mat_unt_case;
                  rcd_psa_psc_actv.psa_cal_mix_qty := rcd_psa_psc_actv.psa_cal_pch_qty / nvl(rcd_psa_psc_actv.psa_mat_yld_value,1);
                  rcd_psa_psc_actv.psa_cal_ton_qty := rcd_psa_psc_actv.psa_cal_cas_qty * rcd_psa_psc_actv.psa_mat_net_weight;
                  rcd_psa_psc_actv.psa_cal_dur_min := rcd_psa_psc_actv.psa_cal_cas_qty / (rcd_psa_psc_actv.psa_def_rra_unt * (rcd_psa_psc_actv.psa_def_rra_eff / 100));
               elsif rcd_pact.psa_prd_type = '*PACK' then
                  rcd_psa_psc_actv.psa_req_plt_qty := rcd_pact.psa_mat_req_qty;
                  rcd_psa_psc_actv.psa_req_cas_qty := 0;
                  rcd_psa_psc_actv.psa_req_pch_qty := 0;
                  rcd_psa_psc_actv.psa_req_mix_qty := 0;
                  rcd_psa_psc_actv.psa_req_ton_qty := 0;
                  rcd_psa_psc_actv.psa_req_dur_min := rcd_psa_psc_actv.psa_req_cas_qty / (rcd_psa_psc_actv.psa_def_rra_unt * (rcd_psa_psc_actv.psa_def_rra_eff / 100));
                  rcd_psa_psc_actv.psa_cal_plt_qty := rcd_pact.psa_mat_req_qty + (rcd_pact.psa_mat_req_qty * (rcd_psa_psc_actv.psa_def_rra_was / 100));
                  rcd_psa_psc_actv.psa_cal_cas_qty := 0;
                  rcd_psa_psc_actv.psa_cal_pch_qty := 0;
                  rcd_psa_psc_actv.psa_cal_mix_qty := 0;
                  rcd_psa_psc_actv.psa_cal_ton_qty := 0;
                  rcd_psa_psc_actv.psa_cal_dur_min := rcd_psa_psc_actv.psa_cal_plt_qty / (rcd_psa_psc_actv.psa_def_rra_unt * (rcd_psa_psc_actv.psa_def_rra_eff / 100));
               elsif rcd_pact.psa_prd_type = '*FORM' then
                  rcd_psa_psc_actv.psa_req_plt_qty := 0;
                  rcd_psa_psc_actv.psa_req_cas_qty := 0;
                  rcd_psa_psc_actv.psa_req_pch_qty := rcd_pact.psa_mat_req_qty;
                  rcd_psa_psc_actv.psa_req_mix_qty := 0;
                  rcd_psa_psc_actv.psa_req_ton_qty := 0;
                  rcd_psa_psc_actv.psa_req_dur_min := rcd_psa_psc_actv.psa_req_pch_qty / (rcd_psa_psc_actv.psa_def_rra_unt * (rcd_psa_psc_actv.psa_def_rra_eff / 100));
                  rcd_psa_psc_actv.psa_cal_plt_qty := 0;
                  rcd_psa_psc_actv.psa_cal_cas_qty := 0;
                  rcd_psa_psc_actv.psa_cal_pch_qty := rcd_pact.psa_mat_req_qty + (rcd_pact.psa_mat_req_qty * (rcd_psa_psc_actv.psa_def_rra_was / 100));
                  rcd_psa_psc_actv.psa_cal_mix_qty := 0;
                  rcd_psa_psc_actv.psa_cal_ton_qty := 0;
                  rcd_psa_psc_actv.psa_cal_dur_min := rcd_psa_psc_actv.psa_cal_pch_qty / (rcd_psa_psc_actv.psa_def_rra_unt * (rcd_psa_psc_actv.psa_def_rra_eff / 100));
               end if;
               rcd_psa_psc_actv.psa_sch_plt_qty := 0;
               rcd_psa_psc_actv.psa_sch_cas_qty := 0;
               rcd_psa_psc_actv.psa_sch_pch_qty := 0;
               rcd_psa_psc_actv.psa_sch_mix_qty := 0;
               rcd_psa_psc_actv.psa_sch_ton_qty := 0;
               rcd_psa_psc_actv.psa_sch_dur_min := 0;
               rcd_psa_psc_actv.psa_act_plt_qty := 0;
               rcd_psa_psc_actv.psa_act_cas_qty := 0;
               rcd_psa_psc_actv.psa_act_pch_qty := 0;
               rcd_psa_psc_actv.psa_act_mix_qty := 0;
               rcd_psa_psc_actv.psa_act_ton_qty := 0;
               rcd_psa_psc_actv.psa_act_dur_min := 0;
               rcd_psa_psc_actv.psa_var_plt_qty := 0;
               rcd_psa_psc_actv.psa_var_cas_qty := 0;
               rcd_psa_psc_actv.psa_var_pch_qty := 0;
               rcd_psa_psc_actv.psa_var_mix_qty := 0;
               rcd_psa_psc_actv.psa_var_ton_qty := 0;
               rcd_psa_psc_actv.psa_var_dur_min := 0;
               update psa_psc_actv
                  set psa_lin_code = rcd_psa_psc_actv.psa_lin_code,
                      psa_con_code = rcd_psa_psc_actv.psa_con_code,
                      psa_dft_flag = rcd_psa_psc_actv.psa_dft_flag,
                      psa_rra_code = rcd_psa_psc_actv.psa_rra_code,
                      psa_def_rra_unt = rcd_psa_psc_actv.psa_def_rra_unt,
                      psa_def_rra_eff = rcd_psa_psc_actv.psa_def_rra_eff,
                      psa_def_rra_was = rcd_psa_psc_actv.psa_def_rra_was,
                      psa_act_rra_unt = rcd_psa_psc_actv.psa_act_rra_unt,
                      psa_act_rra_eff = rcd_psa_psc_actv.psa_act_rra_eff,
                      psa_act_rra_was = rcd_psa_psc_actv.psa_act_rra_was,
                      psa_req_plt_qty = rcd_psa_psc_actv.psa_req_plt_qty,
                      psa_req_cas_qty = rcd_psa_psc_actv.psa_req_cas_qty,
                      psa_req_pch_qty = rcd_psa_psc_actv.psa_req_pch_qty,
                      psa_req_mix_qty = rcd_psa_psc_actv.psa_req_mix_qty,
                      psa_req_ton_qty = rcd_psa_psc_actv.psa_req_ton_qty,
                      psa_req_dur_min = rcd_psa_psc_actv.psa_req_dur_min,
                      psa_cal_plt_qty = rcd_psa_psc_actv.psa_cal_plt_qty,
                      psa_cal_cas_qty = rcd_psa_psc_actv.psa_cal_cas_qty,
                      psa_cal_pch_qty = rcd_psa_psc_actv.psa_cal_pch_qty,
                      psa_cal_mix_qty = rcd_psa_psc_actv.psa_cal_mix_qty,
                      psa_cal_ton_qty = rcd_psa_psc_actv.psa_cal_ton_qty,
                      psa_cal_dur_min = rcd_psa_psc_actv.psa_cal_dur_min,
                      psa_sch_plt_qty = rcd_psa_psc_actv.psa_sch_plt_qty,
                      psa_sch_cas_qty = rcd_psa_psc_actv.psa_sch_cas_qty,
                      psa_sch_pch_qty = rcd_psa_psc_actv.psa_sch_pch_qty,
                      psa_sch_mix_qty = rcd_psa_psc_actv.psa_sch_mix_qty,
                      psa_sch_ton_qty = rcd_psa_psc_actv.psa_sch_ton_qty,
                      psa_sch_dur_min = rcd_psa_psc_actv.psa_sch_dur_min,
                      psa_act_plt_qty = rcd_psa_psc_actv.psa_act_plt_qty,
                      psa_act_cas_qty = rcd_psa_psc_actv.psa_act_cas_qty,
                      psa_act_pch_qty = rcd_psa_psc_actv.psa_act_pch_qty,
                      psa_act_mix_qty = rcd_psa_psc_actv.psa_act_mix_qty,
                      psa_act_ton_qty = rcd_psa_psc_actv.psa_act_ton_qty,
                      psa_act_dur_min = rcd_psa_psc_actv.psa_act_dur_min,
                      psa_var_plt_qty = rcd_psa_psc_actv.psa_var_plt_qty,
                      psa_var_cas_qty = rcd_psa_psc_actv.psa_var_cas_qty,
                      psa_var_pch_qty = rcd_psa_psc_actv.psa_var_pch_qty,
                      psa_var_mix_qty = rcd_psa_psc_actv.psa_var_mix_qty,
                      psa_var_ton_qty = rcd_psa_psc_actv.psa_var_ton_qty,
                      psa_var_dur_min = rcd_psa_psc_actv.psa_var_dur_min
                where psa_act_code = rcd_pact.psa_act_code;

            end if;
            close csr_mlin;

         end loop;
         close csr_pact;

      else

         /*-*/
         /* Delete any orphaned production type time activities for the scheduled week
         /*-*/
         delete from psa_psc_actv
          where psa_psc_code = rcd_psa_psc_week.psw_psc_code
            and psa_psc_week = rcd_psa_psc_week.psw_psc_week
            and psa_act_type = 'T'
            and not(psa_prd_type in (select psp_prd_type
                                       from psa_psc_prod
                                      where psp_psc_code = rcd_psa_psc_week.psw_psc_code
                                        and psp_psc_week = rcd_psa_psc_week.psw_psc_week));

         /*-*/
         /* Delete any orphaned shift model time activities for the scheduled week
         /*-*/
         delete from psa_psc_actv
          where psa_psc_code = rcd_psa_psc_week.psw_psc_code
            and psa_psc_week = rcd_psa_psc_week.psw_psc_week
            and psa_act_type = 'T'
            and not((psa_lin_code,
                     psa_con_code,
                     psa_str_smos) in (select pss_lin_code,
                                              pss_con_code,
                                              pss_smo_seqn
                                         from psa_psc_shft
                                        where pss_psc_code = rcd_psa_psc_week.psw_psc_code
                                          and pss_psc_week = rcd_psa_psc_week.psw_psc_week
                                          and pss_cmo_code != '*NONE'));

         /*-*/
         /* Update any orphaned production activities for the scheduled week
         /*-*/
         update psa_psc_actv
            set psa_act_used = '0'
          where psa_psc_code = rcd_psa_psc_week.psw_psc_code
            and psa_psc_week = rcd_psa_psc_week.psw_psc_week
            and psa_act_type = 'P'
            and not(psa_prd_type in (select psp_prd_type
                                       from psa_psc_prod
                                      where psp_psc_code = rcd_psa_psc_week.psw_psc_code
                                        and psp_psc_week = rcd_psa_psc_week.psw_psc_week));

         /*-*/
         /* Update any orphaned shift model production activities for the scheduled week
         /*-*/
         update psa_psc_actv
            set psa_act_used = '0'
          where psa_psc_code = rcd_psa_psc_week.psw_psc_code
            and psa_psc_week = rcd_psa_psc_week.psw_psc_week
            and psa_act_type = 'P'
            and not((psa_lin_code,
                     psa_con_code,
                     psa_str_smos) in (select pss_lin_code,
                                              pss_con_code,
                                              pss_smo_seqn
                                         from psa_psc_shft
                                        where pss_psc_code = rcd_psa_psc_week.psw_psc_code
                                          and pss_psc_week = rcd_psa_psc_week.psw_psc_week
                                          and pss_cmo_code != '*NONE'));

      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Send the confirm message
      /*-*/
      psa_gen_function.set_cfrm_data('Production schedule week ('||rcd_psa_psc_week.psw_psc_code||' / '||rcd_psa_psc_week.psw_psc_week||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - UPDATE_WEEK - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_week;



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
      var_psc_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = var_psc_code
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
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*DLTDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the existing production schedule
      /*-*/
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
            psa_gen_function.add_mesg_data('Production schedule code ('||var_psc_code||') is currently locked');
      end;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production schedule code ('||var_psc_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Process the production schedule data
      /*-*/
      var_confirm := 'deleted';
      delete from psa_psc_hedr where psh_psc_code = var_psc_code;
      delete from psa_psc_line where psl_psc_code = var_psc_code;
      delete from psa_psc_prod where psp_psc_code = var_psc_code;
      delete from psa_psc_reso where psr_psc_code = var_psc_code;
      delete from psa_psc_shft where pss_psc_code = var_psc_code;
      delete from psa_psc_week where psw_psc_code = var_psc_code;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Send the confirm message
      /*-*/
      psa_gen_function.set_cfrm_data('Production schedule ('||var_psc_code||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - DELETE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_data;

end psa_psc_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_psc_function for psa_app.psa_psc_function;
grant execute on psa_app.psa_psc_function to public;

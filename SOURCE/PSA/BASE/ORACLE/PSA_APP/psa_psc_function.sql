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

      /*-*/
      /* Local cursors
      /*-*/
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
         pipe row(psa_xml_object('<LSTROW SLTTYP="'||psa_to_xml('*WEEK')||'"'||
                                        ' SLTCDE="'||psa_to_xml(rcd_week.psw_psc_week)||'"'||
                                        ' SLTTXT="'||psa_to_xml('Y'||substr(rcd_week.psw_psc_week,1,4)||' P'||substr(rcd_week.psw_psc_week,5,2)||' W'||substr(rcd_week.psw_psc_week,7,1))||'"'||
                                        ' SLTUPD="'||psa_to_xml('Last updated by '||rcd_week.psw_upd_user||' on '||to_char(rcd_week.psw_upd_date,'yyyy/mm/dd'))||'"/>'));

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
                                           ' SLTCDE="'||psa_to_xml(rcd_prod.psp_prd_type)||'"'||
                                           ' SLTTXT="'||psa_to_xml(rcd_prod.pty_prd_name)||'"'||
                                           ' SLTUPD="'||psa_to_xml('Last updated by '||rcd_prod.psp_upd_user||' on '||to_char(rcd_prod.psp_upd_date,'yyyy/mm/dd'))||'"/>'));
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
      var_smo_code varchar2(32);
      var_fil_name varchar2(800);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = var_psc_code;
      rcd_retrieve csr_retrieve%rowtype;

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
          where t01.mars_week > (select mars_week from mars_date where trunc(calendar_date) = trunc(sysdate));
      rcd_week_new csr_week_new%rowtype;

      cursor csr_week_old is
         select t01.psw_psc_week,
                t01.psw_smo_code,
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
                t01.pty_prd_name
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
                t02.lco_con_name
           from psa_lin_defn t01,
                psa_lin_config t02
          where t01.lde_lin_code = t02.lco_lin_code
            and t01.lde_lin_status = '1'
            and t01.lde_prd_type = rcd_ptyp.pty_prd_type
            and t02.lco_con_status = '1'
          order by t01.lde_lin_code asc,
                   t02.lco_con_code asc;
      rcd_lcon csr_lcon%rowtype;

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
      else
         open csr_week_old;
         fetch csr_week_old into rcd_week_old;
         if csr_week_old%notfound then
            psa_gen_function.add_mesg_data('Production Schedule ('||var_psc_code||') MARS week ('||var_wek_code||') does not exist');
         else
            var_mars_week := to_number(rcd_week_old.psw_psc_week);
         end if;
         close csr_week_old;
      end if;
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
                                           ' WEKNAM="'||psa_to_xml(rcd_week.wek_name)||'"/>'));
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
      var_smo_code := '*NULL';
      open csr_smod;
      loop
         fetch csr_smod into rcd_smod;
         if csr_smod%notfound then
            exit;
         end if;
         if rcd_smod.smd_smo_code != var_smo_code then
            var_smo_code := rcd_smod.smd_smo_code;
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
                                        ' PTYNAM="'||psa_to_xml(rcd_ptyp.pty_prd_name)||'"/>'));

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
                                           ' FILNAM="'||psa_to_xml(var_fil_name)||'"/>'));

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
      obj_shf_list xmlDom.domNodeList;
      obj_shf_node xmlDom.domNode;
      obj_lco_list xmlDom.domNodeList;
      obj_lco_node xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      var_pty_code varchar2(32);
      var_shf_code varchar2(32);
      var_cmo_code varchar2(32);
      var_lin_code varchar2(32);
      var_con_code varchar2(32);
      rcd_psa_psc_week psa_psc_week%rowtype;
      rcd_psa_psc_prod psa_psc_prod%rowtype;
      rcd_psa_psc_shft psa_psc_shft%rowtype;
      rcd_psa_psc_reso psa_psc_reso%rowtype;
      rcd_psa_psc_line psa_psc_line%rowtype;

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

      cursor csr_smod is
         select t01.*
           from psa_smo_defn t01
          where t01.smd_smo_code = rcd_psa_psc_week.psw_smo_code;
      rcd_smod csr_smod%rowtype;

      cursor csr_ptyp is
         select t01.*
           from psa_prd_type t01
          where t01.pty_prd_type = var_pty_code;
      rcd_ptyp csr_ptyp%rowtype;

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
      rcd_psa_psc_week.psw_smo_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SMOCDE')));
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
      if rcd_psa_psc_week.psw_smo_code is null then
         psa_gen_function.add_mesg_data('Shift model must be supplied');
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
      var_found := false;
      open csr_smod;
      fetch csr_smod into rcd_smod;
      if csr_smod%found then
         var_found := true;
      end if;
      close csr_smod;
      if var_found = false then
         psa_gen_function.add_mesg_data('Shift model ('||rcd_psa_psc_week.psw_smo_code||') does not exist');
      else
         if var_action = '*CRTWEK' and rcd_smod.smd_smo_status != '1' then
            psa_gen_function.add_mesg_data('Shift model ('||rcd_psa_psc_week.psw_smo_code||') must be status active to create a production schedule week');
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
         obj_shf_list := xslProcessor.selectNodes(obj_pty_node,'PSCSHF');
         for idy in 0..xmlDom.getLength(obj_shf_list)-1 loop
            obj_shf_node := xmlDom.item(obj_shf_list,idy);
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
         obj_lco_list := xslProcessor.selectNodes(obj_pty_node,'PSCLCO');
         for idy in 0..xmlDom.getLength(obj_lco_list)-1 loop
            obj_lco_node := xmlDom.item(obj_lco_list,idy);
            var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_lco_node,'@LINCDE')));
            var_con_code := upper(psa_from_xml(xslProcessor.valueOf(obj_lco_node,'@LCOCDE')));
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
            set psw_smo_code = rcd_psa_psc_week.psw_smo_code,
                psw_req_code = rcd_psa_psc_week.psw_req_code,
                psw_upd_user = rcd_psa_psc_week.psw_upd_user,
                psw_upd_date = rcd_psa_psc_week.psw_upd_date
          where psw_psc_code = rcd_psa_psc_week.psw_psc_code
            and psw_psc_code = rcd_psa_psc_week.psw_psc_code;
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
         /* Retrieve and insert the shift data
         /*-*/
         obj_shf_list := xslProcessor.selectNodes(obj_pty_node,'PSCSHF');
         for idy in 0..xmlDom.getLength(obj_shf_list)-1 loop
            obj_shf_node := xmlDom.item(obj_shf_list,idy);
            rcd_psa_psc_shft.pss_psc_code := rcd_psa_psc_week.psw_psc_code;
            rcd_psa_psc_shft.pss_psc_week := rcd_psa_psc_week.psw_psc_week;
            rcd_psa_psc_shft.pss_prd_type := rcd_psa_psc_prod.psp_prd_type;
            rcd_psa_psc_shft.pss_smo_seqn := idy + 1;
            rcd_psa_psc_shft.pss_shf_code := upper(psa_from_xml(xslProcessor.valueOf(obj_shf_node,'@SHFCDE')));
            rcd_psa_psc_shft.pss_shf_start := psa_to_number(xslProcessor.valueOf(obj_shf_node,'@SHFSTR'));
            rcd_psa_psc_shft.pss_shf_duration := psa_to_number(xslProcessor.valueOf(obj_shf_node,'@SHFDUR'));
            rcd_psa_psc_shft.pss_cmo_code := upper(psa_from_xml(xslProcessor.valueOf(obj_shf_node,'@CMOCDE')));
            insert into psa_psc_shft values rcd_psa_psc_shft;
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
                  rcd_psa_psc_reso.psr_smo_seqn := rcd_psa_psc_shft.pss_smo_seqn;
                  rcd_psa_psc_reso.psr_res_code := rcd_reso.cmr_res_code;
                  rcd_psa_psc_reso.psr_res_qnty := rcd_reso.cmr_res_qnty;
                  insert into psa_psc_reso values rcd_psa_psc_reso;
               end loop;
               close csr_reso;
            end if;
         end loop;

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
            insert into psa_psc_line values rcd_psa_psc_line;
         end loop;

      end loop;

      /*-*/
      /* Update any orphaned production type events
      /*-*/
   --   update from psa_psc_edet
   --      set pse_prd_type = '*NONE'
   --    where pse_psc_code = rcd_psa_psc_week.psw_psc_code
   --      and pse_psc_week = rcd_psa_psc_week.psw_psc_week
   --      and not(pse_prd_type in (select psp_prd_type
   --                                 from psa_psc_prod
   --                                where pse_psp_code = rcd_psa_psc_week.psw_psc_code
   --                                  and pse_psp_week = rcd_psa_psc_week.psw_psc_week));

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

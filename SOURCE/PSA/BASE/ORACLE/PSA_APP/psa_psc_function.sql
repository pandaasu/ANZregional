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
   function retrieve_pulse return psa_xml_type pipelined;
   function retrieve_week return psa_xml_type pipelined;
   function retrieve_type return psa_xml_type pipelined;
   function retrieve_line return psa_xml_type pipelined;
   function retrieve_activity return psa_xml_type pipelined;
   function retrieve_time return psa_xml_type pipelined;
   function retrieve_production return psa_xml_type pipelined;
   procedure update_data(par_user in varchar2);
   procedure update_week(par_user in varchar2);
   procedure update_line(par_user in varchar2);
   procedure update_time(par_user in varchar2);
   procedure update_production(par_user in varchar2);
   procedure update_stock(par_user in varchar2);
   procedure delete_data;
   procedure delete_line(par_user in varchar2);
   procedure delete_activity(par_user in varchar2);
   procedure attach_activity(par_user in varchar2);
   procedure detach_activity(par_user in varchar2);
   procedure sap_data;

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

   /*-*/
   /* Private declarations
   /*-*/
   procedure load_worklist(par_psc_code in varchar2,
                           par_psc_week in varchar2,
                           par_prd_type in varchar2,
                           par_src_code in varchar2);
   procedure load_schedule(par_psc_code in varchar2,
                           par_psc_week in varchar2,
                           par_prd_type in varchar2,
                           par_lin_code in varchar2,
                           par_con_code in varchar2);
   procedure calc_schedule(par_act_code in number);
   procedure calc_actual(par_act_code in number);
   procedure align_activity(par_psc_code in varchar2,
                            par_prd_type in varchar2,
                            par_lin_code in varchar2,
                            par_con_code in varchar2,
                            par_win_code in varchar2);
   procedure align_stock(par_psc_code in varchar2,
                         par_psc_week in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   con_mst_cde constant varchar2(32) := '*MASTER';
   con_max_bar constant number := 768;
   type ptyp_data is table of varchar2(2000 char) index by binary_integer;
   ptbl_data ptyp_data;
   type ptyp_invm is table of number index by varchar2(32);
   type prcd_invd is record (invdat date, invtyp varchar2(10), matary ptyp_invm);
   type ptyp_invd is table of prcd_invd index by binary_integer;
   ptbl_sinv ptyp_invd;

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
      var_src_code varchar2(4);
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
                        t01.psh_psc_name
                   from psa_psc_hedr t01
                  where (var_str_code is null or t01.psh_psc_code >= var_str_code)
                  order by t01.psh_psc_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.psh_psc_code,
                        t01.psh_psc_name
                   from psa_psc_hedr t01
                  where (var_action = '*NXTDEF' and (var_end_code is null or t01.psh_psc_code > var_end_code)) or
                        (var_action = '*PRVDEF')
                  order by t01.psh_psc_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.psh_psc_code,
                        t01.psh_psc_name
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
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_str_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@STRCDE')));
      var_end_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@ENDCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SELDEF' and var_action != '*PRVDEF' and var_action != '*NXTDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if var_src_code != '*SCH' then
         psa_gen_function.add_mesg_data('Invalid source code');
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
            pipe row(psa_xml_object('<LSTROW PSCCDE="'||psa_to_xml(tbl_list(idx).psh_psc_code)||'" PSCNAM="'||psa_to_xml(tbl_list(idx).psh_psc_name)||'"/>'));
         end loop;
      elsif var_action = '*NXTDEF' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW PSCCDE="'||psa_to_xml(tbl_list(idx).psh_psc_code)||'" PSCNAM="'||psa_to_xml(tbl_list(idx).psh_psc_name)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW PSCCDE="'||psa_to_xml(tbl_list(idx).psh_psc_code)||'" PSCNAM="'||psa_to_xml(tbl_list(idx).psh_psc_name)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVDEF' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW PSCCDE="'||psa_to_xml(tbl_list(idx).psh_psc_code)||'" PSCNAM="'||psa_to_xml(tbl_list(idx).psh_psc_name)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW PSCCDE="'||psa_to_xml(tbl_list(idx).psh_psc_code)||'" PSCNAM="'||psa_to_xml(tbl_list(idx).psh_psc_name)||'"/>'));
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
      var_src_code varchar2(4);
      var_psc_code varchar2(32);
      var_output varchar2(2000 char);
      var_ths_week varchar2(7);
      var_lst_week varchar2(7);
      var_sltsts varchar2(1);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_week_now is
         select t01.mars_week
           from mars_date t01
          where trunc(t01.calendar_date) <= trunc(sysdate)
          group by t01.mars_week
          order by t01.mars_week desc;
      rcd_week_now csr_week_now%rowtype;

      cursor csr_week is
         select t01.*
           from psa_psc_week t01
          where t01.psw_psc_code = var_psc_code
            and ((var_src_code = '*SCH' and t01.psw_psc_week >= var_ths_week) or
                 (var_src_code = '*ACT' and t01.psw_psc_week >= var_lst_week and t01.psw_psc_week <= var_ths_week))
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
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*WEKLST' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if var_src_code != '*SCH' and var_src_code != '*ACT' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Set the schedule for actuals
      /*-*/
      if var_src_code = '*ACT' then
         var_psc_code := con_mst_cde;
      end if;

      /*-*/
      /* Retrieve the current MARS week
      /*-*/
      var_ths_week := null;
      var_lst_week := null;
      open csr_week_now;
      fetch csr_week_now into rcd_week_now;
      if csr_week_now%found then
         var_ths_week := to_char(rcd_week_now.mars_week,'fm0000000');
      end if;
      fetch csr_week_now into rcd_week_now;
      if csr_week_now%found then
         var_lst_week := to_char(rcd_week_now.mars_week,'fm0000000');
      end if;
      close csr_week_now;
      if var_ths_week is null then
         psa_gen_function.add_mesg_data('Current MARS week does not exist');
      end if;
      if var_lst_week is null then
         psa_gen_function.add_mesg_data('Last MARS week does not exist');
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

         /*-*/
         /* Pipe the production schedule week types
         /*-*/
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
                                           ' SLTWEK="'||psa_to_xml(rcd_week.psw_psc_week)||'"'||
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
      var_src_code varchar2(4);
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
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' and var_action != '*CPYDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if var_src_code != '*SCH' then
         psa_gen_function.add_mesg_data('Invalid source code');
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
         var_output := var_output||' PSCNAM="'||psa_to_xml(rcd_retrieve.psh_psc_name)||'"/>';
      elsif var_action = '*CPYDEF' then
         var_output := '<PSCDFN PSCCDE=""';
         var_output := var_output||' PSCNAM="'||psa_to_xml(rcd_retrieve.psh_psc_name)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CRTDEF' then
         var_output := '<PSCDFN PSCCDE=""';
         var_output := var_output||' PSCNAM=""/>';
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

   /******************************************************/
   /* This procedure performs the retrieve pulse routine */
   /******************************************************/
   function retrieve_pulse return psa_xml_type pipelined is

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

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                to_char(t01.psp_upd_date,'yyyymmddhh24miss') as pul_value
           from psa_psc_prod t01
          where t01.psp_psc_code = var_psc_code
            and t01.psp_psc_week = var_wek_code
            and t01.psp_prd_type = var_pty_code;
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
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      var_pty_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*GETPUL' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing production schedule type
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
      pipe row(psa_xml_object('<PTYPUL PULVAL="'||psa_to_xml(rcd_retrieve.pul_value)||'"/>'));

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - RETRIEVE_PULSE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_pulse;

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
      var_src_code varchar2(4);
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_output varchar2(2000 char);
      var_mars_week number;
      var_cmo_code varchar2(32);
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
                t01.psw_cmo_code,
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

      cursor csr_pmod is
         select t01.cmd_cmo_code,
                t01.cmd_cmo_name
           from psa_cmo_defn t01
          where t01.cmd_cmo_status = '1'
            and t01.cmd_prd_type = '*PLANT'
          order by t01.cmd_cmo_code asc;
      rcd_pmod csr_pmod%rowtype;

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
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*CRTWEK' and var_action != '*UPDWEK' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if var_src_code != '*SCH' then
         psa_gen_function.add_mesg_data('Invalid source code');
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
         var_cmo_code := '*NONE';
         var_req_code := '*NONE';
      else
         open csr_week_old;
         fetch csr_week_old into rcd_week_old;
         if csr_week_old%notfound then
            psa_gen_function.add_mesg_data('Production Schedule ('||var_psc_code||') MARS week ('||var_wek_code||') does not exist');
         else
            var_mars_week := to_number(rcd_week_old.psw_psc_week);
            var_cmo_code := rcd_week_old.psw_cmo_code;
            var_req_code := rcd_week_old.psw_req_code;
         end if;
         close csr_week_old;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      if var_mars_week < rcd_week_now.mars_week then
         psa_gen_function.add_mesg_data('Production Schedule ('||var_psc_code||') MARS week ('||to_char(var_mars_week,'fm0000000')||') is in the past - unable to update');
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
                                           ' WEKNAM="'||psa_to_xml(rcd_week.wek_name)||'"'||
                                           ' CMOCDE="'||psa_to_xml(var_cmo_code)||'"'||
                                           ' REQCDE="'||psa_to_xml(var_req_code)||'"/>'));
         end if;
         pipe row(psa_xml_object('<DAYDFN DAYCDE="'||psa_to_xml(rcd_week.day_code)||'"'||
                                        ' DAYNAM="'||psa_to_xml(rcd_week.day_name)||'"/>'));
      end loop;
      close csr_week;

      /*-*/
      /* Pipe the crew model data XML
      /*-*/
      open csr_pmod;
      loop
         fetch csr_pmod into rcd_pmod;
         if csr_pmod%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<PLNCMO CMOCDE="'||psa_to_xml(rcd_pmod.cmd_cmo_code)||'"'||
                                        ' CMONAM="'||psa_to_xml(rcd_pmod.cmd_cmo_name)||'"/>'));
      end loop;
      close csr_pmod;

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
      var_src_code varchar2(4);
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_pty_code varchar2(32);
      var_output varchar2(2000 char);
      var_fil_name varchar2(800);
      var_min_time date;
      var_max_time date;
      var_lin_code varchar2(32);
      var_con_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                to_char(t01.psp_upd_date,'yyyymmddhh24miss') as pul_value,
                nvl(t02.pty_prd_name,'*UNKNOWN') as pty_prd_name
           from psa_psc_prod t01,
                psa_prd_type t02
          where t01.psp_prd_type = t02.pty_prd_type(+)
            and t01.psp_psc_code = var_psc_code
            and t01.psp_psc_week = var_wek_code
            and t01.psp_prd_type = var_pty_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_mdat is
         select min(trunc(t01.psd_day_date)) as min_day_date,
                max(trunc(t01.psd_day_date)) + 1 as max_day_date
           from psa_psc_date t01
          where t01.psd_psc_code = rcd_retrieve.psp_psc_code
            and t01.psd_psc_week = rcd_retrieve.psp_psc_week;
      rcd_mdat csr_mdat%rowtype;

      cursor csr_date is
         select to_char(t01.psd_day_date,'dd/mm/yyyy') as psd_day_date,
                t01.psd_day_name as psd_day_name
           from psa_psc_date t01
          where t01.psd_psc_code = rcd_retrieve.psp_psc_code
            and t01.psd_psc_week = rcd_retrieve.psp_psc_week
          order by t01.psd_day_date asc;
      rcd_date csr_date%rowtype;

      cursor csr_stck is
         select t01.sth_stk_time,
                t01.sth_stk_name,
                to_date(t01.sth_stk_time,'yyyy/mm/dd hh24:mi') as sth_wrk_time
           from psa_stk_header t01
          where t01.sth_stk_time >= to_char(var_min_time,'yyyy/mm/dd hh24:mi')
            and t01.sth_stk_time < to_char(var_max_time,'yyyy/mm/dd hh24:mi')
          order by t01.sth_stk_time asc;
      rcd_stck csr_stck%rowtype;

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
                t01.pss_win_code,
                t01.pss_win_type,
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

      cursor csr_olin is
         select t01.psa_lin_code,
                nvl(t02.lde_lin_name,'*UNKNOWN') as lde_lin_name,
                t01.psa_con_code,
                nvl(t03.lco_con_name,'*UNKNOWN') as lco_con_name
           from (select t01.psa_act_lin_code as psa_lin_code,
                        t01.psa_act_con_code as psa_con_code
                   from psa_psc_actv t01
                  where t01.psa_psc_code = rcd_retrieve.psp_psc_code
                    and t01.psa_psc_week < rcd_retrieve.psp_psc_week
                    and t01.psa_prd_type = rcd_retrieve.psp_prd_type
                    and t01.psa_act_win_code != '*NONE'
                    and ((t01.psa_act_str_time >= var_min_time and t01.psa_act_str_time < var_max_time) or
                         (t01.psa_act_end_time >= var_min_time and t01.psa_act_end_time < var_max_time))
                    and not((t01.psa_act_lin_code,
                             t01.psa_act_con_code) in (select psl_lin_code,
                                                              psl_con_code
                                                         from psa_psc_line
                                                        where psl_psc_code = rcd_retrieve.psp_psc_code
                                                          and psl_psc_week = rcd_retrieve.psp_psc_week
                                                          and psl_prd_type = rcd_retrieve.psp_prd_type))
                  group by t01.psa_act_lin_code,
                           t01.psa_act_con_code) t01,
                psa_lin_defn t02,
                psa_lin_config t03
          where t01.psa_lin_code = t02.lde_lin_code(+)
            and t01.psa_lin_code = t03.lco_lin_code(+)
            and t01.psa_con_code = t03.lco_con_code(+)
          order by t01.psa_lin_code asc,
                   t01.psa_con_code asc;
      rcd_olin csr_olin%rowtype;

      cursor csr_fill is
         select t01.lfi_fil_code
           from psa_lin_filler t01
          where t01.lfi_lin_code = var_lin_code
            and t01.lfi_con_code = var_con_code
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
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      var_pty_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*GETTYP' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if var_src_code != '*SCH' and var_src_code != '*ACT' then
         psa_gen_function.add_mesg_data('Invalid source code');
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
      /* Retrieve the week min/max times
      /*-*/
      var_min_time := null;
      var_max_time := null;
      open csr_mdat;
      fetch csr_mdat into rcd_mdat;
      if csr_mdat%found then
         var_min_time := rcd_mdat.min_day_date;
         var_max_time := rcd_mdat.max_day_date;
      end if;
      close csr_mdat;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(psa_xml_object('<?xml version="1.0" encoding="UTF-8"?><PSA_RESPONSE>'));

      /*-*/
      /* Pipe the production type data XML
      /*-*/
      pipe row(psa_xml_object('<PTYDFN PTYCDE="'||psa_to_xml(rcd_retrieve.psp_prd_type)||'"'||
                                     ' PTYNAM="'||psa_to_xml(rcd_retrieve.pty_prd_name)||'"'||
                                     ' PULVAL="'||psa_to_xml(rcd_retrieve.pul_value)||'"'||
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
      /* Pipe the stock data XML
      /*-*/
      open csr_stck;
      loop
         fetch csr_stck into rcd_stck;
         if csr_stck%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<STKDFN STKNAM="'||psa_to_xml('('||rcd_stck.sth_stk_time||') '||rcd_stck.sth_stk_name)||'"'||
                                        ' STKBAR="'||psa_to_xml(to_char(trunc(((rcd_stck.sth_wrk_time - var_min_time) * 1440) / 15) + 1))||'"/>'));
      end loop;
      close csr_stck;

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
         var_lin_code := rcd_line.psl_lin_code;
         var_con_code := rcd_line.psl_con_code;
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
                                        ' FILNAM="'||psa_to_xml(var_fil_name)||'"'||
                                        ' OVRFLW="0"/>'));

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
                                           ' WINCDE="'||psa_to_xml(rcd_shft.pss_win_code)||'"'||
                                           ' WINTYP="'||psa_to_xml(rcd_shft.pss_win_type)||'"'||
                                           ' STRBAR="'||psa_to_xml(rcd_shft.pss_str_bar)||'"'||
                                           ' ENDBAR="'||psa_to_xml(rcd_shft.pss_end_bar)||'"/>'));

         end loop;
         close csr_shft;

         /*-*/
         /* Pipe the line activity data XML when required
         /*-*/
         load_schedule(rcd_retrieve.psp_psc_code,
                       rcd_retrieve.psp_psc_week,
                       rcd_retrieve.psp_prd_type,
                       rcd_line.psl_lin_code,
                       rcd_line.psl_con_code);
         for idx in 1..ptbl_data.count loop
            pipe row(psa_xml_object(ptbl_data(idx)));
         end loop;

      end loop;
      close csr_line;

      /*-*/
      /* Pipe the overflow line configuration data XML
      /* **note** these are lines that are not configured for the current week
      /*-*/
      open csr_olin;
      loop
         fetch csr_olin into rcd_olin;
         if csr_olin%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve the line configuration filler name
         /*-*/
         var_lin_code := rcd_olin.psa_lin_code;
         var_con_code := rcd_olin.psa_con_code;
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
         pipe row(psa_xml_object('<LINDFN LINCDE="'||psa_to_xml(rcd_olin.psa_lin_code)||'"'||
                                        ' LINNAM="'||psa_to_xml(rcd_olin.lde_lin_name)||'"'||
                                        ' LCOCDE="'||psa_to_xml(rcd_olin.psa_con_code)||'"'||
                                        ' LCONAM="'||psa_to_xml(rcd_olin.lco_con_name)||'"'||
                                        ' FILNAM="'||psa_to_xml(var_fil_name)||'"'||
                                        ' OVRFLW="1"/>'));

         /*-*/
         /* Pipe the line activity data XML when required
         /*-*/
         load_schedule(rcd_retrieve.psp_psc_code,
                       rcd_retrieve.psp_psc_week,
                       rcd_retrieve.psp_prd_type,
                       rcd_olin.psa_lin_code,
                       rcd_olin.psa_con_code);
         for idx in 1..ptbl_data.count loop
            pipe row(psa_xml_object(ptbl_data(idx)));
         end loop;

      end loop;
      close csr_olin;

      /*-*/
      /* Pipe the work list XML
      /*-*/
      load_worklist(rcd_retrieve.psp_psc_code,
                    rcd_retrieve.psp_psc_week,
                    rcd_retrieve.psp_prd_type,
                    var_src_code);
      for idx in 1..ptbl_data.count loop
         pipe row(psa_xml_object(ptbl_data(idx)));
      end loop;

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

   /*****************************************************/
   /* This procedure performs the retrieve line routine */
   /*****************************************************/
   function retrieve_line return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_src_code varchar2(4);
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_pty_code varchar2(32);
      var_lin_code varchar2(32);
      var_con_code varchar2(32);
      var_output varchar2(2000 char);
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

      cursor csr_cmod is
         select t01.cmd_cmo_code,
                t01.cmd_cmo_name
           from psa_cmo_defn t01
          where t01.cmd_cmo_status = '1'
            and t01.cmd_prd_type = var_pty_code
          order by t01.cmd_cmo_code asc;
      rcd_cmod csr_cmod%rowtype;

      cursor csr_lcon is
         select t01.lde_lin_code,
                t01.lde_lin_name,
                t02.lco_con_code,
                t02.lco_con_name,
                nvl((select psl_smo_code from psa_psc_line where psl_psc_code = var_psc_code and psl_psc_week = var_wek_code and psl_prd_type = var_pty_code and psl_lin_code = t01.lde_lin_code and psl_con_code = t02.lco_con_code),'*NONE') as smo_code
           from psa_lin_defn t01,
                psa_lin_config t02
          where t01.lde_lin_code = t02.lco_lin_code
            and t01.lde_prd_type = var_pty_code
            and ((var_action = '*CRTLIN' and
                  t01.lde_lin_status = '1' and
                  t02.lco_con_status = '1' and
                  not((t02.lco_lin_code, t02.lco_con_code) in (select psl_lin_code, psl_con_code
                                                                 from psa_psc_line
                                                                where psl_psc_code = var_psc_code
                                                                  and psl_psc_week = var_wek_code
                                                                  and psl_prd_type = var_pty_code))) or
                 (var_action = '*UPDLIN' and
                  t02.lco_lin_code = var_lin_code and
                  t02.lco_con_code = var_con_code))
          order by t01.lde_lin_code asc,
                   t02.lco_con_code asc;
      rcd_lcon csr_lcon%rowtype;

      cursor csr_shft is
         select to_char(t01.sms_smo_seqn) as sms_smo_seqn,
                nvl((select pss_cmo_code from psa_psc_shft where pss_psc_code = var_psc_code and pss_psc_week = var_wek_code and pss_prd_type = var_pty_code and pss_lin_code = rcd_lcon.lde_lin_code and pss_con_code = rcd_lcon.lco_con_code and pss_smo_seqn = t01.sms_smo_seqn and pss_shf_code = t01.sms_shf_code),'*NONE') as pss_cmo_code
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
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      var_pty_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
      var_con_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CONCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*CRTLIN' and var_action != '*UPDLIN' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if var_src_code != '*SCH' and var_src_code != '*ACT' then
         psa_gen_function.add_mesg_data('Invalid source code');
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
      /* Pipe the XML start
      /*-*/
      pipe row(psa_xml_object('<?xml version="1.0" encoding="UTF-8"?><PSA_RESPONSE>'));

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - RETRIEVE_LINE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_line;

   /*********************************************************/
   /* This procedure performs the retrieve activity routine */
   /*********************************************************/
   function retrieve_activity return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_src_code varchar2(4);
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_pty_code varchar2(32);
      var_lin_code varchar2(32);
      var_con_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select to_char(t01.psp_upd_date,'yyyymmddhh24miss') as pul_value
           from psa_psc_prod t01
          where t01.psp_psc_code = var_psc_code
            and t01.psp_psc_week = var_wek_code
            and t01.psp_prd_type = var_pty_code;
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
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      var_pty_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
      var_con_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CONCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*RTVSCH' and var_action != '*RTVACT' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if var_src_code != '*SCH' and var_src_code != '*ACT' then
         psa_gen_function.add_mesg_data('Invalid source code');
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
      /* Pipe the pulse XML
      /*-*/
      pipe row(psa_xml_object('<PTYDFN PULVAL="'||psa_to_xml(rcd_retrieve.pul_value)||'"/>'));

      /*-*/
      /* Load the schedule XML
      /*-*/
      if var_action = '*RTVSCH' then
         load_schedule(var_psc_code,
                       var_wek_code,
                       var_pty_code,
                       var_lin_code,
                       var_con_code);
         for idx in 1..ptbl_data.count loop
            pipe row(psa_xml_object(ptbl_data(idx)));
         end loop;
      end if;

      /*-*/
      /* Load the work list XML when required
      /*-*/
      if var_action = '*RTVSCH' or var_action = '*RTVACT' then
         load_worklist(var_psc_code,
                       var_wek_code,
                       var_pty_code,
                       var_src_code);
         for idx in 1..ptbl_data.count loop
            pipe row(psa_xml_object(ptbl_data(idx)));
         end loop;
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - RETRIEVE_ACTIVITY - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_activity;

   /*****************************************************/
   /* This procedure performs the retrieve time routine */
   /*****************************************************/
   function retrieve_time return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_src_code varchar2(4);
      var_act_code number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_actv t01
          where t01.psa_act_code = var_act_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_time is
         select t01.sad_sac_code,
                '('||t01.sad_sac_code||') '||t01.sad_sac_name as sad_sac_name
           from psa_sac_defn t01
          where t01.sad_sac_status = '1'
          order by t01.sad_sac_code asc;
      rcd_time csr_time%rowtype;

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
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_act_code := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@ACTCDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDACT' and var_action != '*CRTACT' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if var_src_code != '*SCH' and var_src_code != '*ACT' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing production schedule activity when required
      /*-*/
      if var_action = '*UPDACT' then
         var_found := false;
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
         if var_found = false then
            psa_gen_function.add_mesg_data('Production schedule activity ('||var_act_code||') does not exist');
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
      /* Pipe the production schedule activity XML
      /*-*/
      if var_action = '*UPDACT' then
         if var_src_code = '*SCH' then
            pipe row(psa_xml_object('<ACTDFN SACCDE="'||psa_to_xml(rcd_retrieve.psa_sac_code)||'"'||
                                           ' SACNAM="'||psa_to_xml(rcd_retrieve.psa_sac_name)||'"'||
                                           ' DURMIN="'||psa_to_xml(to_char(rcd_retrieve.psa_sch_dur_mins))||'"/>'));
         else
            pipe row(psa_xml_object('<ACTDFN SACCDE="'||psa_to_xml(rcd_retrieve.psa_sac_code)||'"'||
                                           ' SACNAM="'||psa_to_xml(rcd_retrieve.psa_sac_name)||'"'||
                                           ' STRTIM="'||psa_to_xml(to_char(rcd_retrieve.psa_act_str_time,'dd/mm/yyyy hh24:mi'))||'"'||
                                           ' ENDTIM="'||psa_to_xml(to_char(rcd_retrieve.psa_act_end_time,'dd/mm/yyyy hh24:mi'))||'"'||
                                           ' COMTXT="'||psa_to_xml(rcd_retrieve.psa_act_com_text)||'"/>'));
         end if;
      elsif var_action = '*CRTACT' then
         if var_src_code = '*SCH' then
            pipe row(psa_xml_object('<ACTDFN SACCDE="*NONE"'||
                                           ' DURMIN="0"/>'));
         else
            pipe row(psa_xml_object('<ACTDFN SACCDE="*NONE"'||
                                           ' STRTIM="'||psa_to_xml(to_char(sysdate,'dd/mm/yyyy hh24:mi'))||'"'||
                                           ' ENDTIM="'||psa_to_xml(to_char(sysdate,'dd/mm/yyyy hh24:mi'))||'"'||
                                           ' COMTXT=""/>'));
         end if;
      end if;

      /*-*/
      /* Retrieve the schedule activity definitions and pipe the results when required
      /*-*/
      if var_action = '*CRTACT' then
        open csr_time;
         loop
            fetch csr_time into rcd_time;
            if csr_time%notfound then
               exit;
            end if;
            pipe row(psa_xml_object('<SACDFN SACCDE="'||psa_to_xml(rcd_time.sad_sac_code)||'"'||
                                           ' SACNAM="'||psa_to_xml(rcd_time.sad_sac_name)||'"/>'));
         end loop;
         close csr_time;
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - RETRIEVE_TIME - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_time;

   /***********************************************************/
   /* This procedure performs the retrieve production routine */
   /***********************************************************/
   function retrieve_production return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_src_code varchar2(4);
      var_pty_code varchar2(32);
      var_lin_code varchar2(32);
      var_con_code varchar2(32);
      var_act_code number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_actv t01
          where t01.psa_act_code = var_act_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_enty is
         select t01.*
           from psa_psc_enty t01
          where t01.pse_act_code = var_act_code
          order by t01.pse_ent_time asc;
      rcd_enty csr_enty%rowtype;

      cursor csr_mdef is
         select t01.mde_mat_code,
                t01.mde_mat_name,
                t01.mde_mat_type,
                t01.mde_mat_usage
           from psa_mat_defn t01
          where t01.mde_mat_status in ('*ACTIVE','*CHG','*DEL')
            and t01.mde_mat_code in (select mli_mat_code
                                       from psa_mat_line
                                      where mli_prd_type = var_pty_code
                                        and mli_lin_code = var_lin_code
                                        and mli_con_code = var_con_code)
          order by t01.mde_mat_code asc;
      rcd_mdef csr_mdef%rowtype;

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
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_pty_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
      var_con_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CONCDE')));
      var_act_code := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@ACTCDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDACT' and var_action != '*CRTACT' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if var_src_code != '*SCH' and var_src_code != '*ACT' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing production schedule activity when required
      /*-*/
      if var_action = '*UPDACT' then
         var_found := false;
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
         if var_found = false then
            psa_gen_function.add_mesg_data('Production schedule activity ('||var_act_code||') does not exist');
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
      /* Pipe the production schedule activity XML
      /*-*/
      if var_action = '*UPDACT' then
         if var_src_code = '*SCH' then
            pipe row(psa_xml_object('<ACTDFN MATCDE="'||psa_to_xml(rcd_retrieve.psa_mat_code)||'"'||
                                           ' MATNAM="'||psa_to_xml(rcd_retrieve.psa_mat_name)||'"'||
                                           ' REQPLT="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_req_plt_qty,0)))||'"'||
                                           ' REQCAS="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_req_cas_qty,0)))||'"'||
                                           ' REQPCH="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_req_pch_qty,0)))||'"'||
                                           ' REQMIX="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_req_mix_qty,0)))||'"'||
                                           ' REQTON="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_req_ton_qty,0),'fm999999990.000'))||'"'||
                                           ' SCHPLT="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_sch_plt_qty,0)))||'"'||
                                           ' SCHCAS="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_sch_cas_qty,0)))||'"'||
                                           ' SCHPCH="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_sch_pch_qty,0)))||'"'||
                                           ' SCHMIX="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_sch_mix_qty,0)))||'"'||
                                           ' SCHTON="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_sch_ton_qty,0),'fm999999990.000'))||'"'||
                                           ' CHGFLG="'||psa_to_xml(nvl(rcd_retrieve.psa_sch_chg_flag,'0'))||'"'||
                                           ' CHGMIN="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_sch_chg_mins,0)))||'"/>'));
         else
            pipe row(psa_xml_object('<ACTDFN MATCDE="'||psa_to_xml(rcd_retrieve.psa_mat_code)||'"'||
                                           ' MATNAM="'||psa_to_xml(rcd_retrieve.psa_mat_name)||'"'||
                                           ' SCHPLT="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_sch_plt_qty,0)))||'"'||
                                           ' SCHCAS="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_sch_cas_qty,0)))||'"'||
                                           ' SCHPCH="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_sch_pch_qty,0)))||'"'||
                                           ' SCHMIX="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_sch_mix_qty,0)))||'"'||
                                           ' SCHTON="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_sch_ton_qty,0),'fm999999990.000'))||'"'||
                                           ' ACTPLT="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_act_plt_qty,0)))||'"'||
                                           ' ACTCAS="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_act_cas_qty,0)))||'"'||
                                           ' ACTPCH="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_act_pch_qty,0)))||'"'||
                                           ' ACTMIX="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_act_mix_qty,0)))||'"'||
                                           ' ACTTON="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_mat_act_ton_qty,0),'fm999999990.000'))||'"'||
                                           ' STRTIM="'||psa_to_xml(to_char(rcd_retrieve.psa_act_str_time,'dd/mm/yyyy hh24:mi'))||'"'||
                                           ' ENDTIM="'||psa_to_xml(to_char(rcd_retrieve.psa_act_end_time,'dd/mm/yyyy hh24:mi'))||'"'||
                                           ' COMTXT="'||psa_to_xml(rcd_retrieve.psa_act_com_text)||'"'||
                                           ' CHGFLG="'||psa_to_xml(nvl(rcd_retrieve.psa_act_chg_flag,'0'))||'"'||
                                           ' CHGMIN="'||psa_to_xml(to_char(nvl(rcd_retrieve.psa_act_chg_mins,0)))||'"/>'));
            open csr_enty;
            loop
               fetch csr_enty into rcd_enty;
               if csr_enty%notfound then
                  exit;
               end if;
               pipe row(psa_xml_object('<ENTDFN ENTTIM="'||psa_to_xml(to_char(rcd_enty.pse_ent_time,'dd/mm/yyyy hh24:mi'))||'"'||
                                              ' ENTTXT="'||psa_to_xml(rcd_enty.pse_ent_text)||'"'||
                                              ' ENTQTY="'||psa_to_xml(to_char(rcd_enty.pse_ent_qnty))||'"'||
                                              ' ENTWAS="'||psa_to_xml(to_char(rcd_enty.pse_ent_wast))||'"/>'));
            end loop;
            close csr_enty;
         end if;
      elsif var_action = '*CRTACT' then
         if var_src_code = '*SCH' then
            pipe row(psa_xml_object('<ACTDFN MATCDE="*NONE"'||
                                           ' MATNAM=""'||
                                           ' REQPLT="0"'||
                                           ' REQCAS="0"'||
                                           ' REQPCH="0"'||
                                           ' REQMIX="0"'||
                                           ' REQTON="0.000"'||
                                           ' SCHPLT="0"'||
                                           ' SCHCAS="0"'||
                                           ' SCHPCH="0"'||
                                           ' SCHMIX="0"'||
                                           ' SCHTON="0.000"'||
                                           ' CHGFLG="0"'||
                                           ' CHGMIN="0"/>'));
         else
            pipe row(psa_xml_object('<ACTDFN MATCDE="*NONE"'||
                                           ' MATNAM=""'||
                                           ' SCHPLT="0"'||
                                           ' SCHCAS="0"'||
                                           ' SCHPCH="0"'||
                                           ' SCHMIX="0"'||
                                           ' SCHTON="0.000"'||
                                           ' ACTPLT="0"'||
                                           ' ACTCAS="0"'||
                                           ' ACTPCH="0"'||
                                           ' ACTMIX="0"'||
                                           ' ACTTON="0.000"'||
                                           ' STRTIM="'||psa_to_xml(to_char(sysdate,'dd/mm/yyyy hh24:mi'))||'"'||
                                           ' ENDTIM="'||psa_to_xml(to_char(sysdate,'dd/mm/yyyy hh24:mi'))||'"'||
                                           ' COMTXT=""'||
                                           ' CHGFLG="0"'||
                                           ' CHGMIN="0"/>'));
         end if;
         open csr_mdef;
         loop
            fetch csr_mdef into rcd_mdef;
            if csr_mdef%notfound then
               exit;
            end if;
            pipe row(psa_xml_object('<MATDFN MATCDE="'||psa_to_xml(rcd_mdef.mde_mat_code)||'"'||
                                           ' MATNAM="'||psa_to_xml(rcd_mdef.mde_mat_name)||'"'||
                                           ' MATYYP="'||psa_to_xml(rcd_mdef.mde_mat_type)||'"'||
                                           ' MATUSG="'||psa_to_xml(rcd_mdef.mde_mat_usage)||'"/>'));
         end loop;
         close csr_mdef;
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - RETRIEVE_PRODUCTION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_production;

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
      var_src_code varchar2(4);
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
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if var_src_code != '*SCH' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_psa_psc_hedr.psh_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      rcd_psa_psc_hedr.psh_psc_name := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCNAM'));
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
      if rcd_retrieve.psh_psc_code = con_mst_cde then
         psa_gen_function.add_mesg_data('Production schedule code '||con_mst_cde||' - unable to create or update');
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
      var_count number;
      var_upd_user varchar2(30);
      var_upd_date date;
      var_src_code varchar2(4);
      var_pty_code varchar2(32);
      var_shf_code varchar2(32);
      var_cmo_code varchar2(32);
      var_lin_code varchar2(32);
      var_con_code varchar2(32);
      var_smo_code varchar2(32);
      var_win_code varchar2(32);
      var_wrk_code varchar2(32);
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
      rcd_actv psa_psc_actv%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = rcd_psa_psc_week.psw_psc_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_week is
         select t01.*
           from psa_psc_week t01
          where t01.psw_psc_code = rcd_psa_psc_week.psw_psc_code
            and t01.psw_psc_week = rcd_psa_psc_week.psw_psc_week;
      rcd_week csr_week%rowtype;

      cursor csr_mars is
         select to_char(t01.mars_week,'fm0000000') as mars_week
           from mars_date t01
          where trunc(t01.calendar_date) = trunc(sysdate);
      rcd_mars csr_mars%rowtype;

      cursor csr_schd is
         select count(*) as wrk_count
           from psa_psc_actv t01
          where psa_psc_code = rcd_psa_psc_week.psw_psc_code
            and psa_psc_week = rcd_psa_psc_week.psw_psc_week
            and psa_act_ent_flag = '1';
      rcd_schd csr_schd%rowtype;

      cursor csr_pmod is
         select t01.*
           from psa_cmo_defn t01
          where t01.cmd_cmo_code = rcd_psa_psc_week.psw_cmo_code;
      rcd_pmod csr_pmod%rowtype;

      cursor csr_peso is
         select t01.*
           from psa_cmo_resource t01
          where t01.cmr_cmo_code = rcd_psa_psc_week.psw_cmo_code
          order by t01.cmr_res_code asc;
      rcd_peso csr_peso%rowtype;

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
                t02.mde_psa_ucas,
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
            and t02.mde_mat_status in ('*ACTIVE','*CHG','*DEL')
            and t03.mpr_req_flag = '1'
          order by t02.mde_mat_code asc,
                   t03.mpr_prd_type asc;
      rcd_reqd csr_reqd%rowtype;

      cursor csr_uact is
         select t01.*
           from psa_psc_actv t01
          where t01.psa_psc_code = rcd_psa_psc_week.psw_psc_code
            and t01.psa_psc_week = rcd_psa_psc_week.psw_psc_week
          order by t01.psa_mat_code asc,
                   t01.psa_prd_type asc,
                   t01.psa_act_code asc;

      cursor csr_mlin is
         select t01.mli_lin_code,
                t01.mli_con_code,
                t01.mli_dft_flag,
                t01.mli_rra_code,
                decode(t01.mli_rra_efficiency,null,100,0,100,t01.mli_rra_efficiency) as mli_rra_efficiency,
                decode(t01.mli_rra_wastage,null,0,t01.mli_rra_wastage) as mli_rra_wastage,
                decode(t02.rrd_rra_units,null,1,t02.rrd_rra_units) as rrd_rra_units,
                nvl(t04.lde_lin_events,'0') as lde_lin_events
           from psa_mat_line t01,
                psa_rra_defn t02,
                psa_psc_line t03,
                psa_lin_defn t04
          where t01.mli_rra_code = t02.rrd_rra_code
            and t01.mli_prd_type = t03.psl_prd_type
            and t01.mli_lin_code = t03.psl_lin_code
            and t01.mli_con_code = t03.psl_con_code
            and t03.psl_lin_code = t04.lde_lin_code
            and t01.mli_mat_code = rcd_actv.psa_mat_code
            and t01.mli_prd_type = rcd_actv.psa_prd_type
            and t03.psl_psc_code = rcd_psa_psc_week.psw_psc_code
            and t03.psl_psc_week = rcd_psa_psc_week.psw_psc_week
          order by t01.mli_dft_flag desc,
                   t01.mli_lin_code asc,
                   t01.mli_con_code asc;
      rcd_mlin csr_mlin%rowtype;

      cursor csr_wind is
         select t01.pss_win_code,
                min(to_date(to_char(t01.pss_shf_date,'yyyymmdd')||to_char(t01.pss_shf_start,'fm0000'),'yyyymmddhh24mi')) as win_stim,
                max(to_date(to_char(t01.pss_shf_date,'yyyymmdd')||to_char(t01.pss_shf_start,'fm0000'),'yyyymmddhh24mi') + (t01.pss_shf_duration / 1440)) as win_etim
           from psa_psc_shft t01
          where t01.pss_psc_code = rcd_psa_psc_week.psw_psc_code
            and t01.pss_psc_week = rcd_psa_psc_week.psw_psc_week
            and t01.pss_prd_type = rcd_psa_psc_prod.psp_prd_type
            and t01.pss_lin_code = rcd_psa_psc_line.psl_lin_code
            and t01.pss_con_code = rcd_psa_psc_line.psl_con_code
            and t01.pss_win_code != '*NONE'
          group by t01.pss_win_code;
      rcd_wind csr_wind%rowtype;

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
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      if var_action != '*UPDWEK' and var_action != '*CRTWEK' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if var_src_code != '*SCH' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_psa_psc_week.psw_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      rcd_psa_psc_week.psw_psc_week := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      rcd_psa_psc_week.psw_cmo_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CMOCDE'));
      rcd_psa_psc_week.psw_req_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@REQCDE'));
      rcd_psa_psc_week.psw_upd_user := upper(par_user);
      rcd_psa_psc_week.psw_upd_date := sysdate;
      var_upd_user := upper(par_user);
      var_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the production schedule
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
             psa_gen_function.add_mesg_data('Production schedule ('||rcd_psa_psc_week.psw_psc_code||') is currently locked');
      end;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production schedule ('||rcd_psa_psc_week.psw_psc_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Validate the week
      /*-*/
      open csr_mars;
      fetch csr_mars into rcd_mars;
      if csr_mars%found then
         if rcd_psa_psc_week.psw_psc_week < rcd_mars.mars_week then
            psa_gen_function.add_mesg_data('Production schedule week ('||rcd_psa_psc_week.psw_psc_code||' / '||rcd_psa_psc_week.psw_psc_week||') is in the past - unable to create/update');
         end if;
      end if;
      close csr_mars;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the existing production schedule week when required
      /*-*/
      if var_action = '*UPDWEK' then
         var_found := false;
         open csr_week;
         fetch csr_week into rcd_week;
         if csr_week%found then
            var_found := true;
         end if;
         close csr_week;
         if var_found = false then
            psa_gen_function.add_mesg_data('Production schedule week ('||rcd_psa_psc_week.psw_psc_code||' / '||rcd_psa_psc_week.psw_psc_week||') does not exist');
         else
            var_count := 0;
            open csr_schd;
            fetch csr_schd into rcd_schd;
            if csr_schd%found then
               var_count := rcd_schd.wrk_count;
            end if;
            close csr_schd;
            if var_count != 0 then
               psa_gen_function.add_mesg_data('Production schedule week ('||rcd_psa_psc_week.psw_psc_code||' / '||rcd_psa_psc_week.psw_psc_week||') has actuals entered - unable to update');
            end if;
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
      if rcd_psa_psc_week.psw_cmo_code is null then
         psa_gen_function.add_mesg_data('Production crew model must be supplied');
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
      open csr_pmod;
      fetch csr_pmod into rcd_pmod;
      if csr_pmod%found then
         var_found := true;
      end if;
      close csr_pmod;
      if var_found = false then
         psa_gen_function.add_mesg_data('Crew model ('||rcd_psa_psc_week.psw_cmo_code||') does not exist');
      else
         if rcd_pmod.cmd_cmo_status != '1' then
            psa_gen_function.add_mesg_data('Crew model ('||rcd_psa_psc_week.psw_cmo_code||') must be status active');
         end if;
         if rcd_pmod.cmd_prd_type != '*PLANT' then
            psa_gen_function.add_mesg_data('Crew model ('||rcd_psa_psc_week.psw_cmo_code||') must belong to *PLANT');
         end if;
      end if;
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
         if rcd_reqh.rhe_req_status != '*LOADED' then
            psa_gen_function.add_mesg_data('Production requirements ('||rcd_psa_psc_week.psw_req_code||') must be status *LOADED');
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
            if rcd_ptyp.pty_prd_status != '1' then
               psa_gen_function.add_mesg_data('Production type ('||var_pty_code||') must be status active');
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
               if rcd_lcon.lco_con_status != '1' then
                  psa_gen_function.add_mesg_data('Line configuration ('||var_lin_code||' / '||var_con_code||') must be status active');
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
               if rcd_smod.smd_smo_status != '1' then
                  psa_gen_function.add_mesg_data('Shift model ('||var_smo_code||') must be status active');
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
                     if rcd_cmod.cmd_cmo_status != '1' then
                        psa_gen_function.add_mesg_data('Crew model ('||var_cmo_code||') must be status active');
                     end if;
                     if rcd_cmod.cmd_prd_type != var_pty_code then
                        psa_gen_function.add_mesg_data('Crew model ('||var_cmo_code||') must belong to '||var_pty_code);
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
            set psw_cmo_code = rcd_psa_psc_week.psw_cmo_code,
                psw_req_code = rcd_psa_psc_week.psw_req_code,
                psw_upd_user = rcd_psa_psc_week.psw_upd_user,
                psw_upd_date = rcd_psa_psc_week.psw_upd_date
          where psw_psc_code = rcd_psa_psc_week.psw_psc_code
            and psw_psc_code = rcd_psa_psc_week.psw_psc_code;
         delete from psa_psc_enty where pse_act_code in (select psa_act_code from psa_psc_actv where psa_psc_code = rcd_psa_psc_week.psw_psc_code and psa_psc_week = rcd_psa_psc_week.psw_psc_week);
         delete from psa_psc_invt where psi_act_code in (select psa_act_code from psa_psc_actv where psa_psc_code = rcd_psa_psc_week.psw_psc_code and psa_psc_week = rcd_psa_psc_week.psw_psc_week);
         delete from psa_psc_actv where psa_psc_code = rcd_psa_psc_week.psw_psc_code and psa_psc_week = rcd_psa_psc_week.psw_psc_week;
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
      /* Retrieve and insert the plant resource data
      /*-*/
      open csr_peso;
      loop
         fetch csr_peso into rcd_peso;
         if csr_peso%notfound then
            exit;
         end if;
         rcd_psa_psc_reso.psr_psc_code := rcd_psa_psc_week.psw_psc_code;
         rcd_psa_psc_reso.psr_psc_week := rcd_psa_psc_week.psw_psc_week;
         rcd_psa_psc_reso.psr_prd_type := '*PLANT';
         rcd_psa_psc_reso.psr_lin_code := '*PLANT';
         rcd_psa_psc_reso.psr_con_code := '*PLANT';
         rcd_psa_psc_reso.psr_smo_seqn := 0;
         rcd_psa_psc_reso.psr_res_code := rcd_peso.cmr_res_code;
         rcd_psa_psc_reso.psr_res_qnty := rcd_peso.cmr_res_qnty;
         insert into psa_psc_reso values rcd_psa_psc_reso;
      end loop;
      close csr_peso;

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
            var_wrk_code := '*NONE';
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
               rcd_psa_psc_shft.pss_str_bar := 0;
               rcd_psa_psc_shft.pss_str_bar := 0;
               rcd_psa_psc_shft.pss_win_code := '*NONE';
               rcd_psa_psc_shft.pss_win_type := '0';
               rcd_psa_psc_shft.pss_win_stim := null;
               rcd_psa_psc_shft.pss_win_etim := null;
               if rcd_psa_psc_shft.pss_cmo_code != '*NONE' then
                  if var_wrk_code = '*NONE' then
                     var_win_code := rcd_psa_psc_shft.pss_psc_week||'_'||to_char(rcd_psa_psc_shft.pss_smo_seqn,'fm00000');
                     rcd_psa_psc_shft.pss_win_code := var_win_code;
                     rcd_psa_psc_shft.pss_win_type := '1';
                  else
                     rcd_psa_psc_shft.pss_win_code := var_win_code;
                     rcd_psa_psc_shft.pss_win_type := '2';
                  end if;
               end if;
               var_wrk_code := rcd_psa_psc_shft.pss_cmo_code;
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
            open csr_wind;
            loop
               fetch csr_wind into rcd_wind;
               if csr_wind%notfound then
                  exit;
               end if;
               update psa_psc_shft
                  set pss_win_stim = rcd_wind.win_stim,
                      pss_win_etim = rcd_wind.win_etim
                where pss_psc_code = rcd_psa_psc_week.psw_psc_code
                  and pss_psc_week = rcd_psa_psc_week.psw_psc_week
                  and pss_prd_type = rcd_psa_psc_prod.psp_prd_type
                  and pss_lin_code = rcd_psa_psc_line.psl_lin_code
                  and pss_con_code = rcd_psa_psc_line.psl_con_code
                  and pss_win_code = rcd_wind.pss_win_code;
            end loop;
            close csr_wind;

         end loop;

      end loop;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

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
            select psa_act_sequence.nextval into rcd_actv.psa_act_code from dual;
            rcd_actv.psa_psc_code := rcd_psa_psc_week.psw_psc_code;
            rcd_actv.psa_psc_week := rcd_psa_psc_week.psw_psc_week;
            rcd_actv.psa_prd_type := rcd_reqd.mpr_prd_type;
            rcd_actv.psa_act_type := 'P';
            rcd_actv.psa_upd_user := var_upd_user;
            rcd_actv.psa_upd_date := var_upd_date;
            rcd_actv.psa_sch_ent_flag := '1';
            rcd_actv.psa_sch_chg_flag := '0';
            rcd_actv.psa_sch_lin_code := null;
            rcd_actv.psa_sch_con_code := null;
            rcd_actv.psa_sch_dft_flag := null;
            rcd_actv.psa_sch_rra_code := null;
            rcd_actv.psa_sch_rra_unit := null;
            rcd_actv.psa_sch_rra_effp := null;
            rcd_actv.psa_sch_rra_wasp := null;
            rcd_actv.psa_sch_dur_mins := 0;
            rcd_actv.psa_sch_chg_mins := 0;
            rcd_actv.psa_act_ent_flag := '0';
            rcd_actv.psa_act_chg_flag := '0';
            rcd_actv.psa_act_lin_code := null;
            rcd_actv.psa_act_con_code := null;
            rcd_actv.psa_act_dft_flag := null;
            rcd_actv.psa_act_rra_code := null;
            rcd_actv.psa_act_rra_unit := null;
            rcd_actv.psa_act_rra_effp := null;
            rcd_actv.psa_act_rra_wasp := null;
            rcd_actv.psa_act_cal_unit := null;
            rcd_actv.psa_act_cal_effp := null;
            rcd_actv.psa_act_cal_wasp := null;
            rcd_actv.psa_act_win_code := '*NONE';
            rcd_actv.psa_act_win_seqn := null;
            rcd_actv.psa_act_win_flow := null;
            rcd_actv.psa_act_str_time := null;
            rcd_actv.psa_act_chg_time := null;
            rcd_actv.psa_act_end_time := null;
            rcd_actv.psa_act_dur_mins := 0;
            rcd_actv.psa_act_chg_mins := 0;
            rcd_actv.psa_act_com_text := null;
            rcd_actv.psa_var_dur_mins := 0;
            rcd_actv.psa_var_chg_mins := 0;
            rcd_actv.psa_sac_code := null;
            rcd_actv.psa_sac_name := null;
            rcd_actv.psa_mat_code := rcd_reqd.mde_mat_code;
            rcd_actv.psa_mat_name := rcd_reqd.mde_mat_name;
            rcd_actv.psa_mat_type := rcd_reqd.mde_mat_type;
            rcd_actv.psa_mat_usage := rcd_reqd.mde_mat_usage;
            rcd_actv.psa_mat_uom := rcd_reqd.mde_mat_uom;
            rcd_actv.psa_mat_gro_weight := rcd_reqd.mde_gro_weight;
            rcd_actv.psa_mat_net_weight := rcd_reqd.mde_net_weight;
            rcd_actv.psa_mat_unt_case := rcd_reqd.mde_psa_ucas;
            rcd_actv.psa_mat_sch_priority := rcd_reqd.mpr_sch_priority;
            rcd_actv.psa_mat_cas_pallet := rcd_reqd.mpr_cas_pallet;
            rcd_actv.psa_mat_bch_quantity := rcd_reqd.mpr_bch_quantity;
            rcd_actv.psa_mat_yld_percent := rcd_reqd.mpr_yld_percent;
            rcd_actv.psa_mat_yld_value := rcd_reqd.mpr_yld_value;
            rcd_actv.psa_mat_pck_percent := rcd_reqd.mpr_pck_percent;
            rcd_actv.psa_mat_pck_weight := rcd_reqd.mpr_pck_weight;
            rcd_actv.psa_mat_bch_weight := rcd_reqd.mpr_bch_weight;
            rcd_actv.psa_mat_sap_qty := rcd_reqd.rde_mat_qnty;
            rcd_actv.psa_mat_req_qty := rcd_reqd.rde_mat_qnty;
            rcd_actv.psa_mat_req_plt_qty := 0;
            rcd_actv.psa_mat_req_cas_qty := 0;
            rcd_actv.psa_mat_req_pch_qty := 0;
            rcd_actv.psa_mat_req_mix_qty := 0;
            rcd_actv.psa_mat_req_ton_qty := 0;
            rcd_actv.psa_mat_req_dur_min := 0;
            rcd_actv.psa_mat_sch_qty := 0;
            rcd_actv.psa_mat_sch_was := 0;
            rcd_actv.psa_mat_sch_plt_qty := 0;
            rcd_actv.psa_mat_sch_cas_qty := 0;
            rcd_actv.psa_mat_sch_pch_qty := 0;
            rcd_actv.psa_mat_sch_mix_qty := 0;
            rcd_actv.psa_mat_sch_ton_qty := 0;
            rcd_actv.psa_mat_sch_plt_was := 0;
            rcd_actv.psa_mat_sch_cas_was := 0;
            rcd_actv.psa_mat_sch_pch_was := 0;
            rcd_actv.psa_mat_sch_mix_was := 0;
            rcd_actv.psa_mat_sch_ton_was := 0;
            rcd_actv.psa_mat_sch_dur_min := 0;
            rcd_actv.psa_mat_act_qty := 0;
            rcd_actv.psa_mat_act_was := 0;
            rcd_actv.psa_mat_act_plt_qty := 0;
            rcd_actv.psa_mat_act_cas_qty := 0;
            rcd_actv.psa_mat_act_pch_qty := 0;
            rcd_actv.psa_mat_act_mix_qty := 0;
            rcd_actv.psa_mat_act_ton_qty := 0;
            rcd_actv.psa_mat_act_plt_was := 0;
            rcd_actv.psa_mat_act_cas_was := 0;
            rcd_actv.psa_mat_act_pch_was := 0;
            rcd_actv.psa_mat_act_mix_was := 0;
            rcd_actv.psa_mat_act_ton_was := 0;
            rcd_actv.psa_mat_act_dur_min := 0;
            rcd_actv.psa_mat_inv_qty := 0;
            rcd_actv.psa_mat_inv_plt_qty := 0;
            rcd_actv.psa_mat_inv_cas_qty := 0;
            rcd_actv.psa_mat_inv_pch_qty := 0;
            rcd_actv.psa_mat_inv_ton_qty := 0;
            rcd_actv.psa_mat_var_plt_qty := 0;
            rcd_actv.psa_mat_var_cas_qty := 0;
            rcd_actv.psa_mat_var_pch_qty := 0;
            rcd_actv.psa_mat_var_mix_qty := 0;
            rcd_actv.psa_mat_var_ton_qty := 0;
            rcd_actv.psa_mat_var_plt_was := 0;
            rcd_actv.psa_mat_var_cas_was := 0;
            rcd_actv.psa_mat_var_pch_was := 0;
            rcd_actv.psa_mat_var_mix_was := 0;
            rcd_actv.psa_mat_var_ton_was := 0;
            rcd_actv.psa_mat_var_dur_min := 0;
            insert into psa_psc_actv values rcd_actv;
         end if;
      end loop;
      close csr_reqd;

      /*-*/
      /* Assign the production activities to production schedule week lines where possible
      /*-*/
      open csr_uact;
      loop
         fetch csr_uact into rcd_actv;
         if csr_uact%notfound then
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

            /*-*/
            /* Update the schedule production activity
            /*-*/
            rcd_actv.psa_sch_lin_code := rcd_mlin.mli_lin_code;
            rcd_actv.psa_sch_con_code := rcd_mlin.mli_con_code;
            rcd_actv.psa_sch_dft_flag := rcd_mlin.mli_dft_flag;
            rcd_actv.psa_sch_rra_code := rcd_mlin.mli_rra_code;
            rcd_actv.psa_sch_rra_unit := rcd_mlin.rrd_rra_units;
            rcd_actv.psa_sch_rra_effp := rcd_mlin.mli_rra_efficiency;
            rcd_actv.psa_sch_rra_wasp := rcd_mlin.mli_rra_wastage;
            rcd_actv.psa_act_lin_code := rcd_mlin.mli_lin_code;
            rcd_actv.psa_act_con_code := rcd_mlin.mli_con_code;
            rcd_actv.psa_act_dft_flag := rcd_mlin.mli_dft_flag;
            rcd_actv.psa_act_rra_code := rcd_mlin.mli_rra_code;
            rcd_actv.psa_act_rra_unit := rcd_mlin.rrd_rra_units;
            rcd_actv.psa_act_rra_effp := rcd_mlin.mli_rra_efficiency;
            rcd_actv.psa_act_rra_wasp := rcd_mlin.mli_rra_wastage;
            rcd_actv.psa_act_cal_unit := rcd_mlin.rrd_rra_units;
            rcd_actv.psa_act_cal_effp := rcd_mlin.mli_rra_efficiency;
            rcd_actv.psa_act_cal_wasp := rcd_mlin.mli_rra_wastage;
            rcd_actv.psa_sch_chg_flag := '0';
            rcd_actv.psa_sch_chg_mins := 0;
            rcd_actv.psa_act_chg_flag := '0';
            rcd_actv.psa_act_chg_mins := 0;
            if rcd_mlin.lde_lin_events = '1' then
               rcd_actv.psa_sch_chg_flag := '1';
               rcd_actv.psa_sch_chg_mins := 30;
               rcd_actv.psa_act_chg_flag := '1';
               rcd_actv.psa_act_chg_mins := 30;
            end if;
            update psa_psc_actv
               set psa_sch_chg_flag = rcd_actv.psa_sch_chg_flag,
                   psa_sch_chg_mins = rcd_actv.psa_sch_chg_mins,
                   psa_act_chg_mins = rcd_actv.psa_act_chg_mins,
                   psa_sch_lin_code = rcd_actv.psa_sch_lin_code,
                   psa_sch_con_code = rcd_actv.psa_sch_con_code,
                   psa_sch_dft_flag = rcd_actv.psa_sch_dft_flag,
                   psa_sch_rra_code = rcd_actv.psa_sch_rra_code,
                   psa_sch_rra_unit = rcd_actv.psa_sch_rra_unit,
                   psa_sch_rra_effp = rcd_actv.psa_sch_rra_effp,
                   psa_sch_rra_wasp = rcd_actv.psa_sch_rra_wasp,
                   psa_act_chg_flag = rcd_actv.psa_act_chg_flag,
                   psa_act_lin_code = rcd_actv.psa_act_lin_code,
                   psa_act_con_code = rcd_actv.psa_act_con_code,
                   psa_act_dft_flag = rcd_actv.psa_act_dft_flag,
                   psa_act_rra_code = rcd_actv.psa_act_rra_code,
                   psa_act_rra_unit = rcd_actv.psa_act_rra_unit,
                   psa_act_rra_effp = rcd_actv.psa_act_rra_effp,
                   psa_act_rra_wasp = rcd_actv.psa_act_rra_wasp,
                   psa_act_cal_unit = rcd_actv.psa_act_cal_unit,
                   psa_act_cal_effp = rcd_actv.psa_act_cal_effp,
                   psa_act_cal_wasp = rcd_actv.psa_act_cal_wasp
             where psa_act_code = rcd_actv.psa_act_code;

            /*-*/
            /* Update the schedule production activity
            /*-*/
            calc_schedule(rcd_actv.psa_act_code);

         end if;
         close csr_mlin;

      end loop;
      close csr_uact;

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
   /* This procedure performs the update line routine */
   /***************************************************/
   procedure update_line(par_user in varchar2) is

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
      var_count number;
      var_src_code varchar2(32);
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_pty_code varchar2(32);
      var_lin_code varchar2(32);
      var_con_code varchar2(32);
      var_smo_code varchar2(32);
      var_shf_code varchar2(32);
      var_cmo_code varchar2(32);
      var_upd_user varchar2(30);
      var_upd_date date;
      var_win_flag boolean;
      var_win_code varchar2(32);
      var_win_seqn number;
      var_wrk_code varchar2(32);
      var_mat_code varchar2(32);
      var_sav_date date;
      var_day_date date;
      var_wrk_date date;
      var_bar_numb integer;
      rcd_psa_psc_line psa_psc_line%rowtype;
      rcd_psa_psc_shft psa_psc_shft%rowtype;
      rcd_psa_psc_reso psa_psc_reso%rowtype;
      rcd_actv psa_psc_actv%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = var_psc_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_schd is
         select count(*) as wrk_count
           from psa_psc_actv t01
          where t01.psa_psc_code = var_psc_code
            and t01.psa_psc_week = var_wek_code
            and t01.psa_prd_type = var_pty_code
            and t01.psa_act_lin_code = var_lin_code
            and t01.psa_act_con_code = var_con_code
            and t01.psa_act_ent_flag = '1';
      rcd_schd csr_schd%rowtype;

      cursor csr_actl is
         select count(*) as wrk_count
           from psa_psc_actv t01
          where t01.psa_psc_code = var_psc_code
            and t01.psa_psc_week = var_wek_code
            and t01.psa_prd_type = var_pty_code
            and t01.psa_act_lin_code = var_lin_code
            and t01.psa_act_con_code = var_con_code
            and t01.psa_sch_ent_flag = '1';
      rcd_actl csr_actl%rowtype;

      cursor csr_lcon is
         select t01.*
           from psa_lin_config t01
          where t01.lco_lin_code = var_lin_code
            and t01.lco_con_code = var_con_code;
      rcd_lcon csr_lcon%rowtype;

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

      cursor csr_reso is
         select t01.*
           from psa_cmo_resource t01
          where t01.cmr_cmo_code = rcd_psa_psc_shft.pss_cmo_code
          order by t01.cmr_res_code asc;
      rcd_reso csr_reso%rowtype;

      cursor csr_date is
         select min(trunc(t01.psd_day_date)) as min_day_date,
                max(trunc(t01.psd_day_date)) + 1 as max_day_date
           from psa_psc_date t01
          where t01.psd_psc_code = rcd_psa_psc_line.psl_psc_code
            and t01.psd_psc_week = rcd_psa_psc_line.psl_psc_week;
      rcd_date csr_date%rowtype;

      cursor csr_wind is
         select t01.pss_win_code,
                min(to_date(to_char(t01.pss_shf_date,'yyyymmdd')||to_char(t01.pss_shf_start,'fm0000'),'yyyymmddhh24mi')) as win_stim,
                max(to_date(to_char(t01.pss_shf_date,'yyyymmdd')||to_char(t01.pss_shf_start,'fm0000'),'yyyymmddhh24mi') + (t01.pss_shf_duration / 1440)) as win_etim
           from psa_psc_shft t01
          where t01.pss_psc_code = rcd_psa_psc_line.psl_psc_code
            and t01.pss_psc_week = rcd_psa_psc_line.psl_psc_week
            and t01.pss_prd_type = rcd_psa_psc_line.psl_prd_type
            and t01.pss_lin_code = rcd_psa_psc_line.psl_lin_code
            and t01.pss_con_code = rcd_psa_psc_line.psl_con_code
            and t01.pss_win_code != '*NONE'
          group by t01.pss_win_code;
      rcd_wind csr_wind%rowtype;

      cursor csr_uact is
         select t01.*
           from psa_psc_actv t01
          where t01.psa_psc_code = rcd_psa_psc_line.psl_psc_code
            and t01.psa_psc_week = rcd_psa_psc_line.psl_psc_week
            and t01.psa_prd_type = rcd_psa_psc_line.psl_prd_type
            and t01.psa_act_type = 'P'
            and t01.psa_sch_ent_flag = '1'
            and t01.psa_act_ent_flag = '0'
            and t01.psa_sch_lin_code is null
          order by t01.psa_act_code asc;

      cursor csr_mlin is
         select t01.mli_lin_code,
                t01.mli_con_code,
                t01.mli_dft_flag,
                t01.mli_rra_code,
                decode(t01.mli_rra_efficiency,null,100,0,100,t01.mli_rra_efficiency) as mli_rra_efficiency,
                decode(t01.mli_rra_wastage,null,0,t01.mli_rra_wastage) as mli_rra_wastage,
                decode(t02.rrd_rra_units,null,1,t02.rrd_rra_units) as rrd_rra_units,
                nvl(t04.lde_lin_events,'0') as lde_lin_events
           from psa_mat_line t01,
                psa_rra_defn t02,
                psa_psc_line t03,
                psa_lin_defn t04
          where t01.mli_rra_code = t02.rrd_rra_code
            and t01.mli_prd_type = t03.psl_prd_type
            and t01.mli_lin_code = t03.psl_lin_code
            and t01.mli_con_code = t03.psl_con_code
            and t03.psl_lin_code = t04.lde_lin_code
            and t01.mli_mat_code = rcd_actv.psa_mat_code
            and t01.mli_prd_type = rcd_actv.psa_prd_type
            and t03.psl_psc_code = rcd_psa_psc_line.psl_psc_code
            and t03.psl_psc_week = rcd_psa_psc_line.psl_psc_week
          order by t01.mli_dft_flag desc,
                   t01.mli_lin_code asc,
                   t01.mli_con_code asc;
      rcd_mlin csr_mlin%rowtype;

      cursor csr_sact is
         select t01.*
           from psa_psc_actv t01
          where t01.psa_psc_code = rcd_psa_psc_line.psl_psc_code
            and t01.psa_psc_week = rcd_psa_psc_line.psl_psc_week
            and t01.psa_prd_type = rcd_psa_psc_line.psl_prd_type
            and t01.psa_act_lin_code = rcd_psa_psc_line.psl_lin_code
            and t01.psa_act_con_code = rcd_psa_psc_line.psl_con_code
            and t01.psa_act_win_code != '*NONE'
          order by t01.psa_act_str_time asc;
      rcd_sact csr_sact%rowtype;

      cursor csr_wact is
         select t01.pss_win_code as win_code,
                min(to_date(to_char(t01.pss_shf_date,'yyyymmdd')||to_char(t01.pss_shf_start,'fm0000'),'yyyymmddhh24mi')) as win_stim,
                max(to_date(to_char(t01.pss_shf_date,'yyyymmdd')||to_char(t01.pss_shf_start,'fm0000'),'yyyymmddhh24mi') + (t01.pss_shf_duration / 1440)) as win_etim,
                0 as win_seqn
           from psa_psc_shft t01
          where t01.pss_psc_code = rcd_psa_psc_line.psl_psc_code
            and t01.pss_psc_week = rcd_psa_psc_line.psl_psc_week
            and t01.pss_prd_type = rcd_psa_psc_line.psl_prd_type
            and t01.pss_lin_code = rcd_psa_psc_line.psl_lin_code
            and t01.pss_con_code = rcd_psa_psc_line.psl_con_code
            and t01.pss_win_code != '*NONE'
          group by t01.pss_win_code
          order by t01.pss_win_code;

      /*-*/
      /* Local arrays
      /*-*/
      type typ_wact is table of csr_wact%rowtype index by binary_integer;
      tbl_wact typ_wact;

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
      if var_action != '*UPDLIN' and var_action != '*CRTLIN' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      var_pty_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
      var_con_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CONCDE')));
      var_smo_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SMOCDE')));
      var_upd_user := upper(par_user);
      var_upd_date := sysdate;
      if var_src_code != '*SCH' and var_src_code != '*ACT' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the production schedule
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
             psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') is currently locked');
      end;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Validation
      /*-*/
      if var_src_code = '*SCH' then
         var_count := 0;
         open csr_schd;
         fetch csr_schd into rcd_schd;
         if csr_schd%found then
            var_count := rcd_schd.wrk_count;
         end if;
         close csr_schd;
         if var_count != 0 then
            psa_gen_function.add_mesg_data('Production schedule line has actuals entered - unable to update');
         end if;
      else
         var_count := 0;
         open csr_actl;
         fetch csr_actl into rcd_actl;
         if csr_actl%found then
            var_count := rcd_actl.wrk_count;
         end if;
         close csr_actl;
         if var_count != 0 then
            psa_gen_function.add_mesg_data('Production schedule line has activities scheduled - unable to update');
         end if;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Validate the line configuration
      /*-*/
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
         if var_action = '*CRTLIN' and rcd_lcon.lco_con_status != '1' then
            psa_gen_function.add_mesg_data('Line configuration ('||var_lin_code||' / '||var_con_code||') must be status active to create a production schedule line');
         end if;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Validate the shift model
      /*-*/
      var_found := false;
      open csr_smod;
      fetch csr_smod into rcd_smod;
      if csr_smod%found then
         var_found := true;
      end if;
      close csr_smod;
      if var_found = false then
         psa_gen_function.add_mesg_data('Shift model ('||var_smo_code||') does not exist');
      else
         if var_action = '*CRTLIN' and rcd_smod.smd_smo_status != '1' then
            psa_gen_function.add_mesg_data('Shift model ('||var_smo_code||') must be status active to create a production schedule line');
         end if;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Validate the child relationships
      /*-*/
      obj_shf_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/LINSHF');
      for idx in 0..xmlDom.getLength(obj_shf_list)-1 loop
         obj_shf_node := xmlDom.item(obj_shf_list,idx);
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
               if var_action = '*CRTLIN' and rcd_cmod.cmd_cmo_status != '1' then
                  psa_gen_function.add_mesg_data('Crew model ('||var_cmo_code||') must be status active to create a production schedule line');
               end if;
               if var_action = '*CRTLIN' and rcd_cmod.cmd_prd_type != var_pty_code then
                  psa_gen_function.add_mesg_data('Crew model ('||var_cmo_code||') must belong to '||var_pty_code||'  to create a production schedule line');
               end if;
            end if;
         end if;
      end loop;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Update the production schedule type
      /*-*/
      update psa_psc_prod
         set psp_upd_user = var_upd_user,
             psp_upd_date = var_upd_date
       where psp_psc_code = var_psc_code
         and psp_psc_week = var_wek_code
         and psp_prd_type = var_pty_code;

      /*-*/
      /* Process the production schedule line
      /*-*/
      rcd_psa_psc_line.psl_psc_code := var_psc_code;
      rcd_psa_psc_line.psl_psc_week := var_wek_code;
      rcd_psa_psc_line.psl_prd_type := var_pty_code;
      rcd_psa_psc_line.psl_lin_code := var_lin_code;
      rcd_psa_psc_line.psl_con_code := var_con_code;
      rcd_psa_psc_line.psl_smo_code := var_smo_code;
      if var_action = '*UPDLIN' then
         update psa_psc_line
            set psl_smo_code = rcd_psa_psc_line.psl_smo_code
          where psl_psc_code = rcd_psa_psc_line.psl_psc_code
            and psl_psc_week = rcd_psa_psc_line.psl_psc_week
            and psl_prd_type = rcd_psa_psc_line.psl_prd_type
            and psl_lin_code = rcd_psa_psc_line.psl_lin_code
            and psl_con_code = rcd_psa_psc_line.psl_con_code;
         if sql%notfound then
            psa_gen_function.add_mesg_data('Production schedule line ('||rcd_psa_psc_line.psl_psc_code||' / '||rcd_psa_psc_line.psl_psc_week||' / '||rcd_psa_psc_line.psl_prd_type||' / '||rcd_psa_psc_line.psl_lin_code||' / '||rcd_psa_psc_line.psl_con_code||') no longer exists - unable to update');
            rollback;
            return;
         end if;
         delete from psa_psc_reso where psr_psc_code = rcd_psa_psc_line.psl_psc_code
                                    and psr_psc_week = rcd_psa_psc_line.psl_psc_week
                                    and psr_prd_type = rcd_psa_psc_line.psl_prd_type
                                    and psr_lin_code = rcd_psa_psc_line.psl_lin_code
                                    and psr_con_code = rcd_psa_psc_line.psl_con_code;
         delete from psa_psc_shft where pss_psc_code = rcd_psa_psc_line.psl_psc_code
                                    and pss_psc_week = rcd_psa_psc_line.psl_psc_week
                                    and pss_prd_type = rcd_psa_psc_line.psl_prd_type
                                    and pss_lin_code = rcd_psa_psc_line.psl_lin_code
                                    and pss_con_code = rcd_psa_psc_line.psl_con_code;
      elsif var_action = '*CRTLIN' then
         begin
            insert into psa_psc_line values rcd_psa_psc_line;
         exception
            when dup_val_on_index then
               psa_gen_function.add_mesg_data('Production schedule line ('||rcd_psa_psc_line.psl_psc_code||' / '||rcd_psa_psc_line.psl_psc_week||' / '||rcd_psa_psc_line.psl_prd_type||' / '||rcd_psa_psc_line.psl_lin_code||' / '||rcd_psa_psc_line.psl_con_code||') already exists - unable to create');
               rollback;
               return;
         end;
      end if;

      /*-*/
      /* Retrieve and insert the production date data
      /*-*/
      var_sav_date := null;
      open csr_date;
      fetch csr_date into rcd_date;
      if csr_date%found then
         var_sav_date := rcd_date.min_day_date;
      end if;
      close csr_date;

      /*-*/
      /* Retrieve and insert the shift data
      /*-*/
      var_day_date := var_sav_date;
      var_wrk_date := var_sav_date;
      var_wrk_code := '*NONE';
      obj_shf_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/LINSHF');
      for idx in 0..xmlDom.getLength(obj_shf_list)-1 loop
         obj_shf_node := xmlDom.item(obj_shf_list,idx);
         rcd_psa_psc_shft.pss_psc_code := rcd_psa_psc_line.psl_psc_code;
         rcd_psa_psc_shft.pss_psc_week := rcd_psa_psc_line.psl_psc_week;
         rcd_psa_psc_shft.pss_prd_type := rcd_psa_psc_line.psl_prd_type;
         rcd_psa_psc_shft.pss_lin_code := rcd_psa_psc_line.psl_lin_code;
         rcd_psa_psc_shft.pss_con_code := rcd_psa_psc_line.psl_con_code;
         rcd_psa_psc_shft.pss_smo_seqn := idx + 1;
         rcd_psa_psc_shft.pss_shf_code := upper(psa_from_xml(xslProcessor.valueOf(obj_shf_node,'@SHFCDE')));
         rcd_psa_psc_shft.pss_shf_date := var_day_date;
         rcd_psa_psc_shft.pss_shf_start := psa_to_number(xslProcessor.valueOf(obj_shf_node,'@SHFSTR'));
         rcd_psa_psc_shft.pss_shf_duration := psa_to_number(xslProcessor.valueOf(obj_shf_node,'@SHFDUR'));
         rcd_psa_psc_shft.pss_cmo_code := upper(psa_from_xml(xslProcessor.valueOf(obj_shf_node,'@CMOCDE')));
         rcd_psa_psc_shft.pss_str_bar := 0;
         rcd_psa_psc_shft.pss_str_bar := 0;
         rcd_psa_psc_shft.pss_win_code := '*NONE';
         rcd_psa_psc_shft.pss_win_type := '0';
         rcd_psa_psc_shft.pss_win_stim := null;
         rcd_psa_psc_shft.pss_win_etim := null;
         if rcd_psa_psc_shft.pss_cmo_code != '*NONE' then
            if var_wrk_code = '*NONE' then
               var_win_code := rcd_psa_psc_shft.pss_psc_week||'_'||to_char(rcd_psa_psc_shft.pss_smo_seqn,'fm00000');
               rcd_psa_psc_shft.pss_win_code := var_win_code;
               rcd_psa_psc_shft.pss_win_type := '1';
            else
               rcd_psa_psc_shft.pss_win_code := var_win_code;
               rcd_psa_psc_shft.pss_win_type := '2';
            end if;
         end if;
         var_wrk_code := rcd_psa_psc_shft.pss_cmo_code;
         var_bar_numb := (rcd_psa_psc_shft.pss_shf_duration / 60) * 4;
         if idx = 0 then
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
               rcd_psa_psc_reso.psr_psc_code := rcd_psa_psc_line.psl_psc_code;
               rcd_psa_psc_reso.psr_psc_week := rcd_psa_psc_line.psl_psc_week;
               rcd_psa_psc_reso.psr_prd_type := rcd_psa_psc_line.psl_prd_type;
               rcd_psa_psc_reso.psr_lin_code := rcd_psa_psc_line.psl_lin_code;
               rcd_psa_psc_reso.psr_con_code := rcd_psa_psc_line.psl_con_code;
               rcd_psa_psc_reso.psr_smo_seqn := rcd_psa_psc_shft.pss_smo_seqn;
               rcd_psa_psc_reso.psr_res_code := rcd_reso.cmr_res_code;
               rcd_psa_psc_reso.psr_res_qnty := rcd_reso.cmr_res_qnty;
               insert into psa_psc_reso values rcd_psa_psc_reso;
            end loop;
            close csr_reso;
         end if;
      end loop;
      open csr_wind;
      loop
         fetch csr_wind into rcd_wind;
         if csr_wind%notfound then
            exit;
         end if;
         update psa_psc_shft
            set pss_win_stim = rcd_wind.win_stim,
                pss_win_etim = rcd_wind.win_etim
          where pss_psc_code = rcd_psa_psc_line.psl_psc_code
            and pss_psc_week = rcd_psa_psc_line.psl_psc_week
            and pss_prd_type = rcd_psa_psc_line.psl_prd_type
            and pss_lin_code = rcd_psa_psc_line.psl_lin_code
            and pss_con_code = rcd_psa_psc_line.psl_con_code
            and pss_win_code = rcd_wind.pss_win_code;
      end loop;
      close csr_wind;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Assign the unattached production activities to the new production schedule line where possible
      /*-*/
      if var_src_code = '*SCH' and var_action = '*CRTLIN' then
         open csr_uact;
         loop
            fetch csr_uact into rcd_actv;
            if csr_uact%notfound then
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

               /*-*/
               /* Update the schedule production activity
               /*-*/
               rcd_actv.psa_sch_lin_code := rcd_mlin.mli_lin_code;
               rcd_actv.psa_sch_con_code := rcd_mlin.mli_con_code;
               rcd_actv.psa_sch_dft_flag := rcd_mlin.mli_dft_flag;
               rcd_actv.psa_sch_rra_code := rcd_mlin.mli_rra_code;
               rcd_actv.psa_sch_rra_unit := rcd_mlin.rrd_rra_units;
               rcd_actv.psa_sch_rra_effp := rcd_mlin.mli_rra_efficiency;
               rcd_actv.psa_sch_rra_wasp := rcd_mlin.mli_rra_wastage;
               rcd_actv.psa_act_lin_code := rcd_mlin.mli_lin_code;
               rcd_actv.psa_act_con_code := rcd_mlin.mli_con_code;
               rcd_actv.psa_act_dft_flag := rcd_mlin.mli_dft_flag;
               rcd_actv.psa_act_rra_code := rcd_mlin.mli_rra_code;
               rcd_actv.psa_act_rra_unit := rcd_mlin.rrd_rra_units;
               rcd_actv.psa_act_rra_effp := rcd_mlin.mli_rra_efficiency;
               rcd_actv.psa_act_rra_wasp := rcd_mlin.mli_rra_wastage;
               rcd_actv.psa_act_cal_unit := rcd_mlin.rrd_rra_units;
               rcd_actv.psa_act_cal_effp := rcd_mlin.mli_rra_efficiency;
               rcd_actv.psa_act_cal_wasp := rcd_mlin.mli_rra_wastage;
               rcd_actv.psa_sch_chg_flag := '0';
               rcd_actv.psa_sch_chg_mins := 0;
               rcd_actv.psa_act_chg_flag := '0';
               rcd_actv.psa_act_chg_mins := 0;
               if rcd_mlin.lde_lin_events = '1' then
                  rcd_actv.psa_sch_chg_flag := '1';
                  rcd_actv.psa_sch_chg_mins := 30;
                  rcd_actv.psa_act_chg_flag := '1';
                  rcd_actv.psa_act_chg_mins := 30;
               end if;
               update psa_psc_actv
                  set psa_sch_chg_flag = rcd_actv.psa_sch_chg_flag,
                      psa_sch_chg_mins = rcd_actv.psa_sch_chg_mins,
                      psa_sch_lin_code = rcd_actv.psa_sch_lin_code,
                      psa_sch_con_code = rcd_actv.psa_sch_con_code,
                      psa_sch_dft_flag = rcd_actv.psa_sch_dft_flag,
                      psa_sch_rra_code = rcd_actv.psa_sch_rra_code,
                      psa_sch_rra_unit = rcd_actv.psa_sch_rra_unit,
                      psa_sch_rra_effp = rcd_actv.psa_sch_rra_effp,
                      psa_sch_rra_wasp = rcd_actv.psa_sch_rra_wasp,
                      psa_act_chg_flag = rcd_actv.psa_act_chg_flag,
                      psa_act_chg_mins = rcd_actv.psa_act_chg_mins,
                      psa_act_lin_code = rcd_actv.psa_act_lin_code,
                      psa_act_con_code = rcd_actv.psa_act_con_code,
                      psa_act_dft_flag = rcd_actv.psa_act_dft_flag,
                      psa_act_rra_code = rcd_actv.psa_act_rra_code,
                      psa_act_rra_unit = rcd_actv.psa_act_rra_unit,
                      psa_act_rra_effp = rcd_actv.psa_act_rra_effp,
                      psa_act_rra_wasp = rcd_actv.psa_act_rra_wasp,
                      psa_act_cal_unit = rcd_actv.psa_act_cal_unit,
                      psa_act_cal_effp = rcd_actv.psa_act_cal_effp,
                      psa_act_cal_wasp = rcd_actv.psa_act_cal_wasp
                where psa_act_code = rcd_actv.psa_act_code;

               /*-*/
               /* Update the schedule production activity
               /*-*/
               calc_schedule(rcd_actv.psa_act_code);

            end if;
            close csr_mlin;

         end loop;
         close csr_uact;
      end if;

      /*-*/
      /* Realign attached activities for updated production schedule line
      /*-*/
      if var_action = '*UPDLIN' then

         /*-*/
         /* Retrieve the line window data
         /*-*/
         tbl_wact.delete;
         open csr_wact;
         fetch csr_wact bulk collect into tbl_wact;
         close csr_wact;

         /*-*/
         /* Reset the shift window sequences
         /*-*/
         for idx in 1..tbl_wact.count loop
            tbl_wact(idx).win_seqn := 0;
         end loop;

         /*-*/
         /* Update the line activities
         /*-*/
         open csr_sact;
         loop
            fetch csr_sact into rcd_sact;
            if csr_sact%notfound then
               exit;
            end if;
            var_win_flag := false;
            for idx in 1..tbl_wact.count loop
               if tbl_wact(idx).win_code = rcd_sact.psa_act_win_code then
                  tbl_wact(idx).win_seqn := tbl_wact(idx).win_seqn + 1;
                  var_win_code := tbl_wact(idx).win_code;
                  var_win_seqn := tbl_wact(idx).win_seqn;
                  var_win_flag := true;
                  exit;
               end if;
            end loop;
            if var_win_flag = false then
               for idx in reverse 1..tbl_wact.count loop
                  if tbl_wact(idx).win_stim <= rcd_sact.psa_act_str_time then
                     tbl_wact(idx).win_seqn := tbl_wact(idx).win_seqn + 1;
                     var_win_code := tbl_wact(idx).win_code;
                     var_win_seqn := tbl_wact(idx).win_seqn;
                     exit;
                  end if;
               end loop;
            end if;
            update psa_psc_actv
               set psa_act_win_code = var_win_code,
                   psa_act_win_seqn = var_win_seqn
             where psa_act_code = rcd_sact.psa_act_code;
         end loop;
         close csr_sact;

         /*-*/
         /* Align the shift windows
         /*-*/
         for idx in 1..tbl_wact.count loop
            align_activity(rcd_psa_psc_line.psl_psc_code,
                           rcd_psa_psc_line.psl_prd_type,
                           rcd_psa_psc_line.psl_lin_code,
                           rcd_psa_psc_line.psl_con_code,
                           tbl_wact(idx).win_code);
         end loop;

      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - UPDATE_LINE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_line;

   /***************************************************/
   /* This procedure performs the update time routine */
   /***************************************************/
   procedure update_time(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      var_src_code varchar2(4);
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_pty_code varchar2(32);
      var_lin_code varchar2(32);
      var_con_code varchar2(32);
      var_win_code varchar2(32);
      var_win_seqn number;
      var_act_code number;
      var_sac_code varchar2(32);
      var_dur_mins number;
      var_str_time date;
      var_end_time date;
      var_com_text varchar2(256 char);
      var_upd_user varchar2(30);
      var_upd_date date;
      rcd_actv psa_psc_actv%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = var_psc_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_actv is
         select t01.*
           from psa_psc_actv t01
          where t01.psa_act_code = var_act_code;

      cursor csr_time is
         select t01.*
           from psa_sac_defn t01
          where t01.sad_sac_code = var_sac_code;
      rcd_time csr_time%rowtype;

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
      if var_action != '*UPDACT' and var_action != '*CRTACT' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      var_pty_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
      var_con_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CONCDE')));
      var_win_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WINCDE')));
      var_win_seqn := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@WINSEQ'));
      var_act_code := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@ACTCDE'));
      var_sac_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SACCDE')));
      var_dur_mins := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@DURMIN'));
      var_str_time := psa_to_date(xslProcessor.valueOf(obj_psa_request,'@STRTIM'),'dd/mm/yyyy hh24:mi');
      var_end_time := psa_to_date(xslProcessor.valueOf(obj_psa_request,'@ENDTIM'),'dd/mm/yyyy hh24:mi');
      var_com_text := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@COMTXT'));
      var_upd_user := upper(par_user);
      var_upd_date := sysdate;
      if var_src_code != '*SCH' and var_src_code != '*ACT' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the production schedule
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
             psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') is currently locked');
      end;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the production schedule activity when required
      /*-*/
      if var_action = '*UPDACT' then
         var_found := false;
         open csr_actv;
         fetch csr_actv into rcd_actv;
         if csr_actv%found then
            var_found := true;
         end if;
         close csr_actv;
         if var_found = false then
            psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') does not exist');
         else
            var_sac_code := rcd_actv.psa_sac_code;
            if var_src_code = '*SCH' then
               if rcd_actv.psa_act_win_code = '*NONE' then
                  psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') is not attached to the schedule');
               else
                  if rcd_actv.psa_act_ent_flag = '1' then
                     psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') has actuals entered - unable to update schedule');
                  end if;
                  if var_lin_code != rcd_actv.psa_sch_lin_code or var_con_code != rcd_actv.psa_sch_con_code then
                     psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') is no longer attached to the schedule line configuration');
                  end if;
               end if;
            else
               if rcd_actv.psa_act_win_code = '*NONE' then
                  psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') is not attached to the schedule');
               else
                  if var_lin_code != rcd_actv.psa_act_lin_code or var_con_code != rcd_actv.psa_act_con_code then
                     psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') is no longer attached to the actual line configuration');
                  end if;
               end if;
            end if;
         end if;
         if psa_gen_function.get_mesg_count != 0 then
            rollback;
            return;
         end if;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if var_src_code = '*SCH' then
         if var_dur_mins is null or var_dur_mins <= 0 then
            psa_gen_function.add_mesg_data('Duration minutes must be greater than zero');
         end if;
      else
         if var_str_time is null then
            psa_gen_function.add_mesg_data('Start time must be a valid date in the format DD/MM/YYYY HH24:MI');
         end if;
         if var_end_time is null then
            psa_gen_function.add_mesg_data('End time must be a valid date in the format DD/MM/YYYY HH24:MI');
         end if;
         if not(var_str_time is null) and not(var_end_time is null) and var_str_time >= var_end_time then
            psa_gen_function.add_mesg_data('End time must be greater than the start time');
         end if;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Validate the parent relationships
      /*-*/
      var_found := false;
      open csr_time;
      fetch csr_time into rcd_time;
      if csr_time%found then
         var_found := true;
      end if;
      close csr_time;
      if var_found = false then
         psa_gen_function.add_mesg_data('Time activity ('||var_sac_code||') does not exist');
      else
         if rcd_time.sad_sac_status != '1' then
            psa_gen_function.add_mesg_data('Time activity ('||var_sac_code||') must be active');
         end if;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Update the production schedule type
      /*-*/
      update psa_psc_prod
         set psp_upd_user = var_upd_user,
             psp_upd_date = var_upd_date
       where psp_psc_code = var_psc_code
         and psp_psc_week = var_wek_code
         and psp_prd_type = var_pty_code;

      /*-*/
      /* Update/create the production schedule activity
      /*-*/
      if var_action = '*UPDACT' then
         if var_src_code = '*SCH' then
            update psa_psc_actv
               set psa_upd_user = var_upd_user,
                   psa_upd_date = var_upd_date,
                   psa_sac_name = rcd_time.sad_sac_name,
                   psa_sch_ent_flag = '1',
                   psa_act_ent_flag = '0',
                   psa_sch_dur_mins = var_dur_mins,
                   psa_act_dur_mins = var_dur_mins
             where psa_act_code = rcd_actv.psa_act_code;
         else
            rcd_actv.psa_act_dur_mins := var_dur_mins;
            update psa_psc_actv
               set psa_upd_user = var_upd_user,
                   psa_upd_date = var_upd_date,
                   psa_sac_name = rcd_time.sad_sac_name,
                   psa_act_ent_flag = '1',
                   psa_act_str_time = var_str_time,
                   psa_act_end_time = var_end_time,
                   psa_act_dur_mins = round((var_end_time - var_str_time) * 1440, 0),
                   psa_act_com_text = var_com_text
             where psa_act_code = rcd_actv.psa_act_code;
         end if;
      elsif var_action = '*CRTACT' then
         select psa_act_sequence.nextval into rcd_actv.psa_act_code from dual;
         rcd_actv.psa_psc_code := var_psc_code;
         rcd_actv.psa_psc_week := var_wek_code;
         rcd_actv.psa_prd_type := var_pty_code;
         rcd_actv.psa_act_type := 'T';
         rcd_actv.psa_upd_user := var_upd_user;
         rcd_actv.psa_upd_date := var_upd_date;
         rcd_actv.psa_sch_ent_flag := '0';
         rcd_actv.psa_sch_chg_flag := '0';
         rcd_actv.psa_sch_lin_code := null;
         rcd_actv.psa_sch_con_code := null;
         rcd_actv.psa_sch_dft_flag := null;
         rcd_actv.psa_sch_rra_code := null;
         rcd_actv.psa_sch_rra_unit := null;
         rcd_actv.psa_sch_rra_effp := null;
         rcd_actv.psa_sch_rra_wasp := null;
         rcd_actv.psa_sch_dur_mins := null;
         rcd_actv.psa_sch_chg_mins := null;
         rcd_actv.psa_act_ent_flag := '0';
         rcd_actv.psa_act_chg_flag := '0';
         rcd_actv.psa_act_lin_code := null;
         rcd_actv.psa_act_con_code := null;
         rcd_actv.psa_act_dft_flag := null;
         rcd_actv.psa_act_rra_code := null;
         rcd_actv.psa_act_rra_unit := null;
         rcd_actv.psa_act_rra_effp := null;
         rcd_actv.psa_act_rra_wasp := null;
         rcd_actv.psa_act_cal_unit := null;
         rcd_actv.psa_act_cal_effp := null;
         rcd_actv.psa_act_cal_wasp := null;
         rcd_actv.psa_act_win_code := null;
         rcd_actv.psa_act_win_seqn := null;
         rcd_actv.psa_act_win_flow := null;
         rcd_actv.psa_act_str_time := null;
         rcd_actv.psa_act_chg_time := null;
         rcd_actv.psa_act_end_time := null;
         rcd_actv.psa_act_dur_mins := null;
         rcd_actv.psa_act_chg_mins := null;
         rcd_actv.psa_act_com_text := null;
         rcd_actv.psa_var_dur_mins := null;
         rcd_actv.psa_var_chg_mins := null;
         rcd_actv.psa_sac_code := var_sac_code;
         rcd_actv.psa_sac_name := rcd_time.sad_sac_name;
         rcd_actv.psa_mat_code := null;
         rcd_actv.psa_mat_name := null;
         rcd_actv.psa_mat_type := null;
         rcd_actv.psa_mat_usage := null;
         rcd_actv.psa_mat_uom := null;
         rcd_actv.psa_mat_gro_weight := null;
         rcd_actv.psa_mat_net_weight := null;
         rcd_actv.psa_mat_unt_case := null;
         rcd_actv.psa_mat_sch_priority := null;
         rcd_actv.psa_mat_cas_pallet := null;
         rcd_actv.psa_mat_bch_quantity := null;
         rcd_actv.psa_mat_yld_percent := null;
         rcd_actv.psa_mat_yld_value := null;
         rcd_actv.psa_mat_pck_percent := null;
         rcd_actv.psa_mat_pck_weight := null;
         rcd_actv.psa_mat_bch_weight := null;
         rcd_actv.psa_mat_sap_qty := null;
         rcd_actv.psa_mat_req_qty := null;
         rcd_actv.psa_mat_req_plt_qty := null;
         rcd_actv.psa_mat_req_cas_qty := null;
         rcd_actv.psa_mat_req_pch_qty := null;
         rcd_actv.psa_mat_req_mix_qty := null;
         rcd_actv.psa_mat_req_ton_qty := null;
         rcd_actv.psa_mat_req_dur_min := null;
         rcd_actv.psa_mat_sch_qty := null;
         rcd_actv.psa_mat_sch_was := null;
         rcd_actv.psa_mat_sch_plt_qty := null;
         rcd_actv.psa_mat_sch_cas_qty := null;
         rcd_actv.psa_mat_sch_pch_qty := null;
         rcd_actv.psa_mat_sch_mix_qty := null;
         rcd_actv.psa_mat_sch_ton_qty := null;
         rcd_actv.psa_mat_sch_plt_was := null;
         rcd_actv.psa_mat_sch_cas_was := null;
         rcd_actv.psa_mat_sch_pch_was := null;
         rcd_actv.psa_mat_sch_mix_was := null;
         rcd_actv.psa_mat_sch_ton_was := null;
         rcd_actv.psa_mat_sch_dur_min := null;
         rcd_actv.psa_mat_act_qty := null;
         rcd_actv.psa_mat_act_was := null;
         rcd_actv.psa_mat_act_plt_qty := null;
         rcd_actv.psa_mat_act_cas_qty := null;
         rcd_actv.psa_mat_act_pch_qty := null;
         rcd_actv.psa_mat_act_mix_qty := null;
         rcd_actv.psa_mat_act_ton_qty := null;
         rcd_actv.psa_mat_act_plt_was := null;
         rcd_actv.psa_mat_act_cas_was := null;
         rcd_actv.psa_mat_act_pch_was := null;
         rcd_actv.psa_mat_act_mix_was := null;
         rcd_actv.psa_mat_act_ton_was := null;
         rcd_actv.psa_mat_act_dur_min := null;
         rcd_actv.psa_mat_inv_qty := null;
         rcd_actv.psa_mat_inv_plt_qty := null;
         rcd_actv.psa_mat_inv_cas_qty := null;
         rcd_actv.psa_mat_inv_pch_qty := null;
         rcd_actv.psa_mat_inv_ton_qty := null;
         rcd_actv.psa_mat_var_plt_qty := null;
         rcd_actv.psa_mat_var_cas_qty := null;
         rcd_actv.psa_mat_var_pch_qty := null;
         rcd_actv.psa_mat_var_mix_qty := null;
         rcd_actv.psa_mat_var_ton_qty := null;
         rcd_actv.psa_mat_var_plt_was := null;
         rcd_actv.psa_mat_var_cas_was := null;
         rcd_actv.psa_mat_var_pch_was := null;
         rcd_actv.psa_mat_var_mix_was := null;
         rcd_actv.psa_mat_var_ton_was := null;
         rcd_actv.psa_mat_var_dur_min := null;
         if var_src_code = '*SCH' then
            rcd_actv.psa_sch_ent_flag := '1';
            rcd_actv.psa_sch_lin_code := var_lin_code;
            rcd_actv.psa_sch_con_code := var_con_code;
            rcd_actv.psa_sch_dur_mins := var_dur_mins;
            rcd_actv.psa_act_lin_code := var_lin_code;
            rcd_actv.psa_act_con_code := var_con_code;
            rcd_actv.psa_act_win_code := var_win_code;
            rcd_actv.psa_act_win_seqn := var_win_seqn + .10;
            rcd_actv.psa_act_dur_mins := var_dur_mins;
         else
            rcd_actv.psa_act_ent_flag := '1';
            rcd_actv.psa_act_lin_code := var_lin_code;
            rcd_actv.psa_act_con_code := var_con_code;
            rcd_actv.psa_act_win_code := var_win_code;
            rcd_actv.psa_act_win_seqn := var_win_seqn + .10;
            rcd_actv.psa_act_str_time := var_str_time;
            rcd_actv.psa_act_end_time := var_end_time;
            rcd_actv.psa_act_dur_mins := round((var_end_time - var_str_time) * 1440, 0);
            rcd_actv.psa_act_com_text := var_com_text;
         end if;
         insert into psa_psc_actv values rcd_actv;
      end if;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Align the shift window actual activities
      /*-*/
      align_activity(var_psc_code,
                   var_pty_code,
                   var_lin_code,
                   var_con_code,
                   var_win_code);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - UPDATE_TIME - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_time;

   /*********************************************************/
   /* This procedure performs the update production routine */
   /*********************************************************/
   procedure update_production(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      obj_ent_list xmlDom.domNodeList;
      obj_ent_node xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      var_src_code varchar2(4);
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_pty_code varchar2(32);
      var_lin_code varchar2(32);
      var_con_code varchar2(32);
      var_win_code varchar2(32);
      var_win_seqn number;
      var_act_code number;
      var_mat_code varchar2(32);
      var_req_qnty number;
      var_req_wast number;
      var_chg_flag varchar2(1);
      var_chg_mins number;
      var_str_time date;
      var_end_time date;
      var_com_text varchar2(256 char);
      var_upd_user varchar2(30);
      var_upd_date date;
      rcd_actv psa_psc_actv%rowtype;
      rcd_enty psa_psc_enty%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = var_psc_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_actv is
         select t01.*
           from psa_psc_actv t01
          where t01.psa_act_code = var_act_code;

      cursor csr_mdef is
         select t01.mde_mat_code,
                t01.mde_mat_name,
                t01.mde_mat_type,
                t01.mde_mat_usage,
                t01.mde_mat_uom,
                t01.mde_gro_weight,
                t01.mde_net_weight,
                t01.mde_psa_ucas,
                t01.mde_mat_status,
                t02.mpr_prd_type,
                t02.mpr_sch_priority,
                t02.mpr_cas_pallet,
                t02.mpr_bch_quantity,
                t02.mpr_yld_percent,
                t02.mpr_yld_value,
                t02.mpr_pck_percent,
                t02.mpr_pck_weight,
                t02.mpr_bch_weight
           from psa_mat_defn t01,
                psa_mat_prod t02
          where t01.mde_mat_code = t02.mpr_mat_code(+)
            and var_pty_code = t02.mpr_prd_type(+)
            and t01.mde_mat_code = var_mat_code;
      rcd_mdef csr_mdef%rowtype;

      cursor csr_mlin is
         select t01.mli_lin_code,
                t01.mli_con_code,
                t01.mli_dft_flag,
                t01.mli_rra_code,
                decode(t01.mli_rra_efficiency,null,100,0,100,t01.mli_rra_efficiency) as mli_rra_efficiency,
                decode(t01.mli_rra_wastage,null,0,t01.mli_rra_wastage) as mli_rra_wastage,
                decode(t02.rrd_rra_units,null,1,t02.rrd_rra_units) as rrd_rra_units,
                nvl(t03.lde_lin_events,'0') as lde_lin_events
           from psa_mat_line t01,
                psa_rra_defn t02,
                psa_lin_defn t03
          where t01.mli_rra_code = t02.rrd_rra_code
            and t01.mli_lin_code = t03.lde_lin_code
            and t01.mli_mat_code = var_mat_code
            and t01.mli_prd_type = var_pty_code
            and t01.mli_lin_code = var_lin_code
            and t01.mli_con_code = var_con_code;
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
      if var_action != '*UPDACT' and var_action != '*CRTACT' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      var_pty_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
      var_con_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CONCDE')));
      var_win_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WINCDE')));
      var_win_seqn := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@WINSEQ'));
      var_act_code := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@ACTCDE'));
      var_mat_code := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@MATCDE'));
      var_req_qnty := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@REQQTY'));
      var_chg_flag := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CHGFLG'));
      var_chg_mins := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@CHGMIN'));
      var_str_time := psa_to_date(xslProcessor.valueOf(obj_psa_request,'@STRTIM'),'dd/mm/yyyy hh24:mi');
      var_end_time := psa_to_date(xslProcessor.valueOf(obj_psa_request,'@ENDTIM'),'dd/mm/yyyy hh24:mi');
      var_com_text := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@COMTXT'));
      var_upd_user := upper(par_user);
      var_upd_date := sysdate;
      if var_src_code != '*SCH' and var_src_code != '*ACT' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the production schedule
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
             psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') is currently locked');
      end;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the production schedule activity when required
      /*-*/
      if var_action = '*UPDACT' then
         var_found := false;
         open csr_actv;
         fetch csr_actv into rcd_actv;
         if csr_actv%found then
            var_found := true;
         end if;
         close csr_actv;
         if var_found = false then
            psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') does not exist');
         else
            if var_src_code = '*SCH' then
               if rcd_actv.psa_act_win_code = '*NONE' then
                  psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') is not attached to the schedule');
               else
                  if rcd_actv.psa_act_ent_flag = '1' then
                     psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') has actuals entered - unable to update schedule');
                  end if;
                  if var_lin_code != rcd_actv.psa_sch_lin_code or var_con_code != rcd_actv.psa_sch_con_code then
                     psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') is no longer attached to the schedule line configuration');
                  end if;
               end if;
            else
               if rcd_actv.psa_act_win_code = '*NONE' then
                  psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') is not attached to the schedule');
               else
                  if var_lin_code != rcd_actv.psa_act_lin_code or var_con_code != rcd_actv.psa_act_con_code then
                     psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') is no longer attached to the actual line configuration');
                  end if;
               end if;
            end if;
         end if;
         if psa_gen_function.get_mesg_count != 0 then
            rollback;
            return;
         end if;
      end if;

      /*-*/
      /* Retrieve the production line data when required
      /*-*/
      if var_action = '*CRTACT' then
         var_found := false;
         open csr_mdef;
         fetch csr_mdef into rcd_mdef;
         if csr_mdef%found then
            var_found := true;
         end if;
         close csr_mdef;
         if var_found = false then
            psa_gen_function.add_mesg_data('Production schedule activity material ('||rcd_actv.psa_mat_code||') does not have configuration for selected line configuration');
         else
            if rcd_mdef.mde_mat_status != '*ACTIVE' and rcd_mdef.mde_mat_status != '*CHG' and rcd_mdef.mde_mat_status != '*DEL' then
               psa_gen_function.add_mesg_data('Production schedule activity material ('||var_mat_code||') must be status *ACTIVE, *CHG or *DEL');
            end if;
            if rcd_mdef.mpr_prd_type is null then
               psa_gen_function.add_mesg_data('Production schedule activity material ('||var_mat_code||') is not configured for this production type');
            end if;
         end if;
         if psa_gen_function.get_mesg_count = 0 then
            var_found := false;
            open csr_mlin;
            fetch csr_mlin into rcd_mlin;
            if csr_mlin%found then
               var_found := true;
            end if;
            close csr_mlin;
            if var_found = false then
               psa_gen_function.add_mesg_data('Production schedule activity material ('||var_mat_code||') does not have configuration for selected line configuration');
            end if;
         end if;
         if psa_gen_function.get_mesg_count != 0 then
            rollback;
            return;
         end if;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if var_src_code = '*SCH' then
         if var_req_qnty is null or var_req_qnty <= 0 then
            psa_gen_function.add_mesg_data('Requested quantity must be greater than zero');
         end if;
      else
         if var_str_time is null then
            psa_gen_function.add_mesg_data('Start time must be a valid date in the format DD/MM/YYYY HH24:MI');
         end if;
         if var_end_time is null then
            psa_gen_function.add_mesg_data('End time must be a valid date in the format DD/MM/YYYY HH24:MI');
         end if;
         if not(var_str_time is null) and not(var_end_time is null) and var_str_time >= var_end_time then
            psa_gen_function.add_mesg_data('End time must be greater than the start time');
         end if;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Update the production schedule data
      /*-*/
      update psa_psc_prod
         set psp_upd_user = var_upd_user,
             psp_upd_date = var_upd_date
       where psp_psc_code = var_psc_code
         and psp_psc_week = var_wek_code
         and psp_prd_type = var_pty_code;

      /*-*/
      /* Update/create the production schedule activity
      /*-*/
      if var_action = '*UPDACT' then
         if var_src_code = '*SCH' then
            rcd_actv.psa_mat_req_qty := var_req_qnty;
            rcd_actv.psa_sch_chg_flag := '0';
            rcd_actv.psa_sch_chg_mins := 0;
            rcd_actv.psa_act_chg_flag := '0';
            rcd_actv.psa_act_chg_mins := 0;
            if var_chg_flag = '1' then
               rcd_actv.psa_sch_chg_flag := '1';
               rcd_actv.psa_sch_chg_mins := var_chg_mins;
               rcd_actv.psa_act_chg_flag := '1';
               rcd_actv.psa_act_chg_mins := var_chg_mins;
            end if;
            update psa_psc_actv
               set psa_upd_user = var_upd_user,
                   psa_upd_date = var_upd_date,
                   psa_sch_chg_flag = rcd_actv.psa_sch_chg_flag,
                   psa_sch_chg_mins = rcd_actv.psa_sch_chg_mins,
                   psa_sch_ent_flag = '1',
                   psa_act_ent_flag = '0',
                   psa_act_chg_flag = rcd_actv.psa_act_chg_flag,
                   psa_act_chg_mins = rcd_actv.psa_act_chg_mins,
                   psa_mat_req_qty = rcd_actv.psa_mat_req_qty
             where psa_act_code = rcd_actv.psa_act_code;
         else
            rcd_actv.psa_act_chg_flag := '0';
            rcd_actv.psa_act_chg_mins := 0;
            if var_chg_flag = '1' then
               rcd_actv.psa_act_chg_flag := '1';
               rcd_actv.psa_act_chg_mins := var_chg_mins;
            end if;
            rcd_actv.psa_act_str_time := var_str_time;
            rcd_actv.psa_act_end_time := var_end_time;
            rcd_actv.psa_act_com_text := var_com_text;
            update psa_psc_actv
               set psa_upd_user = var_upd_user,
                   psa_upd_date = var_upd_date,
                   psa_act_ent_flag = '1',
                   psa_act_chg_flag = rcd_actv.psa_act_chg_flag,
                   psa_act_chg_mins = rcd_actv.psa_act_chg_mins,
                   psa_act_str_time = rcd_actv.psa_act_str_time,
                   psa_act_end_time = rcd_actv.psa_act_end_time,
                   psa_act_com_text = rcd_actv.psa_act_com_text
             where psa_act_code = rcd_actv.psa_act_code;
         end if;
      elsif var_action = '*CRTACT' then
         select psa_act_sequence.nextval into rcd_actv.psa_act_code from dual;
         rcd_actv.psa_psc_code := var_psc_code;
         rcd_actv.psa_psc_week := var_wek_code;
         rcd_actv.psa_prd_type := var_pty_code;
         rcd_actv.psa_act_type := 'P';
         rcd_actv.psa_upd_user := var_upd_user;
         rcd_actv.psa_upd_date := var_upd_date;
         rcd_actv.psa_sch_ent_flag := '0';
         rcd_actv.psa_sch_chg_flag := '0';
         rcd_actv.psa_sch_lin_code := null;
         rcd_actv.psa_sch_con_code := null;
         rcd_actv.psa_sch_dft_flag := null;
         rcd_actv.psa_sch_rra_code := null;
         rcd_actv.psa_sch_rra_unit := null;
         rcd_actv.psa_sch_rra_effp := null;
         rcd_actv.psa_sch_rra_wasp := null;
         rcd_actv.psa_sch_dur_mins := 0;
         rcd_actv.psa_sch_chg_mins := 0;
         rcd_actv.psa_act_ent_flag := '0';
         rcd_actv.psa_act_chg_flag := '0';
         rcd_actv.psa_act_lin_code := null;
         rcd_actv.psa_act_con_code := null;
         rcd_actv.psa_act_dft_flag := null;
         rcd_actv.psa_act_rra_code := null;
         rcd_actv.psa_act_rra_unit := null;
         rcd_actv.psa_act_rra_effp := null;
         rcd_actv.psa_act_rra_wasp := null;
         rcd_actv.psa_act_cal_unit := null;
         rcd_actv.psa_act_cal_effp := null;
         rcd_actv.psa_act_cal_wasp := null;
         rcd_actv.psa_act_win_code := null;
         rcd_actv.psa_act_win_seqn := null;
         rcd_actv.psa_act_win_flow := null;
         rcd_actv.psa_act_str_time := null;
         rcd_actv.psa_act_chg_time := null;
         rcd_actv.psa_act_end_time := null;
         rcd_actv.psa_act_dur_mins := 0;
         rcd_actv.psa_act_chg_mins := 0;
         rcd_actv.psa_act_com_text := null;
         rcd_actv.psa_var_dur_mins := 0;
         rcd_actv.psa_var_chg_mins := 0;
         rcd_actv.psa_sac_code := null;
         rcd_actv.psa_sac_name := null;
         rcd_actv.psa_mat_code := rcd_mdef.mde_mat_code;
         rcd_actv.psa_mat_name := rcd_mdef.mde_mat_name;
         rcd_actv.psa_mat_type := rcd_mdef.mde_mat_type;
         rcd_actv.psa_mat_usage := rcd_mdef.mde_mat_usage;
         rcd_actv.psa_mat_uom := rcd_mdef.mde_mat_uom;
         rcd_actv.psa_mat_gro_weight := rcd_mdef.mde_gro_weight;
         rcd_actv.psa_mat_net_weight := rcd_mdef.mde_net_weight;
         rcd_actv.psa_mat_unt_case := rcd_mdef.mde_psa_ucas;
         rcd_actv.psa_mat_sch_priority := rcd_mdef.mpr_sch_priority;
         rcd_actv.psa_mat_cas_pallet := rcd_mdef.mpr_cas_pallet;
         rcd_actv.psa_mat_bch_quantity := rcd_mdef.mpr_bch_quantity;
         rcd_actv.psa_mat_yld_percent := rcd_mdef.mpr_yld_percent;
         rcd_actv.psa_mat_yld_value := rcd_mdef.mpr_yld_value;
         rcd_actv.psa_mat_pck_percent := rcd_mdef.mpr_pck_percent;
         rcd_actv.psa_mat_pck_weight := rcd_mdef.mpr_pck_weight;
         rcd_actv.psa_mat_bch_weight := rcd_mdef.mpr_bch_weight;
         rcd_actv.psa_mat_sap_qty := 0;
         rcd_actv.psa_mat_req_qty := 0;
         rcd_actv.psa_mat_req_plt_qty := 0;
         rcd_actv.psa_mat_req_cas_qty := 0;
         rcd_actv.psa_mat_req_pch_qty := 0;
         rcd_actv.psa_mat_req_mix_qty := 0;
         rcd_actv.psa_mat_req_ton_qty := 0;
         rcd_actv.psa_mat_req_dur_min := 0;
         rcd_actv.psa_mat_sch_qty := 0;
         rcd_actv.psa_mat_sch_was := 0;
         rcd_actv.psa_mat_sch_plt_qty := 0;
         rcd_actv.psa_mat_sch_cas_qty := 0;
         rcd_actv.psa_mat_sch_pch_qty := 0;
         rcd_actv.psa_mat_sch_mix_qty := 0;
         rcd_actv.psa_mat_sch_ton_qty := 0;
         rcd_actv.psa_mat_sch_plt_was := 0;
         rcd_actv.psa_mat_sch_cas_was := 0;
         rcd_actv.psa_mat_sch_pch_was := 0;
         rcd_actv.psa_mat_sch_mix_was := 0;
         rcd_actv.psa_mat_sch_ton_was := 0;
         rcd_actv.psa_mat_sch_dur_min := 0;
         rcd_actv.psa_mat_act_qty := 0;
         rcd_actv.psa_mat_act_was := 0;
         rcd_actv.psa_mat_act_plt_qty := 0;
         rcd_actv.psa_mat_act_cas_qty := 0;
         rcd_actv.psa_mat_act_pch_qty := 0;
         rcd_actv.psa_mat_act_mix_qty := 0;
         rcd_actv.psa_mat_act_ton_qty := 0;
         rcd_actv.psa_mat_act_plt_was := 0;
         rcd_actv.psa_mat_act_cas_was := 0;
         rcd_actv.psa_mat_act_pch_was := 0;
         rcd_actv.psa_mat_act_mix_was := 0;
         rcd_actv.psa_mat_act_ton_was := 0;
         rcd_actv.psa_mat_act_dur_min := 0;
         rcd_actv.psa_mat_inv_qty := 0;
         rcd_actv.psa_mat_inv_plt_qty := 0;
         rcd_actv.psa_mat_inv_cas_qty := 0;
         rcd_actv.psa_mat_inv_pch_qty := 0;
         rcd_actv.psa_mat_inv_ton_qty := 0;
         rcd_actv.psa_mat_var_plt_qty := 0;
         rcd_actv.psa_mat_var_cas_qty := 0;
         rcd_actv.psa_mat_var_pch_qty := 0;
         rcd_actv.psa_mat_var_mix_qty := 0;
         rcd_actv.psa_mat_var_ton_qty := 0;
         rcd_actv.psa_mat_var_plt_was := 0;
         rcd_actv.psa_mat_var_cas_was := 0;
         rcd_actv.psa_mat_var_pch_was := 0;
         rcd_actv.psa_mat_var_mix_was := 0;
         rcd_actv.psa_mat_var_ton_was := 0;
         rcd_actv.psa_mat_var_dur_min := 0;
         if var_src_code = '*SCH' then
            rcd_actv.psa_sch_ent_flag := '1';
            rcd_actv.psa_sch_lin_code := rcd_mlin.mli_lin_code;
            rcd_actv.psa_sch_con_code := rcd_mlin.mli_con_code;
            rcd_actv.psa_sch_dft_flag := rcd_mlin.mli_dft_flag;
            rcd_actv.psa_sch_rra_code := rcd_mlin.mli_rra_code;
            rcd_actv.psa_sch_rra_unit := rcd_mlin.rrd_rra_units;
            rcd_actv.psa_sch_rra_effp := rcd_mlin.mli_rra_efficiency;
            rcd_actv.psa_sch_rra_wasp := rcd_mlin.mli_rra_wastage;
            rcd_actv.psa_act_lin_code := rcd_mlin.mli_lin_code;
            rcd_actv.psa_act_con_code := rcd_mlin.mli_con_code;
            rcd_actv.psa_act_dft_flag := rcd_mlin.mli_dft_flag;
            rcd_actv.psa_act_rra_code := rcd_mlin.mli_rra_code;
            rcd_actv.psa_act_rra_unit := rcd_mlin.rrd_rra_units;
            rcd_actv.psa_act_rra_effp := rcd_mlin.mli_rra_efficiency;
            rcd_actv.psa_act_rra_wasp := rcd_mlin.mli_rra_wastage;
            rcd_actv.psa_act_cal_unit := rcd_mlin.rrd_rra_units;
            rcd_actv.psa_act_cal_effp := rcd_mlin.mli_rra_efficiency;
            rcd_actv.psa_act_cal_wasp := rcd_mlin.mli_rra_wastage;
            rcd_actv.psa_act_win_code := var_win_code;
            rcd_actv.psa_act_win_seqn := var_win_seqn + .10;
            if var_chg_flag = '1' then
               rcd_actv.psa_sch_chg_flag := '1';
               rcd_actv.psa_sch_chg_mins := var_chg_mins;
               rcd_actv.psa_act_chg_flag := '1';
               rcd_actv.psa_act_chg_mins := var_chg_mins;
            end if;
            rcd_actv.psa_mat_req_qty := var_req_qnty;
         else
            rcd_actv.psa_act_ent_flag := '1';
            rcd_actv.psa_act_lin_code := rcd_mlin.mli_lin_code;
            rcd_actv.psa_act_con_code := rcd_mlin.mli_con_code;
            rcd_actv.psa_act_dft_flag := rcd_mlin.mli_dft_flag;
            rcd_actv.psa_act_rra_code := rcd_mlin.mli_rra_code;
            rcd_actv.psa_act_rra_unit := rcd_mlin.rrd_rra_units;
            rcd_actv.psa_act_rra_effp := rcd_mlin.mli_rra_efficiency;
            rcd_actv.psa_act_rra_wasp := rcd_mlin.mli_rra_wastage;
            rcd_actv.psa_act_cal_unit := rcd_mlin.rrd_rra_units;
            rcd_actv.psa_act_cal_effp := rcd_mlin.mli_rra_efficiency;
            rcd_actv.psa_act_cal_wasp := rcd_mlin.mli_rra_wastage;
            rcd_actv.psa_act_win_code := var_win_code;
            rcd_actv.psa_act_win_seqn := var_win_seqn + .10;
            if var_chg_flag = '1' then
               rcd_actv.psa_act_chg_flag := '1';
               rcd_actv.psa_act_chg_mins := var_chg_mins;
            end if;
            rcd_actv.psa_act_str_time := var_str_time;
            rcd_actv.psa_act_end_time := var_end_time;
            rcd_actv.psa_act_com_text := var_com_text;
         end if;
         insert into psa_psc_actv values rcd_actv;
      end if;

      /*-*/
      /* Load the schedule actual entry when required
      /*-*/
      if var_src_code = '*ACT' then
         delete from psa_psc_enty where pse_act_code = rcd_actv.psa_act_code;
         obj_ent_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/ENTDFN');
         for idx in 0..xmlDom.getLength(obj_ent_list)-1 loop
            obj_ent_node := xmlDom.item(obj_ent_list,idx);
            rcd_enty.pse_act_code := rcd_actv.psa_act_code;
            rcd_enty.pse_ent_time := nvl(psa_to_date(xslProcessor.valueOf(obj_ent_node,'@ENTTIM'),'dd/mm/yyyy hh24:mi'),sysdate);
            rcd_enty.pse_ent_text := psa_from_xml(xslProcessor.valueOf(obj_ent_node,'@ENTTXT'));
            rcd_enty.pse_ent_qnty := nvl(psa_to_number(xslProcessor.valueOf(obj_ent_node,'@ENTQTY')),0);
            rcd_enty.pse_ent_wast := nvl(psa_to_number(xslProcessor.valueOf(obj_ent_node,'@ENTWAS')),0);
            insert into psa_psc_enty values rcd_enty;
         end loop;
      end if;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Calculate the schedule activity as required
      /*-*/
      if var_src_code = '*SCH' then
         calc_schedule(rcd_actv.psa_act_code);
      else
         calc_actual(rcd_actv.psa_act_code);
      end if;

      /*-*/
      /* Align the shift window actual activities
      /*-*/
      align_activity(var_psc_code,
                     var_pty_code,
                     var_lin_code,
                     var_con_code,
                     var_win_code);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - UPDATE_PRODUCTION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_production;

   /****************************************************/
   /* This procedure performs the update stock routine */
   /****************************************************/
   procedure update_stock(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      var_src_code varchar2(4);
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_upd_user varchar2(30);
      var_upd_date date;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = var_psc_code
            for update;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_ptyp is
         select t01.*
           from psa_psc_prod t01
          where t01.psp_psc_code = var_psc_code
            and t01.psp_psc_week >= var_wek_code;
      rcd_ptyp csr_ptyp%rowtype;

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
      if var_action != '*UPDSTK' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      var_upd_user := upper(par_user);
      var_upd_date := sysdate;
      if var_src_code != '*SCH' and var_src_code != '*ACT' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve and lock the production schedule
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
            psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') is currently locked');
      end;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Update the impacted production schedule week types
      /*-*/
      update psa_psc_prod
         set psp_upd_user = var_upd_user,
             psp_upd_date = var_upd_date
       where psp_psc_code = var_psc_code
         and psp_psc_week >= var_wek_code;

      /*-*/
      /* Align the stock forward from this week
      /*-*/
      align_stock(var_psc_code, var_wek_code);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - UPDATE_STOCK - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_stock;

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
      var_src_code varchar2(4);
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
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      if var_action != '*DLTDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if var_src_code != '*SCH' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

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
      else
         if upper(rcd_retrieve.psh_psc_code) = con_mst_cde then
            psa_gen_function.add_mesg_data('Production schedule code '||con_mst_cde||' - unable to delete');
         end if;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Process the production schedule data
      /*-*/
      var_confirm := 'deleted';
      delete from psa_psc_enty where pse_act_code in (select psa_act_code from psa_psc_actv where psa_psc_code = var_psc_code);
      delete from psa_psc_invt where psi_act_code in (select psa_act_code from psa_psc_actv where psa_psc_code = var_psc_code);
      delete from psa_psc_actv where psa_psc_code = var_psc_code;
      delete from psa_psc_reso where psr_psc_code = var_psc_code;
      delete from psa_psc_shft where pss_psc_code = var_psc_code;
      delete from psa_psc_line where psl_psc_code = var_psc_code;
      delete from psa_psc_prod where psp_psc_code = var_psc_code;
      delete from psa_psc_date where psd_psc_code = var_psc_code;
      delete from psa_psc_week where psw_psc_code = var_psc_code;
      delete from psa_psc_hedr where psh_psc_code = var_psc_code;

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

   /***************************************************/
   /* This procedure performs the delete line routine */
   /***************************************************/
   procedure delete_line(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_count number;
      var_src_code varchar2(4);
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_pty_code varchar2(32);
      var_lin_code varchar2(32);
      var_con_code varchar2(32);
      var_upd_user varchar2(30);
      var_upd_date date;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = var_psc_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_schd is
         select count(*) as wrk_count
           from psa_psc_actv t01
          where t01.psa_psc_code = var_psc_code
            and t01.psa_psc_week = var_wek_code
            and t01.psa_prd_type = var_pty_code
            and t01.psa_act_lin_code = var_lin_code
            and t01.psa_act_con_code = var_con_code
            and t01.psa_act_ent_flag = '1';
      rcd_schd csr_schd%rowtype;

      cursor csr_actl is
         select count(*) as wrk_count
           from psa_psc_actv t01
          where t01.psa_psc_code = var_psc_code
            and t01.psa_psc_week = var_wek_code
            and t01.psa_prd_type = var_pty_code
            and t01.psa_act_lin_code = var_lin_code
            and t01.psa_act_con_code = var_con_code
            and t01.psa_sch_ent_flag = '1';
      rcd_actl csr_actl%rowtype;

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
      if var_action != '*DLTLIN' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      var_pty_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
      var_con_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CONCDE')));
      var_upd_user := upper(par_user);
      if var_src_code != '*SCH' and var_src_code != '*ACT' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      var_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the production schedule
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
            psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') is currently locked');
      end;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Validation
      /*-*/
      if var_src_code = '*SCH' then
         var_count := 0;
         open csr_schd;
         fetch csr_schd into rcd_schd;
         if csr_schd%found then
            var_count := rcd_schd.wrk_count;
         end if;
         close csr_schd;
         if var_count != 0 then
            psa_gen_function.add_mesg_data('Production schedule line has actuals entered - unable to delete');
         end if;
      else
         var_count := 0;
         open csr_actl;
         fetch csr_actl into rcd_actl;
         if csr_actl%found then
            var_count := rcd_actl.wrk_count;
         end if;
         close csr_actl;
         if var_count != 0 then
            psa_gen_function.add_mesg_data('Production schedule line has scheduled activities - unable to delete');
         end if;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Update the production schedule type
      /*-*/
      update psa_psc_prod
         set psp_upd_user = var_upd_user,
             psp_upd_date = var_upd_date
       where psp_psc_code = var_psc_code
         and psp_psc_week = var_wek_code
         and psp_prd_type = var_pty_code;

      /*-*/
      /* Delete the production schedule line
      /*-*/
      delete from psa_psc_reso
       where psr_psc_code = var_psc_code
         and psr_psc_week = var_wek_code
         and psr_prd_type = var_pty_code
         and psr_lin_code = var_lin_code
         and psr_con_code = var_con_code;
      delete from psa_psc_shft
       where pss_psc_code = var_psc_code
         and pss_psc_week = var_wek_code
         and pss_prd_type = var_pty_code
         and pss_lin_code = var_lin_code
         and pss_con_code = var_con_code;
      delete from psa_psc_line
       where psl_psc_code = var_psc_code
         and psl_psc_week = var_wek_code
         and psl_prd_type = var_pty_code
         and psl_lin_code = var_lin_code
         and psl_con_code = var_con_code;

      /*-*/
      /* Orphan activities for the deleted line configuration
      /*-*/
      if var_src_code = '*SCH' then
         update psa_psc_actv
            set psa_act_win_code = '*NONE',
                psa_act_win_seqn = null,
                psa_act_win_flow = null,
                psa_act_str_time = null,
                psa_act_chg_time = null,
                psa_act_end_time = null
          where psa_psc_code = var_psc_code
            and psa_psc_week = var_wek_code
            and psa_prd_type = var_pty_code
            and psa_act_lin_code = var_lin_code
            and psa_act_con_code = var_con_code;
      else
         update psa_psc_actv
            set psa_act_win_code = '*NONE',
                psa_act_win_seqn = null,
                psa_act_win_flow = null,
                psa_act_str_time = null,
                psa_act_chg_time = null,
                psa_act_end_time = null
          where psa_psc_code = var_psc_code
            and psa_psc_week = var_wek_code
            and psa_prd_type = var_pty_code
            and psa_act_lin_code = var_lin_code
            and psa_act_con_code = var_con_code;
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - DELETE_LINE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_line;

   /*******************************************************/
   /* This procedure performs the delete activity routine */
   /*******************************************************/
   procedure delete_activity(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_src_code varchar2(4);
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_pty_code varchar2(32);
      var_win_code varchar2(32);
      var_act_code number;
      var_upd_user varchar2(30);
      var_upd_date date;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = var_psc_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_actv is
         select t01.*
           from psa_psc_actv t01
          where t01.psa_act_code = var_act_code;
      rcd_actv csr_actv%rowtype;

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
      if var_action != '*DLTACT' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      var_pty_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      var_act_code := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@ACTCDE'));
      var_upd_user := upper(par_user);
      var_upd_date := sysdate;
      if var_src_code != '*SCH' and var_src_code != '*ACT' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the production schedule
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
            psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') is currently locked');
      end;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the production schedule activity
      /*-*/
      var_found := false;
      open csr_actv;
      fetch csr_actv into rcd_actv;
      if csr_actv%found then
         var_found := true;
      end if;
      close csr_actv;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') does not exist');
      else
         if var_src_code = '*SCH' then
            if rcd_actv.psa_act_win_code != '*NONE' then
               psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') is currently on schedule - unable to delete');
            else
               if rcd_actv.psa_act_ent_flag = '1' then
                  psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') has actuals entered - unable to delete');
               end if;
            end if;
         else
            if rcd_actv.psa_act_win_code != '*NONE' then
               psa_gen_function.add_mesg_data('Production actual activity code ('||var_act_code||') is currently on schedule - unable to delete');
            else
               if rcd_actv.psa_sch_ent_flag = '1' then
                  psa_gen_function.add_mesg_data('Production actual activity code ('||var_act_code||') is a scheduled activity - unable to delete');
               end if;
            end if;
         end if;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Update the production schedule type
      /*-*/
      update psa_psc_prod
         set psp_upd_user = var_upd_user,
             psp_upd_date = var_upd_date
       where psp_psc_code = var_psc_code
         and psp_psc_week = var_wek_code
         and psp_prd_type = var_pty_code;

      /*-*/
      /* Delete the production schedule activity
      /*-*/
      delete from psa_psc_enty where pse_act_code = var_act_code;
      delete from psa_psc_invt where psi_act_code = var_act_code;
      delete from psa_psc_actv where psa_act_code = var_act_code;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - DELETE_ACTIVITY - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_activity;

   /*******************************************************/
   /* This procedure performs the attach activity routine */
   /*******************************************************/
   procedure attach_activity(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      var_src_code varchar2(4);
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_pty_code varchar2(32);
      var_lin_code varchar2(32);
      var_con_code varchar2(32);
      var_win_code varchar2(32);
      var_win_seqn number;
      var_act_code number;
      var_upd_user varchar2(30);
      var_upd_date date;
      rcd_actv psa_psc_actv%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = var_psc_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_actv is
         select t01.*
           from psa_psc_actv t01
          where t01.psa_act_code = var_act_code;

      cursor csr_mlin is
         select t01.mli_lin_code,
                t01.mli_con_code,
                t01.mli_dft_flag,
                t01.mli_rra_code,
                decode(t01.mli_rra_efficiency,null,100,0,100,t01.mli_rra_efficiency) as mli_rra_efficiency,
                decode(t01.mli_rra_wastage,null,0,t01.mli_rra_wastage) as mli_rra_wastage,
                decode(t02.rrd_rra_units,null,1,t02.rrd_rra_units) as rrd_rra_units
           from psa_mat_line t01,
                psa_rra_defn t02
          where t01.mli_rra_code = t02.rrd_rra_code
            and t01.mli_mat_code = rcd_actv.psa_mat_code
            and t01.mli_prd_type = var_pty_code
            and t01.mli_lin_code = var_lin_code
            and t01.mli_con_code = var_con_code;
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
      if var_action != '*ATTACT' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      var_pty_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
      var_con_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CONCDE')));
      var_win_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WINCDE')));
      var_win_seqn := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@WINSEQ'));
      var_act_code := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@ACTCDE'));
      var_upd_user := upper(par_user);
      var_upd_date := sysdate;
      if var_src_code != '*SCH' and var_src_code != '*ACT' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the production schedule
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
            psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') is currently locked');
      end;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the production schedule activity
      /*-*/
      var_found := false;
      open csr_actv;
      fetch csr_actv into rcd_actv;
      if csr_actv%found then
         var_found := true;
      end if;
      close csr_actv;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') does not exist');
      else
         if var_src_code = '*SCH' then
            if rcd_actv.psa_act_win_code != '*NONE' then
               psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') is already attached');
            else
               if rcd_actv.psa_act_ent_flag = '1' then
                  psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') has actuals entered - unable to attach');
               end if;
            end if;
         else
            if rcd_actv.psa_act_win_code != '*NONE' then
               psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') is already attached');
            end if;
         end if;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the production line data when required
      /*-*/
      if rcd_actv.psa_act_type = 'P' then
         var_found := false;
         open csr_mlin;
         fetch csr_mlin into rcd_mlin;
         if csr_mlin%found then
            var_found := true;
         end if;
         close csr_mlin;
         if var_found = false then
            psa_gen_function.add_mesg_data('Production schedule activity material ('||rcd_actv.psa_mat_code||') does not have configuration for selected line configuration');
         end if;
         if psa_gen_function.get_mesg_count != 0 then
            rollback;
            return;
         end if;
      end if;

      /*-*/
      /* Update the production schedule data
      /*-*/
      update psa_psc_prod
         set psp_upd_user = var_upd_user,
             psp_upd_date = var_upd_date
       where psp_psc_code = var_psc_code
         and psp_psc_week = var_wek_code
         and psp_prd_type = var_pty_code;

      /*-*/
      /* Attach the production schedule activity
      /*-*/
      if rcd_actv.psa_act_type = 'T' then
         if var_src_code = '*SCH' then
            update psa_psc_actv
               set psa_upd_user = var_upd_user,
                   psa_upd_date = var_upd_date,
                   psa_sch_lin_code = var_lin_code,
                   psa_sch_con_code = var_con_code,
                   psa_act_lin_code = var_lin_code,
                   psa_act_con_code = var_con_code,
                   psa_act_win_code = var_win_code,
                   psa_act_win_seqn = var_win_seqn + .10
             where psa_act_code = var_act_code;
         else
            update psa_psc_actv
               set psa_upd_user = var_upd_user,
                   psa_upd_date = var_upd_date,
                   psa_act_lin_code = var_lin_code,
                   psa_act_con_code = var_con_code,
                   psa_act_win_code = var_win_code,
                   psa_act_win_seqn = var_win_seqn + .10
             where psa_act_code = var_act_code;
         end if;
      else
         if var_src_code = '*SCH' then
            rcd_actv.psa_sch_lin_code := rcd_mlin.mli_lin_code;
            rcd_actv.psa_sch_con_code := rcd_mlin.mli_con_code;
            rcd_actv.psa_sch_dft_flag := rcd_mlin.mli_dft_flag;
            rcd_actv.psa_sch_rra_code := rcd_mlin.mli_rra_code;
            rcd_actv.psa_sch_rra_unit := rcd_mlin.rrd_rra_units;
            rcd_actv.psa_sch_rra_effp := rcd_mlin.mli_rra_efficiency;
            rcd_actv.psa_sch_rra_wasp := rcd_mlin.mli_rra_wastage;
            rcd_actv.psa_act_lin_code := rcd_mlin.mli_lin_code;
            rcd_actv.psa_act_con_code := rcd_mlin.mli_con_code;
            rcd_actv.psa_act_dft_flag := rcd_mlin.mli_dft_flag;
            rcd_actv.psa_act_rra_code := rcd_mlin.mli_rra_code;
            rcd_actv.psa_act_rra_unit := rcd_mlin.rrd_rra_units;
            rcd_actv.psa_act_rra_effp := rcd_mlin.mli_rra_efficiency;
            rcd_actv.psa_act_rra_wasp := rcd_mlin.mli_rra_wastage;
            rcd_actv.psa_act_cal_unit := rcd_mlin.rrd_rra_units;
            rcd_actv.psa_act_cal_effp := rcd_mlin.mli_rra_efficiency;
            rcd_actv.psa_act_cal_wasp := rcd_mlin.mli_rra_wastage;
            update psa_psc_actv
               set psa_upd_user = var_upd_user,
                   psa_upd_date = var_upd_date,
                   psa_sch_lin_code = rcd_actv.psa_sch_lin_code,
                   psa_sch_con_code = rcd_actv.psa_sch_con_code,
                   psa_sch_dft_flag = rcd_actv.psa_sch_dft_flag,
                   psa_sch_rra_code = rcd_actv.psa_sch_rra_code,
                   psa_sch_rra_unit = rcd_actv.psa_sch_rra_unit,
                   psa_sch_rra_effp = rcd_actv.psa_sch_rra_effp,
                   psa_sch_rra_wasp = rcd_actv.psa_sch_rra_wasp,
                   psa_act_lin_code = rcd_actv.psa_act_lin_code,
                   psa_act_con_code = rcd_actv.psa_act_con_code,
                   psa_act_dft_flag = rcd_actv.psa_act_dft_flag,
                   psa_act_rra_code = rcd_actv.psa_act_rra_code,
                   psa_act_rra_unit = rcd_actv.psa_act_rra_unit,
                   psa_act_rra_effp = rcd_actv.psa_act_rra_effp,
                   psa_act_rra_wasp = rcd_actv.psa_act_rra_wasp,
                   psa_act_cal_unit = rcd_actv.psa_act_cal_unit,
                   psa_act_cal_effp = rcd_actv.psa_act_cal_effp,
                   psa_act_cal_wasp = rcd_actv.psa_act_cal_wasp,
                   psa_act_win_code = var_win_code,
                   psa_act_win_seqn = var_win_seqn + .10
             where psa_act_code = rcd_actv.psa_act_code;
            calc_schedule(rcd_actv.psa_act_code);
         else
            rcd_actv.psa_act_lin_code := rcd_mlin.mli_lin_code;
            rcd_actv.psa_act_con_code := rcd_mlin.mli_con_code;
            rcd_actv.psa_act_dft_flag := rcd_mlin.mli_dft_flag;
            rcd_actv.psa_act_rra_code := rcd_mlin.mli_rra_code;
            rcd_actv.psa_act_rra_unit := rcd_mlin.rrd_rra_units;
            rcd_actv.psa_act_rra_effp := rcd_mlin.mli_rra_efficiency;
            rcd_actv.psa_act_rra_wasp := rcd_mlin.mli_rra_wastage;
            rcd_actv.psa_act_cal_unit := rcd_mlin.rrd_rra_units;
            rcd_actv.psa_act_cal_effp := rcd_mlin.mli_rra_efficiency;
            rcd_actv.psa_act_cal_wasp := rcd_mlin.mli_rra_wastage;
            update psa_psc_actv
               set psa_upd_user = var_upd_user,
                   psa_upd_date = var_upd_date,
                   psa_act_lin_code = rcd_actv.psa_act_lin_code,
                   psa_act_con_code = rcd_actv.psa_act_con_code,
                   psa_act_dft_flag = rcd_actv.psa_act_dft_flag,
                   psa_act_rra_code = rcd_actv.psa_act_rra_code,
                   psa_act_rra_unit = rcd_actv.psa_act_rra_unit,
                   psa_act_rra_effp = rcd_actv.psa_act_rra_effp,
                   psa_act_rra_wasp = rcd_actv.psa_act_rra_wasp,
                   psa_act_cal_unit = rcd_actv.psa_act_cal_unit,
                   psa_act_cal_effp = rcd_actv.psa_act_cal_effp,
                   psa_act_cal_wasp = rcd_actv.psa_act_cal_wasp,
                   psa_act_win_code = var_win_code,
                   psa_act_win_seqn = var_win_seqn + .10
             where psa_act_code = rcd_actv.psa_act_code;
            calc_actual(rcd_actv.psa_act_code);
         end if;
      end if;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Align the shift window actual activities
      /*-*/
      align_activity(var_psc_code,
                     var_pty_code,
                     var_lin_code,
                     var_con_code,
                     var_win_code);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - ATTACH_ACTIVITY - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end attach_activity;

   /*******************************************************/
   /* This procedure performs the detach activity routine */
   /*******************************************************/
   procedure detach_activity(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_src_code varchar2(4);
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_pty_code varchar2(32);
      var_win_code varchar2(32);
      var_act_code number;
      var_upd_user varchar2(30);
      var_upd_date date;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = var_psc_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_actv is
         select t01.*
           from psa_psc_actv t01
          where t01.psa_act_code = var_act_code;
      rcd_actv csr_actv%rowtype;

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
      if var_action != '*DETACT' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      var_wek_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@WEKCDE'));
      var_pty_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PTYCDE')));
      var_act_code := psa_to_number(xslProcessor.valueOf(obj_psa_request,'@ACTCDE'));
      var_upd_user := upper(par_user);
      var_upd_date := sysdate;
      if var_src_code != '*SCH' and var_src_code != '*ACT' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the production schedule
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
            psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') is currently locked');
      end;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production schedule ('||var_psc_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the production schedule activity
      /*-*/
      var_found := false;
      open csr_actv;
      fetch csr_actv into rcd_actv;
      if csr_actv%found then
         var_found := true;
      end if;
      close csr_actv;
      if var_found = false then
         psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') does not exist');
      else
         if var_src_code = '*SCH' then
            if rcd_actv.psa_act_win_code = '*NONE' then
               psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') is already detached');
            else
               if rcd_actv.psa_act_ent_flag = '1' then
                  psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') has actuals entered - unable to detached');
               end if;
            end if;
         else
            if rcd_actv.psa_act_win_code = '*NONE' then
               psa_gen_function.add_mesg_data('Production schedule activity code ('||var_act_code||') is already detached');
            end if;
         end if;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Update the production schedule data
      /*-*/
      update psa_psc_prod
         set psp_upd_user = var_upd_user,
             psp_upd_date = var_upd_date
       where psp_psc_code = var_psc_code
         and psp_psc_week = var_wek_code
         and psp_prd_type = var_pty_code;

      /*-*/
      /* Detach the activity from the schedule
      /*-*/
      if var_src_code = '*SCH' then
         update psa_psc_actv
            set psa_upd_user = var_upd_user,
                psa_upd_date = var_upd_date,
                psa_act_win_code = '*NONE',
                psa_act_win_seqn = null,
                psa_act_win_flow = null,
                psa_act_str_time = null,
                psa_act_chg_time = null,
                psa_act_end_time = null
             where psa_act_code = var_act_code;
      else
         update psa_psc_actv
            set psa_upd_user = var_upd_user,
                psa_upd_date = var_upd_date,
                psa_act_win_code = '*NONE',
                psa_act_win_seqn = null,
                psa_act_win_flow = null,
                psa_act_str_time = null,
                psa_act_chg_time = null,
                psa_act_end_time = null
             where psa_act_code = var_act_code;
      end if;

      /*-*/
      /* Align the shift window actual activities
      /*-*/
      align_activity(rcd_actv.psa_psc_code,
                     rcd_actv.psa_prd_type,
                     rcd_actv.psa_act_lin_code,
                     rcd_actv.psa_act_con_code,
                     rcd_actv.psa_act_win_code);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_PSC_FUNCTION - DETACH_ACTIVITY - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end detach_activity;

   /************************************************/
   /* This procedure performs the sap data routine */
   /************************************************/
   procedure sap_data is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      var_src_code varchar2(4);
      var_psc_code varchar2(32);
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_start boolean;

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
      var_src_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@SRCCDE')));
      var_psc_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@PSCCDE')));
      if var_action != '*SAPDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if var_src_code != '*SCH' then
         psa_gen_function.add_mesg_data('Invalid source code');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

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
      else
         if rcd_retrieve.psh_psc_code != con_mst_cde then
            psa_gen_function.add_mesg_data('Production schedule code '||con_mst_cde||' - must be *MASTER for SAP update');
         end if;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Initialise the log variables
      /*-*/
      var_log_prefix := 'PSA - SAP_SCHEDULE_INTERFACE';
      var_log_search := 'SAP_SCHEDULE_INTERFACE';

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - PSA SAP Schedule Interface');



      /*-*/
      /* Extract the order data
      /*-*/
    --  var_int_date := to_char(sysdate,'yyyymmddhh24midss');
    --    var_start := true;
    --  open csr_extract;
    --  loop
    --     fetch csr_extract into rcd_extract;
    --     if csr_extract%notfound then
    --        exit;
    --     end if;

         /*-*/
         /* Create outbound interface when required
         /*-*/
    --     if var_start = true then
    --        var_instance := lics_outbound_loader.create_interface('CISATL11',null,'CISATL11.DAT');
    --        var_start := false;
    --     end if;



    --     lics_outbound_loader.append_data('CTL009'||var_int_date);
    --     lics_outbound_loader.append_data('HDR||rcd_detl.sap_code||rpad(' ',18-length(rcd_detl.sap_code),' ')||'NZ01NZ01      '||to_char(rcd_detl.sch_qnty,'fm000000000000000')||rcd_detl.uom_code||rpad(' ',3-length(rcd_detl.uom_code),' ')||'0001');
    --     lics_outbound_loader.append_data('DET0010    '||to_char(rcd_detl.end_date,'yyyymmddhh24midss')||to_char(rcd_detl.str_date,'yyyymmddhh24midss'));


    --  end loop;
    --  close csr_extract;

      /*-*/
      /* Finalise interface when required
      /*-*/
    --  if var_start = false and lics_outbound_loader.is_created = true then
    --     lics_outbound_loader.finalise_interface;
    --  end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - PSA SAP Schedule Interface');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Process the production schedule data
      /*-*/
      var_confirm := 'sent SAP interface';

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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 1536);

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         end if;

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
      --   if var_start = false and lics_outbound_loader.is_created = true then
      --      lics_outbound_loader.add_exception(var_exception);
      --      lics_outbound_loader.finalise_interface;
      --   end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - PSA_PSC_FUNCTION - SAP_DATA - ' || var_exception);


   /*-------------*/
   /* End routine */
   /*-------------*/
   end sap_data;

   /******************************************************/
   /* This procedure performs the load work list routine */
   /******************************************************/
   procedure load_worklist(par_psc_code in varchar2,
                           par_psc_week in varchar2,
                           par_prd_type in varchar2,
                           par_src_code in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_uact is
         select to_char(t01.psa_act_code) as psa_act_code,
                t01.psa_act_type,
                t01.psa_mat_code,
                t01.psa_mat_name,
                t01.psa_sac_code,
                t01.psa_sac_name,
                t01.psa_act_ent_flag,
                nvl(t01.psa_sch_lin_code,'*NONE') as psa_sch_lin_code,
                nvl(t01.psa_sch_con_code,'*NONE') as psa_sch_con_code,
                nvl(t01.psa_sch_dft_flag,'0') as psa_sch_dft_flag,
                to_char(t01.psa_mat_sap_qty) as psa_mat_sap_qty,
                to_char(t01.psa_mat_req_plt_qty) as psa_mat_req_plt_qty,
                to_char(t01.psa_mat_req_cas_qty) as psa_mat_req_cas_qty,
                to_char(t01.psa_mat_req_pch_qty) as psa_mat_req_pch_qty,
                to_char(t01.psa_mat_req_mix_qty) as psa_mat_req_mix_qty,
                to_char(t01.psa_mat_req_ton_qty,'fm999999990.000') as psa_mat_req_ton_qty,
                to_char(t01.psa_mat_sch_plt_qty) as psa_mat_sch_plt_qty,
                to_char(t01.psa_mat_sch_cas_qty) as psa_mat_sch_cas_qty,
                to_char(t01.psa_mat_sch_pch_qty) as psa_mat_sch_pch_qty,
                to_char(t01.psa_mat_sch_mix_qty) as psa_mat_sch_mix_qty,
                to_char(t01.psa_mat_sch_ton_qty,'fm999999990.000') as psa_mat_sch_ton_qty,
                to_char(trunc(t01.psa_sch_dur_mins/60))||' hrs '||to_char(mod(t01.psa_sch_dur_mins,60))||' min' as psa_sch_dur_mins
           from psa_psc_actv t01
          where t01.psa_psc_code = par_psc_code
            and t01.psa_psc_week = par_psc_week
            and t01.psa_prd_type = par_prd_type
            and t01.psa_act_win_code = '*NONE'
            and t01.psa_act_ent_flag = '0'
          order by t01.psa_act_type asc,
                   t01.psa_sch_lin_code asc,
                   t01.psa_sch_con_code asc,
                   t01.psa_mat_code asc;
      rcd_uact csr_uact%rowtype;

      cursor csr_aact is
         select to_char(t01.psa_act_code) as psa_act_code,
                t01.psa_act_type,
                t01.psa_mat_code,
                t01.psa_mat_name,
                t01.psa_sac_code,
                t01.psa_sac_name,
                t01.psa_act_ent_flag,
                nvl(t01.psa_act_lin_code,'*NONE') as psa_act_lin_code,
                nvl(t01.psa_act_con_code,'*NONE') as psa_act_con_code,
                nvl(t01.psa_act_dft_flag,'0') as psa_act_dft_flag,
                to_char(t01.psa_mat_sch_plt_qty) as psa_mat_sch_plt_qty,
                to_char(t01.psa_mat_sch_cas_qty) as psa_mat_sch_cas_qty,
                to_char(t01.psa_mat_sch_pch_qty) as psa_mat_sch_pch_qty,
                to_char(t01.psa_mat_sch_mix_qty) as psa_mat_sch_mix_qty,
                to_char(t01.psa_mat_sch_ton_qty,'fm999999990.000') as psa_mat_sch_ton_qty,
                to_char(t01.psa_mat_act_plt_qty) as psa_mat_act_plt_qty,
                to_char(t01.psa_mat_act_cas_qty) as psa_mat_act_cas_qty,
                to_char(t01.psa_mat_act_pch_qty) as psa_mat_act_pch_qty,
                to_char(t01.psa_mat_act_mix_qty) as psa_mat_act_mix_qty,
                to_char(t01.psa_mat_act_ton_qty,'fm999999990.000') as psa_mat_act_ton_qty,
                to_char(trunc(t01.psa_act_dur_mins/60))||' hrs '||to_char(mod(t01.psa_act_dur_mins,60))||' min' as psa_act_dur_mins
           from psa_psc_actv t01
          where t01.psa_psc_code = par_psc_code
            and t01.psa_psc_week = par_psc_week
            and t01.psa_prd_type = par_prd_type
            and t01.psa_act_win_code = '*NONE'
          order by t01.psa_act_type asc,
                   t01.psa_act_lin_code asc,
                   t01.psa_act_con_code asc,
                   t01.psa_mat_code asc;
      rcd_aact csr_aact%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Clear the data table
      /*-*/
      ptbl_data.delete;

      /*-*/
      /* Load the work list activities
      /*-*/
      if par_src_code = '*SCH' then
         open csr_uact;
         loop
            fetch csr_uact into rcd_uact;
            if csr_uact%notfound then
               exit;
            end if;
            if rcd_uact.psa_act_type = 'P' then
               ptbl_data(ptbl_data.count+1) := '<UNSACT ACTCDE="'||psa_to_xml(rcd_uact.psa_act_code)||'"'||
                                                      ' ACTTYP="'||psa_to_xml(rcd_uact.psa_act_type)||'"'||
                                                      ' MATCDE="'||psa_to_xml(rcd_uact.psa_mat_code)||'"'||
                                                      ' MATNAM="'||psa_to_xml(rcd_uact.psa_mat_name)||'"'||
                                                      ' ACTENT="'||psa_to_xml(rcd_uact.psa_act_ent_flag)||'"'||
                                                      ' LINCDE="'||psa_to_xml(rcd_uact.psa_sch_lin_code)||'"'||
                                                      ' CONCDE="'||psa_to_xml(rcd_uact.psa_sch_con_code)||'"'||
                                                      ' DFTFLG="'||psa_to_xml(rcd_uact.psa_sch_dft_flag)||'"'||
                                                      ' SAPQTY="'||psa_to_xml(rcd_uact.psa_mat_sap_qty)||'"'||
                                                      ' REQPLT="'||psa_to_xml(rcd_uact.psa_mat_req_plt_qty)||'"'||
                                                      ' REQCAS="'||psa_to_xml(rcd_uact.psa_mat_req_cas_qty)||'"'||
                                                      ' REQPCH="'||psa_to_xml(rcd_uact.psa_mat_req_pch_qty)||'"'||
                                                      ' REQMIX="'||psa_to_xml(rcd_uact.psa_mat_req_mix_qty)||'"'||
                                                      ' REQTON="'||psa_to_xml(rcd_uact.psa_mat_req_ton_qty)||'"'||
                                                      ' SCHPLT="'||psa_to_xml(rcd_uact.psa_mat_sch_plt_qty)||'"'||
                                                      ' SCHCAS="'||psa_to_xml(rcd_uact.psa_mat_sch_cas_qty)||'"'||
                                                      ' SCHPCH="'||psa_to_xml(rcd_uact.psa_mat_sch_pch_qty)||'"'||
                                                      ' SCHMIX="'||psa_to_xml(rcd_uact.psa_mat_sch_mix_qty)||'"'||
                                                      ' SCHTON="'||psa_to_xml(rcd_uact.psa_mat_sch_ton_qty)||'"'||
                                                      ' SCHDUR="'||psa_to_xml(rcd_uact.psa_sch_dur_mins)||'"/>';
            else
               ptbl_data(ptbl_data.count+1) := '<UNSACT ACTCDE="'||psa_to_xml(rcd_uact.psa_act_code)||'"'||
                                                      ' ACTTYP="'||psa_to_xml(rcd_uact.psa_act_type)||'"'||
                                                      ' MATCDE="'||psa_to_xml(rcd_uact.psa_sac_code)||'"'||
                                                      ' MATNAM="'||psa_to_xml(rcd_uact.psa_sac_name)||'"'||
                                                      ' ACTENT="'||psa_to_xml(rcd_uact.psa_act_ent_flag)||'"'||
                                                      ' LINCDE="'||psa_to_xml(rcd_uact.psa_sch_lin_code)||'"'||
                                                      ' CONCDE="'||psa_to_xml(rcd_uact.psa_sch_con_code)||'"'||
                                                      ' SCHDUR="'||psa_to_xml(rcd_uact.psa_sch_dur_mins)||'"/>';
            end if;
         end loop;
         close csr_uact;
      else
         open csr_aact;
         loop
            fetch csr_aact into rcd_aact;
            if csr_aact%notfound then
               exit;
            end if;
            if rcd_aact.psa_act_type = 'P' then
               ptbl_data(ptbl_data.count+1) := '<UNSACT ACTCDE="'||psa_to_xml(rcd_aact.psa_act_code)||'"'||
                                                      ' ACTTYP="'||psa_to_xml(rcd_aact.psa_act_type)||'"'||
                                                      ' MATCDE="'||psa_to_xml(rcd_aact.psa_mat_code)||'"'||
                                                      ' MATNAM="'||psa_to_xml(rcd_aact.psa_mat_name)||'"'||
                                                      ' ACTENT="'||psa_to_xml(rcd_uact.psa_act_ent_flag)||'"'||
                                                      ' LINCDE="'||psa_to_xml(rcd_aact.psa_act_lin_code)||'"'||
                                                      ' CONCDE="'||psa_to_xml(rcd_aact.psa_act_con_code)||'"'||
                                                      ' DFTFLG="'||psa_to_xml(rcd_aact.psa_act_dft_flag)||'"'||
                                                      ' REQPLT="'||psa_to_xml(rcd_aact.psa_mat_sch_plt_qty)||'"'||
                                                      ' REQCAS="'||psa_to_xml(rcd_aact.psa_mat_sch_cas_qty)||'"'||
                                                      ' REQPCH="'||psa_to_xml(rcd_aact.psa_mat_sch_pch_qty)||'"'||
                                                      ' REQMIX="'||psa_to_xml(rcd_aact.psa_mat_sch_mix_qty)||'"'||
                                                      ' REQTON="'||psa_to_xml(rcd_aact.psa_mat_sch_ton_qty)||'"'||
                                                      ' SCHPLT="'||psa_to_xml(rcd_aact.psa_mat_act_plt_qty)||'"'||
                                                      ' SCHCAS="'||psa_to_xml(rcd_aact.psa_mat_act_cas_qty)||'"'||
                                                      ' SCHPCH="'||psa_to_xml(rcd_aact.psa_mat_act_pch_qty)||'"'||
                                                      ' SCHMIX="'||psa_to_xml(rcd_aact.psa_mat_act_mix_qty)||'"'||
                                                      ' SCHTON="'||psa_to_xml(rcd_aact.psa_mat_act_ton_qty)||'"'||
                                                      ' SCHDUR="'||psa_to_xml(rcd_aact.psa_act_dur_mins)||'"/>';
            else
               ptbl_data(ptbl_data.count+1) := '<UNSACT ACTCDE="'||psa_to_xml(rcd_aact.psa_act_code)||'"'||
                                                      ' ACTTYP="'||psa_to_xml(rcd_aact.psa_act_type)||'"'||
                                                      ' MATCDE="'||psa_to_xml(rcd_aact.psa_sac_code)||'"'||
                                                      ' MATNAM="'||psa_to_xml(rcd_aact.psa_sac_name)||'"'||
                                                      ' ACTENT="'||psa_to_xml(rcd_uact.psa_act_ent_flag)||'"'||
                                                      ' LINCDE="'||psa_to_xml(rcd_aact.psa_act_lin_code)||'"'||
                                                      ' CONCDE="'||psa_to_xml(rcd_aact.psa_act_con_code)||'"'||
                                                      ' SCHDUR="'||psa_to_xml(rcd_aact.psa_act_dur_mins)||'"/>';
            end if;
         end loop;
         close csr_aact;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_worklist;

   /*****************************************************/
   /* This procedure performs the load schedule routine */
   /*****************************************************/
   procedure load_schedule(par_psc_code in varchar2,
                           par_psc_week in varchar2,
                           par_prd_type in varchar2,
                           par_lin_code in varchar2,
                           par_con_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_min_time date;
      var_max_time date;
      var_str_barn number;
      var_chg_barn number;
      var_end_barn number;
      var_wek_flow varchar2(1);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_date is
         select min(trunc(t01.psd_day_date)) as min_day_date,
                max(trunc(t01.psd_day_date)) + 1 as max_day_date
           from psa_psc_date t01
          where t01.psd_psc_code = par_psc_code
            and t01.psd_psc_week = par_psc_week;
      rcd_date csr_date%rowtype;

      cursor csr_sact is
         select to_char(t01.psa_act_code) as psa_act_code,
                t01.psa_psc_week,
                t01.psa_act_type,
                t01.psa_sch_chg_flag,
                t01.psa_act_chg_flag,
                t01.psa_act_win_code,
                to_char(t01.psa_act_win_seqn) as psa_act_win_seqn,
                t01.psa_act_win_flow,
                t01.psa_act_str_time,
                t01.psa_act_chg_time,
                t01.psa_act_end_time,
                to_char(trunc(nvl(t01.psa_sch_dur_mins,0)/60))||' hrs '||to_char(mod(nvl(t01.psa_sch_dur_mins,0),60))||' min' as psa_sch_dur_mins,
                to_char(trunc(nvl(t01.psa_act_dur_mins,0)/60))||' hrs '||to_char(mod(nvl(t01.psa_act_dur_mins,0),60))||' min' as psa_act_dur_mins,
                to_char(trunc(nvl(t01.psa_sch_chg_mins,0)/60))||' hrs '||to_char(mod(nvl(t01.psa_sch_chg_mins,0),60))||' min' as psa_sch_chg_mins,
                to_char(trunc(nvl(t01.psa_act_chg_mins,0)/60))||' hrs '||to_char(mod(nvl(t01.psa_act_chg_mins,0),60))||' min' as psa_act_chg_mins,
                t01.psa_act_ent_flag,
                t01.psa_sac_code,
                t01.psa_sac_name,
                t01.psa_mat_code,
                t01.psa_mat_name,
                to_char(t01.psa_mat_sch_plt_qty) as psa_mat_sch_plt_qty,
                to_char(t01.psa_mat_sch_cas_qty) as psa_mat_sch_cas_qty,
                to_char(t01.psa_mat_sch_pch_qty) as psa_mat_sch_pch_qty,
                to_char(t01.psa_mat_sch_mix_qty) as psa_mat_sch_mix_qty,
                to_char(t01.psa_mat_sch_ton_qty,'fm999999990.000') as psa_mat_sch_ton_qty,
                to_char(t01.psa_mat_act_plt_qty) as psa_mat_act_plt_qty,
                to_char(t01.psa_mat_act_cas_qty) as psa_mat_act_cas_qty,
                to_char(t01.psa_mat_act_pch_qty) as psa_mat_act_pch_qty,
                to_char(t01.psa_mat_act_mix_qty) as psa_mat_act_mix_qty,
                to_char(t01.psa_mat_act_ton_qty,'fm999999990.000') as psa_mat_act_ton_qty
           from psa_psc_actv t01
          where t01.psa_psc_code = par_psc_code
            and t01.psa_prd_type = par_prd_type
            and t01.psa_act_lin_code = par_lin_code
            and t01.psa_act_con_code = par_con_code
            and t01.psa_act_win_code != '*NONE'
            and ((t01.psa_act_str_time >= var_min_time and t01.psa_act_str_time < var_max_time) or
                 (t01.psa_act_end_time >= var_min_time and t01.psa_act_end_time < var_max_time) or
                 (t01.psa_act_str_time < var_min_time and t01.psa_act_end_time >= var_max_time))
          order by t01.psa_act_str_time asc;
      rcd_sact csr_sact%rowtype;

      cursor csr_sivt is
         select t01.psi_mat_code,
                t02.mde_mat_name,
                to_char(t01.psi_inv_qnty) as psi_inv_qnty,
                to_char(t01.psi_inv_aval) as psi_inv_aval
           from psa_psc_invt t01,
                psa_mat_defn t02
          where t01.psi_mat_code = t02.mde_mat_code
            and t01.psi_act_code = rcd_sact.psa_act_code
          order by t01.psi_mat_code asc;
      rcd_sivt csr_sivt%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Clear the data table
      /*-*/
      ptbl_data.delete;

      /*-*/
      /* Retrieve the week boundaries
      /*-*/
      var_min_time := null;
      var_max_time := null;
      open csr_date;
      fetch csr_date into rcd_date;
      if csr_date%found then
         var_min_time := rcd_date.min_day_date;
         var_max_time := rcd_date.max_day_date;
      end if;
      close csr_date;
      if var_min_time is null then
         return;
      end if;

      /*-*/
      /* Load the schedule data
      /*-*/
      open csr_sact;
      loop
         fetch csr_sact into rcd_sact;
         if csr_sact%notfound then
            exit;
         end if;
         var_wek_flow := '0';
         if rcd_sact.psa_psc_week != par_psc_week then
            var_wek_flow := '1';
         end if;
         var_str_barn := trunc(((rcd_sact.psa_act_str_time - var_min_time) * 1440) / 15) + 1;
         var_end_barn := trunc(((rcd_sact.psa_act_end_time - var_min_time) * 1440) / 15) + 1;
         if rcd_sact.psa_act_str_time < var_min_time then
            var_str_barn := 1;
         end if;
         if rcd_sact.psa_act_end_time >= var_max_time then
            var_end_barn := con_max_bar;
         end if;
         if rcd_sact.psa_act_type = 'P' then
            if rcd_sact.psa_act_chg_flag = '1' then
               var_chg_barn := trunc(((rcd_sact.psa_act_chg_time - var_min_time) * 1440) / 15) + 1;
               if rcd_sact.psa_act_chg_time < var_min_time or rcd_sact.psa_act_chg_time >= var_max_time then
                  var_chg_barn := 0;
               end if;
               ptbl_data(ptbl_data.count+1) := '<LINACT ACTCDE="'||psa_to_xml(rcd_sact.psa_act_code)||'"'||
                                                      ' ACTTYP="'||psa_to_xml(rcd_sact.psa_act_type)||'"'||
                                                      ' SCHCHG="'||psa_to_xml(rcd_sact.psa_sch_chg_flag)||'"'||
                                                      ' CHGFLG="'||psa_to_xml(rcd_sact.psa_act_chg_flag)||'"'||
                                                      ' WINCDE="'||psa_to_xml(rcd_sact.psa_act_win_code)||'"'||
                                                      ' WINSEQ="'||psa_to_xml(rcd_sact.psa_act_win_seqn)||'"'||
                                                      ' WINFLW="'||psa_to_xml(rcd_sact.psa_act_win_flow)||'"'||
                                                      ' WEKFLW="'||psa_to_xml(var_wek_flow)||'"'||
                                                      ' STRTIM="'||psa_to_xml(to_char(rcd_sact.psa_act_str_time,'dd/mm/yyyy hh24:mi'))||'"'||
                                                      ' CHGTIM="'||psa_to_xml(to_char(rcd_sact.psa_act_chg_time,'dd/mm/yyyy hh24:mi'))||'"'||
                                                      ' ENDTIM="'||psa_to_xml(to_char(rcd_sact.psa_act_end_time,'dd/mm/yyyy hh24:mi'))||'"'||
                                                      ' STRBAR="'||psa_to_xml(to_char(var_str_barn))||'"'||
                                                      ' CHGBAR="'||psa_to_xml(to_char(var_chg_barn))||'"'||
                                                      ' ENDBAR="'||psa_to_xml(to_char(var_end_barn))||'"'||
                                                      ' SCHDMI="'||psa_to_xml(rcd_sact.psa_sch_dur_mins)||'"'||
                                                      ' ACTDMI="'||psa_to_xml(rcd_sact.psa_act_dur_mins)||'"'||
                                                      ' SCHCMI="'||psa_to_xml(rcd_sact.psa_sch_chg_mins)||'"'||
                                                      ' ACTCMI="'||psa_to_xml(rcd_sact.psa_act_chg_mins)||'"'||
                                                      ' ACTENT="'||psa_to_xml(rcd_sact.psa_act_ent_flag)||'"'||
                                                      ' MATCDE="'||psa_to_xml(rcd_sact.psa_mat_code)||'"'||
                                                      ' MATNAM="'||psa_to_xml(rcd_sact.psa_mat_name)||'"'||
                                                      ' SCHPLT="'||psa_to_xml(rcd_sact.psa_mat_sch_plt_qty)||'"'||
                                                      ' SCHCAS="'||psa_to_xml(rcd_sact.psa_mat_sch_cas_qty)||'"'||
                                                      ' SCHPCH="'||psa_to_xml(rcd_sact.psa_mat_sch_pch_qty)||'"'||
                                                      ' SCHMIX="'||psa_to_xml(rcd_sact.psa_mat_sch_mix_qty)||'"'||
                                                      ' SCHTON="'||psa_to_xml(rcd_sact.psa_mat_sch_ton_qty)||'"'||
                                                      ' ACTPLT="'||psa_to_xml(rcd_sact.psa_mat_act_plt_qty)||'"'||
                                                      ' ACTCAS="'||psa_to_xml(rcd_sact.psa_mat_act_cas_qty)||'"'||
                                                      ' ACTPCH="'||psa_to_xml(rcd_sact.psa_mat_act_pch_qty)||'"'||
                                                      ' ACTMIX="'||psa_to_xml(rcd_sact.psa_mat_act_mix_qty)||'"'||
                                                      ' ACTTON="'||psa_to_xml(rcd_sact.psa_mat_act_ton_qty)||'"/>';
            else
               ptbl_data(ptbl_data.count+1) := '<LINACT ACTCDE="'||psa_to_xml(rcd_sact.psa_act_code)||'"'||
                                                      ' ACTTYP="'||psa_to_xml(rcd_sact.psa_act_type)||'"'||
                                                      ' SCHCHG="'||psa_to_xml(rcd_sact.psa_sch_chg_flag)||'"'||
                                                      ' CHGFLG="'||psa_to_xml(rcd_sact.psa_act_chg_flag)||'"'||
                                                      ' WINCDE="'||psa_to_xml(rcd_sact.psa_act_win_code)||'"'||
                                                      ' WINSEQ="'||psa_to_xml(rcd_sact.psa_act_win_seqn)||'"'||
                                                      ' WINFLW="'||psa_to_xml(rcd_sact.psa_act_win_flow)||'"'||
                                                      ' WEKFLW="'||psa_to_xml(var_wek_flow)||'"'||
                                                      ' STRTIM="'||psa_to_xml(to_char(rcd_sact.psa_act_str_time,'dd/mm/yyyy hh24:mi'))||'"'||
                                                      ' ENDTIM="'||psa_to_xml(to_char(rcd_sact.psa_act_end_time,'dd/mm/yyyy hh24:mi'))||'"'||
                                                      ' STRBAR="'||psa_to_xml(to_char(var_str_barn))||'"'||
                                                      ' ENDBAR="'||psa_to_xml(to_char(var_end_barn))||'"'||
                                                      ' SCHDMI="'||psa_to_xml(rcd_sact.psa_sch_dur_mins)||'"'||
                                                      ' ACTDMI="'||psa_to_xml(rcd_sact.psa_act_dur_mins)||'"'||
                                                      ' ACTENT="'||psa_to_xml(rcd_sact.psa_act_ent_flag)||'"'||
                                                      ' MATCDE="'||psa_to_xml(rcd_sact.psa_mat_code)||'"'||
                                                      ' MATNAM="'||psa_to_xml(rcd_sact.psa_mat_name)||'"'||
                                                      ' SCHPLT="'||psa_to_xml(rcd_sact.psa_mat_sch_plt_qty)||'"'||
                                                      ' SCHCAS="'||psa_to_xml(rcd_sact.psa_mat_sch_cas_qty)||'"'||
                                                      ' SCHPCH="'||psa_to_xml(rcd_sact.psa_mat_sch_pch_qty)||'"'||
                                                      ' SCHMIX="'||psa_to_xml(rcd_sact.psa_mat_sch_mix_qty)||'"'||
                                                      ' SCHTON="'||psa_to_xml(rcd_sact.psa_mat_sch_ton_qty)||'"'||
                                                      ' ACTPLT="'||psa_to_xml(rcd_sact.psa_mat_act_plt_qty)||'"'||
                                                      ' ACTCAS="'||psa_to_xml(rcd_sact.psa_mat_act_cas_qty)||'"'||
                                                      ' ACTPCH="'||psa_to_xml(rcd_sact.psa_mat_act_pch_qty)||'"'||
                                                      ' ACTMIX="'||psa_to_xml(rcd_sact.psa_mat_act_mix_qty)||'"'||
                                                      ' ACTTON="'||psa_to_xml(rcd_sact.psa_mat_act_ton_qty)||'"/>';
            end if;
            open csr_sivt;
            loop
               fetch csr_sivt into rcd_sivt;
               if csr_sivt%notfound then
                  exit;
               end if;
               ptbl_data(ptbl_data.count+1) := '<LININV MATCDE="'||psa_to_xml(rcd_sivt.psi_mat_code)||'"'||
                                                      ' MATNAM="'||psa_to_xml(rcd_sivt.mde_mat_name)||'"'||
                                                      ' INVQTY="'||psa_to_xml(rcd_sivt.psi_inv_qnty)||'"'||
                                                      ' INVAVL="'||psa_to_xml(rcd_sivt.psi_inv_aval)||'"/>';
            end loop;
            close csr_sivt;
         elsif rcd_sact.psa_act_type = 'T' then
            ptbl_data(ptbl_data.count+1) := '<LINACT ACTCDE="'||psa_to_xml(rcd_sact.psa_act_code)||'"'||
                                                   ' ACTTYP="'||psa_to_xml(rcd_sact.psa_act_type)||'"'||
                                                   ' WINCDE="'||psa_to_xml(rcd_sact.psa_act_win_code)||'"'||
                                                   ' WINSEQ="'||psa_to_xml(rcd_sact.psa_act_win_seqn)||'"'||
                                                   ' WINFLW="'||psa_to_xml(rcd_sact.psa_act_win_flow)||'"'||
                                                   ' WEKFLW="'||psa_to_xml(var_wek_flow)||'"'||
                                                   ' STRTIM="'||psa_to_xml(to_char(rcd_sact.psa_act_str_time,'dd/mm/yyyy hh24:mi'))||'"'||
                                                   ' ENDTIM="'||psa_to_xml(to_char(rcd_sact.psa_act_end_time,'dd/mm/yyyy hh24:mi'))||'"'||
                                                   ' STRBAR="'||psa_to_xml(to_char(var_str_barn))||'"'||
                                                   ' ENDBAR="'||psa_to_xml(to_char(var_end_barn))||'"'||
                                                   ' SCHDMI="'||psa_to_xml(rcd_sact.psa_sch_dur_mins)||'"'||
                                                   ' ACTDMI="'||psa_to_xml(rcd_sact.psa_act_dur_mins)||'"'||
                                                   ' ACTENT="'||psa_to_xml(rcd_sact.psa_act_ent_flag)||'"'||
                                                   ' MATCDE="'||psa_to_xml(rcd_sact.psa_sac_code)||'"'||
                                                   ' MATNAM="'||psa_to_xml(rcd_sact.psa_sac_name)||'"/>';
         end if;
      end loop;
      close csr_sact;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_schedule;

   /**********************************************************/
   /* This procedure performs the calculate schedule routine */
   /**********************************************************/
   procedure calc_schedule(par_act_code in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      rcd_psa_psc_invt psa_psc_invt%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_actv is
         select t01.*
           from psa_psc_actv t01
          where t01.psa_act_code = par_act_code;
      rcd_actv csr_actv%rowtype;

      cursor csr_mcom is
         select t01.mco_com_code,
                t01.mco_com_quantity
           from psa_mat_comp t01
          where t01.mco_mat_code = rcd_actv.psa_mat_code
            and t01.mco_prd_type = rcd_actv.psa_prd_type
          order by t01.mco_com_code asc;
      rcd_mcom csr_mcom%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the activity
      /*-*/
      var_found := false;
      open csr_actv;
      fetch csr_actv into rcd_actv;
      if csr_actv%found then
         var_found := true;
      end if;
      close csr_actv;
      if var_found = false then
         return;
      end if;

      /*-*/
      /* Calculate the activity data
      /*-*/
      if nvl(rcd_actv.psa_sch_rra_effp,0) = 0 then
         rcd_actv.psa_sch_rra_effp := 100;
      end if;
      if nvl(rcd_actv.psa_sch_rra_wasp,0) = 0 then
         rcd_actv.psa_sch_rra_wasp := 0;
      end if;
      if nvl(rcd_actv.psa_sch_rra_unit,0) = 0 then
         rcd_actv.psa_sch_rra_unit := 1;
      end if;
      if rcd_actv.psa_prd_type = '*FILL' then
         rcd_actv.psa_mat_req_plt_qty := 0;
         rcd_actv.psa_mat_req_cas_qty := rcd_actv.psa_mat_req_qty;
         rcd_actv.psa_mat_req_pch_qty := ceil(rcd_actv.psa_mat_req_cas_qty * rcd_actv.psa_mat_unt_case);
         rcd_actv.psa_mat_req_mix_qty := ceil(rcd_actv.psa_mat_req_pch_qty / nvl(rcd_actv.psa_mat_yld_value,1));
         rcd_actv.psa_mat_req_ton_qty := round((rcd_actv.psa_mat_req_cas_qty * rcd_actv.psa_mat_net_weight) / 1000, 3);
         rcd_actv.psa_mat_req_dur_min := round(rcd_actv.psa_mat_req_pch_qty / (rcd_actv.psa_sch_rra_unit * (rcd_actv.psa_sch_rra_effp / 100)), 0);
         rcd_actv.psa_mat_sch_plt_qty := 0;
         rcd_actv.psa_mat_sch_cas_qty := ceil((rcd_actv.psa_mat_req_cas_qty / (100 - rcd_actv.psa_sch_rra_wasp)) * 100);
         rcd_actv.psa_mat_sch_pch_qty := ceil(rcd_actv.psa_mat_sch_cas_qty * rcd_actv.psa_mat_unt_case);
         rcd_actv.psa_mat_sch_mix_qty := ceil(rcd_actv.psa_mat_sch_pch_qty / nvl(rcd_actv.psa_mat_yld_value,1));
         rcd_actv.psa_mat_sch_ton_qty := round((rcd_actv.psa_mat_sch_cas_qty * rcd_actv.psa_mat_net_weight) / 1000, 3);
         rcd_actv.psa_mat_sch_dur_min := round(rcd_actv.psa_mat_sch_pch_qty / (rcd_actv.psa_sch_rra_unit * (rcd_actv.psa_sch_rra_effp / 100)), 0);
         rcd_actv.psa_mat_sch_qty := rcd_actv.psa_mat_sch_cas_qty;
         rcd_actv.psa_mat_sch_was := rcd_actv.psa_mat_sch_qty - rcd_actv.psa_mat_req_qty;
      elsif rcd_actv.psa_prd_type = '*PACK' then
         rcd_actv.psa_mat_req_cas_qty := rcd_actv.psa_mat_req_qty;
         rcd_actv.psa_mat_req_plt_qty := ceil(rcd_actv.psa_mat_req_cas_qty / rcd_actv.psa_mat_cas_pallet);
         rcd_actv.psa_mat_req_pch_qty := 0;
         rcd_actv.psa_mat_req_mix_qty := 0;
         rcd_actv.psa_mat_req_ton_qty := 0;
         rcd_actv.psa_mat_req_dur_min := round((rcd_actv.psa_mat_req_cas_qty / (rcd_actv.psa_sch_rra_unit * (rcd_actv.psa_sch_rra_effp / 100))) * 60, 0);
         rcd_actv.psa_mat_sch_cas_qty := ceil((rcd_actv.psa_mat_req_cas_qty / (100 - rcd_actv.psa_sch_rra_wasp)) * 100);
         rcd_actv.psa_mat_sch_plt_qty := ceil(rcd_actv.psa_mat_sch_cas_qty / rcd_actv.psa_mat_cas_pallet);
         rcd_actv.psa_mat_sch_pch_qty := 0;
         rcd_actv.psa_mat_sch_mix_qty := 0;
         rcd_actv.psa_mat_sch_ton_qty := 0;
         rcd_actv.psa_mat_sch_dur_min := round((rcd_actv.psa_mat_sch_cas_qty / (rcd_actv.psa_sch_rra_unit * (rcd_actv.psa_sch_rra_effp / 100))) * 60, 0);
         rcd_actv.psa_mat_sch_qty := rcd_actv.psa_mat_sch_cas_qty;
         rcd_actv.psa_mat_sch_was := rcd_actv.psa_mat_sch_qty - rcd_actv.psa_mat_req_qty;
      elsif rcd_actv.psa_prd_type = '*FORM' then
         rcd_actv.psa_mat_req_plt_qty := 0;
         rcd_actv.psa_mat_req_cas_qty := 0;
         rcd_actv.psa_mat_req_pch_qty := rcd_actv.psa_mat_req_qty;
         rcd_actv.psa_mat_req_mix_qty := 0;
         rcd_actv.psa_mat_req_ton_qty := 0;
         rcd_actv.psa_mat_req_dur_min := round(rcd_actv.psa_mat_req_pch_qty / (rcd_actv.psa_sch_rra_unit * (rcd_actv.psa_sch_rra_effp / 100)), 0);
         rcd_actv.psa_mat_sch_plt_qty := 0;
         rcd_actv.psa_mat_sch_cas_qty := 0;
         rcd_actv.psa_mat_sch_pch_qty := ceil((rcd_actv.psa_mat_req_pch_qty / (100 - rcd_actv.psa_sch_rra_wasp)) * 100);
         rcd_actv.psa_mat_sch_mix_qty := 0;
         rcd_actv.psa_mat_sch_ton_qty := 0;
         rcd_actv.psa_mat_sch_dur_min := round(rcd_actv.psa_mat_sch_pch_qty / (rcd_actv.psa_sch_rra_unit * (rcd_actv.psa_sch_rra_effp / 100)), 0);
         rcd_actv.psa_mat_sch_qty := rcd_actv.psa_mat_sch_pch_qty;
         rcd_actv.psa_mat_sch_was := rcd_actv.psa_mat_sch_qty - rcd_actv.psa_mat_req_qty;
      end if;
      rcd_actv.psa_mat_sch_plt_was := rcd_actv.psa_mat_sch_plt_qty - rcd_actv.psa_mat_req_plt_qty;
      rcd_actv.psa_mat_sch_cas_was := rcd_actv.psa_mat_sch_cas_qty - rcd_actv.psa_mat_req_cas_qty;
      rcd_actv.psa_mat_sch_pch_was := rcd_actv.psa_mat_sch_pch_qty - rcd_actv.psa_mat_req_pch_qty;
      rcd_actv.psa_mat_sch_mix_was := rcd_actv.psa_mat_sch_mix_qty - rcd_actv.psa_mat_req_mix_qty;
      rcd_actv.psa_mat_sch_ton_was := rcd_actv.psa_mat_sch_ton_qty - rcd_actv.psa_mat_req_ton_qty;
      rcd_actv.psa_sch_dur_mins := rcd_actv.psa_mat_sch_dur_min;
      rcd_actv.psa_mat_act_qty := rcd_actv.psa_mat_sch_qty;
      rcd_actv.psa_mat_act_was := rcd_actv.psa_mat_sch_was;
      rcd_actv.psa_mat_act_plt_qty := rcd_actv.psa_mat_sch_plt_qty;
      rcd_actv.psa_mat_act_cas_qty := rcd_actv.psa_mat_sch_cas_qty;
      rcd_actv.psa_mat_act_pch_qty := rcd_actv.psa_mat_sch_pch_qty;
      rcd_actv.psa_mat_act_mix_qty := rcd_actv.psa_mat_sch_mix_qty;
      rcd_actv.psa_mat_act_ton_qty := rcd_actv.psa_mat_sch_ton_qty;
      rcd_actv.psa_mat_act_plt_was := rcd_actv.psa_mat_sch_plt_was;
      rcd_actv.psa_mat_act_cas_was := rcd_actv.psa_mat_sch_cas_was;
      rcd_actv.psa_mat_act_pch_was := rcd_actv.psa_mat_sch_pch_was;
      rcd_actv.psa_mat_act_mix_was := rcd_actv.psa_mat_sch_mix_was;
      rcd_actv.psa_mat_act_ton_was := rcd_actv.psa_mat_sch_ton_was;
      rcd_actv.psa_mat_act_dur_min := rcd_actv.psa_mat_sch_dur_min;
      rcd_actv.psa_act_dur_mins := rcd_actv.psa_mat_act_dur_min;
      rcd_actv.psa_mat_inv_qty := rcd_actv.psa_mat_req_qty;
      rcd_actv.psa_mat_inv_plt_qty := rcd_actv.psa_mat_req_plt_qty;
      rcd_actv.psa_mat_inv_cas_qty := rcd_actv.psa_mat_req_cas_qty;
      rcd_actv.psa_mat_inv_pch_qty := rcd_actv.psa_mat_req_pch_qty;
      rcd_actv.psa_mat_inv_ton_qty := rcd_actv.psa_mat_req_ton_qty;

      /*-*/
      /* Update the activity data
      /*-*/
      update psa_psc_actv
         set psa_sch_dur_mins = rcd_actv.psa_sch_dur_mins,
             psa_act_dur_mins = rcd_actv.psa_act_dur_mins,
             psa_mat_req_plt_qty = rcd_actv.psa_mat_req_plt_qty,
             psa_mat_req_cas_qty = rcd_actv.psa_mat_req_cas_qty,
             psa_mat_req_pch_qty = rcd_actv.psa_mat_req_pch_qty,
             psa_mat_req_mix_qty = rcd_actv.psa_mat_req_mix_qty,
             psa_mat_req_ton_qty = rcd_actv.psa_mat_req_ton_qty,
             psa_mat_req_dur_min = rcd_actv.psa_mat_req_dur_min,
             psa_mat_sch_qty = rcd_actv.psa_mat_sch_qty,
             psa_mat_sch_was = rcd_actv.psa_mat_sch_was,
             psa_mat_sch_plt_qty = rcd_actv.psa_mat_sch_plt_qty,
             psa_mat_sch_cas_qty = rcd_actv.psa_mat_sch_cas_qty,
             psa_mat_sch_pch_qty = rcd_actv.psa_mat_sch_pch_qty,
             psa_mat_sch_mix_qty = rcd_actv.psa_mat_sch_mix_qty,
             psa_mat_sch_ton_qty = rcd_actv.psa_mat_sch_ton_qty,
             psa_mat_sch_plt_was = rcd_actv.psa_mat_sch_plt_was,
             psa_mat_sch_cas_was = rcd_actv.psa_mat_sch_cas_was,
             psa_mat_sch_pch_was = rcd_actv.psa_mat_sch_pch_was,
             psa_mat_sch_mix_was = rcd_actv.psa_mat_sch_mix_was,
             psa_mat_sch_ton_was = rcd_actv.psa_mat_sch_ton_was,
             psa_mat_sch_dur_min = rcd_actv.psa_mat_sch_dur_min,
             psa_mat_act_qty = rcd_actv.psa_mat_act_qty,
             psa_mat_act_was = rcd_actv.psa_mat_act_was,
             psa_mat_act_plt_qty = rcd_actv.psa_mat_act_plt_qty,
             psa_mat_act_cas_qty = rcd_actv.psa_mat_act_cas_qty,
             psa_mat_act_pch_qty = rcd_actv.psa_mat_act_pch_qty,
             psa_mat_act_mix_qty = rcd_actv.psa_mat_act_mix_qty,
             psa_mat_act_ton_qty = rcd_actv.psa_mat_act_ton_qty,
             psa_mat_act_plt_was = rcd_actv.psa_mat_act_plt_was,
             psa_mat_act_cas_was = rcd_actv.psa_mat_act_cas_was,
             psa_mat_act_pch_was = rcd_actv.psa_mat_act_pch_was,
             psa_mat_act_mix_was = rcd_actv.psa_mat_act_mix_was,
             psa_mat_act_ton_was = rcd_actv.psa_mat_act_ton_was,
             psa_mat_act_dur_min = rcd_actv.psa_mat_act_dur_min,
             psa_mat_inv_qty = rcd_actv.psa_mat_inv_qty,
             psa_mat_inv_plt_qty = rcd_actv.psa_mat_inv_plt_qty,
             psa_mat_inv_cas_qty = rcd_actv.psa_mat_inv_cas_qty,
             psa_mat_inv_pch_qty = rcd_actv.psa_mat_inv_pch_qty,
             psa_mat_inv_ton_qty = rcd_actv.psa_mat_inv_ton_qty
       where psa_act_code = rcd_actv.psa_act_code;

      /*-*/
      /* Reload the activity inventory requirements
      /*-*/
      delete from psa_psc_invt where psi_act_code = rcd_actv.psa_act_code;
      open csr_mcom;
      loop
         fetch csr_mcom into rcd_mcom;
         if csr_mcom%notfound then
            exit;
         end if;
         rcd_psa_psc_invt.psi_act_code := rcd_actv.psa_act_code;
         rcd_psa_psc_invt.psi_mat_code := rcd_mcom.mco_com_code;
         rcd_psa_psc_invt.psi_inv_qnty := rcd_mcom.mco_com_quantity * rcd_actv.psa_mat_act_qty;
         rcd_psa_psc_invt.psi_inv_aval := 0;
         insert into psa_psc_invt values rcd_psa_psc_invt;
      end loop;
      close csr_mcom;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end calc_schedule;

   /********************************************************/
   /* This procedure performs the calculate actual routine */
   /********************************************************/
   procedure calc_actual(par_act_code in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      rcd_psa_psc_invt psa_psc_invt%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_actv is
         select t01.*
           from psa_psc_actv t01
          where t01.psa_act_code = par_act_code;
      rcd_actv csr_actv%rowtype;

      cursor csr_enty is
         select sum(t01.pse_ent_qnty) as pse_ent_qnty,
                sum(t01.pse_ent_wast) as pse_ent_wast
           from psa_psc_enty t01
          where t01.pse_act_code = par_act_code;
      rcd_enty csr_enty%rowtype;

      cursor csr_mcom is
         select t01.mco_com_code,
                t01.mco_com_quantity
           from psa_mat_comp t01
          where t01.mco_mat_code = rcd_actv.psa_mat_code
            and t01.mco_prd_type = rcd_actv.psa_prd_type
          order by t01.mco_com_code asc;
      rcd_mcom csr_mcom%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the activity
      /*-*/
      var_found := false;
      open csr_actv;
      fetch csr_actv into rcd_actv;
      if csr_actv%found then
         var_found := true;
      end if;
      close csr_actv;
      if var_found = false then
         return;
      end if;

      /*-*/
      /* Retrieve the entry
      /*-*/
      rcd_actv.psa_mat_act_qty := 0;
      rcd_actv.psa_mat_act_was := 0;
      open csr_enty;
      fetch csr_enty into rcd_enty;
      if csr_enty%found then
         rcd_actv.psa_mat_act_qty := nvl(rcd_enty.pse_ent_qnty,0) + nvl(rcd_enty.pse_ent_wast,0);
         rcd_actv.psa_mat_act_was := nvl(rcd_enty.pse_ent_wast,0);
      end if;
      close csr_enty;

      /*-*/
      /* Calculate the activity data
      /*-*/
      if nvl(rcd_actv.psa_act_rra_effp,0) = 0 then
         rcd_actv.psa_act_rra_effp := 100;
      end if;
      if nvl(rcd_actv.psa_act_rra_wasp,0) = 0 then
         rcd_actv.psa_act_rra_wasp := 0;
      end if;
      if nvl(rcd_actv.psa_act_rra_unit,0) = 0 then
         rcd_actv.psa_act_rra_unit := 1;
      end if;
      if rcd_actv.psa_act_chg_flag = '0' then
         rcd_actv.psa_mat_act_dur_min := round((rcd_actv.psa_act_end_time - rcd_actv.psa_act_str_time) * 1440, 0);
      else
         rcd_actv.psa_act_chg_time := rcd_actv.psa_act_end_time - (rcd_actv.psa_act_chg_mins / 1440);
         rcd_actv.psa_mat_act_dur_min := round((rcd_actv.psa_act_chg_time - rcd_actv.psa_act_str_time) * 1440, 0);
      end if;
      rcd_actv.psa_act_dur_mins := rcd_actv.psa_mat_act_dur_min;
      if rcd_actv.psa_prd_type = '*FILL' then
         rcd_actv.psa_mat_act_plt_qty := 0;
         rcd_actv.psa_mat_act_pch_qty := rcd_actv.psa_mat_act_qty;
         rcd_actv.psa_mat_act_cas_qty := ceil(rcd_actv.psa_mat_act_pch_qty / nvl(rcd_actv.psa_mat_unt_case,1));
         rcd_actv.psa_mat_act_mix_qty := ceil(rcd_actv.psa_mat_act_pch_qty / nvl(rcd_actv.psa_mat_yld_value,1));
         rcd_actv.psa_mat_act_ton_qty := round((rcd_actv.psa_mat_act_cas_qty * rcd_actv.psa_mat_net_weight) / 1000, 3);
         rcd_actv.psa_mat_act_plt_was := 0;
         rcd_actv.psa_mat_act_pch_was := rcd_actv.psa_mat_act_was;
         rcd_actv.psa_mat_act_cas_was := ceil(rcd_actv.psa_mat_act_pch_was / nvl(rcd_actv.psa_mat_unt_case,1));
         rcd_actv.psa_mat_act_mix_was := ceil(rcd_actv.psa_mat_act_pch_was / nvl(rcd_actv.psa_mat_yld_value,1));
         rcd_actv.psa_mat_act_ton_was := round((rcd_actv.psa_mat_act_cas_was * rcd_actv.psa_mat_net_weight) / 1000, 3);
         rcd_actv.psa_act_cal_unit := ceil(rcd_actv.psa_mat_act_qty / rcd_actv.psa_mat_act_dur_min);
         rcd_actv.psa_act_cal_effp := round((rcd_actv.psa_act_cal_unit / rcd_actv.psa_act_rra_unit) * 100, 2);
         rcd_actv.psa_act_cal_wasp := round((rcd_actv.psa_mat_act_was / rcd_actv.psa_mat_act_qty) * 100, 2);
      elsif rcd_actv.psa_prd_type = '*PACK' then
         rcd_actv.psa_mat_act_cas_qty := rcd_actv.psa_mat_act_qty;
         rcd_actv.psa_mat_act_plt_qty := ceil(rcd_actv.psa_mat_act_cas_qty / rcd_actv.psa_mat_cas_pallet);
         rcd_actv.psa_mat_act_pch_qty := 0;
         rcd_actv.psa_mat_act_mix_qty := 0;
         rcd_actv.psa_mat_act_ton_qty := 0;
         rcd_actv.psa_mat_act_cas_was := rcd_actv.psa_mat_act_was;
         rcd_actv.psa_mat_act_plt_was := ceil(rcd_actv.psa_mat_act_cas_was / rcd_actv.psa_mat_cas_pallet);
         rcd_actv.psa_mat_act_pch_was := 0;
         rcd_actv.psa_mat_act_mix_was := 0;
         rcd_actv.psa_mat_act_ton_was := 0;
         rcd_actv.psa_act_cal_unit := ceil(rcd_actv.psa_mat_act_qty / (rcd_actv.psa_mat_act_dur_min / 60));
         rcd_actv.psa_act_cal_effp := round((rcd_actv.psa_act_cal_unit / rcd_actv.psa_act_rra_unit) * 100, 2);
         rcd_actv.psa_act_cal_wasp := round((rcd_actv.psa_mat_act_was / rcd_actv.psa_mat_act_qty) * 100, 2);
      elsif rcd_actv.psa_prd_type = '*FORM' then
         rcd_actv.psa_mat_act_plt_qty := 0;
         rcd_actv.psa_mat_act_cas_qty := 0;
         rcd_actv.psa_mat_act_pch_qty := rcd_actv.psa_mat_act_qty;
         rcd_actv.psa_mat_act_mix_qty := 0;
         rcd_actv.psa_mat_act_ton_qty := 0;
         rcd_actv.psa_mat_act_plt_was := 0;
         rcd_actv.psa_mat_act_cas_was := 0;
         rcd_actv.psa_mat_act_pch_was := rcd_actv.psa_mat_act_was;
         rcd_actv.psa_mat_act_mix_was := 0;
         rcd_actv.psa_mat_act_ton_was := 0;
         rcd_actv.psa_act_cal_unit := ceil(rcd_actv.psa_mat_act_qty / rcd_actv.psa_mat_act_dur_min);
         rcd_actv.psa_act_cal_effp := round((rcd_actv.psa_act_cal_unit / rcd_actv.psa_act_rra_unit) * 100, 2);
         rcd_actv.psa_act_cal_wasp := round((rcd_actv.psa_mat_act_was / rcd_actv.psa_mat_act_qty) * 100, 2);
      end if;
      rcd_actv.psa_mat_inv_qty := rcd_actv.psa_mat_act_qty - rcd_actv.psa_mat_act_was;
      rcd_actv.psa_mat_inv_plt_qty := rcd_actv.psa_mat_act_plt_qty - rcd_actv.psa_mat_act_plt_was;
      rcd_actv.psa_mat_inv_cas_qty := rcd_actv.psa_mat_act_cas_qty - rcd_actv.psa_mat_act_cas_was;
      rcd_actv.psa_mat_inv_pch_qty := rcd_actv.psa_mat_act_pch_qty - rcd_actv.psa_mat_act_pch_was;
      rcd_actv.psa_mat_inv_ton_qty := rcd_actv.psa_mat_act_ton_qty - rcd_actv.psa_mat_act_ton_was;
      rcd_actv.psa_mat_var_plt_qty := rcd_actv.psa_mat_act_plt_qty - rcd_actv.psa_mat_sch_plt_qty;
      rcd_actv.psa_mat_var_cas_qty := rcd_actv.psa_mat_act_cas_qty - rcd_actv.psa_mat_sch_cas_qty;
      rcd_actv.psa_mat_var_pch_qty := rcd_actv.psa_mat_act_pch_qty - rcd_actv.psa_mat_sch_pch_qty;
      rcd_actv.psa_mat_var_mix_qty := rcd_actv.psa_mat_act_mix_qty - rcd_actv.psa_mat_sch_mix_qty;
      rcd_actv.psa_mat_var_ton_qty := rcd_actv.psa_mat_act_ton_qty - rcd_actv.psa_mat_sch_ton_qty;
      rcd_actv.psa_mat_var_plt_was := rcd_actv.psa_mat_act_plt_was - rcd_actv.psa_mat_sch_plt_was;
      rcd_actv.psa_mat_var_cas_was := rcd_actv.psa_mat_act_cas_was - rcd_actv.psa_mat_sch_cas_was;
      rcd_actv.psa_mat_var_pch_was := rcd_actv.psa_mat_act_pch_was - rcd_actv.psa_mat_sch_pch_was;
      rcd_actv.psa_mat_var_mix_was := rcd_actv.psa_mat_act_mix_was - rcd_actv.psa_mat_sch_mix_was;
      rcd_actv.psa_mat_var_ton_was := rcd_actv.psa_mat_act_ton_was - rcd_actv.psa_mat_sch_ton_was;
      rcd_actv.psa_mat_var_dur_min := rcd_actv.psa_mat_act_dur_min - rcd_actv.psa_mat_sch_dur_min;
      rcd_actv.psa_var_dur_mins := rcd_actv.psa_act_dur_mins - rcd_actv.psa_sch_dur_mins;
      rcd_actv.psa_var_chg_mins := rcd_actv.psa_act_chg_mins - rcd_actv.psa_sch_chg_mins;

      /*-*/
      /* Update the activity data
      /*-*/
      update psa_psc_actv
         set psa_act_cal_unit = rcd_actv.psa_act_cal_unit,
             psa_act_cal_effp = rcd_actv.psa_act_cal_effp,
             psa_act_cal_wasp = rcd_actv.psa_act_cal_wasp,
             psa_act_dur_mins = rcd_actv.psa_act_dur_mins,
             psa_var_dur_mins = rcd_actv.psa_var_dur_mins,
             psa_var_chg_mins = rcd_actv.psa_var_chg_mins,
             psa_mat_act_qty = rcd_actv.psa_mat_act_qty,
             psa_mat_act_was = rcd_actv.psa_mat_act_was,
             psa_mat_act_plt_qty = rcd_actv.psa_mat_act_plt_qty,
             psa_mat_act_cas_qty = rcd_actv.psa_mat_act_cas_qty,
             psa_mat_act_pch_qty = rcd_actv.psa_mat_act_pch_qty,
             psa_mat_act_mix_qty = rcd_actv.psa_mat_act_mix_qty,
             psa_mat_act_ton_qty = rcd_actv.psa_mat_act_ton_qty,
             psa_mat_act_plt_was = rcd_actv.psa_mat_act_plt_was,
             psa_mat_act_cas_was = rcd_actv.psa_mat_act_cas_was,
             psa_mat_act_pch_was = rcd_actv.psa_mat_act_pch_was,
             psa_mat_act_mix_was = rcd_actv.psa_mat_act_mix_was,
             psa_mat_act_ton_was = rcd_actv.psa_mat_act_ton_was,
             psa_mat_act_dur_min = rcd_actv.psa_mat_act_dur_min,
             psa_mat_inv_qty = rcd_actv.psa_mat_inv_qty,
             psa_mat_inv_plt_qty = rcd_actv.psa_mat_inv_plt_qty,
             psa_mat_inv_cas_qty = rcd_actv.psa_mat_inv_cas_qty,
             psa_mat_inv_pch_qty = rcd_actv.psa_mat_inv_pch_qty,
             psa_mat_inv_ton_qty = rcd_actv.psa_mat_inv_ton_qty,
             psa_mat_var_plt_qty = rcd_actv.psa_mat_var_plt_qty,
             psa_mat_var_cas_qty = rcd_actv.psa_mat_var_cas_qty,
             psa_mat_var_pch_qty = rcd_actv.psa_mat_var_pch_qty,
             psa_mat_var_mix_qty = rcd_actv.psa_mat_var_mix_qty,
             psa_mat_var_ton_qty = rcd_actv.psa_mat_var_ton_qty,
             psa_mat_var_plt_was = rcd_actv.psa_mat_var_plt_was,
             psa_mat_var_cas_was = rcd_actv.psa_mat_var_cas_was,
             psa_mat_var_pch_was = rcd_actv.psa_mat_var_pch_was,
             psa_mat_var_mix_was = rcd_actv.psa_mat_var_mix_was,
             psa_mat_var_ton_was = rcd_actv.psa_mat_var_ton_was,
             psa_mat_var_dur_min = rcd_actv.psa_mat_var_dur_min
       where psa_act_code = rcd_actv.psa_act_code;

      /*-*/
      /* Reload the activity inventory requirements
      /*-*/
      delete from psa_psc_invt where psi_act_code = rcd_actv.psa_act_code;
      open csr_mcom;
      loop
         fetch csr_mcom into rcd_mcom;
         if csr_mcom%notfound then
            exit;
         end if;
         rcd_psa_psc_invt.psi_act_code := rcd_actv.psa_act_code;
         rcd_psa_psc_invt.psi_mat_code := rcd_mcom.mco_com_code;
         rcd_psa_psc_invt.psi_inv_qnty := rcd_mcom.mco_com_quantity * rcd_actv.psa_mat_act_qty;
         rcd_psa_psc_invt.psi_inv_aval := 0;
         insert into psa_psc_invt values rcd_psa_psc_invt;
      end loop;
      close csr_mcom;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end calc_actual;

   /******************************************************/
   /* This procedure performs the align activity routine */
   /******************************************************/
   procedure align_activity(par_psc_code in varchar2,
                            par_prd_type in varchar2,
                            par_lin_code in varchar2,
                            par_con_code in varchar2,
                            par_win_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_win_code varchar2(32);
      var_win_seqn number;
      var_win_flow varchar2(1);
      var_str_time date;
      var_chg_time date;
      var_end_time date;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_pact is
         select t01.*
           from psa_psc_actv t01
          where t01.psa_psc_code = par_psc_code
            and t01.psa_prd_type = par_prd_type
            and t01.psa_act_lin_code = par_lin_code
            and t01.psa_act_con_code = par_con_code
            and t01.psa_act_win_code != '*NONE'
            and t01.psa_act_win_code < par_win_code
          order by t01.psa_act_win_code desc,
                   t01.psa_act_win_seqn desc;
      rcd_pact csr_pact%rowtype;

      cursor csr_sact is
         select t01.*,
                t02.pss_win_stim,
                t02.pss_win_etim
           from psa_psc_actv t01,
                (select t01.pss_win_code,
                        t01.pss_win_stim,
                        t01.pss_win_etim
                   from psa_psc_shft t01
                  where t01.pss_psc_code = par_psc_code
                    and t01.pss_prd_type = par_prd_type
                    and t01.pss_lin_code = par_lin_code
                    and t01.pss_con_code = par_con_code
                    and t01.pss_win_code != '*NONE'
                    and t01.pss_win_code >= par_win_code
                    and t01.pss_win_type = '1') t02
          where t01.psa_act_win_code = t02.pss_win_code(+)
            and t01.psa_psc_code = par_psc_code
            and t01.psa_prd_type = par_prd_type
            and t01.psa_act_lin_code = par_lin_code
            and t01.psa_act_con_code = par_con_code
            and t01.psa_act_win_code != '*NONE'
            and t01.psa_act_win_code >= par_win_code
          order by t01.psa_act_win_code asc,
                   t01.psa_act_win_seqn asc;
      rcd_sact csr_sact%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the previous activity
      /*-*/
      var_win_code := '*NONE';
      var_win_seqn := 0;
      var_str_time := to_date('20000101','yyyymmdd');
      var_chg_time := null;
      var_end_time := null;
      open csr_pact;
      fetch csr_pact into rcd_pact;
      if csr_pact%found then
         var_win_code := rcd_pact.psa_act_win_code;
         var_win_seqn := rcd_pact.psa_act_win_seqn;
         var_str_time := rcd_pact.psa_act_end_time + (1 / 1440);
      end if;
      close csr_pact;

      /*-*/
      /* Realign the shift window actual activities
      /*-*/
      open csr_sact;
      loop
         fetch csr_sact into rcd_sact;
         if csr_sact%notfound then
            exit;
         end if;
         if rcd_sact.psa_act_win_code != var_win_code then
            var_win_code := rcd_sact.psa_act_win_code;
            var_win_seqn := 0;
            if rcd_sact.pss_win_stim >= var_str_time then
               var_str_time := rcd_sact.pss_win_stim;
               if var_win_code > par_win_code and rcd_sact.psa_act_str_time = rcd_sact.pss_win_stim then
                  exit;
               end if;
            end if;
         end if;
         var_win_seqn := var_win_seqn + 1;
         if rcd_sact.psa_act_type = 'P' then
            if rcd_sact.psa_act_chg_flag = '1' then
               var_chg_time := var_str_time + (rcd_sact.psa_act_dur_mins / 1440);
               var_end_time := var_str_time + ((rcd_sact.psa_act_dur_mins + rcd_sact.psa_act_chg_mins) / 1440);
            else
               var_chg_time := null;
               var_end_time := var_str_time + (rcd_sact.psa_act_dur_mins / 1440);
            end if;
         else
            var_chg_time := null;
            var_end_time := var_str_time + (rcd_sact.psa_act_dur_mins / 1440);
         end if;
         var_win_flow := '0';
         if var_end_time > rcd_sact.pss_win_etim then
            var_win_flow := '1';
         end if;
         update psa_psc_actv
            set psa_act_win_seqn = var_win_seqn,
                psa_act_win_flow = var_win_flow,
                psa_act_str_time = var_str_time,
                psa_act_chg_time = var_chg_time,
                psa_act_end_time = var_end_time
          where psa_act_code = rcd_sact.psa_act_code;
         var_str_time := var_end_time + (1 / 1440);
      end loop;
      close csr_sact;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end align_activity;

   /***************************************************/
   /* This procedure performs the align stock routine */
   /***************************************************/
   procedure align_stock(par_psc_code in varchar2,
                         par_psc_week in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_min_date date;
      var_str_date date;
      var_stk_code varchar2(32);
      var_stk_type varchar2(10);
      var_act_code number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_date is
         select min(trunc(t01.psd_day_date)) as min_day_date
           from psa_psc_date t01
          where t01.psd_psc_code = par_psc_code
            and t01.psd_psc_week = par_psc_week;
      rcd_date csr_date%rowtype;

      cursor csr_stak is
         select t01.sth_stk_code,
                to_date(t01.sth_stk_time,'yyyy/mm/dd hh24:mi') as sth_stk_time,
                nvl(t02.std_mat_code,'*NONE') as std_mat_code,
                nvl(t02.std_mat_qnty,0) as std_mat_qnty
           from psa_stk_header t01,
                psa_stk_detail t02
          where t01.sth_stk_code = t02.std_stk_code(+)
            and t01.sth_stk_type = var_stk_type
          order by to_date(t01.sth_stk_time,'yyyy/mm/dd hh24:mi') desc,
                   t01.sth_stk_code asc,
                   t02.std_mat_code asc;
      rcd_stak csr_stak%rowtype;

      cursor csr_sact is
         select t01.*,
                decode(t01.psa_act_chg_flag,'1',t01.psa_act_chg_time,t01.psa_act_end_time) as psa_prd_time,
                nvl(t02.psi_mat_code,'*NONE') as psi_mat_code,
                nvl(t02.psi_inv_qnty,0) as psi_inv_qnty,
                nvl(t03.mde_mat_type,'*NONE') as psi_mat_type
           from psa_psc_actv t01,
                psa_psc_invt t02,
                psa_mat_defn t03
          where t01.psa_act_code = t02.psi_act_code(+)
            and t02.psi_mat_code = t03.mde_mat_code(+)
            and t01.psa_psc_code = par_psc_code
            and t01.psa_act_type = 'P'
            and t01.psa_act_win_code != '*NONE'
            and t01.psa_act_str_time >= var_str_date
          order by t01.psa_act_str_time asc;
      rcd_sact csr_sact%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the schedule inventory
      /*-*/
      ptbl_sinv.delete;

      /*-*/
      /* Retrieve the week boundaries
      /*-*/
      var_min_date := null;
      open csr_date;
      fetch csr_date into rcd_date;
      if csr_date%found then
         var_min_date := rcd_date.min_day_date;
      end if;
      close csr_date;

      /*-*/
      /* Retrieve the relevant stocktake FERT data
      /*-*/
      var_stk_type := 'FERT';
      var_str_date := to_date('20000101','yyyymmdd');
      var_stk_code := '*FIRST';
      open csr_stak;
      loop
         fetch csr_stak into rcd_stak;
         if csr_stak%notfound then
            exit;
         end if;
         if rcd_stak.sth_stk_code != var_stk_code then
            if var_stk_code = '*EXIT' then
               exit;
            end if;
            if rcd_stak.sth_stk_time < var_min_date then
               var_str_date := rcd_stak.sth_stk_time;
               var_stk_code := '*EXIT';
            else
               var_stk_code := rcd_stak.sth_stk_code;
            end if;
            ptbl_sinv(ptbl_sinv.count+1).invdat := rcd_stak.sth_stk_time;
            ptbl_sinv(ptbl_sinv.count).invtyp := 'FERT';
            ptbl_sinv(ptbl_sinv.count).matary.delete;
         end if;
         if rcd_stak.std_mat_code != '*NONE' then
            ptbl_sinv(ptbl_sinv.count).matary(rcd_stak.std_mat_code) := rcd_stak.std_mat_qnty;
         end if;
      end loop;
      close csr_stak;
      ptbl_sinv(ptbl_sinv.count+1).invdat := to_date('20000101','yyyymmdd');
      ptbl_sinv(ptbl_sinv.count).invtyp := 'FERT';
      ptbl_sinv(ptbl_sinv.count).matary.delete;

      /*-*/
      /* Retrieve the relevant stocktake VERP data
      /*-*/
      var_stk_type := 'VERP';
      var_str_date := to_date('20000101','yyyymmdd');
      var_stk_code := '*FIRST';
      open csr_stak;
      loop
         fetch csr_stak into rcd_stak;
         if csr_stak%notfound then
            exit;
         end if;
         if rcd_stak.sth_stk_code != var_stk_code then
            if var_stk_code = '*EXIT' then
               exit;
            end if;
            if rcd_stak.sth_stk_time < var_min_date then
               var_str_date := rcd_stak.sth_stk_time;
               var_stk_code := '*EXIT';
            else
               var_stk_code := rcd_stak.sth_stk_code;
            end if;
            ptbl_sinv(ptbl_sinv.count+1).invdat := rcd_stak.sth_stk_time;
            ptbl_sinv(ptbl_sinv.count).invtyp := 'VERP';
            ptbl_sinv(ptbl_sinv.count).matary.delete;
         end if;
         if rcd_stak.std_mat_code != '*NONE' then
            ptbl_sinv(ptbl_sinv.count).matary(rcd_stak.std_mat_code) := rcd_stak.std_mat_qnty;
         end if;
      end loop;
      close csr_stak;
      ptbl_sinv(ptbl_sinv.count+1).invdat := to_date('20000101','yyyymmdd');
      ptbl_sinv(ptbl_sinv.count).invtyp := 'VERP';
      ptbl_sinv(ptbl_sinv.count).matary.delete;

      /*-*/
      /* Update the production activity inventory data
      /*-*/
      var_act_code := -1;
      open csr_sact;
      loop
         fetch csr_sact into rcd_sact;
         if csr_sact%notfound then
            exit;
         end if;

         /*-*/
         /* Update the activity inventory comsumption when required
         /* **note** consumption is based on activity start time
         /*-*/
         if rcd_sact.psi_mat_code != '*NONE' then
            for idx in 1..ptbl_sinv.count loop
               if ptbl_sinv(idx).invtyp = rcd_sact.psi_mat_type and ptbl_sinv(idx).invdat <= rcd_sact.psa_prd_time then
                  if not(ptbl_sinv(idx).matary.exists(rcd_sact.psi_mat_code)) then
                     update psa_psc_invt
                        set psi_inv_aval = 0
                      where psi_act_code = rcd_sact.psa_act_code
                        and psi_mat_code = rcd_sact.psi_mat_code;
                     ptbl_sinv(idx).matary(rcd_sact.psi_mat_code) := rcd_sact.psi_inv_qnty * -1;
                  else
                     update psa_psc_invt
                        set psi_inv_aval = ptbl_sinv(idx).matary(rcd_sact.psi_mat_code)
                      where psi_act_code = rcd_sact.psa_act_code
                        and psi_mat_code = rcd_sact.psi_mat_code;
                     ptbl_sinv(idx).matary(rcd_sact.psi_mat_code) := ptbl_sinv(idx).matary(rcd_sact.psi_mat_code) - rcd_sact.psi_inv_qnty;
                  end if;
                  exit;
               end if;
            end loop;
         end if;

         /*-*/
         /* Update the activity inventory production when required
         /* **note** production is based on activity end time
         /*-*/
         if rcd_sact.psa_act_code != var_act_code then
            var_act_code := rcd_sact.psa_act_code;
            for idx in 1..ptbl_sinv.count loop
               if ptbl_sinv(idx).invtyp = rcd_sact.psa_mat_type and ptbl_sinv(idx).invdat <= rcd_sact.psa_act_end_time then
                  if not(ptbl_sinv(idx).matary.exists(rcd_sact.psa_mat_code)) then
                     ptbl_sinv(idx).matary(rcd_sact.psa_mat_code) := rcd_sact.psa_mat_inv_qty;
                  else
                     ptbl_sinv(idx).matary(rcd_sact.psa_mat_code) := ptbl_sinv(idx).matary(rcd_sact.psa_mat_code) + rcd_sact.psa_mat_inv_qty;
                  end if;
                  exit;
              end if;
            end loop;
         end if;

      end loop;
      close csr_sact;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end align_stock;

end psa_psc_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_psc_function for psa_app.psa_psc_function;
grant execute on psa_app.psa_psc_function to public;
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
   function retrieve_data return psa_xml_type pipelined;
   function retrieve_week return psa_xml_type pipelined;

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
      var_wek_code varchar2(32);
      var_output varchar2(2000 char);
      var_shf_flag boolean;
      var_bar_snam varchar2(512);
      var_bar_spos number;
      var_bar_scnt number;
      var_bar_sday number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = var_psc_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_week is
         select t01.psw_psc_code,
                t01.psw_psc_week,
                'Y'||substr(t01.psw_psc_week,1,4)||' P'||substr(t01.psw_psc_week,5,2)||' W'||substr(t01.psw_psc_week,7,1) as wek_name,
                to_char(t02.calendar_date,'yyyy/mm/dd') as day_code,
                to_char(t02.calendar_date,'dy') as day_name
           from psa_psc_week t01,
                mars_date t02
          where t01.psw_psc_week = to_char(t02.mars_week,'fm0000000')
            and t01.psw_psc_code = rcd_retrieve.psh_psc_code
          order by t01.psw_psc_week asc,
                   t02.calendar_date asc;
      rcd_week csr_week%rowtype;

      cursor csr_shft is
         select t01.pss_shf_code,
                t01.pss_shf_start,
                t01.pss_shf_duration,
                t02.sde_shf_name
           from psa_psc_shft t01,
                psa_shf_defn t02
          where t01.pss_shf_code = t02.sde_shf_code
            and t01.pss_psc_code = rcd_week.psw_psc_code
            and t01.pss_psc_week = rcd_week.psw_psc_week
          order by t01.pss_smo_seqn asc;
      rcd_shft csr_shft%rowtype;

      cursor csr_prod is
         select t01.psp_psc_code,
                t01.psp_psc_week,
                t01.psp_prd_type,
                t02.pty_prd_name
           from psa_psc_prod t01,
                psa_prd_type t02
          where t01.psp_prd_type = t02.pty_prd_type
            and t01.psp_psc_code = rcd_week.psw_psc_code
            and t01.psp_psc_week = rcd_week.psw_psc_week
            and t01.psp_prd_type in ('*FILL','*PACK','*FORM')
          order by decode(t01.psp_prd_type,'*FILL',1,'*PACK',2,'*FORM',3) asc;
      rcd_prod csr_prod%rowtype;

      cursor csr_crew is
         select t01.psc_shf_code,
                t01.psc_cmo_code
           from psa_psc_crew t01
          where t01.psc_psc_code = rcd_prod.psp_psc_code
            and t01.psc_psc_week = rcd_prod.psp_psc_week
            and t01.psc_prd_type = rcd_prod.psp_prd_type
          order by t01.psc_shf_code asc;
      rcd_crew csr_crew%rowtype;

      cursor csr_line is
         select t01.psl_lin_code,
                t01.psl_con_code
           from psa_psc_line t01
          where t01.psl_psc_code = rcd_prod.psp_psc_code
            and t01.psl_psc_week = rcd_prod.psp_psc_week
            and t01.psl_prd_type = rcd_prod.psp_prd_type
          order by t01.psl_lin_code asc,
                   t01.psl_con_code asc;
      rcd_line csr_line%rowtype;

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
      /* Pipe the week data XML
      /*-*/
      var_wek_code := '*NULL';
      open csr_week;
      loop
         fetch csr_week into rcd_week;
         if csr_week%notfound then
            exit;
         end if;

         /*-*/
         /* Pipe the week data XML
         /*-*/
         if rcd_week.psw_psc_week != var_wek_code then
            var_wek_code := rcd_week.psw_psc_week;
            pipe row(psa_xml_object('<WEKDFN WEKCDE="'||psa_to_xml(rcd_week.psw_psc_week)||'"'||
                                           ' DAYNAM="'||psa_to_xml(rcd_week.wek_name)||'"/>'));
         end if;

         /*-*/
         /* Pipe the day data XML
         /*-*/
         pipe row(psa_xml_object('<DAYDFN DAYCDE="'||psa_to_xml(rcd_week.day_code)||'"'||
                                        ' DAYNAM="'||psa_to_xml(rcd_week.day_name)||'"/>'));

         /*-*/
         /* Pipe the shift data XML
         /*-*/
         var_shf_flag := false;
         open csr_shft;
         loop
            fetch csr_shft into rcd_shft;
            if csr_shft%notfound then
               exit;
            end if;

            /*-*/
            /* Calculate the shift name
            /*-*/
            if var_shf_flag = false then
               var_bar_spos := ((trunc(rcd_shft.pss_shf_start / 100) + (mod(rcd_shft.pss_shf_start,100) / 60)) * 4) + 1;
            else
               var_bar_spos := var_bar_spos + var_bar_scnt;
            end if;
            var_bar_scnt := (rcd_shft.pss_shf_duration / 60) * 4;
            var_bar_sday := trunc(var_bar_spos / 96) + 1;
            var_bar_snam := 'Sunday';
            if var_bar_sday = 1 then
               var_bar_snam := 'Sunday';
            elsif var_bar_sday = 2 then
               var_bar_snam := 'Monday';
            elsif var_bar_sday = 3 then
               var_bar_snam := 'Tuesday';
            elsif var_bar_sday = 4 then
               var_bar_snam := 'Wednesday';
            elsif var_bar_sday = 5 then
               var_bar_snam := 'Thursday';
            elsif var_bar_sday = 6 then
               var_bar_snam := 'Friday';
            elsif var_bar_sday = 7 then
               var_bar_snam := 'Saturday';
            elsif var_bar_sday = 8 then
               var_bar_snam := 'Sunday';
            end if;
            var_bar_snam := var_bar_snam||' - '||rcd_shft.sde_shf_name;

            /*-*/
            /* Pipe the shift data XML
            /*-*/
            pipe row(psa_xml_object('<SHFDFN SHFCDE="'||psa_to_xml(rcd_shft.pss_shf_code)||'"'||
                                           ' SFHNAM="'||psa_to_xml(var_bar_snam)||'"'||
                                           ' SHFSTR="'||psa_to_xml(to_char(rcd_shft.pss_shf_start))||'"'||
                                           ' SHFDUR="'||psa_to_xml(to_char(rcd_shft.pss_shf_duration))||'"/>'));

         end loop;
         close csr_shft;

         /*-*/
         /* Pipe the production type data XML
         /*-*/
         open csr_prod;
         loop
            fetch csr_prod into rcd_prod;
            if csr_prod%notfound then
               exit;
            end if;

            /*-*/
            /* Pipe the production type data XML
            /*-*/
            pipe row(psa_xml_object('<PTYDFN PTYCDE="'||psa_to_xml(rcd_prod.psp_prd_type)||'"'||
                                           ' PTYNAM="'||psa_to_xml(rcd_prod.pty_prd_name)||'"/>'));

            /*-*/
            /* Pipe the production type crew data XML
            /*-*/
            open csr_crew;
            loop
               fetch csr_crew into rcd_crew;
               if csr_crew%notfound then
                  exit;
               end if;

               /*-*/
               /* Pipe the production type crew data XML
               /*-*/
               pipe row(psa_xml_object('<CREDFN SHFCDE="'||psa_to_xml(rcd_crew.psc_shf_code)||'"'||
                                              ' CMOCDE="'||psa_to_xml(rcd_crew.psc_cmo_code)||'"/>'));

            end loop;
            close csr_crew;

            /*-*/
            /* Pipe the production type line data XML
            /*-*/
            open csr_line;
            loop
               fetch csr_line into rcd_line;
               if csr_line%notfound then
                  exit;
               end if;

               /*-*/
               /* Pipe the production type line data XML
               /*-*/
               pipe row(psa_xml_object('<LINDFN LINCDE="'||psa_to_xml(rcd_line.psl_lin_code)||'"'||
                                              ' CONCDE="'||psa_to_xml(rcd_line.psl_con_code)||'"/>'));

            end loop;
            close csr_line;

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
      var_output varchar2(2000 char);
      var_wek_code varchar2(32);
      var_smo_code varchar2(32);
      var_fil_name varchar2(400);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_psc_hedr t01
          where t01.psh_psc_code = var_psc_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_week is
         select to_char(t01.mars_week,'fm0000000') as wek_code,
                'Y'||substr(to_char(t01.mars_week,'fm0000000'),1,4)||' P'||substr(to_char(t01.mars_week,'fm0000000'),5,2)||' W'||substr(to_char(t01.mars_week,'fm0000000'),7,1) as wek_name,
                to_char(t01.calendar_date,'yyyy/mm/dd') as day_code,
                to_char(t01.calendar_date,'dy') as day_name
           from mars_date t01
          where t01.mars_week in (select distinct(mars_week)
                                    from mars_date
                                    where calendar_date >= trunc(sysdate-28)
                                      and calendar_date <= trunc(sysdate+28))
          order by t01.mars_week asc,
                   t01.calendar_date asc;
      rcd_week csr_week%rowtype;

      cursor csr_preq is
         select t01.rhe_req_code,
                t01.rhe_req_name,
                to_char(t01.rhe_str_week,'fm0000000') as rhe_str_week
           from psa_req_header t01
          where t01.rhe_req_status = '*LOADED'
            and t01.rhe_str_week in (select distinct(mars_week)
                                       from mars_date
                                      where calendar_date >= trunc(sysdate-28)
                                        and calendar_date <= trunc(sysdate+28))
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
                to_char(t01.lde_lin_wastage,'fm990.00') as lde_lin_wastage,
                t01.lde_lin_events,
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
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*CRTWEK' then
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
                                        ' REQNAM="'||psa_to_xml(rcd_preq.rhe_req_name)||'"'||
                                        ' REQWEK="'||psa_to_xml(rcd_preq.rhe_str_week)||'"/>'));
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
                                           ' LINWAS="'||psa_to_xml(rcd_lcon.lde_lin_wastage)||'"'||
                                           ' LINEVT="'||psa_to_xml(rcd_lcon.lde_lin_events)||'"'||
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

end psa_psc_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_psc_function for psa_app.psa_psc_function;
grant execute on psa_app.psa_psc_function to public;

/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_lco_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_lco_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - Line Configuration Function

    This package contain the line configuration functions and procedures.

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

end psa_lco_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_lco_function as

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
      var_lin_code varchar2(32);
      var_str_code varchar2(32);
      var_end_code varchar2(32);
      var_output varchar2(2000 char);
      var_pag_size number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_slct is
         select t01.*
           from (select t01.lco_con_code,
                        t01.lco_con_name,
                        decode(t01.lco_con_status,'0','Inactive','1','Active','*UNKNOWN') as lco_con_status
                   from psa_lin_config t01
                  where (var_str_code is null or t01.lco_con_code >= var_str_code)
                    and t01.lco_lin_code = var_lin_code
                  order by t01.lco_con_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.lco_con_code,
                        t01.lco_con_name,
                        decode(t01.lco_con_status,'0','Inactive','1','Active','*UNKNOWN') as lco_con_status
                   from psa_lin_config t01
                  where ((var_action = '*NXTDEF' and (var_end_code is null or t01.lco_con_code > var_end_code)) or
                         (var_action = '*PRVDEF'))
                    and t01.lco_lin_code = var_lin_code
                  order by t01.lco_con_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.lco_con_code,
                        t01.lco_con_name,
                        decode(t01.lco_con_status,'0','Inactive','1','Active','*UNKNOWN') as lco_con_status
                   from psa_lin_config t01
                  where ((var_action = '*PRVDEF' and (var_str_code is null or t01.lco_con_code < var_str_code)) or
                         (var_action = '*NXTDEF'))
                    and t01.lco_lin_code = var_lin_code
                  order by t01.lco_con_code desc) t01
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
      var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
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
      /* Retrieve the line configuration list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELDEF' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(psa_xml_object('<LSTROW CONCDE="'||to_char(tbl_list(idx).lco_con_code)||'" CONNAM="'||psa_to_xml(tbl_list(idx).lco_con_name)||'" CONSTS="'||psa_to_xml(tbl_list(idx).lco_con_status)||'"/>'));
         end loop;
      elsif var_action = '*NXTDEF' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW CONCDE="'||to_char(tbl_list(idx).lco_con_code)||'" CONNAM="'||psa_to_xml(tbl_list(idx).lco_con_name)||'" CONSTS="'||psa_to_xml(tbl_list(idx).lco_con_status)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW CONCDE="'||to_char(tbl_list(idx).lco_con_code)||'" CONNAM="'||psa_to_xml(tbl_list(idx).lco_con_name)||'" CONSTS="'||psa_to_xml(tbl_list(idx).lco_con_status)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVDEF' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW CONCDE="'||to_char(tbl_list(idx).lco_con_code)||'" CONNAM="'||psa_to_xml(tbl_list(idx).lco_con_name)||'" CONSTS="'||psa_to_xml(tbl_list(idx).lco_con_status)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW CONCDE="'||to_char(tbl_list(idx).lco_con_code)||'" CONNAM="'||psa_to_xml(tbl_list(idx).lco_con_name)||'" CONSTS="'||psa_to_xml(tbl_list(idx).lco_con_status)||'"/>'));
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_LCO_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_lin_code varchar2(32);
      var_con_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_line is
         select t01.*,
                t02.*
           from psa_lin_defn t01,
                psa_prd_type t02
          where t01.lde_prd_type = t02.pty_prd_type
            and t01.lde_lin_code = var_lin_code;
      rcd_line csr_line%rowtype;

      cursor csr_retrieve is
         select t01.*
           from psa_lin_config t01
          where t01.lco_lin_code = var_lin_code
            and t01.lco_con_code = var_con_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_lco_rate is
         select t01.*,
                t02.*
           from psa_lin_rate t01,
                psa_rra_defn t02
          where t01.lra_rra_code = t02.rrd_rra_code
            and t01.lra_lin_code = rcd_retrieve.lco_lin_code
            and t01.lra_con_code = rcd_retrieve.lco_con_code
            and t02.rrd_prd_type = rcd_line.lde_prd_type
            and t02.rrd_rra_status = '1'
          order by t01.lra_rra_code asc;
      rcd_lco_rate csr_lco_rate%rowtype;

      cursor csr_rate is
         select t01.*
           from psa_rra_defn t01
          where t01.rrd_prd_type = rcd_line.lde_prd_type
            and t01.rrd_rra_status = '1'
          order by t01.rrd_rra_code asc;
      rcd_rate csr_rate%rowtype;

      cursor csr_lco_filler is
         select t01.*,
                t02.*
           from psa_lin_filler t01,
                psa_fil_defn t02
          where t01.lfi_fil_code = t02.fde_fil_code
            and t01.lfi_lin_code = rcd_retrieve.lco_lin_code
            and t01.lfi_con_code = rcd_retrieve.lco_con_code
            and t02.fde_fil_status = '1'
          order by t01.lfi_fil_code asc;
      rcd_lco_filler csr_lco_filler%rowtype;

      cursor csr_filler is
         select t01.*
           from psa_fil_defn t01
          where t01.fde_fil_status = '1'
          order by t01.fde_fil_code asc;
      rcd_filler csr_filler%rowtype;

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
      var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
      var_con_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CONCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' and var_action != '*CPYDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the line
      /*-*/
      var_found := false;
      open csr_line;
      fetch csr_line into rcd_line;
      if csr_line%found then
         var_found := true;
      end if;
      close csr_line;
      if var_found = false then
         psa_gen_function.add_mesg_data('Line ('||var_lin_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing line configuration when required
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
            psa_gen_function.add_mesg_data('Line configuration ('||var_lin_code||' - '||var_con_code||') does not exist');
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
      /* Pipe the line XML
      /*-*/
      if var_action = '*UPDDEF' then
         var_output := '<LCODFN CONCDE="'||psa_to_xml(rcd_retrieve.lco_con_code||' - (Last updated by '||rcd_retrieve.lco_upd_user||' on '||to_char(rcd_retrieve.lco_upd_date,'yyyy/mm/dd')||')')||'"';
         var_output := var_output||' CONNAM="'||psa_to_xml(rcd_retrieve.lco_con_name)||'"';
         var_output := var_output||' CONSTS="'||psa_to_xml(rcd_retrieve.lco_con_status)||'"';
         var_output := var_output||' CONFIL="'||psa_to_xml(rcd_line.pty_prd_lin_filler)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CPYDEF' then
         var_output := '<LCODFN CONCDE=""';
         var_output := var_output||' CONNAM="'||psa_to_xml(rcd_retrieve.lco_con_name)||'"';
         var_output := var_output||' CONSTS="'||psa_to_xml(rcd_retrieve.lco_con_status)||'"';
         var_output := var_output||' CONFIL="'||psa_to_xml(rcd_line.pty_prd_lin_filler)||'"/>';
         pipe row(psa_xml_object(var_output));
      elsif var_action = '*CRTDEF' then
         var_output := '<LCODFN CONCDE=""';
         var_output := var_output||' CONNAM=""';
         var_output := var_output||' CONSTS="1"';
         var_output := var_output||' CONFIL="'||psa_to_xml(rcd_line.pty_prd_lin_filler)||'"/>';
         pipe row(psa_xml_object(var_output));
      end if;

      /*-*/
      /* Pipe the line configuration run rate data XML
      /*-*/
      open csr_lco_rate;
      loop
         fetch csr_lco_rate into rcd_lco_rate;
         if csr_lco_rate%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<LCORRA RRACDE="'||psa_to_xml(rcd_lco_rate.rrd_rra_code)||'" RRANAM="'||psa_to_xml('('||rcd_lco_rate.rrd_rra_code||') '||rcd_lco_rate.rrd_rra_name)||'"/>'));
      end loop;
      close csr_lco_rate;

      /*-*/
      /* Pipe the run rate data XML
      /*-*/
      open csr_rate;
      loop
         fetch csr_rate into rcd_rate;
         if csr_rate%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<RRADFN RRACDE="'||psa_to_xml(rcd_rate.rrd_rra_code)||'" RRANAM="'||psa_to_xml('('||rcd_rate.rrd_rra_code||') '||rcd_rate.rrd_rra_name)||'"/>'));
      end loop;
      close csr_rate;

      /*-*/
      /* Retrieve the filler data when required
      /*-*/
      if rcd_line.pty_prd_lin_filler = '1' then

         /*-*/
         /* Pipe the line configuration filler data XML
         /*-*/
         open csr_lco_filler;
         loop
            fetch csr_lco_filler into rcd_lco_filler;
            if csr_lco_filler%notfound then
               exit;
            end if;
            pipe row(psa_xml_object('<LCOFIL FILCDE="'||psa_to_xml(rcd_lco_filler.fde_fil_code)||'" FILNAM="'||psa_to_xml('('||rcd_lco_filler.fde_fil_code||') '||rcd_lco_filler.fde_fil_name)||'"/>'));
         end loop;
         close csr_lco_filler;

         /*-*/
         /* Pipe the filler data XML
         /*-*/
         open csr_filler;
         loop
            fetch csr_filler into rcd_filler;
            if csr_filler%notfound then
               exit;
            end if;
            pipe row(psa_xml_object('<FILDFN FILCDE="'||psa_to_xml(rcd_filler.fde_fil_code)||'" FILNAM="'||psa_to_xml('('||rcd_filler.fde_fil_code||') '||rcd_filler.fde_fil_name)||'"/>'));
         end loop;
         close csr_filler;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_LCO_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      obj_rra_list xmlDom.domNodeList;
      obj_rra_node xmlDom.domNode;
      obj_fil_list xmlDom.domNodeList;
      obj_fil_node xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      var_rra_code varchar2(32);
      var_fil_code varchar2(32);
      rcd_psa_lin_config psa_lin_config%rowtype;
      rcd_psa_lin_rate psa_lin_rate%rowtype;
      rcd_psa_lin_filler psa_lin_filler%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_lin_config t01
          where t01.lco_lin_code = rcd_psa_lin_config.lco_lin_code
            and t01.lco_con_code = rcd_psa_lin_config.lco_con_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_line is
         select t01.*,
                t02.*
           from psa_lin_defn t01,
                psa_prd_type t02
          where t01.lde_prd_type = t02.pty_prd_type
            and t01.lde_lin_code = rcd_psa_lin_config.lco_lin_code;
      rcd_line csr_line%rowtype;

      cursor csr_rate is
         select t01.*
           from psa_rra_defn t01
          where t01.rrd_rra_code = var_rra_code;
      rcd_rate csr_rate%rowtype;

      cursor csr_filler is
         select t01.*
           from psa_fil_defn t01
          where t01.fde_fil_code = var_fil_code;
      rcd_filler csr_filler%rowtype;

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
      rcd_psa_lin_config.lco_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
      rcd_psa_lin_config.lco_con_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CONCDE')));
      rcd_psa_lin_config.lco_con_name := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CONNAM'));
      rcd_psa_lin_config.lco_con_status := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CONSTS'));
      rcd_psa_lin_config.lco_upd_user := upper(par_user);
      rcd_psa_lin_config.lco_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_psa_lin_config.lco_con_code is null then
         psa_gen_function.add_mesg_data('Line configuration code must be supplied');
      end if;
      if rcd_psa_lin_config.lco_con_name is null then
         psa_gen_function.add_mesg_data('Line configuration name must be supplied');
      end if;
      if rcd_psa_lin_config.lco_con_status is null or (rcd_psa_lin_config.lco_con_status != '0' and rcd_psa_lin_config.lco_con_status != '1') then
         psa_gen_function.add_mesg_data('Line configuration status must be (0)inactive or (1)active');
      end if;
      if rcd_psa_lin_config.lco_upd_user is null then
         psa_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the parent relationships
      /*-*/
      open csr_line;
      fetch csr_line into rcd_line;
      if csr_line%notfound then
         psa_gen_function.add_mesg_data('Line code ('||rcd_psa_lin_config.lco_lin_code||') does not exist');
      end if;
      close csr_line;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the child relationships
      /*-*/
      obj_rra_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/LCORRA');
      for idx in 0..xmlDom.getLength(obj_rra_list)-1 loop
         obj_rra_node := xmlDom.item(obj_rra_list,idx);
         var_rra_code := upper(psa_from_xml(xslProcessor.valueOf(obj_rra_node,'@RRACDE')));
         open csr_rate;
         fetch csr_rate into rcd_rate;
         if csr_rate%notfound then
            psa_gen_function.add_mesg_data('Run rate code ('||var_rra_code||') does not exist');
         else
            if rcd_rate.rrd_prd_type != rcd_line.lde_prd_type then
               psa_gen_function.add_mesg_data('Run rate code ('||var_rra_code||') production type must match the parent line production type');
            end if;
            if rcd_rate.rrd_rra_status != '1' then
               psa_gen_function.add_mesg_data('Run rate code ('||var_rra_code||') status must be (1)active');
            end if;
         end if;
         close csr_rate;
      end loop;
      if rcd_line.pty_prd_lin_filler = '1' then
         obj_fil_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/LCOFIL');
         for idx in 0..xmlDom.getLength(obj_fil_list)-1 loop
            obj_fil_node := xmlDom.item(obj_fil_list,idx);
            var_fil_code := upper(psa_from_xml(xslProcessor.valueOf(obj_fil_node,'@FILCDE')));
            open csr_filler;
            fetch csr_filler into rcd_filler;
            if csr_filler%notfound then
               psa_gen_function.add_mesg_data('Filler code ('||var_fil_code||') does not exist');
            else
               if rcd_filler.fde_fil_status != '1' then
                  psa_gen_function.add_mesg_data('Filler code ('||var_fil_code||') status must be (1)active');
               end if;
            end if;
            close csr_filler;
         end loop;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the line configuration
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
               psa_gen_function.add_mesg_data('Line configuration ('||rcd_psa_lin_config.lco_lin_code||' / '||rcd_psa_lin_config.lco_con_code||') is currently locked');
         end;
         if var_found = false then
            psa_gen_function.add_mesg_data('Line configuration ('||rcd_psa_lin_config.lco_lin_code||' / '||rcd_psa_lin_config.lco_con_code||') does not exist');
         end if;
         if psa_gen_function.get_mesg_count = 0 then
            update psa_lin_config
               set lco_con_name = rcd_psa_lin_config.lco_con_name,
                   lco_con_status = rcd_psa_lin_config.lco_con_status,
                   lco_upd_user = rcd_psa_lin_config.lco_upd_user,
                   lco_upd_date = rcd_psa_lin_config.lco_upd_date
             where lco_lin_code = rcd_psa_lin_config.lco_lin_code
               and lco_con_code = rcd_psa_lin_config.lco_con_code;
            delete from psa_lin_rate
             where lra_lin_code = rcd_psa_lin_config.lco_lin_code
               and lra_con_code = rcd_psa_lin_config.lco_con_code;
            delete from psa_lin_filler
             where lfi_lin_code = rcd_psa_lin_config.lco_lin_code
               and lfi_con_code = rcd_psa_lin_config.lco_con_code;
         end if;
      elsif var_action = '*CRTDEF' then
         var_confirm := 'created';
         begin
            insert into psa_lin_config values rcd_psa_lin_config;
         exception
            when dup_val_on_index then
               psa_gen_function.add_mesg_data('Line configuration ('||rcd_psa_lin_config.lco_lin_code||' / '||rcd_psa_lin_config.lco_con_code||') already exists - unable to create');
         end;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve and insert the line configuration run rate data
      /*-*/
      rcd_psa_lin_rate.lra_lin_code := rcd_psa_lin_config.lco_lin_code;
      rcd_psa_lin_rate.lra_con_code := rcd_psa_lin_config.lco_con_code;
      obj_rra_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/LCORRA');
      for idx in 0..xmlDom.getLength(obj_rra_list)-1 loop
         obj_rra_node := xmlDom.item(obj_rra_list,idx);
         rcd_psa_lin_rate.lra_rra_code := upper(psa_from_xml(xslProcessor.valueOf(obj_rra_node,'@RRACDE')));
         insert into psa_lin_rate values rcd_psa_lin_rate;
      end loop;

      /*-*/
      /* Retrieve and insert the line configuration filler data when required
      /*-*/
      if rcd_line.pty_prd_lin_filler = '1' then
         rcd_psa_lin_filler.lfi_lin_code := rcd_psa_lin_config.lco_lin_code;
         rcd_psa_lin_filler.lfi_con_code := rcd_psa_lin_config.lco_con_code;
         obj_fil_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/LCOFIL');
         for idx in 0..xmlDom.getLength(obj_fil_list)-1 loop
            obj_fil_node := xmlDom.item(obj_fil_list,idx);
            rcd_psa_lin_filler.lfi_fil_code := upper(psa_from_xml(xslProcessor.valueOf(obj_fil_node,'@FILCDE')));
            insert into psa_lin_filler values rcd_psa_lin_filler;
         end loop;
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
      psa_gen_function.set_cfrm_data('Line configuration ('||rcd_psa_lin_config.lco_lin_code||' / '||rcd_psa_lin_config.lco_con_code||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_LCO_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      var_lin_code varchar2(32);
      var_con_code varchar2(32);

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
      var_lin_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@LINCDE')));
      var_con_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@CONCDE')));
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the line configuration
      /*-*/
      var_confirm := 'deleted';
      delete from psa_lin_filler where lfi_lin_code = var_lin_code and lfi_con_code = var_con_code;
      delete from psa_lin_rate where lra_lin_code = var_lin_code and lra_con_code = var_con_code;
      delete from psa_lin_config where lco_lin_code = var_lin_code and lco_con_code = var_con_code;

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
      psa_gen_function.set_cfrm_data('Line configuration ('||var_lin_code||' / '||var_con_code||') successfully '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_LCO_FUNCTION - DELETE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_data;

end psa_lco_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_lco_function for psa_app.psa_lco_function;
grant execute on psa_app.psa_lco_function to public;

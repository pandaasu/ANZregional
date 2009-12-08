/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_gen_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_gen_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - General functions

    This package contain the general functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure clear_mesg_data;
   function get_mesg_count return number;
   procedure add_mesg_data(par_message in varchar2);
   function get_mesg_data return psa_xml_type pipelined;
   procedure set_cfrm_data(par_confirm in varchar2);
   function retrieve_system_control return psa_xml_type pipelined;
   procedure update_system_control(par_user in varchar2);
   procedure cancel_system_control(par_user in varchar2);
   function retrieve_system_values return psa_xml_type pipelined;
   procedure update_system_values(par_user in varchar2);
   function retrieve_system_value(par_code in varchar2) return varchar2;

end psa_gen_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_gen_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   pvar_end_code number;
   pvar_cfrm varchar2(2000 char);
   type ptyp_mesg is table of varchar2(2000 char) index by binary_integer;
   ptbl_mesg ptyp_mesg;

   /**********************************************************/
   /* This procedure performs the clear message data routine */
   /**********************************************************/
   procedure clear_mesg_data is

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
      ptbl_mesg.delete;
      pvar_cfrm := null;

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
         raise_application_error(-20000, 'FATAL ERROR - PSA_GEN_FUNCTION - CLEAR_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear_mesg_data;

   /*********************************************************/
   /* This procedure performs the get message count routine */
   /*********************************************************/
   function get_mesg_count return number is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Return the message data count
      /*-*/
      return ptbl_mesg.count;

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
         raise_application_error(-20000, 'FATAL ERROR - PSA_GEN_FUNCTION - GET_MESG_COUNT - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_mesg_count;

   /********************************************************/
   /* This procedure performs the add message data routine */
   /********************************************************/
   procedure add_mesg_data(par_message in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Add the message data
      /*-*/
      ptbl_mesg(ptbl_mesg.count+1) := par_message;

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
         raise_application_error(-20000, 'FATAL ERROR - PSA_GEN_FUNCTION - ADD_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_mesg_data;

   /********************************************************/
   /* This procedure performs the get message data routine */
   /********************************************************/
   function get_mesg_data return psa_xml_type pipelined is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Pipe the message data when required
      /*-*/
      if ptbl_mesg.count != 0 or not(pvar_cfrm is null) then
         pipe row(psa_xml_object('<?xml version="1.0" encoding="UTF-8"?><PSA_RESPONSE>'));
      end if;
      for idx in 1..ptbl_mesg.count loop
         pipe row(psa_xml_object('<ERROR ERRTXT="'||psa_to_xml(ptbl_mesg(idx))||'"/>'));
      end loop;
      if not(pvar_cfrm is null) then
         pipe row(psa_xml_object('<CONFIRM CONTXT="'||psa_to_xml(pvar_cfrm)||'"/>'));
      end if;
      if ptbl_mesg.count != 0 or not(pvar_cfrm is null) then
         pipe row(psa_xml_object('</PSA_RESPONSE>'));
      end if;

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
         raise_application_error(-20000, 'FATAL ERROR - PSA_GEN_FUNCTION - GET_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_mesg_data;

   /********************************************************/
   /* This procedure performs the set confirm data routine */
   /********************************************************/
   procedure set_cfrm_data(par_confirm in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Set the confirm data
      /*-*/
      pvar_cfrm := par_confirm;

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
         raise_application_error(-20000, 'FATAL ERROR - PSA_GEN_FUNCTION - SET_CFRM_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_cfrm_data;

   /***************************************************************/
   /* This procedure performs the retrieve system control routine */
   /***************************************************************/
   function retrieve_system_control return psa_xml_type pipelined is

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
      cursor csr_retrieve is
         select t01.*
           from psa_system t01
          where t01.sys_code = 'SYSTEM_PROCESS';
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_broadcast is
         select t01.*,
                to_char(to_date(t01.rhe_qry_date,'yyyymmddhh24miss'),'yyyy/mm/dd hh24:mi:ss') as rpt_date,
                decode(t01.rhe_status,'1','Automatic','5','Submitted','*UNKNOWN') as exe_status
           from psa_rpt_header t01
          where (t01.rhe_crt_date = to_char(sysdate,'yyyymmdd') and t01.rhe_status = '1') or t01.rhe_status = '5'
          order by t01.rhe_qry_date asc;
      rcd_broadcast csr_broadcast%rowtype;

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
      if var_action != '*GETSYS' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the system value
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         psa_gen_function.add_mesg_data('System code (SYSTEM_PROCESS) does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML response start
      /*-*/
      pipe row(psa_xml_object('<?xml version="1.0" encoding="UTF-8"?><PSA_RESPONSE>'));

      /*-*/
      /* Pipe the XML system status data
      /*-*/
      if rcd_retrieve.sys_value = '*ACTIVE'then
         pipe row(psa_xml_object('<SYSTEM STATUS="System processing is ACTIVE"/>'));
      end if;
      if rcd_retrieve.sys_value = '*STOPPED'then
         pipe row(psa_xml_object('<SYSTEM STATUS="System processing is STOPPED"/>'));
      end if;

      /*-*/
      /* Retrieve the broadcast list
      /*-*/
      open csr_broadcast;
      loop
         fetch csr_broadcast into rcd_broadcast;
         if csr_broadcast%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<BROADCAST QRYCDE="'||psa_to_xml(rcd_broadcast.rhe_qry_code)||'" QRYDTE="'||psa_to_xml(rcd_broadcast.rhe_qry_date)||'" RPTDTE="'||psa_to_xml(rcd_broadcast.rpt_date)||'" EXESTS="'||psa_to_xml(rcd_broadcast.exe_status)||'"/>'));
      end loop;
      close csr_broadcast;

      /*-*/
      /* Pipe the XML response end
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_GEN_FUNCTION - RETRIEVE_SYSTEM_CONTROL - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_system_control;

   /*************************************************************/
   /* This procedure performs the update system control routine */
   /*************************************************************/
   procedure update_system_control(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      rcd_psa_system psa_system%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_system t01
          where t01.sys_code = rcd_psa_system.sys_code
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
      if var_action != '*SYSSTART' and var_action != '*SYSSTOP' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_psa_system.sys_code := 'SYSTEM_PROCESS';
      if var_action = '*SYSSTART'then
         rcd_psa_system.sys_value := '*ACTIVE';
         var_confirm := 'started';
      end if;
      if var_action = '*SYSSTOP'then
         rcd_psa_system.sys_value := '*STOPPED';
         var_confirm := 'stopped';
      end if;
      rcd_psa_system.sys_upd_user := upper(par_user);
      rcd_psa_system.sys_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Update the system value
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
            psa_gen_function.add_mesg_data('System code ('||rcd_psa_system.sys_code||') is currently locked');
      end;
      if var_found = false then
         psa_gen_function.add_mesg_data('System code ('||rcd_psa_system.sys_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count = 0 then
         update psa_system
            set sys_value = rcd_psa_system.sys_value,
                sys_upd_user = rcd_psa_system.sys_upd_user,
                sys_upd_date = rcd_psa_system.sys_upd_date
          where sys_code = rcd_psa_system.sys_code;
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
      psa_gen_function.set_cfrm_data('System processing has been '||var_confirm);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_GEN_FUNCTION - UPDATE_SYSTEM_CONTROL - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_system_control;

   /*************************************************************/
   /* This procedure performs the cancel system control routine */
   /*************************************************************/
   procedure cancel_system_control(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_qry_code varchar2(64);
      var_qry_date varchar2(14);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_rpt_header t01
          where t01.rhe_qry_code = var_qry_code
            and t01.rhe_qry_date = var_qry_date
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
      var_qry_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@QRYCDE'));
      var_qry_date := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@QRYDTE'));
      if var_action != '*CANRPT' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing report
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
            psa_gen_function.add_mesg_data('Report ('||var_qry_code||' - '||var_qry_date||') is currently locked');
      end;
      if var_found = false then
         psa_gen_function.add_mesg_data('Report ('||var_qry_code||' - '||var_qry_date||') does not exist');
      else
         if rcd_retrieve.rhe_status != '1' and rcd_retrieve.rhe_status != '5' then
            psa_gen_function.add_mesg_data('Report ('||var_qry_code||' - '||var_qry_date||') must be status loaded or submitted');
         end if;
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Update the report header to cancelled
      /*-*/
      update psa_rpt_header
         set rhe_upd_user = par_user,
             rhe_upd_date = sysdate,
             rhe_status = '4'
       where rhe_qry_code = rcd_retrieve.rhe_qry_code
         and rhe_qry_date = rcd_retrieve.rhe_qry_date;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_GEN_FUNCTION - CANCEL_SYSTEM_CONTROL - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end cancel_system_control;

   /**************************************************************/
   /* This procedure performs the retrieve system values routine */
   /**************************************************************/
   function retrieve_system_values return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_system t01
          where t01.sys_code != 'SYSTEM_PROCESS';
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
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*GETVAL' then
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
      /* Retrieve the system values
      /*-*/
      open csr_retrieve;
      loop
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<SYSTEM SYSCDE="'||psa_to_xml(rcd_retrieve.sys_code)||'" SYSVAL="'||psa_to_xml(rcd_retrieve.sys_value)||'"/>'));
      end loop;
      close csr_retrieve;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_GEN_FUNCTION - RETRIEVE_SYSTEM_VALUES - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_system_values;

   /************************************************************/
   /* This procedure performs the update system values routine */
   /************************************************************/
   procedure update_system_values(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      obj_val_list xmlDom.domNodeList;
      obj_val_node xmlDom.domNode;
      var_action varchar2(32);
      rcd_psa_system psa_system%rowtype;

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
      if var_action != '*UPDVAL' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and update the system values
      /*-*/
      obj_val_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST/SYSTEM');
      for idx in 0..xmlDom.getLength(obj_val_list)-1 loop
         obj_val_node := xmlDom.item(obj_val_list,idx);
         rcd_psa_system.sys_code := psa_from_xml(xslProcessor.valueOf(obj_val_node,'@SYSCDE'));
         rcd_psa_system.sys_value := psa_from_xml(xslProcessor.valueOf(obj_val_node,'@SYSVAL'));
         rcd_psa_system.sys_upd_user := upper(par_user);
         rcd_psa_system.sys_upd_date := sysdate;
         update psa_system
            set sys_value = rcd_psa_system.sys_value,
                sys_upd_user = rcd_psa_system.sys_upd_user,
                sys_upd_date = rcd_psa_system.sys_upd_date
          where sys_code = rcd_psa_system.sys_code;
      end loop;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_GEN_FUNCTION - UPDATE_SYSTEM_VALUES - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_system_values;

   /*************************************************************/
   /* This procedure performs the retrieve system value routine */
   /*************************************************************/
   function retrieve_system_value(par_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(256);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_system is
         select t01.sys_value
           from psa_system t01
          where t01.sys_code = par_code;
      rcd_system csr_system%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the abbreviation
      /*-*/
      var_return := '*NONE';
      open csr_system;
      fetch csr_system into rcd_system;
      if csr_system%found then
         var_return := rcd_system.sys_value;
      end if;
      close csr_system;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_system_value;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package variables
   /*-*/
   ptbl_mesg.delete;
   pvar_end_code := 0;

end psa_gen_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_gen_function for psa_app.psa_gen_function;
grant execute on psa_app.psa_gen_function to public;

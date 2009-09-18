/******************/
/* Package Header */
/******************/
create or replace package sms_app.sms_gen_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : sms_gen_function
    Owner   : sms_app

    Description
    -----------
    SMS Reporting System - General functions

    This package contain the general functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/07   Steve Gregan   Created
    2009/09   Steve Gregan   Added broadcast cancel to system control
   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure clear_mesg_data;
   function get_mesg_count return number;
   procedure add_mesg_data(par_message in varchar2);
   function get_mesg_data return sms_xml_type pipelined;
   procedure set_cfrm_data(par_confirm in varchar2);
   function retrieve_system_control return sms_xml_type pipelined;
   procedure update_system_control(par_user in varchar2);
   procedure update_system_broadcast(par_user in varchar2);
   function retrieve_system_values return sms_xml_type pipelined;
   procedure update_system_values(par_user in varchar2);
   function retrieve_system_value(par_code in varchar2) return varchar2;
   procedure update_abbreviation(par_qry_code in varchar2, par_qry_date in varchar2);
   function retrieve_abbreviation(par_dim_data in varchar2) return varchar2;
   procedure daily_maintenance;
   procedure period_maintenance;

end sms_gen_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body sms_app.sms_gen_function as

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
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - CLEAR_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

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
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - GET_MESG_COUNT - ' || substr(SQLERRM, 1, 2048));

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
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - ADD_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_mesg_data;

   /********************************************************/
   /* This procedure performs the get message data routine */
   /********************************************************/
   function get_mesg_data return sms_xml_type pipelined is

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
         pipe row(sms_xml_object('<?xml version="1.0" encoding="UTF-8"?><SMS_RESPONSE>'));
      end if;
      for idx in 1..ptbl_mesg.count loop
         pipe row(sms_xml_object('<ERROR ERRTXT="'||sms_to_xml(ptbl_mesg(idx))||'"/>'));
      end loop;
      if not(pvar_cfrm is null) then
         pipe row(sms_xml_object('<CONFIRM CONTXT="'||sms_to_xml(pvar_cfrm)||'"/>'));
      end if;
      if ptbl_mesg.count != 0 or not(pvar_cfrm is null) then
         pipe row(sms_xml_object('</SMS_RESPONSE>'));
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
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - GET_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

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
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - SET_CFRM_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_cfrm_data;

   /***************************************************************/
   /* This procedure performs the retrieve system control routine */
   /***************************************************************/
   function retrieve_system_control return sms_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_sms_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_system t01
          where t01.sys_code = 'SYSTEM_PROCESS';
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_broadcast is
         select t01.*,
                to_char(to_date(t01.rhe_qry_date,'yyyymmddhh24miss'),'yyyy/mm/dd hh24:mi:ss') as rpt_date,
                decode(t01.rhe_status,'1','Automatic','5','Submitted','*UNKNOWN') as exe_status
           from sms_rpt_header t01
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
      sms_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('SMS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_sms_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/SMS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_sms_request,'@ACTION'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*GETSYS' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
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
         sms_gen_function.add_mesg_data('System code (SYSTEM_PROCESS) does not exist');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML response start
      /*-*/
      pipe row(sms_xml_object('<?xml version="1.0" encoding="UTF-8"?><SMS_RESPONSE>'));

      /*-*/
      /* Pipe the XML system status data
      /*-*/
      if rcd_retrieve.sys_value = '*ACTIVE'then
         pipe row(sms_xml_object('<SYSTEM STATUS="System processing is ACTIVE"/>'));
      end if;
      if rcd_retrieve.sys_value = '*STOPPED'then
         pipe row(sms_xml_object('<SYSTEM STATUS="System processing is STOPPED"/>'));
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
         pipe row(sms_xml_object('<BROADCAST QRYCDE="'||sms_to_xml(rcd_broadcast.rhe_qry_code)||'" QRYDTE="'||sms_to_xml(rcd_broadcast.rhe_qry_date)||'" RPTDTE="'||sms_to_xml(rcd_broadcast.rpt_date)||'" EXESTS="'||sms_to_xml(rcd_broadcast.exe_status)||'"/>'));
      end loop;
      close csr_broadcast;

      /*-*/
      /* Pipe the XML response end
      /*-*/
      pipe row(sms_xml_object('</SMS_RESPONSE>'));

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_GEN_FUNCTION - RETRIEVE_SYSTEM_CONTROL - ' || substr(SQLERRM, 1, 1536));

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
      obj_sms_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      rcd_sms_system sms_system%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_system t01
          where t01.sys_code = rcd_sms_system.sys_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the message data
      /*-*/
      sms_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('SMS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_sms_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/SMS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_sms_request,'@ACTION'));
      if var_action != '*SYSSTART' and var_action != '*SYSSTOP' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_sms_system.sys_code := 'SYSTEM_PROCESS';
      if var_action = '*SYSSTART'then
         rcd_sms_system.sys_value := '*ACTIVE';
         var_confirm := 'started';
      end if;
      if var_action = '*SYSSTOP'then
         rcd_sms_system.sys_value := '*STOPPED';
         var_confirm := 'stopped';
      end if;
      rcd_sms_system.sys_upd_user := upper(par_user);
      rcd_sms_system.sys_upd_date := sysdate;
      if sms_gen_function.get_mesg_count != 0 then
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
            sms_gen_function.add_mesg_data('System code ('||rcd_sms_system.sys_code||') is currently locked');
      end;
      if var_found = false then
         sms_gen_function.add_mesg_data('System code ('||rcd_sms_system.sys_code||') does not exist');
      end if;
      if sms_gen_function.get_mesg_count = 0 then
         update sms_system
            set sys_value = rcd_sms_system.sys_value,
                sys_upd_user = rcd_sms_system.sys_upd_user,
                sys_upd_date = rcd_sms_system.sys_upd_date
          where sys_code = rcd_sms_system.sys_code;
      end if;
      if sms_gen_function.get_mesg_count != 0 then
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
      sms_gen_function.set_cfrm_data('System processing has been '||var_confirm);

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_GEN_FUNCTION - UPDATE_SYSTEM_CONTROL - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_system_control;

   /***************************************************************/
   /* This procedure performs the update system broadcast routine */
   /***************************************************************/
   procedure update_system_broadcast(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_sms_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_qry_code varchar2(64);
      var_qry_date varchar2(14);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_rpt_header t01
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
      sms_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('SMS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_sms_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/SMS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_sms_request,'@ACTION'));
      var_qry_code := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYCDE'));
      var_qry_date := sms_from_xml(xslProcessor.valueOf(obj_sms_request,'@QRYDTE'));
      if var_action != '*CANRPT' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
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
            sms_gen_function.add_mesg_data('Report ('||var_qry_code||' - '||var_qry_date||') is currently locked');
      end;
      if var_found = false then
         sms_gen_function.add_mesg_data('Report ('||var_qry_code||' - '||var_qry_date||') does not exist');
      else
         if rcd_retrieve.rhe_status != '1' and rcd_retrieve.rhe_status != '5' then
            sms_gen_function.add_mesg_data('Report ('||var_qry_code||' - '||var_qry_date||') must be status loaded or submitted');
         end if;
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Update the report header to cancelled
      /*-*/
      update sms_rpt_header
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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_GEN_FUNCTION - UPDATE_SYSTEM_BROADCAST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_system_broadcast;

   /**************************************************************/
   /* This procedure performs the retrieve system values routine */
   /**************************************************************/
   function retrieve_system_values return sms_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_sms_request xmlDom.domNode;
      var_action varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from sms_system t01
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
      sms_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('SMS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_sms_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/SMS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_sms_request,'@ACTION'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*GETVAL' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(sms_xml_object('<?xml version="1.0" encoding="UTF-8"?><SMS_RESPONSE>'));

      /*-*/
      /* Retrieve the system values
      /*-*/
      open csr_retrieve;
      loop
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            exit;
         end if;
         pipe row(sms_xml_object('<SYSTEM SYSCDE="'||sms_to_xml(rcd_retrieve.sys_code)||'" SYSVAL="'||sms_to_xml(rcd_retrieve.sys_value)||'"/>'));
      end loop;
      close csr_retrieve;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(sms_xml_object('</SMS_RESPONSE>'));

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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_GEN_FUNCTION - RETRIEVE_SYSTEM_VALUES - ' || substr(SQLERRM, 1, 1536));

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
      obj_sms_request xmlDom.domNode;
      obj_val_list xmlDom.domNodeList;
      obj_val_node xmlDom.domNode;
      var_action varchar2(32);
      rcd_sms_system sms_system%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the message data
      /*-*/
      sms_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('SMS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_sms_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/SMS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_sms_request,'@ACTION'));
      if var_action != '*UPDVAL' then
         sms_gen_function.add_mesg_data('Invalid request action');
      end if;
      if sms_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and update the system values
      /*-*/
      obj_val_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/SMS_REQUEST/SYSTEM');
      for idx in 0..xmlDom.getLength(obj_val_list)-1 loop
         obj_val_node := xmlDom.item(obj_val_list,idx);
         rcd_sms_system.sys_code := sms_from_xml(xslProcessor.valueOf(obj_val_node,'@SYSCDE'));
         rcd_sms_system.sys_value := sms_from_xml(xslProcessor.valueOf(obj_val_node,'@SYSVAL'));
         rcd_sms_system.sys_upd_user := upper(par_user);
         rcd_sms_system.sys_upd_date := sysdate;
         update sms_system
            set sys_value = rcd_sms_system.sys_value,
                sys_upd_user = rcd_sms_system.sys_upd_user,
                sys_upd_date = rcd_sms_system.sys_upd_date
          where sys_code = rcd_sms_system.sys_code;
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
         sms_gen_function.add_mesg_data('FATAL ERROR - SMS_GEN_FUNCTION - UPDATE_SYSTEM_VALUES - ' || substr(SQLERRM, 1, 1536));

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
           from sms_system t01
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

   /***********************************************************/
   /* This procedure performs the update abbreviation routine */
   /***********************************************************/
   procedure update_abbreviation(par_qry_code in varchar2, par_qry_date in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Update the abbreviation table with missing dimension 01 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_val01,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_qry_date =  par_qry_date
            and not(rda_dim_cod01 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_data = rda_dim_val01)
          group by rda_dim_val01;

      /*-*/
      /* Update the abbreviation table with missing dimension 02 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_val02,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_qry_date =  par_qry_date
            and not(rda_dim_cod02 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_data = rda_dim_val02)
          group by rda_dim_val02;

      /*-*/
      /* Update the abbreviation table with missing dimension 03 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_val03,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_qry_date =  par_qry_date
            and not(rda_dim_cod03 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_data = rda_dim_val03)
          group by rda_dim_val03;

      /*-*/
      /* Update the abbreviation table with missing dimension 04 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_val04,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_qry_date =  par_qry_date
            and not(rda_dim_cod04 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_data = rda_dim_val04)
          group by rda_dim_val04;

      /*-*/
      /* Update the abbreviation table with missing dimension 05 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_val05,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_qry_date =  par_qry_date
            and not(rda_dim_cod05 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_data = rda_dim_val05)
          group by rda_dim_val05;

      /*-*/
      /* Update the abbreviation table with missing dimension 06 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_val06,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_qry_date =  par_qry_date
            and not(rda_dim_cod06 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_data = rda_dim_val06)
          group by rda_dim_val06;

      /*-*/
      /* Update the abbreviation table with missing dimension 07 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_val07,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_qry_date =  par_qry_date
            and not(rda_dim_cod07 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_data = rda_dim_val07)
          group by rda_dim_val07;

      /*-*/
      /* Update the abbreviation table with missing dimension 08 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_val08,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_qry_date =  par_qry_date
            and not(rda_dim_cod08 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_data = rda_dim_val08)
          group by rda_dim_val08;

      /*-*/
      /* Update the abbreviation table with missing dimension 09 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_val09,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_qry_date =  par_qry_date
            and not(rda_dim_cod09 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_data = rda_dim_val09)
          group by rda_dim_val09;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_abbreviation;

   /*************************************************************/
   /* This procedure performs the retrieve abbreviation routine */
   /*************************************************************/
   function retrieve_abbreviation(par_dim_data in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_abbreviation is
         select nvl(t01.abb_dim_abbr,t01.abb_dim_data) as abb_dim_abbr
           from sms_abbreviation t01
          where t01.abb_dim_data = par_dim_data;
      rcd_abbreviation csr_abbreviation%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the abbreviation
      /*-*/
      var_return := par_dim_data;
      open csr_abbreviation;
      fetch csr_abbreviation into rcd_abbreviation;
      if csr_abbreviation%found then
         var_return := rcd_abbreviation.abb_dim_abbr;
      end if;
      close csr_abbreviation;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_abbreviation;

   /*********************************************************/
   /* This procedure performs the daily maintenance routine */
   /*********************************************************/
   procedure daily_maintenance is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_check_alert varchar2(256);
      var_check_email varchar2(256);
      var_abbrv_email varchar2(256);
      var_purge number;
      var_errors boolean;
      var_warnings boolean;
      var_required boolean;
      var_found boolean;
      var_day_number number;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'SMS Daily Maintenance';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_query is
         select t01.*
           from sms_query t01;
      rcd_query csr_query%rowtype;

      cursor csr_report is
         select t01.*
           from sms_rpt_header t01
          where t01.rhe_qry_code = rcd_query.que_qry_code
            and substr(t01.rhe_qry_date,1,8) = to_char(sysdate,'yyyymmdd');
      rcd_report csr_report%rowtype;

      cursor csr_abbreviation is
         select t01.*
           from sms_abbreviation t01
          where t01.abb_dim_abbr is null
          order by t01.abb_dim_data asc;
      rcd_abbreviation csr_abbreviation%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log variables
      /*-*/
      var_log_prefix := 'SMS - DAILY_MAINTENANCE';
      var_log_search := 'SMS_DAILY_MAINTENANCE';
      var_check_alert := sms_gen_function.retrieve_system_value('QUERY_CHECKER_ALERT');
      var_check_email := sms_gen_function.retrieve_system_value('QUERY_CHECKER_EMAIL_GROUP');
      var_abbrv_email := sms_gen_function.retrieve_system_value('ABBREVIATION_EMAIL_GROUP');
      var_purge := nvl(sms_to_number(sms_gen_function.retrieve_system_value('QUERY_HISTORY_DAYS')),30);
      var_errors := false;
      var_warnings := false;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SMS Daily Maintenance');

      /*-*/
      /* Retrieve the current day number
      /*-*/
      var_day_number := to_number(trim(to_char(sysdate,'D')));

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('#-> Starting query maintenance');

      /*-*/
      /* Retrieve the active queries
      /*-*/
      open csr_query;
      loop
         fetch csr_query into rcd_query;
         if csr_query%notfound then
            exit;
         end if;

         /*-*/
         /* Check query for receipt requirement when active
         /*-*/
         if rcd_query.que_status = '1' then

            /*-*/
            /* Log the event
            /*-*/
            lics_logging.write_log('#---> Checking active query receipt requirement for today - '||rcd_query.que_qry_code);

            /*-*/
            /* Check the query receipt requirement
            /*-*/
            var_required := false;
            if var_day_number = 1 and rcd_query.que_rcv_day01 = '1' then
               var_required := true;
            elsif var_day_number = 2 and rcd_query.que_rcv_day02 = '1' then
               var_required := true;
            elsif var_day_number = 3 and rcd_query.que_rcv_day03 = '1' then
               var_required := true;
            elsif var_day_number = 4 and rcd_query.que_rcv_day04 = '1' then
               var_required := true;
            elsif var_day_number = 5 and rcd_query.que_rcv_day05 = '1' then
               var_required := true;
            elsif var_day_number = 6 and rcd_query.que_rcv_day06 = '1' then
               var_required := true;
            elsif var_day_number = 7 and rcd_query.que_rcv_day07 = '1' then
               var_required := true;
            end if;
            if var_required = true then
               open csr_report;
               fetch csr_report into rcd_report;
               if csr_report%found then
                  lics_logging.write_log('#-----> Query expected and received');
               else
                  lics_logging.write_log('#-----> **WARNING** Query expected and NOT received');
                  var_warnings := true;
               end if;
               close csr_report;
            else
               lics_logging.write_log('#-----> Query not expected');
            end if;

         end if;

         /*-*/
         /* Log the event
         /*-*/
         lics_logging.write_log('#---> Purging all query report history older than '||to_char(var_purge)||' days - '||rcd_query.que_qry_code);

         /*-*/
         /* Purge the query report data
         /*-*/
         delete from sms_rpt_recipient
          where rre_qry_code = rcd_query.que_qry_code
            and rre_qry_date < to_char(trunc(sysdate)-var_purge,'yyyymmddhh24miss');
         delete from sms_rpt_message
          where rme_qry_code = rcd_query.que_qry_code
            and rme_qry_date < to_char(trunc(sysdate)-var_purge,'yyyymmddhh24miss');
         delete from sms_rpt_execution
          where rex_qry_code = rcd_query.que_qry_code
            and rex_qry_date < to_char(trunc(sysdate)-var_purge,'yyyymmddhh24miss');
         delete from sms_rpt_data
          where rda_qry_code = rcd_query.que_qry_code
            and rda_qry_date < to_char(trunc(sysdate)-var_purge,'yyyymmddhh24miss');
         delete from sms_rpt_header
          where rhe_qry_code = rcd_query.que_qry_code
            and rhe_qry_date < to_char(trunc(sysdate)-var_purge,'yyyymmddhh24miss');

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_query;

      /*-*/
      /* Check warnings
      /*-*/
      if var_warnings = true then

         /*-*/
         /* Log the event
         /*-*/
         lics_logging.write_log('#---> Sending query warning');

         /*-*/
         /* Alert and email
         /*-*/
         if not(trim(var_check_alert) is null) and trim(upper(var_check_alert)) != '*NONE' then
            lics_notification.send_alert(var_check_alert);
         end if;
         if not(trim(var_check_email) is null) and trim(upper(var_check_email)) != '*NONE' then
            lics_notification.send_email(sms_parameter.system_code,
                                         sms_parameter.system_unit,
                                         sms_parameter.system_environment,
                                         con_function||' - **WARNING**',
                                         'SMS_DAILY_MAINTENANCE',
                                         var_check_email,
                                         'One or more warnings occurred during the SMS Daily Maintenance execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

      end if;

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('#-> Checking for missing abbreviations');

      /*-*/
      /* Generate the missing abbreviation report when required
      /*-*/
      var_found := false;
      open csr_abbreviation;
      loop
         fetch csr_abbreviation into rcd_abbreviation;
         if csr_abbreviation%notfound then
            exit;
         end if;

         /*-*/
         /* Report data found
         /*-*/
         if var_found = false then

            /*-*/
            /* Set the indicator
            /*-*/
            var_found := true;

            /*-*/
            /* Log the event
            /*-*/
            lics_logging.write_log('#---> Sending missing abbreviations report');

            /*-*/
            /* Create the new email and create the email text header part
            /*-*/
            lics_mailer.create_email('SMS_' || sms_parameter.system_unit || '_' || sms_parameter.system_environment,
                                     var_abbrv_email,
                                     'SMS Reporting - Missing Abbbreviations',
                                     null,
                                     null);
            lics_mailer.create_part(null);
            lics_mailer.append_data('SMS Reporting - Missing Abbbreviations');
            lics_mailer.append_data(null);
            lics_mailer.append_data(null);
            lics_mailer.append_data(null);

            /*-*/
            /* Create the email file and output the header data
            /*-*/
            lics_mailer.create_part('SMS_Missing_Abbreviation.xls');
            lics_mailer.append_data('<head><meta http-equiv=Content-Type content="text/html; charset=utf-8"></head>');
            lics_mailer.append_data('<table border=1 cellpadding="0" cellspacing="0">');
            lics_mailer.append_data('<tr>');
            lics_mailer.append_data('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">SMS Reporting - Missing Abbbreviations Report - '||to_char(sysdate,'yyyy/mm/dd')||'</td>');
            lics_mailer.append_data('</tr>');

            /*-*/
            /* Output the report header
            /*-*/
            lics_mailer.append_data('<tr>');
            lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Dimension Data</td>');
            lics_mailer.append_data('</tr>');

         end if;

         /*-*/
         /* Output the report data
         /*-*/
         lics_mailer.append_data('<tr>');
         lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_abbreviation.abb_dim_data||'</td>');
         lics_mailer.append_data('</tr>');

      end loop;
      close csr_abbreviation;

      /*-*/
      /* Output the email file part trailer data when required
      /*-*/
      if var_found = true then
         lics_mailer.append_data('</table>');
         lics_mailer.create_part(null);
         lics_mailer.append_data(null);
         lics_mailer.append_data(null);
         lics_mailer.append_data(null);
         lics_mailer.append_data('** Email End **');
         lics_mailer.finalise_email('utf-8');
      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SMS Daily Maintenance');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

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
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - DAILY_MAINTENANCE - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end daily_maintenance;

   /**********************************************************/
   /* This procedure performs the period maintenance routine */
   /**********************************************************/
   procedure period_maintenance is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_recpt_email varchar2(256);
      var_purge number;
      var_errors boolean;
      var_warnings boolean;
      var_found boolean;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'SMS Period Maintenance';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_recipient is
         select t01.*,
                decode(t01.rec_status,'0','Inactive','1','Active','*UNKNOWN') as sts_text
           from sms_recipient t01
          order by t01.rec_rcp_code asc;
      rcd_recipient csr_recipient%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log variables
      /*-*/
      var_log_prefix := 'SMS - PERIOD_MAINTENANCE';
      var_log_search := 'SMS_PERIOD_MAINTENANCE';
      var_recpt_email := sms_gen_function.retrieve_system_value('RECIPIENT_EMAIL_GROUP');
      var_errors := false;
      var_warnings := false;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SMS Period Maintenance');

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('#-> Sending recipient audit report');

      /*-*/
      /* Create the new email and create the email text header part
      /*-*/
      lics_mailer.create_email('SMS_' || sms_parameter.system_unit || '_' || sms_parameter.system_environment,
                               var_recpt_email,
                               'SMS Reporting - Recipient Audit',
                               null,
                               null);
      lics_mailer.create_part(null);
      lics_mailer.append_data('SMS Reporting - Recipient Audit');
      lics_mailer.append_data(null);
      lics_mailer.append_data(null);
      lics_mailer.append_data(null);

      /*-*/
      /* Create the email file and output the header data
      /*-*/
      lics_mailer.create_part('SMS_Recipient_Audit.xls');
      lics_mailer.append_data('<head><meta http-equiv=Content-Type content="text/html; charset=utf-8"></head>');
      lics_mailer.append_data('<table border=1 cellpadding="0" cellspacing="0">');
      lics_mailer.append_data('<tr>');
      lics_mailer.append_data('<td align=center colspan=5 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">SMS Reporting - Recipient Audit Report - '||to_char(sysdate,'yyyy/mm/dd')||'</td>');
      lics_mailer.append_data('</tr>');

      /*-*/
      /* Output the report header columns
      /*-*/
      lics_mailer.append_data('<tr>');
      lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Code</td>');
      lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Name</td>');
      lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Mobile</td>');
      lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Email</td>');
      lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Status</td>');
      lics_mailer.append_data('</tr>');

      /*-*/
      /* Generate the recipient audit report
      /*-*/
      open csr_recipient;
      loop
         fetch csr_recipient into rcd_recipient;
         if csr_recipient%notfound then
            exit;
         end if;

         /*-*/
         /* Output the report data
         /*-*/
         lics_mailer.append_data('<tr>');
         lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_recipient.rec_rcp_code||'</td>');
         lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_recipient.rec_rcp_name||'</td>');
         lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_recipient.rec_rcp_mobile||'</td>');
         lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_recipient.rec_rcp_email||'</td>');
         lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_recipient.sts_text||'</td>');
         lics_mailer.append_data('</tr>');

      end loop;
      close csr_recipient;

      /*-*/
      /* Output the email file part trailer data
      /*-*/
      lics_mailer.append_data('</table>');
      lics_mailer.create_part(null);
      lics_mailer.append_data(null);
      lics_mailer.append_data(null);
      lics_mailer.append_data(null);
      lics_mailer.append_data('** Email End **');
      lics_mailer.finalise_email('utf-8');

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SMS Period Maintenance');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

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
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - PERIOD_MAINTENANCE - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end period_maintenance;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package variables
   /*-*/
   ptbl_mesg.delete;
   pvar_end_code := 0;

end sms_gen_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym sms_gen_function for sms_app.sms_gen_function;
grant execute on sms_app.sms_gen_function to public;

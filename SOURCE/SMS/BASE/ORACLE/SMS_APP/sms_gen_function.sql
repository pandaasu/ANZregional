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
   function retrieve_system_value(par_code in varchar2) return varchar2;
   procedure update_abbreviation(par_qry_code in varchar2, par_qry_date in varchar2);
   function retrieve_abbreviation(par_dim_data in varchar2) return varchar2;

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
      /* Pipe the XML data
      /*-*/
      pipe row(sms_xml_object('<?xml version="1.0" encoding="UTF-8"?><SMS_RESPONSE>'));
      if rcd_retrieve.sys_value = '*ACTIVE'then
         pipe row(sms_xml_object('<SYSTEM STATUS="System processing is ACTIVE"/>'));
      end if;
      if rcd_retrieve.sys_value = '*STOPPED'then
         pipe row(sms_xml_object('<SYSTEM STATUS="System processing is STOPPED"/>'));
      end if;
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

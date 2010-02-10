/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_sys_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_smo_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - Shift Model Function

    This package contain the system functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function retrieve_system_values return psa_xml_type pipelined;
   procedure update_system_values(par_user in varchar2);
   function retrieve_system_value(par_code in varchar2) return varchar2;

end psa_sys_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_sys_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

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
           from psa_system t01;
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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_SYS_FUNCTION - RETRIEVE_SYSTEM_VALUES - ' || substr(SQLERRM, 1, 1536));

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_SYS_FUNCTION - UPDATE_SYSTEM_VALUES - ' || substr(SQLERRM, 1, 1536));

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

end psa_sys_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_sys_function for psa_app.psa_sys_function;
grant execute on psa_app.psa_sys_function to public;

/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_map_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_map_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Mapping Function

    This package contain the mapping functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function retrieve_list return pts_xml_type pipelined;
   function retrieve_data return pts_xml_type pipelined;
   procedure update_data(par_user in varchar2);
   function select_question return pts_xml_type pipelined;
   procedure execute_extract;

end pts_map_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_map_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*****************************************************/
   /* This procedure performs the retrieve list routine */
   /*****************************************************/
   function retrieve_list return pts_xml_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.mde_map_code
           from pts_map_definition t01
          order by t01.mde_map_code asc;
      rcd_list csr_list%rowtype;

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
      pts_gen_function.clear_mesg_data;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));
      pipe row(pts_xml_object('<LSTCTL COLCNT="1"/>'));

      /*-*/
      /* Retrieve the mapping list and pipe the results
      /*-*/
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<LSTROW SELCDE="'||pts_to_xml(rcd_list.mde_map_code)||'" SELTXT="'||pts_to_xml(rcd_list.mde_map_code)||'" COL1="'||pts_to_xml(rcd_list.mde_map_code)||'"/>'));
      end loop;
      close csr_list;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(pts_xml_object('</PTS_RESPONSE>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_MAP_FUNCTION - RETRIEVE_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_list;

   /*****************************************************/
   /* This procedure performs the retrieve data routine */
   /*****************************************************/
   function retrieve_data return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_map_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_map_definition t01
          where t01.mde_map_code = var_map_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_question is
         select t01.*,
                nvl(t02.qde_que_text,'*UNKNOWN') as qde_que_text
           from pts_map_question t01,
                pts_que_definition t02
          where t01.mqu_que_code = t02.qde_que_code(+)
            and t01.mqu_map_code = rcd_retrieve.mde_map_code
          order by t01.mqu_que_code;
      rcd_question csr_question%rowtype;

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
      pts_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      var_map_code := xslProcessor.valueOf(obj_pts_request,'@MAPCODE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDMAP' and var_action != '*CRTMAP' and var_action != '*CPYMAP' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing mapping when required
      /*-*/
      if var_action = '*UPDMAP' or var_action = '*CPYMAP' then
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            pts_gen_function.add_mesg_data('Mapping ('||var_map_code||') does not exist');
            return;
         end if;
         close csr_retrieve;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the mapping XML
      /*-*/
      if var_action = '*UPDMAP' then
         var_output := '<MAP MAPCODE="'||pts_to_xml(rcd_retrieve.mde_map_code)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYMAP' then
         var_output := '<MAP MAPCODE="*NEW"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CRTMAP' then
         var_output := '<MAP MAPCODE="*NEW"/>';
         pipe row(pts_xml_object(var_output));
      end if;

      /*-*/
      /* Pipe the question XML when required
      /*-*/
      if var_action != '*CRTMAP' then
         open csr_question;
         loop
            fetch csr_question into rcd_question;
            if csr_question%notfound then
               exit;
             end if;
            pipe row(pts_xml_object('<MAP_QUESTION QUECODE="'||to_char(rcd_question.mqu_que_code)||'" QUETEXT="'||pts_to_xml(rcd_question.qde_que_text)||'"/>'));
         end loop;
         close csr_question;
      end if;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(pts_xml_object('</PTS_RESPONSE>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_MAP_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      obj_pts_request xmlDom.domNode;
      obj_que_list xmlDom.domNodeList;
      obj_que_node xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      rcd_pts_map_definition pts_map_definition%rowtype;
      rcd_pts_map_question pts_map_question%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check is
         select t01.*
           from pts_map_definition t01
          where t01.mde_map_code = rcd_pts_map_definition.mde_map_code;
      rcd_check csr_check%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the message data
      /*-*/
      pts_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      if var_action != '*DEFMAP' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_map_definition.mde_map_code := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@MAPCODE'));
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      obj_que_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/MAP_QUESTION');
      if xmlDom.getLength(obj_que_list) = 0 then
         pts_gen_function.add_mesg_data('At least one question must be supplied');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
     
      /*-*/
      /* Retrieve and process the map definition
      /*-*/
      open csr_check;
      fetch csr_check into rcd_check;
      if csr_check%found then
         var_confirm := 'updated';
         delete from pts_map_question where mqu_map_code = rcd_pts_map_definition.mde_map_code;
      else
         var_confirm := 'created';
         insert into pts_map_definition values rcd_pts_map_definition;
      end if;
      close csr_check;

      /*-*/
      /* Retrieve and insert the map question data
      /*-*/
      rcd_pts_map_question.mqu_map_code := rcd_pts_map_definition.mde_map_code;
      obj_que_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/MAP_QUESTION');
      for idx in 0..xmlDom.getLength(obj_que_list)-1 loop
         obj_que_node := xmlDom.item(obj_que_list,idx);
         rcd_pts_map_question.mqu_que_code := pts_to_number(xslProcessor.valueOf(obj_que_node,'@QUECODE'));
         insert into pts_map_question values rcd_pts_map_question;
      end loop;

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
      pts_gen_function.set_cfrm_data('Mapping ('||to_char(rcd_pts_map_definition.mde_map_code)||') successfully '||var_confirm);

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_MAP_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

   /*******************************************************/
   /* This procedure performs the select question routine */
   /*******************************************************/
   function select_question return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_que_code number;
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_question is
         select t01.*
           from pts_que_definition t01
          where t01.qde_que_code = var_que_code;
      rcd_question csr_question%rowtype;

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
      pts_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      if var_action != '*SELQUE' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_que_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@QUECDE'));
      if var_que_code is null then
         pts_gen_function.add_mesg_data('Question code ('||xslProcessor.valueOf(obj_pts_request,'@QUECDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the question
      /*-*/
      var_found := false;
      open csr_question;
      fetch csr_question into rcd_question;
      if csr_question%found then
         var_found := true;
      end if;
      close csr_question;
      if var_found = false then
         pts_gen_function.add_mesg_data('Question ('||to_char(var_que_code)||') does not exist');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the question xml
      /*-*/
      pipe row(pts_xml_object('<QUESTION QUECDE="'||to_char(rcd_question.qde_que_code)||'" QUETXT="('||to_char(rcd_question.qde_que_code)||') '||pts_to_xml(rcd_question.qde_que_text)||'"/>'));

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(pts_xml_object('</PTS_RESPONSE>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_MAP_FUNCTION - SELECT_QUESTION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_question;

   /*******************************************************/
   /* This procedure performs the execute extract routine */
   /*******************************************************/
   procedure execute_extract is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_locked boolean;
      var_errors boolean;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'PTS Extract';
      con_alt_group constant varchar2(32) := 'PTS_ALERT';
      con_alt_code constant varchar2(32) := 'PTS_EXTRACT';
      con_ema_group constant varchar2(32) := 'PTS_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'PTS_EXTRACT';

      /*-*/
      /* Local cursors
      /*-*/


   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'PTS - EXTRACT';
      var_log_search := 'PTS_EXTRACT';
      var_loc_string := 'PTS_EXTRACT';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;
      var_locked := false;


      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
   --   lics_logging.write_log('Begin - PTS Extract - Parameters(' || upper(par_data) || ' + ' || upper(par_action) || ' + ' || upper(par_str_value) || ' + ' || upper(par_end_value) || ')');

      /*-*/
      /* Request the lock
      /*-*/
      begin
         lics_locking.request(var_loc_string);
         var_locked := true;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log(substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* Execute the requested procedures
      /*-*/
      if var_locked = true then

         /*-*/
         /* Execute the delivery extract procedure when required
         /*-*/
        --    begin
        --       extract_delivery(var_str_date, var_end_date);
        --    exception
        --       when others then
        --          var_errors := true;
        --    end;

         /*-*/
         /* Release the lock
         /*-*/
         lics_locking.release(var_loc_string);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - PTS Extract');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(pts_parameter.system_code,
                                         pts_parameter.system_unit,
                                         pts_parameter.system_environment,
                                         con_function,
                                         'PTS_GLOPAL',
                                         var_email,
                                         'One or more errors occurred during the PTS extract execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;
      end if;

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
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Release the lock
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - PTS_MAP_FUNCTION - EXECUTE_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_extract;

end pts_map_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_map_function for pts_app.pts_map_function;
grant execute on pts_app.pts_map_function to public;

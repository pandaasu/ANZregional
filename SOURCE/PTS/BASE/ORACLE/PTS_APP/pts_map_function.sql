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

   /*-*/
   /* Private declarations
   /*-*/
   procedure extract_customer;

   /*-*/
   /* Private constants
   /*-*/
   con_separator constant varchar2(1) := ',';
   con_missing constant varchar2(4) := 'null';

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
          order by t01.ide_int_code asc;
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
         pipe row(pts_xml_object('<LSTROW SELCDE="'||pts_to_xml(rcd_list.mde_map_code)||'" SELTXT="'||pts_to_xml(rcd_list.mde_map_code)||'" COL2="'||pts_to_xml(rcd_list.rcd_list.mde_map_code)||'"/>'));
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

      cursor csr_geo_zone is
         select t01.*
           from table(pts_app.pts_gen_function.list_geo_zone(rcd_pts_int_definition.ide_geo_type)) t01
          where t01.geo_zone = rcd_pts_int_definition.ide_geo_zone;
      rcd_geo_zone csr_geo_zone%rowtype;

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
      obj_map_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/MAP_QUESTION');
      if xmlDom.getLength(obj_map_list) = 0 then
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
      obj_map_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/MAP_QUESTION');
      for idx in 0..xmlDom.getLength(obj_map_list)-1 loop
         obj_map_node := xmlDom.item(obj_map_list,idx);
         rcd_pts_map_question.mqu_que_code := pts_to_number(xslProcessor.valueOf(obj_map_node,'@QUECODE'));
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
      var_str_period number;
      var_end_period number;
      var_str_date date;
      var_end_date date;

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
      cursor csr_this_period is
         select t01.mars_period
           from mars_date t01
          where trunc(t01.calendar_date) = trunc(sysdate);
      rcd_this_period csr_this_period%rowtype;

      cursor csr_mars_date is
         select min(t01.mars_period) as str_period,
                max(t01.mars_period) as end_period,
                min(t01.calendar_date) as str_date,
                max(t01.calendar_date) as end_date
           from mars_date t01
          where t01.mars_period >= var_str_period
            and t01.mars_period <= var_end_period;
      rcd_mars_date csr_mars_date%rowtype;

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
      /* Validate the data parameter
      /*-*/
      if upper(par_data) != '*ALL' and
         upper(par_data) != '*DELIVERY' and
         upper(par_data) != '*MATERIAL' and
         upper(par_data) != '*CUSTOMER' then
         raise_application_error(-20000, 'Data parameter (' || par_data || ') must be *ALL, *DELIVERY, *MATERIAL or *CUSTOMER');
      end if;

      /*-*/
      /* Validate the delivery parameters when required
      /*-*/
      if upper(par_data) = '*ALL' or upper(par_data) = '*DELIVERY' then
         if upper(par_action) != '*PERIOD_THIS' and
            upper(par_action) != '*PERIOD_LAST' and
            upper(par_action) != '*PERIOD_RANGE' and
            upper(par_action) != '*DATE_RANGE' then
            raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *PERIOD_THIS, *PERIOD_LAST, *PERIOD_RANGE or *DATE_RANGE');
         end if;
      end if;

      /*-*/
      /* Validate the period this when required
      /*-*/
      if upper(par_data) = '*ALL' or upper(par_data) = '*DELIVERY' then
         if upper(par_action) = '*PERIOD_THIS' then
            open csr_this_period;
            fetch csr_this_period into rcd_this_period;
            if csr_this_period%notfound then
               raise_application_error(-20000, 'Start and end period not found in MARS_DATE');
            else
               var_str_period := rcd_this_period.mars_period;
               var_end_period := var_str_period;
            end if;
            close csr_this_period;
            open csr_mars_date;
            fetch csr_mars_date into rcd_mars_date;
            if csr_mars_date%notfound then
               raise_application_error(-20000, 'Start and end period not found in MARS_DATE');
            else
               if rcd_mars_date.str_period is null or rcd_mars_date.str_period != var_str_period then
                  raise_application_error(-20000, 'Start period ' || to_char(par_str_value) || ' not found in MARS_DATE');
               end if;
               if rcd_mars_date.end_period is null or rcd_mars_date.end_period != var_end_period then
                  raise_application_error(-20000, 'End period ' || to_char(par_end_value) || ' not found in MARS_DATE');
               end if;
            end if;
            close csr_mars_date;
            var_str_date := rcd_mars_date.str_date;
            var_end_date := rcd_mars_date.end_date;
         end if;
      end if;

      /*-*/
      /* Validate the period last when required
      /*-*/
      if upper(par_data) = '*ALL' or upper(par_data) = '*DELIVERY' then
         if upper(par_action) = '*PERIOD_LAST' then
            open csr_this_period;
            fetch csr_this_period into rcd_this_period;
            if csr_this_period%notfound then
               raise_application_error(-20000, 'Start and end period not found in MARS_DATE');
            else
               var_str_period := rcd_this_period.mars_period - 1;
               if to_number(substr(to_char(var_str_period,'FM000000'),5,2)) = 0 then
                  var_str_period := var_str_period - 87;
               end if;
               var_end_period := var_str_period;
            end if;
            close csr_this_period;
            open csr_mars_date;
            fetch csr_mars_date into rcd_mars_date;
            if csr_mars_date%notfound then
               raise_application_error(-20000, 'Start and end period not found in MARS_DATE');
            else
               if rcd_mars_date.str_period is null or rcd_mars_date.str_period != var_str_period then
                  raise_application_error(-20000, 'Start period ' || to_char(par_str_value) || ' not found in MARS_DATE');
               end if;
               if rcd_mars_date.end_period is null or rcd_mars_date.end_period != var_end_period then
                  raise_application_error(-20000, 'End period ' || to_char(par_end_value) || ' not found in MARS_DATE');
               end if;
            end if;
            close csr_mars_date;
            var_str_date := rcd_mars_date.str_date;
            var_end_date := rcd_mars_date.end_date;
         end if;
      end if;

      /*-*/
      /* Validate the period range when required
      /*-*/
      if upper(par_data) = '*ALL' or upper(par_data) = '*DELIVERY' then
         if upper(par_action) = '*PERIOD_RANGE' then
            if par_str_value is null then
               raise_application_error(-20000, 'Start period parameter must be supplied for action *PERIOD_RANGE');
            end if;
            if par_end_value is null then
               raise_application_error(-20000, 'End period parameter must be supplied for action *PERIOD_RANGE');
            end if;
            if par_str_value > par_end_value then
               raise_application_error(-20000, 'End period must be greater than or equal to start period for action *PERIOD_RANGE');
            end if;
            begin
               var_str_period := to_number(par_str_value);
            exception
               when others then
                  raise_application_error(-20000, 'Start period parameter (' || par_str_value || ') - unable to convert to number');
            end;
            begin
               var_end_period := to_number(par_end_value);
            exception
               when others then
                  raise_application_error(-20000, 'End period parameter (' || par_end_value || ') - unable to convert to number');
            end;
            open csr_mars_date;
            fetch csr_mars_date into rcd_mars_date;
            if csr_mars_date%notfound then
               raise_application_error(-20000, 'Start and end period not found in MARS_DATE');
            else
               if rcd_mars_date.str_period is null or rcd_mars_date.str_period != var_str_period then
                  raise_application_error(-20000, 'Start period ' || to_char(par_str_value) || ' not found in MARS_DATE');
               end if;
               if rcd_mars_date.end_period is null or rcd_mars_date.end_period != var_end_period then
                  raise_application_error(-20000, 'End period ' || to_char(par_end_value) || ' not found in MARS_DATE');
               end if;
            end if;
            close csr_mars_date;
            var_str_date := rcd_mars_date.str_date;
            var_end_date := rcd_mars_date.end_date;
         end if;
      end if;

      /*-*/
      /* Validate the date range when required
      /*-*/
      if upper(par_data) = '*ALL' or upper(par_data) = '*DELIVERY' then
         if upper(par_action) = '*DATE_RANGE' then
            if par_str_value is null then
               raise_application_error(-20000, 'Start date parameter must be supplied for action *DATE_RANGE');
            end if;
            if par_end_value is null then
               raise_application_error(-20000, 'End date parameter must be supplied for action *DATE_RANGE');
            end if;
            if par_str_value > par_end_value then
               raise_application_error(-20000, 'End date must be greater than or equal to start date for action *DATE_RANGE');
            end if;
            begin
               var_str_date := to_date(par_str_value,'yyyymmdd');
            exception
               when others then
                  raise_application_error(-20000, 'Start date parameter (' || par_str_value || ') - unable to convert to date format YYYYMMDD');
            end;
            begin
               var_end_date := to_date(par_end_value,'yyyymmdd');
            exception
               when others then
                  raise_application_error(-20000, 'End date parameter (' || par_end_value || ') - unable to convert to date format YYYYMMDD');
            end;
          end if;
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - PTS Extract - Parameters(' || upper(par_data) || ' + ' || upper(par_action) || ' + ' || upper(par_str_value) || ' + ' || upper(par_end_value) || ')');

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
         if upper(par_data) = '*ALL' or upper(par_data) = '*DELIVERY' then
            begin
               extract_delivery(var_str_date, var_end_date);
            exception
               when others then
                  var_errors := true;
            end;
         end if;

         /*-*/
         /* Execute the material extract procedure when required
         /*-*/
         if upper(par_data) = '*ALL' or upper(par_data) = '*MATERIAL' then
            begin
               extract_material;
            exception
               when others then
                  var_errors := true;
            end;
         end if;

         /*-*/
         /* Execute the customer extract procedure when required
         /*-*/
         if upper(par_data) = '*ALL' or upper(par_data) = '*CUSTOMER' then
            begin
               extract_customer;
            exception
               when others then
                  var_errors := true;
            end;
         end if;

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
            lics_notification.send_email(lads_parameter.system_code,
                                         lads_parameter.system_unit,
                                         lads_parameter.system_environment,
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
         raise_application_error(-20000, 'FATAL ERROR - PTS_GLO_FUNCTION - EXECUTE_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_extract;

   /********************************************************/
   /* This procedure performs the extract customer routine */
   /********************************************************/
   procedure extract_customer is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_output varchar2(2000);

      type typ_cus_outp is table of varchar2(2000) index by binary_integer;
      tbl_cus_data typ_cus_data;
      tbl_cus_outp typ_cus_outp;
      var_cidx number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_cus_hdr is
         select t01.kunnr as cus_kunnr,
                t01.ktokd as cus_ktokd
           from lads_cus_hdr t01,
          where t01.kunnr = t02.kunnr(+)
            and t01.kunnr = t03.kunnr(+)
            and t03.sap_cust_group_code = t04.sap_cust_group_code(+)
            and t03.sap_channel_code = t05.sap_channel_code(+)
            and t03.sap_banner_code = t06.sap_banner_code(+)
            and t03.sap_loc_type_code = t07.sap_loc_type_code(+)
          order by t01.kunnr;
      rcd_lads_cus_hdr csr_lads_cus_hdr%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - PTS Extract - Extract customer');

      /*-*/
      /* Clear the extract data
      /*-*/
      tbl_cus_data.delete;
      tbl_cus_outp.delete;

      /*-*/
      /* Retrieve the customer rows
      /*-*/
      open csr_lads_cus_hdr;
      loop
         fetch csr_lads_cus_hdr into rcd_lads_cus_hdr;
         if csr_lads_cus_hdr%notfound then
            exit;
         end if;

         /*-*/
         /* Clear the customer data
         /*-*/
         tbl_cus_data.delete;

         /*-*/
         /* Initialise the customer values
         /*-*/
         var_cidx := tbl_cus_data.count + 1;
         tbl_cus_data(var_cidx).customer := rcd_lads_cus_hdr.cus_kunnr;
         tbl_cus_data(var_cidx).name := rcd_lads_cus_hdr.cus_name;
         tbl_cus_data(var_cidx).addr := rcd_lads_cus_hdr.cus_street;
         if not(rcd_lads_cus_hdr.cus_house_no is null) then
            tbl_cus_data(var_cidx).addr := rcd_lads_cus_hdr.cus_house_no || ' ' || rcd_lads_cus_hdr.cus_street;
         end if;
         tbl_cus_data(var_cidx).city := rcd_lads_cus_hdr.cus_city;
         tbl_cus_data(var_cidx).state := rcd_lads_cus_hdr.cus_region;
         tbl_cus_data(var_cidx).pcode := rcd_lads_cus_hdr.cus_pcode;
         tbl_cus_data(var_cidx).route := con_missing;
         tbl_cus_data(var_cidx).rte_desc := con_missing;
         tbl_cus_data(var_cidx).trn_zone := rcd_lads_cus_hdr.cus_transpzone;
         tbl_cus_data(var_cidx).channel := rcd_lads_cus_hdr.chl_desc;
         tbl_cus_data(var_cidx).cus_grp := rcd_lads_cus_hdr.cgp_desc;
         tbl_cus_data(var_cidx).banner := rcd_lads_cus_hdr.ban_desc;
         tbl_cus_data(var_cidx).loc_typ := rcd_lads_cus_hdr.ltp_desc;
         tbl_cus_data(var_cidx).excess_wait := con_missing;
         tbl_cus_data(var_cidx).del_hours := con_missing;
         tbl_cus_data(var_cidx).special_wrap := con_missing;
         tbl_cus_data(var_cidx).single_sku := con_missing;

         /*-*/
         /* Append the customer record
         /*-*/
         var_output := tbl_cus_data(var_cidx).customer || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).name || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).addr || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).city || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).state || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).pcode || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).route || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).rte_desc || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).trn_zone || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).channel || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).cus_grp || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).banner || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).loc_typ || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).excess_wait || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).del_hours || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).special_wrap || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).single_sku;
         tbl_cus_outp(tbl_cus_outp.count + 1) := var_output;

      end loop;
      close csr_lads_cus_hdr;

      /*-*/
      /* Create the customer interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('PTSGPL','xxxxxx.txt');
      for idx in 1..tbl_cus_outp.count loop
         lics_outbound_loader.append_data(tbl_cus_outp(idx));
      end loop;
      lics_outbound_loader.finalise_interface;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - PTS Extract - Extract customer');

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
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**ERROR** - PTS Extract - Extract customer - ' || var_exception);
            lics_logging.write_log('End - PTS Extract - Extract customer');
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_customer;

end pts_map_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_map_function for pts_app.pts_map_function;
grant execute on pts_app.pts_map_function to public;

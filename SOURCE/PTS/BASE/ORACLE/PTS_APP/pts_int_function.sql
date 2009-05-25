/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_int_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_int_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Interviewer Function

    This package contain the interviewer functions and procedures.

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

end pts_int_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_int_function as

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
         select t01.ide_int_code,
                t01.ide_int_name,
                decode(t01.ide_int_status,1,'Active',2,'Inactive','*UNKNOWN') as ide_int_status
           from pts_int_definition t01
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
      pipe row(pts_xml_object('<LSTCTL COLCNT="2"/>'));

      /*-*/
      /* Retrieve the interviewer list and pipe the results
      /*-*/
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.ide_int_code)||'" SELTXT="'||pts_to_xml('('||to_char(rcd_list.ide_int_code)||') '||rcd_list.ide_int_name)||'" COL1="'||pts_to_xml('('||to_char(rcd_list.ide_int_code)||') '||rcd_list.ide_int_name)||'" COL2="'||pts_to_xml(rcd_list.ide_int_status)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_INT_FUNCTION - RETRIEVE_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_int_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_int_definition t01
          where t01.ide_int_code = pts_to_number(var_int_code);
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_geo_zone is
         select t01.*
           from table(pts_app.pts_gen_function.list_geo_zone(30)) t01;
      rcd_geo_zone csr_geo_zone%rowtype;

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
      var_int_code := xslProcessor.valueOf(obj_pts_request,'@INTCODE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDINT' and var_action != '*CRTINT' and var_action != '*CPYINT' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing interviewer when required
      /*-*/
      if var_action = '*UPDINT' or var_action = '*CPYINT' then
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            pts_gen_function.add_mesg_data('Interviewer ('||var_int_code||') does not exist');
            return;
         end if;
         close csr_retrieve;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the status XML
      /*-*/
      pipe row(pts_xml_object('<STA_LIST VALCDE="1" VALTXT="Active"/>'));
      pipe row(pts_xml_object('<STA_LIST VALCDE="2" VALTXT="Inactive"/>'));

      /*-*/
      /* Pipe the geographic zone XML
      /*-*/
      pipe row(pts_xml_object('<GEO_ZONE VALCDE="" VALTXT="** NO GEOGRAPHIC ZONE **"/>'));
      open csr_geo_zone;
      loop
         fetch csr_geo_zone into rcd_geo_zone;
         if csr_geo_zone%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<GEO_ZONE VALCDE="'||to_char(rcd_geo_zone.geo_zone)||'" VALTXT="'||pts_to_xml(rcd_geo_zone.geo_text)||'"/>'));
      end loop;
      close csr_geo_zone;

      /*-*/
      /* Pipe the interviewer XML
      /*-*/
      if var_action = '*UPDINT' then
         var_output := '<INTERVIEWER INTCODE="'||to_char(rcd_retrieve.ide_int_code)||'"';
         var_output := var_output||' INTSTAT="'||to_char(rcd_retrieve.ide_int_status)||'"';
         var_output := var_output||' GEOZONE="'||to_char(rcd_retrieve.ide_geo_zone)||'"';
         var_output := var_output||' INTNAME="'||pts_to_xml(rcd_retrieve.ide_int_name)||'"';
         var_output := var_output||' LOCSTRT="'||pts_to_xml(rcd_retrieve.ide_loc_street)||'"';
         var_output := var_output||' LOCTOWN="'||pts_to_xml(rcd_retrieve.ide_loc_town)||'"';
         var_output := var_output||' LOCPCDE="'||pts_to_xml(rcd_retrieve.ide_loc_postcode)||'"';
         var_output := var_output||' LOCCNTY="'||pts_to_xml(rcd_retrieve.ide_loc_country)||'"';
         var_output := var_output||' TELACDE="'||pts_to_xml(rcd_retrieve.ide_tel_areacode)||'"';
         var_output := var_output||' TELNUMB="'||pts_to_xml(rcd_retrieve.ide_tel_number)||'"/>';

         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYINT' then
         var_output := '<INTERVIEWER INTCODE="*NEW"';
         var_output := var_output||' INTSTAT="'||to_char(rcd_retrieve.ide_int_status)||'"';
         var_output := var_output||' GEOZONE="'||to_char(rcd_retrieve.ide_geo_zone)||'"';
         var_output := var_output||' INTNAME="'||pts_to_xml(rcd_retrieve.ide_int_name)||'"';
         var_output := var_output||' LOCSTRT="'||pts_to_xml(rcd_retrieve.ide_loc_street)||'"';
         var_output := var_output||' LOCTOWN="'||pts_to_xml(rcd_retrieve.ide_loc_town)||'"';
         var_output := var_output||' LOCPCDE="'||pts_to_xml(rcd_retrieve.ide_loc_postcode)||'"';
         var_output := var_output||' LOCCNTY="'||pts_to_xml(rcd_retrieve.ide_loc_country)||'"';
         var_output := var_output||' TELACDE="'||pts_to_xml(rcd_retrieve.ide_tel_areacode)||'"';
         var_output := var_output||' TELNUMB="'||pts_to_xml(rcd_retrieve.ide_tel_number)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CRTINT' then
         var_output := '<INTERVIEWER INTCODE="*NEW"';
         var_output := var_output||' INTSTAT="1"';
         var_output := var_output||' GEOZONE=""';
         var_output := var_output||' INTNAME=""';
         var_output := var_output||' LOCSTRT=""';
         var_output := var_output||' LOCTOWN=""';
         var_output := var_output||' LOCPCDE=""';
         var_output := var_output||' LOCCNTY=""';
         var_output := var_output||' TELACDE=""';
         var_output := var_output||' TELNUMB=""/>';
         pipe row(pts_xml_object(var_output));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_INT_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      var_action varchar2(32);
      var_confirm varchar2(32);
      rcd_pts_int_definition pts_int_definition%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check is
         select t01.*
           from pts_int_definition t01
          where t01.ide_int_code = rcd_pts_int_definition.ide_int_code;
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
      if var_action != '*DEFINT' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_int_definition.ide_int_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@INTCODE'));
      rcd_pts_int_definition.ide_int_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@INTSTAT'));
      rcd_pts_int_definition.ide_upd_user := upper(par_user);
      rcd_pts_int_definition.ide_upd_date := sysdate;
      rcd_pts_int_definition.ide_geo_type := null;
      rcd_pts_int_definition.ide_geo_zone := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@GEOZONE'));
      rcd_pts_int_definition.ide_int_name := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@INTNAME'));
      rcd_pts_int_definition.ide_loc_street := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@LOCSTRT'));
      rcd_pts_int_definition.ide_loc_town := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@LOCTOWN'));
      rcd_pts_int_definition.ide_loc_postcode := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@LOCPCDE'));
      rcd_pts_int_definition.ide_loc_country := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@LOCCNTY'));
      rcd_pts_int_definition.ide_tel_areacode := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@TELACDE'));
      rcd_pts_int_definition.ide_tel_number := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@TELNUMB'));
      if rcd_pts_int_definition.ide_int_code is null and not(xslProcessor.valueOf(obj_pts_request,'@INTCODE') = '*NEW') then
         pts_gen_function.add_mesg_data('Interviewer code ('||xslProcessor.valueOf(obj_pts_request,'@INTCODE')||') must be a number');
      end if;
      if rcd_pts_int_definition.ide_int_status is null and not(xslProcessor.valueOf(obj_pts_request,'@INTSTAT') is null) then
         pts_gen_function.add_mesg_data('Interviewer status ('||xslProcessor.valueOf(obj_pts_request,'@INTSTAT')||') must be a number');
      end if;
      if rcd_pts_int_definition.ide_geo_zone is null and not(xslProcessor.valueOf(obj_pts_request,'@GEOZONE') is null) then
         pts_gen_function.add_mesg_data('Geographic zone ('||xslProcessor.valueOf(obj_pts_request,'@GEOZONE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_int_definition.ide_int_status is null then
         pts_gen_function.add_mesg_data('Interviewer status must be supplied');
      else
         if (rcd_pts_int_definition.ide_int_status != 1 and rcd_pts_int_definition.ide_int_status != 2) then
            pts_gen_function.add_mesg_data('Interviewer status must be 1(Active) or 2(Inactive)');
        end if;
      end if;
      if rcd_pts_int_definition.ide_upd_user is null then
         pts_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if rcd_pts_int_definition.ide_int_name is null then
         pts_gen_function.add_mesg_data('Interviewer name must be supplied');
      end if;
      if not(rcd_pts_int_definition.ide_geo_zone is null) then
         rcd_pts_int_definition.ide_geo_type := 30;
         open csr_geo_zone;
         fetch csr_geo_zone into rcd_geo_zone;
         if csr_geo_zone%notfound then
            pts_gen_function.add_mesg_data('Geographic zone ('||to_char(rcd_pts_int_definition.ide_geo_zone)||') does not exist');
         else
            if rcd_geo_zone.geo_status != 1 then
               pts_gen_function.add_mesg_data('Geographic zone ('||to_char(rcd_pts_int_definition.ide_geo_zone)||') is not active');
            end if;
         end if;
         close csr_geo_zone;
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
     
      /*-*/
      /* Retrieve and process the interviewer definition
      /*-*/
      open csr_check;
      fetch csr_check into rcd_check;
      if csr_check%found then
         var_confirm := 'updated';
         update pts_int_definition
            set ide_int_status = rcd_pts_int_definition.ide_int_status,
                ide_upd_user = rcd_pts_int_definition.ide_upd_user,
                ide_upd_date = rcd_pts_int_definition.ide_upd_date,
                ide_geo_type = rcd_pts_int_definition.ide_geo_type,
                ide_geo_zone = rcd_pts_int_definition.ide_geo_zone,
                ide_int_name = rcd_pts_int_definition.ide_int_name,
                ide_loc_street = rcd_pts_int_definition.ide_loc_street,
                ide_loc_town = rcd_pts_int_definition.ide_loc_town,
                ide_loc_postcode = rcd_pts_int_definition.ide_loc_postcode,
                ide_loc_country = rcd_pts_int_definition.ide_loc_country,
                ide_tel_areacode = rcd_pts_int_definition.ide_tel_areacode,
                ide_tel_number = rcd_pts_int_definition.ide_tel_number
          where ide_int_code = rcd_pts_int_definition.ide_int_code;
      else
         var_confirm := 'created';
         select pts_int_sequence.nextval into rcd_pts_int_definition.ide_int_code from dual;
         insert into pts_int_definition values rcd_pts_int_definition;
      end if;
      close csr_check;

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
      pts_gen_function.set_cfrm_data('Interviewer ('||to_char(rcd_pts_int_definition.ide_int_code)||') successfully '||var_confirm);

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_INT_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

end pts_int_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_int_function for pts_app.pts_int_function;
grant execute on pts_app.pts_int_function to public;

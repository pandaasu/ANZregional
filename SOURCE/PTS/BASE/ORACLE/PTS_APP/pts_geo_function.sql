/******************/
/* Package Header */
/******************/
create or replace
package         pts_geo_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_geo_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Geographic Zone Function

    This package contain the geographic zone functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function retrieve_cnty_list return pts_xml_type pipelined;
   function retrieve_cnty_data return pts_xml_type pipelined;
   procedure update_cnty_data(par_user in varchar2);
   function retrieve_locn_list return pts_xml_type pipelined;
   function retrieve_locn_data return pts_xml_type pipelined;
   procedure update_locn_data(par_user in varchar2);
   function retrieve_dist_list return pts_xml_type pipelined;
   function retrieve_dist_data return pts_xml_type pipelined;
   procedure update_dist_data(par_user in varchar2);
   function retrieve_area_list return pts_xml_type pipelined;
   function retrieve_area_data return pts_xml_type pipelined;
   procedure update_area_data(par_user in varchar2);

end pts_geo_function;
/

/****************/
/* Package Body */
/****************/
create or replace
package body         pts_geo_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   pvar_country constant number := 10;
   pvar_location constant number := 20;
   pvar_district constant number := 30;
   pvar_area constant number := 40;

   /*************************************************************/
   /* This procedure performs the retrieve country list routine */
   /*************************************************************/
   function retrieve_cnty_list return pts_xml_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.gzo_geo_zone,
                t01.gzo_zon_text,
                decode(t01.gzo_zon_status,1,'Active',2,'Inactive','*UNKNOWN') as gzo_zon_status
           from pts_geo_zone t01
          where t01.gzo_geo_type = pvar_country
          order by t01.gzo_geo_zone asc;
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
      pipe row(pts_xml_object('<LSTCTL COLCNT="2" HED1="'||pts_to_xml('Country')||'" HED2="'||pts_to_xml('Country Status')||'"/>'));

      /*-*/
      /* Retrieve the country list and pipe the results
      /*-*/
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.gzo_geo_zone)||'" SELTXT="'||pts_to_xml('('||to_char(rcd_list.gzo_geo_zone)||') '||rcd_list.gzo_zon_text)||'" COL1="'||pts_to_xml('('||to_char(rcd_list.gzo_geo_zone)||') '||rcd_list.gzo_zon_text)||'" COL2="'||pts_to_xml(rcd_list.gzo_zon_status)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEO_FUNCTION - RETRIEVE_CNTY_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_cnty_list;

   /*************************************************************/
   /* This procedure performs the retrieve country data routine */
   /*************************************************************/
   function retrieve_cnty_data return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_geo_zone varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = pvar_country
            and t01.gzo_geo_zone = pts_to_number(var_geo_zone);
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
      var_geo_zone := xslProcessor.valueOf(obj_pts_request,'@GEOZONE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDGEO' and var_action != '*CRTGEO' and var_action != '*CPYGEO' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing country when required
      /*-*/
      if var_action = '*UPDGEO' or var_action = '*CPYGEO' then
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            pts_gen_function.add_mesg_data('Country ('||var_geo_zone||') does not exist');
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
      /* Pipe the country XML
      /*-*/
      if var_action = '*UPDGEO' then
         var_output := '<ZONE GEOZONE="'||to_char(rcd_retrieve.gzo_geo_zone)||'"';
         var_output := var_output||' GEOTEXT="'||pts_to_xml(rcd_retrieve.gzo_zon_text)||'"';
         var_output := var_output||' GEOSTAT="'||to_char(rcd_retrieve.gzo_zon_status)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYGEO' then
         var_output := '<ZONE GEOZONE="*NEW"';
         var_output := var_output||' GEOTEXT="'||pts_to_xml(rcd_retrieve.gzo_zon_text)||'"';
         var_output := var_output||' GEOSTAT="'||to_char(rcd_retrieve.gzo_zon_status)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CRTGEO' then
         var_output := '<ZONE GEOZONE="*NEW"';
         var_output := var_output||' GEOTEXT=""';
         var_output := var_output||' GEOSTAT="1"/>';
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEO_FUNCTION - RETRIEVE_CNTY_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_cnty_data;

   /***********************************************************/
   /* This procedure performs the update country data routine */
   /***********************************************************/
   procedure update_cnty_data(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      rcd_pts_geo_zone pts_geo_zone%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = rcd_pts_geo_zone.gzo_geo_type
            and t01.gzo_geo_zone = rcd_pts_geo_zone.gzo_geo_zone;
      rcd_check csr_check%rowtype;

      cursor csr_child is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_par_type = rcd_pts_geo_zone.gzo_geo_type
            and t01.gzo_par_zone = rcd_pts_geo_zone.gzo_geo_zone
            and t01.gzo_zon_status != 2;
      rcd_child csr_child%rowtype;

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
      if var_action != '*DEFGEO' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_geo_zone.gzo_geo_type := pvar_country;
      rcd_pts_geo_zone.gzo_geo_zone := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@GEOZONE'));
      rcd_pts_geo_zone.gzo_zon_text := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@GEOTEXT'));
      rcd_pts_geo_zone.gzo_zon_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@GEOSTAT'));
      rcd_pts_geo_zone.gzo_upd_user := upper(par_user);
      rcd_pts_geo_zone.gzo_upd_date := sysdate;
      rcd_pts_geo_zone.gzo_par_type := null;
      rcd_pts_geo_zone.gzo_par_zone := null;
      if rcd_pts_geo_zone.gzo_geo_zone is null and not(xslProcessor.valueOf(obj_pts_request,'@GEOZONE') is null) then
         pts_gen_function.add_mesg_data('Country code ('||xslProcessor.valueOf(obj_pts_request,'@GEOZONE')||') must be a number');
      end if;
      if rcd_pts_geo_zone.gzo_zon_status is null and not(xslProcessor.valueOf(obj_pts_request,'@GEOSTAT') is null) then
         pts_gen_function.add_mesg_data('Country status ('||xslProcessor.valueOf(obj_pts_request,'@GEOSTAT')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_geo_zone.gzo_geo_zone is null then
         pts_gen_function.add_mesg_data('Country code must be supplied');
      end if;
      if rcd_pts_geo_zone.gzo_zon_text is null then
         pts_gen_function.add_mesg_data('Country name must be supplied');
      end if;
      if rcd_pts_geo_zone.gzo_zon_status is null then
         pts_gen_function.add_mesg_data('Country status must be supplied');
      else
         if (rcd_pts_geo_zone.gzo_zon_status != 1 and rcd_pts_geo_zone.gzo_zon_status != 2) then
            pts_gen_function.add_mesg_data('Country status must be 1(Active) or 2(Inactive)');
         end if;
         if (rcd_pts_geo_zone.gzo_zon_status = 2) then
            open csr_child;
            fetch csr_child into rcd_child;
            if csr_child%found then
               pts_gen_function.add_mesg_data('Country has active locations - unable to inactivate');
            end if;
            close csr_child;
         end if;
      end if;
      if rcd_pts_geo_zone.gzo_upd_user is null then
         pts_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and process the country definition
      /*-*/
      open csr_check;
      fetch csr_check into rcd_check;
      if csr_check%found then
         var_confirm := 'updated';
         update pts_geo_zone
            set gzo_zon_text = rcd_pts_geo_zone.gzo_zon_text,
                gzo_zon_status = rcd_pts_geo_zone.gzo_zon_status,
                gzo_upd_user = rcd_pts_geo_zone.gzo_upd_user,
                gzo_upd_date = rcd_pts_geo_zone.gzo_upd_date,
                gzo_par_type = rcd_pts_geo_zone.gzo_par_type,
                gzo_par_zone = rcd_pts_geo_zone.gzo_par_zone
          where gzo_geo_type = rcd_pts_geo_zone.gzo_geo_type
            and gzo_geo_zone = rcd_pts_geo_zone.gzo_geo_zone;
      else
         var_confirm := 'created';
         insert into pts_geo_zone values rcd_pts_geo_zone;
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
      pts_gen_function.set_cfrm_data('Country ('||to_char(rcd_pts_geo_zone.gzo_geo_zone)||') successfully '||var_confirm);

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEO_FUNCTION - UPDATE_CNTY_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_cnty_data;

   /**************************************************************/
   /* This procedure performs the retrieve location list routine */
   /**************************************************************/
   function retrieve_locn_list return pts_xml_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select '('||t01.gzo_geo_zone||') '||t01.gzo_zon_text as cnty_text,
                t02.gzo_geo_zone as locn_zone,
                '('||t02.gzo_geo_zone||') '||t02.gzo_zon_text as locn_text,
                decode(t02.gzo_zon_status,1,'Active',2,'Inactive','*UNKNOWN') as locn_status
           from pts_geo_zone t01,
                pts_geo_zone t02
          where t01.gzo_geo_type = t02.gzo_par_type
            and t01.gzo_geo_zone = t02.gzo_par_zone
            and t01.gzo_geo_type = pvar_country
            and t02.gzo_geo_type = pvar_location
          order by t01.gzo_geo_zone asc,
                   t02.gzo_geo_zone asc;
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
      pipe row(pts_xml_object('<LSTCTL COLCNT="3" HED1="'||pts_to_xml('Country')||'" HED2="'||pts_to_xml('Location')||'" HED3="'||pts_to_xml('Location Status')||'"/>'));

      /*-*/
      /* Retrieve the location list and pipe the results
      /*-*/
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.locn_zone)||'" SELTXT="'||pts_to_xml(rcd_list.locn_text)||'" COL1="'||pts_to_xml(rcd_list.cnty_text)||'" COL2="'||pts_to_xml(rcd_list.locn_text)||'" COL3="'||pts_to_xml(rcd_list.locn_status)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEO_FUNCTION - RETRIEVE_LOCN_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_locn_list;

   /**************************************************************/
   /* This procedure performs the retrieve location data routine */
   /**************************************************************/
   function retrieve_locn_data return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_geo_zone varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = pvar_location
            and t01.gzo_geo_zone = pts_to_number(var_geo_zone);
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_parent is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = pvar_country
          order by t01.gzo_geo_zone asc;
      rcd_parent csr_parent%rowtype;

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
      var_geo_zone := xslProcessor.valueOf(obj_pts_request,'@GEOZONE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDGEO' and var_action != '*CRTGEO' and var_action != '*CPYGEO' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing location when required
      /*-*/
      if var_action = '*UPDGEO' or var_action = '*CPYGEO' then
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            pts_gen_function.add_mesg_data('Location ('||var_geo_zone||') does not exist');
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
      /* Pipe the country XML
      /*-*/
      open csr_parent;
      loop
         fetch csr_parent into rcd_parent;
         if csr_parent%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<PAR_LIST VALCDE="'||to_char(rcd_parent.gzo_geo_zone)||'" VALTXT="'||pts_to_xml('('||to_char(rcd_parent.gzo_geo_zone)||') '||rcd_parent.gzo_zon_text)||'"/>'));
      end loop;
      close csr_parent;

      /*-*/
      /* Pipe the location XML
      /*-*/
      if var_action = '*UPDGEO' then
         var_output := '<ZONE GEOZONE="'||to_char(rcd_retrieve.gzo_geo_zone)||'"';
         var_output := var_output||' GEOTEXT="'||pts_to_xml(rcd_retrieve.gzo_zon_text)||'"';
         var_output := var_output||' GEOSTAT="'||to_char(rcd_retrieve.gzo_zon_status)||'"';
         var_output := var_output||' PARZONE="'||to_char(rcd_retrieve.gzo_par_zone)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYGEO' then
         var_output := '<ZONE GEOZONE="*NEW"';
         var_output := var_output||' GEOTEXT="'||pts_to_xml(rcd_retrieve.gzo_zon_text)||'"';
         var_output := var_output||' GEOSTAT="'||to_char(rcd_retrieve.gzo_zon_status)||'"';
         var_output := var_output||' PARZONE="'||to_char(rcd_retrieve.gzo_par_zone)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CRTGEO' then
         var_output := '<ZONE GEOZONE="*NEW"';
         var_output := var_output||' GEOTEXT=""';
         var_output := var_output||' GEOSTAT="1"';
         var_output := var_output||' PARZONE=""/>';
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEO_FUNCTION - RETRIEVE_LOCN_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_locn_data;

   /************************************************************/
   /* This procedure performs the update location data routine */
   /************************************************************/
   procedure update_locn_data(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      rcd_pts_geo_zone pts_geo_zone%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = rcd_pts_geo_zone.gzo_geo_type
            and t01.gzo_geo_zone = rcd_pts_geo_zone.gzo_geo_zone;
      rcd_check csr_check%rowtype;

      cursor csr_parent is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = rcd_pts_geo_zone.gzo_par_type
            and t01.gzo_geo_zone = rcd_pts_geo_zone.gzo_par_zone;
      rcd_parent csr_parent%rowtype;

      cursor csr_child is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_par_type = rcd_pts_geo_zone.gzo_geo_type
            and t01.gzo_par_zone = rcd_pts_geo_zone.gzo_geo_zone
            and t01.gzo_zon_status != 2;
      rcd_child csr_child%rowtype;

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
      if var_action != '*DEFGEO' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_geo_zone.gzo_geo_type := pvar_location;
      rcd_pts_geo_zone.gzo_geo_zone := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@GEOZONE'));
      rcd_pts_geo_zone.gzo_zon_text := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@GEOTEXT'));
      rcd_pts_geo_zone.gzo_zon_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@GEOSTAT'));
      rcd_pts_geo_zone.gzo_upd_user := upper(par_user);
      rcd_pts_geo_zone.gzo_upd_date := sysdate;
      rcd_pts_geo_zone.gzo_par_type := pvar_country;
      rcd_pts_geo_zone.gzo_par_zone := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PARZONE'));
      if rcd_pts_geo_zone.gzo_geo_zone is null and not(xslProcessor.valueOf(obj_pts_request,'@GEOZONE') is null) then
         pts_gen_function.add_mesg_data('Location code ('||xslProcessor.valueOf(obj_pts_request,'@GEOZONE')||') must be a number');
      end if;
      if rcd_pts_geo_zone.gzo_zon_status is null and not(xslProcessor.valueOf(obj_pts_request,'@GEOSTAT') is null) then
         pts_gen_function.add_mesg_data('Location status ('||xslProcessor.valueOf(obj_pts_request,'@GEOSTAT')||') must be a number');
      end if;
      if rcd_pts_geo_zone.gzo_par_zone is null and not(xslProcessor.valueOf(obj_pts_request,'@PARZONE') is null) then
         pts_gen_function.add_mesg_data('Country code ('||xslProcessor.valueOf(obj_pts_request,'@PARZONE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_geo_zone.gzo_geo_zone is null then
         pts_gen_function.add_mesg_data('Location code must be supplied');
      end if;
      if rcd_pts_geo_zone.gzo_zon_text is null then
         pts_gen_function.add_mesg_data('Location name must be supplied');
      end if;
      if rcd_pts_geo_zone.gzo_zon_status is null then
         pts_gen_function.add_mesg_data('Location status must be supplied');
      else
         if (rcd_pts_geo_zone.gzo_zon_status != 1 and rcd_pts_geo_zone.gzo_zon_status != 2) then
            pts_gen_function.add_mesg_data('Location status must be 1(Active) or 2(Inactive)');
         end if;
         if (rcd_pts_geo_zone.gzo_zon_status = 2) then
            open csr_child;
            fetch csr_child into rcd_child;
            if csr_child%found then
               pts_gen_function.add_mesg_data('Location has active districts - unable to inactivate');
            end if;
            close csr_child;
         end if;
      end if;
      open csr_parent;
      fetch csr_parent into rcd_parent;
      if csr_parent%notfound then
          pts_gen_function.add_mesg_data('Country ('||to_char(rcd_pts_geo_zone.gzo_par_zone)||') does not exist');
      else
         if rcd_parent.gzo_zon_status = 2 and rcd_pts_geo_zone.gzo_zon_status != 2 then
            pts_gen_function.add_mesg_data('Country is inactive so location must be inactive');
         end if;
      end if;
      close csr_parent;
      if rcd_pts_geo_zone.gzo_upd_user is null then
         pts_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and process the location definition
      /*-*/
      open csr_check;
      fetch csr_check into rcd_check;
      if csr_check%found then
         var_confirm := 'updated';
         update pts_geo_zone
            set gzo_zon_text = rcd_pts_geo_zone.gzo_zon_text,
                gzo_zon_status = rcd_pts_geo_zone.gzo_zon_status,
                gzo_upd_user = rcd_pts_geo_zone.gzo_upd_user,
                gzo_upd_date = rcd_pts_geo_zone.gzo_upd_date,
                gzo_par_type = rcd_pts_geo_zone.gzo_par_type,
                gzo_par_zone = rcd_pts_geo_zone.gzo_par_zone
          where gzo_geo_type = rcd_pts_geo_zone.gzo_geo_type
            and gzo_geo_zone = rcd_pts_geo_zone.gzo_geo_zone;
      else
         var_confirm := 'created';
         insert into pts_geo_zone values rcd_pts_geo_zone;
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
      pts_gen_function.set_cfrm_data('Location ('||to_char(rcd_pts_geo_zone.gzo_geo_zone)||') successfully '||var_confirm);

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEO_FUNCTION - UPDATE_LOCN_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_locn_data;

   /**************************************************************/
   /* This procedure performs the retrieve district list routine */
   /**************************************************************/
   function retrieve_dist_list return pts_xml_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select '('||t01.gzo_geo_zone||') '||t01.gzo_zon_text as cnty_text,
                '('||t02.gzo_geo_zone||') '||t02.gzo_zon_text as locn_text,
                t03.gzo_geo_zone as dist_zone,
                '('||t03.gzo_geo_zone||') '||t03.gzo_zon_text as dist_text,
                decode(t03.gzo_zon_status,1,'Active',2,'Inactive','*UNKNOWN') as dist_status
           from pts_geo_zone t01,
                pts_geo_zone t02,
                pts_geo_zone t03
          where t01.gzo_geo_type = t02.gzo_par_type
            and t01.gzo_geo_zone = t02.gzo_par_zone
            and t02.gzo_geo_type = t03.gzo_par_type
            and t02.gzo_geo_zone = t03.gzo_par_zone
            and t01.gzo_geo_type = pvar_country
            and t02.gzo_geo_type = pvar_location
            and t03.gzo_geo_type = pvar_district
          order by t01.gzo_geo_zone asc,
                   t02.gzo_geo_zone asc,
                   t03.gzo_geo_zone asc;
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
      pipe row(pts_xml_object('<LSTCTL COLCNT="4" HED1="'||pts_to_xml('Country')||'" HED2="'||pts_to_xml('Location')||'" HED3="'||pts_to_xml('District')||'" HED4="'||pts_to_xml('District Status')||'"/>'));

      /*-*/
      /* Retrieve the district list and pipe the results
      /*-*/
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.dist_zone)||'" SELTXT="'||pts_to_xml(rcd_list.dist_text)||'" COL1="'||pts_to_xml(rcd_list.cnty_text)||'" COL2="'||pts_to_xml(rcd_list.locn_text)||'" COL3="'||pts_to_xml(rcd_list.dist_text)||'" COL4="'||pts_to_xml(rcd_list.dist_status)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEO_FUNCTION - RETRIEVE_DIST_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_dist_list;

   /**************************************************************/
   /* This procedure performs the retrieve district data routine */
   /**************************************************************/
   function retrieve_dist_data return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_geo_zone varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = pvar_district
            and t01.gzo_geo_zone = pts_to_number(var_geo_zone);
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_parent is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = pvar_location
          order by t01.gzo_geo_zone asc;
      rcd_parent csr_parent%rowtype;

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
      var_geo_zone := xslProcessor.valueOf(obj_pts_request,'@GEOZONE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDGEO' and var_action != '*CRTGEO' and var_action != '*CPYGEO' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing district when required
      /*-*/
      if var_action = '*UPDGEO' or var_action = '*CPYGEO' then
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            pts_gen_function.add_mesg_data('District ('||var_geo_zone||') does not exist');
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
      /* Pipe the location XML
      /*-*/
      open csr_parent;
      loop
         fetch csr_parent into rcd_parent;
         if csr_parent%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<PAR_LIST VALCDE="'||to_char(rcd_parent.gzo_geo_zone)||'" VALTXT="'||pts_to_xml('('||to_char(rcd_parent.gzo_geo_zone)||') '||rcd_parent.gzo_zon_text)||'"/>'));
      end loop;
      close csr_parent;

      /*-*/
      /* Pipe the district XML
      /*-*/
      if var_action = '*UPDGEO' then
         var_output := '<ZONE GEOZONE="'||to_char(rcd_retrieve.gzo_geo_zone)||'"';
         var_output := var_output||' GEOTEXT="'||pts_to_xml(rcd_retrieve.gzo_zon_text)||'"';
         var_output := var_output||' GEOSTAT="'||to_char(rcd_retrieve.gzo_zon_status)||'"';
         var_output := var_output||' PARZONE="'||to_char(rcd_retrieve.gzo_par_zone)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYGEO' then
         var_output := '<ZONE GEOZONE="*NEW"';
         var_output := var_output||' GEOTEXT="'||pts_to_xml(rcd_retrieve.gzo_zon_text)||'"';
         var_output := var_output||' GEOSTAT="'||to_char(rcd_retrieve.gzo_zon_status)||'"';
         var_output := var_output||' PARZONE="'||to_char(rcd_retrieve.gzo_par_zone)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CRTGEO' then
         var_output := '<ZONE GEOZONE="*NEW"';
         var_output := var_output||' GEOTEXT=""';
         var_output := var_output||' GEOSTAT="1"';
         var_output := var_output||' PARZONE=""/>';
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEO_FUNCTION - RETRIEVE_DIST_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_dist_data;

   /************************************************************/
   /* This procedure performs the update district data routine */
   /************************************************************/
   procedure update_dist_data(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      rcd_pts_geo_zone pts_geo_zone%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = rcd_pts_geo_zone.gzo_geo_type
            and t01.gzo_geo_zone = rcd_pts_geo_zone.gzo_geo_zone;
      rcd_check csr_check%rowtype;

      cursor csr_parent is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = rcd_pts_geo_zone.gzo_par_type
            and t01.gzo_geo_zone = rcd_pts_geo_zone.gzo_par_zone;
      rcd_parent csr_parent%rowtype;

      cursor csr_child is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_par_type = rcd_pts_geo_zone.gzo_geo_type
            and t01.gzo_par_zone = rcd_pts_geo_zone.gzo_geo_zone
            and t01.gzo_zon_status != 2;
      rcd_child csr_child%rowtype;

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
      if var_action != '*DEFGEO' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_geo_zone.gzo_geo_type := pvar_district;
      rcd_pts_geo_zone.gzo_geo_zone := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@GEOZONE'));
      rcd_pts_geo_zone.gzo_zon_text := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@GEOTEXT'));
      rcd_pts_geo_zone.gzo_zon_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@GEOSTAT'));
      rcd_pts_geo_zone.gzo_upd_user := upper(par_user);
      rcd_pts_geo_zone.gzo_upd_date := sysdate;
      rcd_pts_geo_zone.gzo_par_type := pvar_location;
      rcd_pts_geo_zone.gzo_par_zone := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PARZONE'));
      if rcd_pts_geo_zone.gzo_geo_zone is null and not(xslProcessor.valueOf(obj_pts_request,'@GEOZONE') is null) then
         pts_gen_function.add_mesg_data('District code ('||xslProcessor.valueOf(obj_pts_request,'@GEOZONE')||') must be a number');
      end if;
      if rcd_pts_geo_zone.gzo_zon_status is null and not(xslProcessor.valueOf(obj_pts_request,'@GEOSTAT') is null) then
         pts_gen_function.add_mesg_data('District status ('||xslProcessor.valueOf(obj_pts_request,'@GEOSTAT')||') must be a number');
      end if;
      if rcd_pts_geo_zone.gzo_par_zone is null and not(xslProcessor.valueOf(obj_pts_request,'@PARZONE') is null) then
         pts_gen_function.add_mesg_data('Location code ('||xslProcessor.valueOf(obj_pts_request,'@PARZONE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_geo_zone.gzo_geo_zone is null then
         pts_gen_function.add_mesg_data('District code must be supplied');
      end if;
      if rcd_pts_geo_zone.gzo_zon_text is null then
         pts_gen_function.add_mesg_data('District name must be supplied');
      end if;
      if rcd_pts_geo_zone.gzo_zon_status is null then
         pts_gen_function.add_mesg_data('District status must be supplied');
      else
         if (rcd_pts_geo_zone.gzo_zon_status != 1 and rcd_pts_geo_zone.gzo_zon_status != 2) then
            pts_gen_function.add_mesg_data('District status must be 1(Active) or 2(Inactive)');
         end if;
         if (rcd_pts_geo_zone.gzo_zon_status = 2) then
            open csr_child;
            fetch csr_child into rcd_child;
            if csr_child%found then
               pts_gen_function.add_mesg_data('District has active areas - unable to inactivate');
            end if;
            close csr_child;
         end if;
      end if;
      open csr_parent;
      fetch csr_parent into rcd_parent;
      if csr_parent%notfound then
          pts_gen_function.add_mesg_data('Location ('||to_char(rcd_pts_geo_zone.gzo_par_zone)||') does not exist');
      else
         if rcd_parent.gzo_zon_status = 2 and rcd_pts_geo_zone.gzo_zon_status != 2 then
            pts_gen_function.add_mesg_data('Location is inactive so district must be inactive');
         end if;
      end if;
      close csr_parent;
      if rcd_pts_geo_zone.gzo_upd_user is null then
         pts_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and process the district definition
      /*-*/
      open csr_check;
      fetch csr_check into rcd_check;
      if csr_check%found then
         var_confirm := 'updated';
         update pts_geo_zone
            set gzo_zon_text = rcd_pts_geo_zone.gzo_zon_text,
                gzo_zon_status = rcd_pts_geo_zone.gzo_zon_status,
                gzo_upd_user = rcd_pts_geo_zone.gzo_upd_user,
                gzo_upd_date = rcd_pts_geo_zone.gzo_upd_date,
                gzo_par_type = rcd_pts_geo_zone.gzo_par_type,
                gzo_par_zone = rcd_pts_geo_zone.gzo_par_zone
          where gzo_geo_type = rcd_pts_geo_zone.gzo_geo_type
            and gzo_geo_zone = rcd_pts_geo_zone.gzo_geo_zone;
      else
         var_confirm := 'created';
         insert into pts_geo_zone values rcd_pts_geo_zone;
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
      pts_gen_function.set_cfrm_data('District ('||to_char(rcd_pts_geo_zone.gzo_geo_zone)||') successfully '||var_confirm);

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEO_FUNCTION - UPDATE_DIST_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_dist_data;

   /**********************************************************/
   /* This procedure performs the retrieve area list routine */
   /**********************************************************/
   function retrieve_area_list return pts_xml_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select '('||t01.gzo_geo_zone||') '||t01.gzo_zon_text as cnty_text,
                '('||t02.gzo_geo_zone||') '||t02.gzo_zon_text as locn_text,
                '('||t03.gzo_geo_zone||') '||t03.gzo_zon_text as dist_text,
                t04.gzo_geo_zone as area_zone,
                '('||t04.gzo_geo_zone||') '||t04.gzo_zon_text as area_text,
                decode(t04.gzo_zon_status,1,'Active',2,'Inactive','*UNKNOWN') as area_status
           from pts_geo_zone t01,
                pts_geo_zone t02,
                pts_geo_zone t03,
                pts_geo_zone t04
          where t01.gzo_geo_type = t02.gzo_par_type
            and t01.gzo_geo_zone = t02.gzo_par_zone
            and t02.gzo_geo_type = t03.gzo_par_type
            and t02.gzo_geo_zone = t03.gzo_par_zone
            and t03.gzo_geo_type = t04.gzo_par_type
            and t03.gzo_geo_zone = t04.gzo_par_zone
            and t01.gzo_geo_type = pvar_country
            and t02.gzo_geo_type = pvar_location
            and t03.gzo_geo_type = pvar_district
            and t04.gzo_geo_type = pvar_area
          order by t01.gzo_geo_zone asc,
                   t02.gzo_geo_zone asc,
                   t03.gzo_geo_zone asc,
                   t04.gzo_geo_zone asc;
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
      pipe row(pts_xml_object('<LSTCTL COLCNT="5" HED1="'||pts_to_xml('Country')||'" HED2="'||pts_to_xml('Location')||'" HED3="'||pts_to_xml('District')||'" HED4="'||pts_to_xml('Area')||'" HED5="'||pts_to_xml('Area Status')||'"/>'));

      /*-*/
      /* Retrieve the area list and pipe the results
      /*-*/
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
          pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.area_zone)||'" SELTXT="'||pts_to_xml(rcd_list.area_text)||'" COL1="'||pts_to_xml(rcd_list.cnty_text)||'" COL2="'||pts_to_xml(rcd_list.locn_text)||'" COL3="'||pts_to_xml(rcd_list.dist_text)||'" COL4="'||pts_to_xml(rcd_list.area_text)||'" COL5="'||pts_to_xml(rcd_list.area_status)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEO_FUNCTION - RETRIEVE_AREA_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_area_list;

   /**********************************************************/
   /* This procedure performs the retrieve area data routine */
   /**********************************************************/
   function retrieve_area_data return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_geo_zone varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = pvar_area
            and t01.gzo_geo_zone = pts_to_number(var_geo_zone);
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_parent is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = pvar_district
          order by t01.gzo_geo_zone asc;
      rcd_parent csr_parent%rowtype;

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
      var_geo_zone := xslProcessor.valueOf(obj_pts_request,'@GEOZONE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDGEO' and var_action != '*CRTGEO' and var_action != '*CPYGEO' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing area when required
      /*-*/
      if var_action = '*UPDGEO' or var_action = '*CPYGEO' then
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            pts_gen_function.add_mesg_data('Area ('||var_geo_zone||') does not exist');
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
      /* Pipe the district XML
      /*-*/
      open csr_parent;
      loop
         fetch csr_parent into rcd_parent;
         if csr_parent%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<PAR_LIST VALCDE="'||to_char(rcd_parent.gzo_geo_zone)||'" VALTXT="'||pts_to_xml('('||to_char(rcd_parent.gzo_geo_zone)||') '||rcd_parent.gzo_zon_text)||'"/>'));
      end loop;
      close csr_parent;

      /*-*/
      /* Pipe the area XML
      /*-*/
      if var_action = '*UPDGEO' then
         var_output := '<ZONE GEOZONE="'||to_char(rcd_retrieve.gzo_geo_zone)||'"';
         var_output := var_output||' GEOTEXT="'||pts_to_xml(rcd_retrieve.gzo_zon_text)||'"';
         var_output := var_output||' GEOSTAT="'||to_char(rcd_retrieve.gzo_zon_status)||'"';
         var_output := var_output||' PARZONE="'||to_char(rcd_retrieve.gzo_par_zone)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYGEO' then
         var_output := '<ZONE GEOZONE="*NEW"';
         var_output := var_output||' GEOTEXT="'||pts_to_xml(rcd_retrieve.gzo_zon_text)||'"';
         var_output := var_output||' GEOSTAT="'||to_char(rcd_retrieve.gzo_zon_status)||'"';
         var_output := var_output||' PARZONE="'||to_char(rcd_retrieve.gzo_par_zone)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CRTGEO' then
         var_output := '<ZONE GEOZONE="*NEW"';
         var_output := var_output||' GEOTEXT=""';
         var_output := var_output||' GEOSTAT="1"';
         var_output := var_output||' PARZONE=""/>';
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEO_FUNCTION - RETRIEVE_AREA_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_area_data;

   /********************************************************/
   /* This procedure performs the update area data routine */
   /********************************************************/
   procedure update_area_data(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      rcd_pts_geo_zone pts_geo_zone%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = rcd_pts_geo_zone.gzo_geo_type
            and t01.gzo_geo_zone = rcd_pts_geo_zone.gzo_geo_zone;
      rcd_check csr_check%rowtype;

      cursor csr_parent is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = rcd_pts_geo_zone.gzo_par_type
            and t01.gzo_geo_zone = rcd_pts_geo_zone.gzo_par_zone;
      rcd_parent csr_parent%rowtype;

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
      if var_action != '*DEFGEO' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_geo_zone.gzo_geo_type := pvar_area;
      rcd_pts_geo_zone.gzo_geo_zone := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@GEOZONE'));
      rcd_pts_geo_zone.gzo_zon_text := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@GEOTEXT'));
      rcd_pts_geo_zone.gzo_zon_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@GEOSTAT'));
      rcd_pts_geo_zone.gzo_upd_user := upper(par_user);
      rcd_pts_geo_zone.gzo_upd_date := sysdate;
      rcd_pts_geo_zone.gzo_par_type := pvar_district;
      rcd_pts_geo_zone.gzo_par_zone := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PARZONE'));
      if rcd_pts_geo_zone.gzo_geo_zone is null and not(xslProcessor.valueOf(obj_pts_request,'@GEOZONE') is null) then
         pts_gen_function.add_mesg_data('Area code ('||xslProcessor.valueOf(obj_pts_request,'@GEOZONE')||') must be a number');
      end if;
      if rcd_pts_geo_zone.gzo_zon_status is null and not(xslProcessor.valueOf(obj_pts_request,'@GEOSTAT') is null) then
         pts_gen_function.add_mesg_data('Area status ('||xslProcessor.valueOf(obj_pts_request,'@GEOSTAT')||') must be a number');
      end if;
      if rcd_pts_geo_zone.gzo_par_zone is null and not(xslProcessor.valueOf(obj_pts_request,'@PARZONE') is null) then
         pts_gen_function.add_mesg_data('District code ('||xslProcessor.valueOf(obj_pts_request,'@PARZONE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_geo_zone.gzo_geo_zone is null then
         pts_gen_function.add_mesg_data('Area code must be supplied');
      end if;
      if rcd_pts_geo_zone.gzo_zon_text is null then
         pts_gen_function.add_mesg_data('Area name must be supplied');
      end if;
      if rcd_pts_geo_zone.gzo_zon_status is null then
         pts_gen_function.add_mesg_data('Area status must be supplied');
      else
         if (rcd_pts_geo_zone.gzo_zon_status != 1 and rcd_pts_geo_zone.gzo_zon_status != 2) then
            pts_gen_function.add_mesg_data('Area status must be 1(Active) or 2(Inactive)');
         end if;
      end if;
      open csr_parent;
      fetch csr_parent into rcd_parent;
      if csr_parent%notfound then
          pts_gen_function.add_mesg_data('District ('||to_char(rcd_pts_geo_zone.gzo_par_zone)||') does not exist');
      else
         if rcd_parent.gzo_zon_status = 2 and rcd_pts_geo_zone.gzo_zon_status != 2 then
            pts_gen_function.add_mesg_data('District is inactive so area must be inactive');
         end if;
      end if;
      close csr_parent;
      if rcd_pts_geo_zone.gzo_upd_user is null then
         pts_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and process the area definition
      /*-*/
      open csr_check;
      fetch csr_check into rcd_check;
      if csr_check%found then
         var_confirm := 'updated';
         update pts_geo_zone
            set gzo_zon_text = rcd_pts_geo_zone.gzo_zon_text,
                gzo_zon_status = rcd_pts_geo_zone.gzo_zon_status,
                gzo_upd_user = rcd_pts_geo_zone.gzo_upd_user,
                gzo_upd_date = rcd_pts_geo_zone.gzo_upd_date,
                gzo_par_type = rcd_pts_geo_zone.gzo_par_type,
                gzo_par_zone = rcd_pts_geo_zone.gzo_par_zone
          where gzo_geo_type = rcd_pts_geo_zone.gzo_geo_type
            and gzo_geo_zone = rcd_pts_geo_zone.gzo_geo_zone;
      else
         var_confirm := 'created';
         insert into pts_geo_zone values rcd_pts_geo_zone;
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
      pts_gen_function.set_cfrm_data('Area ('||to_char(rcd_pts_geo_zone.gzo_geo_zone)||') successfully '||var_confirm);

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_GEO_FUNCTION - UPDATE_AREA_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_area_data;

end pts_geo_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_geo_function for pts_app.pts_geo_function;
grant execute on pts_app.pts_geo_function to public;

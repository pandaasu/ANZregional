/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_hou_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_hou_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Household functions

    This package contain the household functions and procedures.

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
   function get_class_code(par_hou_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_code_type pipelined;
   function get_class_number(par_hou_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_numb_type pipelined;
   function get_class_text(par_hou_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_text_type pipelined;

end pts_hou_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_hou_function as

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
      /* Local definitions
      /*-*/
      var_pag_size number;
      var_row_count number;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.hde_hou_code,
                t01.hde_con_fullname,
                nvl((select sva_val_text from pts_sys_value where sva_tab_code = '*HOU_DEF' and sva_fld_code = 13 and sva_val_code = t01.hde_hou_status),'*UNKNOWN') as hde_hou_status
           from pts_hou_definition t01
          where t01.hde_hou_code in (select sel_code from table(pts_app.pts_gen_function.get_list_data('*HOUSEHOLD',null)))
            and t01.hde_hou_code > (select sel_code from table(pts_app.pts_gen_function.get_list_from))
          order by t01.hde_hou_code asc;
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
      /* Retrieve the household list and pipe the results
      /*-*/
      var_pag_size := 20;
      var_row_count := 0;
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_row_count := var_row_count + 1;
         if var_row_count <= var_pag_size then
            pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.hde_hou_code)||'" SELTXT="'||pts_to_xml('('||to_char(rcd_list.hde_hou_code)||') '||rcd_list.hde_con_fullname)||'" COL1="'||pts_to_xml('('||to_char(rcd_list.hde_hou_code)||') '||rcd_list.hde_con_fullname)||'" COL2="'||pts_to_xml(rcd_list.hde_hou_status)||'"/>'));
         else
            exit;
         end if;
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_HOU_FUNCTION - RETRIEVE_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_hou_code varchar2(32);
      var_tab_flag boolean;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_hou_definition t01
          where t01.hde_hou_code = pts_to_number(var_hou_code);
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*HOU_DEF',13)) t01;
      rcd_sta_code csr_sta_code%rowtype;

      cursor csr_geo_zone is
         select t01.*
           from table(pts_app.pts_gen_function.list_geo_zone(40)) t01
          where t01.geo_status = 1;
      rcd_geo_zone csr_geo_zone%rowtype;

      cursor csr_del_note is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*HOU_DEF',14)) t01;
      rcd_del_note csr_del_note%rowtype;

      cursor csr_table is
         select t01.sta_tab_code,
                t01.sta_tab_text
           from pts_sys_table t01
          where t01.sta_tab_code in ('*HOU_CLA','*HOU_SAM')
          order by t01.sta_tab_text asc;
      rcd_table csr_table%rowtype;

      cursor csr_field is
         select t01.sfi_fld_code,
                t01.sfi_fld_text
           from pts_sys_field t01
          where t01.sfi_tab_code = rcd_table.sta_tab_code
            and t01.sfi_fld_status = '1'
          order by t01.sfi_fld_text asc;
      rcd_field csr_field%rowtype;

      cursor csr_classification is
         select t01.hcl_val_code,
                t01.hcl_val_text
           from pts_hou_classification t01
          where t01.hcl_hou_code = pts_to_number(var_hou_code)
            and t01.hcl_tab_code = rcd_table.sta_tab_code
            and t01.hcl_fld_code = rcd_field.sfi_fld_code
          order by t01.hcl_val_code asc;
      rcd_classification csr_classification%rowtype;

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
      var_hou_code := xslProcessor.valueOf(obj_pts_request,'@HOUCODE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDHOU' and var_action != '*CRTHOU' and var_action != '*CPYHOU' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing household when required
      /*-*/
      if var_action = '*UPDHOU' or var_action = '*CPYHOU' then
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            pts_gen_function.add_mesg_data('Household ('||var_hou_code||') does not exist');
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
      open csr_sta_code;
      loop
         fetch csr_sta_code into rcd_sta_code;
         if csr_sta_code%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<STA_LIST VALCDE="'||to_char(rcd_sta_code.val_code)||'" VALTXT="'||pts_to_xml(rcd_sta_code.val_text)||'"/>'));
      end loop;
      close csr_sta_code;

      /*-*/
      /* Pipe the geographic zone XML
      /*-*/
      pipe row(pts_xml_object('<GEO_LIST VALCDE="" VALTXT="** NO GEOGRAPHIC ZONE **"/>'));
      open csr_geo_zone;
      loop
         fetch csr_geo_zone into rcd_geo_zone;
         if csr_geo_zone%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<GEO_LIST VALCDE="'||to_char(rcd_geo_zone.geo_zone)||'" VALTXT="'||pts_to_xml(rcd_geo_zone.geo_text)||'"/>'));
      end loop;
      close csr_geo_zone;

      /*-*/
      /* Pipe the delete notifier XML
      /*-*/
      pipe row(pts_xml_object('<DEL_NOTE VALCDE="" VALTXT="** NO DELETE NOTIFIER **"/>'));
      open csr_del_note;
      loop
         fetch csr_del_note into rcd_del_note;
         if csr_del_note%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<DEL_NOTE VALCDE="'||to_char(rcd_del_note.val_code)||'" VALTXT="'||pts_to_xml(rcd_del_note.val_text)||'"/>'));
      end loop;
      close csr_del_note;

      /*-*/
      /* Pipe the household XML
      /*-*/
      if var_action = '*UPDHOU' then
         var_output := '<HOUSEHOLD HOUCODE="'||to_char(rcd_retrieve.hde_hou_code)||'"';
         var_output := var_output||' HOUSTAT="'||to_char(rcd_retrieve.hde_hou_status)||'"';
         var_output := var_output||' GEOZONE="'||to_char(rcd_retrieve.hde_geo_zone)||'"';
         var_output := var_output||' DELNOTE="'||to_char(rcd_retrieve.hde_del_notifier)||'"';
         var_output := var_output||' DATJOIN="'||to_char(rcd_retrieve.hde_dat_joined,'dd/mm/yyyy')||'"';
         var_output := var_output||' DATUSED="'||to_char(rcd_retrieve.hde_dat_used,'dd/mm/yyyy')||'"';
         var_output := var_output||' LOCSTRT="'||pts_to_xml(rcd_retrieve.hde_loc_street)||'"';
         var_output := var_output||' LOCTOWN="'||pts_to_xml(rcd_retrieve.hde_loc_town)||'"';
         var_output := var_output||' LOCPCDE="'||pts_to_xml(rcd_retrieve.hde_loc_postcode)||'"';
         var_output := var_output||' LOCCNTY="'||pts_to_xml(rcd_retrieve.hde_loc_country)||'"';
         var_output := var_output||' TELACDE="'||pts_to_xml(rcd_retrieve.hde_tel_areacode)||'"';
         var_output := var_output||' TELNUMB="'||pts_to_xml(rcd_retrieve.hde_tel_number)||'"';
         var_output := var_output||' CONSNAM="'||pts_to_xml(rcd_retrieve.hde_con_surname)||'"';
         var_output := var_output||' CONFNAM="'||pts_to_xml(rcd_retrieve.hde_con_fullname)||'"';
         var_output := var_output||' CONBYER="'||to_char(rcd_retrieve.hde_con_birth_year)||'"';
         var_output := var_output||' HOUNOTE="'||pts_to_xml(rcd_retrieve.hde_notes)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYHOU' then
         var_output := '<HOUSEHOLD HOUCODE="*NEW"';
         var_output := var_output||' HOUSTAT="'||to_char(rcd_retrieve.hde_hou_status)||'"';
         var_output := var_output||' GEOZONE="'||to_char(rcd_retrieve.hde_geo_zone)||'"';
         var_output := var_output||' DELNOTE="'||to_char(rcd_retrieve.hde_del_notifier)||'"';
         var_output := var_output||' DATJOIN="'||to_char(rcd_retrieve.hde_dat_joined,'dd/mm/yyyy')||'"';
         var_output := var_output||' DATUSED="'||to_char(rcd_retrieve.hde_dat_used,'dd/mm/yyyy')||'"';
         var_output := var_output||' LOCSTRT="'||pts_to_xml(rcd_retrieve.hde_loc_street)||'"';
         var_output := var_output||' LOCTOWN="'||pts_to_xml(rcd_retrieve.hde_loc_town)||'"';
         var_output := var_output||' LOCPCDE="'||pts_to_xml(rcd_retrieve.hde_loc_postcode)||'"';
         var_output := var_output||' LOCCNTY="'||pts_to_xml(rcd_retrieve.hde_loc_country)||'"';
         var_output := var_output||' TELACDE="'||pts_to_xml(rcd_retrieve.hde_tel_areacode)||'"';
         var_output := var_output||' TELNUMB="'||pts_to_xml(rcd_retrieve.hde_tel_number)||'"';
         var_output := var_output||' CONSNAM="'||pts_to_xml(rcd_retrieve.hde_con_surname)||'"';
         var_output := var_output||' CONFNAM="'||pts_to_xml(rcd_retrieve.hde_con_fullname)||'"';
         var_output := var_output||' CONBYER="'||to_char(rcd_retrieve.hde_con_birth_year)||'"';
         var_output := var_output||' HOUNOTE="'||pts_to_xml(rcd_retrieve.hde_notes)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CRTHOU' then
         var_output := '<HOUSEHOLD HOUCODE="*NEW"';
         var_output := var_output||' HOUSTAT="1"';
         var_output := var_output||' GEOZONE=""';
         var_output := var_output||' DELNOTE=""';
         var_output := var_output||' DATJOIN=""';
         var_output := var_output||' DATUSED=""';
         var_output := var_output||' LOCSTRT=""';
         var_output := var_output||' LOCTOWN=""';
         var_output := var_output||' LOCPCDE=""';
         var_output := var_output||' LOCCNTY=""';
         var_output := var_output||' TELACDE=""';
         var_output := var_output||' TELNUMB=""';
         var_output := var_output||' CONSNAM=""';
         var_output := var_output||' CONFNAM=""';
         var_output := var_output||' CONBYER=""';
         var_output := var_output||' HOUNOTE=""';
         pipe row(pts_xml_object(var_output));
      end if;

      /*-*/
      /* Pipe the household classification data
      /*-*/
      open csr_table;
      loop
         fetch csr_table into rcd_table;
         if csr_table%notfound then
            exit;
         end if;
         var_tab_flag := false;
         open csr_field;
         loop
            fetch csr_field into rcd_field;
            if csr_field%notfound then
               exit;
            end if;
            if var_tab_flag = false then
               var_tab_flag := true;
               pipe row(pts_xml_object('<TABLE TABCDE="'||rcd_table.sta_tab_code||'" TABTXT="'||pts_to_xml(rcd_table.sta_tab_text)||'"/>'));
            end if;
            pipe row(pts_xml_object('<FIELD FLDCDE="'||to_char(rcd_field.sfi_fld_code)||' FLDTXT="'||pts_to_xml(rcd_field.sfi_fld_text)||'"/>'));
            if var_action != '*CRTHOU' then
               open csr_classification;
               loop
                  fetch csr_classification into rcd_classification;
                  if csr_classification%notfound then
                     exit;
                  end if;
                  pipe row(pts_xml_object('<VALUE VALCDE="'||to_char(rcd_classification.hcl_val_code)||' VALTXT="'||pts_to_xml(rcd_classification.hcl_val_text)||'"/>'));
               end loop;
               close csr_classification;
            end if;
         end loop;
         close csr_field;
      end loop;
      close csr_table;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_HOU_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      obj_cla_list xmlDom.domNodeList;
      obj_cla_node xmlDom.domNode;
      obj_val_list xmlDom.domNodeList;
      obj_val_node xmlDom.domNode;
      var_action varchar2(32);
      rcd_pts_hou_definition pts_hou_definition%rowtype;
      rcd_pts_hou_classification pts_hou_classification%rowtype;
      type typ_dynamic_cursor is ref cursor;
      var_dynamic_cursor typ_dynamic_cursor;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check is
         select t01.*
           from pts_hou_definition t01
          where t01.hde_hou_code = rcd_pts_hou_definition.hde_hou_code;
      rcd_check csr_check%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*HOU_DEF',13)) t01
          where t01.val_code = rcd_pts_hou_definition.hde_hou_status;
      rcd_sta_code csr_sta_code%rowtype;

      cursor csr_geo_zone is
         select t01.*
           from table(pts_app.pts_gen_function.list_geo_zone(40)) t01
          where t01.geo_zone = rcd_pts_hou_definition.hde_geo_zone;
      rcd_geo_zone csr_geo_zone%rowtype;

      cursor csr_del_note is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*HOU_DEF',14)) t01
          where t01.val_code = rcd_pts_hou_definition.hde_del_notifier;
      rcd_del_note csr_del_note%rowtype;

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
      rcd_pts_hou_definition.hde_hou_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@HOUCODE'));
      rcd_pts_hou_definition.hde_hou_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@HOUSTAT'));
      rcd_pts_hou_definition.hde_upd_user := upper(par_user);
      rcd_pts_hou_definition.hde_upd_date := sysdate;
      rcd_pts_hou_definition.hde_geo_zone := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@GEOZONE'));
      rcd_pts_hou_definition.hde_del_notifier := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@DELNOTE'));
      rcd_pts_hou_definition.hde_loc_street := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@LOCSTRT'));
      rcd_pts_hou_definition.hde_loc_town := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@LOCTOWN'));
      rcd_pts_hou_definition.hde_loc_postcode := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@LOCPCDE'));
      rcd_pts_hou_definition.hde_loc_country := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@LOCCNTY'));
      rcd_pts_hou_definition.hde_tel_areacode := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@TELACDE'));
      rcd_pts_hou_definition.hde_tel_number := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@TELNUMB'));
      rcd_pts_hou_definition.hde_con_surname := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@CONSNAM'));
      rcd_pts_hou_definition.hde_con_fullname := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@CONFNAM'));
      rcd_pts_hou_definition.hde_con_birth_year := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@CONBYER'));
      rcd_pts_hou_definition.hde_notes := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@HOUNOTE'));
      if rcd_pts_hou_definition.hde_hou_code is null and not(xslProcessor.valueOf(obj_pts_request,'@HOUCODE') = '*NEW') then
         pts_gen_function.add_mesg_data('Household code ('||xslProcessor.valueOf(obj_pts_request,'@HOUCODE')||') must be a number');
      end if;
      if rcd_pts_hou_definition.hde_geo_zone is null and not(xslProcessor.valueOf(obj_pts_request,'@GEOZONE') is null) then
         pts_gen_function.add_mesg_data('Geographic zone ('||xslProcessor.valueOf(obj_pts_request,'@GEOZONE')||') must be a number');
      end if;
      if rcd_pts_hou_definition.hde_del_notifier is null and not(xslProcessor.valueOf(obj_pts_request,'@DELNOTE') is null) then
         pts_gen_function.add_mesg_data('Delete notifier ('||xslProcessor.valueOf(obj_pts_request,'@DELNOTE')||') must be a number');
      end if;
      if rcd_pts_hou_definition.hde_con_birth_year is null and not(xslProcessor.valueOf(obj_pts_request,'@CONBYER') is null) then
         pts_gen_function.add_mesg_data('Contact birth year ('||xslProcessor.valueOf(obj_pts_request,'@CONBYER')||') must be a number');
      end if;
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*DEFHOU' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_hou_definition.hde_hou_status is null then
         pts_gen_function.add_mesg_data('Household status must be supplied');
      end if;
      if rcd_pts_hou_definition.hde_upd_user is null then
         pts_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if rcd_pts_hou_definition.hde_con_fullname is null then
         pts_gen_function.add_mesg_data('Household contact full name must be supplied');
      end if;
      fetch csr_sta_code into rcd_sta_code;
      if csr_sta_code%notfound then
         pts_gen_function.add_mesg_data('Household status ('||to_char(rcd_pts_hou_definition.hde_hou_status)||') does not exist');
      end if;
      close csr_sta_code;
      if not(rcd_pts_hou_definition.hde_geo_zone is null) then
         rcd_pts_hou_definition.hde_geo_type := 40;
         open csr_geo_zone;
         fetch csr_geo_zone into rcd_geo_zone;
         if csr_geo_zone%notfound then
            pts_gen_function.add_mesg_data('Geographic zone ('||to_char(rcd_pts_hou_definition.hde_geo_zone)||') does not exist');
         else
            if rcd_geo_zone.geo_status != 1 then
               pts_gen_function.add_mesg_data('Geographic zone ('||to_char(rcd_pts_hou_definition.hde_geo_zone)||') is not active');
            end if;
         end if;
         close csr_geo_zone;
      end if;
      if not(rcd_pts_hou_definition.hde_del_notifier is null) then
         open csr_del_note;
         fetch csr_del_note into rcd_del_note;
         if csr_del_note%notfound then
            pts_gen_function.add_mesg_data('Delete notifier ('||to_char(rcd_pts_hou_definition.hde_del_notifier)||') does not exist');
         end if;
         close csr_del_note;
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and process the household definition
      /*-*/
      open csr_check;
      fetch csr_check into rcd_check;
      if csr_check%found then
         update pts_hou_definition
            set hde_hou_status = rcd_pts_hou_definition.hde_hou_status,
                hde_upd_user = rcd_pts_hou_definition.hde_upd_user,
                hde_upd_date = rcd_pts_hou_definition.hde_upd_date,
                hde_geo_type = rcd_pts_hou_definition.hde_geo_type,
                hde_geo_zone = rcd_pts_hou_definition.hde_geo_zone,
                hde_del_notifier = rcd_pts_hou_definition.hde_del_notifier,
                hde_loc_street = rcd_pts_hou_definition.hde_loc_street,
                hde_loc_town = rcd_pts_hou_definition.hde_loc_town,
                hde_loc_postcode = rcd_pts_hou_definition.hde_loc_postcode,
                hde_loc_country = rcd_pts_hou_definition.hde_loc_country,
                hde_tel_areacode = rcd_pts_hou_definition.hde_tel_areacode,
                hde_tel_number = rcd_pts_hou_definition.hde_tel_number,
                hde_con_surname = rcd_pts_hou_definition.hde_con_surname,
                hde_con_fullname = rcd_pts_hou_definition.hde_con_fullname,
                hde_con_birth_year = rcd_pts_hou_definition.hde_con_birth_year,
                hde_notes = rcd_pts_hou_definition.hde_notes
          where hde_hou_code = rcd_pts_hou_definition.hde_hou_code;
         delete from pts_hou_classification where hcl_hou_code = rcd_pts_hou_definition.hde_hou_code;
      else
         select pts_hou_sequence.nextval into rcd_pts_hou_definition.hde_hou_code from dual;
         rcd_pts_hou_definition.hde_del_notifier := null;
         rcd_pts_hou_definition.hde_dat_joined := trunc(sysdate);
         rcd_pts_hou_definition.hde_dat_used := null;
         insert into pts_hou_definition values rcd_pts_hou_definition;
      end if;
      close csr_check;

      /*-*/
      /* Retrieve and insert the classification data
      /*-*/
      rcd_pts_hou_classification.hcl_hou_code := rcd_pts_hou_definition.hde_hou_code;
      obj_cla_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/CLA_DATA');
      for idx in 0..xmlDom.getLength(obj_cla_list)-1 loop
         obj_cla_node := xmlDom.item(obj_cla_list,idx);
         rcd_pts_hou_classification.hcl_tab_code := pts_to_number(xslProcessor.valueOf(obj_cla_node,'@TABCDE'));
         rcd_pts_hou_classification.hcl_fld_code := pts_to_number(xslProcessor.valueOf(obj_cla_node,'@FLDCDE'));
         obj_val_list := xslProcessor.selectNodes(obj_cla_node,'VAL_DATA');
         for idy in 0..xmlDom.getLength(obj_val_list)-1 loop
            obj_val_node := xmlDom.item(obj_val_list,idy);
            rcd_pts_hou_classification.hcl_val_code := pts_to_number(xslProcessor.valueOf(obj_val_node,'@VALCDE'));
            rcd_pts_hou_classification.hcl_val_text := pts_from_xml(xslProcessor.valueOf(obj_val_node,'@VALTXT'));
            insert into pts_hou_classification values rcd_pts_hou_classification;
         end loop;
      end loop;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_HOU_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

   /***************************************************************/
   /* This procedure performs the get classification code routine */
   /***************************************************************/
   function get_class_code(par_hou_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_code_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_classification is
         select nvl(t01.hcl_val_code,0) as hcl_val_code
           from pts_hou_classification t01
          where t01.hcl_hou_code = par_hou_code
            and t01.hcl_tab_code = upper(par_tab_code)
            and t01.hcl_val_code = par_fld_code;
      rcd_classification csr_classification%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the household classification value code
      /*-*/
      open csr_classification;
      loop
         fetch csr_classification into rcd_classification;
         if csr_classification%found then
            pipe row(pts_cla_code_object(rcd_classification.hcl_val_code));
         else
            pipe row(pts_cla_code_object(0));
         end if;
      end loop;
      close csr_classification;

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
         raise_application_error(-20000, 'PTS_HOU_FUNCTION - GET_CLASS_CODE - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_class_code;

   /*****************************************************************/
   /* This procedure performs the get classification number routine */
   /*****************************************************************/
   function get_class_number(par_hou_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_numb_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_classification is
         select nvl(t01.hcl_val_text,0) as hcl_val_text
           from pts_hou_classification t01
          where t01.hcl_hou_code = par_hou_code
            and t01.hcl_tab_code = upper(par_tab_code)
            and t01.hcl_val_code = par_fld_code;
      rcd_classification csr_classification%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the household classification value number
      /*-*/
      open csr_classification;
      loop
         fetch csr_classification into rcd_classification;
         if csr_classification%found then
            pipe row(pts_cla_numb_object(rcd_classification.hcl_val_text));
         else
            pipe row(pts_cla_numb_object(0));
         end if;
      end loop;
      close csr_classification;

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
         raise_application_error(-20000, 'PTS_HOU_FUNCTION - GET_CLASS_NUMBER - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_class_number;

   /***************************************************************/
   /* This procedure performs the get classification text routine */
   /***************************************************************/
   function get_class_text(par_hou_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_text_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_classification is
         select t01.hcl_val_text as hcl_val_text
           from pts_hou_classification t01
          where t01.hcl_hou_code = par_hou_code
            and t01.hcl_tab_code = upper(par_tab_code)
            and t01.hcl_val_code = par_fld_code;
      rcd_classification csr_classification%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the household classification value text
      /*-*/
      open csr_classification;
      loop
         fetch csr_classification into rcd_classification;
         if csr_classification%found then
            pipe row(pts_cla_text_object(rcd_classification.hcl_val_text));
         else
            pipe row(pts_cla_text_object('*NULL'));
         end if;
      end loop;
      close csr_classification;

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
         raise_application_error(-20000, 'PTS_HOU_FUNCTION - GET_CLASS_TEXT - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_class_text;

end pts_hou_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_hou_function for pts_app.pts_hou_function;
grant execute on pts_app.pts_hou_function to public;

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
      if var_action != '*UPDMAP' and var_action != '*CRTMAP' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing mapping when required
      /*-*/
      if var_action = '*UPDMAP' then
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
      elsif var_action = '*CRTMAP' then
         var_output := '<MAP MAPCODE=""/>';
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
      if rcd_pts_map_definition.mde_map_code is null then
         pts_gen_function.add_mesg_data('Mapping code must be supplied');
      end if;
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
      var_output varchar2(4000);
      var_instance number(15,0);
      var_source varchar2(30);
      var_map_code varchar2(32);
      var_ext_date varchar2(32);
      var_hou_code number;
      var_pet_code number;
      var_approach_code number(6);
      var_approach_desc varchar2(30);
      var_approach_score number(6);
      var_more_code number(6);
      var_more_desc varchar2(30);
      var_more_score number(6);
      var_enjoy_code number(6);
      var_enjoy_desc varchar2(30);
      var_enjoy_score number(6);
      var_estintake_desc varchar2(30);
      var_estintake_code number(6);
      var_estintake_score number(6);
      var_intake_code number(6);
      var_intake_desc varchar2(30);
      var_intake_score number(6);
      var_aroma_code number(6);
      var_aroma_desc varchar2(30);
      var_aroma_score number(6);
      var_buy_code number(6);
      var_buy_desc varchar2(30);
      var_buy_score number(6);
      var_offered_code number(6);
      var_offered_desc varchar2(30);
      var_offered_score number(10,3);
      var_rate_code number(6);
      var_rate_desc varchar2(30);
      var_rate_score number(6);
      var_time_code number(6);
      var_time_desc varchar2(30);
      var_time_score number(6);
      var_enjoyflag_code number(6);
      var_enjoyflag_desc varchar2(30);
      var_enjoyflag_score number(6);
      var_woffered_code number(6);
      var_woffered_desc varchar2(30);
      var_woffered_score number(6);
      var_weoffered_code number(6);
      var_weoffered_desc varchar2(30);
      var_weoffered_score number(6);
      var_wbowl_code number(6);
      var_wbowl_desc varchar2(30);
      var_wbowl_score number(6);
      var_wremaining_code number(6);
      var_wremaining_desc varchar2(30);
      var_wremaining_score number(6);
      var_feeding_qty number(4);
      var_proportion_offered number(6);
      var_amount_offered number(10,3);
      var_intake_amount number(10,3);
      var_health_comments varchar2(1);
      var_num_adults number;
      var_num_children number;
      var_num_total number;
      type typ_hdr_outp is table of varchar2(4000) index by binary_integer;
      type typ_det_outp is table of varchar2(4000) index by binary_integer;
      type typ_env_outp is table of varchar2(4000) index by binary_integer;
      type typ_ani_outp is table of varchar2(4000) index by binary_integer;
      tbl_hdr_outp typ_hdr_outp;
      tbl_det_outp typ_det_outp;
      tbl_env_outp typ_env_outp;
      tbl_ani_outp typ_ani_outp;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'PTS GLOPAL Extract';
      con_alt_group constant varchar2(32) := 'PTS_ALERT';
      con_alt_code constant varchar2(32) := 'PTS_GLOPAL_EXTRACT';
      con_ema_group constant varchar2(32) := 'PTS_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'PTS_GLOPAL_EXTRACT';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.*,
                t02.tty_typ_text
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type
            and t01.tde_glo_status = 3
          order by t01.tde_tes_code;
      rcd_header csr_header%rowtype;

      cursor csr_country is
         select t01.gzo_zon_text
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
            and t01.gzo_geo_type = 10
            and t04.gzo_geo_zone = (select min(tpa_geo_zone)
                                      from pts_tes_panel
                                     where tpa_tes_code = rcd_header.tde_tes_code);
      rcd_country csr_country%rowtype;

      cursor csr_detail is
         select t01.tpa_tes_code,
                t01.tpa_hou_code,
                t01.tpa_pan_code,
                t01.tpa_pet_name,
                t01.tpa_health_comment,
                t01.tpa_birth_year,
                t02.tal_day_code,
                t02.tal_sam_code,
                t03.sde_plop_code,
                t03.sde_uom_size,
                (select pty_typ_text from pts_pet_type where pty_pet_type = t01.tpa_pet_type) as pet_type_text,
                (select sva_val_text from pts_sys_value where sva_tab_code = '*PET_CLA' and sva_fld_code = 1 and sva_val_code = (select tcl_val_code from pts_tes_classification where tcl_tab_code = '*PET_CLA' and tcl_fld_code = 1 and tcl_tes_code = t01.tpa_tes_code and tcl_pan_code = t01.tpa_pan_code)) as pet_breed_text,
                (select sva_val_text from pts_sys_value where sva_tab_code = '*PET_CLA' and sva_fld_code = 8 and sva_val_code = (select tcl_val_code from pts_tes_classification where tcl_tab_code = '*PET_CLA' and tcl_fld_code = 8 and tcl_tes_code = t01.tpa_tes_code and tcl_pan_code = t01.tpa_pan_code)) as pet_size_text,
                nvl((select sva_val_text from pts_sys_value where sva_tab_code = '*PET_CLA' and sva_fld_code = 26 and sva_val_code = (select tcl_val_code from pts_tes_classification where tcl_tab_code = '*PET_CLA' and tcl_fld_code = 26 and tcl_tes_code = t01.tpa_tes_code and tcl_pan_code = t01.tpa_pan_code)),'Household') as pet_envir_text,
                decode((select tcl_val_code from pts_tes_classification where tcl_tab_code = '*PET_CLA' and tcl_fld_code = 3 and tcl_tes_code = t01.tpa_tes_code and tcl_pan_code = t01.tpa_pan_code),1,'M',2,'F',null) as pet_sex_code,
                decode((select tcl_val_code from pts_tes_classification where tcl_tab_code = '*PET_CLA' and tcl_fld_code = 5 and tcl_tes_code = t01.tpa_tes_code and tcl_pan_code = t01.tpa_pan_code),1,'E',2,'N',null) as pet_desexed_code,
                decode((select tcl_val_code from pts_tes_classification where tcl_tab_code = '*PET_CLA' and tcl_fld_code = 6 and tcl_tes_code = t01.tpa_tes_code and tcl_pan_code = t01.tpa_pan_code),1,'Y',2,'N',null) as pet_pedigree_code,
                (select hde_dat_joined from pts_hou_definition where hde_hou_code = t01.tpa_hou_code) as hou_dat_joined,
                (select t11.gzo_zon_text
                   from pts_geo_zone t11,
                        pts_geo_zone t12,
                        pts_geo_zone t13,
                        pts_geo_zone t14
                 where t11.gzo_geo_type = t12.gzo_par_type
                   and t11.gzo_geo_zone = t12.gzo_par_zone
                   and t12.gzo_geo_type = t13.gzo_par_type
                   and t12.gzo_geo_zone = t13.gzo_par_zone
                   and t13.gzo_geo_type = t14.gzo_par_type
                   and t13.gzo_geo_zone = t14.gzo_par_zone
                   and t14.gzo_geo_type = t01.tpa_geo_type
                   and t14.gzo_geo_zone = t01.tpa_geo_zone
                   and t11.gzo_geo_type = 10) as hou_cou_text,
                (select gzo_zon_text from pts_geo_zone where gzo_geo_type = 40 and gzo_geo_type = t01.tpa_geo_type and gzo_geo_zone = t01.tpa_geo_zone) as hou_geo_text,
                nvl((select count(*) from pts_pet_definition where pde_hou_code = t01.tpa_hou_code and pde_pet_type = 1 and not(pde_pet_status in (4,9))),0) as hou_dog_count,
                nvl((select count(*) from pts_pet_definition where pde_hou_code = t01.tpa_hou_code and pde_pet_type = 2 and not(pde_pet_status in (4,9))),0) as hou_cat_count,
                to_number(nvl((select hcl_val_text from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 1 and hcl_hou_code = t01.tpa_hou_code),'0')) as hou_adult01_count,
                to_number(nvl((select hcl_val_text from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 2 and hcl_hou_code = t01.tpa_hou_code),'0')) as hou_child11_count,
                to_number(nvl((select hcl_val_text from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 3 and hcl_hou_code = t01.tpa_hou_code),'0')) as hou_child12_count,
                to_number(nvl((select hcl_val_text from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 4 and hcl_hou_code = t01.tpa_hou_code),'0')) as hou_child13_count,
                to_number(nvl((select hcl_val_text from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 5 and hcl_hou_code = t01.tpa_hou_code),'0')) as hou_adult02_count,
                to_number(nvl((select hcl_val_text from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 6 and hcl_hou_code = t01.tpa_hou_code),'0')) as hou_child21_count,
                to_number(nvl((select hcl_val_text from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 7 and hcl_hou_code = t01.tpa_hou_code),'0')) as hou_child22_count,
                to_number(nvl((select hcl_val_text from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 8 and hcl_hou_code = t01.tpa_hou_code),'0')) as hou_child23_count,
                (select sva_val_text from pts_sys_value where sva_tab_code = '*HOU_CLA' and sva_fld_code = 9 and sva_val_code = (select hcl_val_code from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 9 and hcl_hou_code = t01.tpa_hou_code)) as hou_urban_text,
                (select sva_val_text from pts_sys_value where sva_tab_code = '*HOU_CLA' and sva_fld_code = 10 and sva_val_code = (select hcl_val_code from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 10 and hcl_hou_code = t01.tpa_hou_code)) as hou_income_text,
                decode((select hcl_val_code from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 11 and hcl_hou_code = t01.tpa_hou_code),1,'M',2,'F',null) as hou_sex_code,
                (select sva_val_text from pts_sys_value where sva_tab_code = '*HOU_CLA' and sva_fld_code = 12 and sva_val_code = (select hcl_val_code from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 12 and hcl_hou_code = t01.tpa_hou_code)) as hou_work_text,
                (select sva_val_text from pts_sys_value where sva_tab_code = '*HOU_CLA' and sva_fld_code = 13 and sva_val_code = (select hcl_val_code from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 13 and hcl_hou_code = t01.tpa_hou_code)) as hou_edu_text,
                (select sva_val_text from pts_sys_value where sva_tab_code = '*HOU_CLA' and sva_fld_code = 14 and sva_val_code = (select hcl_val_code from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 14 and hcl_hou_code = t01.tpa_hou_code)) as hou_marital_text,
                (select sva_val_text from pts_sys_value where sva_tab_code = '*HOU_CLA' and sva_fld_code = 15 and sva_val_code = (select hcl_val_code from pts_hou_classification where hcl_tab_code = '*HOU_CLA' and hcl_fld_code = 15 and hcl_hou_code = t01.tpa_hou_code)) as hou_age_text
           from pts_tes_panel t01,
                pts_tes_allocation t02,
                pts_sam_definition t03
          where t01.tpa_tes_code = t02.tal_tes_code
            and t01.tpa_pan_code = t02.tal_pan_code
            and t02.tal_sam_code = t03.sde_sam_code
            and t01.tpa_tes_code = rcd_header.tde_tes_code
            and (t01.tpa_tes_code, t01.tpa_pan_code) in (select tre_tes_code, tre_pan_code
                                                           from pts_tes_response
                                                          where tre_tes_code = rcd_header.tde_tes_code
                                                          group by tre_tes_code, tre_pan_code)
           order by t01.tpa_hou_code,
                    t01.tpa_pan_code,
                    t02.tal_day_code,
                    t02.tal_sam_code;
      rcd_detail csr_detail%rowtype;

      cursor csr_response is
         select t03.qre_res_code as resp_code,
                t03.qre_res_text as resp_desc,
                t01.tre_res_value as resp_score
           from pts_tes_response t01,
                pts_que_definition t02,
                pts_que_response t03,
                pts_map_question t04
          where t01.tre_que_code = t02.qde_que_code
            and t01.tre_que_code = t03.qre_que_code(+)
            and t01.tre_res_value = t03.qre_res_code(+)
            and t01.tre_tes_code = rcd_detail.tpa_tes_code
            and t01.tre_pan_code = rcd_detail.tpa_pan_code
            and (t01.tre_sam_code = rcd_detail.tal_sam_code or t01.tre_sam_code = 0)
            and t01.tre_day_code = rcd_detail.tal_day_code
            and t01.tre_que_code = t04.mqu_que_code
            and t04.mqu_map_code = var_map_code;
      rcd_response csr_response%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'PTS - GLOPAL EXTRACT';
      var_log_search := 'PTS_GLOPAL_EXTRACT';
      var_loc_string := 'PTS_GLOPAL_EXTRACT';
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
      lics_logging.write_log('Begin - PTS GloPal Extract');

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
         /* Retrieve the extract constants
         /*-*/
         var_ext_date := to_char(sysdate,'ddmmyyyy');
         var_source := 'WOD';

         /*-*/
         /* Clear the output arrays
         /*-*/
         tbl_hdr_outp.delete;
         tbl_det_outp.delete;
         tbl_env_outp.delete;
         tbl_ani_outp.delete;

         /*-*/
         /* Retrieve the header data
         /*-*/
         open csr_header;
         loop
            fetch csr_header into rcd_header;
            if csr_header%notfound then
               exit;
            end if;

            /*-*/
            /* Retrieve the header country
            /*-*/
            open csr_country;
            fetch csr_country into rcd_country;
            if csr_country%notfound then
               rcd_country.gzo_zon_text := null;
            end if;
            close csr_country;

            /*-*/
            /* Output the header
            /*-*/
            var_output := '"' || var_ext_date || '",' ||
                          '"",' ||
                          '"",' ||
                          to_char(rcd_header.tde_tes_day_count) || ',' ||
                          '"' || rtrim(substr(rcd_header.tde_tes_req_miden,1,8)) || '",' ||
                          '"' || rtrim(substr(rcd_header.tde_tes_req_name,1,40)) || '",' ||
                          '"",' ||
                          '"' || var_source || '",' ||
                          '"' || to_char(rcd_header.tde_tes_str_date,'ddmmyyyy') || '",' ||
                          '"' || substr(rcd_header.tde_tes_aim,1,255) || '",' ||
                          '"' || substr(rcd_country.gzo_zon_text,1,20) || '",' ||
                          '"' || to_char(rcd_header.tde_tes_code) || '",' ||
                          '"' || rtrim(substr(rcd_header.tty_typ_text,1,20)) || '"';
            tbl_hdr_outp(tbl_hdr_outp.count + 1) := var_output;

            /*-*/
            /* Retrieve the details
            /*-*/
            var_hou_code := -1;
            var_pet_code := -1;
            open csr_detail;
            loop
               fetch csr_detail into rcd_detail;
               if csr_detail%notfound then
                  exit;
               end if;

               /*-*/
               /* Retrieve the response values
               /*-*/
               var_map_code := 'Approach to food';
               var_approach_code := null;
               var_approach_desc := null;
               var_approach_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_approach_code := rcd_response.resp_code;
                  var_approach_desc := rcd_response.resp_desc;
                  var_approach_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_map_code := 'More/Less';
               var_more_code := null;
               var_more_desc := null;
               var_more_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_more_code := rcd_response.resp_code;
                  var_more_desc := rcd_response.resp_desc;
                  var_more_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_map_code := 'Enjoyment score';
               var_enjoy_code := null;
               var_enjoy_desc := null;
               var_enjoy_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_enjoy_code := rcd_response.resp_code;
                  var_enjoy_desc := rcd_response.resp_desc;
                  var_enjoy_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_map_code := 'Estimated Intake';
               var_estintake_code := null;
               var_estintake_desc := null;
               var_estintake_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_estintake_code := rcd_response.resp_code;
                  var_estintake_desc := rcd_response.resp_desc;
                  var_estintake_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_map_code := 'Intake';
               var_intake_code := null;
               var_intake_desc := null;
               var_intake_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_intake_code := rcd_response.resp_code;
                  var_intake_desc := rcd_response.resp_desc;
                  var_intake_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_map_code := 'Aroma';
               var_aroma_code := null;
               var_aroma_desc := null;
               var_aroma_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_aroma_code := rcd_response.resp_code;
                  var_aroma_desc := rcd_response.resp_desc;
                  var_aroma_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_map_code := 'Will buy';
               var_buy_code := null;
               var_buy_desc := null;
               var_buy_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_buy_code := rcd_response.resp_code;
                  var_buy_desc := rcd_response.resp_desc;
                  var_buy_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_map_code := '% offered';
               var_offered_code := null;
               var_offered_desc := null;
               var_offered_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_offered_code := rcd_response.resp_code;
                  var_offered_desc := rcd_response.resp_desc;
                  var_offered_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_map_code := 'Eating Rate';
               var_rate_code := null;
               var_rate_desc := null;
               var_rate_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_rate_code := rcd_response.resp_code;
                  var_rate_desc := rcd_response.resp_desc;
                  var_rate_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_map_code := 'Time';
               var_time_code := null;
               var_time_desc := null;
               var_time_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_time_code := rcd_response.resp_code;
                  var_time_desc := rcd_response.resp_desc;
                  var_time_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_map_code := 'Enjoy flag';
               var_enjoyflag_code := null;
               var_enjoyflag_desc := null;
               var_enjoyflag_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_enjoyflag_code := rcd_response.resp_code;
                  var_enjoyflag_desc := rcd_response.resp_desc;
                  var_enjoyflag_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_map_code := 'Weight Offered';
               var_woffered_code := null;
               var_woffered_desc := null;
               var_woffered_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_woffered_code := rcd_response.resp_code;
                  var_woffered_desc := rcd_response.resp_desc;
                  var_woffered_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_map_code := 'Weight Est Offered';
               var_weoffered_code := null;
               var_weoffered_desc := null;
               var_weoffered_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_weoffered_code := rcd_response.resp_code;
                  var_weoffered_desc := rcd_response.resp_desc;
                  var_weoffered_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_map_code := 'Weight of Bowl';
               var_wbowl_code := null;
               var_wbowl_desc := null;
               var_wbowl_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_wbowl_code := rcd_response.resp_code;
                  var_wbowl_desc := rcd_response.resp_desc;
                  var_wbowl_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_map_code := 'Weight Remaining';
               var_wremaining_code := null;
               var_wremaining_desc := null;
               var_wremaining_score := null;
               open csr_response;
               fetch csr_response into rcd_response;
               if csr_response%found then
                  var_wremaining_code := rcd_response.resp_code;
                  var_wremaining_desc := rcd_response.resp_desc;
                  var_wremaining_score := rcd_response.resp_score;
               end if;
               close csr_response;

               var_feeding_qty := rcd_detail.sde_uom_size;
               select decode(var_offered_code,1,0.250,2,0.333,3,0.500,4,0.666,5,0.750,6,1.000,7,1.5,8,2,9,2.5,10,3,1) into var_offered_score from dual;
               var_amount_offered := nvl(var_woffered_score, nvl(to_number(var_weoffered_desc),var_feeding_qty * nvl(var_offered_score,1)));
               var_proportion_offered := var_offered_code;
               if var_estintake_code is null then
                  if var_wremaining_score is null then
                     var_intake_amount := null;
                  else
                     var_intake_amount := var_amount_offered + nvl(var_wbowl_score,0) - nvl(var_wremaining_score,0);
                  end if;
               else
                  var_intake_amount := null;
               end if;

               /*-*/
               /* Output the detail
               /*-*/
               var_output := nvl(to_char(var_amount_offered),'') || ',' ||
                             nvl(var_approach_code,'') || ',' ||
                             '"' || rtrim(substr(nvl(var_approach_desc,''),1,50)) || '",' ||
                             ',' ||
                             '"' || var_ext_date || '",' ||
                             '"' || to_char(rcd_header.tde_tes_str_date + (rcd_detail.tal_day_code - 1),'ddmmyyyy') || '",' ||
                             nvl(var_more_code,'') || ',' ||
                             '"' || rtrim(substr(nvl(var_more_desc,''),1,50)) || '",' ||
                             nvl(var_enjoy_score,'') || ',' ||
                             nvl(var_estintake_code,'') || ',' ||
                             '"' || rtrim(substr(nvl(var_estintake_desc,''),1,50)) || '",' ||
                             '"' || rtrim(rcd_detail.tal_sam_code) || '",' ||
                             ',' ||
                             to_number(nvl(var_intake_amount,'')) || ',' ||
                             '1,' ||
                             '"' || rtrim(substr(rcd_detail.sde_plop_code,1,20)) || '",' ||
                             to_number(nvl(var_aroma_score,'')) || ',' ||
                             nvl(var_buy_code,'') || ',' ||
                             '"' || rtrim(substr(nvl(var_buy_desc,''),1,50)) || '",' ||
                             nvl(var_proportion_offered,'') || ',' ||
                             to_number(nvl(var_rate_score,'')) || ',' ||
                             nvl(rcd_header.tde_tes_max_temp,'') || ',' ||
                             '"' || var_source || '",' ||
                             '"' || rtrim(rcd_header.tde_tes_code) || '",' ||
                             to_number(nvl(var_time_score,'')) || ',' ||
                             '"' || rtrim(rcd_detail.tpa_pan_code) || '",' ||
                             ',' ||
                             '1,' ||
                             rcd_header.tde_tes_len_meal;
               tbl_det_outp(tbl_det_outp.count + 1) := var_output;

               /*-*/
               /* Output the household data when required
               /*-*/
               if rcd_detail.tpa_hou_code != var_hou_code then

                  var_num_adults := rcd_detail.hou_adult01_count + rcd_detail.hou_adult02_count;
                  var_num_children := rcd_detail.hou_child11_count + rcd_detail.hou_child12_count + rcd_detail.hou_child13_count + rcd_detail.hou_child21_count + rcd_detail.hou_child22_count + rcd_detail.hou_child23_count;
                  var_num_total := var_num_adults + var_num_children;

                  var_output := '"' || rtrim(substr(rcd_detail.hou_geo_text,1,18)) || '",' ||
                                '"' || var_ext_date || '",' ||
                                '"' || to_char(rcd_detail.hou_dat_joined, 'ddmmyyyy')|| '",' ||
                                '"' || rtrim(substr(rcd_detail.hou_edu_text,1,27)) || '",' ||
                                '"' || rtrim(substr(rcd_detail.hou_cou_text,1,20))|| '",' ||
                                '"' || rtrim(substr(rcd_detail.pet_envir_text,1,10)) || '",' ||
                                '"' || rtrim(substr(rcd_detail.hou_income_text,1,15)) || '",' ||
                                '"' || rtrim(substr(rcd_detail.hou_urban_text,1,19)) || '",' ||
                                '"' || rtrim(substr(rcd_detail.hou_marital_text,1,18)) || '",' ||
                                var_num_adults || ',' ||
                                rcd_detail.hou_cat_count || ',' ||
                                var_num_children || ',' ||
                                rcd_detail.hou_dog_count || ',' ||
                                var_num_total || ',' ||
                                '"' || rtrim(substr(rcd_detail.hou_work_text,1,50)) || '",' ||
                                '"' || rtrim(substr(rcd_detail.hou_age_text,1,12)) || '",' ||
                                '"' || rcd_detail.hou_sex_code || '",' ||
                                '"' || rcd_detail.tpa_hou_code || '",' ||
                                '"' || var_source || '"';
                  tbl_env_outp(tbl_env_outp.count + 1) := var_output;

               end if;
               var_hou_code := rcd_detail.tpa_hou_code;

               /*-*/
               /* Retrieve the pet data when required
               /*-*/
               if rcd_detail.tpa_pan_code != var_pet_code then

                  if rcd_detail.tpa_health_comment is null then
                     var_health_comments := 'N';
                  else
                     var_health_comments := 'Y';
                  end if;

                  var_output := '"' || rtrim(substr(rcd_detail.hou_cou_text,1,20)) || '",' ||
                                ',' ||
                                '"",' ||
                                '"' || rcd_detail.pet_sex_code || '",' ||
                                '"",' ||
                                ',' ||
                                ',' ||
                                ',' ||
                                ',' ||
                                '"' || rcd_detail.pet_desexed_code || '",' ||
                                '"' || rtrim(substr(rcd_detail.pet_size_text,1,6))|| '",' ||
                                '"",' ||
                                '"' || rtrim(substr(rcd_detail.pet_type_text,1,10)) || '",' ||
                                '"' || to_char(rcd_detail.tpa_pan_code) || '",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                ',' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"' || var_ext_date || '",' ||
                                '"' || to_char(rcd_detail.tpa_birth_year) || '01",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                ',' ||
                                '"",' ||
                                '"' || to_char(rcd_detail.tpa_hou_code)  || '",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                ',' ||
                                '"",' ||
                                ',' ||
                                '"",' ||
                                ',' ||
                                '"",' ||
                                ',' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                ',' ||
                                '"",' ||
                                '"' || rtrim(substr(rcd_detail.tpa_pet_name,1,18)) || '",' ||
                                '"' || rcd_detail.pet_pedigree_code|| '",' ||
                                ',' ||
                                ',' ||
                                '"",' ||
                                ',' ||
                                '"",' ||
                                ',' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                '"",' ||
                                ',' ||
                                '"",' ||
                                ',' ||
                                '"",' ||
                                '"' || var_source || '",' ||
                                ',' ||
                                '"",' ||
                                ',' ||
                                '"' || var_health_comments || '",' ||
                                '"' || rtrim(substr(rcd_detail.pet_breed_text,1,30)) || '",' ||
                                ','||
                                '"",';
                  tbl_ani_outp(tbl_ani_outp.count + 1) := var_output;

               end if;
               var_pet_code := rcd_detail.tpa_pan_code;

            end loop;
            close csr_detail;

            /*-*/
            /* Create the test definition
            /*-*/
            update pts_tes_definition
               set tde_glo_status = 4
             where tde_tes_code = rcd_header.tde_tes_code;

         end loop;
         close csr_header;

         /*-*/
         /* Create the header interface
         /*-*/
         var_instance := lics_outbound_loader.create_interface('PTSGPL01',null,'TESTDEF_'||var_source||'.TXT');
         for idx in 1..tbl_hdr_outp.count loop
            lics_outbound_loader.append_data(tbl_hdr_outp(idx));
         end loop;
         lics_outbound_loader.finalise_interface;

         /*-*/
         /* Create the detail interface
         /*-*/
         var_instance := lics_outbound_loader.create_interface('PTSGPL02',null,'TESTDETL_'||var_source||'.TXT');
         for idx in 1..tbl_det_outp.count loop
            lics_outbound_loader.append_data(tbl_det_outp(idx));
         end loop;
         lics_outbound_loader.finalise_interface;

         /*-*/
         /* Create the environment interface
         /*-*/
         var_instance := lics_outbound_loader.create_interface('PTSGPL03',null,'ENVRNT_'||var_source||'.TXT');
         for idx in 1..tbl_env_outp.count loop
            lics_outbound_loader.append_data(tbl_env_outp(idx));
         end loop;
         lics_outbound_loader.finalise_interface;

         /*-*/
         /* Create the animal interface
         /*-*/
         var_instance := lics_outbound_loader.create_interface('PTSGPL04',null,'ANML_'||var_source||'.TXT');
         for idx in 1..tbl_ani_outp.count loop
            lics_outbound_loader.append_data(tbl_ani_outp(idx));
         end loop;
         lics_outbound_loader.finalise_interface;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

         /*-*/
         /* Release the lock
         /*-*/
         lics_locking.release(var_loc_string);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - PTS GloPal Extract');

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
                                         'PTS_GLOPAL_EXTRACT',
                                         var_email,
                                         'One or more errors occurred during the PTS GloPal extract execution - refer to web log - ' || lics_logging.callback_identifier);
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

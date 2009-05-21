/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_pet_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_pet_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Pet Function

    This package contain the pet functions and procedures.

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

end pts_pet_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_pet_function as

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
         select t01.pde_pet_code,
                t01.pde_pet_name,
                nvl((select sva_val_text from pts_sys_value where sva_tab_code = '*PET_DEF' and sva_fld_code = 4 and sva_val_code = t01.pde_pet_status),'*UNKNOWN') as pde_pet_status
           from pts_pet_definition t01
          where t01.pde_pet_code in (select sel_code from table(pts_app.pts_gen_function.get_list_data('*PET',null)))
            and t01.pde_pet_code > (select sel_code from table(pts_app.pts_gen_function.get_list_from))
          order by t01.pde_pet_code asc;
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
      /* Retrieve the pet list and pipe the results
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
            pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.pde_pet_code)||'" SELTXT="'||pts_to_xml('('||to_char(rcd_list.pde_pet_code)||') '||rcd_list.pde_pet_name)||'" COL1="'||pts_to_xml('('||to_char(rcd_list.pde_pet_code)||') '||rcd_list.pde_pet_name)||'" COL2="'||pts_to_xml(rcd_list.pde_pet_status)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_PET_FUNCTION - RETRIEVE_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_pet_code varchar2(32);
      var_tab_flag boolean;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                decode(t02.hde_hou_code,null,'** DATA ENTRY **',t02.hde_con_fullname||', '||hde_loc_street||', '||hde_loc_town) as hou_text
           from pts_pet_definition t01,
                pts_hou_definition t02
          where t01.pde_hou_code = t02.hde_hou_code(+)
            and t01.pde_pet_code = pts_to_number(var_pet_code);
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*PET_DEF',4)) t01;
      rcd_sta_code csr_sta_code%rowtype;

      cursor csr_pet_type is
         select t01.*
           from table(pts_app.pts_gen_function.list_pet_type) t01
          where t01.pty_status = 1;
      rcd_pet_type csr_pet_type%rowtype;

      cursor csr_del_note is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*PET_DEF',5)) t01;
      rcd_del_note csr_del_note%rowtype;

      cursor csr_table is
         select t01.sta_tab_code,
                t01.sta_tab_text
           from pts_sys_table t01
          where t01.sta_tab_code in ('*PET_CLA','*PET_SAM')
          order by t01.sta_tab_text asc;
      rcd_table csr_table%rowtype;

      cursor csr_field is
         select t01.sfi_fld_code,
                t01.sfi_fld_text,
                t01.sfi_fld_inp_leng,
                t01.sfi_fld_sel_type
           from pts_sys_field t01
          where t01.sfi_tab_code = rcd_table.sta_tab_code
            and t01.sfi_fld_status = '1'
          order by t01.sfi_fld_text asc;
      rcd_field csr_field%rowtype;

      cursor csr_classification is
         select t01.pcl_val_code,
                t01.pcl_val_text,
                t02.sva_val_code,
                t02.sva_val_text
           from pts_pet_classification t01,
                pts_sys_value t02
          where t01.pcl_tab_code = t02.sva_tab_code(+)
            and t01.pcl_fld_code = t02.sva_fld_code(+)
            and t01.pcl_val_code = t02.sva_val_code(+)
            and t01.pcl_pet_code = pts_to_number(var_pet_code)
            and t01.pcl_tab_code = rcd_table.sta_tab_code
            and t01.pcl_fld_code = rcd_field.sfi_fld_code
          order by t01.pcl_val_code asc;
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
      var_pet_code := xslProcessor.valueOf(obj_pts_request,'@PETCODE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDPET' and var_action != '*CRTPET' and var_action != '*CPYPET' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing pet when required
      /*-*/
      if var_action = '*UPDPET' or var_action = '*CPYPET' then
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            pts_gen_function.add_mesg_data('Pet ('||var_pet_code||') does not exist');
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
         pipe row(pts_xml_object('<STA_LIST VALCDE="'||rcd_sta_code.val_code||'" VALTXT="'||pts_to_xml(rcd_sta_code.val_text)||'"/>'));
      end loop;
      close csr_sta_code;

      /*-*/
      /* Pipe the pet type XML
      /*-*/
      pipe row(pts_xml_object('<PET_TYPE VALCDE="" VALTXT="** NO PET TYPE **"/>'));
      open csr_pet_type;
      loop
         fetch csr_pet_type into rcd_pet_type;
         if csr_pet_type%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<PET_TYPE VALCDE="'||rcd_pet_type.pty_code||'" VALTXT="'||pts_to_xml(rcd_pet_type.pty_text)||'"/>'));
      end loop;
      close csr_pet_type;

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
      /* Pipe the pet XML
      /*-*/
      if var_action = '*UPDPET' then
         var_output := '<PET PETCODE="'||to_char(rcd_retrieve.pde_pet_code)||'"';
         var_output := var_output||' PETSTAT="'||to_char(rcd_retrieve.pde_pet_status)||'"';
         var_output := var_output||' PETNAME="'||pts_to_xml(rcd_retrieve.pde_pet_name)||'"';
         var_output := var_output||' PETTYPE="'||to_char(rcd_retrieve.pde_pet_type)||'"';
         var_output := var_output||' HOUCODE="'||to_char(rcd_retrieve.pde_hou_code)||'"';
         var_output := var_output||' HOUTEXT="'||pts_to_xml(rcd_retrieve.hou_text)||'"';
         var_output := var_output||' BTHYEAR="'||to_char(rcd_retrieve.pde_birth_year)||'"';
         var_output := var_output||' DELNOTE="'||to_char(rcd_retrieve.pde_del_notifier)||'"';
         var_output := var_output||' FEDCMNT="'||pts_to_xml(rcd_retrieve.pde_feed_comment)||'"';
         var_output := var_output||' HTHCMNT="'||pts_to_xml(rcd_retrieve.pde_health_comment)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYPET' then
         var_output := '<PET PETCODE="*NEW"';
         var_output := var_output||' PETSTAT="'||to_char(rcd_retrieve.pde_pet_status)||'"';
         var_output := var_output||' PETNAME="'||pts_to_xml(rcd_retrieve.pde_pet_name)||'"';
         var_output := var_output||' PETTYPE="'||to_char(rcd_retrieve.pde_pet_type)||'"';
         var_output := var_output||' HOUCODE="'||to_char(rcd_retrieve.pde_hou_code)||'"';
         var_output := var_output||' HOUTEXT="'||pts_to_xml(rcd_retrieve.hou_text)||'"';
         var_output := var_output||' BTHYEAR="'||to_char(rcd_retrieve.pde_birth_year)||'"';
         var_output := var_output||' DELNOTE="'||to_char(rcd_retrieve.pde_del_notifier)||'"';
         var_output := var_output||' FEDCMNT="'||pts_to_xml(rcd_retrieve.pde_feed_comment)||'"';
         var_output := var_output||' HTHCMNT="'||pts_to_xml(rcd_retrieve.pde_health_comment)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CRTPET' then
         var_output := '<PET PETCODE="*NEW"';
         var_output := var_output||' PETSTAT="1"';
         var_output := var_output||' PETNAME=""';
         var_output := var_output||' PETTYPE=""';
         var_output := var_output||' HOUCODE=""';
         var_output := var_output||' HOUTEXT="** DATA ENTRY **"';
         var_output := var_output||' BTHYEAR=""';
         var_output := var_output||' DELNOTE=""';
         var_output := var_output||' FEDCMNT=""';
         var_output := var_output||' HTHCMNT=""/>';
         pipe row(pts_xml_object(var_output));
      end if;

      /*-*/
      /* Pipe the pet classification data
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
            pipe row(pts_xml_object('<FIELD FLDCDE="'||to_char(rcd_field.sfi_fld_code)||'" FLDTXT="'||pts_to_xml(rcd_field.sfi_fld_text)||'" INPLEN="'||to_char(rcd_field.sfi_fld_inp_leng)||'" SELTYP="'||rcd_field.sfi_fld_sel_type||'"/>'));
            if var_action != '*CRTPET' then
               open csr_classification;
               loop
                  fetch csr_classification into rcd_classification;
                  if csr_classification%notfound then
                     exit;
                  end if;
                  if rcd_classification.sva_val_code is null then
                     pipe row(pts_xml_object('<VALUE VALCDE="'||to_char(rcd_classification.pcl_val_code)||'" VALTXT="'||pts_to_xml(rcd_classification.pcl_val_text)||'"/>'));
                  else
                     pipe row(pts_xml_object('<VALUE VALCDE="'||to_char(rcd_classification.pcl_val_code)||'" VALTXT="'||pts_to_xml('('||to_char(rcd_classification.sva_val_code)||') '||rcd_classification.sva_val_text)||'"/>'));
                  end if;
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_PET_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      var_confirm varchar2(32);
      rcd_pts_pet_definition pts_pet_definition%rowtype;
      rcd_pts_pet_classification pts_pet_classification%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check is
         select t01.*
           from pts_pet_definition t01
          where t01.pde_pet_code = rcd_pts_pet_definition.pde_pet_code;
      rcd_check csr_check%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*PET_DEF',4)) t01
          where t01.val_code = rcd_pts_pet_definition.pde_pet_status;
      rcd_sta_code csr_sta_code%rowtype;

      cursor csr_pet_type is
         select t01.*
           from table(pts_app.pts_gen_function.list_pet_type) t01
          where t01.pty_code = rcd_pts_pet_definition.pde_pet_type;
      rcd_pet_type csr_pet_type%rowtype;

      cursor csr_hou_code is
         select t01.*
           from pts_hou_definition t01
          where t01.hde_hou_code = rcd_pts_pet_definition.pde_hou_code;
      rcd_hou_code csr_hou_code%rowtype;

      cursor csr_del_note is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*PET_DEF',5)) t01
          where t01.val_code = rcd_pts_pet_definition.pde_del_notifier;
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
      if var_action != '*DEFPET' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_pet_definition.pde_pet_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PETCODE'));
      rcd_pts_pet_definition.pde_pet_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PETSTAT'));
      rcd_pts_pet_definition.pde_upd_user := upper(par_user);
      rcd_pts_pet_definition.pde_upd_date := sysdate;
      rcd_pts_pet_definition.pde_pet_name := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@PETNAME'));
      rcd_pts_pet_definition.pde_pet_type := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PETTYPE'));
      rcd_pts_pet_definition.pde_hou_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@HOUCODE'));
      rcd_pts_pet_definition.pde_birth_year := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@BTHYEAR'));
      rcd_pts_pet_definition.pde_del_notifier := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@DELNOTE'));
      rcd_pts_pet_definition.pde_feed_comment := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@FEDCMNT'));
      rcd_pts_pet_definition.pde_health_comment := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@HTHCMNT'));
      if rcd_pts_pet_definition.pde_pet_code is null and not(xslProcessor.valueOf(obj_pts_request,'@PETCODE') = '*NEW') then
         pts_gen_function.add_mesg_data('Pet code ('||xslProcessor.valueOf(obj_pts_request,'@PETCODE')||') must be a number');
      end if;
      if rcd_pts_pet_definition.pde_pet_status is null and not(xslProcessor.valueOf(obj_pts_request,'@PETSTAT') is null) then
         pts_gen_function.add_mesg_data('Pet status ('||xslProcessor.valueOf(obj_pts_request,'@PETSTAT')||') must be a number');
      end if;
      if rcd_pts_pet_definition.pde_pet_type is null and not(xslProcessor.valueOf(obj_pts_request,'@PETTYPE') is null) then
         pts_gen_function.add_mesg_data('Pet type ('||xslProcessor.valueOf(obj_pts_request,'@PETTYPE')||') must be a number');
      end if;
      if rcd_pts_pet_definition.pde_hou_code is null and not(xslProcessor.valueOf(obj_pts_request,'@HOUCODE') is null) then
         pts_gen_function.add_mesg_data('Household code ('||xslProcessor.valueOf(obj_pts_request,'@HOUCODE')||') must be a number');
      end if;
      if rcd_pts_pet_definition.pde_birth_year is null and not(xslProcessor.valueOf(obj_pts_request,'@BTHYEAR') is null) then
         pts_gen_function.add_mesg_data('Birth year ('||xslProcessor.valueOf(obj_pts_request,'@BTHYEAR')||') must be a number');
      end if;
      if rcd_pts_pet_definition.pde_del_notifier is null and not(xslProcessor.valueOf(obj_pts_request,'@DELNOTE') is null) then
         pts_gen_function.add_mesg_data('Delete notifier ('||xslProcessor.valueOf(obj_pts_request,'@DELNOTE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_pet_definition.pde_pet_name is null then
         pts_gen_function.add_mesg_data('Pet name must be supplied');
      end if;
      if rcd_pts_pet_definition.pde_pet_status is null then
         pts_gen_function.add_mesg_data('Pet status must be supplied');
      end if;
      if rcd_pts_pet_definition.pde_upd_user is null then
         pts_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      open csr_sta_code;
      fetch csr_sta_code into rcd_sta_code;
      if csr_sta_code%notfound then
         pts_gen_function.add_mesg_data('Pet status ('||to_char(rcd_pts_pet_definition.pde_pet_status)||') does not exist');
      end if;
      close csr_sta_code;
      if not(rcd_pts_pet_definition.pde_pet_type is null) then
         open csr_pet_type;
         fetch csr_pet_type into rcd_pet_type;
         if csr_pet_type%notfound then
            pts_gen_function.add_mesg_data('Pet type ('||to_char(rcd_pts_pet_definition.pde_pet_type)||') does not exist');
         else
            if rcd_pet_type.pty_status != 1 then
               pts_gen_function.add_mesg_data('Pet type ('||to_char(rcd_pts_pet_definition.pde_pet_type)||') is not active');
            end if;
         end if;
         close csr_pet_type;
      end if;
      if not(rcd_pts_pet_definition.pde_hou_code is null) then
         open csr_hou_code;
         fetch csr_hou_code into rcd_hou_code;
         if csr_hou_code%notfound then
            pts_gen_function.add_mesg_data('Household code ('||to_char(rcd_pts_pet_definition.pde_hou_code)||') does not exist');
         end if;
         close csr_hou_code;
      end if;
      if not(rcd_pts_pet_definition.pde_del_notifier is null) then
         open csr_del_note;
         fetch csr_del_note into rcd_del_note;
         if csr_del_note%notfound then
            pts_gen_function.add_mesg_data('Delete notifier ('||to_char(rcd_pts_pet_definition.pde_del_notifier)||') does not exist');
         end if;
         close csr_del_note;
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and process the pet definition
      /*-*/
      open csr_check;
      fetch csr_check into rcd_check;
      if csr_check%found then
         var_confirm := 'updated';
         update pts_pet_definition
            set pde_pet_status = rcd_pts_pet_definition.pde_pet_status,
                pde_upd_user = rcd_pts_pet_definition.pde_upd_user,
                pde_upd_date = rcd_pts_pet_definition.pde_upd_date,
                pde_pet_name = rcd_pts_pet_definition.pde_pet_name,
                pde_pet_type = rcd_pts_pet_definition.pde_pet_type,
                pde_hou_code = rcd_pts_pet_definition.pde_hou_code,
                pde_birth_year = rcd_pts_pet_definition.pde_birth_year,
                pde_del_notifier = rcd_pts_pet_definition.pde_del_notifier,
                pde_feed_comment = rcd_pts_pet_definition.pde_feed_comment,
                pde_health_comment = rcd_pts_pet_definition.pde_health_comment
          where pde_pet_code = rcd_pts_pet_definition.pde_pet_code;
         delete from pts_pet_classification where pcl_pet_code = rcd_pts_pet_definition.pde_pet_code;
      else
         var_confirm := 'created';
         select pts_pet_sequence.nextval into rcd_pts_pet_definition.pde_pet_code from dual;
         rcd_pts_pet_definition.pde_del_notifier := null;
         rcd_pts_pet_definition.pde_test_date := null;
         insert into pts_pet_definition values rcd_pts_pet_definition;
      end if;
      close csr_check;

      /*-*/
      /* Retrieve and insert the classification data
      /*-*/
      rcd_pts_pet_classification.pcl_pet_code := rcd_pts_pet_definition.pde_pet_code;
      obj_cla_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/CLA_DATA');
      for idx in 0..xmlDom.getLength(obj_cla_list)-1 loop
         obj_cla_node := xmlDom.item(obj_cla_list,idx);
         rcd_pts_pet_classification.pcl_tab_code := pts_from_xml(xslProcessor.valueOf(obj_cla_node,'@TABCDE'));
         rcd_pts_pet_classification.pcl_fld_code := pts_to_number(xslProcessor.valueOf(obj_cla_node,'@FLDCDE'));
         obj_val_list := xslProcessor.selectNodes(obj_cla_node,'VAL_DATA');
         for idy in 0..xmlDom.getLength(obj_val_list)-1 loop
            obj_val_node := xmlDom.item(obj_val_list,idy);
            rcd_pts_pet_classification.pcl_val_code := pts_to_number(xslProcessor.valueOf(obj_val_node,'@VALCDE'));
            rcd_pts_pet_classification.pcl_val_text := pts_from_xml(xslProcessor.valueOf(obj_val_node,'@VALTXT'));
            insert into pts_pet_classification values rcd_pts_pet_classification;
         end loop;
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
      pts_gen_function.set_cfrm_data('Pet ('||to_char(rcd_pts_pet_definition.pde_pet_code)||') successfully '||var_confirm);

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

         /* Raise an exception to the calling application
         /*-*/
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_PET_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

end pts_pet_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_pet_function for pts_app.pts_pet_function;
grant execute on pts_app.pts_pet_function to public;

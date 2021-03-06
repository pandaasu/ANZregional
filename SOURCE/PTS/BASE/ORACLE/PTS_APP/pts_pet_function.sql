/******************/
/* Package Header */
/******************/
create or replace
package         pts_pet_function as

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
    2011/11   Peter Tylee    Updated to support validation tests
    2014/08   Peter Tylee    Added pet reporting

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function retrieve_list return pts_xml_type pipelined;
   function retrieve_list_validation return pts_xml_type pipelined;
   function retrieve_prompt return pts_xml_type pipelined;
   function retrieve_data return pts_xml_type pipelined;
   procedure update_data(par_user in varchar2);
   function retrieve_restore return pts_xml_type pipelined;
   procedure update_restore(par_user in varchar2);
   function retrieve_report_fields return pts_xml_type pipelined;
   function report_pet(par_geo_zone in number) return pts_xls_type pipelined;

end pts_pet_function;
 

/

/****************/
/* Package Body */
/****************/
create or replace
package body         pts_pet_function as

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
   /* This procedure performs the retrieve list routine */
   /*****************************************************/
   function retrieve_list_validation return pts_xml_type pipelined is

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
            and exists (
                  select  1
                  from    pts_val_pet p
                          inner join pts_val_status s on p.vpe_sta_code = s.vst_sta_code
                  where   p.vpe_pet_code = t01.pde_pet_code
                          and s.vst_val_flg = 1
                )
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_PET_FUNCTION - RETRIEVE_LIST_VALIDATION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_list_validation;

   /*******************************************************/
   /* This procedure performs the retrieve prompt routine */
   /*******************************************************/
   function retrieve_prompt return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_pet_type is
         select t01.*
           from table(pts_app.pts_gen_function.list_pet_type) t01
          where t01.pty_status = 1;
      rcd_pet_type csr_pet_type%rowtype;

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
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*PMTPET' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the pet type XML
      /*-*/
      pipe row(pts_xml_object('<PET_TYPE VALCDE="" VALTXT="** Create Pet Type **"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_PET_FUNCTION - RETRIEVE_PROMPT - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_prompt;

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
      var_pet_type varchar2(32);
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
           from table(pts_app.pts_gen_function.list_class('*PET_DEF',4)) t01
          where var_action = '*UPDPET' or val_code = 1;
      rcd_sta_code csr_sta_code%rowtype;

      cursor csr_del_note is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*PET_DEF',5)) t01;
      rcd_del_note csr_del_note%rowtype;

      cursor csr_pet_type is
         select t01.*
           from table(pts_app.pts_gen_function.list_pet_type) t01
          where t01.pty_code = rcd_retrieve.pde_pet_type;
      rcd_pet_type csr_pet_type%rowtype;

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
                t01.sfi_fld_sel_type,
                t01.sfi_fld_val_type
           from pts_sys_field t01,
                (select t01.psf_tab_code,
                        t01.psf_fld_code
                   from pts_pty_sys_field t01
                  where t01.psf_pet_type = rcd_retrieve.pde_pet_type) t02
          where t01.sfi_tab_code = t02.psf_tab_code
            and t01.sfi_fld_code = t02.psf_fld_code
            and t01.sfi_tab_code = rcd_table.sta_tab_code
            and t01.sfi_fld_status = '1'
          order by t01.sfi_fld_dsp_seqn asc,
                   t01.sfi_fld_text asc;
      rcd_field csr_field%rowtype;

      cursor csr_classification is
         select t01.pcl_val_code,
                t01.pcl_val_text,
                t02.sva_val_code,
                t02.sva_val_text
           from pts_pet_classification t01,
                (select t01.*
                   from pts_sys_value t01
                  where t01.sva_tab_code = rcd_table.sta_tab_code
                    and t01.sva_fld_code = rcd_field.sfi_fld_code
                    and (rcd_field.sfi_fld_val_type = '*ALL' or
                         t01.sva_val_code in (select psv_val_code
                                                from pts_pty_sys_value
                                               where psv_pet_type = rcd_retrieve.pde_pet_type
                                                 and psv_tab_code = rcd_table.sta_tab_code
                                                 and psv_fld_code = rcd_field.sfi_fld_code))) t02
          where t01.pcl_tab_code = t02.sva_tab_code
            and t01.pcl_fld_code = t02.sva_fld_code
            and t01.pcl_val_code = t02.sva_val_code
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
      var_pet_type := xslProcessor.valueOf(obj_pts_request,'@PETTYPE');
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
      else
         rcd_retrieve.pde_pet_type := pts_to_number(var_pet_type);
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
      /* Pipe the delete notifier XML
      /*-*/
      pipe row(pts_xml_object('<DEL_NOTE VALCDE="" VALTXT="** NO DELETE NOTIFIER **"/>'));
      if var_action = '*UPDPET' then
         open csr_del_note;
         loop
            fetch csr_del_note into rcd_del_note;
            if csr_del_note%notfound then
               exit;
            end if;
            pipe row(pts_xml_object('<DEL_NOTE VALCDE="'||to_char(rcd_del_note.val_code)||'" VALTXT="'||pts_to_xml(rcd_del_note.val_text)||'"/>'));
         end loop;
         close csr_del_note;
      end if;

      /*-*/
      /* Pipe the pet type text
      /*-*/
      open csr_pet_type;
      fetch csr_pet_type into rcd_pet_type;
      if csr_pet_type%notfound then
         rcd_pet_type.pty_text := '*UNKNOWN';
      end if;
      close csr_pet_type;

      /*-*/
      /* Pipe the pet XML
      /*-*/
      if var_action = '*UPDPET' then
         var_output := '<PET PETCODE="'||to_char(rcd_retrieve.pde_pet_code)||'"';
         var_output := var_output||' PETSTAT="'||to_char(rcd_retrieve.pde_pet_status)||'"';
         var_output := var_output||' PETNAME="'||pts_to_xml(rcd_retrieve.pde_pet_name)||'"';
         var_output := var_output||' PETTYPE="'||to_char(rcd_retrieve.pde_pet_type)||'"';
         var_output := var_output||' TYPTEXT="'||pts_to_xml(rcd_pet_type.pty_text)||'"';
         var_output := var_output||' HOUCODE="'||to_char(rcd_retrieve.pde_hou_code)||'"';
         var_output := var_output||' HOUTEXT="'||pts_to_xml(rcd_retrieve.hou_text)||'"';
         var_output := var_output||' BTHYEAR="'||to_char(rcd_retrieve.pde_birth_year)||'"';
         var_output := var_output||' DELNOTE="'||to_char(rcd_retrieve.pde_del_notifier)||'"';
         var_output := var_output||' FEDCMNT="'||pts_to_xml(rcd_retrieve.pde_feed_comment)||'"';
         var_output := var_output||' HTHCMNT="'||pts_to_xml(rcd_retrieve.pde_health_comment)||'"';
         var_output := var_output||' CRTDATE="'||to_char(rcd_retrieve.pde_crt_date,'DD/MM/YYYY')||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYPET' then
         var_output := '<PET PETCODE="*NEW"';
         var_output := var_output||' PETSTAT="'||to_char(rcd_retrieve.pde_pet_status)||'"';
         var_output := var_output||' PETNAME="'||pts_to_xml(rcd_retrieve.pde_pet_name)||'"';
         var_output := var_output||' PETTYPE="'||to_char(rcd_retrieve.pde_pet_type)||'"';
         var_output := var_output||' TYPTEXT="'||pts_to_xml(rcd_pet_type.pty_text)||'"';
         var_output := var_output||' HOUCODE="'||to_char(rcd_retrieve.pde_hou_code)||'"';
         var_output := var_output||' HOUTEXT="'||pts_to_xml(rcd_retrieve.hou_text)||'"';
         var_output := var_output||' BTHYEAR="'||to_char(rcd_retrieve.pde_birth_year)||'"';
         var_output := var_output||' DELNOTE="'||to_char(rcd_retrieve.pde_del_notifier)||'"';
         var_output := var_output||' FEDCMNT="'||pts_to_xml(rcd_retrieve.pde_feed_comment)||'"';
         var_output := var_output||' HTHCMNT="'||pts_to_xml(rcd_retrieve.pde_health_comment)||'"';
         var_output := var_output||' CRTDATE="'||to_char(sysdate,'DD/MM/YYYY')||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CRTPET' then
         var_output := '<PET PETCODE="*NEW"';
         var_output := var_output||' PETSTAT="1"';
         var_output := var_output||' PETNAME=""';
         var_output := var_output||' PETTYPE="'||to_char(rcd_retrieve.pde_pet_type)||'"';
         var_output := var_output||' TYPTEXT="'||pts_to_xml(rcd_pet_type.pty_text)||'"';
         var_output := var_output||' HOUCODE=""';
         var_output := var_output||' HOUTEXT="** DATA ENTRY **"';
         var_output := var_output||' BTHYEAR=""';
         var_output := var_output||' DELNOTE=""';
         var_output := var_output||' FEDCMNT=""';
         var_output := var_output||' HTHCMNT=""';
         var_output := var_output||' CRTDATE="'||to_char(sysdate,'DD/MM/YYYY')||'"/>';
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
      /* Pipe the validation status
      /*-*/
      for val_status in (
        select    vst_sta_code,
                  vst_sta_text
        from      pts_val_status
        order by  vst_sta_seq asc      
      ) loop
        pipe row(pts_xml_object('<VAL_STATUS VALCDE="'||pts_to_xml(val_status.vst_sta_code)||'" VALTXT="'||pts_to_xml(val_status.vst_sta_text)||'"/>'));
      end loop;

      /*-*/
      /* Pipe the validation type data
      /*-*/
      for val_type in (
          select    t.vty_val_type,
                    t.vty_typ_text,
                    nvl(s.vst_sta_seq-1,0) as status_index,
                    case
                      when not exists ( --No validation allocated
                        select  1
                        from    pts_pet_definition pde
                                inner join pts_val_allocation val on pde.pde_val_code = val.val_val_code
                                inner join pts_tes_definition tde on tde.tde_tes_code = val.val_tes_code
                        where   pde.pde_pet_code = pts_to_number(var_pet_code)
                                and tde.tde_val_type = t.vty_val_type
                      ) and exists ( --And status requires validation
                        select  1
                        from    pts_val_pet p
                                inner join pts_val_status s on p.vpe_sta_code = s.vst_sta_code
                        where   p.vpe_pet_code = pts_to_number(var_pet_code)
                                and p.vpe_val_type = t.vty_val_type
                                and s.vst_val_flg = 1
                      ) then '*NOT ALLOCATED'
                      when not exists ( --No validation required
                        select  1
                        from    pts_val_pet p
                                inner join pts_val_status s on p.vpe_sta_code = s.vst_sta_code
                        where   p.vpe_pet_code = pts_to_number(var_pet_code)
                                and p.vpe_val_type = t.vty_val_type
                                and s.vst_val_flg = 1
                      ) then ''
                      else to_char(( -- Responses recorded
                        select  count(1)
                        from    pts_pet_definition p
                                inner join pts_val_test vt on p.pde_val_code = vt.vte_val_code
                                inner join pts_tes_definition td on td.tde_tes_code = vt.vte_tes_code
                                inner join pts_tes_response r on r.tre_tes_code = td.tde_tes_code
                        where   p.pde_pet_code = pts_to_number(var_pet_code)
                                and td.tde_val_type = t.vty_val_type
                      )) ||'/'|| to_char(( -- Responses total
                        select  count(1)
                        from    pts_pet_definition p
                                inner join pts_val_test vt on p.pde_val_code = vt.vte_val_code
                                inner join pts_tes_definition td on td.tde_tes_code = vt.vte_tes_code
                                inner join pts_tes_question q on q.tqu_tes_code = td.tde_tes_code
                        where   p.pde_pet_code = pts_to_number(var_pet_code)
                                and td.tde_val_type = t.vty_val_type
                      ))
                    end as progress
          from      pts_val_type t
                    left outer join pts_val_pet p on (
                      t.vty_val_type = p.vpe_val_type
                      and p.vpe_pet_code = pts_to_number(var_pet_code)
                    )
                    left outer join pts_val_status s on p.vpe_sta_code = s.vst_sta_code
          order by  t.vty_typ_seq asc
      ) loop
        pipe row(pts_xml_object('<VAL_TYPE VALCDE="'||pts_to_xml(val_type.vty_val_type)||'" VALTXT="'||pts_to_xml(val_type.vty_typ_text)||'" VALSEL="'||pts_to_xml(val_type.status_index)||'" VALPROG="'||pts_to_xml(val_type.progress)||'"/>'));
      end loop;
      
      /*-*/
      /* Pipe the history data
      /*-*/
      for val_history in (
          select    to_char(h.vhi_date,'DD/MM/YYYY') as vhi_date,
                    t.vty_typ_text,
                    r.vre_vre_text
          from      pts_val_history h
                    inner join pts_val_reason r on h.vhi_vre_code = r.vre_vre_code
                    inner join pts_val_type t on h.vhi_val_type = t.vty_val_type
          where     h.vhi_pet_code = pts_to_number(var_pet_code)
          order by  h.vhi_date desc,
                    t.vty_typ_text asc
      ) loop
        pipe row(pts_xml_object('<VAL_HIS VALDAT="'||pts_to_xml(val_history.vhi_date)||'" VALTYP="'||pts_to_xml(val_history.vty_typ_text)||'" VALREA="'||pts_to_xml(val_history.vre_vre_text)||'"/>'));
      end loop;
      
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
      obj_v_list xmlDom.domNodeList;
      obj_v_node xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_locked boolean;
      rcd_pts_pet_definition pts_pet_definition%rowtype;
      rcd_pts_pet_classification pts_pet_classification%rowtype;
      rcd_pts_val_pet pts_val_pet%rowtype;
      var_count_pet number;
      var_count_hou number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_pet_definition t01
          where t01.pde_pet_code = rcd_pts_pet_definition.pde_pet_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;
      
      cursor csr_retrieve_hou is
         select t01.*
           from pts_hou_definition t01
          where t01.hde_hou_code = rcd_pts_pet_definition.pde_hou_code
            for update nowait;
      rcd_retrieve_hou csr_retrieve_hou%rowtype;

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
      
      cursor csr_pet_val is
        select    count(1) as total
        from      pts_pet_definition p
                  inner join pts_val_test vt on p.pde_val_code = vt.vte_val_code
                  inner join pts_tes_definition t on vt.vte_tes_code = t.tde_tes_code
                  inner join pts_val_pet vp on (
                    p.pde_pet_code = vp.vpe_pet_code
                    and t.tde_val_type = vp.vpe_val_type
                  )
                  inner join pts_val_status s on vp.vpe_sta_code = s.vst_sta_code 
        where     p.pde_pet_code = rcd_pts_pet_definition.pde_pet_code
                  and s.vst_val_flg = 1 --Still requires validation for this type
                  and exists ( --Is allocated to that test
                    select  1
                    from    pts_val_allocation a
                    where   a.val_val_code = p.pde_val_code
                            and a.val_pet_code = p.pde_pet_code
                  );
      rcd_pet_val csr_pet_val%rowtype;
      
      cursor csr_hou_val is
        select    count(1) as total
        from      pts_pet_definition p
                  inner join pts_val_test vt on p.pde_val_code = vt.vte_val_code
                  inner join pts_tes_definition t on vt.vte_tes_code = t.tde_tes_code
                  inner join pts_val_pet vp on (
                    p.pde_pet_code = vp.vpe_pet_code
                    and t.tde_val_type = vp.vpe_val_type
                  )
                  inner join pts_val_status s on vp.vpe_sta_code = s.vst_sta_code 
        where     p.pde_hou_code in (
                    select  pde_hou_code
                    from    pts_pet_definition
                    where   pde_pet_code = rcd_pts_pet_definition.pde_pet_code
                  )
                  and p.pde_pet_code <> rcd_pts_pet_definition.pde_pet_code
                  and s.vst_val_flg = 1 --Still requires validation for this type
                  and exists ( --Is allocated to that test
                    select  1
                    from    pts_val_allocation a
                    where   a.val_val_code = p.pde_val_code
                            and a.val_pet_code = p.pde_pet_code
                  );
      rcd_hou_val csr_hou_val%rowtype;
      
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
      rcd_pts_pet_definition.pde_crt_date := sysdate;
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
      /* Retrieve and lock the existing pet when required
      /*-*/
      var_locked := false;
      begin
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_locked := true;
         end if;
         close csr_retrieve;
      exception
         when others then
            pts_gen_function.add_mesg_data('Pet ('||to_char(rcd_pts_pet_definition.pde_pet_code)||') is currently locked');
      end;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;
      
      begin
         open csr_retrieve_hou;
         fetch csr_retrieve_hou into rcd_retrieve_hou;
         close csr_retrieve_hou;
      exception
         when others then
            pts_gen_function.add_mesg_data('Household ('||to_char(rcd_pts_pet_definition.pde_hou_code)||') is currently locked');
      end;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
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
      if var_locked = true then
         if rcd_retrieve.pde_pet_status = 1 and (rcd_pts_pet_definition.pde_pet_status != 1 and rcd_pts_pet_definition.pde_pet_status != 3 and rcd_pts_pet_definition.pde_pet_status != 9) then
            pts_gen_function.add_mesg_data('Current status is Available - new status must be Available, Suspended or Deleted');
         end if;
         if rcd_retrieve.pde_pet_status = 2 and (rcd_pts_pet_definition.pde_pet_status != 2 and rcd_pts_pet_definition.pde_pet_status != 5) then
            pts_gen_function.add_mesg_data('Current status is On Test - new status must be On Test or Suspended On Test');
         end if;
         if rcd_retrieve.pde_pet_status = 3 and (rcd_pts_pet_definition.pde_pet_status != 1 and rcd_pts_pet_definition.pde_pet_status != 3 and rcd_pts_pet_definition.pde_pet_status != 9) then
            pts_gen_function.add_mesg_data('Current status is Suspended - new status must be Available, Suspended or Deleted');
         end if;
         if rcd_retrieve.pde_pet_status = 5 and (rcd_pts_pet_definition.pde_pet_status != 2 and rcd_pts_pet_definition.pde_pet_status != 5) then
            pts_gen_function.add_mesg_data('Current status is Suspended On Test - new status must be On Test or Suspended On Test');
         end if;
         if rcd_retrieve.pde_pet_status = 9 then
            pts_gen_function.add_mesg_data('Current status is Deleted - update not allowed');
         end if;
         if rcd_pts_pet_definition.pde_pet_status = 9 then
            if rcd_pts_pet_definition.pde_del_notifier is null then
                pts_gen_function.add_mesg_data('Pet status is Deleted and no delete notifier defined');
            end if;
         else
            if not(rcd_pts_pet_definition.pde_del_notifier is null) then
                pts_gen_function.add_mesg_data('Delete notifier must only be selected for status Deleted');
            end if;
         end if;
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Process the pet definition
      /*-*/
      if var_locked = true then

         /*-*/
         /* Update the pet
         /*-*/
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

         /*-*/
         /* Create the pet
         /*-*/
         var_confirm := 'created';
         select pts_pet_sequence.nextval into rcd_pts_pet_definition.pde_pet_code from dual;
         rcd_pts_pet_definition.pde_del_notifier := null;
         rcd_pts_pet_definition.pde_test_date := null;
         insert into pts_pet_definition values rcd_pts_pet_definition;

      end if;

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
      /* Preserve the pet and houshold validation status
      /*-*/
      open csr_pet_val;
      fetch csr_pet_val into rcd_pet_val;
      close csr_pet_val;
      var_count_pet := rcd_pet_val.total;
      
      open csr_hou_val;
      fetch csr_hou_val into rcd_hou_val;
      close csr_hou_val;
      var_count_hou := rcd_hou_val.total;

      /*-*/
      /* Retrieve and insert the validation status data
      /*-*/
      rcd_pts_val_pet.vpe_pet_code := rcd_pts_pet_definition.pde_pet_code;
      obj_v_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/V_DATA');
      for idx in 0..xmlDom.getLength(obj_v_list)-1 loop
         obj_v_node := xmlDom.item(obj_v_list,idx);
         rcd_pts_val_pet.vpe_val_type := pts_to_number(xslProcessor.valueOf(obj_v_node,'@VALCDE'));
         rcd_pts_val_pet.vpe_sta_code := pts_to_number(xslProcessor.valueOf(obj_v_node,'@VALSEL'));
         merge into pts_val_pet p
         using (
            select  rcd_pts_val_pet.vpe_pet_code vpe_pet_code,
                    rcd_pts_val_pet.vpe_val_type vpe_val_type,
                    rcd_pts_val_pet.vpe_sta_code vpe_sta_code
            from    dual
         ) x on (
            p.vpe_pet_code = x.vpe_pet_code
            and p.vpe_val_type = x.vpe_val_type
         )
         when matched then
            update
            set     p.vpe_sta_code = x.vpe_sta_code
            where   p.vpe_sta_code <> x.vpe_sta_code
         when not matched then
            insert
            (
              vpe_pet_code,
              vpe_val_type,
              vpe_sta_code
            )
            values
            (
              x.vpe_pet_code,
              x.vpe_val_type,
              x.vpe_sta_code
            );
      end loop;
      
      /*-*/
      /* Check the number of allocated tests that still require validation
      /*-*/
      open csr_pet_val;
      fetch csr_pet_val into rcd_pet_val;
      close csr_pet_val;
      
      open csr_hou_val;
      fetch csr_hou_val into rcd_hou_val;
      close csr_hou_val;

      /*-*/
      /* Release from validation test if all validation requirements for the current validation are complete
      /*-*/
      if var_count_pet > 0 and rcd_pet_val.total = 0 then
        update  pts_pet_definition
        set     pde_val_code = null,
                pde_pet_status = decode(pde_pet_status,2,1,5,3,1)
        where   pde_pet_code = rcd_pts_pet_definition.pde_pet_code;
      end if;
      if var_count_hou > 0 and rcd_hou_val.total = 0 then
        update  pts_hou_definition
        set     hde_hou_status = decode(hde_hou_status,2,1,5,3,1),
                hde_val_code = null
        where   hde_hou_code in (
                  select  pde_hou_code
                  from    pts_pet_definition
                  where   pde_pet_code = rcd_pts_pet_definition.pde_pet_code
                );
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

   /********************************************************/
   /* This procedure performs the retrieve restore routine */
   /********************************************************/
   function retrieve_restore return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_pet_code number;
      var_found boolean;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_pet_definition t01
          where t01.pde_pet_code = var_pet_code;
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
      if var_action != '*RTVRES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_pet_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PETCODE'));
      if var_pet_code is null then
         pts_gen_function.add_mesg_data('Pet code ('||xslProcessor.valueOf(obj_pts_request,'@PETCODE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the pet
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         pts_gen_function.add_mesg_data('Pet ('||to_char(var_pet_code)||') does not exist');
      end if;
      if rcd_retrieve.pde_pet_status != 9 then
         pts_gen_function.add_mesg_data('Pet ('||to_char(var_pet_code)||') must be status Deleted');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the pet xml
      /*-*/
      var_output := '<PET PETCODE="'||to_char(rcd_retrieve.pde_pet_code)||'"';
      var_output := var_output||' PETNAME="'||pts_to_xml(rcd_retrieve.pde_pet_name)||'"/>';
      pipe row(pts_xml_object(var_output));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_PET_FUNCTION - RETRIEVE_RESTORE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_restore;

   /******************************************************/
   /* This procedure performs the update restore routine */
   /******************************************************/
   procedure update_restore(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_pet_code number;
      var_found boolean;
      rcd_pts_pet_definition pts_pet_definition%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_pet_definition t01
          where t01.pde_pet_code = rcd_pts_pet_definition.pde_pet_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

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
      if var_action != '*UPDRES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_pet_definition.pde_pet_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PETCODE'));
      rcd_pts_pet_definition.pde_upd_user := upper(par_user);
      rcd_pts_pet_definition.pde_upd_date := sysdate;
      if rcd_pts_pet_definition.pde_pet_code is null then
         pts_gen_function.add_mesg_data('Pet code ('||xslProcessor.valueOf(obj_pts_request,'@PETCODE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the existing pet
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
            pts_gen_function.add_mesg_data('Pet ('||to_char(rcd_pts_pet_definition.pde_pet_code)||') is currently locked');
            return;
      end;
      if var_found = false then
         pts_gen_function.add_mesg_data('Pet ('||to_char(rcd_pts_pet_definition.pde_pet_code)||') does not exist');
      end if;
      if rcd_retrieve.pde_pet_status != 9 then
         pts_gen_function.add_mesg_data('Pet (' || to_char(rcd_pts_pet_definition.pde_pet_code) || ') must be status Deleted - restore not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Update the pet definition
      /*-*/
      update pts_pet_definition
         set pde_upd_user = rcd_pts_pet_definition.pde_upd_user,
             pde_upd_date = rcd_pts_pet_definition.pde_upd_date,
             pde_pet_status = 1
       where pde_pet_code = rcd_pts_pet_definition.pde_pet_code;

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
      pts_gen_function.set_cfrm_data('Pet ('||to_char(rcd_pts_pet_definition.pde_pet_code)||') successfully restored');

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_PET_FUNCTION - UPDATE_RESTORE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_restore;
   
   
   /**************************************************************/
   /* This procedure performs the retrieve report fields routine */
   /**************************************************************/
   function retrieve_report_fields return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_geo_zone number;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = 40
            and t01.gzo_geo_zone = var_geo_zone;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_field is
         select t01.sfi_tab_code,
                t01.sfi_fld_code,
                t01.sfi_fld_text
           from pts_sys_field t01
          where (
                  (
                    t01.sfi_tab_code = '*PET_DEF'
                    and t01.sfi_fld_code = 6 --Pet age
                  )
                  or (
                    t01.sfi_tab_code = '*PET_CLA'
                    and t01.sfi_fld_sel_type in ('*OPT_SINGLE_LIST','*MAN_SINGLE_LIST')
                  )
                )
                and t01.sfi_fld_status = '1'
          order by t01.sfi_tab_code desc,
                   t01.sfi_fld_dsp_seqn asc,
                   t01.sfi_fld_text asc;
      rcd_field csr_field%rowtype;

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
      if var_action != '*GETFLD' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_geo_zone := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@GEOCDE'));
      if var_geo_zone is null then
         pts_gen_function.add_mesg_data('Area code ('||xslProcessor.valueOf(obj_pts_request,'@GEOCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the test
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         pts_gen_function.add_mesg_data('Area ('||to_char(var_geo_zone)||') does not exist');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test xml
      /*-*/
      pipe row(pts_xml_object('<AREA TEXT="('||to_char(var_geo_zone)||') '||pts_to_xml(rcd_retrieve.gzo_zon_text)||'"/>'));

      /*-*/
      /* Pipe the pet classification XML
      /*-*/
      open csr_field;
      loop
         fetch csr_field into rcd_field;
         if csr_field%notfound then
         exit;
         end if;
         pipe row(pts_xml_object('<FIELD TABCDE="'||rcd_field.sfi_tab_code||'" FLDCDE="'||to_char(rcd_field.sfi_fld_code)||'" FLDTXT="'||pts_to_xml(rcd_field.sfi_fld_text)||'"/>'));
      end loop;
      close csr_field;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_PET_FUNCTION - RETRIEVE_REPORT_FIELDS - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_report_fields;

  
  /********************************************************/
   /* This procedure performs the report pet routine      */
   /*******************************************************/
   function report_pet(par_geo_zone in number) return pts_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_geo_zone number;
      var_found boolean;
      var_household boolean;
      var_pet boolean;
      var_output varchar2(4000 char);
      var_query varchar2(32767);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_geo_zone t01
          where t01.gzo_geo_type = 40
            and t01.gzo_geo_zone = var_geo_zone;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_pet is
        select  distinct
                t01.*,
                t04.hde_hou_code,
                decode(t01.pde_pet_status,1,'Available',2,'On Test',3,'Suspended',5,'Suspended On Test') as pet_status_text,
                decode(t04.hde_hou_status,1,'Available',2,'On Test',3,'Suspended',5,'Suspended On Test') as household_status_text,
                decode(t02.pty_pet_type,null,'*UNKNOWN',t02.pty_typ_text) as type_text,
                decode(t03.pcl_val_code,null,'*UNKNOWN',t03.size_text) as size_text,
                nvl(t05.gzo_zon_text,'*UNKNOWN') as gzo_zon_text
        from    pts_pet_definition t01
                left outer join pts_pet_type t02 on t01.pde_pet_type = t02.pty_pet_type
                left outer join (
                  select  t01.pcl_pet_code,
                          t01.pcl_val_code,
                          nvl(t02.sva_val_text,'*UNKNOWN') as size_text
                  from    pts_pet_classification t01
                          left outer join (
                            select  t01.sva_val_code,
                                    t01.sva_val_text
                            from    pts_sys_value t01
                            where   t01.sva_tab_code = '*PET_CLA'
                                    and t01.sva_fld_code = 8
                          ) t02 on t01.pcl_val_code = t02.sva_val_code
                  where   t01.pcl_tab_code = '*PET_CLA'
                          and t01.pcl_fld_code = 8
                ) t03 on t01.pde_pet_code = t03.pcl_pet_code
                inner join pts.pts_hou_definition t04 on t01.pde_hou_code = t04.hde_hou_code
                left outer join pts_geo_zone t05 on t04.hde_geo_zone = t05.gzo_geo_zone
        where   t04.hde_geo_zone = par_geo_zone
                and t01.pde_pet_status in (1,2,3,5)
        order by t01.pde_pet_code asc;
      rcd_pet csr_pet%rowtype;
      
      cursor csr_classification is
         select t01.sfi_tab_code,
                t01.sfi_fld_code,
                t01.sfi_fld_text,
                t01.sfi_fld_text as val_text,
                t01.sfi_fld_sel_type,
                t01.sfi_fld_rul_sql,
                t01.sfi_fld_sel_sql
           from pts_sys_field t01
          where (t01.sfi_tab_code, t01.sfi_fld_code) in (select wtf_tab_code, wtf_fld_code from pts_wor_tab_field)
          order by t01.sfi_fld_text asc;
      
      cursor csr_pet_classification is
         select t01.pcl_tab_code,
                t01.pcl_fld_code,
                 nvl(t02.sva_val_text,t01.pcl_val_text) as val_text
           from pts_pet_classification t01,
                pts_sys_value t02
          where t01.pcl_tab_code = t02.sva_tab_code(+)
            and t01.pcl_fld_code = t02.sva_fld_code(+)
            and t01.pcl_val_code = t02.sva_val_code(+)
            and t01.pcl_pet_code = rcd_pet.pde_pet_code
            and (t01.pcl_tab_code,t01.pcl_fld_code) in (select wtf_tab_code, wtf_fld_code from pts_wor_tab_field)
            and t01.pcl_tab_code = '*PET_CLA'
          order by t01.pcl_tab_code asc,
                   t01.pcl_fld_code asc;
      rcd_pet_classification csr_pet_classification%rowtype;
      
      /*-*/
      /* Local arrays
      /*-*/
      type typ_cary is table of csr_classification%rowtype index by binary_integer;
      tbl_cary typ_cary;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameters
      /*-*/
      var_geo_zone := par_geo_zone;

      /*-*/
      /* Retrieve the area
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         raise_application_error(-20000, 'Area ('||to_char(var_geo_zone)||') does not exist');
      end if;

      /*-*/
      /* Retrieve and load the classification array
      /*-*/
      tbl_cary.delete;
      open csr_classification;
      fetch csr_classification bulk collect into tbl_cary;
      close csr_classification;

      /*-*/
      /* Start the report
      /*-*/
      var_output := '"'||'Pet'||'"';
      var_output := var_output||',"'||'Household'||'"';
      var_output := var_output||',"'||'Area'||'"';
      var_output := var_output||',"'||'Pet Type'||'"';
      var_output := var_output||',"'||'Pet Size'||'"';
      var_output := var_output||',"'||'Pet Status'||'"';
      var_output := var_output||',"'||'Household Status'||'"';
      for idx in 1..tbl_cary.count loop
         var_output := var_output||',"'||tbl_cary(idx).sfi_fld_text||'"';
      end loop;
      pipe row(var_output);
      
      /*-*/
      /* Retrieve the panel
      /*-*/
      open csr_pet;
      loop
         fetch csr_pet into rcd_pet;
         if csr_pet%notfound then
            exit;
         end if;

         /*-*/
         /* Set the classification array text
         /*-*/
         for idx in 1..tbl_cary.count loop
            tbl_cary(idx).val_text := null;
            
            -- If it's a pet logic column get the result
            if tbl_cary(idx).sfi_fld_sel_type = '*LOGIC' then
              var_query := 'select ';
              var_query := var_query || tbl_cary(idx).sfi_fld_sel_sql;
              var_query := var_query || 'from pts.pts_pet_definition p1 inner join pts.pts_hou_definition h1 on p1.pde_hou_code = h1.hde_hou_code ';
              var_query := var_query || 'where p1.pde_pet_code = ' || to_char(rcd_pet.pde_pet_code);
              
              execute immediate var_query
              into tbl_cary(idx).val_text;
            end if;
            
         end loop;
         open csr_pet_classification;
         loop
            fetch csr_pet_classification into rcd_pet_classification;
            if csr_pet_classification%notfound then
               exit;
            end if;
            for idx in 1..tbl_cary.count loop
               if (tbl_cary(idx).sfi_tab_code = rcd_pet_classification.pcl_tab_code and
                   tbl_cary(idx).sfi_fld_code = rcd_pet_classification.pcl_fld_code) then
                  tbl_cary(idx).val_text := rcd_pet_classification.val_text;
                  exit;
               end if;
            end loop;
         end loop;
         close csr_pet_classification;


         var_output := '"'||to_char(rcd_pet.pde_pet_code)||'"';
         var_output := var_output||',"'||to_char(rcd_pet.hde_hou_code)||'"';
         var_output := var_output||',"'||replace(rcd_pet.gzo_zon_text,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_pet.type_text,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_pet.size_text,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_pet.pet_status_text,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_pet.household_status_text,'"','""')||'"';
         
         for idy in 1..tbl_cary.count loop
            var_output := var_output||',"'||replace(tbl_cary(idy).val_text,'"','""')||'"';
         end loop;
         pipe row(var_output);

      end loop;
      close csr_pet;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_PET_FUNCTION - REPORT_PET - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_pet;

end pts_pet_function;

/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_pet_function for pts_app.pts_pet_function;
grant execute on pts_app.pts_pet_function to public;

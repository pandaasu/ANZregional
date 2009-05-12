/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_sam_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_sam_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Sample Function

    This package contain the sample functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function select_list return pts_xml_type pipelined;
   function retrieve_list return pts_xml_type pipelined;
   function retrieve_data return pts_xml_type pipelined;
   procedure update_data(par_user in varchar2);

end pts_sam_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_sam_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***************************************************/
   /* This procedure performs the select list routine */
   /***************************************************/
   function select_list return pts_xml_type pipelined is

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
         select t01.sde_sam_code,
                t01.sde_sam_text,
                nvl((select sva_val_text from pts_sys_value where sva_tab_code = '*SAM_DEF' and sva_fld_code = 9 and sva_val_code = t01.sde_sam_status),'*UNKNOWN') as sde_sam_status
           from pts_sam_definition t01
          where t01.sde_sam_code in (select sel_code from table(pts_app.pts_gen_function.get_list_data('*SAMPLE',null)))
            and t01.sde_sam_code > (select sel_code from table(pts_app.pts_gen_function.get_list_from))
            and t01.sde_sam_status = '1'
          order by t01.sde_sam_code asc;
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
      /* Retrieve the sample list and pipe the results
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
            pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.sde_sam_code)||'" SELTXT="'||pts_to_xml('('||to_char(rcd_list.sde_sam_code)||') '||rcd_list.sde_sam_text)||'" COL1="'||pts_to_xml('('||to_char(rcd_list.sde_sam_code)||') '||rcd_list.sde_sam_text)||'" COL2="'||pts_to_xml(rcd_list.sde_sam_status)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_SAM_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_list;

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
         select t01.sde_sam_code,
                t01.sde_sam_text,
                nvl((select sva_val_text from pts_sys_value where sva_tab_code = '*SAM_DEF' and sva_fld_code = 9 and sva_val_code = t01.sde_sam_status),'*UNKNOWN') as sde_sam_status
           from pts_sam_definition t01
          where t01.sde_sam_code in (select sel_code from table(pts_app.pts_gen_function.get_list_data('*SAMPLE',null)))
            and t01.sde_sam_code > (select sel_code from table(pts_app.pts_gen_function.get_list_from))
          order by t01.sde_sam_code asc;
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
      /* Retrieve the sample list and pipe the results
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
            pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.sde_sam_code)||'" SELTXT="'||pts_to_xml('('||to_char(rcd_list.sde_sam_code)||') '||rcd_list.sde_sam_text)||'" COL1="'||pts_to_xml('('||to_char(rcd_list.sde_sam_code)||') '||rcd_list.sde_sam_text)||'" COL2="'||pts_to_xml(rcd_list.sde_sam_status)||'"/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_SAM_FUNCTION - RETRIEVE_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_sam_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_sam_definition t01
          where t01.sde_sam_code = pts_to_number(var_sam_code);
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*SAM_DEF',9)) t01;
      rcd_sta_code csr_sta_code%rowtype;

      cursor csr_uom_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*SAM_DEF',4)) t01;
      rcd_uom_code csr_uom_code%rowtype;

      cursor csr_pre_locn is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*SAM_DEF',3)) t01;
      rcd_pre_locn csr_pre_locn%rowtype;

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
      var_sam_code := xslProcessor.valueOf(obj_pts_request,'@SAMCODE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDSAM' and var_action != '*CRTSAM' and var_action != '*CPYSAM' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing sample when required
      /*-*/
      if var_action = '*UPDSAM' or var_action = '*CPYSAM' then
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            pts_gen_function.add_mesg_data('Sample ('||var_sam_code||') does not exist');
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
      /* Pipe the unit of measure XML
      /*-*/
      pipe row(pts_xml_object('<UOM_LIST VALCDE="" VALTXT="** NO UNIT OF MEASURE **"/>'));
      open csr_uom_code;
      loop
         fetch csr_uom_code into rcd_uom_code;
         if csr_uom_code%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<UOM_LIST VALCDE="'||to_char(rcd_uom_code.val_code)||'" VALTXT="'||pts_to_xml(rcd_uom_code.val_text)||'"/>'));
      end loop;
      close csr_uom_code;

      /*-*/
      /* Pipe the prepared location XML
      /*-*/
      pipe row(pts_xml_object('<PRE_LIST VALCDE="" VALTXT="** NO PREPARED LOCATION **"/>'));
      open csr_pre_locn;
      loop
         fetch csr_pre_locn into rcd_pre_locn;
         if csr_pre_locn%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<PRE_LIST VALCDE="'||to_char(rcd_pre_locn.val_code)||'" VALTXT="'||pts_to_xml(rcd_pre_locn.val_text)||'"/>'));
      end loop;
      close csr_pre_locn;

      /*-*/
      /* Pipe the sample XML
      /*-*/
      if var_action = '*UPDSAM' then
         var_output := '<SAMPLE SAMCODE="'||to_char(rcd_retrieve.sde_sam_code)||'"';
         var_output := var_output||' SAMTEXT="'||pts_to_xml(rcd_retrieve.sde_sam_text)||'"';
         var_output := var_output||' SAMSTAT="'||to_char(rcd_retrieve.sde_sam_status)||'"';
         var_output := var_output||' UOMCODE="'||to_char(rcd_retrieve.sde_uom_code)||'"';
         var_output := var_output||' UOMSIZE="'||to_char(rcd_retrieve.sde_uom_size)||'"';
         var_output := var_output||' PRELOCN="'||to_char(rcd_retrieve.sde_pre_locn)||'"';
         var_output := var_output||' PREDATE="'||to_char(rcd_retrieve.sde_pre_date,'dd/mm/yyyy')||'"';
         var_output := var_output||' EXTRFNR="'||pts_to_xml(rcd_retrieve.sde_ext_rec_refnr)||'"';
         var_output := var_output||' PLOPCDE="'||pts_to_xml(rcd_retrieve.sde_plop_code)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYSAM' then
         var_output := '<SAMPLE SAMCODE="*NEW"';
         var_output := var_output||' SAMTEXT="'||pts_to_xml(rcd_retrieve.sde_sam_text)||'"';
         var_output := var_output||' SAMSTAT="'||to_char(rcd_retrieve.sde_sam_status)||'"';
         var_output := var_output||' UOMCODE="'||to_char(rcd_retrieve.sde_uom_code)||'"';
         var_output := var_output||' UOMSIZE="'||to_char(rcd_retrieve.sde_uom_size)||'"';
         var_output := var_output||' PRELOCN="'||to_char(rcd_retrieve.sde_pre_locn)||'"';
         var_output := var_output||' PREDATE="'||to_char(rcd_retrieve.sde_pre_date,'dd/mm/yyyy')||'"';
         var_output := var_output||' EXTRFNR="'||pts_to_xml(rcd_retrieve.sde_ext_rec_refnr)||'"';
         var_output := var_output||' PLOPCDE="'||pts_to_xml(rcd_retrieve.sde_plop_code)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CRTSAM' then
         var_output := '<SAMPLE SAMCODE="*NEW"';
         var_output := var_output||' SAMTEXT=""';
         var_output := var_output||' SAMSTAT="1"';
         var_output := var_output||' UOMCODE=""';
         var_output := var_output||' UOMSIZE=""';
         var_output := var_output||' PRELOCN=""';
         var_output := var_output||' PREDATE=""';
         var_output := var_output||' EXTRFNR=""';
         var_output := var_output||' PLOPCDE=""/>';
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_SAM_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      rcd_pts_sam_definition pts_sam_definition%rowtype;
      type typ_dynamic_cursor is ref cursor;
      var_dynamic_cursor typ_dynamic_cursor;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check is
         select t01.*
           from pts_sam_definition t01
          where t01.sde_sam_code = rcd_pts_sam_definition.sde_sam_code;
      rcd_check csr_check%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*SAM_DEF',9)) t01
          where t01.val_code = rcd_pts_sam_definition.sde_sam_status;
      rcd_sta_code csr_sta_code%rowtype;

      cursor csr_uom_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*SAM_DEF',4)) t01
          where t01.val_code = rcd_pts_sam_definition.sde_uom_code;
      rcd_uom_code csr_uom_code%rowtype;

      cursor csr_pre_locn is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*SAM_DEF',3)) t01
          where t01.val_code = rcd_pts_sam_definition.sde_pre_locn;
      rcd_pre_locn csr_pre_locn%rowtype;

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
      if var_action != '*DEFSAM' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_sam_definition.sde_sam_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@SAMCODE'));
      rcd_pts_sam_definition.sde_sam_text := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@SAMTEXT'));
      rcd_pts_sam_definition.sde_sam_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@SAMSTAT'));
      rcd_pts_sam_definition.sde_upd_user := upper(par_user);
      rcd_pts_sam_definition.sde_upd_date := sysdate;
      rcd_pts_sam_definition.sde_uom_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@UOMCODE'));
      rcd_pts_sam_definition.sde_uom_size := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@UOMSIZE'));
      rcd_pts_sam_definition.sde_pre_locn := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PRELOCN'));
      rcd_pts_sam_definition.sde_pre_date := pts_to_date(xslProcessor.valueOf(obj_pts_request,'@PREDATE'),'dd/mm/yyyy');
      rcd_pts_sam_definition.sde_ext_rec_refnr := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@EXTRFNR'));
      rcd_pts_sam_definition.sde_plop_code := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@PLOPCDE'));
      if rcd_pts_sam_definition.sde_sam_code is null and not(xslProcessor.valueOf(obj_pts_request,'@SAMCODE') = '*NEW') then
         pts_gen_function.add_mesg_data('Sample code ('||xslProcessor.valueOf(obj_pts_request,'@SAMCODE')||') must be a number');
      end if;
      if rcd_pts_sam_definition.sde_uom_size is null and not(xslProcessor.valueOf(obj_pts_request,'@UOMSIZE') is null) then
         pts_gen_function.add_mesg_data('Unit of measure size ('||xslProcessor.valueOf(obj_pts_request,'@UOMSIZE')||') must be a number');
      end if;
      if rcd_pts_sam_definition.sde_pre_date is null and not(xslProcessor.valueOf(obj_pts_request,'@PREDATE') is null) then
         pts_gen_function.add_mesg_data('Prepared date ('||xslProcessor.valueOf(obj_pts_request,'@PREDATE')||') must be a date in the format DD/MM/YYYY');
      end if;
      xmlDom.freeDocument(obj_xml_document);
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_sam_definition.sde_sam_text is null then
         pts_gen_function.add_mesg_data('Sample description must be supplied');
      end if;
      if rcd_pts_sam_definition.sde_sam_status is null then
         pts_gen_function.add_mesg_data('Sample status must be supplied');
      end if;
      if rcd_pts_sam_definition.sde_upd_user is null then
         pts_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if rcd_pts_sam_definition.sde_uom_code is null and not(rcd_pts_sam_definition.sde_uom_size is null) then
         pts_gen_function.add_mesg_data('Unit of measure must be supplied when unit of measure size supplied');
      end if;
      if rcd_pts_sam_definition.sde_pre_locn is null and not(rcd_pts_sam_definition.sde_pre_date is null) then
         pts_gen_function.add_mesg_data('Prepared location must be supplied when prepared date supplied');
      end if;
      open csr_sta_code;
      fetch csr_sta_code into rcd_sta_code;
      if csr_sta_code%notfound then
         pts_gen_function.add_mesg_data('Sample status ('||to_char(rcd_pts_sam_definition.sde_sam_status)||') does not exist');
      end if;
      close csr_sta_code;
      if not(rcd_pts_sam_definition.sde_uom_code is null) then
         open csr_uom_code;
         fetch csr_uom_code into rcd_uom_code;
         if csr_uom_code%notfound then
            pts_gen_function.add_mesg_data('Unit of measure ('||to_char(rcd_pts_sam_definition.sde_uom_code)||') does not exist');
         end if;
         close csr_uom_code;
      end if;
      if not(rcd_pts_sam_definition.sde_pre_locn is null) then
         open csr_pre_locn;
         fetch csr_pre_locn into rcd_pre_locn;
         if csr_pre_locn%notfound then
            pts_gen_function.add_mesg_data('Prepared location ('||to_char(rcd_pts_sam_definition.sde_pre_locn)||') does not exist');
         end if;
         close csr_pre_locn;
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
     
      /*-*/
      /* Retrieve and process the sample definition
      /*-*/
      open csr_check;
      fetch csr_check into rcd_check;
      if csr_check%found then
         update pts_sam_definition
            set sde_sam_text = rcd_pts_sam_definition.sde_sam_text,
                sde_sam_status = rcd_pts_sam_definition.sde_sam_status,
                sde_upd_user = rcd_pts_sam_definition.sde_upd_user,
                sde_upd_date = rcd_pts_sam_definition.sde_upd_date,
                sde_uom_code = rcd_pts_sam_definition.sde_uom_code,
                sde_uom_size = rcd_pts_sam_definition.sde_uom_size,
                sde_pre_locn = rcd_pts_sam_definition.sde_pre_locn,
                sde_pre_date = rcd_pts_sam_definition.sde_pre_date,
                sde_ext_rec_refnr = rcd_pts_sam_definition.sde_ext_rec_refnr,
                sde_plop_code = rcd_pts_sam_definition.sde_plop_code
          where sde_sam_code = rcd_pts_sam_definition.sde_sam_code;
      else
         select pts_sam_sequence.nextval into rcd_pts_sam_definition.sde_sam_code from dual;
         insert into pts_sam_definition values rcd_pts_sam_definition;
      end if;
      close csr_check;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_SAM_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

end pts_sam_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_sam_function for pts_app.pts_sam_function;
grant execute on pts_app.pts_sam_function to public;

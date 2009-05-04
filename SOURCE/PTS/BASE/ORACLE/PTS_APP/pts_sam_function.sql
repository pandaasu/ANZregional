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
   procedure set_list_data;
   function get_list_data return pts_sam_list_type pipelined;
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

   /*-*/
   /* Private definitions
   /*-*/
   pvar_pag_size number;
   pvar_end_code number;

   /*****************************************************/
   /* This procedure performs the set list data routine */
   /*****************************************************/
   procedure set_list_data is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      obj_grp_list xmlDom.domNodeList;
      obj_grp_node xmlDom.domNode;
      obj_rul_list xmlDom.domNodeList;
      obj_rul_node xmlDom.domNode;
      obj_val_list xmlDom.domNodeList;
      obj_val_node xmlDom.domNode;
      rcd_pts_wor_sel_group pts_wor_sel_group%rowtype;
      rcd_pts_wor_sel_rule pts_wor_sel_rule%rowtype;
      rcd_pts_wor_sel_value pts_wor_sel_value%rowtype;
      var_action varchar2(32);
      var_group boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Clear the work selection temporary tables
      /*-*/
      delete from pts_wor_sel_group;
      delete from pts_wor_sel_rule;
      delete from pts_wor_sel_value;

      /*-*/
      /* Set the list defaults
      /*-*/
      pvar_pag_size := 20;
      pvar_end_code := 0;

      /*-*/
      /* Parse the XML input
      /*-*/
      if dbms_lob.getlength(lics_form.get_clob('PTS_STREAM')) = 0 then
         return;
      end if;
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve and process the stream header
      /*-*/
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      pvar_end_code := nvl(pts_to_number(xslProcessor.valueOf(obj_pts_request,'@ENDCDE')),0);
      if var_action != '*SELDTA' then
         raise_application_error(-20000, 'Invalid request action');
      end if;

      /*-*/
      /* Retrieve and process the stream nodes
      /*-*/
      obj_grp_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/GROUPS/GROUP');
      for idg in 0..xmlDom.getLength(obj_grp_list)-1 loop
         obj_grp_node := xmlDom.item(obj_grp_list,idg);
         var_group := false;
         obj_rul_list := xslProcessor.selectNodes(obj_grp_node,'RULES/RULE');
         for idr in 0..xmlDom.getLength(obj_rul_list)-1 loop
            if var_group = false then
               rcd_pts_wor_sel_group.wsg_sel_group := upper(xslProcessor.valueOf(obj_grp_node,'@GRPCDE'));
               insert into pts_wor_sel_group values rcd_pts_wor_sel_group;
               var_group := true;
            end if;
            obj_rul_node := xmlDom.item(obj_rul_list,idr);
            rcd_pts_wor_sel_rule.wsr_sel_group := rcd_pts_wor_sel_group.wsg_sel_group;
            rcd_pts_wor_sel_rule.wsr_tab_code := upper(xslProcessor.valueOf(obj_rul_node,'@TABCDE'));
            rcd_pts_wor_sel_rule.wsr_fld_code := pts_to_number(xslProcessor.valueOf(obj_rul_node,'@FLDCDE'));
            rcd_pts_wor_sel_rule.wsr_rul_code := upper(xslProcessor.valueOf(obj_rul_node,'@RULCDE'));
            insert into pts_wor_sel_rule values rcd_pts_wor_sel_rule;
            obj_val_list := xslProcessor.selectNodes(obj_rul_node,'VALUES/VALUE');
            for idv in 0..xmlDom.getLength(obj_val_list)-1 loop
               obj_val_node := xmlDom.item(obj_val_list,idv);
               rcd_pts_wor_sel_value.wsv_sel_group := rcd_pts_wor_sel_rule.wsr_sel_group;
               rcd_pts_wor_sel_value.wsv_tab_code := rcd_pts_wor_sel_rule.wsr_tab_code;
               rcd_pts_wor_sel_value.wsv_fld_code := rcd_pts_wor_sel_rule.wsr_rul_code;
               rcd_pts_wor_sel_value.wsv_val_code := pts_to_number(xslProcessor.valueOf(obj_val_node,'@VALCDE'));
               rcd_pts_wor_sel_value.wsv_val_text := xslProcessor.valueOf(obj_val_node,'@VALTXT');
               insert into pts_wor_sel_value values rcd_pts_wor_sel_value;
            end loop;
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
         raise_application_error(-20000, 'PTS_GEN_FUNCTION - SET_LIST_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_list_data;

   /*****************************************************/
   /* This procedure performs the get list data routine */
   /******************************************************/
   function get_list_data return pts_sam_list_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_row_count number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_select is
         select t01.sde_sam_code,
                t01.sde_sam_text,
                decode(t01.sde_sam_status,'0','Inactive','1','Active',t01.sde_sam_status) as sde_sam_status
           from pts_sam_definition t01
          where t01.sde_sam_code in (select sel_code from table(pts_app.pts_gen_function.select_list('*SAMPLE',null)))
            and t01.sde_sam_code > pvar_end_code
          order by t01.sde_sam_code asc;
      rcd_select csr_select%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the pet selection list and pipe the results
      /*-*/
      var_row_count := 0;
      open csr_select;
      loop
         fetch csr_select into rcd_select;
         if csr_select%notfound then
            exit;
         end if;
         var_row_count := var_row_count + 1;
         if var_row_count <= pvar_pag_size then
            pipe row(pts_sam_list_object(rcd_select.sde_sam_code,rcd_select.sde_sam_text,rcd_select.sde_sam_status));
         else
            exit;
         end if;
      end loop;
      close csr_select;

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
         raise_application_error(-20000, 'PTS_SAM_FUNCTION - GET_LIST_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_list_data;

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
      cursor csr_sample is
         select t01.*
           from pts_sam_definition t01
          where t01.sde_sam_code = pts_to_number(var_sam_code);
      rcd_sample csr_sample%rowtype;

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
      /* Parse the XML input
      /*-*/
      if dbms_lob.getlength(lics_form.get_clob('PTS_STREAM')) = 0 then
         return;
      end if;
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      var_sam_code := xslProcessor.valueOf(obj_pts_request,'@SAMCODE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDSAM' and var_action != '*CRTSAM' and var_action != '*CPYSAM' then
         pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_ERROR><ERROR ERRTXT="'||pts_to_xml('Invalid request action')||'"/></PTS_ERROR>'));
         return;
      end if;

      /*-*/
      /* Retrieve the existing sample when required
      /*-*/
      if var_action = '*UPDSAM' or var_action = '*CPYSAM' then
         open csr_sample;
         fetch csr_sample into rcd_sample;
         if csr_sample%notfound then
            pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_ERROR><ERROR ERRTXT="'||pts_to_xml('Sample ('||var_sam_code||') does not exist')||'"/></PTS_ERROR>'));
            return;
         end if;
         close csr_sample;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the sample status XML
      /*-*/
      pipe row(pts_xml_object('<STA_LIST VALCDE="0" VALTXT="Inactive"/>'));
      pipe row(pts_xml_object('<STA_LIST VALCDE="1" VALTXT="Active"/>'));

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
         pipe row(pts_xml_object('<UOM_LIST VALCDE="'||rcd_uom_code.val_code||'" VALTXT="'||pts_to_xml(rcd_uom_code.val_text)||'"/>'));
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
         pipe row(pts_xml_object('<PRE_LIST VALCDE="'||rcd_pre_locn.val_code||'" VALTXT="'||pts_to_xml(rcd_pre_locn.val_text)||'"/>'));
      end loop;
      close csr_pre_locn;

      /*-*/
      /* Pipe the sample XML
      /*-*/
      if var_action = '*UPDSAM' then
         var_output := '<SAMPLE SAMCODE="'||to_char(rcd_sample.sde_sam_code)||'"';
         var_output := var_output||' SAMTEXT="'||pts_to_xml(rcd_sample.sde_sam_text)||'"';
         var_output := var_output||' SAMSTAT="'||rcd_sample.sde_sam_status||'"';
         var_output := var_output||' UOMCODE="'||to_char(rcd_sample.sde_uom_code)||'"';
         var_output := var_output||' UOMSIZE="'||to_char(rcd_sample.sde_uom_size)||'"';
         var_output := var_output||' PRELOCN="'||to_char(rcd_sample.sde_pre_locn)||'"';
         var_output := var_output||' PREDATE="'||to_char(rcd_sample.sde_pre_date,'dd/mm/yyyy')||'"';
         var_output := var_output||' EXTRFNR="'||pts_to_xml(rcd_sample.sde_ext_rec_refnr)||'"';
         var_output := var_output||' PLOPCDE="'||pts_to_xml(rcd_sample.sde_plop_code)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYSAM' then
         var_output := '<SAMPLE SAMCODE="*NEW"';
         var_output := var_output||' SAMTEXT="'||pts_to_xml(rcd_sample.sde_sam_text)||'"';
         var_output := var_output||' SAMSTAT="'||rcd_sample.sde_sam_status||'"';
         var_output := var_output||' UOMCODE="'||to_char(rcd_sample.sde_uom_code)||'"';
         var_output := var_output||' UOMSIZE="'||to_char(rcd_sample.sde_uom_size)||'"';
         var_output := var_output||' PRELOCN="'||to_char(rcd_sample.sde_pre_locn)||'"';
         var_output := var_output||' PREDATE="'||to_char(rcd_sample.sde_pre_date,'dd/mm/yyyy')||'"';
         var_output := var_output||' EXTRFNR="'||pts_to_xml(rcd_sample.sde_ext_rec_refnr)||'"';
         var_output := var_output||' PLOPCDE="'||pts_to_xml(rcd_sample.sde_plop_code)||'"/>';
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
         raise_application_error(-20000, 'FATAL ERROR - PTS_SAM_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 2048));

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
      /* Parse the XML input
      /*-*/
      if dbms_lob.getlength(lics_form.get_clob('PTS_STREAM')) = 0 then
         return;
      end if;
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      rcd_pts_sam_definition.sde_sam_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@SAMCODE'));
      rcd_pts_sam_definition.sde_sam_text := xslProcessor.valueOf(obj_pts_request,'@SAMTEXT');
      rcd_pts_sam_definition.sde_sam_status := xslProcessor.valueOf(obj_pts_request,'@SAMSTAT');
      rcd_pts_sam_definition.sde_upd_user := upper(par_user);
      rcd_pts_sam_definition.sde_upd_date := sysdate;
      rcd_pts_sam_definition.sde_uom_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@UOMCODE'));
      rcd_pts_sam_definition.sde_uom_size := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@UOMSIZE'));
      rcd_pts_sam_definition.sde_pre_locn := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PRECODE'));
      rcd_pts_sam_definition.sde_pre_date := pts_to_date(xslProcessor.valueOf(obj_pts_request,'@PREDATE'),'dd/mm/yyyy');
      rcd_pts_sam_definition.sde_ext_rec_refnr := xslProcessor.valueOf(obj_pts_request,'@EXTRFNR');
      rcd_pts_sam_definition.sde_plop_code := xslProcessor.valueOf(obj_pts_request,'@PLOPCDE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*DEFSAM' then
         raise_application_error(-20000, 'Invalid request action');
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_sam_definition.sde_sam_text is null then
         raise_application_error(-20000, 'Sample description must be supplied');
      end if;
      if rcd_pts_sam_definition.sde_sam_status is null then
         raise_application_error(-20000, 'Sample status must be supplied');
      else
         if rcd_pts_sam_definition.sde_sam_status != '0' and rcd_pts_sam_definition.sde_sam_status != '1' then
            raise_application_error(-20000, 'Sample status must be active or inactive');
         end if;
      end if;
      if rcd_pts_sam_definition.sde_upd_user is null then
         raise_application_error(-20000, 'Update user must be supplied');
      end if;
      if not(rcd_pts_sam_definition.sde_uom_code is null) and rcd_pts_sam_definition.sde_uom_size is null then
         raise_application_error(-20000, 'Unit of measure size must be supplied when unit of measure supplied');
      end if;
      if not(rcd_pts_sam_definition.sde_pre_locn is null) and rcd_pts_sam_definition.sde_pre_date is null then
         raise_application_error(-20000, 'Prepared date must be supplied when prepared location supplied');
      end if;
      if not(rcd_pts_sam_definition.sde_uom_code is null) then
         open csr_uom_code;
         fetch csr_uom_code into rcd_uom_code;
         if csr_uom_code%notfound then
            raise_application_error(-20000, 'Unit of measure ('||to_char(rcd_pts_sam_definition.sde_uom_code)||') does not exist');
         end if;
         close csr_uom_code;
      end if;
      if not(rcd_pts_sam_definition.sde_pre_locn is null) then
         open csr_pre_locn;
         fetch csr_pre_locn into rcd_pre_locn;
         if csr_pre_locn%notfound then
            raise_application_error(-20000, 'Prepared location ('||to_char(rcd_pts_sam_definition.sde_pre_locn)||') does not exist');
         end if;
         close csr_pre_locn;
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
         raise_application_error(-20000, 'FATAL ERROR - PTS_SAM_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package variables
   /*-*/
   pvar_pag_size := 20;
   pvar_end_code := 0;

end pts_sam_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_sam_function for pts_app.pts_sam_function;
grant execute on pts_app.pts_sam_function to public;

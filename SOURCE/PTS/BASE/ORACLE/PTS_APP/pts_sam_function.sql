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
   function get_list_cntl return pts_sam_cntl_type pipelined;
   function list_class(par_tab_code in varchar2, par_fld_code in number) return pts_cla_list_type pipelined;

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
   pvar_lst_more number;
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
      obj_pts_stream xmlDom.domNode;
      obj_grp_list xmlDom.domNodeList;
      obj_grp_node xmlDom.domNode;
      obj_rul_list xmlDom.domNodeList;
      obj_rul_node xmlDom.domNode;
      obj_val_list xmlDom.domNodeList;
      obj_val_node xmlDom.domNode;
      rcd_pts_wor_sel_group pts_wor_sel_group%rowtype;
      rcd_pts_wor_sel_rule pts_wor_sel_rule%rowtype;
      rcd_pts_wor_sel_value pts_wor_sel_value%rowtype;

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
      pvar_lst_more := 0;
      pvar_end_code := 0;
      if dbms_lob.getlength(lics_form.get_clob('PTS_STREAM')) = 0 then
         return;
      end if;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve and process the stream header
      /*-*/
      obj_pts_stream := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      pvar_pag_size := nvl(pts_app.pts_gen_function.to_number(xslProcessor.valueOf(obj_pts_stream,'@PAGSIZ')),20);
      pvar_end_code := nvl(pts_app.pts_gen_function.to_number(xslProcessor.valueOf(obj_pts_stream,'@ENDCDE')),0);

      /*-*/
      /* Retrieve and process the stream nodes
      /*-*/
      obj_grp_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_STREAM/GROUPS/GROUP');
      for idg in 0..xmlDom.getLength(obj_grp_list)-1 loop
         obj_grp_node := xmlDom.item(obj_grp_list,idg);
         rcd_pts_wor_sel_group.wsg_sel_group := upper(xslProcessor.valueOf(obj_grp_node,'@SELGROUP'));
         insert into pts_wor_sel_group values rcd_pts_wor_sel_group;
         obj_rul_list := xslProcessor.selectNodes(obj_grp_node,'RULES/RULE');
         for idr in 0..xmlDom.getLength(obj_rul_list)-1 loop
            obj_rul_node := xmlDom.item(obj_rul_list,idr);
            rcd_pts_wor_sel_rule.wsr_sel_group := rcd_pts_wor_sel_group.wsg_sel_group;
            rcd_pts_wor_sel_rule.wsr_tab_code := upper(xslProcessor.valueOf(obj_rul_node,'@TABCDE'));
            rcd_pts_wor_sel_rule.wsr_fld_code := pts_app.pts_gen_function.to_number(xslProcessor.valueOf(obj_rul_node,'@FLDCDE'));
            rcd_pts_wor_sel_rule.wsr_rul_code := upper(xslProcessor.valueOf(obj_rul_node,'@RULCDE'));
            insert into pts_wor_sel_rule values rcd_pts_wor_sel_rule;
            obj_val_list := xslProcessor.selectNodes(obj_rul_node,'VALUES/VALUE');
            for idv in 0..xmlDom.getLength(obj_val_list)-1 loop
               obj_val_node := xmlDom.item(obj_val_list,idv);
               rcd_pts_wor_sel_value.wsv_sel_group := rcd_pts_wor_sel_rule.wsr_sel_group;
               rcd_pts_wor_sel_value.wsv_tab_code := rcd_pts_wor_sel_rule.wsr_tab_code;
               rcd_pts_wor_sel_value.wsv_fld_code := rcd_pts_wor_sel_rule.wsr_rul_code;
               rcd_pts_wor_sel_value.wsv_val_code := pts_app.pts_gen_function.to_number(xslProcessor.valueOf(obj_val_node,'@VALCDE'));
               rcd_pts_wor_sel_value.wsv_val_text := xslProcessor.valueOf(obj_val_node,'@VALTXT');
               insert into pts_wor_sel_value values rcd_pts_wor_sel_value;
            end loop;
         end loop;
      end loop;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

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
      var_lst_more number;
      var_end_code number;
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
      /* Initialise the list control values
      /*-*/
      var_lst_more := 0;
      var_end_code := 0;

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
            var_end_code := rcd_select.sde_sam_code;
         else
            var_lst_more := 1;
            exit;
         end if;
      end loop;
      close csr_select;
      pvar_lst_more := var_lst_more;
      pvar_end_code := var_end_code;

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

   /********************************************************/
   /* This procedure performs the get list control routine */
   /********************************************************/
   function get_list_cntl return pts_sam_cntl_type pipelined is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Return the list control data
      /*-*/
      pipe row(pts_sam_cntl_object(pvar_lst_more,pvar_end_code));

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
         raise_application_error(-20000, 'PTS_SAM_FUNCTION - GET_LIST_CNTL - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_list_cntl;

   /***********************************************************/
   /* This procedure performs the list classification routine */
   /***********************************************************/
   function list_class(par_tab_code in varchar2, par_fld_code in number) return pts_cla_list_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_system_all is
         select t01.sva_val_code,
                t01.sva_val_text
           from pts_sys_value t01
          where t01.sva_tab_code = upper(par_tab_code)
            and t01.sva_fld_code = par_fld_code
          order by t01.sva_val_code asc;
      rcd_system_all csr_system_all%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the sample system values
      /*-*/
      open csr_system_all;
      loop
         fetch csr_system_all into rcd_system_all;
         if csr_system_all%notfound then
            exit;
         end if;
         pipe row(pts_cla_list_object(rcd_system_all.sva_val_code,rcd_system_all.sva_val_text));
      end loop;
      close csr_system_all;

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
         raise_application_error(-20000, 'PTS_SAM_FUNCTION - LIST_CLASS - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_class;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package variables
   /*-*/
   pvar_pag_size := 20;
   pvar_lst_more := 0;
   pvar_end_code := 0;

end pts_sam_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_sam_function for pts_app.pts_sam_function;
grant execute on pts_app.pts_sam_function to public;

/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_sal_rpt_110                                     */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : October 2007                                       */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_sal_rpt_110 as

/**DESCRIPTION**
 OP by customer hierarchy by material.

 **PARAMETERS**
 par_company_code = SAP company code (mandatory)

   /*-*/
   /* Public declarations
   /*-*/
   function main(par_company_code in varchar2) return varchar2;

end hk_sal_rpt_110;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_sal_rpt_110 as

   /*-*/
   /* Private package methods
   /*-*/
   procedure do_prd_br(par_company_code in varchar2);

   /*-*/
   /* Private package variables
   /*-*/
   type typ_lookup is table of number index by varchar2(128);
   tbl_lookup typ_lookup;

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_company_code in varchar2) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute the requested report method
      /*-*/
      do_prd_br(par_company_code);

      /*-*/
      /* Must return *OK when successful
      /*-*/
      return '*OK';

   /*-------------*/
   /* End routine */
   /*-------------*/
   end main;

   /********************************************************/
   /* This procedure performs the period BR report routine */
   /********************************************************/
   procedure do_prd_br(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_string varchar2(2048 char);
      var_name varchar2(31 char);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_mat_node is
         select 'ALL' mat_node,
                '0' node_level,
                'All' node_name
           from dual
          union all
         select 'MISSING' cust_node,
                'BUS_SGMNT_MISSING' node_level,
                'Business Segment - MISSING' node_name
           from (select count(*) miss_count
                   from pld_sal_cus_prd_1201 t01,
                        material_dim t02
                  where t01.sap_material_code = t02.sap_material_code(+)
                    and t01.sap_company_code = par_company_code
                    and t02.sap_bus_sgmnt_code is null
                    and t02.sap_material_type_code not in ('ZPRM','ZHIE')) t01
          where t01.miss_count > 0
          union all
         select t02.sap_bus_sgmnt_code mat_node,
                'BUS_SGMNT_CODE' node_level,
                max(substr(trim(nvl(t02.bus_sgmnt_desc,'Business Segment - UNKNOWN')),1,31)) node_name
           from pld_sal_cus_prd_1201 t01,
                material_dim t02
          where t01.sap_material_code = t02.sap_material_code(+)
            and t01.sap_company_code = par_company_code
            and not(t02.sap_bus_sgmnt_code is null)
            and t02.sap_material_type_code not in ('ZPRM','ZHIE')
          group by t02.sap_bus_sgmnt_code
          union all
         select 'MISSING' cust_node,
                'BDT_MISSING' node_level,
                'BDT - MISSING' node_name
           from (select count(*) miss_count
                   from pld_sal_cus_prd_1201 t01,
                        material_dim t02
                  where t01.sap_material_code = t02.sap_material_code(+)
                    and t01.sap_company_code = par_company_code
                    and t02.sap_bdt_code is null
                    and t02.sap_material_type_code not in ('ZPRM','ZHIE')) t01
          where t01.miss_count > 0
          union all
         select t02.sap_bdt_code mat_node,
                'BDT_CODE' node_level,
                max(substr(trim(nvl(t02.bdt_desc,'BDT - UNKNOWN')),1,31)) node_name
           from pld_sal_cus_prd_1201 t01,
                material_dim t02
          where t01.sap_material_code = t02.sap_material_code(+)
            and t01.sap_company_code = par_company_code
            and not(t02.sap_bdt_code is null)
            and t02.sap_material_type_code not in ('ZPRM','ZHIE')
          group by t02.sap_bdt_code
          union all
         select 'MISSING' cust_node,
                'BRAND_MISSING' node_level,
                'Brand - MISSING' node_name
           from (select count(*) miss_count
                   from pld_sal_cus_prd_1201 t01,
                        material_dim t02
                  where t01.sap_material_code = t02.sap_material_code(+)
                    and t01.sap_company_code = par_company_code
                    and t02.sap_brand_flag_code is null
                    and t02.sap_material_type_code not in ('ZPRM','ZHIE')) t01
          where t01.miss_count > 0
          union all
         select t02.sap_brand_flag_code mat_node,
                'BRAND_CODE' node_level,
                max(substr(trim(nvl(t02.brand_flag_desc,'Brand - UNKNOWN')),1,31)) node_name
           from pld_sal_cus_prd_1201 t01,
                material_dim t02
          where t01.sap_material_code = t02.sap_material_code(+)
            and t01.sap_company_code = par_company_code
            and not(t02.sap_brand_flag_code is null)
            and t02.sap_material_type_code not in ('ZPRM','ZHIE')
          group by t02.sap_brand_flag_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the report heading
      /*-*/
      var_string := 'OP by Customer Hierarchy by Material';

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_cus_prd_12_excel.start_report(par_company_code);

      /*-*/
      /* Retrieve the material nodes
      /*-*/
      tbl_lookup.delete;
      for rcd_mat_node in csr_mat_node loop

            /*-*/
            /* Define sheet
            /*-*/
            if tbl_lookup.exists(upper(rcd_mat_node.node_name)) then
               tbl_lookup(upper(rcd_mat_node.node_name)) := tbl_lookup(upper(rcd_mat_node.node_name)) + 1;
               var_name := substr('('||to_char(tbl_lookup(upper(rcd_mat_node.node_name)))||') '||rcd_mat_node.node_name,1,31);
            else
               tbl_lookup(upper(rcd_mat_node.node_name)) := 0;
               var_name := substr(rcd_mat_node.node_name,1,31);
            end if;
            if (rcd_mat_node.node_level = 'BUS_SGMNT_MISSING' or
                rcd_mat_node.node_level = 'BDT_MISSING' or
                rcd_mat_node.node_level = 'BRAND_MISSING') then
               hk_sal_cus_prd_12_excel.define_sheet(var_name,6);
            else
               hk_sal_cus_prd_12_excel.define_sheet(var_name,5);
            end if;

            /*-*/
            /* Add the columns based on parameters
            /*-*/
            hk_sal_cus_prd_12_excel.add_group('GSV');
            hk_sal_cus_prd_12_excel.add_column('PRD0113_TOP_GSV',null,3,5,1000);
            hk_sal_cus_prd_12_excel.add_column('YEE_OP_GSV',null,3,5,1000);

            hk_sal_cus_prd_12_excel.add_group('QTY');
            hk_sal_cus_prd_12_excel.add_column('PRD0113_TOP_QTY',null,3,3,1);
            hk_sal_cus_prd_12_excel.add_column('YEE_OP_QTY',null,3,3,1);

            /*-*/
            /* Start the sheet
            /*-*/
            hk_sal_cus_prd_12_excel.start_sheet(var_string);
            if rcd_mat_node.node_level <> '0' then
               hk_sal_cus_prd_12_excel.set_parameter_string(rcd_mat_node.node_level, rcd_mat_node.mat_node);
            end if;

            /*-*/
            /* Set the parameters and hierarchy
            /*-*/
            if (rcd_mat_node.node_level = 'BUS_SGMNT_MISSING' or
                rcd_mat_node.node_level = 'BDT_MISSING' or
                rcd_mat_node.node_level = 'BRAND_MISSING') then

               hk_sal_cus_prd_12_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(2,'STD_HIER01',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(3,'STD_HIER02',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(4,'STD_HIER03',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(5,'SHIP_TO_CUSTOMER',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(6,'MATERIAL',false);
               hk_sal_cus_prd_12_excel.retrieve_data;

            else

               hk_sal_cus_prd_12_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(2,'STD_HIER01',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(3,'STD_HIER02',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(4,'STD_HIER03',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(5,'SHIP_TO_CUSTOMER',false);
               hk_sal_cus_prd_12_excel.retrieve_data;

            end if;

            /*-*/
            /* End the sheet
            /*-*/
            hk_sal_cus_prd_12_excel.end_sheet;

      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_prd_br;

end hk_sal_rpt_110;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_sal_rpt_110 for pld_rep_app.hk_sal_rpt_110;
grant execute on hk_sal_rpt_110 to public;
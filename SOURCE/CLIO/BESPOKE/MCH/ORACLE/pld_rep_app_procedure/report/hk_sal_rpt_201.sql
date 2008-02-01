/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_sal_rpt_201                                     */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : October 2007                                       */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_sal_rpt_201 as

/**DESCRIPTION**
 Period sales report by material by customer hierarchy.

 **PARAMETERS**
 par_company_code = SAP company code (mandatory)
 par_yr_end = 'Y' or 'N' (mandatory)

   /*-*/
   /* Public declarations
   /*-*/
   function main(par_company_code in varchar2, par_yr_end in varchar2) return varchar2;

end hk_sal_rpt_201;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_sal_rpt_201 as

   /*-*/
   /* Private package methods
   /*-*/
   procedure do_mth_br(par_company_code in varchar2);
   procedure do_full_mth(par_company_code in varchar2);

   /*-*/
   /* Private package variables
   /*-*/
   type typ_lookup is table of number index by varchar2(128);
   tbl_lookup typ_lookup;

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_company_code in varchar2, par_yr_end in varchar2) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute the requested report method
      /*-*/
      if par_yr_end = 'N' then
         do_mth_br(par_company_code);
      else
         do_full_mth(par_company_code);
      end if;

      /*-*/
      /* Must return *OK when successful
      /*-*/
      return '*OK';

   /*-------------*/
   /* End routine */
   /*-------------*/
   end main;

   /********************************************************/
   /* This procedure performs the month BR report routine */
   /********************************************************/
   procedure do_mth_br(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_string varchar2(2048 char);
      var_name varchar2(31 char);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_cust_node is
         select 'ALL' cust_node,
                '0' node_level,
                'All Customer' node_name
           from dual
          union all
         select 'MISSING' cust_node,
                'STD_HIER_MISSING' node_level,
                'Hierarchy - MISSING' node_name
           from (select count(*) miss_count
                   from pld_sal_cus_mth_1201 t01,
                        std_hier t02
                  where t01.sap_ship_to_cust_code = t02.sap_hier_cust_code(+)
                    and t01.sap_sales_org_code = t02.sap_sales_org_code(+)
                    and t01.sap_distbn_chnl_code = t02.sap_distbn_chnl_code(+)
                    and t01.sap_division_code = t02.sap_division_code(+)
                    and t01.sap_company_code = par_company_code
                    and t02.sap_hier_cust_code is null) t01
          where t01.miss_count > 0
          union all
         select t02.sap_cust_code_level_1 cust_node,
                'STD_HIER01_CODE' node_level,
                max(substr(trim(nvl(t02.cust_name_en_level_1,'Hierarchy 01 - UNKNOWN')),1,31)) node_name
           from pld_sal_cus_mth_1201 t01,
                std_hier t02
          where t01.sap_ship_to_cust_code = t02.sap_hier_cust_code(+)
            and t01.sap_sales_org_code = t02.sap_sales_org_code(+)
            and t01.sap_distbn_chnl_code = t02.sap_distbn_chnl_code(+)
            and t01.sap_division_code = t02.sap_division_code(+)
            and t01.sap_company_code = par_company_code
            and not(t02.sap_hier_cust_code is null)
          group by t02.sap_cust_code_level_1
          union all
         select t02.sap_cust_code_level_3 cust_node,
                'STD_HIER03_CODE' node_level,
                max(substr(trim(nvl(t02.cust_name_en_level_3,'Hierarchy 03 - UNKNOWN')),1,31)) node_name
           from pld_sal_cus_mth_1201 t01,
                std_hier t02
          where t01.sap_ship_to_cust_code = t02.sap_hier_cust_code(+)
            and t01.sap_sales_org_code = t02.sap_sales_org_code(+)
            and t01.sap_distbn_chnl_code = t02.sap_distbn_chnl_code(+)
            and t01.sap_division_code = t02.sap_division_code(+)
            and t01.sap_company_code = par_company_code
            and not(t02.sap_hier_cust_code is null)
          group by t02.sap_cust_code_level_3;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the report heading
      /*-*/
      var_string := 'Monthly Sales Report by Material by Customer Hierarchy';

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_cus_mth_12_excel.start_report(par_company_code);

      /*-*/
      /* Retrieve the hierarchy nodes
      /*-*/
      tbl_lookup.delete;
      for rcd_cust_node in csr_cust_node loop

            /*-*/
            /* Define sheet
            /*-*/
            if tbl_lookup.exists(upper(rcd_cust_node.node_name)) then
               tbl_lookup(upper(rcd_cust_node.node_name)) := tbl_lookup(upper(rcd_cust_node.node_name)) + 1;
               var_name := substr('('||to_char(tbl_lookup(upper(rcd_cust_node.node_name)))||') '||rcd_cust_node.node_name,1,31);
            else
               tbl_lookup(upper(rcd_cust_node.node_name)) := 0;
               var_name := substr(rcd_cust_node.node_name,1,31);
            end if;
            if rcd_cust_node.node_level = 'STD_HIER_MISSING' then
               hk_sal_cus_mth_12_excel.define_sheet(var_name,4);
            else
               hk_sal_cus_mth_12_excel.define_sheet(var_name,9);
            end if;

            /*-*/
            /* Add the columns based on parameters
            /*-*/
            hk_sal_cus_mth_12_excel.add_group('GSV');
            hk_sal_cus_mth_12_excel.add_column('MTH0112_ABR_GSV',null,3,5,1000);
            hk_sal_cus_mth_12_excel.add_column('YEE_LY_GSV','Prior YEE',3,5,1000);
            hk_sal_cus_mth_12_excel.add_column('MTH_LY_GSV','YAG',3,5,1000);
            hk_sal_cus_mth_12_excel.add_column('MTH_TY_LY_GSV','%YAG',null,null,null);
            hk_sal_cus_mth_12_excel.add_column('YTD_TY_GSV','YTD',3,5,1000);
            hk_sal_cus_mth_12_excel.add_column('YTD_LY_GSV','Prior YTD',3,5,1000);
            hk_sal_cus_mth_12_excel.add_column('YTD_TY_LY_GSV','YTD %YAG',null,null,null);

            hk_sal_cus_mth_12_excel.add_group('NIV');
            hk_sal_cus_mth_12_excel.add_column('MTH0112_ABR_NIV',null,3,5,1000);
            hk_sal_cus_mth_12_excel.add_column('YEE_LY_NIV','Prior YEE',3,5,1000);
            hk_sal_cus_mth_12_excel.add_column('MTH_LY_NIV','YAG',3,5,1000);
            hk_sal_cus_mth_12_excel.add_column('MTH_TY_LY_NIV','%YAG',null,null,null);
            hk_sal_cus_mth_12_excel.add_column('YTD_TY_NIV','YTD',3,5,1000);
            hk_sal_cus_mth_12_excel.add_column('YTD_LY_NIV','Prior YTD',3,5,1000);
            hk_sal_cus_mth_12_excel.add_column('YTD_TY_LY_NIV','YTD %YAG',null,null,null);

            hk_sal_cus_mth_12_excel.add_group('QTY');
            hk_sal_cus_mth_12_excel.add_column('MTH0112_ABR_QTY',null,3,3,1);
            hk_sal_cus_mth_12_excel.add_column('YEE_LY_QTY','Prior YEE',3,3,1);
            hk_sal_cus_mth_12_excel.add_column('MTH_LY_QTY','YAG',3,3,1);
            hk_sal_cus_mth_12_excel.add_column('MTH_TY_LY_QTY','%YAG',null,null,null);
            hk_sal_cus_mth_12_excel.add_column('YTD_TY_QTY','YTD',3,3,1);
            hk_sal_cus_mth_12_excel.add_column('YTD_LY_QTY','Prior YTD',3,3,1);
            hk_sal_cus_mth_12_excel.add_column('YTD_TY_LY_QTY','YTD %YAG',null,null,null);

            /*-*/
            /* Start the sheet
            /*-*/
            hk_sal_cus_mth_12_excel.start_sheet(var_string);
            if rcd_cust_node.node_level <> '0' then
               hk_sal_cus_mth_12_excel.set_parameter_string(rcd_cust_node.node_level, rcd_cust_node.cust_node);
            end if;

            /*-*/
            /* Set the parameters and hierarchy
            /*-*/
            if rcd_cust_node.node_level = 'STD_HIER_MISSING' then

               hk_sal_cus_mth_12_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(3,'SHIP_TO_CUSTOMER',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(4,'MATERIAL',false);
               hk_sal_cus_mth_12_excel.retrieve_data;

            else

               /*-*/
               /* Snackfood data
               /*-*/
               hk_sal_cus_mth_12_excel.set_parameter_string('BUS_SGMNT_CODE','01');
               hk_sal_cus_mth_12_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(3,'BDT',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(4,'BRAND',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(5,'BRAND',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(6,'BRAND',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(7,'BRAND',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(8,'REP_ITEM',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(9,'MATERIAL',false);
               hk_sal_cus_mth_12_excel.retrieve_data;

               /*-*/
               /* Food data
               /*-*/
               hk_sal_cus_mth_12_excel.set_parameter_string('BUS_SGMNT_CODE','02');
               hk_sal_cus_mth_12_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(3,'BDT',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(4,'BRAND',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(5,'PRDCT_CTGRY',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(6,'CNSMR_PACK',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(7,'PACK_SIZE',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(8,'REP_ITEM',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(9,'MATERIAL',false);
               hk_sal_cus_mth_12_excel.retrieve_data;

               /*-*/
               /* Petcare data
               /*-*/
               hk_sal_cus_mth_12_excel.set_parameter_string('BUS_SGMNT_CODE','05');
               hk_sal_cus_mth_12_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(3,'BRAND',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(5,'CNSMR_PACK',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(6,'SUB_BRAND',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(7,'PACK_SIZE',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(8,'REP_ITEM',false);
               hk_sal_cus_mth_12_excel.set_hierarchy(9,'MATERIAL',false);
               hk_sal_cus_mth_12_excel.retrieve_data;

            end if;

            /*-*/
            /* End the sheet
            /*-*/
            hk_sal_cus_mth_12_excel.end_sheet;

      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_mth_br;

   /********************************************************/
   /* This procedure performs full month report routine    */
   /********************************************************/
   procedure do_full_mth(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_string varchar2(2048 char);
      var_name varchar2(31 char);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_cust_node is
         select 'ALL' cust_node,
                '0' node_level,
                'All Customer' node_name
           from dual
          union all
         select 'MISSING' cust_node,
                'STD_HIER_MISSING' node_level,
                'Hierarchy - MISSING' node_name
           from (select count(*) miss_count
                   from pld_sal_cus_mth_1301 t01,
                        std_hier t02
                  where t01.sap_ship_to_cust_code = t02.sap_hier_cust_code(+)
                    and t01.sap_sales_org_code = t02.sap_sales_org_code(+)
                    and t01.sap_distbn_chnl_code = t02.sap_distbn_chnl_code(+)
                    and t01.sap_division_code = t02.sap_division_code(+)
                    and t01.sap_company_code = par_company_code
                    and t02.sap_hier_cust_code is null) t01
          where t01.miss_count > 0
          union all
         select t02.sap_cust_code_level_1 cust_node,
                'STD_HIER01_CODE' node_level,
                max(substr(trim(nvl(t02.cust_name_en_level_1,'Hierarchy 01 - UNKNOWN')),1,31)) node_name
           from pld_sal_cus_mth_1301 t01,
                std_hier t02
          where t01.sap_ship_to_cust_code = t02.sap_hier_cust_code(+)
            and t01.sap_sales_org_code = t02.sap_sales_org_code(+)
            and t01.sap_distbn_chnl_code = t02.sap_distbn_chnl_code(+)
            and t01.sap_division_code = t02.sap_division_code(+)
            and t01.sap_company_code = par_company_code
            and not(t02.sap_hier_cust_code is null)
          group by t02.sap_cust_code_level_1
          union all
         select t02.sap_cust_code_level_3 cust_node,
                'STD_HIER03_CODE' node_level,
                max(substr(trim(nvl(t02.cust_name_en_level_3,'Hierarchy 03 - UNKNOWN')),1,31)) node_name
           from pld_sal_cus_mth_1301 t01,
                std_hier t02
          where t01.sap_ship_to_cust_code = t02.sap_hier_cust_code(+)
            and t01.sap_sales_org_code = t02.sap_sales_org_code(+)
            and t01.sap_distbn_chnl_code = t02.sap_distbn_chnl_code(+)
            and t01.sap_division_code = t02.sap_division_code(+)
            and t01.sap_company_code = par_company_code
            and not(t02.sap_hier_cust_code is null)
          group by t02.sap_cust_code_level_3;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the report heading
      /*-*/
      var_string := 'Monthly Sales Report by Material by Customer Hierarchy';

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_cus_mth_13_excel.start_report(par_company_code);

      /*-*/
      /* Retrieve the hierarchy nodes
      /*-*/
      tbl_lookup.delete;
      for rcd_cust_node in csr_cust_node loop

            /*-*/
            /* Define sheet
            /*-*/
            if tbl_lookup.exists(upper(rcd_cust_node.node_name)) then
               tbl_lookup(upper(rcd_cust_node.node_name)) := tbl_lookup(upper(rcd_cust_node.node_name)) + 1;
               var_name := substr('('||to_char(tbl_lookup(upper(rcd_cust_node.node_name)))||') '||rcd_cust_node.node_name,1,31);
            else
               tbl_lookup(upper(rcd_cust_node.node_name)) := 0;
               var_name := substr(rcd_cust_node.node_name,1,31);
            end if;
            if rcd_cust_node.node_level = 'STD_HIER_MISSING' then
               hk_sal_cus_mth_13_excel.define_sheet(var_name,4);
            else
               hk_sal_cus_mth_13_excel.define_sheet(var_name,9);
            end if;

            /*-*/
            /* Add the columns based on parameters
            /*-*/
            hk_sal_cus_mth_13_excel.add_group('GSV');
            hk_sal_cus_mth_13_excel.add_column('MLY0112_TYR_GSV',null,3,5,1000);
            hk_sal_cus_mth_13_excel.add_column('TOT_TY_GSV',null,3,5,1000);

            hk_sal_cus_mth_13_excel.add_group('NIV');
            hk_sal_cus_mth_13_excel.add_column('MLY0112_TYR_NIV',null,3,5,1000);
            hk_sal_cus_mth_13_excel.add_column('TOT_TY_NIV',null,3,5,1000);

            hk_sal_cus_mth_13_excel.add_group('QTY');
            hk_sal_cus_mth_13_excel.add_column('MLY0112_TYR_QTY',null,3,3,1);
            hk_sal_cus_mth_13_excel.add_column('TOT_TY_QTY',null,3,3,1);

            /*-*/
            /* Start the sheet
            /*-*/
            hk_sal_cus_mth_13_excel.start_sheet(var_string);
            if rcd_cust_node.node_level <> '0' then
               hk_sal_cus_mth_13_excel.set_parameter_string(rcd_cust_node.node_level, rcd_cust_node.cust_node);
            end if;

            /*-*/
            /* Set the parameters and hierarchy
            /*-*/
            if rcd_cust_node.node_level = 'STD_HIER_MISSING' then

               hk_sal_cus_mth_13_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(3,'SHIP_TO_CUSTOMER',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(4,'MATERIAL',false);
               hk_sal_cus_mth_13_excel.retrieve_data;

            else

               /*-*/
               /* Snackfood data
               /*-*/
               hk_sal_cus_mth_13_excel.set_parameter_string('BUS_SGMNT_CODE','01');
               hk_sal_cus_mth_13_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(3,'BDT',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(4,'BRAND',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(5,'BRAND',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(6,'BRAND',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(7,'BRAND',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(8,'REP_ITEM',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(9,'MATERIAL',false);
               hk_sal_cus_mth_13_excel.retrieve_data;

               /*-*/
               /* Food data
               /*-*/
               hk_sal_cus_mth_13_excel.set_parameter_string('BUS_SGMNT_CODE','02');
               hk_sal_cus_mth_13_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(3,'BDT',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(4,'BRAND',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(5,'PRDCT_CTGRY',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(6,'CNSMR_PACK',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(7,'PACK_SIZE',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(8,'REP_ITEM',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(9,'MATERIAL',false);
               hk_sal_cus_mth_13_excel.retrieve_data;

               /*-*/
               /* Petcare data
               /*-*/
               hk_sal_cus_mth_13_excel.set_parameter_string('BUS_SGMNT_CODE','05');
               hk_sal_cus_mth_13_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(3,'BRAND',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(5,'CNSMR_PACK',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(6,'SUB_BRAND',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(7,'PACK_SIZE',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(8,'REP_ITEM',false);
               hk_sal_cus_mth_13_excel.set_hierarchy(9,'MATERIAL',false);
               hk_sal_cus_mth_13_excel.retrieve_data;

            end if;

            /*-*/
            /* End the sheet
            /*-*/
            hk_sal_cus_mth_13_excel.end_sheet;

      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_full_mth;

end hk_sal_rpt_201;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_sal_rpt_201 for pld_rep_app.hk_sal_rpt_201;
grant execute on hk_sal_rpt_201 to public;
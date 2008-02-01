/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_sal_rpt_101                                     */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : October 2007                                       */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_sal_rpt_101 as

/**DESCRIPTION**
 Period sales report by material by customer hierarchy.

 **PARAMETERS**
 par_company_code = SAP company code (mandatory)
 par_val_type = Value type (mandatory)
                  QTY = quantity
                  TON = tonnes
                  GSV = gross sale value
                  NIV = net invoice value
 par_yr_end = 'Y' or 'N' (mandatory)

   /*-*/
   /* Public declarations
   /*-*/
   function main(par_company_code in varchar2, par_val_type in varchar2, par_yr_end in varchar2) return varchar2;

end hk_sal_rpt_101;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_sal_rpt_101 as

   /*-*/
   /* Private package methods
   /*-*/
   procedure do_prd_br(par_company_code in varchar2, par_val_type in varchar2);
   procedure do_full_prd(par_company_code in varchar2, par_val_type in varchar2);

   /*-*/
   /* Private package variables
   /*-*/
   type typ_lookup is table of number index by varchar2(128);
   tbl_lookup typ_lookup;

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_company_code in varchar2, par_val_type in varchar2, par_yr_end in varchar2) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute the requested report method
      /*-*/
      if par_yr_end = 'Y' then
         do_full_prd(par_company_code, par_val_type);
      else
         do_prd_br(par_company_code, par_val_type);
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
   /* This procedure performs the period BR report routine */
   /********************************************************/
   procedure do_prd_br(par_company_code in varchar2, par_val_type in varchar2) is

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
                   from pld_sal_cus_prd_1201 t01,
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
           from pld_sal_cus_prd_1201 t01,
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
           from pld_sal_cus_prd_1201 t01,
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
      var_string := 'Period Sales Report by Material by Customer Hierarchy';
      if par_val_type = 'QTY' then
         var_string := var_string || ' - Quantity';
      elsif par_val_type = 'TON' then
         var_string := var_string || ' - Tonnes';
      elsif par_val_type = 'GSV' then
         var_string := var_string || ' - Gross Sales Value (HK$ Thousands)';
      elsif par_val_type = 'NIV' then
         var_string := var_string || ' - Net Invoice Value (HK$ Thousands)';
      end if;

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_cus_prd_12_excel.start_report(par_company_code);

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
               hk_sal_cus_prd_12_excel.define_sheet(var_name,4);
            else
               hk_sal_cus_prd_12_excel.define_sheet(var_name,9);
            end if;

            /*-*/
            /* Add the columns based on parameters
            /*-*/
            if par_val_type = 'QTY' then

               hk_sal_cus_prd_12_excel.add_group('ACT+BR');
               hk_sal_cus_prd_12_excel.add_column('PRD0113_ABR_QTY',null,3,3,1);

               hk_sal_cus_prd_12_excel.add_group('CP');
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_QTY','ACT',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('PRD_LY_QTY','YAG',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_LY_QTY','%YAG',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('PRD_OP_QTY','OP',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_OP_QTY','%OP',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('PRD_BR_QTY','BR',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_BR_QTY','%BR',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_QTY_SHR','%Share',null,null,null);

               hk_sal_cus_prd_12_excel.add_group('YTD');
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_QTY','ACT',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YTD_LY_QTY','Prior YTD',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_LY_QTY','%YAG',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YTD_OP_QTY','OP',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_OP_QTY','%OP',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_QTY_SHR','%Share',null,null,null);

               hk_sal_cus_prd_12_excel.add_group('YTG');
               hk_sal_cus_prd_12_excel.add_column('YTG_BR_QTY','BR',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YTG_LY_QTY','Prior YTG',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YTG_BR_LY_QTY','%YAG',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YTG_OP_QTY','OP',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YTG_BR_OP_QTY','%OP',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YTG_BR_QTY_SHR','%Share',null,null,null);

               hk_sal_cus_prd_12_excel.add_group('YEE');
               hk_sal_cus_prd_12_excel.add_column('YEE_TB_QTY','YEE',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YEE_LY_QTY','Prior YEE',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YEE_TB_LY_QTY','%YAG',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YEE_OP_QTY','OP',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YEE_TB_OP_QTY','%OP',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YEE_TB_QTY_SHR','%Share',null,null,null);

            elsif par_val_type = 'TON' then

               hk_sal_cus_prd_12_excel.add_group('ACT+BR');
               hk_sal_cus_prd_12_excel.add_column('PRD0113_ABR_TON',null,3,3,1);

               hk_sal_cus_prd_12_excel.add_group('CP');
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_TON','ACT',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('PRD_LY_TON','YAG',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_LY_TON','%YAG',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('PRD_OP_TON','OP',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_OP_TON','%OP',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('PRD_BR_TON','BR',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_BR_TON','%BR',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_TON_SHR','%Share',null,null,null);

               hk_sal_cus_prd_12_excel.add_group('YTD');
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_TON','ACT',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YTD_LY_TON','Prior YTD',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_LY_TON','%YAG',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YTD_OP_TON','OP',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_OP_TON','%OP',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_TON_SHR','%Share',null,null,null);

               hk_sal_cus_prd_12_excel.add_group('YTG');
               hk_sal_cus_prd_12_excel.add_column('YTG_BR_TON','BR',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YTG_LY_TON','Prior YTG',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YTG_BR_LY_TON','%YAG',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YTG_OP_TON','OP',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YTG_BR_OP_TON','%OP',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YTG_BR_TON_SHR','%Share',null,null,null);

               hk_sal_cus_prd_12_excel.add_group('YEE');
               hk_sal_cus_prd_12_excel.add_column('YEE_TB_TON','YEE',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YEE_LY_TON','Prior YEE',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YEE_TB_LY_TON','%YAG',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YEE_OP_TON','OP',3,3,1);
               hk_sal_cus_prd_12_excel.add_column('YEE_TB_OP_TON','%OP',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YEE_TB_TON_SHR','%Share',null,null,null);

            elsif par_val_type = 'GSV' then

               hk_sal_cus_prd_12_excel.add_group('ACT+BR');
               hk_sal_cus_prd_12_excel.add_column('PRD0113_ABR_GSV',null,3,5,1000);

               hk_sal_cus_prd_12_excel.add_group('CP');
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_GSV','ACT',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('PRD_LY_GSV','YAG',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_LY_GSV','%YAG',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('PRD_OP_GSV','OP',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_OP_GSV','%OP',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('PRD_BR_GSV','BR',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_BR_GSV','%BR',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_GSV_SHR','%Share',null,null,null);

               hk_sal_cus_prd_12_excel.add_group('YTD');
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_GSV','ACT',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('YTD_LY_GSV','Prior YTD',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_LY_GSV','%YAG',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YTD_OP_GSV','OP',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_OP_GSV','%OP',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_GSV_SHR','%Share',null,null,null);

               hk_sal_cus_prd_12_excel.add_group('YTG');
               hk_sal_cus_prd_12_excel.add_column('YTG_BR_GSV','BR',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('YTG_LY_GSV','Prior YTG',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('YTG_BR_LY_GSV','%YAG',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YTG_OP_GSV','OP',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('YTG_BR_OP_GSV','%OP',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YTG_BR_GSV_SHR','%Share',null,null,null);

               hk_sal_cus_prd_12_excel.add_group('YEE');
               hk_sal_cus_prd_12_excel.add_column('YEE_TB_GSV','YEE',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('YEE_LY_GSV','Prior YEE',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('YEE_TB_LY_GSV','%YAG',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YEE_OP_GSV','OP',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('YEE_TB_OP_GSV','%OP',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YEE_TB_GSV_SHR','%Share',null,null,null);

            elsif par_val_type = 'NIV' then

               hk_sal_cus_prd_12_excel.add_group('ACT+BR');
               hk_sal_cus_prd_12_excel.add_column('PRD0113_ABR_NIV',null,3,5,1000);

               hk_sal_cus_prd_12_excel.add_group('CP');
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_NIV','ACT',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('PRD_LY_NIV','YAG',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_LY_NIV','%YAG',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('PRD_TY_NIV_SHR','%Share',null,null,null);

               hk_sal_cus_prd_12_excel.add_group('YTD');
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_NIV','ACT',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('YTD_LY_NIV','Prior YTD',3,5,1000);
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_LY_NIV','%YAG',null,null,null);
               hk_sal_cus_prd_12_excel.add_column('YTD_TY_NIV_SHR','%Share',null,null,null);

            end if;

            /*-*/
            /* Start the sheet
            /*-*/
            hk_sal_cus_prd_12_excel.start_sheet(var_string);
            if rcd_cust_node.node_level <> '0' then
               hk_sal_cus_prd_12_excel.set_parameter_string(rcd_cust_node.node_level, rcd_cust_node.cust_node);
            end if;

            /*-*/
            /* Set the parameters and hierarchy
            /*-*/
            if rcd_cust_node.node_level = 'STD_HIER_MISSING' then

               hk_sal_cus_prd_12_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(3,'SHIP_TO_CUSTOMER',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(4,'MATERIAL',false);
               hk_sal_cus_prd_12_excel.retrieve_data;

            else

               /*-*/
               /* Snackfood data
               /*-*/
               hk_sal_cus_prd_12_excel.set_parameter_string('BUS_SGMNT_CODE','01');
               hk_sal_cus_prd_12_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(3,'BDT',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(4,'BRAND',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(5,'BRAND',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(6,'BRAND',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(7,'BRAND',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(8,'REP_ITEM',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(9,'MATERIAL',false);
               hk_sal_cus_prd_12_excel.retrieve_data;

               /*-*/
               /* Food data
               /*-*/
               hk_sal_cus_prd_12_excel.set_parameter_string('BUS_SGMNT_CODE','02');
               hk_sal_cus_prd_12_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(3,'BDT',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(4,'BRAND',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(5,'PRDCT_CTGRY',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(6,'CNSMR_PACK',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(7,'PACK_SIZE',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(8,'REP_ITEM',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(9,'MATERIAL',false);
               hk_sal_cus_prd_12_excel.retrieve_data;

               /*-*/
               /* Petcare data
               /*-*/
               hk_sal_cus_prd_12_excel.set_parameter_string('BUS_SGMNT_CODE','05');
               hk_sal_cus_prd_12_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(3,'BRAND',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(5,'CNSMR_PACK',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(6,'SUB_BRAND',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(7,'PACK_SIZE',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(8,'REP_ITEM',false);
               hk_sal_cus_prd_12_excel.set_hierarchy(9,'MATERIAL',false);
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

   /********************************************************/
   /* This procedure performs full period report routine   */
   /********************************************************/
   procedure do_full_prd(par_company_code in varchar2, par_val_type in varchar2) is

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
                   from pld_sal_cus_prd_1301 t01,
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
           from pld_sal_cus_prd_1301 t01,
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
           from pld_sal_cus_prd_1301 t01,
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
      var_string := 'Period Sales Report by Material by Customer Hierarchy';
      if par_val_type = 'QTY' then
         var_string := var_string || ' - Quantity';
      elsif par_val_type = 'TON' then
         var_string := var_string || ' - Tonnes';
      elsif par_val_type = 'GSV' then
         var_string := var_string || ' - Gross Sales Value (HK$ Thousands)';
      elsif par_val_type = 'NIV' then
         var_string := var_string || ' - Net Invoice Value (HK$ Thousands)';
      end if;

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_cus_prd_13_excel.start_report(par_company_code);

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
               hk_sal_cus_prd_13_excel.define_sheet(var_name,4);
            else
               hk_sal_cus_prd_13_excel.define_sheet(var_name,9);
            end if;

            /*-*/
            /* Add the columns based on parameters
            /*-*/
            if par_val_type = 'QTY' then
               hk_sal_cus_prd_13_excel.add_group('ACT');
               hk_sal_cus_prd_13_excel.add_column('PLY0113_TYR_QTY',null,3,3,1);
               hk_sal_cus_prd_13_excel.add_group('YTD');
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_QTY','ACT',3,3,1);
               hk_sal_cus_prd_13_excel.add_column('TOT_LY_QTY','YAG',3,3,1);
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_LY_QTY','%YAG',null,null,null);
               hk_sal_cus_prd_13_excel.add_column('TOT_OP_QTY','OP',3,3,1);
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_OP_QTY','%OP',null,null,null);
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_QTY_SHR','%Share',null,null,null);
            elsif par_val_type = 'TON' then
               hk_sal_cus_prd_13_excel.add_group('ACT');
               hk_sal_cus_prd_13_excel.add_column('PLY0113_TYR_TON',null,3,3,1);
               hk_sal_cus_prd_13_excel.add_group('YTD');
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_TON','ACT',3,3,1);
               hk_sal_cus_prd_13_excel.add_column('TOT_LY_TON','YAG',3,3,1);
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_LY_TON','%YAG',null,null,null);
               hk_sal_cus_prd_13_excel.add_column('TOT_OP_QTY','OP',3,3,1);
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_OP_TON','%OP',null,null,null);
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_TON_SHR','%Share',null,null,null);
            elsif par_val_type = 'GSV' then
               hk_sal_cus_prd_13_excel.add_group('ACT');
               hk_sal_cus_prd_13_excel.add_column('PLY0113_TYR_GSV',null,3,5,1000);
               hk_sal_cus_prd_13_excel.add_group('YTD');
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_GSV','ACT',3,5,1000);
               hk_sal_cus_prd_13_excel.add_column('TOT_LY_GSV','YAG',3,5,1000);
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_LY_GSV','%YAG',null,null,null);
               hk_sal_cus_prd_13_excel.add_column('TOT_OP_GSV','OP',3,5,1000);
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_OP_GSV','%OP',null,null,null);
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_GSV_SHR','%Share',null,null,null);
            elsif par_val_type = 'NIV' then
               hk_sal_cus_prd_13_excel.add_group('Actual');
               hk_sal_cus_prd_13_excel.add_column('PLY0113_TYR_NIV',null,3,5,1000);
               hk_sal_cus_prd_13_excel.add_group('YTD');
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_NIV','ACT',3,5,1000);
               hk_sal_cus_prd_13_excel.add_column('TOT_LY_NIV','YAG',3,5,1000);
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_LY_NIV','%YAG',null,null,null);
               hk_sal_cus_prd_13_excel.add_column('TOT_OP_NIV','OP',3,5,1000);
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_OP_NIV','%OP',null,null,null);
               hk_sal_cus_prd_13_excel.add_column('TOT_TY_NIV_SHR','%Share',null,null,null);
            end if;

            /*-*/
            /* Start the sheet
            /*-*/
            hk_sal_cus_prd_13_excel.start_sheet(var_string);
            if rcd_cust_node.node_level <> '0' then
               hk_sal_cus_prd_13_excel.set_parameter_string(rcd_cust_node.node_level, rcd_cust_node.cust_node);
            end if;

            /*-*/
            /* Set the parameters and hierarchy
            /*-*/
            if rcd_cust_node.node_level = 'STD_HIER_MISSING' then

               hk_sal_cus_prd_13_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(3,'SHIP_TO_CUSTOMER',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(4,'MATERIAL',false);
               hk_sal_cus_prd_13_excel.retrieve_data;

            else

               /*-*/
               /* Snackfood data
               /*-*/
               hk_sal_cus_prd_13_excel.set_parameter_string('BUS_SGMNT_CODE','01');
               hk_sal_cus_prd_13_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(3,'BDT',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(4,'BRAND',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(5,'BRAND',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(6,'BRAND',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(7,'BRAND',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(8,'REP_ITEM',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(9,'MATERIAL',false);
               hk_sal_cus_prd_13_excel.retrieve_data;

               /*-*/
               /* Food data
               /*-*/
               hk_sal_cus_prd_13_excel.set_parameter_string('BUS_SGMNT_CODE','02');
               hk_sal_cus_prd_13_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(3,'BDT',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(4,'BRAND',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(5,'PRDCT_CTGRY',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(6,'CNSMR_PACK',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(7,'PACK_SIZE',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(8,'REP_ITEM',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(9,'MATERIAL',false);
               hk_sal_cus_prd_13_excel.retrieve_data;

               /*-*/
               /* Petcare data
               /*-*/
               hk_sal_cus_prd_13_excel.set_parameter_string('BUS_SGMNT_CODE','05');
               hk_sal_cus_prd_13_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(2,'BUS_SGMNT',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(3,'BRAND',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(5,'CNSMR_PACK',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(6,'SUB_BRAND',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(7,'PACK_SIZE',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(8,'REP_ITEM',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(9,'MATERIAL',false);
               hk_sal_cus_prd_13_excel.retrieve_data;

            end if;

            /*-*/
            /* End the sheet
            /*-*/
            hk_sal_cus_prd_13_excel.end_sheet;

      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_full_prd;

end hk_sal_rpt_101;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_sal_rpt_101 for pld_rep_app.hk_sal_rpt_101;
grant execute on hk_sal_rpt_101 to public;
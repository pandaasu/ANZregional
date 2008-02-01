/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_sal_rpt_104                                     */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : October 2007                                       */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_sal_rpt_104 as

/**DESCRIPTION**
 Period sales report by customer by material.

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

end hk_sal_rpt_104;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_sal_rpt_104 as

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
      var_string := 'Period Sales Report by Customer by Material';
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
                   from pld_sal_cus_prd_1301 t01,
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
           from pld_sal_cus_prd_1301 t01,
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
                   from pld_sal_cus_prd_1301 t01,
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
           from pld_sal_cus_prd_1301 t01,
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
                   from pld_sal_cus_prd_1301 t01,
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
           from pld_sal_cus_prd_1301 t01,
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
      var_string := 'Period Sales Report by Customer by Material';
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
               hk_sal_cus_prd_13_excel.define_sheet(var_name,6);
            else
               hk_sal_cus_prd_13_excel.define_sheet(var_name,5);
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
            if rcd_mat_node.node_level <> '0' then
               hk_sal_cus_prd_13_excel.set_parameter_string(rcd_mat_node.node_level, rcd_mat_node.mat_node);
            end if;

            /*-*/
            /* Set the parameters and hierarchy
            /*-*/
            if (rcd_mat_node.node_level = 'BUS_SGMNT_MISSING' or
                rcd_mat_node.node_level = 'BDT_MISSING' or
                rcd_mat_node.node_level = 'BRAND_MISSING') then

               hk_sal_cus_prd_13_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(2,'STD_HIER01',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(3,'STD_HIER02',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(4,'STD_HIER03',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(5,'SHIP_TO_CUSTOMER',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(6,'MATERIAL',false);
               hk_sal_cus_prd_13_excel.retrieve_data;

            else

               hk_sal_cus_prd_13_excel.set_hierarchy(1,'COMPANY',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(2,'STD_HIER01',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(3,'STD_HIER02',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(4,'STD_HIER03',false);
               hk_sal_cus_prd_13_excel.set_hierarchy(5,'SHIP_TO_CUSTOMER',false);
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

end hk_sal_rpt_104;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_sal_rpt_104 for pld_rep_app.hk_sal_rpt_104;
grant execute on hk_sal_rpt_104 to public;

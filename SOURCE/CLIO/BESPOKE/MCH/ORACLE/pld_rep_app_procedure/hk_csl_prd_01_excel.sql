/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_csl_prd_01_excel                                */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : May 2006                                           */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_csl_prd_01_excel as

   /*-*/
   /* Public package methods
   /*-*/
   procedure set_print_override(par_print_xml in varchar2);
   procedure set_parameter_string(par_parameter in varchar2, par_value in varchar2);
   procedure set_parameter_number(par_parameter in varchar2, par_value in number);
   procedure set_parameter_date(par_parameter in varchar2, par_value in date);
   procedure set_hierarchy(par_index in number, par_hierarchy in varchar2, par_adj_text in boolean);
   procedure set_hierarchy_column(par_index in number, par_column in varchar2, par_num_static in boolean, par_prt_supress in boolean);
   procedure add_group(par_heading in varchar2);
   procedure add_column(par_column in varchar2, par_heading in varchar2, par_dec_print in number, par_dec_round in number, par_sca_factor in number);
   procedure start_report(par_company_code in varchar2, par_material_type in varchar2);
   procedure define_sheet(par_name in varchar2, par_depth in number, par_table in varchar2);
   procedure start_sheet(par_htxt1 in varchar2, par_report in varchar2);
   procedure retrieve_data;
   procedure end_sheet;

end hk_csl_prd_01_excel;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_csl_prd_01_excel as

   /*-*/
   /* Private package variables
   /*-*/
   rcd_pld_csl_prd_0100 pld_csl_prd_0100%rowtype;
   var_material_type varchar2(4);
   var_case_target varchar2(20);
   var_order_target varchar2(20);
   var_delivery_target varchar2(20);
   var_ontime_target varchar2(20);

   /*-*/
   /* Private package methods
   /*-*/
   procedure load_base_data01;
   procedure load_base_data02;

   /**********************************************************/
   /* This procedure performs the set print override routine */
   /**********************************************************/
   procedure set_print_override(par_print_xml in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the print override XML
      /*-*/
      hk_sal_base_excel.set_print_override(par_print_xml);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_print_override;

   /************************************************************/
   /* This procedure performs the set parameter string routine */
   /************************************************************/
   procedure set_parameter_string(par_parameter in varchar2, par_value in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameter
      /*-*/
      hk_sal_base_excel.set_parameter_string(par_parameter, par_value);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_parameter_string;

   /************************************************************/
   /* This procedure performs the set parameter number routine */
   /************************************************************/
   procedure set_parameter_number(par_parameter in varchar2, par_value in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameter
      /*-*/
      hk_sal_base_excel.set_parameter_number(par_parameter, par_value);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_parameter_number;

   /**********************************************************/
   /* This procedure performs the set parameter date routine */
   /**********************************************************/
   procedure set_parameter_date(par_parameter in varchar2, par_value in date) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameter
      /*-*/
      hk_sal_base_excel.set_parameter_date(par_parameter, par_value);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_parameter_date;

   /*****************************************************/
   /* This procedure performs the set hierarchy routine */
   /*****************************************************/
   procedure set_hierarchy(par_index in number, par_hierarchy in varchar2, par_adj_text in boolean) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the hierarchy
      /*-*/
      hk_sal_base_excel.set_hierarchy(par_index, par_hierarchy, par_adj_text);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_hierarchy;

   /************************************************************/
   /* This procedure performs the set hierarchy column routine */
   /************************************************************/
   procedure set_hierarchy_column(par_index in number, par_column in varchar2, par_num_static in boolean, par_prt_supress in boolean) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the hierarchy column
      /*-*/
      hk_sal_base_excel.set_hierarchy_column(par_index, par_column, par_num_static, par_prt_supress);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_hierarchy_column;

   /*************************************************/
   /* This procedure performs the add group routine */
   /*************************************************/
   procedure add_group(par_heading in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Add the group
      /*-*/
      hk_sal_base_excel.add_group(par_heading);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_group;

   /**************************************************/
   /* This procedure performs the add column routine */
   /**************************************************/
   procedure add_column(par_column in varchar2, par_heading in varchar2, par_dec_print in number, par_dec_round in number, par_sca_factor in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Add the column
      /*-*/
      hk_sal_base_excel.add_column(par_column, par_heading, par_dec_print, par_dec_round, par_sca_factor);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_column;

   /****************************************************/
   /* This procedure performs the start report routine */
   /****************************************************/
   procedure start_report(par_company_code in varchar2, par_material_type in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_pld_csl_prd_0100 is 
         select *
         from pld_csl_prd_0100 t01
         where t01.sap_company_code = par_company_code;

      cursor csr_pld_rep_parameter is 
         select max(case when par_code = 'CASE_FILL' then par_value||'%' end) as case_target,
                max(case when par_code = 'ORDER_FILL' then par_value||'%' end) as order_target,
                max(case when par_code = 'DELIVERY' then par_value||'%' end) as delivery_target,
                max(case when par_code = 'ON-TIME' then par_value||'%' end) as ontime_target
           from pld_rep_parameter
          where par_group = 'CSL_REPORT'
            and (par_code = 'CASE_FILL' or
                 par_code = 'ORDER_FILL' or
                 par_code = 'DELIVERY' or
                 par_code = 'ON-TIME')
          group by par_group;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the format control
      /*-*/
      var_found := true;
      open csr_pld_csl_prd_0100;
      fetch csr_pld_csl_prd_0100 into rcd_pld_csl_prd_0100;
      if csr_pld_csl_prd_0100%notfound then
         var_found := false;
      end if;
      close csr_pld_csl_prd_0100;
      if var_found = false then
         raise_application_error(-20000, 'Extract control row PLD_CSL_PRD_0100 not found');
      end if;

      /*-*/
      /* Set the material type
      /*-*/
      var_material_type := par_material_type;

      /*-*/
      /* Retrieve the CSL report target percentages
      /*-*/
      open csr_pld_rep_parameter;
      fetch csr_pld_rep_parameter into var_case_target,
                                       var_order_target,
                                       var_delivery_target,
                                       var_ontime_target;
      close csr_pld_rep_parameter;

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_base_excel.start_report(par_company_code);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end start_report;

   /****************************************************/
   /* This procedure performs the define sheet routine */
   /****************************************************/
   procedure define_sheet(par_name in varchar2, par_depth in number, par_table in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Load the base data based on the table parameter
      /*-*/
      if par_table = '01' then
         load_base_data01;
      elsif par_table = '02' then
         load_base_data02;
      end if;

      /*-*/
      /* Define the sheet
      /*-*/
      hk_sal_base_excel.define_sheet(par_name, par_depth);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end define_sheet;

   /***************************************************/
   /* This procedure performs the start sheet routine */
   /***************************************************/
   procedure start_sheet(par_htxt1 in varchar2, par_report in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_work_period number(6,0);
      var_work_text varchar2(7);
      var_target_text varchar2(20);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the previous period value
      /*-*/
      var_work_period := rcd_pld_csl_prd_0100.current_yyyypp - 1;
      if mod(var_work_period, 100) = 0 then
         var_work_period := var_work_period - 87;
      end if;
      var_work_text := substr(to_char(var_work_period,'fm000000'),1,4) || '/' || substr(to_char(var_work_period,'fm000000'),5,6);

      /*-*/
      /* Set the target rate based on the report parameter
      /*-*/
      if par_report = 'CASE' then
         var_target_text := var_case_target;
      elsif par_report = 'ORDER' then
         var_target_text := var_order_target;
      elsif par_report = 'DELIVERY' then
         var_target_text := var_delivery_target;
      elsif par_report = 'ONTIME' then
         var_target_text := var_ontime_target;
      end if;

      /*-*/
      /* Start the sheet
      /*-*/
      hk_sal_base_excel.start_sheet(par_htxt1,
                                    'Target Rate: ' || var_target_text,
                                    'Period End: ' || var_work_text);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end start_sheet;

   /*****************************************************/
   /* This procedure performs the retrieve data routine */
   /*****************************************************/
   procedure retrieve_data is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the data
      /*-*/
      hk_sal_base_excel.retrieve_data;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_data;

   /*************************************************/
   /* This procedure performs the end sheet routine */
   /*************************************************/
   procedure end_sheet is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* End the shett
      /*-*/
      hk_sal_base_excel.end_sheet;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end end_sheet;

   /*********************************************************/
   /* This procedure performs the load base data 01 routine */
   /*********************************************************/
   procedure load_base_data01 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the variables
      /*-*/
      hk_sal_base_excel.var_print_xml := null;
      hk_sal_base_excel.tbl_main_name := null;
      hk_sal_base_excel.tbl_main_join := null;
      hk_sal_base_excel.tbl_parameter.delete;
      hk_sal_base_excel.tbl_hierarchy.delete;
      hk_sal_base_excel.tbl_table.delete;
      hk_sal_base_excel.tbl_column.delete;

      /*-*/
      /* Initialise the parameter variables
      /*-*/
      hk_sal_base_excel.tbl_parameter('STD_HIER01_CODE').par_text := 'Standard Hierarchy code 01';
      hk_sal_base_excel.tbl_parameter('STD_HIER01_CODE').par_type := '1';
      hk_sal_base_excel.tbl_parameter('STD_HIER01_CODE').par_psql := 't03.sap_cust_code_level_1 = '':VAL''';

      hk_sal_base_excel.tbl_parameter('STD_HIER02_CODE').par_text := 'Standard Hierarchy code 02';
      hk_sal_base_excel.tbl_parameter('STD_HIER02_CODE').par_type := '1';
      hk_sal_base_excel.tbl_parameter('STD_HIER02_CODE').par_psql := 't03.sap_cust_code_level_2 = '':VAL''';

      hk_sal_base_excel.tbl_parameter('STD_HIER03_CODE').par_text := 'Standard Hierarchy code 03';
      hk_sal_base_excel.tbl_parameter('STD_HIER03_CODE').par_type := '1';
      hk_sal_base_excel.tbl_parameter('STD_HIER03_CODE').par_psql := 't03.sap_cust_code_level_3 = '':VAL''';

      hk_sal_base_excel.tbl_parameter('STD_HIER_MISSING').par_text := 'Standard Hierarchy Missing';
      hk_sal_base_excel.tbl_parameter('STD_HIER_MISSING').par_type := '1';
      hk_sal_base_excel.tbl_parameter('STD_HIER_MISSING').par_psql := 't03.sap_hier_cust_code is null';

      hk_sal_base_excel.tbl_parameter('BUS_SGMNT_CODE').par_text := 'Business Segment';
      hk_sal_base_excel.tbl_parameter('BUS_SGMNT_CODE').par_type := '1';
      hk_sal_base_excel.tbl_parameter('BUS_SGMNT_CODE').par_psql := 't02.sap_bus_sgmnt_code = '':VAL''';

      hk_sal_base_excel.tbl_parameter('BDT_CODE').par_text := 'BDT';
      hk_sal_base_excel.tbl_parameter('BDT_CODE').par_type := '1';
      hk_sal_base_excel.tbl_parameter('BDT_CODE').par_psql := 't02.sap_bdt_code = '':VAL''';

      hk_sal_base_excel.tbl_parameter('BRAND_CODE').par_text := 'Brand';
      hk_sal_base_excel.tbl_parameter('BRAND_CODE').par_type := '1';
      hk_sal_base_excel.tbl_parameter('BRAND_CODE').par_psql := 't02.sap_brand_flag_code = '':VAL''';

      hk_sal_base_excel.tbl_parameter('BUS_SGMNT_MISSING').par_text := 'Business Segment Missing';
      hk_sal_base_excel.tbl_parameter('BUS_SGMNT_MISSING').par_type := '1';
      hk_sal_base_excel.tbl_parameter('BUS_SGMNT_MISSING').par_psql := 't02.sap_bus_sgmnt_code is null';

      hk_sal_base_excel.tbl_parameter('BDT_MISSING').par_text := 'BDT Missing';
      hk_sal_base_excel.tbl_parameter('BDT_MISSING').par_type := '1';
      hk_sal_base_excel.tbl_parameter('BDT_MISSING').par_psql := 't02.sap_bdt_code is null';

      hk_sal_base_excel.tbl_parameter('BRAND_MISSING').par_text := 'Brand Missing';
      hk_sal_base_excel.tbl_parameter('BRAND_MISSING').par_type := '1';
      hk_sal_base_excel.tbl_parameter('BRAND_MISSING').par_psql := 't02.sap_brand_flag_code is null';

      /*-*/
      /* Initialise the hierarchy variables
      /*-*/
      hk_sal_base_excel.tbl_hierarchy('STD_HIER01').hie_ssql := 'max(decode(t03.sap_cust_code_level_1,null,''UNKNOWN'',t03.sap_cust_code_level_1))';
      hk_sal_base_excel.tbl_hierarchy('STD_HIER01').hie_tsql := 'max(decode(t03.cust_name_en_level_1,null,''UNKNOWN'',t03.cust_name_en_level_1))';
      hk_sal_base_excel.tbl_hierarchy('STD_HIER01').hie_gsql := 't03.sap_cust_code_level_1';

      hk_sal_base_excel.tbl_hierarchy('STD_HIER02').hie_ssql := 'max(decode(t03.sap_cust_code_level_2,null,''UNKNOWN'',t03.sap_cust_code_level_2))';
      hk_sal_base_excel.tbl_hierarchy('STD_HIER02').hie_tsql := 'max(decode(t03.cust_name_en_level_2,null,''UNKNOWN'',t03.cust_name_en_level_2))';
      hk_sal_base_excel.tbl_hierarchy('STD_HIER02').hie_gsql := 't03.sap_cust_code_level_2';

      hk_sal_base_excel.tbl_hierarchy('STD_HIER03').hie_ssql := 'max(decode(t03.sap_cust_code_level_3,null,''UNKNOWN'',t03.sap_cust_code_level_3))';
      hk_sal_base_excel.tbl_hierarchy('STD_HIER03').hie_tsql := 'max(decode(t03.cust_name_en_level_3,null,''UNKNOWN'',t03.cust_name_en_level_3))';
      hk_sal_base_excel.tbl_hierarchy('STD_HIER03').hie_gsql := 't03.sap_cust_code_level_3';

      hk_sal_base_excel.tbl_hierarchy('SHIP_TO_CUSTOMER').hie_ssql := 'max(decode(t01.sap_ship_to_cust_code,null,''UNKNOWN'',t01.sap_ship_to_cust_code))';
      hk_sal_base_excel.tbl_hierarchy('SHIP_TO_CUSTOMER').hie_tsql := 'max(''('' || t01.sap_ship_to_cust_code || '') '' || decode(t03.cust_name_en_level_4,null,''UNKNOWN'',t03.cust_name_en_level_4))';
      hk_sal_base_excel.tbl_hierarchy('SHIP_TO_CUSTOMER').hie_gsql := 't01.sap_ship_to_cust_code';

      hk_sal_base_excel.tbl_hierarchy('COMPANY').hie_ssql := 'max(''Company Total'')';
      hk_sal_base_excel.tbl_hierarchy('COMPANY').hie_tsql := 'max(''Company Total'')';
      hk_sal_base_excel.tbl_hierarchy('COMPANY').hie_gsql := null;

      hk_sal_base_excel.tbl_hierarchy('BUS_SGMNT').hie_ssql := 'max(decode(t02.bus_sgmnt_desc,null,''UNKNOWN'',t02.bus_sgmnt_desc))';
      hk_sal_base_excel.tbl_hierarchy('BUS_SGMNT').hie_tsql := 'max(decode(t02.bus_sgmnt_desc,null,''UNKNOWN'',t02.bus_sgmnt_desc))';
      hk_sal_base_excel.tbl_hierarchy('BUS_SGMNT').hie_gsql := 't02.sap_bus_sgmnt_code';

      hk_sal_base_excel.tbl_hierarchy('BDT').hie_ssql := 'max(decode(t02.bdt_desc,null,''UNKNOWN'',''00'',''Not Applicable'',t02.bdt_desc))';
      hk_sal_base_excel.tbl_hierarchy('BDT').hie_tsql := 'max(decode(t02.bdt_desc,null,''UNKNOWN'',''00'',''Not Applicable'',t02.bdt_desc))';
      hk_sal_base_excel.tbl_hierarchy('BDT').hie_gsql := 't02.sap_bdt_code';

      hk_sal_base_excel.tbl_hierarchy('BRAND').hie_ssql := 'max(decode(t02.sap_brand_flag_code,null,''UNKNOWN'',''000'',''Not Applicable'',t02.brand_flag_desc))';
      hk_sal_base_excel.tbl_hierarchy('BRAND').hie_tsql := 'max(decode(t02.sap_brand_flag_code,null,''UNKNOWN'',''000'',''Not Applicable'',t02.brand_flag_desc))';
      hk_sal_base_excel.tbl_hierarchy('BRAND').hie_gsql := 't02.sap_brand_flag_code';

      hk_sal_base_excel.tbl_hierarchy('SUB_BRAND').hie_ssql := 'max(decode(t02.sap_brand_sub_flag_code,null,''UNKNOWN'',''000'',''Not Applicable'',t02.brand_sub_flag_desc))';
      hk_sal_base_excel.tbl_hierarchy('SUB_BRAND').hie_tsql := 'max(decode(t02.sap_brand_sub_flag_code,null,''UNKNOWN'',''000'',''Not Applicable'',t02.brand_sub_flag_desc))';
      hk_sal_base_excel.tbl_hierarchy('SUB_BRAND').hie_gsql := 't02.sap_brand_sub_flag_code';

      hk_sal_base_excel.tbl_hierarchy('PACK_SIZE').hie_ssql := 'max(decode(t02.sap_prdct_pack_size_code,null,''UNKNOWN'',''000'',''Not Applicable'',t02.prdct_pack_size_desc))';
      hk_sal_base_excel.tbl_hierarchy('PACK_SIZE').hie_tsql := 'max(decode(t02.sap_prdct_pack_size_code,null,''UNKNOWN'',''000'',''Not Applicable'',t02.prdct_pack_size_desc))';
      hk_sal_base_excel.tbl_hierarchy('PACK_SIZE').hie_gsql := 't02.sap_prdct_pack_size_code';

      hk_sal_base_excel.tbl_hierarchy('INGRED_VRTY').hie_ssql := 'max(decode(t02.sap_ingred_vrty_code,null,''UNKNOWN'',''0000'',''Not Applicable'',t02.ingred_vrty_desc))';
      hk_sal_base_excel.tbl_hierarchy('INGRED_VRTY').hie_tsql := 'max(decode(t02.sap_ingred_vrty_code,null,''UNKNOWN'',''0000'',''Not Applicable'',t02.ingred_vrty_desc))';
      hk_sal_base_excel.tbl_hierarchy('INGRED_VRTY').hie_gsql := 't02.sap_ingred_vrty_code';

      hk_sal_base_excel.tbl_hierarchy('CNSMR_PACK').hie_ssql := 'max(decode(t02.sap_cnsmr_pack_frmt_code,null,''UNKNOWN'',''00'',''Not Applicable'',t02.cnsmr_pack_frmt_desc))';
      hk_sal_base_excel.tbl_hierarchy('CNSMR_PACK').hie_tsql := 'max(decode(t02.sap_cnsmr_pack_frmt_code,null,''UNKNOWN'',''00'',''Not Applicable'',t02.cnsmr_pack_frmt_desc))';
      hk_sal_base_excel.tbl_hierarchy('CNSMR_PACK').hie_gsql := 't02.sap_cnsmr_pack_frmt_code';

      hk_sal_base_excel.tbl_hierarchy('PRDCT_CTGRY').hie_ssql := 'max(decode(t02.sap_prdct_ctgry_code,null,''UNKNOWN'',''00'',''Not Applicable'',t02.prdct_ctgry_desc))';
      hk_sal_base_excel.tbl_hierarchy('PRDCT_CTGRY').hie_tsql := 'max(decode(t02.sap_prdct_ctgry_code,null,''UNKNOWN'',''00'',''Not Applicable'',t02.prdct_ctgry_desc))';
      hk_sal_base_excel.tbl_hierarchy('PRDCT_CTGRY').hie_gsql := 't02.sap_prdct_ctgry_code';

      hk_sal_base_excel.tbl_hierarchy('MKT_SGMNT').hie_ssql := 'max(decode(t02.sap_mkt_sgmnt_code,null,''UNKNOWN'',''00'',''Not Applicable'',t02.mkt_sgmnt_desc))';
      hk_sal_base_excel.tbl_hierarchy('MKT_SGMNT').hie_tsql := 'max(decode(t02.sap_mkt_sgmnt_code,null,''UNKNOWN'',''00'',''Not Applicable'',t02.mkt_sgmnt_desc))';
      hk_sal_base_excel.tbl_hierarchy('MKT_SGMNT').hie_gsql := 't02.sap_prdct_ctgry_code';

      hk_sal_base_excel.tbl_hierarchy('SUPPLY_SGMNT').hie_ssql := 'max(decode(t02.sap_supply_sgmnt_code,null,''UNKNOWN'',''000'',''Not Applicable'',t02.supply_sgmnt_desc))';
      hk_sal_base_excel.tbl_hierarchy('SUPPLY_SGMNT').hie_tsql := 'max(decode(t02.sap_supply_sgmnt_code,null,''UNKNOWN'',''000'',''Not Applicable'',t02.supply_sgmnt_desc))';
      hk_sal_base_excel.tbl_hierarchy('SUPPLY_SGMNT').hie_gsql := 't02.sap_supply_sgmnt_code';

      hk_sal_base_excel.tbl_hierarchy('REP_ITEM').hie_ssql := 'max(decode(t02.sap_rpt_item_code,null,''No Representative Item'',t02.rpt_item_desc_en || t02.sap_rpt_item_code))';
      hk_sal_base_excel.tbl_hierarchy('REP_ITEM').hie_tsql := 'max(decode(t02.sap_rpt_item_code,null,''No Representative Item'',''('' || t02.sap_rpt_item_code || '') '' || decode(t02.rpt_item_desc_en,null,''UNKNOWN'',t02.rpt_item_desc_en)))';
      hk_sal_base_excel.tbl_hierarchy('REP_ITEM').hie_gsql := 't02.sap_rep_item_code';

      hk_sal_base_excel.tbl_hierarchy('MATERIAL').hie_ssql := 'max(t02.material_desc_en || t01.sap_material_code)';
      hk_sal_base_excel.tbl_hierarchy('MATERIAL').hie_tsql := 'max(''('' || t01.sap_material_code || '') '' || decode(t02.material_desc_en,null,''UNKNOWN'',t02.material_desc_en))';
      hk_sal_base_excel.tbl_hierarchy('MATERIAL').hie_gsql := 't01.sap_material_code';

      /*-*/
      /* Initialise the customer tables variables
      /*-*/
      hk_sal_base_excel.tbl_main_name := 'pld_csl_prd_0101 t01,material_dim t02,std_hier t03';
      hk_sal_base_excel.tbl_main_join := 't01.sap_material_code = t02.sap_material_code(+) and t01.sap_ship_to_cust_code = t03.sap_hier_cust_code(+) and t01.sap_sales_org_code = t03.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t03.sap_distbn_chnl_code(+) and t01.sap_division_code = t03.sap_division_code(+) and t01.sap_company_code = :A';
      hk_sal_base_excel.tbl_main_join := hk_sal_base_excel.tbl_main_join || ' and t02.sap_material_type_code = ''' || var_material_type || '''';

      /*-*/
      /* Case fill column variables
      /*-*/
      hk_sal_base_excel.tbl_column('PRD_ORD_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_ORD_QTY').col_htxt := 'Order QTY';
      hk_sal_base_excel.tbl_column('PRD_ORD_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_ORD_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_ORD_QTY').col_dsql := 'sum(nvl(t01.ord_qty,0))';
      hk_sal_base_excel.tbl_column('PRD_ORD_QTY').col_zsql := 'nvl(t01.ord_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_ORD_QTY').col_decp := 3;
      hk_sal_base_excel.tbl_column('PRD_ORD_QTY').col_decr := 3;
      hk_sal_base_excel.tbl_column('PRD_ORD_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_ORD_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_ORD_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_ORD_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_ORD_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_DEL_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_DEL_QTY').col_htxt := 'Delivery QTY';
      hk_sal_base_excel.tbl_column('PRD_DEL_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_DEL_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_DEL_QTY').col_dsql := 'sum(nvl(t01.del_qty,0))';
      hk_sal_base_excel.tbl_column('PRD_DEL_QTY').col_zsql := 'nvl(t01.del_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_DEL_QTY').col_decp := 3;
      hk_sal_base_excel.tbl_column('PRD_DEL_QTY').col_decr := 3;
      hk_sal_base_excel.tbl_column('PRD_DEL_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_DEL_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_DEL_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_DEL_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_DEL_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_POD_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_POD_QTY').col_htxt := 'Pod QTY';
      hk_sal_base_excel.tbl_column('PRD_POD_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_POD_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_POD_QTY').col_dsql := 'sum(nvl(t01.pod_qty,0))';
      hk_sal_base_excel.tbl_column('PRD_POD_QTY').col_zsql := 'nvl(t01.pod_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_POD_QTY').col_decp := 3;
      hk_sal_base_excel.tbl_column('PRD_POD_QTY').col_decr := 3;
      hk_sal_base_excel.tbl_column('PRD_POD_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_POD_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_POD_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_POD_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_POD_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_CF_PCT').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_CF_PCT').col_htxt := 'Case Fill %';
      hk_sal_base_excel.tbl_column('PRD_CF_PCT').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_CF_PCT').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_CF_PCT').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_CF_PCT').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_CF_PCT').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_CF_PCT').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_CF_PCT').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_CF_PCT').col_ref1 := 'PRD_DEL_QTY';
      hk_sal_base_excel.tbl_column('PRD_CF_PCT').col_ref2 := 'PRD_ORD_QTY';
      hk_sal_base_excel.tbl_column('PRD_CF_PCT').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_CF_PCT').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_DR_PCT').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_DR_PCT').col_htxt := 'Delivery Rate %';
      hk_sal_base_excel.tbl_column('PRD_DR_PCT').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_DR_PCT').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_DR_PCT').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_DR_PCT').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_DR_PCT').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_DR_PCT').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_DR_PCT').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_DR_PCT').col_ref1 := 'PRD_POD_QTY';
      hk_sal_base_excel.tbl_column('PRD_DR_PCT').col_ref2 := 'PRD_DEL_QTY';
      hk_sal_base_excel.tbl_column('PRD_DR_PCT').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_DR_PCT').col_lnd2 := 'NoY';

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_base_data01;

   /*********************************************************/
   /* This procedure performs the load base data 02 routine */
   /*********************************************************/
   procedure load_base_data02 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the variables
      /*-*/
      hk_sal_base_excel.var_print_xml := null;
      hk_sal_base_excel.tbl_main_name := null;
      hk_sal_base_excel.tbl_main_join := null;
      hk_sal_base_excel.tbl_parameter.delete;
      hk_sal_base_excel.tbl_hierarchy.delete;
      hk_sal_base_excel.tbl_table.delete;
      hk_sal_base_excel.tbl_column.delete;

      /*-*/
      /* Initialise the parameter variables
      /*-*/
      hk_sal_base_excel.tbl_parameter('STD_HIER01_CODE').par_text := 'Standard Hierarchy code 01';
      hk_sal_base_excel.tbl_parameter('STD_HIER01_CODE').par_type := '1';
      hk_sal_base_excel.tbl_parameter('STD_HIER01_CODE').par_psql := 't03.sap_cust_code_level_1 = '':VAL''';

      hk_sal_base_excel.tbl_parameter('STD_HIER02_CODE').par_text := 'Standard Hierarchy code 02';
      hk_sal_base_excel.tbl_parameter('STD_HIER02_CODE').par_type := '1';
      hk_sal_base_excel.tbl_parameter('STD_HIER02_CODE').par_psql := 't03.sap_cust_code_level_2 = '':VAL''';

      hk_sal_base_excel.tbl_parameter('STD_HIER03_CODE').par_text := 'Standard Hierarchy code 03';
      hk_sal_base_excel.tbl_parameter('STD_HIER03_CODE').par_type := '1';
      hk_sal_base_excel.tbl_parameter('STD_HIER03_CODE').par_psql := 't03.sap_cust_code_level_3 = '':VAL''';

      hk_sal_base_excel.tbl_parameter('STD_HIER_MISSING').par_text := 'Standard Hierarchy Missing';
      hk_sal_base_excel.tbl_parameter('STD_HIER_MISSING').par_type := '1';
      hk_sal_base_excel.tbl_parameter('STD_HIER_MISSING').par_psql := 't03.sap_hier_cust_code is null';

      /*-*/
      /* Initialise the hierarchy variables
      /*-*/
      hk_sal_base_excel.tbl_hierarchy('STD_HIER01').hie_ssql := 'max(decode(t03.sap_cust_code_level_1,null,''UNKNOWN'',t03.sap_cust_code_level_1))';
      hk_sal_base_excel.tbl_hierarchy('STD_HIER01').hie_tsql := 'max(decode(t03.cust_name_en_level_1,null,''UNKNOWN'',t03.cust_name_en_level_1))';
      hk_sal_base_excel.tbl_hierarchy('STD_HIER01').hie_gsql := 't03.sap_cust_code_level_1';

      hk_sal_base_excel.tbl_hierarchy('STD_HIER02').hie_ssql := 'max(decode(t03.sap_cust_code_level_2,null,''UNKNOWN'',t03.sap_cust_code_level_2))';
      hk_sal_base_excel.tbl_hierarchy('STD_HIER02').hie_tsql := 'max(decode(t03.cust_name_en_level_2,null,''UNKNOWN'',t03.cust_name_en_level_2))';
      hk_sal_base_excel.tbl_hierarchy('STD_HIER02').hie_gsql := 't03.sap_cust_code_level_2';

      hk_sal_base_excel.tbl_hierarchy('STD_HIER03').hie_ssql := 'max(decode(t03.sap_cust_code_level_3,null,''UNKNOWN'',t03.sap_cust_code_level_3))';
      hk_sal_base_excel.tbl_hierarchy('STD_HIER03').hie_tsql := 'max(decode(t03.cust_name_en_level_3,null,''UNKNOWN'',t03.cust_name_en_level_3))';
      hk_sal_base_excel.tbl_hierarchy('STD_HIER03').hie_gsql := 't03.sap_cust_code_level_3';

      hk_sal_base_excel.tbl_hierarchy('SHIP_TO_CUSTOMER').hie_ssql := 'max(decode(t01.sap_ship_to_cust_code,null,''UNKNOWN'',t01.sap_ship_to_cust_code))';
      hk_sal_base_excel.tbl_hierarchy('SHIP_TO_CUSTOMER').hie_tsql := 'max(''('' || t01.sap_ship_to_cust_code || '') '' || decode(t03.cust_name_en_level_4,null,''UNKNOWN'',t03.cust_name_en_level_4))';
      hk_sal_base_excel.tbl_hierarchy('SHIP_TO_CUSTOMER').hie_gsql := 't01.sap_ship_to_cust_code';

      hk_sal_base_excel.tbl_hierarchy('COMPANY').hie_ssql := 'max(''Company Total'')';
      hk_sal_base_excel.tbl_hierarchy('COMPANY').hie_tsql := 'max(''Company Total'')';
      hk_sal_base_excel.tbl_hierarchy('COMPANY').hie_gsql := null;

      /*-*/
      /* Initialise the customer tables variables
      /*-*/
      hk_sal_base_excel.tbl_main_name := 'pld_csl_prd_0102 t01,std_hier t03';
      hk_sal_base_excel.tbl_main_join := 't01.sap_ship_to_cust_code = t03.sap_hier_cust_code(+) and t01.sap_sales_org_code = t03.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t03.sap_distbn_chnl_code(+) and t01.sap_division_code = t03.sap_division_code(+) and t01.sap_company_code = :A';

      /*-*/
      /* Order column variables
      /*-*/
      hk_sal_base_excel.tbl_column('TOT_ORD_CNT').col_tabi := 1;
      hk_sal_base_excel.tbl_column('TOT_ORD_CNT').col_htxt := 'Total Order Count';
      hk_sal_base_excel.tbl_column('TOT_ORD_CNT').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('TOT_ORD_CNT').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('TOT_ORD_CNT').col_dsql := 'sum(nvl(t01.ord_tot,0))';
      hk_sal_base_excel.tbl_column('TOT_ORD_CNT').col_zsql := 'nvl(t01.ord_tot,0) != 0';
      hk_sal_base_excel.tbl_column('TOT_ORD_CNT').col_decp := 3;
      hk_sal_base_excel.tbl_column('TOT_ORD_CNT').col_decr := 3;
      hk_sal_base_excel.tbl_column('TOT_ORD_CNT').col_scle := 1;
      hk_sal_base_excel.tbl_column('TOT_ORD_CNT').col_ref1 := null;
      hk_sal_base_excel.tbl_column('TOT_ORD_CNT').col_ref2 := null;
      hk_sal_base_excel.tbl_column('TOT_ORD_CNT').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('TOT_ORD_CNT').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('FIL_ORD_CNT').col_tabi := 1;
      hk_sal_base_excel.tbl_column('FIL_ORD_CNT').col_htxt := 'Filled Order Count';
      hk_sal_base_excel.tbl_column('FIL_ORD_CNT').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('FIL_ORD_CNT').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('FIL_ORD_CNT').col_dsql := 'sum(nvl(t01.ord_fil,0))';
      hk_sal_base_excel.tbl_column('FIL_ORD_CNT').col_zsql := 'nvl(t01.ord_fil,0) != 0';
      hk_sal_base_excel.tbl_column('FIL_ORD_CNT').col_decp := 3;
      hk_sal_base_excel.tbl_column('FIL_ORD_CNT').col_decr := 3;
      hk_sal_base_excel.tbl_column('FIL_ORD_CNT').col_scle := 1;
      hk_sal_base_excel.tbl_column('FIL_ORD_CNT').col_ref1 := null;
      hk_sal_base_excel.tbl_column('FIL_ORD_CNT').col_ref2 := null;
      hk_sal_base_excel.tbl_column('FIL_ORD_CNT').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('FIL_ORD_CNT').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('ONT_ORD_CNT').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ONT_ORD_CNT').col_htxt := 'On-Time Order Count';
      hk_sal_base_excel.tbl_column('ONT_ORD_CNT').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('ONT_ORD_CNT').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ONT_ORD_CNT').col_dsql := 'sum(nvl(t01.ord_tim,0))';
      hk_sal_base_excel.tbl_column('ONT_ORD_CNT').col_zsql := 'nvl(t01.ord_tim,0) != 0';
      hk_sal_base_excel.tbl_column('ONT_ORD_CNT').col_decp := 3;
      hk_sal_base_excel.tbl_column('ONT_ORD_CNT').col_decr := 3;
      hk_sal_base_excel.tbl_column('ONT_ORD_CNT').col_scle := 1;
      hk_sal_base_excel.tbl_column('ONT_ORD_CNT').col_ref1 := null;
      hk_sal_base_excel.tbl_column('ONT_ORD_CNT').col_ref2 := null;
      hk_sal_base_excel.tbl_column('ONT_ORD_CNT').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('ONT_ORD_CNT').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_OF_PCT').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_OF_PCT').col_htxt := 'Order Fill %';
      hk_sal_base_excel.tbl_column('PRD_OF_PCT').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_OF_PCT').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_OF_PCT').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_OF_PCT').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_OF_PCT').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_OF_PCT').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_OF_PCT').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_OF_PCT').col_ref1 := 'FIL_ORD_CNT';
      hk_sal_base_excel.tbl_column('PRD_OF_PCT').col_ref2 := 'TOT_ORD_CNT';
      hk_sal_base_excel.tbl_column('PRD_OF_PCT').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_OF_PCT').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_OT_PCT').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_OT_PCT').col_htxt := 'Order On-Time %';
      hk_sal_base_excel.tbl_column('PRD_OT_PCT').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_OT_PCT').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_OT_PCT').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_OT_PCT').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_OT_PCT').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_OT_PCT').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_OT_PCT').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_OT_PCT').col_ref1 := 'ONT_ORD_CNT';
      hk_sal_base_excel.tbl_column('PRD_OT_PCT').col_ref2 := 'TOT_ORD_CNT';
      hk_sal_base_excel.tbl_column('PRD_OT_PCT').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_OT_PCT').col_lnd2 := 'NoY';

      /*-*/
      /* Order promotional column variables
      /*-*/
      hk_sal_base_excel.tbl_column('TOT_PRM_CNT').col_tabi := 1;
      hk_sal_base_excel.tbl_column('TOT_PRM_CNT').col_htxt := 'Total Order Promotional Count';
      hk_sal_base_excel.tbl_column('TOT_PRM_CNT').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('TOT_PRM_CNT').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('TOT_PRM_CNT').col_dsql := 'sum(nvl(t01.ord_prm_tot,0))';
      hk_sal_base_excel.tbl_column('TOT_PRM_CNT').col_zsql := 'nvl(t01.ord_prm_tot,0) != 0';
      hk_sal_base_excel.tbl_column('TOT_PRM_CNT').col_decp := 3;
      hk_sal_base_excel.tbl_column('TOT_PRM_CNT').col_decr := 3;
      hk_sal_base_excel.tbl_column('TOT_PRM_CNT').col_scle := 1;
      hk_sal_base_excel.tbl_column('TOT_PRM_CNT').col_ref1 := null;
      hk_sal_base_excel.tbl_column('TOT_PRM_CNT').col_ref2 := null;
      hk_sal_base_excel.tbl_column('TOT_PRM_CNT').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('TOT_PRM_CNT').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('FIL_PRM_CNT').col_tabi := 1;
      hk_sal_base_excel.tbl_column('FIL_PRM_CNT').col_htxt := 'Filled Order Promotional Count';
      hk_sal_base_excel.tbl_column('FIL_PRM_CNT').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('FIL_PRM_CNT').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('FIL_PRM_CNT').col_dsql := 'sum(nvl(t01.ord_prm_fil,0))';
      hk_sal_base_excel.tbl_column('FIL_PRM_CNT').col_zsql := 'nvl(t01.ord_prm_fil,0) != 0';
      hk_sal_base_excel.tbl_column('FIL_PRM_CNT').col_decp := 3;
      hk_sal_base_excel.tbl_column('FIL_PRM_CNT').col_decr := 3;
      hk_sal_base_excel.tbl_column('FIL_PRM_CNT').col_scle := 1;
      hk_sal_base_excel.tbl_column('FIL_PRM_CNT').col_ref1 := null;
      hk_sal_base_excel.tbl_column('FIL_PRM_CNT').col_ref2 := null;
      hk_sal_base_excel.tbl_column('FIL_PRM_CNT').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('FIL_PRM_CNT').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('ONT_PRM_CNT').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ONT_PRM_CNT').col_htxt := 'On-Time Order Promotional Count';
      hk_sal_base_excel.tbl_column('ONT_PRM_CNT').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('ONT_PRM_CNT').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ONT_PRM_CNT').col_dsql := 'sum(nvl(t01.ord_prm_tim,0))';
      hk_sal_base_excel.tbl_column('ONT_PRM_CNT').col_zsql := 'nvl(t01.ord_prm_tim,0) != 0';
      hk_sal_base_excel.tbl_column('ONT_PRM_CNT').col_decp := 3;
      hk_sal_base_excel.tbl_column('ONT_PRM_CNT').col_decr := 3;
      hk_sal_base_excel.tbl_column('ONT_PRM_CNT').col_scle := 1;
      hk_sal_base_excel.tbl_column('ONT_PRM_CNT').col_ref1 := null;
      hk_sal_base_excel.tbl_column('ONT_PRM_CNT').col_ref2 := null;
      hk_sal_base_excel.tbl_column('ONT_PRM_CNT').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('ONT_PRM_CNT').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRM_OF_PCT').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRM_OF_PCT').col_htxt := 'Order Promotional Fill %';
      hk_sal_base_excel.tbl_column('PRM_OF_PCT').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRM_OF_PCT').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRM_OF_PCT').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRM_OF_PCT').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRM_OF_PCT').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRM_OF_PCT').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRM_OF_PCT').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRM_OF_PCT').col_ref1 := 'FIL_PRM_CNT';
      hk_sal_base_excel.tbl_column('PRM_OF_PCT').col_ref2 := 'TOT_PRM_CNT';
      hk_sal_base_excel.tbl_column('PRM_OF_PCT').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRM_OF_PCT').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRM_OT_PCT').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRM_OT_PCT').col_htxt := 'Order Promotional On-Time %';
      hk_sal_base_excel.tbl_column('PRM_OT_PCT').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRM_OT_PCT').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRM_OT_PCT').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRM_OT_PCT').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRM_OT_PCT').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRM_OT_PCT').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRM_OT_PCT').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRM_OT_PCT').col_ref1 := 'ONT_PRM_CNT';
      hk_sal_base_excel.tbl_column('PRM_OT_PCT').col_ref2 := 'TOT_PRM_CNT';
      hk_sal_base_excel.tbl_column('PRM_OT_PCT').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRM_OT_PCT').col_lnd2 := 'NoY';

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_base_data02;

end hk_csl_prd_01_excel;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_csl_prd_01_excel for pld_rep_app.hk_csl_prd_01_excel;
grant execute on hk_csl_prd_01_excel to public;
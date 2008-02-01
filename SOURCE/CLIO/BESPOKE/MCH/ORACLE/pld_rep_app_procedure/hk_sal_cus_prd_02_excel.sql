/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_sal_cus_prd_02_excel                            */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : March 2006                                         */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_sal_cus_prd_02_excel as

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
   procedure start_report(par_company_code in varchar2);
   procedure define_sheet(par_name in varchar2, par_depth in number);
   procedure start_sheet(par_htxt1 in varchar2);
   procedure retrieve_data;
   procedure end_sheet;

end hk_sal_cus_prd_02_excel;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_sal_cus_prd_02_excel as

   /*-*/
   /* Private package variables
   /*-*/
   rcd_pld_sal_cus_prd_0200 pld_sal_cus_prd_0200%rowtype;

   /*-*/
   /* Private package methods
   /*-*/
   procedure load_base_data;

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
   procedure start_report(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_pld_sal_cus_prd_0200 is 
         select *
         from pld_sal_cus_prd_0200 t01
         where t01.sap_company_code = par_company_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the format control
      /*-*/
      var_found := true;
      open csr_pld_sal_cus_prd_0200;
      fetch csr_pld_sal_cus_prd_0200 into rcd_pld_sal_cus_prd_0200;
      if csr_pld_sal_cus_prd_0200%notfound then
         var_found := false;
      end if;
      close csr_pld_sal_cus_prd_0200;
      if var_found = false then
         raise_application_error(-20000, 'Extract control row PLD_SAL_CUS_PRD_0200 not found');
      end if;

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_base_excel.start_report(par_company_code);

      /*-*/
      /* Load the base data
      /*-*/
      load_base_data;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end start_report;

   /****************************************************/
   /* This procedure performs the define sheet routine */
   /****************************************************/
   procedure define_sheet(par_name in varchar2, par_depth in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

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
   procedure start_sheet(par_htxt1 in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Start the sheet
      /*-*/
      hk_sal_base_excel.start_sheet(par_htxt1,
                                    rcd_pld_sal_cus_prd_0200.extract_status || ' ' || rcd_pld_sal_cus_prd_0200.sales_status,
                                    'Period End: ' || substr(to_char(rcd_pld_sal_cus_prd_0200.current_yyyypp,'fm000000'),1,4) || '/' || substr(to_char(rcd_pld_sal_cus_prd_0200.current_yyyypp-1,'fm000000'),5,6));

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

   /******************************************************/
   /* This procedure performs the load base data routine */
   /******************************************************/
   procedure load_base_data is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

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
      hk_sal_base_excel.tbl_main_name := 'pld_sal_cus_prd_0201 t01,material_dim t02,std_hier t03';
      hk_sal_base_excel.tbl_main_join := 't01.sap_material_code = t02.sap_material_code(+) and t01.sap_ship_to_cust_code = t03.sap_hier_cust_code(+) and t01.sap_sales_org_code = t03.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t03.sap_distbn_chnl_code(+) and t01.sap_division_code = t03.sap_division_code(+) and t01.sap_company_code = :A';

      hk_sal_base_excel.tbl_table(11).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_qty,p02_qty,p03_qty,p04_qty,p05_qty,p06_qty,p07_qty,p08_qty,p09_qty,p10_qty,p11_qty,p12_qty,p13_qty from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''AOP'') t11';
      hk_sal_base_excel.tbl_table(11).tab_join := 'and t01.sap_ship_to_cust_code = t11.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t11.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t11.sap_distbn_chnl_code(+) and t01.sap_division_code = t11.sap_division_code(+) and t01.sap_material_code = t11.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(12).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_ton,p02_ton,p03_ton,p04_ton,p05_ton,p06_ton,p07_ton,p08_ton,p09_ton,p10_ton,p11_ton,p12_ton,p13_ton from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''AOP'') t12';
      hk_sal_base_excel.tbl_table(12).tab_join := 'and t01.sap_ship_to_cust_code = t12.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t12.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t12.sap_distbn_chnl_code(+) and t01.sap_division_code = t12.sap_division_code(+) and t01.sap_material_code = t12.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(13).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_gsv,p02_gsv,p03_gsv,p04_gsv,p05_gsv,p06_gsv,p07_gsv,p08_gsv,p09_gsv,p10_gsv,p11_gsv,p12_gsv,p13_gsv from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''AOP'') t13';
      hk_sal_base_excel.tbl_table(13).tab_join := 'and t01.sap_ship_to_cust_code = t13.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t13.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t13.sap_distbn_chnl_code(+) and t01.sap_division_code = t13.sap_division_code(+) and t01.sap_material_code = t13.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(14).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_niv,p02_niv,p03_niv,p04_niv,p05_niv,p06_niv,p07_niv,p08_niv,p09_niv,p10_niv,p11_niv,p12_niv,p13_niv from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''AOP'') t14';
      hk_sal_base_excel.tbl_table(14).tab_join := 'and t01.sap_ship_to_cust_code = t14.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t14.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t14.sap_distbn_chnl_code(+) and t01.sap_division_code = t14.sap_division_code(+) and t01.sap_material_code = t14.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(21).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_qty,p02_qty,p03_qty,p04_qty,p05_qty,p06_qty,p07_qty,p08_qty,p09_qty,p10_qty,p11_qty,p12_qty,p13_qty from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''ABR'') t21';
      hk_sal_base_excel.tbl_table(21).tab_join := 'and t01.sap_ship_to_cust_code = t21.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t21.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t21.sap_distbn_chnl_code(+) and t01.sap_division_code = t21.sap_division_code(+) and t01.sap_material_code = t21.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(22).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_ton,p02_ton,p03_ton,p04_ton,p05_ton,p06_ton,p07_ton,p08_ton,p09_ton,p10_ton,p11_ton,p12_ton,p13_ton from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''ABR'') t22';
      hk_sal_base_excel.tbl_table(22).tab_join := 'and t01.sap_ship_to_cust_code = t22.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t22.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t22.sap_distbn_chnl_code(+) and t01.sap_division_code = t22.sap_division_code(+) and t01.sap_material_code = t22.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(23).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_gsv,p02_gsv,p03_gsv,p04_gsv,p05_gsv,p06_gsv,p07_gsv,p08_gsv,p09_gsv,p10_gsv,p11_gsv,p12_gsv,p13_gsv from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''ABR'') t23';
      hk_sal_base_excel.tbl_table(23).tab_join := 'and t01.sap_ship_to_cust_code = t23.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t23.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t23.sap_distbn_chnl_code(+) and t01.sap_division_code = t23.sap_division_code(+) and t01.sap_material_code = t23.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(24).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_niv,p02_niv,p03_niv,p04_niv,p05_niv,p06_niv,p07_niv,p08_niv,p09_niv,p10_niv,p11_niv,p12_niv,p13_niv from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''ABR'') t24';
      hk_sal_base_excel.tbl_table(24).tab_join := 'and t01.sap_ship_to_cust_code = t24.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t24.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t24.sap_distbn_chnl_code(+) and t01.sap_division_code = t24.sap_division_code(+) and t01.sap_material_code = t24.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(31).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_qty,p02_qty,p03_qty,p04_qty,p05_qty,p06_qty,p07_qty,p08_qty,p09_qty,p10_qty,p11_qty,p12_qty,p13_qty from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''ARB'') t31';
      hk_sal_base_excel.tbl_table(31).tab_join := 'and t01.sap_ship_to_cust_code = t31.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t31.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t31.sap_distbn_chnl_code(+) and t01.sap_division_code = t31.sap_division_code(+) and t01.sap_material_code = t31.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(32).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_ton,p02_ton,p03_ton,p04_ton,p05_ton,p06_ton,p07_ton,p08_ton,p09_ton,p10_ton,p11_ton,p12_ton,p13_ton from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''ARB'') t32';
      hk_sal_base_excel.tbl_table(32).tab_join := 'and t01.sap_ship_to_cust_code = t32.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t32.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t32.sap_distbn_chnl_code(+) and t01.sap_division_code = t32.sap_division_code(+) and t01.sap_material_code = t32.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(33).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_gsv,p02_gsv,p03_gsv,p04_gsv,p05_gsv,p06_gsv,p07_gsv,p08_gsv,p09_gsv,p10_gsv,p11_gsv,p12_gsv,p13_gsv from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''ARB'') t33';
      hk_sal_base_excel.tbl_table(33).tab_join := 'and t01.sap_ship_to_cust_code = t33.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t33.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t33.sap_distbn_chnl_code(+) and t01.sap_division_code = t33.sap_division_code(+) and t01.sap_material_code = t33.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(34).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_niv,p02_niv,p03_niv,p04_niv,p05_niv,p06_niv,p07_niv,p08_niv,p09_niv,p10_niv,p11_niv,p12_niv,p13_niv from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''ARB'') t34';
      hk_sal_base_excel.tbl_table(34).tab_join := 'and t01.sap_ship_to_cust_code = t34.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t34.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t34.sap_distbn_chnl_code(+) and t01.sap_division_code = t34.sap_division_code(+) and t01.sap_material_code = t34.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(41).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_qty,p02_qty,p03_qty,p04_qty,p05_qty,p06_qty,p07_qty,p08_qty,p09_qty,p10_qty,p11_qty,p12_qty,p13_qty from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''LYR'') t41';
      hk_sal_base_excel.tbl_table(41).tab_join := 'and t01.sap_ship_to_cust_code = t41.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t41.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t41.sap_distbn_chnl_code(+) and t01.sap_division_code = t41.sap_division_code(+) and t01.sap_material_code = t41.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(42).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_ton,p02_ton,p03_ton,p04_ton,p05_ton,p06_ton,p07_ton,p08_ton,p09_ton,p10_ton,p11_ton,p12_ton,p13_ton from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''LYR'') t42';
      hk_sal_base_excel.tbl_table(42).tab_join := 'and t01.sap_ship_to_cust_code = t42.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t42.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t42.sap_distbn_chnl_code(+) and t01.sap_division_code = t42.sap_division_code(+) and t01.sap_material_code = t42.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(43).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_gsv,p02_gsv,p03_gsv,p04_gsv,p05_gsv,p06_gsv,p07_gsv,p08_gsv,p09_gsv,p10_gsv,p11_gsv,p12_gsv,p13_gsv from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''LYR'') t43';
      hk_sal_base_excel.tbl_table(43).tab_join := 'and t01.sap_ship_to_cust_code = t43.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t43.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t43.sap_distbn_chnl_code(+) and t01.sap_division_code = t43.sap_division_code(+) and t01.sap_material_code = t43.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(44).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_niv,p02_niv,p03_niv,p04_niv,p05_niv,p06_niv,p07_niv,p08_niv,p09_niv,p10_niv,p11_niv,p12_niv,p13_niv from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''LYR'') t44';
      hk_sal_base_excel.tbl_table(44).tab_join := 'and t01.sap_ship_to_cust_code = t44.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t44.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t44.sap_distbn_chnl_code(+) and t01.sap_division_code = t44.sap_division_code(+) and t01.sap_material_code = t44.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(51).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_qty,p02_qty,p03_qty,p04_qty,p05_qty,p06_qty,p07_qty,p08_qty,p09_qty,p10_qty,p11_qty,p12_qty,p13_qty from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''TOP'') t51';
      hk_sal_base_excel.tbl_table(51).tab_join := 'and t01.sap_ship_to_cust_code = t51.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t51.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t51.sap_distbn_chnl_code(+) and t01.sap_division_code = t51.sap_division_code(+) and t01.sap_material_code = t51.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(52).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_ton,p02_ton,p03_ton,p04_ton,p05_ton,p06_ton,p07_ton,p08_ton,p09_ton,p10_ton,p11_ton,p12_ton,p13_ton from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''TOP'') t52';
      hk_sal_base_excel.tbl_table(52).tab_join := 'and t01.sap_ship_to_cust_code = t52.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t52.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t52.sap_distbn_chnl_code(+) and t01.sap_division_code = t52.sap_division_code(+) and t01.sap_material_code = t52.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(53).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_gsv,p02_gsv,p03_gsv,p04_gsv,p05_gsv,p06_gsv,p07_gsv,p08_gsv,p09_gsv,p10_gsv,p11_gsv,p12_gsv,p13_gsv from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''TOP'') t53';
      hk_sal_base_excel.tbl_table(53).tab_join := 'and t01.sap_ship_to_cust_code = t53.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t53.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t53.sap_distbn_chnl_code(+) and t01.sap_division_code = t53.sap_division_code(+) and t01.sap_material_code = t53.sap_material_code(+)';

      hk_sal_base_excel.tbl_table(54).tab_name := '(select sap_ship_to_cust_code,sap_sales_org_code,sap_distbn_chnl_code,sap_division_code,sap_material_code,p01_niv,p02_niv,p03_niv,p04_niv,p05_niv,p06_niv,p07_niv,p08_niv,p09_niv,p10_niv,p11_niv,p12_niv,p13_niv from pld_sal_cus_prd_0202 where sap_company_code = :A and dta_type = ''TOP'') t54';
      hk_sal_base_excel.tbl_table(54).tab_join := 'and t01.sap_ship_to_cust_code = t54.sap_ship_to_cust_code(+) and t01.sap_sales_org_code = t54.sap_sales_org_code(+) and t01.sap_distbn_chnl_code = t54.sap_distbn_chnl_code(+) and t01.sap_division_code = t54.sap_division_code(+) and t01.sap_material_code = t54.sap_material_code(+)';

      /*-*/
      /* Period column variables
      /*-*/
      hk_sal_base_excel.tbl_column('PRD_TY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_QTY').col_htxt := 'PRD ACT QTY';
      hk_sal_base_excel.tbl_column('PRD_TY_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_TY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_QTY').col_dsql := 'sum(nvl(t01.cur_ty_qty,0))';
      hk_sal_base_excel.tbl_column('PRD_TY_QTY').col_zsql := 'nvl(t01.cur_ty_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_TY_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PRD_TY_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PRD_TY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_TY_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_TY_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_TY_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_TY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_TON').col_htxt := 'PRD ACT TON';
      hk_sal_base_excel.tbl_column('PRD_TY_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_TY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_TON').col_dsql := 'sum(nvl(t01.cur_ty_ton,0))';
      hk_sal_base_excel.tbl_column('PRD_TY_TON').col_zsql := 'nvl(t01.cur_ty_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_TY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PRD_TY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_TY_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_TY_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_TY_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_TY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_GSV').col_htxt := 'PRD ACT GSV';
      hk_sal_base_excel.tbl_column('PRD_TY_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_TY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_GSV').col_dsql := 'sum(nvl(t01.cur_ty_gsv,0))';
      hk_sal_base_excel.tbl_column('PRD_TY_GSV').col_zsql := 'nvl(t01.cur_ty_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_TY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_TY_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_TY_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_TY_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_TY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_NIV').col_htxt := 'PRD ACT NIV';
      hk_sal_base_excel.tbl_column('PRD_TY_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_TY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_NIV').col_dsql := 'sum(nvl(t01.cur_ty_niv,0))';
      hk_sal_base_excel.tbl_column('PRD_TY_NIV').col_zsql := 'nvl(t01.cur_ty_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_TY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_TY_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_TY_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_TY_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('PRD_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_QTY').col_htxt := 'SPLY QTY';
      hk_sal_base_excel.tbl_column('PRD_LY_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_QTY').col_dsql := 'sum(nvl(t01.cur_ly_qty,0))';
      hk_sal_base_excel.tbl_column('PRD_LY_QTY').col_zsql := 'nvl(t01.cur_ly_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_LY_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PRD_LY_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PRD_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_LY_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_LY_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_LY_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_TON').col_htxt := 'SPLY TON';
      hk_sal_base_excel.tbl_column('PRD_LY_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_TON').col_dsql := 'sum(nvl(t01.cur_ly_ton,0))';
      hk_sal_base_excel.tbl_column('PRD_LY_TON').col_zsql := 'nvl(t01.cur_ly_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_LY_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PRD_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_LY_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_LY_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_LY_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_GSV').col_htxt := 'SPLY GSV';
      hk_sal_base_excel.tbl_column('PRD_LY_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_GSV').col_dsql := 'sum(nvl(t01.cur_ly_gsv,0))';
      hk_sal_base_excel.tbl_column('PRD_LY_GSV').col_zsql := 'nvl(t01.cur_ly_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_LY_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_LY_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_LY_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_NIV').col_htxt := 'SPLY NIV';
      hk_sal_base_excel.tbl_column('PRD_LY_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_NIV').col_dsql := 'sum(nvl(t01.cur_ly_niv,0))';
      hk_sal_base_excel.tbl_column('PRD_LY_NIV').col_zsql := 'nvl(t01.cur_ly_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_LY_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_LY_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_LY_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('PRD_OP_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_OP_QTY').col_htxt := 'PRD OP QTY';
      hk_sal_base_excel.tbl_column('PRD_OP_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_OP_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_OP_QTY').col_dsql := 'sum(nvl(t01.cur_op_qty,0))';
      hk_sal_base_excel.tbl_column('PRD_OP_QTY').col_zsql := 'nvl(t01.cur_op_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_OP_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PRD_OP_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PRD_OP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_OP_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_OP_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_OP_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_OP_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_OP_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_OP_TON').col_htxt := 'PRD OP TON';
      hk_sal_base_excel.tbl_column('PRD_OP_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_OP_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_OP_TON').col_dsql := 'sum(nvl(t01.cur_op_ton,0))';
      hk_sal_base_excel.tbl_column('PRD_OP_TON').col_zsql := 'nvl(t01.cur_op_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_OP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_OP_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PRD_OP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_OP_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_OP_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_OP_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_OP_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_OP_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_OP_GSV').col_htxt := 'PRD OP GSV';
      hk_sal_base_excel.tbl_column('PRD_OP_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_OP_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_OP_GSV').col_dsql := 'sum(nvl(t01.cur_op_gsv,0))';
      hk_sal_base_excel.tbl_column('PRD_OP_GSV').col_zsql := 'nvl(t01.cur_op_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_OP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_OP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_OP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_OP_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_OP_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_OP_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_OP_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_OP_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_OP_NIV').col_htxt := 'PRD OP NIV';
      hk_sal_base_excel.tbl_column('PRD_OP_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_OP_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_OP_NIV').col_dsql := 'sum(nvl(t01.cur_op_niv,0))';
      hk_sal_base_excel.tbl_column('PRD_OP_NIV').col_zsql := 'nvl(t01.cur_op_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_OP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_OP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_OP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_OP_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_OP_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_OP_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_OP_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('PRD_BR_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_BR_QTY').col_htxt := 'PRD BR QTY';
      hk_sal_base_excel.tbl_column('PRD_BR_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_BR_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_BR_QTY').col_dsql := 'sum(nvl(t01.cur_br_qty,0))';
      hk_sal_base_excel.tbl_column('PRD_BR_QTY').col_zsql := 'nvl(t01.cur_br_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_BR_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PRD_BR_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PRD_BR_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_BR_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_BR_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_BR_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_BR_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_BR_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_BR_TON').col_htxt := 'PRD BR TON';
      hk_sal_base_excel.tbl_column('PRD_BR_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_BR_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_BR_TON').col_dsql := 'sum(nvl(t01.cur_br_ton,0))';
      hk_sal_base_excel.tbl_column('PRD_BR_TON').col_zsql := 'nvl(t01.cur_br_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_BR_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_BR_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PRD_BR_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_BR_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_BR_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_BR_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_BR_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_BR_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_BR_GSV').col_htxt := 'PRD BR GSV';
      hk_sal_base_excel.tbl_column('PRD_BR_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_BR_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_BR_GSV').col_dsql := 'sum(nvl(t01.cur_br_gsv,0))';
      hk_sal_base_excel.tbl_column('PRD_BR_GSV').col_zsql := 'nvl(t01.cur_br_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_BR_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_BR_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_BR_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_BR_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_BR_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_BR_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_BR_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_BR_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_BR_NIV').col_htxt := 'PRD BR NIV';
      hk_sal_base_excel.tbl_column('PRD_BR_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_BR_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_BR_NIV').col_dsql := 'sum(nvl(t01.cur_br_niv,0))';
      hk_sal_base_excel.tbl_column('PRD_BR_NIV').col_zsql := 'nvl(t01.cur_br_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_BR_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_BR_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_BR_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_BR_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_BR_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_BR_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_BR_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('PRD_RB_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_RB_QTY').col_htxt := 'PRD ROB QTY';
      hk_sal_base_excel.tbl_column('PRD_RB_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_RB_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_RB_QTY').col_dsql := 'sum(nvl(t01.cur_rb_qty,0))';
      hk_sal_base_excel.tbl_column('PRD_RB_QTY').col_zsql := 'nvl(t01.cur_rb_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_RB_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PRD_RB_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PRD_RB_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_RB_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_RB_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_RB_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_RB_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_RB_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_RB_TON').col_htxt := 'PRD ROB TON';
      hk_sal_base_excel.tbl_column('PRD_RB_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_RB_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_RB_TON').col_dsql := 'sum(nvl(t01.cur_rb_ton,0))';
      hk_sal_base_excel.tbl_column('PRD_RB_TON').col_zsql := 'nvl(t01.cur_rb_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_RB_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_RB_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PRD_RB_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_RB_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_RB_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_RB_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_RB_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_RB_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_RB_GSV').col_htxt := 'PRD ROB GSV';
      hk_sal_base_excel.tbl_column('PRD_RB_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_RB_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_RB_GSV').col_dsql := 'sum(nvl(t01.cur_rb_gsv,0))';
      hk_sal_base_excel.tbl_column('PRD_RB_GSV').col_zsql := 'nvl(t01.cur_rb_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_RB_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_RB_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_RB_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_RB_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_RB_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_RB_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_RB_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD_RB_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_RB_NIV').col_htxt := 'PRD ROB NIV';
      hk_sal_base_excel.tbl_column('PRD_RB_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD_RB_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_RB_NIV').col_dsql := 'sum(nvl(t01.cur_rb_niv,0))';
      hk_sal_base_excel.tbl_column('PRD_RB_NIV').col_zsql := 'nvl(t01.cur_rb_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD_RB_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_RB_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_RB_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_RB_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD_RB_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD_RB_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD_RB_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('PRD_TY_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_QTY').col_htxt := 'PRD QTY ACT % SPLY';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_QTY').col_ref1 := 'PRD_TY_QTY';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_QTY').col_ref2 := 'PRD_LY_QTY';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_TON').col_htxt := 'PRD TON ACT % SPLY';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_TON').col_ref1 := 'PRD_TY_TON';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_TON').col_ref2 := 'PRD_LY_TON';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_GSV').col_htxt := 'PRD GSV ACT % SPLY';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_GSV').col_ref1 := 'PRD_TY_GSV';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_GSV').col_ref2 := 'PRD_LY_GSV';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_NIV').col_htxt := 'PRD NIV ACT % SPLY';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_LY_NIV').col_ref1 := 'PRD_TY_NIV';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_NIV').col_ref2 := 'PRD_LY_NIV';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_LY_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('PRD_TY_OP_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_QTY').col_htxt := 'PRD QTY ACT % OP';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_QTY').col_ref1 := 'PRD_TY_QTY';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_QTY').col_ref2 := 'PRD_OP_QTY';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_OP_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_TON').col_htxt := 'PRD TON ACT % OP';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_TON').col_ref1 := 'PRD_TY_TON';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_TON').col_ref2 := 'PRD_OP_TON';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_OP_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_GSV').col_htxt := 'PRD GSV ACT % OP';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_GSV').col_ref1 := 'PRD_TY_GSV';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_GSV').col_ref2 := 'PRD_OP_GSV';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_OP_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_NIV').col_htxt := 'PRD NIV ACT % OP';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_OP_NIV').col_ref1 := 'PRD_TY_NIV';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_NIV').col_ref2 := 'PRD_OP_NIV';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_OP_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('PRD_TY_BR_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_QTY').col_htxt := 'PRD QTY ACT % BR';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_QTY').col_ref1 := 'PRD_TY_QTY';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_QTY').col_ref2 := 'PRD_BR_QTY';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_BR_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_TON').col_htxt := 'PRD TON ACT % BR';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_TON').col_ref1 := 'PRD_TY_TON';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_TON').col_ref2 := 'PRD_BR_TON';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_BR_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_GSV').col_htxt := 'PRD GSV ACT % BR';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_GSV').col_ref1 := 'PRD_TY_GSV';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_GSV').col_ref2 := 'PRD_BR_GSV';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_BR_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_NIV').col_htxt := 'PRD NIV ACT % BR';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_BR_NIV').col_ref1 := 'PRD_TY_NIV';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_NIV').col_ref2 := 'PRD_BR_NIV';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_BR_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('PRD_TY_RB_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_QTY').col_htxt := 'PRD QTY ACT % ROB';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_QTY').col_ref1 := 'PRD_TY_QTY';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_QTY').col_ref2 := 'PRD_RB_QTY';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_RB_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_TON').col_htxt := 'PRD TON ACT % ROB';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_TON').col_ref1 := 'PRD_TY_TON';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_TON').col_ref2 := 'PRD_RB_TON';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_RB_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_GSV').col_htxt := 'PRD GSV ACT % ROB';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_GSV').col_ref1 := 'PRD_TY_GSV';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_GSV').col_ref2 := 'PRD_RB_GSV';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_RB_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_NIV').col_htxt := 'PRD NIV ACT % ROB';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_RB_NIV').col_ref1 := 'PRD_TY_NIV';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_NIV').col_ref2 := 'PRD_RB_NIV';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_RB_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('PRD_TY_QTY_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_QTY_SHR').col_htxt := 'PRD QTY ACT % Share';
      hk_sal_base_excel.tbl_column('PRD_TY_QTY_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PRD_TY_QTY_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_QTY_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_QTY_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_QTY_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_QTY_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_QTY_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_QTY_SHR').col_ref1 := 'PRD_TY_QTY';
      hk_sal_base_excel.tbl_column('PRD_TY_QTY_SHR').col_ref2 := 'PRD_TY_QTY';
      hk_sal_base_excel.tbl_column('PRD_TY_QTY_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_QTY_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_TON_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_TON_SHR').col_htxt := 'PRD QTY ACT % Share';
      hk_sal_base_excel.tbl_column('PRD_TY_TON_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PRD_TY_TON_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_TON_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_TON_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_TON_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_TON_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_TON_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_TON_SHR').col_ref1 := 'PRD_TY_TON';
      hk_sal_base_excel.tbl_column('PRD_TY_TON_SHR').col_ref2 := 'PRD_TY_TON';
      hk_sal_base_excel.tbl_column('PRD_TY_TON_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_TON_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_GSV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_GSV_SHR').col_htxt := 'PRD GSV ACT % Share';
      hk_sal_base_excel.tbl_column('PRD_TY_GSV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PRD_TY_GSV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_GSV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_GSV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_GSV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_GSV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_GSV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_GSV_SHR').col_ref1 := 'PRD_TY_GSV';
      hk_sal_base_excel.tbl_column('PRD_TY_GSV_SHR').col_ref2 := 'PRD_TY_GSV';
      hk_sal_base_excel.tbl_column('PRD_TY_GSV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_GSV_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_TY_NIV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_NIV_SHR').col_htxt := 'PRD NIV ACT % Share';
      hk_sal_base_excel.tbl_column('PRD_TY_NIV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PRD_TY_NIV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_NIV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_TY_NIV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_TY_NIV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_NIV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_TY_NIV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_TY_NIV_SHR').col_ref1 := 'PRD_TY_NIV';
      hk_sal_base_excel.tbl_column('PRD_TY_NIV_SHR').col_ref2 := 'PRD_TY_NIV';
      hk_sal_base_excel.tbl_column('PRD_TY_NIV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_TY_NIV_SHR').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('PRD_LY_QTY_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_QTY_SHR').col_htxt := 'SPLY QTY % Share';
      hk_sal_base_excel.tbl_column('PRD_LY_QTY_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PRD_LY_QTY_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_QTY_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_LY_QTY_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_LY_QTY_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_LY_QTY_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_LY_QTY_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_QTY_SHR').col_ref1 := 'PRD_LY_QTY';
      hk_sal_base_excel.tbl_column('PRD_LY_QTY_SHR').col_ref2 := 'PRD_LY_QTY';
      hk_sal_base_excel.tbl_column('PRD_LY_QTY_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_LY_QTY_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_LY_TON_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_TON_SHR').col_htxt := 'SPLY QTY % Share';
      hk_sal_base_excel.tbl_column('PRD_LY_TON_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PRD_LY_TON_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_TON_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_LY_TON_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_LY_TON_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_LY_TON_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_LY_TON_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_TON_SHR').col_ref1 := 'PRD_LY_TON';
      hk_sal_base_excel.tbl_column('PRD_LY_TON_SHR').col_ref2 := 'PRD_LY_TON';
      hk_sal_base_excel.tbl_column('PRD_LY_TON_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_LY_TON_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_LY_GSV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_GSV_SHR').col_htxt := 'SPLY GSV % Share';
      hk_sal_base_excel.tbl_column('PRD_LY_GSV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PRD_LY_GSV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_GSV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_LY_GSV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_LY_GSV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_LY_GSV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_LY_GSV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_GSV_SHR').col_ref1 := 'PRD_LY_GSV';
      hk_sal_base_excel.tbl_column('PRD_LY_GSV_SHR').col_ref2 := 'PRD_LY_GSV';
      hk_sal_base_excel.tbl_column('PRD_LY_GSV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_LY_GSV_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PRD_LY_NIV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_NIV_SHR').col_htxt := 'SPLY NIV % Share';
      hk_sal_base_excel.tbl_column('PRD_LY_NIV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PRD_LY_NIV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_NIV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PRD_LY_NIV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PRD_LY_NIV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD_LY_NIV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD_LY_NIV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD_LY_NIV_SHR').col_ref1 := 'PRD_LY_NIV';
      hk_sal_base_excel.tbl_column('PRD_LY_NIV_SHR').col_ref2 := 'PRD_LY_NIV';
      hk_sal_base_excel.tbl_column('PRD_LY_NIV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PRD_LY_NIV_SHR').col_lnd2 := 'NoY';

      /*-*/
      /* Year to date column variables
      /*-*/
      hk_sal_base_excel.tbl_column('YTD_TY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_QTY').col_htxt := 'YTD ACT QTY';
      hk_sal_base_excel.tbl_column('YTD_TY_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTD_TY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_QTY').col_dsql := 'sum(nvl(t01.ytd_ty_qty,0))';
      hk_sal_base_excel.tbl_column('YTD_TY_QTY').col_zsql := 'nvl(t01.ytd_ty_qty,0) != 0';
      hk_sal_base_excel.tbl_column('YTD_TY_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('YTD_TY_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('YTD_TY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTD_TY_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTD_TY_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTD_TY_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTD_TY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_TON').col_htxt := 'YTD ACT TON';
      hk_sal_base_excel.tbl_column('YTD_TY_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTD_TY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_TON').col_dsql := 'sum(nvl(t01.ytd_ty_ton,0))';
      hk_sal_base_excel.tbl_column('YTD_TY_TON').col_zsql := 'nvl(t01.ytd_ty_ton,0) != 0';
      hk_sal_base_excel.tbl_column('YTD_TY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('YTD_TY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTD_TY_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTD_TY_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTD_TY_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTD_TY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_GSV').col_htxt := 'YTD ACT GSV';
      hk_sal_base_excel.tbl_column('YTD_TY_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTD_TY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_GSV').col_dsql := 'sum(nvl(t01.ytd_ty_gsv,0))';
      hk_sal_base_excel.tbl_column('YTD_TY_GSV').col_zsql := 'nvl(t01.ytd_ty_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('YTD_TY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTD_TY_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTD_TY_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTD_TY_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTD_TY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_NIV').col_htxt := 'YTD ACT NIV';
      hk_sal_base_excel.tbl_column('YTD_TY_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTD_TY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_NIV').col_dsql := 'sum(nvl(t01.ytd_ty_niv,0))';
      hk_sal_base_excel.tbl_column('YTD_TY_NIV').col_zsql := 'nvl(t01.ytd_ty_niv,0) != 0';
      hk_sal_base_excel.tbl_column('YTD_TY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTD_TY_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTD_TY_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTD_TY_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('YTD_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_QTY').col_htxt := 'YTD LY QTY';
      hk_sal_base_excel.tbl_column('YTD_LY_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTD_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_QTY').col_dsql := 'sum(nvl(t01.ytd_ly_qty,0))';
      hk_sal_base_excel.tbl_column('YTD_LY_QTY').col_zsql := 'nvl(t01.ytd_ly_qty,0) != 0';
      hk_sal_base_excel.tbl_column('YTD_LY_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('YTD_LY_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('YTD_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTD_LY_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTD_LY_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTD_LY_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTD_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_TON').col_htxt := 'YTD LY TON';
      hk_sal_base_excel.tbl_column('YTD_LY_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTD_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_TON').col_dsql := 'sum(nvl(t01.ytd_ly_ton,0))';
      hk_sal_base_excel.tbl_column('YTD_LY_TON').col_zsql := 'nvl(t01.ytd_ly_ton,0) != 0';
      hk_sal_base_excel.tbl_column('YTD_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_LY_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('YTD_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTD_LY_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTD_LY_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTD_LY_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTD_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_GSV').col_htxt := 'YTD LY GSV';
      hk_sal_base_excel.tbl_column('YTD_LY_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTD_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_GSV').col_dsql := 'sum(nvl(t01.ytd_ly_gsv,0))';
      hk_sal_base_excel.tbl_column('YTD_LY_GSV').col_zsql := 'nvl(t01.ytd_ly_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('YTD_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTD_LY_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTD_LY_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTD_LY_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTD_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_NIV').col_htxt := 'YTD LY NIV';
      hk_sal_base_excel.tbl_column('YTD_LY_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTD_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_NIV').col_dsql := 'sum(nvl(t01.ytd_ly_niv,0))';
      hk_sal_base_excel.tbl_column('YTD_LY_NIV').col_zsql := 'nvl(t01.ytd_ly_niv,0) != 0';
      hk_sal_base_excel.tbl_column('YTD_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTD_LY_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTD_LY_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTD_LY_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('YTD_OP_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_OP_QTY').col_htxt := 'YTD OP QTY';
      hk_sal_base_excel.tbl_column('YTD_OP_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTD_OP_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_OP_QTY').col_dsql := 'sum(nvl(t01.ytd_op_qty,0))';
      hk_sal_base_excel.tbl_column('YTD_OP_QTY').col_zsql := 'nvl(t01.ytd_op_qty,0) != 0';
      hk_sal_base_excel.tbl_column('YTD_OP_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('YTD_OP_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('YTD_OP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_OP_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTD_OP_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTD_OP_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTD_OP_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTD_OP_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_OP_TON').col_htxt := 'YTD OP TON';
      hk_sal_base_excel.tbl_column('YTD_OP_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTD_OP_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_OP_TON').col_dsql := 'sum(nvl(t01.ytd_op_ton,0))';
      hk_sal_base_excel.tbl_column('YTD_OP_TON').col_zsql := 'nvl(t01.ytd_op_ton,0) != 0';
      hk_sal_base_excel.tbl_column('YTD_OP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_OP_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('YTD_OP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_OP_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTD_OP_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTD_OP_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTD_OP_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTD_OP_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_OP_GSV').col_htxt := 'YTD OP GSV';
      hk_sal_base_excel.tbl_column('YTD_OP_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTD_OP_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_OP_GSV').col_dsql := 'sum(nvl(t01.ytd_op_gsv,0))';
      hk_sal_base_excel.tbl_column('YTD_OP_GSV').col_zsql := 'nvl(t01.ytd_op_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('YTD_OP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_OP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_OP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_OP_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTD_OP_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTD_OP_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTD_OP_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTD_OP_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_OP_NIV').col_htxt := 'YTD OP NIV';
      hk_sal_base_excel.tbl_column('YTD_OP_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTD_OP_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_OP_NIV').col_dsql := 'sum(nvl(t01.ytd_op_niv,0))';
      hk_sal_base_excel.tbl_column('YTD_OP_NIV').col_zsql := 'nvl(t01.ytd_op_niv,0) != 0';
      hk_sal_base_excel.tbl_column('YTD_OP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_OP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_OP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_OP_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTD_OP_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTD_OP_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTD_OP_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('YTD_TY_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_QTY').col_htxt := 'YTD QTY ACT % LY';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_QTY').col_ref1 := 'YTD_TY_QTY';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_QTY').col_ref2 := 'YTD_LY_QTY';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTD_TY_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_TON').col_htxt := 'YTD TON ACT % LY';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_TON').col_ref1 := 'YTD_TY_TON';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_TON').col_ref2 := 'YTD_LY_TON';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTD_TY_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_GSV').col_htxt := 'YTD GSV ACT % LY';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_GSV').col_ref1 := 'YTD_TY_GSV';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_GSV').col_ref2 := 'YTD_LY_GSV';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTD_TY_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_NIV').col_htxt := 'YTD NIV ACT % LY';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_LY_NIV').col_ref1 := 'YTD_TY_NIV';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_NIV').col_ref2 := 'YTD_LY_NIV';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_TY_LY_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YTD_TY_OP_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_QTY').col_htxt := 'YTD QTY ACT % OP';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_QTY').col_ref1 := 'YTD_TY_GSV';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_QTY').col_ref2 := 'YTD_OP_GSV';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTD_TY_OP_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_TON').col_htxt := 'YTD TON ACT % OP';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_TON').col_ref1 := 'YTD_TY_TON';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_TON').col_ref2 := 'YTD_OP_TON';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTD_TY_OP_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_GSV').col_htxt := 'YTD GSV ACT % OP';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_GSV').col_ref1 := 'YTD_TY_GSV';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_GSV').col_ref2 := 'YTD_OP_GSV';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTD_TY_OP_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_NIV').col_htxt := 'YTD NIV ACT % OP';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_OP_NIV').col_ref1 := 'YTD_TY_NIV';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_NIV').col_ref2 := 'YTD_OP_NIV';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_TY_OP_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YTD_TY_QTY_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_QTY_SHR').col_htxt := 'YTD ACT QTY % Share';
      hk_sal_base_excel.tbl_column('YTD_TY_QTY_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YTD_TY_QTY_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_QTY_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_TY_QTY_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_TY_QTY_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_QTY_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_QTY_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_QTY_SHR').col_ref1 := 'YTD_TY_QTY';
      hk_sal_base_excel.tbl_column('YTD_TY_QTY_SHR').col_ref2 := 'YTD_TY_QTY';
      hk_sal_base_excel.tbl_column('YTD_TY_QTY_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_TY_QTY_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTD_TY_TON_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_TON_SHR').col_htxt := 'YTD ACT QTY % Share';
      hk_sal_base_excel.tbl_column('YTD_TY_TON_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YTD_TY_TON_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_TON_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_TY_TON_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_TY_TON_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_TON_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_TON_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_TON_SHR').col_ref1 := 'YTD_TY_TON';
      hk_sal_base_excel.tbl_column('YTD_TY_TON_SHR').col_ref2 := 'YTD_TY_TON';
      hk_sal_base_excel.tbl_column('YTD_TY_TON_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_TY_TON_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTD_TY_GSV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_GSV_SHR').col_htxt := 'YTD ACT GSV % Share';
      hk_sal_base_excel.tbl_column('YTD_TY_GSV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YTD_TY_GSV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_GSV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_TY_GSV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_TY_GSV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_GSV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_GSV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_GSV_SHR').col_ref1 := 'YTD_TY_GSV';
      hk_sal_base_excel.tbl_column('YTD_TY_GSV_SHR').col_ref2 := 'YTD_TY_GSV';
      hk_sal_base_excel.tbl_column('YTD_TY_GSV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_TY_GSV_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTD_TY_NIV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_NIV_SHR').col_htxt := 'YTD ACT NIV % Share';
      hk_sal_base_excel.tbl_column('YTD_TY_NIV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YTD_TY_NIV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_NIV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_TY_NIV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_TY_NIV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_NIV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_TY_NIV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_TY_NIV_SHR').col_ref1 := 'YTD_TY_NIV';
      hk_sal_base_excel.tbl_column('YTD_TY_NIV_SHR').col_ref2 := 'YTD_TY_NIV';
      hk_sal_base_excel.tbl_column('YTD_TY_NIV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_TY_NIV_SHR').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YTD_LY_QTY_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_QTY_SHR').col_htxt := 'YTD LY QTY % Share';
      hk_sal_base_excel.tbl_column('YTD_LY_QTY_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YTD_LY_QTY_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_QTY_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_LY_QTY_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_LY_QTY_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_LY_QTY_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_LY_QTY_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_QTY_SHR').col_ref1 := 'YTD_LY_QTY';
      hk_sal_base_excel.tbl_column('YTD_LY_QTY_SHR').col_ref2 := 'YTD_LY_QTY';
      hk_sal_base_excel.tbl_column('YTD_LY_QTY_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_LY_QTY_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTD_LY_TON_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_TON_SHR').col_htxt := 'YTD LY QTY % Share';
      hk_sal_base_excel.tbl_column('YTD_LY_TON_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YTD_LY_TON_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_TON_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_LY_TON_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_LY_TON_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_LY_TON_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_LY_TON_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_TON_SHR').col_ref1 := 'YTD_LY_TON';
      hk_sal_base_excel.tbl_column('YTD_LY_TON_SHR').col_ref2 := 'YTD_LY_TON';
      hk_sal_base_excel.tbl_column('YTD_LY_TON_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_LY_TON_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTD_LY_GSV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_GSV_SHR').col_htxt := 'YTD LY GSV % Share';
      hk_sal_base_excel.tbl_column('YTD_LY_GSV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YTD_LY_GSV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_GSV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_LY_GSV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_LY_GSV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_LY_GSV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_LY_GSV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_GSV_SHR').col_ref1 := 'YTD_LY_GSV';
      hk_sal_base_excel.tbl_column('YTD_LY_GSV_SHR').col_ref2 := 'YTD_LY_GSV';
      hk_sal_base_excel.tbl_column('YTD_LY_GSV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_LY_GSV_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTD_LY_NIV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_NIV_SHR').col_htxt := 'YTD LY NIV % Share';
      hk_sal_base_excel.tbl_column('YTD_LY_NIV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YTD_LY_NIV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_NIV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTD_LY_NIV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTD_LY_NIV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTD_LY_NIV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTD_LY_NIV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTD_LY_NIV_SHR').col_ref1 := 'YTD_LY_NIV';
      hk_sal_base_excel.tbl_column('YTD_LY_NIV_SHR').col_ref2 := 'YTD_LY_NIV';
      hk_sal_base_excel.tbl_column('YTD_LY_NIV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTD_LY_NIV_SHR').col_lnd2 := 'NoY';

      /*-*/
      /* Year to go column variables
      /*-*/
      hk_sal_base_excel.tbl_column('YTG_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_LY_QTY').col_htxt := 'YTG LY QTY';
      hk_sal_base_excel.tbl_column('YTG_LY_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_LY_QTY').col_dsql := 'sum(nvl(t01.ytg_ly_qty,0))';
      hk_sal_base_excel.tbl_column('YTG_LY_QTY').col_zsql := 'nvl(t01.ytg_ly_qty,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_LY_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('YTG_LY_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('YTG_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_LY_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_LY_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_LY_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_LY_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTG_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_LY_TON').col_htxt := 'YTG LY TON';
      hk_sal_base_excel.tbl_column('YTG_LY_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_LY_TON').col_dsql := 'sum(nvl(t01.ytg_ly_ton,0))';
      hk_sal_base_excel.tbl_column('YTG_LY_TON').col_zsql := 'nvl(t01.ytg_ly_ton,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_LY_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('YTG_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_LY_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_LY_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_LY_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_LY_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTG_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_LY_GSV').col_htxt := 'YTG LY GSV';
      hk_sal_base_excel.tbl_column('YTG_LY_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_LY_GSV').col_dsql := 'sum(nvl(t01.ytg_ly_gsv,0))';
      hk_sal_base_excel.tbl_column('YTG_LY_GSV').col_zsql := 'nvl(t01.ytg_ly_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_LY_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_LY_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_LY_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_LY_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTG_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_LY_NIV').col_htxt := 'YTG LY NIV';
      hk_sal_base_excel.tbl_column('YTG_LY_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_LY_NIV').col_dsql := 'sum(nvl(t01.ytg_ly_niv,0))';
      hk_sal_base_excel.tbl_column('YTG_LY_NIV').col_zsql := 'nvl(t01.ytg_ly_niv,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_LY_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_LY_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_LY_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_LY_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('YTG_OP_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_QTY').col_htxt := 'YTG OP QTY';
      hk_sal_base_excel.tbl_column('YTG_OP_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_OP_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_QTY').col_dsql := 'sum(nvl(t01.ytg_op_qty,0))';
      hk_sal_base_excel.tbl_column('YTG_OP_QTY').col_zsql := 'nvl(t01.ytg_op_qty,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_OP_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('YTG_OP_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('YTG_OP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_OP_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_OP_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_OP_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTG_OP_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_TON').col_htxt := 'YTG OP TON';
      hk_sal_base_excel.tbl_column('YTG_OP_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_OP_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_TON').col_dsql := 'sum(nvl(t01.ytg_op_ton,0))';
      hk_sal_base_excel.tbl_column('YTG_OP_TON').col_zsql := 'nvl(t01.ytg_op_ton,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_OP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_OP_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('YTG_OP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_OP_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_OP_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_OP_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTG_OP_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_GSV').col_htxt := 'YTG OP GSV';
      hk_sal_base_excel.tbl_column('YTG_OP_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_OP_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_GSV').col_dsql := 'sum(nvl(t01.ytg_op_gsv,0))';
      hk_sal_base_excel.tbl_column('YTG_OP_GSV').col_zsql := 'nvl(t01.ytg_op_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_OP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_OP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_OP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_OP_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_OP_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_OP_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTG_OP_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_NIV').col_htxt := 'YTG OP NIV';
      hk_sal_base_excel.tbl_column('YTG_OP_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_OP_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_NIV').col_dsql := 'sum(nvl(t01.ytg_op_niv,0))';
      hk_sal_base_excel.tbl_column('YTG_OP_NIV').col_zsql := 'nvl(t01.ytg_op_niv,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_OP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_OP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_OP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_OP_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_OP_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_OP_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('YTG_BR_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_QTY').col_htxt := 'YTG BR QTY';
      hk_sal_base_excel.tbl_column('YTG_BR_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_BR_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_QTY').col_dsql := 'sum(nvl(t01.ytg_br_qty,0))';
      hk_sal_base_excel.tbl_column('YTG_BR_QTY').col_zsql := 'nvl(t01.ytg_br_qty,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_BR_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('YTG_BR_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('YTG_BR_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_BR_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_BR_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_BR_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTG_BR_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_TON').col_htxt := 'YTG BR TON';
      hk_sal_base_excel.tbl_column('YTG_BR_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_BR_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_TON').col_dsql := 'sum(nvl(t01.ytg_br_ton,0))';
      hk_sal_base_excel.tbl_column('YTG_BR_TON').col_zsql := 'nvl(t01.ytg_br_ton,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_BR_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('YTG_BR_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_BR_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_BR_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_BR_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTG_BR_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_GSV').col_htxt := 'YTG BR GSV';
      hk_sal_base_excel.tbl_column('YTG_BR_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_BR_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_GSV').col_dsql := 'sum(nvl(t01.ytg_br_gsv,0))';
      hk_sal_base_excel.tbl_column('YTG_BR_GSV').col_zsql := 'nvl(t01.ytg_br_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_BR_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_BR_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_BR_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_BR_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTG_BR_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_NIV').col_htxt := 'YTG BR NIV';
      hk_sal_base_excel.tbl_column('YTG_BR_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_BR_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_NIV').col_dsql := 'sum(nvl(t01.ytg_br_niv,0))';
      hk_sal_base_excel.tbl_column('YTG_BR_NIV').col_zsql := 'nvl(t01.ytg_br_niv,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_BR_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_BR_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_BR_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_BR_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('YTG_RB_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_QTY').col_htxt := 'YTG ROB QTY';
      hk_sal_base_excel.tbl_column('YTG_RB_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_RB_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_QTY').col_dsql := 'sum(nvl(t01.ytg_rb_qty,0))';
      hk_sal_base_excel.tbl_column('YTG_RB_QTY').col_zsql := 'nvl(t01.ytg_rb_qty,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_RB_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('YTG_RB_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('YTG_RB_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_RB_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_RB_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_RB_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTG_RB_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_TON').col_htxt := 'YTG ROB TON';
      hk_sal_base_excel.tbl_column('YTG_RB_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_RB_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_TON').col_dsql := 'sum(nvl(t01.ytg_rb_ton,0))';
      hk_sal_base_excel.tbl_column('YTG_RB_TON').col_zsql := 'nvl(t01.ytg_rb_ton,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_RB_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('YTG_RB_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_RB_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_RB_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_RB_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTG_RB_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_GSV').col_htxt := 'YTG ROB GSV';
      hk_sal_base_excel.tbl_column('YTG_RB_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_RB_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_GSV').col_dsql := 'sum(nvl(t01.ytg_rb_gsv,0))';
      hk_sal_base_excel.tbl_column('YTG_RB_GSV').col_zsql := 'nvl(t01.ytg_rb_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_RB_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_RB_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_RB_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_RB_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YTG_RB_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_NIV').col_htxt := 'YTG ROB NIV';
      hk_sal_base_excel.tbl_column('YTG_RB_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YTG_RB_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_NIV').col_dsql := 'sum(nvl(t01.ytg_rb_niv,0))';
      hk_sal_base_excel.tbl_column('YTG_RB_NIV').col_zsql := 'nvl(t01.ytg_rb_niv,0) != 0';
      hk_sal_base_excel.tbl_column('YTG_RB_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YTG_RB_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YTG_RB_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YTG_RB_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('YTG_OP_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_QTY').col_htxt := 'YTG QTY OP % LY';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_QTY').col_ref1 := 'YTG_OP_QTY';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_QTY').col_ref2 := 'YTG_LY_QTY';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_OP_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_TON').col_htxt := 'YTG TON OP % LY';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_TON').col_ref1 := 'YTG_OP_TON';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_TON').col_ref2 := 'YTG_LY_TON';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_OP_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_GSV').col_htxt := 'YTG GSV OP % LY';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_GSV').col_ref1 := 'YTG_OP_GSV';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_GSV').col_ref2 := 'YTG_LY_GSV';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_OP_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_NIV').col_htxt := 'YTG NIV OP % LY';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_OP_LY_NIV').col_ref1 := 'YTG_OP_NIV';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_NIV').col_ref2 := 'YTG_LY_NIV';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_OP_LY_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YTG_BR_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_QTY').col_htxt := 'YTG QTY BR % LY';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_QTY').col_ref1 := 'YTG_BR_QTY';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_QTY').col_ref2 := 'YTG_LY_QTY';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_BR_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_TON').col_htxt := 'YTG TON BR % LY';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_TON').col_ref1 := 'YTG_BR_TON';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_TON').col_ref2 := 'YTG_LY_TON';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_BR_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_GSV').col_htxt := 'YTG GSV BR % LY';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_GSV').col_ref1 := 'YTG_BR_GSV';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_GSV').col_ref2 := 'YTG_LY_GSV';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_BR_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_NIV').col_htxt := 'YTG NIV BR % LY';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_LY_NIV').col_ref1 := 'YTG_BR_NIV';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_NIV').col_ref2 := 'YTG_LY_NIV';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_BR_LY_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YTG_RB_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_QTY').col_htxt := 'YTG QTY ROB % LY';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_QTY').col_ref1 := 'YTG_RB_QTY';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_QTY').col_ref2 := 'YTG_LY_QTY';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_RB_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_TON').col_htxt := 'YTG TON ROB % LY';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_TON').col_ref1 := 'YTG_RB_TON';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_TON').col_ref2 := 'YTG_LY_TON';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_RB_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_GSV').col_htxt := 'YTG GSV ROB % LY';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_GSV').col_ref1 := 'YTG_RB_GSV';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_GSV').col_ref2 := 'YTG_LY_GSV';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_RB_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_NIV').col_htxt := 'YTG NIV ROB % LY';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_LY_NIV').col_ref1 := 'YTG_RB_NIV';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_NIV').col_ref2 := 'YTG_LY_NIV';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_RB_LY_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YTG_BR_OP_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_QTY').col_htxt := 'YTG QTY BR % OP';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_QTY').col_ref1 := 'YTG_BR_QTY';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_QTY').col_ref2 := 'YTG_OP_QTY';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_BR_OP_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_TON').col_htxt := 'YTG TON BR % OP';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_TON').col_ref1 := 'YTG_BR_TON';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_TON').col_ref2 := 'YTG_OP_TON';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_BR_OP_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_GSV').col_htxt := 'YTG GSV BR % OP';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_GSV').col_ref1 := 'YTG_BR_GSV';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_GSV').col_ref2 := 'YTG_OP_GSV';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_BR_OP_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_NIV').col_htxt := 'YTG NIV BR % OP';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_BR_OP_NIV').col_ref1 := 'YTG_BR_NIV';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_NIV').col_ref2 := 'YTG_OP_NIV';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_BR_OP_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YTG_RB_OP_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_QTY').col_htxt := 'YTG QTY ROB % OP';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_QTY').col_ref1 := 'YTG_RB_QTY';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_QTY').col_ref2 := 'YTG_OP_QTY';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_RB_OP_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_TON').col_htxt := 'YTG TON ROB % OP';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_TON').col_ref1 := 'YTG_RB_TON';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_TON').col_ref2 := 'YTG_OP_TON';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_RB_OP_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_GSV').col_htxt := 'YTG GSV ROB % OP';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_GSV').col_ref1 := 'YTG_RB_GSV';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_GSV').col_ref2 := 'YTG_OP_GSV';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YTG_RB_OP_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_NIV').col_htxt := 'YTG NIV ROB % OP';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YTG_RB_OP_NIV').col_ref1 := 'YTG_RB_NIV';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_NIV').col_ref2 := 'YTG_OP_NIV';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YTG_RB_OP_NIV').col_lnd2 := 'NoY';

      /*-*/
      /* Year end estimate column variables
      /*-*/
      hk_sal_base_excel.tbl_column('YEE_TO_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_QTY').col_htxt := 'YEE ACT/OP QTY';
      hk_sal_base_excel.tbl_column('YEE_TO_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_TO_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_QTY').col_dsql := 'sum(nvl(t01.ytd_ty_qty,0)+nvl(t01.ytg_op_qty,0))';
      hk_sal_base_excel.tbl_column('YEE_TO_QTY').col_zsql := '(nvl(t01.ytd_ty_qty,0)+nvl(t01.ytg_op_qty,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_TO_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('YEE_TO_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('YEE_TO_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_TO_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_TO_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_TO_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_TO_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_TON').col_htxt := 'YEE ACT/OP TON';
      hk_sal_base_excel.tbl_column('YEE_TO_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_TO_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_TON').col_dsql := 'sum(nvl(t01.ytd_ty_ton,0)+nvl(t01.ytg_op_ton,0))';
      hk_sal_base_excel.tbl_column('YEE_TO_TON').col_zsql := '(nvl(t01.ytd_ty_ton,0)+nvl(t01.ytg_op_ton,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_TO_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('YEE_TO_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_TO_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_TO_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_TO_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_TO_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_GSV').col_htxt := 'YEE ACT/OP GSV';
      hk_sal_base_excel.tbl_column('YEE_TO_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_TO_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_GSV').col_dsql := 'sum(nvl(t01.ytd_ty_gsv,0)+nvl(t01.ytg_op_gsv,0))';
      hk_sal_base_excel.tbl_column('YEE_TO_GSV').col_zsql := '(nvl(t01.ytd_ty_gsv,0)+nvl(t01.ytg_op_gsv,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_TO_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_TO_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_TO_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_TO_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_TO_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_NIV').col_htxt := 'YEE ACT/OP NIV';
      hk_sal_base_excel.tbl_column('YEE_TO_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_TO_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_NIV').col_dsql := 'sum(nvl(t01.ytd_ty_niv,0)+nvl(t01.ytg_op_niv,0))';
      hk_sal_base_excel.tbl_column('YEE_TO_NIV').col_zsql := '(nvl(t01.ytd_ty_niv,0)+nvl(t01.ytg_op_niv,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_TO_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_TO_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_TO_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_TO_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_TB_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_QTY').col_htxt := 'YEE ACT/BR QTY';
      hk_sal_base_excel.tbl_column('YEE_TB_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_TB_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_QTY').col_dsql := 'sum(nvl(t01.ytd_ty_qty,0)+nvl(t01.ytg_br_qty,0))';
      hk_sal_base_excel.tbl_column('YEE_TB_QTY').col_zsql := '(nvl(t01.ytd_ty_qty,0)+nvl(t01.ytg_br_qty,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_TB_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('YEE_TB_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('YEE_TB_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_TB_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_TB_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_TB_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_TB_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_TON').col_htxt := 'YEE ACT/BR TON';
      hk_sal_base_excel.tbl_column('YEE_TB_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_TB_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_TON').col_dsql := 'sum(nvl(t01.ytd_ty_ton,0)+nvl(t01.ytg_br_ton,0))';
      hk_sal_base_excel.tbl_column('YEE_TB_TON').col_zsql := '(nvl(t01.ytd_ty_ton,0)+nvl(t01.ytg_br_ton,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_TB_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('YEE_TB_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_TB_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_TB_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_TB_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_TB_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_GSV').col_htxt := 'YEE ACT/BR GSV';
      hk_sal_base_excel.tbl_column('YEE_TB_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_TB_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_GSV').col_dsql := 'sum(nvl(t01.ytd_ty_gsv,0)+nvl(t01.ytg_br_gsv,0))';
      hk_sal_base_excel.tbl_column('YEE_TB_GSV').col_zsql := '(nvl(t01.ytd_ty_gsv,0)+nvl(t01.ytg_br_gsv,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_TB_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_TB_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_TB_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_TB_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_TB_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_NIV').col_htxt := 'YEE ACT/BR NIV';
      hk_sal_base_excel.tbl_column('YEE_TB_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_TB_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_NIV').col_dsql := 'sum(nvl(t01.ytd_ty_niv,0)+nvl(t01.ytg_br_niv,0))';
      hk_sal_base_excel.tbl_column('YEE_TB_NIV').col_zsql := '(nvl(t01.ytd_ty_niv,0)+nvl(t01.ytg_br_niv,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_TB_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_TB_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_TB_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_TB_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_TR_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_QTY').col_htxt := 'YEE ACT/ROB QTY';
      hk_sal_base_excel.tbl_column('YEE_TR_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_TR_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_QTY').col_dsql := 'sum(nvl(t01.ytd_ty_qty,0)+nvl(t01.ytg_rb_qty,0))';
      hk_sal_base_excel.tbl_column('YEE_TR_QTY').col_zsql := '(nvl(t01.ytd_ty_qty,0)+nvl(t01.ytg_rb_qty,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_TR_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('YEE_TR_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('YEE_TR_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_TR_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_TR_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_TR_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_TR_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_TON').col_htxt := 'YEE ACT/ROB TON';
      hk_sal_base_excel.tbl_column('YEE_TR_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_TR_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_TON').col_dsql := 'sum(nvl(t01.ytd_ty_ton,0)+nvl(t01.ytg_rb_ton,0))';
      hk_sal_base_excel.tbl_column('YEE_TR_TON').col_zsql := '(nvl(t01.ytd_ty_ton,0)+nvl(t01.ytg_rb_ton,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_TR_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('YEE_TR_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_TR_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_TR_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_TR_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_TR_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_GSV').col_htxt := 'YEE ACT/ROB GSV';
      hk_sal_base_excel.tbl_column('YEE_TR_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_TR_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_GSV').col_dsql := 'sum(nvl(t01.ytd_ty_gsv,0)+nvl(t01.ytg_rb_gsv,0))';
      hk_sal_base_excel.tbl_column('YEE_TR_GSV').col_zsql := '(nvl(t01.ytd_ty_gsv,0)+nvl(t01.ytg_rb_gsv,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_TR_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_TR_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_TR_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_TR_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_TR_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_NIV').col_htxt := 'YEE ACT/ROB NIV';
      hk_sal_base_excel.tbl_column('YEE_TR_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_TR_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_NIV').col_dsql := 'sum(nvl(t01.ytd_ty_niv,0)+nvl(t01.ytg_rb_niv,0))';
      hk_sal_base_excel.tbl_column('YEE_TR_NIV').col_zsql := '(nvl(t01.ytd_ty_niv,0)+nvl(t01.ytg_rb_niv,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_TR_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_TR_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_TR_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_TR_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_QTY').col_htxt := 'YEE LY QTY';
      hk_sal_base_excel.tbl_column('YEE_LY_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_QTY').col_dsql := 'sum(nvl(t01.ytd_ly_qty,0)+nvl(t01.ytg_ly_qty,0))';
      hk_sal_base_excel.tbl_column('YEE_LY_QTY').col_zsql := '(nvl(t01.ytd_ly_qty,0)+nvl(t01.ytg_ly_qty,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_LY_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('YEE_LY_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('YEE_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_LY_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_LY_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_LY_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_TON').col_htxt := 'YEE LY TON';
      hk_sal_base_excel.tbl_column('YEE_LY_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_TON').col_dsql := 'sum(nvl(t01.ytd_ly_ton,0)+nvl(t01.ytg_ly_ton,0))';
      hk_sal_base_excel.tbl_column('YEE_LY_TON').col_zsql := '(nvl(t01.ytd_ly_ton,0)+nvl(t01.ytg_ly_ton,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_LY_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('YEE_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_LY_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_LY_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_LY_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_GSV').col_htxt := 'YEE LY GSV';
      hk_sal_base_excel.tbl_column('YEE_LY_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_GSV').col_dsql := 'sum(nvl(t01.ytd_ly_gsv,0)+nvl(t01.ytg_ly_gsv,0))';
      hk_sal_base_excel.tbl_column('YEE_LY_GSV').col_zsql := '(nvl(t01.ytd_ly_gsv,0)+nvl(t01.ytg_ly_gsv,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_LY_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_LY_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_LY_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_NIV').col_htxt := 'YEE LY NIV';
      hk_sal_base_excel.tbl_column('YEE_LY_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_NIV').col_dsql := 'sum(nvl(t01.ytd_ly_niv,0)+nvl(t01.ytg_ly_niv,0))';
      hk_sal_base_excel.tbl_column('YEE_LY_NIV').col_zsql := '(nvl(t01.ytd_ly_niv,0)+nvl(t01.ytg_ly_niv,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_LY_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_LY_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_LY_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_OP_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_QTY').col_htxt := 'YEE OP QTY';
      hk_sal_base_excel.tbl_column('YEE_OP_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_OP_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_QTY').col_dsql := 'sum(nvl(t01.ytd_op_qty,0)+nvl(t01.ytg_op_qty,0))';
      hk_sal_base_excel.tbl_column('YEE_OP_QTY').col_zsql := '(nvl(t01.ytd_op_qty,0)+nvl(t01.ytg_op_qty,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_OP_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('YEE_OP_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('YEE_OP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_OP_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_OP_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_OP_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_OP_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_TON').col_htxt := 'YEE OP TON';
      hk_sal_base_excel.tbl_column('YEE_OP_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_OP_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_TON').col_dsql := 'sum(nvl(t01.ytd_op_ton,0)+nvl(t01.ytg_op_ton,0))';
      hk_sal_base_excel.tbl_column('YEE_OP_TON').col_zsql := '(nvl(t01.ytd_op_ton,0)+nvl(t01.ytg_op_ton,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_OP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_OP_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('YEE_OP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_OP_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_OP_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_OP_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_OP_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_GSV').col_htxt := 'YEE OP GSV';
      hk_sal_base_excel.tbl_column('YEE_OP_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_OP_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_GSV').col_dsql := 'sum(nvl(t01.ytd_op_gsv,0)+nvl(t01.ytg_op_gsv,0))';
      hk_sal_base_excel.tbl_column('YEE_OP_GSV').col_zsql := '(nvl(t01.ytd_op_gsv,0)+nvl(t01.ytg_op_gsv,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_OP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_OP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_OP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_OP_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_OP_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_OP_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('YEE_OP_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_NIV').col_htxt := 'YEE OP NIV';
      hk_sal_base_excel.tbl_column('YEE_OP_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('YEE_OP_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_NIV').col_dsql := 'sum(nvl(t01.ytd_op_niv,0)+nvl(t01.ytg_op_niv,0))';
      hk_sal_base_excel.tbl_column('YEE_OP_NIV').col_zsql := '(nvl(t01.ytd_op_niv,0)+nvl(t01.ytg_op_niv,0)) != 0';
      hk_sal_base_excel.tbl_column('YEE_OP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_OP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_OP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('YEE_OP_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('YEE_OP_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('YEE_OP_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_TO_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_QTY').col_htxt := 'YEE QTY ACT/OP % LY';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_QTY').col_ref1 := 'YEE_TO_QTY';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_QTY').col_ref2 := 'YEE_LY_QTY';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TO_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_TON').col_htxt := 'YEE TON ACT/OP % LY';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_TON').col_ref1 := 'YEE_TO_TON';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_TON').col_ref2 := 'YEE_LY_TON';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TO_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_GSV').col_htxt := 'YEE GSV ACT/OP % LY';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_GSV').col_ref1 := 'YEE_TO_GSV';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_GSV').col_ref2 := 'YEE_LY_GSV';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TO_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_NIV').col_htxt := 'YEE NIV ACT/OP % LY';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_LY_NIV').col_ref1 := 'YEE_TO_NIV';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_NIV').col_ref2 := 'YEE_LY_NIV';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TO_LY_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_TB_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_QTY').col_htxt := 'YEE QTY ACT/BR % LY';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_QTY').col_ref1 := 'YEE_TB_QTY';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_QTY').col_ref2 := 'YEE_LY_QTY';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TB_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_TON').col_htxt := 'YEE TON ACT/BR % LY';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_TON').col_ref1 := 'YEE_TB_TON';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_TON').col_ref2 := 'YEE_LY_TON';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TB_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_GSV').col_htxt := 'YEE GSV ACT/BR % LY';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_GSV').col_ref1 := 'YEE_TB_GSV';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_GSV').col_ref2 := 'YEE_LY_GSV';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TB_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_NIV').col_htxt := 'YEE NIV ACT/BR % LY';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_LY_NIV').col_ref1 := 'YEE_TB_NIV';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_NIV').col_ref2 := 'YEE_LY_NIV';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TB_LY_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_TR_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_QTY').col_htxt := 'YEE QTY ACT/ROB % LY';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_QTY').col_ref1 := 'YEE_TR_QTY';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_QTY').col_ref2 := 'YEE_LY_QTY';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TR_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_TON').col_htxt := 'YEE TON ACT/ROB % LY';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_TON').col_ref1 := 'YEE_TR_TON';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_TON').col_ref2 := 'YEE_LY_TON';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TR_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_GSV').col_htxt := 'YEE GSV ACT/ROB % LY';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_GSV').col_ref1 := 'YEE_TR_GSV';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_GSV').col_ref2 := 'YEE_LY_GSV';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TR_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_NIV').col_htxt := 'YEE NIV ACT/ROB % LY';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_LY_NIV').col_ref1 := 'YEE_TR_NIV';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_NIV').col_ref2 := 'YEE_LY_NIV';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TR_LY_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_TO_OP_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_QTY').col_htxt := 'YEE QTY ACT/OP % OP';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_QTY').col_ref1 := 'YEE_TO_QTY';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_QTY').col_ref2 := 'YEE_OP_QTY';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TO_OP_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_TON').col_htxt := 'YEE ton ACT/OP % OP';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_TON').col_ref1 := 'YEE_TO_TON';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_TON').col_ref2 := 'YEE_OP_TON';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TO_OP_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_GSV').col_htxt := 'YEE GSV ACT/OP % OP';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_GSV').col_ref1 := 'YEE_TO_GSV';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_GSV').col_ref2 := 'YEE_OP_GSV';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TO_OP_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_NIV').col_htxt := 'YEE NIV ACT/OP % OP';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_OP_NIV').col_ref1 := 'YEE_TO_NIV';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_NIV').col_ref2 := 'YEE_OP_NIV';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TO_OP_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_TB_OP_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_QTY').col_htxt := 'YEE QTY ACT/BR % OP';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_QTY').col_ref1 := 'YEE_TB_QTY';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_QTY').col_ref2 := 'YEE_OP_QTY';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TB_OP_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_TON').col_htxt := 'YEE TON ACT/BR % OP';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_TON').col_ref1 := 'YEE_TB_TON';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_TON').col_ref2 := 'YEE_OP_TON';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TB_OP_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_GSV').col_htxt := 'YEE GSV ACT/BR % OP';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_GSV').col_ref1 := 'YEE_TB_GSV';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_GSV').col_ref2 := 'YEE_OP_GSV';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TB_OP_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_NIV').col_htxt := 'YEE NIV ACT/BR % OP';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_OP_NIV').col_ref1 := 'YEE_TB_NIV';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_NIV').col_ref2 := 'YEE_OP_NIV';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TB_OP_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_TR_OP_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_QTY').col_htxt := 'YEE QTY ACT/ROB % OP';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_QTY').col_ref1 := 'YEE_TR_QTY';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_QTY').col_ref2 := 'YEE_OP_QTY';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TR_OP_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_TON').col_htxt := 'YEE TON ACT/ROB % OP';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_TON').col_ref1 := 'YEE_TR_TON';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_TON').col_ref2 := 'YEE_OP_TON';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TR_OP_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_GSV').col_htxt := 'YEE GSV ACT/ROB % OP';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_GSV').col_ref1 := 'YEE_TR_GSV';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_GSV').col_ref2 := 'YEE_OP_GSV';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TR_OP_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_NIV').col_htxt := 'YEE NIV ACT/ROB % OP';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_OP_NIV').col_ref1 := 'YEE_TR_NIV';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_NIV').col_ref2 := 'YEE_OP_NIV';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TR_OP_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_OP_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_QTY').col_htxt := 'YEE QTY OP % LY';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_QTY').col_ref1 := 'YEE_OP_QTY';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_QTY').col_ref2 := 'YEE_LY_QTY';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_OP_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_TON').col_htxt := 'YEE TON OP % LY';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_TON').col_ref1 := 'YEE_OP_TON';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_TON').col_ref2 := 'YEE_LY_TON';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_OP_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_GSV').col_htxt := 'YEE GSV OP % LY';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_GSV').col_ref1 := 'YEE_OP_GSV';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_GSV').col_ref2 := 'YEE_LY_GSV';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_OP_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_NIV').col_htxt := 'YEE NIV OP % LY';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_OP_LY_NIV').col_ref1 := 'YEE_OP_NIV';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_NIV').col_ref2 := 'YEE_LY_NIV';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_OP_LY_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_TO_QTY_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_QTY_SHR').col_htxt := 'YEE ACT/OP QTY % Share';
      hk_sal_base_excel.tbl_column('YEE_TO_QTY_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_TO_QTY_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_QTY_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TO_QTY_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TO_QTY_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_QTY_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_QTY_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_QTY_SHR').col_ref1 := 'YEE_TO_QTY';
      hk_sal_base_excel.tbl_column('YEE_TO_QTY_SHR').col_ref2 := 'YEE_TO_QTY';
      hk_sal_base_excel.tbl_column('YEE_TO_QTY_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TO_QTY_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TO_TON_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_TON_SHR').col_htxt := 'YEE ACT/OP QTY % Share';
      hk_sal_base_excel.tbl_column('YEE_TO_TON_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_TO_TON_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_TON_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TO_TON_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TO_TON_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_TON_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_TON_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_TON_SHR').col_ref1 := 'YEE_TO_TON';
      hk_sal_base_excel.tbl_column('YEE_TO_TON_SHR').col_ref2 := 'YEE_TO_TON';
      hk_sal_base_excel.tbl_column('YEE_TO_TON_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TO_TON_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TO_GSV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_GSV_SHR').col_htxt := 'YEE ACT/OP GSV % Share';
      hk_sal_base_excel.tbl_column('YEE_TO_GSV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_TO_GSV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_GSV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TO_GSV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TO_GSV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_GSV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_GSV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_GSV_SHR').col_ref1 := 'YEE_TO_GSV';
      hk_sal_base_excel.tbl_column('YEE_TO_GSV_SHR').col_ref2 := 'YEE_TO_GSV';
      hk_sal_base_excel.tbl_column('YEE_TO_GSV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TO_GSV_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TO_NIV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_NIV_SHR').col_htxt := 'YEE ACT/OP NIV % Share';
      hk_sal_base_excel.tbl_column('YEE_TO_NIV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_TO_NIV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_NIV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TO_NIV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TO_NIV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_NIV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TO_NIV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TO_NIV_SHR').col_ref1 := 'YEE_TO_NIV';
      hk_sal_base_excel.tbl_column('YEE_TO_NIV_SHR').col_ref2 := 'YEE_TO_NIV';
      hk_sal_base_excel.tbl_column('YEE_TO_NIV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TO_NIV_SHR').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_TB_QTY_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_QTY_SHR').col_htxt := 'YEE ACT/BR QTY % Share';
      hk_sal_base_excel.tbl_column('YEE_TB_QTY_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_TB_QTY_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_QTY_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TB_QTY_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TB_QTY_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_QTY_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_QTY_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_QTY_SHR').col_ref1 := 'YEE_TB_QTY';
      hk_sal_base_excel.tbl_column('YEE_TB_QTY_SHR').col_ref2 := 'YEE_TB_QTY';
      hk_sal_base_excel.tbl_column('YEE_TB_QTY_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TB_QTY_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TB_TON_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_TON_SHR').col_htxt := 'YEE ACT/BR QTY % Share';
      hk_sal_base_excel.tbl_column('YEE_TB_TON_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_TB_TON_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_TON_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TB_TON_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TB_TON_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_TON_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_TON_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_TON_SHR').col_ref1 := 'YEE_TB_TON';
      hk_sal_base_excel.tbl_column('YEE_TB_TON_SHR').col_ref2 := 'YEE_TB_TON';
      hk_sal_base_excel.tbl_column('YEE_TB_TON_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TB_TON_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TB_GSV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_GSV_SHR').col_htxt := 'YEE ACT/BR GSV % Share';
      hk_sal_base_excel.tbl_column('YEE_TB_GSV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_TB_GSV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_GSV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TB_GSV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TB_GSV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_GSV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_GSV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_GSV_SHR').col_ref1 := 'YEE_TB_GSV';
      hk_sal_base_excel.tbl_column('YEE_TB_GSV_SHR').col_ref2 := 'YEE_TB_GSV';
      hk_sal_base_excel.tbl_column('YEE_TB_GSV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TB_GSV_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TB_NIV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_NIV_SHR').col_htxt := 'YEE ACT/BR NIV % Share';
      hk_sal_base_excel.tbl_column('YEE_TB_NIV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_TB_NIV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_NIV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TB_NIV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TB_NIV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_NIV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TB_NIV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TB_NIV_SHR').col_ref1 := 'YEE_TB_NIV';
      hk_sal_base_excel.tbl_column('YEE_TB_NIV_SHR').col_ref2 := 'YEE_TB_NIV';
      hk_sal_base_excel.tbl_column('YEE_TB_NIV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TB_NIV_SHR').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_TR_QTY_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_QTY_SHR').col_htxt := 'YEE ACT/ROB QTY % Share';
      hk_sal_base_excel.tbl_column('YEE_TR_QTY_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_TR_QTY_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_QTY_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TR_QTY_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TR_QTY_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_QTY_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_QTY_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_QTY_SHR').col_ref1 := 'YEE_TR_QTY';
      hk_sal_base_excel.tbl_column('YEE_TR_QTY_SHR').col_ref2 := 'YEE_TR_QTY';
      hk_sal_base_excel.tbl_column('YEE_TR_QTY_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TR_QTY_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TR_TON_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_TON_SHR').col_htxt := 'YEE ACT/ROB QTY % Share';
      hk_sal_base_excel.tbl_column('YEE_TR_TON_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_TR_TON_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_TON_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TR_TON_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TR_TON_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_TON_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_TON_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_TON_SHR').col_ref1 := 'YEE_TR_TON';
      hk_sal_base_excel.tbl_column('YEE_TR_TON_SHR').col_ref2 := 'YEE_TR_TON';
      hk_sal_base_excel.tbl_column('YEE_TR_TON_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TR_TON_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TR_GSV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_GSV_SHR').col_htxt := 'YEE ACT/ROB GSV % Share';
      hk_sal_base_excel.tbl_column('YEE_TR_GSV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_TR_GSV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_GSV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TR_GSV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TR_GSV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_GSV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_GSV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_GSV_SHR').col_ref1 := 'YEE_TR_GSV';
      hk_sal_base_excel.tbl_column('YEE_TR_GSV_SHR').col_ref2 := 'YEE_TR_GSV';
      hk_sal_base_excel.tbl_column('YEE_TR_GSV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TR_GSV_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_TR_NIV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_NIV_SHR').col_htxt := 'YEE ACT/ROB NIV % Share';
      hk_sal_base_excel.tbl_column('YEE_TR_NIV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_TR_NIV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_NIV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_TR_NIV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_TR_NIV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_NIV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_TR_NIV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_TR_NIV_SHR').col_ref1 := 'YEE_TR_NIV';
      hk_sal_base_excel.tbl_column('YEE_TR_NIV_SHR').col_ref2 := 'YEE_TR_NIV';
      hk_sal_base_excel.tbl_column('YEE_TR_NIV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_TR_NIV_SHR').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('YEE_LY_QTY_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_QTY_SHR').col_htxt := 'YEE LY QTY % Share';
      hk_sal_base_excel.tbl_column('YEE_LY_QTY_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_LY_QTY_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_QTY_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_LY_QTY_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_LY_QTY_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_LY_QTY_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_LY_QTY_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_QTY_SHR').col_ref1 := 'YEE_LY_QTY';
      hk_sal_base_excel.tbl_column('YEE_LY_QTY_SHR').col_ref2 := 'YEE_LY_QTY';
      hk_sal_base_excel.tbl_column('YEE_LY_QTY_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_LY_QTY_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_LY_TON_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_TON_SHR').col_htxt := 'YEE LY QTY % Share';
      hk_sal_base_excel.tbl_column('YEE_LY_TON_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_LY_TON_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_TON_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_LY_TON_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_LY_TON_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_LY_TON_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_LY_TON_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_TON_SHR').col_ref1 := 'YEE_LY_TON';
      hk_sal_base_excel.tbl_column('YEE_LY_TON_SHR').col_ref2 := 'YEE_LY_TON';
      hk_sal_base_excel.tbl_column('YEE_LY_TON_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_LY_TON_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_LY_GSV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_GSV_SHR').col_htxt := 'YEE LY GSV % Share';
      hk_sal_base_excel.tbl_column('YEE_LY_GSV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_LY_GSV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_GSV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_LY_GSV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_LY_GSV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_LY_GSV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_LY_GSV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_GSV_SHR').col_ref1 := 'YEE_LY_GSV';
      hk_sal_base_excel.tbl_column('YEE_LY_GSV_SHR').col_ref2 := 'YEE_LY_GSV';
      hk_sal_base_excel.tbl_column('YEE_LY_GSV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_LY_GSV_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('YEE_LY_NIV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_NIV_SHR').col_htxt := 'YEE LY NIV % Share';
      hk_sal_base_excel.tbl_column('YEE_LY_NIV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('YEE_LY_NIV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_NIV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('YEE_LY_NIV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('YEE_LY_NIV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('YEE_LY_NIV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('YEE_LY_NIV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('YEE_LY_NIV_SHR').col_ref1 := 'YEE_LY_NIV';
      hk_sal_base_excel.tbl_column('YEE_LY_NIV_SHR').col_ref2 := 'YEE_LY_NIV';
      hk_sal_base_excel.tbl_column('YEE_LY_NIV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('YEE_LY_NIV_SHR').col_lnd2 := 'NoY';

      /*-*/
      /* Period column variables
      /*-*/
      hk_sal_base_excel.tbl_column('PRD0113_AOP_QTY').col_tabi := 11;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_QTY').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_QTY').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_QTY').col_dsql := 'sum(nvl(t11.p01_qty,0)),sum(nvl(t11.p02_qty,0)),sum(nvl(t11.p03_qty,0)),sum(nvl(t11.p04_qty,0)),sum(nvl(t11.p05_qty,0)),sum(nvl(t11.p06_qty,0)),sum(nvl(t11.p07_qty,0)),sum(nvl(t11.p08_qty,0)),sum(nvl(t11.p09_qty,0)),sum(nvl(t11.p10_qty,0)),sum(nvl(t11.p11_qty,0)),sum(nvl(t11.p12_qty,0)),sum(nvl(t11.p13_qty,0))';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_QTY').col_zsql := 'nvl(t11.p01_qty,0) != 0 or nvl(t11.p02_qty,0) != 0 or nvl(t11.p03_qty,0) != 0 or nvl(t11.p04_qty,0) != 0 or nvl(t11.p05_qty,0) != 0 or nvl(t11.p06_qty,0) != 0 or nvl(t11.p07_qty,0) != 0 or nvl(t11.p08_qty,0) != 0 or nvl(t11.p09_qty,0) != 0 or nvl(t11.p10_qty,0) != 0 or nvl(t11.p11_qty,0) != 0 or nvl(t11.p12_qty,0) != 0 or nvl(t11.p13_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_AOP_TON').col_tabi := 12;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_TON').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_TON').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_TON').col_dsql := 'sum(nvl(t12.p01_ton,0)),sum(nvl(t12.p02_ton,0)),sum(nvl(t12.p03_ton,0)),sum(nvl(t12.p04_ton,0)),sum(nvl(t12.p05_ton,0)),sum(nvl(t12.p06_ton,0)),sum(nvl(t12.p07_ton,0)),sum(nvl(t12.p08_ton,0)),sum(nvl(t12.p09_ton,0)),sum(nvl(t12.p10_ton,0)),sum(nvl(t12.p11_ton,0)),sum(nvl(t12.p12_ton,0)),sum(nvl(t12.p13_ton,0))';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_TON').col_zsql := 'nvl(t12.p01_ton,0) != 0 or nvl(t12.p02_ton,0) != 0 or nvl(t12.p03_ton,0) != 0 or nvl(t12.p04_ton,0) != 0 or nvl(t12.p05_ton,0) != 0 or nvl(t12.p06_ton,0) != 0 or nvl(t12.p07_ton,0) != 0 or nvl(t12.p08_ton,0) != 0 or nvl(t12.p09_ton,0) != 0 or nvl(t12.p10_ton,0) != 0 or nvl(t12.p11_ton,0) != 0 or nvl(t12.p12_ton,0) != 0 or nvl(t12.p13_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_AOP_GSV').col_tabi := 13;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_GSV').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_GSV').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_GSV').col_dsql := 'sum(nvl(t13.p01_gsv,0)),sum(nvl(t13.p02_gsv,0)),sum(nvl(t13.p03_gsv,0)),sum(nvl(t13.p04_gsv,0)),sum(nvl(t13.p05_gsv,0)),sum(nvl(t13.p06_gsv,0)),sum(nvl(t13.p07_gsv,0)),sum(nvl(t13.p08_gsv,0)),sum(nvl(t13.p09_gsv,0)),sum(nvl(t13.p10_gsv,0)),sum(nvl(t13.p11_gsv,0)),sum(nvl(t13.p12_gsv,0)),sum(nvl(t13.p13_gsv,0))';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_GSV').col_zsql := 'nvl(t13.p01_gsv,0) != 0 or nvl(t13.p02_gsv,0) != 0 or nvl(t13.p03_gsv,0) != 0 or nvl(t13.p04_gsv,0) != 0 or nvl(t13.p05_gsv,0) != 0 or nvl(t13.p06_gsv,0) != 0 or nvl(t13.p07_gsv,0) != 0 or nvl(t13.p08_gsv,0) != 0 or nvl(t13.p09_gsv,0) != 0 or nvl(t13.p10_gsv,0) != 0 or nvl(t13.p11_gsv,0) != 0 or nvl(t13.p12_gsv,0) != 0 or nvl(t13.p13_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_AOP_NIV').col_tabi := 14;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_NIV').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_NIV').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_NIV').col_dsql := 'sum(nvl(t14.p01_niv,0)),sum(nvl(t14.p02_niv,0)),sum(nvl(t14.p03_niv,0)),sum(nvl(t14.p04_niv,0)),sum(nvl(t14.p05_niv,0)),sum(nvl(t14.p06_niv,0)),sum(nvl(t14.p07_niv,0)),sum(nvl(t14.p08_niv,0)),sum(nvl(t14.p09_niv,0)),sum(nvl(t14.p10_niv,0)),sum(nvl(t14.p11_niv,0)),sum(nvl(t14.p12_niv,0)),sum(nvl(t14.p13_niv,0))';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_NIV').col_zsql := 'nvl(t14.p01_niv,0) != 0 or nvl(t14.p02_niv,0) != 0 or nvl(t14.p03_niv,0) != 0 or nvl(t14.p04_niv,0) != 0 or nvl(t14.p05_niv,0) != 0 or nvl(t14.p06_niv,0) != 0 or nvl(t14.p07_niv,0) != 0 or nvl(t14.p08_niv,0) != 0 or nvl(t14.p09_niv,0) != 0 or nvl(t14.p10_niv,0) != 0 or nvl(t14.p11_niv,0) != 0 or nvl(t14.p12_niv,0) != 0 or nvl(t14.p13_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_AOP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_AOP_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('PRD0113_ABR_QTY').col_tabi := 21;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_QTY').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_QTY').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_QTY').col_dsql := 'sum(nvl(t21.p01_qty,0)),sum(nvl(t21.p02_qty,0)),sum(nvl(t21.p03_qty,0)),sum(nvl(t21.p04_qty,0)),sum(nvl(t21.p05_qty,0)),sum(nvl(t21.p06_qty,0)),sum(nvl(t21.p07_qty,0)),sum(nvl(t21.p08_qty,0)),sum(nvl(t21.p09_qty,0)),sum(nvl(t21.p10_qty,0)),sum(nvl(t21.p11_qty,0)),sum(nvl(t21.p12_qty,0)),sum(nvl(t21.p13_qty,0))';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_QTY').col_zsql := 'nvl(t21.p01_qty,0) != 0 or nvl(t21.p02_qty,0) != 0 or nvl(t21.p03_qty,0) != 0 or nvl(t21.p04_qty,0) != 0 or nvl(t21.p05_qty,0) != 0 or nvl(t21.p06_qty,0) != 0 or nvl(t21.p07_qty,0) != 0 or nvl(t21.p08_qty,0) != 0 or nvl(t21.p09_qty,0) != 0 or nvl(t21.p10_qty,0) != 0 or nvl(t21.p11_qty,0) != 0 or nvl(t21.p12_qty,0) != 0 or nvl(t21.p13_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_ABR_TON').col_tabi := 22;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_TON').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_TON').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_TON').col_dsql := 'sum(nvl(t22.p01_ton,0)),sum(nvl(t22.p02_ton,0)),sum(nvl(t22.p03_ton,0)),sum(nvl(t22.p04_ton,0)),sum(nvl(t22.p05_ton,0)),sum(nvl(t22.p06_ton,0)),sum(nvl(t22.p07_ton,0)),sum(nvl(t22.p08_ton,0)),sum(nvl(t22.p09_ton,0)),sum(nvl(t22.p10_ton,0)),sum(nvl(t22.p11_ton,0)),sum(nvl(t22.p12_ton,0)),sum(nvl(t22.p13_ton,0))';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_TON').col_zsql := 'nvl(t22.p01_ton,0) != 0 or nvl(t22.p02_ton,0) != 0 or nvl(t22.p03_ton,0) != 0 or nvl(t22.p04_ton,0) != 0 or nvl(t22.p05_ton,0) != 0 or nvl(t22.p06_ton,0) != 0 or nvl(t22.p07_ton,0) != 0 or nvl(t22.p08_ton,0) != 0 or nvl(t22.p09_ton,0) != 0 or nvl(t22.p10_ton,0) != 0 or nvl(t22.p11_ton,0) != 0 or nvl(t22.p12_ton,0) != 0 or nvl(t22.p13_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_ABR_GSV').col_tabi := 23;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_GSV').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_GSV').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_GSV').col_dsql := 'sum(nvl(t23.p01_gsv,0)),sum(nvl(t23.p02_gsv,0)),sum(nvl(t23.p03_gsv,0)),sum(nvl(t23.p04_gsv,0)),sum(nvl(t23.p05_gsv,0)),sum(nvl(t23.p06_gsv,0)),sum(nvl(t23.p07_gsv,0)),sum(nvl(t23.p08_gsv,0)),sum(nvl(t23.p09_gsv,0)),sum(nvl(t23.p10_gsv,0)),sum(nvl(t23.p11_gsv,0)),sum(nvl(t23.p12_gsv,0)),sum(nvl(t23.p13_gsv,0))';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_GSV').col_zsql := 'nvl(t23.p01_gsv,0) != 0 or nvl(t23.p02_gsv,0) != 0 or nvl(t23.p03_gsv,0) != 0 or nvl(t23.p04_gsv,0) != 0 or nvl(t23.p05_gsv,0) != 0 or nvl(t23.p06_gsv,0) != 0 or nvl(t23.p07_gsv,0) != 0 or nvl(t23.p08_gsv,0) != 0 or nvl(t23.p09_gsv,0) != 0 or nvl(t23.p10_gsv,0) != 0 or nvl(t23.p11_gsv,0) != 0 or nvl(t23.p12_gsv,0) != 0 or nvl(t23.p13_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_ABR_NIV').col_tabi := 24;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_NIV').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_NIV').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_NIV').col_dsql := 'sum(nvl(t24.p01_niv,0)),sum(nvl(t24.p02_niv,0)),sum(nvl(t24.p03_niv,0)),sum(nvl(t24.p04_niv,0)),sum(nvl(t24.p05_niv,0)),sum(nvl(t24.p06_niv,0)),sum(nvl(t24.p07_niv,0)),sum(nvl(t24.p08_niv,0)),sum(nvl(t24.p09_niv,0)),sum(nvl(t24.p10_niv,0)),sum(nvl(t24.p11_niv,0)),sum(nvl(t24.p12_niv,0)),sum(nvl(t24.p13_niv,0))';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_NIV').col_zsql := 'nvl(t24.p01_niv,0) != 0 or nvl(t24.p02_niv,0) != 0 or nvl(t24.p03_niv,0) != 0 or nvl(t24.p04_niv,0) != 0 or nvl(t24.p05_niv,0) != 0 or nvl(t24.p06_niv,0) != 0 or nvl(t24.p07_niv,0) != 0 or nvl(t24.p08_niv,0) != 0 or nvl(t24.p09_niv,0) != 0 or nvl(t24.p10_niv,0) != 0 or nvl(t24.p11_niv,0) != 0 or nvl(t24.p12_niv,0) != 0 or nvl(t24.p13_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_ABR_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ABR_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('PRD0113_ARB_QTY').col_tabi := 31;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_QTY').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_QTY').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_QTY').col_dsql := 'sum(nvl(t31.p01_qty,0)),sum(nvl(t31.p02_qty,0)),sum(nvl(t31.p03_qty,0)),sum(nvl(t31.p04_qty,0)),sum(nvl(t31.p05_qty,0)),sum(nvl(t31.p06_qty,0)),sum(nvl(t31.p07_qty,0)),sum(nvl(t31.p08_qty,0)),sum(nvl(t31.p09_qty,0)),sum(nvl(t31.p10_qty,0)),sum(nvl(t31.p11_qty,0)),sum(nvl(t31.p12_qty,0)),sum(nvl(t31.p13_qty,0))';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_QTY').col_zsql := 'nvl(t31.p01_qty,0) != 0 or nvl(t31.p02_qty,0) != 0 or nvl(t31.p03_qty,0) != 0 or nvl(t31.p04_qty,0) != 0 or nvl(t31.p05_qty,0) != 0 or nvl(t31.p06_qty,0) != 0 or nvl(t31.p07_qty,0) != 0 or nvl(t31.p08_qty,0) != 0 or nvl(t31.p09_qty,0) != 0 or nvl(t31.p10_qty,0) != 0 or nvl(t31.p11_qty,0) != 0 or nvl(t31.p12_qty,0) != 0 or nvl(t31.p13_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_ARB_TON').col_tabi := 32;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_TON').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_TON').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_TON').col_dsql := 'sum(nvl(t32.p01_ton,0)),sum(nvl(t32.p02_ton,0)),sum(nvl(t32.p03_ton,0)),sum(nvl(t32.p04_ton,0)),sum(nvl(t32.p05_ton,0)),sum(nvl(t32.p06_ton,0)),sum(nvl(t32.p07_ton,0)),sum(nvl(t32.p08_ton,0)),sum(nvl(t32.p09_ton,0)),sum(nvl(t32.p10_ton,0)),sum(nvl(t32.p11_ton,0)),sum(nvl(t32.p12_ton,0)),sum(nvl(t32.p13_ton,0))';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_TON').col_zsql := 'nvl(t32.p01_ton,0) != 0 or nvl(t32.p02_ton,0) != 0 or nvl(t32.p03_ton,0) != 0 or nvl(t32.p04_ton,0) != 0 or nvl(t32.p05_ton,0) != 0 or nvl(t32.p06_ton,0) != 0 or nvl(t32.p07_ton,0) != 0 or nvl(t32.p08_ton,0) != 0 or nvl(t32.p09_ton,0) != 0 or nvl(t32.p10_ton,0) != 0 or nvl(t32.p11_ton,0) != 0 or nvl(t32.p12_ton,0) != 0 or nvl(t32.p13_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_ARB_GSV').col_tabi := 33;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_GSV').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_GSV').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_GSV').col_dsql := 'sum(nvl(t33.p01_gsv,0)),sum(nvl(t33.p02_gsv,0)),sum(nvl(t33.p03_gsv,0)),sum(nvl(t33.p04_gsv,0)),sum(nvl(t33.p05_gsv,0)),sum(nvl(t33.p06_gsv,0)),sum(nvl(t33.p07_gsv,0)),sum(nvl(t33.p08_gsv,0)),sum(nvl(t33.p09_gsv,0)),sum(nvl(t33.p10_gsv,0)),sum(nvl(t33.p11_gsv,0)),sum(nvl(t33.p12_gsv,0)),sum(nvl(t33.p13_gsv,0))';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_GSV').col_zsql := 'nvl(t33.p01_gsv,0) != 0 or nvl(t33.p02_gsv,0) != 0 or nvl(t33.p03_gsv,0) != 0 or nvl(t33.p04_gsv,0) != 0 or nvl(t33.p05_gsv,0) != 0 or nvl(t33.p06_gsv,0) != 0 or nvl(t33.p07_gsv,0) != 0 or nvl(t33.p08_gsv,0) != 0 or nvl(t33.p09_gsv,0) != 0 or nvl(t33.p10_gsv,0) != 0 or nvl(t33.p11_gsv,0) != 0 or nvl(t33.p12_gsv,0) != 0 or nvl(t33.p13_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_ARB_NIV').col_tabi := 34;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_NIV').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_NIV').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_NIV').col_dsql := 'sum(nvl(t34.p01_niv,0)),sum(nvl(t34.p02_niv,0)),sum(nvl(t34.p03_niv,0)),sum(nvl(t34.p04_niv,0)),sum(nvl(t34.p05_niv,0)),sum(nvl(t34.p06_niv,0)),sum(nvl(t34.p07_niv,0)),sum(nvl(t34.p08_niv,0)),sum(nvl(t34.p09_niv,0)),sum(nvl(t34.p10_niv,0)),sum(nvl(t34.p11_niv,0)),sum(nvl(t34.p12_niv,0)),sum(nvl(t34.p13_niv,0))';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_NIV').col_zsql := 'nvl(t34.p01_niv,0) != 0 or nvl(t34.p02_niv,0) != 0 or nvl(t34.p03_niv,0) != 0 or nvl(t34.p04_niv,0) != 0 or nvl(t34.p05_niv,0) != 0 or nvl(t34.p06_niv,0) != 0 or nvl(t34.p07_niv,0) != 0 or nvl(t34.p08_niv,0) != 0 or nvl(t34.p09_niv,0) != 0 or nvl(t34.p10_niv,0) != 0 or nvl(t34.p11_niv,0) != 0 or nvl(t34.p12_niv,0) != 0 or nvl(t34.p13_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_ARB_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_ARB_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('PRD0113_LYR_QTY').col_tabi := 41;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_QTY').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_QTY').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_QTY').col_dsql := 'sum(nvl(t41.p01_qty,0)),sum(nvl(t41.p02_qty,0)),sum(nvl(t41.p03_qty,0)),sum(nvl(t41.p04_qty,0)),sum(nvl(t41.p05_qty,0)),sum(nvl(t41.p06_qty,0)),sum(nvl(t41.p07_qty,0)),sum(nvl(t41.p08_qty,0)),sum(nvl(t41.p09_qty,0)),sum(nvl(t41.p10_qty,0)),sum(nvl(t41.p11_qty,0)),sum(nvl(t41.p12_qty,0)),sum(nvl(t41.p13_qty,0))';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_QTY').col_zsql := 'nvl(t41.p01_qty,0) != 0 or nvl(t41.p02_qty,0) != 0 or nvl(t41.p03_qty,0) != 0 or nvl(t41.p04_qty,0) != 0 or nvl(t41.p05_qty,0) != 0 or nvl(t41.p06_qty,0) != 0 or nvl(t41.p07_qty,0) != 0 or nvl(t41.p08_qty,0) != 0 or nvl(t41.p09_qty,0) != 0 or nvl(t41.p10_qty,0) != 0 or nvl(t41.p11_qty,0) != 0 or nvl(t41.p12_qty,0) != 0 or nvl(t41.p13_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_LYR_TON').col_tabi := 42;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_TON').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_TON').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_TON').col_dsql := 'sum(nvl(t42.p01_ton,0)),sum(nvl(t42.p02_ton,0)),sum(nvl(t42.p03_ton,0)),sum(nvl(t42.p04_ton,0)),sum(nvl(t42.p05_ton,0)),sum(nvl(t42.p06_ton,0)),sum(nvl(t42.p07_ton,0)),sum(nvl(t42.p08_ton,0)),sum(nvl(t42.p09_ton,0)),sum(nvl(t42.p10_ton,0)),sum(nvl(t42.p11_ton,0)),sum(nvl(t42.p12_ton,0)),sum(nvl(t42.p13_ton,0))';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_TON').col_zsql := 'nvl(t42.p01_ton,0) != 0 or nvl(t42.p02_ton,0) != 0 or nvl(t42.p03_ton,0) != 0 or nvl(t42.p04_ton,0) != 0 or nvl(t42.p05_ton,0) != 0 or nvl(t42.p06_ton,0) != 0 or nvl(t42.p07_ton,0) != 0 or nvl(t42.p08_ton,0) != 0 or nvl(t42.p09_ton,0) != 0 or nvl(t42.p10_ton,0) != 0 or nvl(t42.p11_ton,0) != 0 or nvl(t42.p12_ton,0) != 0 or nvl(t42.p13_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_LYR_GSV').col_tabi := 43;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_GSV').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_GSV').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_GSV').col_dsql := 'sum(nvl(t43.p01_gsv,0)),sum(nvl(t43.p02_gsv,0)),sum(nvl(t43.p03_gsv,0)),sum(nvl(t43.p04_gsv,0)),sum(nvl(t43.p05_gsv,0)),sum(nvl(t43.p06_gsv,0)),sum(nvl(t43.p07_gsv,0)),sum(nvl(t43.p08_gsv,0)),sum(nvl(t43.p09_gsv,0)),sum(nvl(t43.p10_gsv,0)),sum(nvl(t43.p11_gsv,0)),sum(nvl(t43.p12_gsv,0)),sum(nvl(t43.p13_gsv,0))';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_GSV').col_zsql := 'nvl(t43.p01_gsv,0) != 0 or nvl(t43.p02_gsv,0) != 0 or nvl(t43.p03_gsv,0) != 0 or nvl(t43.p04_gsv,0) != 0 or nvl(t43.p05_gsv,0) != 0 or nvl(t43.p06_gsv,0) != 0 or nvl(t43.p07_gsv,0) != 0 or nvl(t43.p08_gsv,0) != 0 or nvl(t43.p09_gsv,0) != 0 or nvl(t43.p10_gsv,0) != 0 or nvl(t43.p11_gsv,0) != 0 or nvl(t43.p12_gsv,0) != 0 or nvl(t43.p13_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_LYR_NIV').col_tabi := 44;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_NIV').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_NIV').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_NIV').col_dsql := 'sum(nvl(t44.p01_niv,0)),sum(nvl(t44.p02_niv,0)),sum(nvl(t44.p03_niv,0)),sum(nvl(t44.p04_niv,0)),sum(nvl(t44.p05_niv,0)),sum(nvl(t44.p06_niv,0)),sum(nvl(t44.p07_niv,0)),sum(nvl(t44.p08_niv,0)),sum(nvl(t44.p09_niv,0)),sum(nvl(t44.p10_niv,0)),sum(nvl(t44.p11_niv,0)),sum(nvl(t44.p12_niv,0)),sum(nvl(t44.p13_niv,0))';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_NIV').col_zsql := 'nvl(t44.p01_niv,0) != 0 or nvl(t44.p02_niv,0) != 0 or nvl(t44.p03_niv,0) != 0 or nvl(t44.p04_niv,0) != 0 or nvl(t44.p05_niv,0) != 0 or nvl(t44.p06_niv,0) != 0 or nvl(t44.p07_niv,0) != 0 or nvl(t44.p08_niv,0) != 0 or nvl(t44.p09_niv,0) != 0 or nvl(t44.p10_niv,0) != 0 or nvl(t44.p11_niv,0) != 0 or nvl(t44.p12_niv,0) != 0 or nvl(t44.p13_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_LYR_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_LYR_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('PRD0113_TOP_QTY').col_tabi := 51;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_QTY').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_QTY').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_QTY').col_dsql := 'sum(nvl(t51.p01_qty,0)),sum(nvl(t51.p02_qty,0)),sum(nvl(t51.p03_qty,0)),sum(nvl(t51.p04_qty,0)),sum(nvl(t51.p05_qty,0)),sum(nvl(t51.p06_qty,0)),sum(nvl(t51.p07_qty,0)),sum(nvl(t51.p08_qty,0)),sum(nvl(t51.p09_qty,0)),sum(nvl(t51.p10_qty,0)),sum(nvl(t51.p11_qty,0)),sum(nvl(t51.p12_qty,0)),sum(nvl(t51.p13_qty,0))';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_QTY').col_zsql := 'nvl(t51.p01_qty,0) != 0 or nvl(t51.p02_qty,0) != 0 or nvl(t51.p03_qty,0) != 0 or nvl(t51.p04_qty,0) != 0 or nvl(t51.p05_qty,0) != 0 or nvl(t51.p06_qty,0) != 0 or nvl(t51.p07_qty,0) != 0 or nvl(t51.p08_qty,0) != 0 or nvl(t51.p09_qty,0) != 0 or nvl(t51.p10_qty,0) != 0 or nvl(t51.p11_qty,0) != 0 or nvl(t51.p12_qty,0) != 0 or nvl(t51.p13_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_TOP_TON').col_tabi := 52;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_TON').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_TON').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_TON').col_dsql := 'sum(nvl(t52.p01_ton,0)),sum(nvl(t52.p02_ton,0)),sum(nvl(t52.p03_ton,0)),sum(nvl(t52.p04_ton,0)),sum(nvl(t52.p05_ton,0)),sum(nvl(t52.p06_ton,0)),sum(nvl(t52.p07_ton,0)),sum(nvl(t52.p08_ton,0)),sum(nvl(t52.p09_ton,0)),sum(nvl(t52.p10_ton,0)),sum(nvl(t52.p11_ton,0)),sum(nvl(t52.p12_ton,0)),sum(nvl(t52.p13_ton,0))';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_TON').col_zsql := 'nvl(t52.p01_ton,0) != 0 or nvl(t52.p02_ton,0) != 0 or nvl(t52.p03_ton,0) != 0 or nvl(t52.p04_ton,0) != 0 or nvl(t52.p05_ton,0) != 0 or nvl(t52.p06_ton,0) != 0 or nvl(t52.p07_ton,0) != 0 or nvl(t52.p08_ton,0) != 0 or nvl(t52.p09_ton,0) != 0 or nvl(t52.p10_ton,0) != 0 or nvl(t52.p11_ton,0) != 0 or nvl(t52.p12_ton,0) != 0 or nvl(t52.p13_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_TOP_GSV').col_tabi := 53;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_GSV').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_GSV').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_GSV').col_dsql := 'sum(nvl(t53.p01_gsv,0)),sum(nvl(t53.p02_gsv,0)),sum(nvl(t53.p03_gsv,0)),sum(nvl(t53.p04_gsv,0)),sum(nvl(t53.p05_gsv,0)),sum(nvl(t53.p06_gsv,0)),sum(nvl(t53.p07_gsv,0)),sum(nvl(t53.p08_gsv,0)),sum(nvl(t53.p09_gsv,0)),sum(nvl(t53.p10_gsv,0)),sum(nvl(t53.p11_gsv,0)),sum(nvl(t53.p12_gsv,0)),sum(nvl(t53.p13_gsv,0))';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_GSV').col_zsql := 'nvl(t53.p01_gsv,0) != 0 or nvl(t53.p02_gsv,0) != 0 or nvl(t53.p03_gsv,0) != 0 or nvl(t53.p04_gsv,0) != 0 or nvl(t53.p05_gsv,0) != 0 or nvl(t53.p06_gsv,0) != 0 or nvl(t53.p07_gsv,0) != 0 or nvl(t53.p08_gsv,0) != 0 or nvl(t53.p09_gsv,0) != 0 or nvl(t53.p10_gsv,0) != 0 or nvl(t53.p11_gsv,0) != 0 or nvl(t53.p12_gsv,0) != 0 or nvl(t53.p13_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PRD0113_TOP_NIV').col_tabi := 54;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_NIV').col_htxt := 'P01'||chr(9)||'P02'||chr(9)||'P03'||chr(9)||'P04'||chr(9)||'P05'||chr(9)||'P06'||chr(9)||'P07'||chr(9)||'P08'||chr(9)||'P09'||chr(9)||'P10'||chr(9)||'P11'||chr(9)||'P12'||chr(9)||'P13';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_NIV').col_ccnt := 13;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_NIV').col_dsql := 'sum(nvl(t54.p01_niv,0)),sum(nvl(t54.p02_niv,0)),sum(nvl(t54.p03_niv,0)),sum(nvl(t54.p04_niv,0)),sum(nvl(t54.p05_niv,0)),sum(nvl(t54.p06_niv,0)),sum(nvl(t54.p07_niv,0)),sum(nvl(t54.p08_niv,0)),sum(nvl(t54.p09_niv,0)),sum(nvl(t54.p10_niv,0)),sum(nvl(t54.p11_niv,0)),sum(nvl(t54.p12_niv,0)),sum(nvl(t54.p13_niv,0))';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_NIV').col_zsql := 'nvl(t54.p01_niv,0) != 0 or nvl(t54.p02_niv,0) != 0 or nvl(t54.p03_niv,0) != 0 or nvl(t54.p04_niv,0) != 0 or nvl(t54.p05_niv,0) != 0 or nvl(t54.p06_niv,0) != 0 or nvl(t54.p07_niv,0) != 0 or nvl(t54.p08_niv,0) != 0 or nvl(t54.p09_niv,0) != 0 or nvl(t54.p10_niv,0) != 0 or nvl(t54.p11_niv,0) != 0 or nvl(t54.p12_niv,0) != 0 or nvl(t54.p13_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PRD0113_TOP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PRD0113_TOP_NIV').col_lnd2 := null;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_base_data;

end hk_sal_cus_prd_02_excel;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_sal_cus_prd_02_excel for pld_rep_app.hk_sal_cus_prd_02_excel;
grant execute on hk_sal_cus_prd_02_excel to public;
/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_sal_mat_prd_01_excel                            */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : March 2006                                         */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_sal_mat_prd_01_excel as

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

end hk_sal_mat_prd_01_excel;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_sal_mat_prd_01_excel as

   /*-*/
   /* Private package variables
   /*-*/
   rcd_pld_sal_mat_prd_0100 pld_sal_mat_prd_0100%rowtype;

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
      cursor csr_pld_sal_mat_prd_0100 is 
         select *
         from pld_sal_mat_prd_0100 t01
         where t01.sap_company_code = par_company_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the format control
      /*-*/
      var_found := true;
      open csr_pld_sal_mat_prd_0100;
      fetch csr_pld_sal_mat_prd_0100 into rcd_pld_sal_mat_prd_0100;
      if csr_pld_sal_mat_prd_0100%notfound then
         var_found := false;
      end if;
      close csr_pld_sal_mat_prd_0100;
      if var_found = false then
         raise_application_error(-20000, 'Extract control row PLD_SAL_MAT_PRD_0100 not found');
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
                                    rcd_pld_sal_mat_prd_0100.extract_status || ' ' || rcd_pld_sal_mat_prd_0100.sales_status,
                                    rcd_pld_sal_mat_prd_0100.prd_asofdays);

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
      /* Initialise the material tables variables
      /*-*/
      hk_sal_base_excel.tbl_main_name := 'pld_sal_mat_prd_0101 t01,material_dim t02';
      hk_sal_base_excel.tbl_main_join := 't01.sap_material_code = t02.sap_material_code(+) and t01.sap_company_code = :A';

      /*-*/
      /* Current order column variables
      /*-*/
      hk_sal_base_excel.tbl_column('ORD_UC_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_QTY').col_htxt := 'Unconfirmed QTY';
      hk_sal_base_excel.tbl_column('ORD_UC_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('ORD_UC_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_QTY').col_dsql := 'sum(nvl(t01.ord_uc_qty,0))';
      hk_sal_base_excel.tbl_column('ORD_UC_QTY').col_zsql := 'nvl(t01.ord_uc_qty,0) != 0';
      hk_sal_base_excel.tbl_column('ORD_UC_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('ORD_UC_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('ORD_UC_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('ORD_UC_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('ORD_UC_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('ORD_UC_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('ORD_UC_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_TON').col_htxt := 'Unconfirmed TON';
      hk_sal_base_excel.tbl_column('ORD_UC_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('ORD_UC_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_TON').col_dsql := 'sum(nvl(t01.ord_uc_ton,0))';
      hk_sal_base_excel.tbl_column('ORD_UC_TON').col_zsql := 'nvl(t01.ord_uc_ton,0) != 0';
      hk_sal_base_excel.tbl_column('ORD_UC_TON').col_decp := 6;
      hk_sal_base_excel.tbl_column('ORD_UC_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_UC_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('ORD_UC_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('ORD_UC_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('ORD_UC_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('ORD_UC_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_GSV').col_htxt := 'Unconfirmed GSV';
      hk_sal_base_excel.tbl_column('ORD_UC_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('ORD_UC_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_GSV').col_dsql := 'sum(nvl(t01.ord_uc_gsv,0))';
      hk_sal_base_excel.tbl_column('ORD_UC_GSV').col_zsql := 'nvl(t01.ord_uc_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('ORD_UC_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_UC_GSV').col_decr := 3;
      hk_sal_base_excel.tbl_column('ORD_UC_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('ORD_UC_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('ORD_UC_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('ORD_UC_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('ORD_UC_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_NIV').col_htxt := 'Unconfirmed NIV';
      hk_sal_base_excel.tbl_column('ORD_UC_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('ORD_UC_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_NIV').col_dsql := 'sum(nvl(t01.ord_uc_niv,0))';
      hk_sal_base_excel.tbl_column('ORD_UC_NIV').col_zsql := 'nvl(t01.ord_uc_niv,0) != 0';
      hk_sal_base_excel.tbl_column('ORD_UC_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_UC_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_UC_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('ORD_UC_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('ORD_UC_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('ORD_UC_NIV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('ORD_CN_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_QTY').col_htxt := 'Confirmed QTY';
      hk_sal_base_excel.tbl_column('ORD_CN_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('ORD_CN_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_QTY').col_dsql := 'sum(nvl(t01.ord_cn_qty,0))';
      hk_sal_base_excel.tbl_column('ORD_CN_QTY').col_zsql := 'nvl(t01.ord_cn_qty,0) != 0';
      hk_sal_base_excel.tbl_column('ORD_CN_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('ORD_CN_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('ORD_CN_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('ORD_CN_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('ORD_CN_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('ORD_CN_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('ORD_CN_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_TON').col_htxt := 'Confirmed TON';
      hk_sal_base_excel.tbl_column('ORD_CN_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('ORD_CN_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_TON').col_dsql := 'sum(nvl(t01.ord_cn_ton,0))';
      hk_sal_base_excel.tbl_column('ORD_CN_TON').col_zsql := 'nvl(t01.ord_cn_ton,0) != 0';
      hk_sal_base_excel.tbl_column('ORD_CN_TON').col_decp := 6;
      hk_sal_base_excel.tbl_column('ORD_CN_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_CN_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('ORD_CN_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('ORD_CN_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('ORD_CN_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('ORD_CN_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_GSV').col_htxt := 'Confirmed GSV';
      hk_sal_base_excel.tbl_column('ORD_CN_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('ORD_CN_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_GSV').col_dsql := 'sum(nvl(t01.ord_cn_gsv,0))';
      hk_sal_base_excel.tbl_column('ORD_CN_GSV').col_zsql := 'nvl(t01.ord_cn_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('ORD_CN_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_CN_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_CN_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('ORD_CN_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('ORD_CN_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('ORD_CN_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('ORD_CN_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_NIV').col_htxt := 'Confirmed NIV';
      hk_sal_base_excel.tbl_column('ORD_CN_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('ORD_CN_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_NIV').col_dsql := 'sum(nvl(t01.ord_cn_niv,0))';
      hk_sal_base_excel.tbl_column('ORD_CN_NIV').col_zsql := 'nvl(t01.ord_cn_niv,0) != 0';
      hk_sal_base_excel.tbl_column('ORD_CN_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_CN_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_CN_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('ORD_CN_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('ORD_CN_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('ORD_CN_NIV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('ORD_UP_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_QTY').col_htxt := 'Unposted QTY';
      hk_sal_base_excel.tbl_column('ORD_UP_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('ORD_UP_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_QTY').col_dsql := 'sum(nvl(t01.ord_uc_qty,0)+nvl(t01.ord_cn_qty,0))';
      hk_sal_base_excel.tbl_column('ORD_UP_QTY').col_zsql := '(nvl(t01.ord_uc_qty,0)+nvl(t01.ord_cn_qty,0)) != 0';
      hk_sal_base_excel.tbl_column('ORD_UP_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('ORD_UP_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('ORD_UP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('ORD_UP_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('ORD_UP_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('ORD_UP_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('ORD_UP_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_TON').col_htxt := 'Unposted TON';
      hk_sal_base_excel.tbl_column('ORD_UP_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('ORD_UP_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_TON').col_dsql := 'sum(nvl(t01.ord_uc_ton,0)+nvl(t01.ord_cn_ton,0))';
      hk_sal_base_excel.tbl_column('ORD_UP_TON').col_zsql := '(nvl(t01.ord_uc_ton,0)+nvl(t01.ord_cn_ton,0)) != 0';
      hk_sal_base_excel.tbl_column('ORD_UP_TON').col_decp := 6;
      hk_sal_base_excel.tbl_column('ORD_UP_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_UP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('ORD_UP_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('ORD_UP_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('ORD_UP_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('ORD_UP_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_GSV').col_htxt := 'Unposted GSV';
      hk_sal_base_excel.tbl_column('ORD_UP_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('ORD_UP_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_GSV').col_dsql := 'sum(nvl(t01.ord_uc_gsv,0)+nvl(t01.ord_cn_gsv,0))';
      hk_sal_base_excel.tbl_column('ORD_UP_GSV').col_zsql := '(nvl(t01.ord_uc_gsv,0)+nvl(t01.ord_cn_gsv,0)) != 0';
      hk_sal_base_excel.tbl_column('ORD_UP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_UP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_UP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('ORD_UP_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('ORD_UP_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('ORD_UP_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('ORD_UP_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_NIV').col_htxt := 'Unposted NIV';
      hk_sal_base_excel.tbl_column('ORD_UP_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('ORD_UP_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_NIV').col_dsql := 'sum(nvl(t01.ord_uc_niv,0)+nvl(t01.ord_cn_niv,0))';
      hk_sal_base_excel.tbl_column('ORD_UP_NIV').col_zsql := '(nvl(t01.ord_uc_niv,0)+nvl(t01.ord_cn_niv,0)) != 0';
      hk_sal_base_excel.tbl_column('ORD_UP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_UP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_UP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('ORD_UP_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('ORD_UP_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('ORD_UP_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('ORD_UC_QTY_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_QTY_SHR').col_htxt := 'Unconfirmed QTY % Share';
      hk_sal_base_excel.tbl_column('ORD_UC_QTY_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('ORD_UC_QTY_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_QTY_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('ORD_UC_QTY_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('ORD_UC_QTY_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_UC_QTY_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_UC_QTY_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_QTY_SHR').col_ref1 := 'ORD_UC_QTY';
      hk_sal_base_excel.tbl_column('ORD_UC_QTY_SHR').col_ref2 := 'ORD_UC_QTY';
      hk_sal_base_excel.tbl_column('ORD_UC_QTY_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('ORD_UC_QTY_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('ORD_UC_TON_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_TON_SHR').col_htxt := 'Unconfirmed QTY % Share';
      hk_sal_base_excel.tbl_column('ORD_UC_TON_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('ORD_UC_TON_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_TON_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('ORD_UC_TON_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('ORD_UC_TON_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_UC_TON_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_UC_TON_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_TON_SHR').col_ref1 := 'ORD_UC_TON';
      hk_sal_base_excel.tbl_column('ORD_UC_TON_SHR').col_ref2 := 'ORD_UC_TON';
      hk_sal_base_excel.tbl_column('ORD_UC_TON_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('ORD_UC_TON_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('ORD_UC_GSV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_GSV_SHR').col_htxt := 'Unconfirmed GSV % Share';
      hk_sal_base_excel.tbl_column('ORD_UC_GSV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('ORD_UC_GSV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_GSV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('ORD_UC_GSV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('ORD_UC_GSV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_UC_GSV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_UC_GSV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_GSV_SHR').col_ref1 := 'ORD_UC_GSV';
      hk_sal_base_excel.tbl_column('ORD_UC_GSV_SHR').col_ref2 := 'ORD_UC_GSV';
      hk_sal_base_excel.tbl_column('ORD_UC_GSV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('ORD_UC_GSV_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('ORD_UC_NIV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_NIV_SHR').col_htxt := 'Unconfirmed NIV % Share';
      hk_sal_base_excel.tbl_column('ORD_UC_NIV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('ORD_UC_NIV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_NIV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('ORD_UC_NIV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('ORD_UC_NIV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_UC_NIV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_UC_NIV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UC_NIV_SHR').col_ref1 := 'ORD_UC_NIV';
      hk_sal_base_excel.tbl_column('ORD_UC_NIV_SHR').col_ref2 := 'ORD_UC_NIV';
      hk_sal_base_excel.tbl_column('ORD_UC_NIV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('ORD_UC_NIV_SHR').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('ORD_CN_QTY_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_QTY_SHR').col_htxt := 'Confirmed QTY % Share';
      hk_sal_base_excel.tbl_column('ORD_CN_QTY_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('ORD_CN_QTY_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_QTY_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('ORD_CN_QTY_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('ORD_CN_QTY_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_CN_QTY_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_CN_QTY_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_QTY_SHR').col_ref1 := 'ORD_CN_QTY';
      hk_sal_base_excel.tbl_column('ORD_CN_QTY_SHR').col_ref2 := 'ORD_CN_QTY';
      hk_sal_base_excel.tbl_column('ORD_CN_QTY_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('ORD_CN_QTY_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('ORD_CN_TON_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_TON_SHR').col_htxt := 'Confirmed QTY % Share';
      hk_sal_base_excel.tbl_column('ORD_CN_TON_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('ORD_CN_TON_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_TON_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('ORD_CN_TON_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('ORD_CN_TON_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_CN_TON_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_CN_TON_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_TON_SHR').col_ref1 := 'ORD_CN_TON';
      hk_sal_base_excel.tbl_column('ORD_CN_TON_SHR').col_ref2 := 'ORD_CN_TON';
      hk_sal_base_excel.tbl_column('ORD_CN_TON_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('ORD_CN_TON_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('ORD_CN_GSV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_GSV_SHR').col_htxt := 'Confirmed GSV % Share';
      hk_sal_base_excel.tbl_column('ORD_CN_GSV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('ORD_CN_GSV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_GSV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('ORD_CN_GSV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('ORD_CN_GSV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_CN_GSV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_CN_GSV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_GSV_SHR').col_ref1 := 'ORD_CN_GSV';
      hk_sal_base_excel.tbl_column('ORD_CN_GSV_SHR').col_ref2 := 'ORD_CN_GSV';
      hk_sal_base_excel.tbl_column('ORD_CN_GSV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('ORD_CN_GSV_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('ORD_CN_NIV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_NIV_SHR').col_htxt := 'Confirmed NIV % Share';
      hk_sal_base_excel.tbl_column('ORD_CN_NIV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('ORD_CN_NIV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_NIV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('ORD_CN_NIV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('ORD_CN_NIV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_CN_NIV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_CN_NIV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_CN_NIV_SHR').col_ref1 := 'ORD_CN_NIV';
      hk_sal_base_excel.tbl_column('ORD_CN_NIV_SHR').col_ref2 := 'ORD_CN_NIV';
      hk_sal_base_excel.tbl_column('ORD_CN_NIV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('ORD_CN_NIV_SHR').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('ORD_UP_QTY_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_QTY_SHR').col_htxt := 'Unposted QTY % Share';
      hk_sal_base_excel.tbl_column('ORD_UP_QTY_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('ORD_UP_QTY_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_QTY_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('ORD_UP_QTY_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('ORD_UP_QTY_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_UP_QTY_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_UP_QTY_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_QTY_SHR').col_ref1 := 'ORD_UP_QTY';
      hk_sal_base_excel.tbl_column('ORD_UP_QTY_SHR').col_ref2 := 'ORD_UP_QTY';
      hk_sal_base_excel.tbl_column('ORD_UP_QTY_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('ORD_UP_QTY_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('ORD_UP_TON_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_TON_SHR').col_htxt := 'Unposted QTY % Share';
      hk_sal_base_excel.tbl_column('ORD_UP_TON_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('ORD_UP_TON_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_TON_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('ORD_UP_TON_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('ORD_UP_TON_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_UP_TON_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_UP_TON_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_TON_SHR').col_ref1 := 'ORD_UP_TON';
      hk_sal_base_excel.tbl_column('ORD_UP_TON_SHR').col_ref2 := 'ORD_UP_TON';
      hk_sal_base_excel.tbl_column('ORD_UP_TON_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('ORD_UP_TON_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('ORD_UP_GSV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_GSV_SHR').col_htxt := 'Unposted GSV % Share';
      hk_sal_base_excel.tbl_column('ORD_UP_GSV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('ORD_UP_GSV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_GSV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('ORD_UP_GSV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('ORD_UP_GSV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_UP_GSV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_UP_GSV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_GSV_SHR').col_ref1 := 'ORD_UP_GSV';
      hk_sal_base_excel.tbl_column('ORD_UP_GSV_SHR').col_ref2 := 'ORD_UP_GSV';
      hk_sal_base_excel.tbl_column('ORD_UP_GSV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('ORD_UP_GSV_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('ORD_UP_NIV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_NIV_SHR').col_htxt := 'Unposted NIV % Share';
      hk_sal_base_excel.tbl_column('ORD_UP_NIV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('ORD_UP_NIV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_NIV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('ORD_UP_NIV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('ORD_UP_NIV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('ORD_UP_NIV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('ORD_UP_NIV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('ORD_UP_NIV_SHR').col_ref1 := 'ORD_UP_NIV';
      hk_sal_base_excel.tbl_column('ORD_UP_NIV_SHR').col_ref2 := 'ORD_UP_NIV';
      hk_sal_base_excel.tbl_column('ORD_UP_NIV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('ORD_UP_NIV_SHR').col_lnd2 := 'NoY';

      /*-*/
      /* Current day column variables
      /*-*/
      hk_sal_base_excel.tbl_column('CUR_DY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_QTY').col_htxt := 'Day QTY';
      hk_sal_base_excel.tbl_column('CUR_DY_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('CUR_DY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_QTY').col_dsql := 'sum(nvl(t01.cur_dy_qty,0))';
      hk_sal_base_excel.tbl_column('CUR_DY_QTY').col_zsql := 'nvl(t01.cur_dy_qty,0) != 0';
      hk_sal_base_excel.tbl_column('CUR_DY_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('CUR_DY_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('CUR_DY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('CUR_DY_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('CUR_DY_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('CUR_DY_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('CUR_DY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_TON').col_htxt := 'Day TON';
      hk_sal_base_excel.tbl_column('CUR_DY_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('CUR_DY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_TON').col_dsql := 'sum(nvl(t01.cur_dy_ton,0))';
      hk_sal_base_excel.tbl_column('CUR_DY_TON').col_zsql := 'nvl(t01.cur_dy_ton,0) != 0';
      hk_sal_base_excel.tbl_column('CUR_DY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('CUR_DY_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('CUR_DY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('CUR_DY_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('CUR_DY_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('CUR_DY_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('CUR_DY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_GSV').col_htxt := 'Day GSV';
      hk_sal_base_excel.tbl_column('CUR_DY_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('CUR_DY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_GSV').col_dsql := 'sum(nvl(t01.cur_dy_gsv,0))';
      hk_sal_base_excel.tbl_column('CUR_DY_GSV').col_zsql := 'nvl(t01.cur_dy_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('CUR_DY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('CUR_DY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('CUR_DY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('CUR_DY_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('CUR_DY_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('CUR_DY_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('CUR_DY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_NIV').col_htxt := 'Day NIV';
      hk_sal_base_excel.tbl_column('CUR_DY_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('CUR_DY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_NIV').col_dsql := 'sum(nvl(t01.cur_dy_niv,0))';
      hk_sal_base_excel.tbl_column('CUR_DY_NIV').col_zsql := 'nvl(t01.cur_dy_niv,0) != 0';
      hk_sal_base_excel.tbl_column('CUR_DY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('CUR_DY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('CUR_DY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('CUR_DY_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('CUR_DY_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('CUR_DY_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('CUR_DY_QTY_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_QTY_SHR').col_htxt := 'Day QTY % Share';
      hk_sal_base_excel.tbl_column('CUR_DY_QTY_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('CUR_DY_QTY_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_QTY_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('CUR_DY_QTY_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('CUR_DY_QTY_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('CUR_DY_QTY_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('CUR_DY_QTY_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_QTY_SHR').col_ref1 := 'CUR_DY_QTY';
      hk_sal_base_excel.tbl_column('CUR_DY_QTY_SHR').col_ref2 := 'CUR_DY_QTY';
      hk_sal_base_excel.tbl_column('CUR_DY_QTY_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('CUR_DY_QTY_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('CUR_DY_TON_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_TON_SHR').col_htxt := 'Day QTY % Share';
      hk_sal_base_excel.tbl_column('CUR_DY_TON_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('CUR_DY_TON_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_TON_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('CUR_DY_TON_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('CUR_DY_TON_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('CUR_DY_TON_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('CUR_DY_TON_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_TON_SHR').col_ref1 := 'CUR_DY_TON';
      hk_sal_base_excel.tbl_column('CUR_DY_TON_SHR').col_ref2 := 'CUR_DY_TON';
      hk_sal_base_excel.tbl_column('CUR_DY_TON_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('CUR_DY_TON_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('CUR_DY_GSV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_GSV_SHR').col_htxt := 'Day GSV % Share';
      hk_sal_base_excel.tbl_column('CUR_DY_GSV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('CUR_DY_GSV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_GSV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('CUR_DY_GSV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('CUR_DY_GSV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('CUR_DY_GSV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('CUR_DY_GSV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_GSV_SHR').col_ref1 := 'CUR_DY_GSV';
      hk_sal_base_excel.tbl_column('CUR_DY_GSV_SHR').col_ref2 := 'CUR_DY_GSV';
      hk_sal_base_excel.tbl_column('CUR_DY_GSV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('CUR_DY_GSV_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('CUR_DY_NIV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_NIV_SHR').col_htxt := 'Day NIV % Share';
      hk_sal_base_excel.tbl_column('CUR_DY_NIV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('CUR_DY_NIV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_NIV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('CUR_DY_NIV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('CUR_DY_NIV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('CUR_DY_NIV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('CUR_DY_NIV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('CUR_DY_NIV_SHR').col_ref1 := 'CUR_DY_NIV';
      hk_sal_base_excel.tbl_column('CUR_DY_NIV_SHR').col_ref2 := 'CUR_DY_NIV';
      hk_sal_base_excel.tbl_column('CUR_DY_NIV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('CUR_DY_NIV_SHR').col_lnd2 := 'NoY';

      /*-*/
      /* Period to date column variables
      /*-*/
      hk_sal_base_excel.tbl_column('PTD_TY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_QTY').col_htxt := 'PTD ACT QTY';
      hk_sal_base_excel.tbl_column('PTD_TY_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_TY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_QTY').col_dsql := 'sum(nvl(t01.cur_ty_qty,0))';
      hk_sal_base_excel.tbl_column('PTD_TY_QTY').col_zsql := 'nvl(t01.cur_ty_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_TY_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PTD_TY_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PTD_TY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_TY_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_TY_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_TY_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_TY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_TON').col_htxt := 'PTD ACT TON';
      hk_sal_base_excel.tbl_column('PTD_TY_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_TY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_TON').col_dsql := 'sum(nvl(t01.cur_ty_ton,0))';
      hk_sal_base_excel.tbl_column('PTD_TY_TON').col_zsql := 'nvl(t01.cur_ty_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_TY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PTD_TY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_TY_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_TY_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_TY_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_TY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_GSV').col_htxt := 'PTD ACT GSV';
      hk_sal_base_excel.tbl_column('PTD_TY_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_TY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_GSV').col_dsql := 'sum(nvl(t01.cur_ty_gsv,0))';
      hk_sal_base_excel.tbl_column('PTD_TY_GSV').col_zsql := 'nvl(t01.cur_ty_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_TY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_TY_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_TY_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_TY_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_TY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_NIV').col_htxt := 'PTD ACT NIV';
      hk_sal_base_excel.tbl_column('PTD_TY_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_TY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_NIV').col_dsql := 'sum(nvl(t01.cur_ty_niv,0))';
      hk_sal_base_excel.tbl_column('PTD_TY_NIV').col_zsql := 'nvl(t01.cur_ty_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_TY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_TY_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_TY_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_TY_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('PTD_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_QTY').col_htxt := 'SPLY QTY';
      hk_sal_base_excel.tbl_column('PTD_LY_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_QTY').col_dsql := 'sum(nvl(t01.cur_ly_qty,0))';
      hk_sal_base_excel.tbl_column('PTD_LY_QTY').col_zsql := 'nvl(t01.cur_ly_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_LY_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PTD_LY_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PTD_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_LY_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_LY_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_LY_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_TON').col_htxt := 'SPLY TON';
      hk_sal_base_excel.tbl_column('PTD_LY_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_TON').col_dsql := 'sum(nvl(t01.cur_ly_ton,0))';
      hk_sal_base_excel.tbl_column('PTD_LY_TON').col_zsql := 'nvl(t01.cur_ly_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_LY_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PTD_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_LY_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_LY_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_LY_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_GSV').col_htxt := 'SPLY GSV';
      hk_sal_base_excel.tbl_column('PTD_LY_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_GSV').col_dsql := 'sum(nvl(t01.cur_ly_gsv,0))';
      hk_sal_base_excel.tbl_column('PTD_LY_GSV').col_zsql := 'nvl(t01.cur_ly_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_LY_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_LY_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_LY_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_NIV').col_htxt := 'SPLY NIV';
      hk_sal_base_excel.tbl_column('PTD_LY_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_NIV').col_dsql := 'sum(nvl(t01.cur_ly_niv,0))';
      hk_sal_base_excel.tbl_column('PTD_LY_NIV').col_zsql := 'nvl(t01.cur_ly_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_LY_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_LY_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_LY_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('PTD_OP_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_OP_QTY').col_htxt := 'PTD OP QTY';
      hk_sal_base_excel.tbl_column('PTD_OP_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_OP_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_OP_QTY').col_dsql := 'sum(nvl(t01.cur_op_qty,0))';
      hk_sal_base_excel.tbl_column('PTD_OP_QTY').col_zsql := 'nvl(t01.cur_op_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_OP_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PTD_OP_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PTD_OP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_OP_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_OP_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_OP_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_OP_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_OP_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_OP_TON').col_htxt := 'PTD OP TON';
      hk_sal_base_excel.tbl_column('PTD_OP_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_OP_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_OP_TON').col_dsql := 'sum(nvl(t01.cur_op_ton,0))';
      hk_sal_base_excel.tbl_column('PTD_OP_TON').col_zsql := 'nvl(t01.cur_op_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_OP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_OP_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PTD_OP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_OP_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_OP_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_OP_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_OP_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_OP_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_OP_GSV').col_htxt := 'PTD OP GSV';
      hk_sal_base_excel.tbl_column('PTD_OP_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_OP_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_OP_GSV').col_dsql := 'sum(nvl(t01.cur_op_gsv,0))';
      hk_sal_base_excel.tbl_column('PTD_OP_GSV').col_zsql := 'nvl(t01.cur_op_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_OP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_OP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_OP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_OP_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_OP_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_OP_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_OP_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_OP_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_OP_NIV').col_htxt := 'PTD OP NIV';
      hk_sal_base_excel.tbl_column('PTD_OP_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_OP_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_OP_NIV').col_dsql := 'sum(nvl(t01.cur_op_niv,0))';
      hk_sal_base_excel.tbl_column('PTD_OP_NIV').col_zsql := 'nvl(t01.cur_op_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_OP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_OP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_OP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_OP_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_OP_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_OP_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_OP_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('PTD_BR_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_BR_QTY').col_htxt := 'PTD BR QTY';
      hk_sal_base_excel.tbl_column('PTD_BR_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_BR_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_BR_QTY').col_dsql := 'sum(nvl(t01.cur_br_qty,0))';
      hk_sal_base_excel.tbl_column('PTD_BR_QTY').col_zsql := 'nvl(t01.cur_br_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_BR_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PTD_BR_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PTD_BR_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_BR_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_BR_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_BR_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_BR_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_BR_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_BR_TON').col_htxt := 'PTD BR TON';
      hk_sal_base_excel.tbl_column('PTD_BR_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_BR_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_BR_TON').col_dsql := 'sum(nvl(t01.cur_br_ton,0))';
      hk_sal_base_excel.tbl_column('PTD_BR_TON').col_zsql := 'nvl(t01.cur_br_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_BR_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_BR_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PTD_BR_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_BR_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_BR_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_BR_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_BR_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_BR_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_BR_GSV').col_htxt := 'PTD BR GSV';
      hk_sal_base_excel.tbl_column('PTD_BR_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_BR_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_BR_GSV').col_dsql := 'sum(nvl(t01.cur_br_gsv,0))';
      hk_sal_base_excel.tbl_column('PTD_BR_GSV').col_zsql := 'nvl(t01.cur_br_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_BR_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_BR_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_BR_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_BR_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_BR_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_BR_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_BR_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_BR_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_BR_NIV').col_htxt := 'PTD BR NIV';
      hk_sal_base_excel.tbl_column('PTD_BR_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_BR_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_BR_NIV').col_dsql := 'sum(nvl(t01.cur_br_niv,0))';
      hk_sal_base_excel.tbl_column('PTD_BR_NIV').col_zsql := 'nvl(t01.cur_br_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_BR_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_BR_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_BR_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_BR_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_BR_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_BR_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_BR_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('PTD_RB_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_RB_QTY').col_htxt := 'PTD ROB QTY';
      hk_sal_base_excel.tbl_column('PTD_RB_QTY').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_RB_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_RB_QTY').col_dsql := 'sum(nvl(t01.cur_rb_qty,0))';
      hk_sal_base_excel.tbl_column('PTD_RB_QTY').col_zsql := 'nvl(t01.cur_rb_qty,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_RB_QTY').col_decp := 0;
      hk_sal_base_excel.tbl_column('PTD_RB_QTY').col_decr := 0;
      hk_sal_base_excel.tbl_column('PTD_RB_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_RB_QTY').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_RB_QTY').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_RB_QTY').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_RB_QTY').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_RB_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_RB_TON').col_htxt := 'PTD ROB TON';
      hk_sal_base_excel.tbl_column('PTD_RB_TON').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_RB_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_RB_TON').col_dsql := 'sum(nvl(t01.cur_rb_ton,0))';
      hk_sal_base_excel.tbl_column('PTD_RB_TON').col_zsql := 'nvl(t01.cur_rb_ton,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_RB_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_RB_TON').col_decr := 6;
      hk_sal_base_excel.tbl_column('PTD_RB_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_RB_TON').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_RB_TON').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_RB_TON').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_RB_TON').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_RB_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_RB_GSV').col_htxt := 'PTD ROB GSV';
      hk_sal_base_excel.tbl_column('PTD_RB_GSV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_RB_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_RB_GSV').col_dsql := 'sum(nvl(t01.cur_rb_gsv,0))';
      hk_sal_base_excel.tbl_column('PTD_RB_GSV').col_zsql := 'nvl(t01.cur_rb_gsv,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_RB_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_RB_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_RB_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_RB_GSV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_RB_GSV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_RB_GSV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_RB_GSV').col_lnd2 := null;

      hk_sal_base_excel.tbl_column('PTD_RB_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_RB_NIV').col_htxt := 'PTD ROB NIV';
      hk_sal_base_excel.tbl_column('PTD_RB_NIV').col_ctyp := '1';
      hk_sal_base_excel.tbl_column('PTD_RB_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_RB_NIV').col_dsql := 'sum(nvl(t01.cur_rb_niv,0))';
      hk_sal_base_excel.tbl_column('PTD_RB_NIV').col_zsql := 'nvl(t01.cur_rb_niv,0) != 0';
      hk_sal_base_excel.tbl_column('PTD_RB_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_RB_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_RB_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_RB_NIV').col_ref1 := null;
      hk_sal_base_excel.tbl_column('PTD_RB_NIV').col_ref2 := null;
      hk_sal_base_excel.tbl_column('PTD_RB_NIV').col_lnd1 := null;
      hk_sal_base_excel.tbl_column('PTD_RB_NIV').col_lnd2 := null;

      /*-*/

      hk_sal_base_excel.tbl_column('PTD_TY_LY_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_QTY').col_htxt := 'PTD QTY ACT % SPLY';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_QTY').col_ref1 := 'PTD_TY_QTY';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_QTY').col_ref2 := 'PTD_LY_QTY';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_LY_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_TON').col_htxt := 'PTD TON ACT % SPLY';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_TON').col_ref1 := 'PTD_TY_TON';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_TON').col_ref2 := 'PTD_LY_TON';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_LY_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_GSV').col_htxt := 'PTD GSV ACT % SPLY';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_GSV').col_ref1 := 'PTD_TY_GSV';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_GSV').col_ref2 := 'PTD_LY_GSV';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_LY_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_NIV').col_htxt := 'PTD NIV ACT % SPLY';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_LY_NIV').col_ref1 := 'PTD_TY_NIV';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_NIV').col_ref2 := 'PTD_LY_NIV';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_LY_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('PTD_TY_OP_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_QTY').col_htxt := 'PTD QTY ACT % OP';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_QTY').col_ref1 := 'PTD_TY_QTY';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_QTY').col_ref2 := 'PTD_OP_QTY';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_OP_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_TON').col_htxt := 'PTD TON ACT % OP';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_TON').col_ref1 := 'PTD_TY_TON';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_TON').col_ref2 := 'PTD_OP_TON';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_OP_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_GSV').col_htxt := 'PTD GSV ACT % OP';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_GSV').col_ref1 := 'PTD_TY_GSV';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_GSV').col_ref2 := 'PTD_OP_GSV';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_OP_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_NIV').col_htxt := 'PTD NIV ACT % OP';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_OP_NIV').col_ref1 := 'PTD_TY_NIV';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_NIV').col_ref2 := 'PTD_OP_NIV';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_OP_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('PTD_TY_BR_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_QTY').col_htxt := 'PTD QTY ACT % BR';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_QTY').col_ref1 := 'PTD_TY_QTY';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_QTY').col_ref2 := 'PTD_BR_QTY';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_BR_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_TON').col_htxt := 'PTD TON ACT % BR';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_TON').col_ref1 := 'PTD_TY_TON';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_TON').col_ref2 := 'PTD_BR_TON';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_BR_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_GSV').col_htxt := 'PTD GSV ACT % BR';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_GSV').col_ref1 := 'PTD_TY_GSV';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_GSV').col_ref2 := 'PTD_BR_GSV';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_BR_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_NIV').col_htxt := 'PTD NIV ACT % BR';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_BR_NIV').col_ref1 := 'PTD_TY_NIV';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_NIV').col_ref2 := 'PTD_BR_NIV';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_BR_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('PTD_TY_RB_QTY').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_QTY').col_htxt := 'PTD QTY ACT % ROB';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_QTY').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_QTY').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_QTY').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_QTY').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_QTY').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_QTY').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_QTY').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_QTY').col_ref1 := 'PTD_TY_QTY';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_QTY').col_ref2 := 'PTD_RB_QTY';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_QTY').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_QTY').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_RB_TON').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_TON').col_htxt := 'PTD TON ACT % ROB';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_TON').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_TON').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_TON').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_TON').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_TON').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_TON').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_TON').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_TON').col_ref1 := 'PTD_TY_TON';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_TON').col_ref2 := 'PTD_RB_TON';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_TON').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_TON').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_RB_GSV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_GSV').col_htxt := 'PTD GSV ACT % ROB';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_GSV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_GSV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_GSV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_GSV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_GSV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_GSV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_GSV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_GSV').col_ref1 := 'PTD_TY_GSV';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_GSV').col_ref2 := 'PTD_RB_GSV';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_GSV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_GSV').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_RB_NIV').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_NIV').col_htxt := 'PTD NIV ACT % ROB';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_NIV').col_ctyp := '2';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_NIV').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_NIV').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_NIV').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_NIV').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_NIV').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_NIV').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_RB_NIV').col_ref1 := 'PTD_TY_NIV';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_NIV').col_ref2 := 'PTD_RB_NIV';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_NIV').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_RB_NIV').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('PTD_TY_QTY_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_QTY_SHR').col_htxt := 'PTD ACT QTY % Share';
      hk_sal_base_excel.tbl_column('PTD_TY_QTY_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PTD_TY_QTY_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_QTY_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_QTY_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_QTY_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_QTY_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_QTY_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_QTY_SHR').col_ref1 := 'PTD_TY_QTY';
      hk_sal_base_excel.tbl_column('PTD_TY_QTY_SHR').col_ref2 := 'PTD_TY_QTY';
      hk_sal_base_excel.tbl_column('PTD_TY_QTY_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_QTY_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_TON_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_TON_SHR').col_htxt := 'PTD ACT QTY % Share';
      hk_sal_base_excel.tbl_column('PTD_TY_TON_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PTD_TY_TON_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_TON_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_TON_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_TON_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_TON_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_TON_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_TON_SHR').col_ref1 := 'PTD_TY_TON';
      hk_sal_base_excel.tbl_column('PTD_TY_TON_SHR').col_ref2 := 'PTD_TY_TON';
      hk_sal_base_excel.tbl_column('PTD_TY_TON_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_TON_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_GSV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_GSV_SHR').col_htxt := 'PTD ACT GSV % Share';
      hk_sal_base_excel.tbl_column('PTD_TY_GSV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PTD_TY_GSV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_GSV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_GSV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_GSV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_GSV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_GSV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_GSV_SHR').col_ref1 := 'PTD_TY_GSV';
      hk_sal_base_excel.tbl_column('PTD_TY_GSV_SHR').col_ref2 := 'PTD_TY_GSV';
      hk_sal_base_excel.tbl_column('PTD_TY_GSV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_GSV_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_TY_NIV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_NIV_SHR').col_htxt := 'PTD ACT NIV % Share';
      hk_sal_base_excel.tbl_column('PTD_TY_NIV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PTD_TY_NIV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_NIV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_TY_NIV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_TY_NIV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_NIV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_TY_NIV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_TY_NIV_SHR').col_ref1 := 'PTD_TY_NIV';
      hk_sal_base_excel.tbl_column('PTD_TY_NIV_SHR').col_ref2 := 'PTD_TY_NIV';
      hk_sal_base_excel.tbl_column('PTD_TY_NIV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_TY_NIV_SHR').col_lnd2 := 'NoY';

      /*-*/

      hk_sal_base_excel.tbl_column('PTD_LY_QTY_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_QTY_SHR').col_htxt := 'SPLY QTY % Share';
      hk_sal_base_excel.tbl_column('PTD_LY_QTY_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PTD_LY_QTY_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_QTY_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_LY_QTY_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_LY_QTY_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_LY_QTY_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_LY_QTY_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_QTY_SHR').col_ref1 := 'PTD_LY_QTY';
      hk_sal_base_excel.tbl_column('PTD_LY_QTY_SHR').col_ref2 := 'PTD_LY_QTY';
      hk_sal_base_excel.tbl_column('PTD_LY_QTY_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_LY_QTY_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_LY_TON_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_TON_SHR').col_htxt := 'SPLY QTY % Share';
      hk_sal_base_excel.tbl_column('PTD_LY_TON_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PTD_LY_TON_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_TON_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_LY_TON_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_LY_TON_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_LY_TON_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_LY_TON_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_TON_SHR').col_ref1 := 'PTD_LY_TON';
      hk_sal_base_excel.tbl_column('PTD_LY_TON_SHR').col_ref2 := 'PTD_LY_TON';
      hk_sal_base_excel.tbl_column('PTD_LY_TON_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_LY_TON_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_LY_GSV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_GSV_SHR').col_htxt := 'SPLY GSV % Share';
      hk_sal_base_excel.tbl_column('PTD_LY_GSV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PTD_LY_GSV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_GSV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_LY_GSV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_LY_GSV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_LY_GSV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_LY_GSV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_GSV_SHR').col_ref1 := 'PTD_LY_GSV';
      hk_sal_base_excel.tbl_column('PTD_LY_GSV_SHR').col_ref2 := 'PTD_LY_GSV';
      hk_sal_base_excel.tbl_column('PTD_LY_GSV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_LY_GSV_SHR').col_lnd2 := 'NoY';

      hk_sal_base_excel.tbl_column('PTD_LY_NIV_SHR').col_tabi := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_NIV_SHR').col_htxt := 'SPLY NIV % Share';
      hk_sal_base_excel.tbl_column('PTD_LY_NIV_SHR').col_ctyp := '3';
      hk_sal_base_excel.tbl_column('PTD_LY_NIV_SHR').col_ccnt := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_NIV_SHR').col_dsql := '0';
      hk_sal_base_excel.tbl_column('PTD_LY_NIV_SHR').col_zsql := null;
      hk_sal_base_excel.tbl_column('PTD_LY_NIV_SHR').col_decp := 2;
      hk_sal_base_excel.tbl_column('PTD_LY_NIV_SHR').col_decr := 2;
      hk_sal_base_excel.tbl_column('PTD_LY_NIV_SHR').col_scle := 1;
      hk_sal_base_excel.tbl_column('PTD_LY_NIV_SHR').col_ref1 := 'PTD_LY_NIV';
      hk_sal_base_excel.tbl_column('PTD_LY_NIV_SHR').col_ref2 := 'PTD_LY_NIV';
      hk_sal_base_excel.tbl_column('PTD_LY_NIV_SHR').col_lnd1 := 'NoX';
      hk_sal_base_excel.tbl_column('PTD_LY_NIV_SHR').col_lnd2 := 'NoY';

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_base_data;

end hk_sal_mat_prd_01_excel;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_sal_mat_prd_01_excel for pld_rep_app.hk_sal_mat_prd_01_excel;
grant execute on hk_sal_mat_prd_01_excel to public;
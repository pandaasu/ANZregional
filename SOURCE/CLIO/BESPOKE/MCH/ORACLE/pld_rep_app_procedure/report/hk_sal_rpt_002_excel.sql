/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_sal_rpt_002_excel                               */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : October 2007                                       */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_sal_rpt_002_excel as

   /*-*/
   /* Public package methods
   /*-*/
   procedure set_print_override(par_print_xml in varchar2);
   procedure set_parameter_string(par_parameter in varchar2, par_value in varchar2);
   procedure set_parameter_number(par_parameter in varchar2, par_value in number);
   procedure set_parameter_date(par_parameter in varchar2, par_value in date);
   procedure set_hierarchy(par_index in number, par_hierarchy in varchar2, par_adj_text in boolean);
   procedure add_group(par_heading in varchar2);
   procedure add_column(par_column in varchar2, par_heading in varchar2, par_dec_print in number, par_dec_round in number, par_sca_factor in number);
   procedure start_report(par_company_code in varchar2);
   procedure define_sheet(par_name in varchar2, par_depth in number);
   procedure start_sheet(par_htxt1 in varchar2);
   procedure retrieve_data;
   procedure end_sheet;

end hk_sal_rpt_002_excel;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_sal_rpt_002_excel as

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

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

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
      hk_sal_base_excel.start_sheet(par_htxt1,null,null);

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

      /*-*/
      /* Initialise the hierarchy variables
      /*-*/
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

      hk_sal_base_excel.tbl_hierarchy('MATERIAL').hie_ssql := 'max(t02.material_desc_en || t02.sap_material_code)';
      hk_sal_base_excel.tbl_hierarchy('MATERIAL').hie_tsql := 'max(''('' || t02.sap_material_code || '') '' || decode(t02.material_desc_en,null,''UNKNOWN'',t02.material_desc_en))';
      hk_sal_base_excel.tbl_hierarchy('MATERIAL').hie_gsql := 't02.sap_material_code';

      /*-*/
      /* Initialise the material tables variables
      /*-*/
      hk_sal_base_excel.tbl_main_name := 'material_dim t02';
      hk_sal_base_excel.tbl_main_join := '''x''=''x'' and sap_material_type_code = ''FERT''';

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_base_data;

end hk_sal_rpt_002_excel;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_sal_rpt_002_excel for pld_rep_app.hk_sal_rpt_002_excel;
grant execute on hk_sal_rpt_002_excel to public;
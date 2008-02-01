/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_sal_format04_excel01                        */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : June 2004                                          */
/****************************************************************/
/**DESCRIPTION**
 Geography Hierarchy Sales Report

 **PARAMETERS**
 par_sap_company_code = SAP company code (mandatory)
 par_for_type = Forecast type (mandatory)
                  PRD_BR = Period BR forecast
                  PRD_LE = Period LE forecast
                  MTH_BR = Month BR forecast
                  MTH_LE = Month LE forecast
 par_print_xml = Print xml data string (optional)
                   Format = SetPrintOverride Orientation='1' FitWidthPages='1' Zoom='0'
                   Orientation = 1(Portrait) 2(Landscape)
                   FitWidthPages = number 0 to 999
                   Zoom = number 0 to 100 (overrides FitWidthPages)

 **NOTES**
 1. NOT APPLICABLE descriptions are replaced based on the SAP codes (hard-coded)
 2. Only rows with sales or forecasts are reported

 **LEGEND**
 NS = No sales
 NF = No forecast
 NP = No plan

**/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_sal_format04_excel01 as
   
   /*-*/
   /* Public declarations */
   /*-*/
   function main(par_sap_company_code in varchar2,
                 par_for_type in varchar2,
                 par_print_xml in varchar2) return varchar2;

end mfjpln_sal_format04_excel01;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_sal_format04_excel01 as

   /*-*/
   /* Private global declarations */
   /*-*/
   procedure doDetail(par_level in number);
   procedure clearReport;
   procedure checkSummary;
   procedure doTotal;
   procedure doHeading;
   procedure doFormat;
   procedure doBorder;

   /*-*/
   /* Private global variables */
   /*-*/
   SUMMARY_MAX number(2,0) := 15;
   var_sum_level number(2,0);
   var_sum_str number(2,0);
   var_sum_end number(2,0);
   var_row_count number(15,0);
   var_details boolean;
   var_sap_company_code varchar2(6 char);
   var_for_type varchar2(6 char);
   var_print_xml varchar2(256 char);
   var_company_desc varchar2(60 char);
   var_extract_date date;
   var_logical_date date;
   var_current_YYYYPP number(6,0);
   var_current_YYYYMM number(6,0);
   var_extract_status varchar2(256 char);
   var_sales_date date;
   var_sales_status varchar2(256 char);
   var_prd_asofdays varchar2(128 char);
   var_prd_percent number(5,2);
   var_mth_asofdays varchar2(128 char);
   var_mth_percent number(5,2);
   type rcdSummary is record(current_value varchar2(256 char),
                             saved_value varchar2(256 char),
                             saved_row number(9,0),
                             description varchar2(128 char),
                             adjust boolean,
                             wrk_cur_billed_qty number,
                             wrk_cur_billed_bps number,
                             wrk_ytd_billed_qty number,
                             wrk_ytd_billed_bps number,
                             wrk_ytd_op_qty number,
                             wrk_ytd_op_bps number,
                             wrk_ytg_op_qty number,
                             wrk_ytg_op_bps number,
                             wrk_cur_for_qty number,
                             wrk_cur_for_bps number,
                             wrk_ytd_for_qty number,
                             wrk_ytd_for_bps number,
                             wrk_ytg_for_qty number,
                             wrk_ytg_for_bps number);
   type typSummary is table of rcdSummary index by binary_integer;
   tblSummary typSummary;

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_sap_company_code in varchar2,
                 par_for_type in varchar2,
                 par_print_xml in varchar2) return varchar2 is

      /*-*/
      /* Exception definitions */
      /*-*/
      ApplicationError exception;
      pragma exception_init(ApplicationError, -20000);

      /*-*/
      /* Variable definitions */
      /*-*/
      var_found boolean;
      var_wrk_string varchar2(2048);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor company_c01 is 
         select company.company_desc
         from company
         where company.sap_company_code = var_sap_company_code;

      cursor pld_sal_format0400_c01 is 
         select t01.extract_date,
                t01.logical_date,
                t01.current_YYYYPP,
                t01.current_YYYYMM,
                t01.extract_status,
                t01.sales_date,
                t01.sales_status,
                t01.prd_asofdays,
                t01.prd_percent,
                t01.mth_asofdays,
                t01.mth_percent
         from pld_sal_format0400 t01;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameter values */
      /*-*/
      var_sap_company_code := par_sap_company_code;
      var_for_type := par_for_type;
      var_print_xml := par_print_xml;

      /*-*/
      /* Retrieve the format control */
      /*-*/
      var_found := true;
      open pld_sal_format0400_c01;
      fetch pld_sal_format0400_c01 into var_extract_date,
                                        var_logical_date,
                                        var_current_YYYYPP,
                                        var_current_YYYYMM,
                                        var_extract_status,
                                        var_sales_date,
                                        var_sales_status,
                                        var_prd_asofdays,
                                        var_prd_percent,
                                        var_mth_asofdays,
                                        var_mth_percent;
      if pld_sal_format0400_c01%notfound then
         var_found := false;
      end if;
      close pld_sal_format0400_c01;
      if var_found = false then
         raise_application_error(-20000, 'Format control row PLD_SAL_FORMAT0400 not found');
      end if;

      /*-*/
      /* Retrieve the company */
      /*-*/
      var_found := true;
      open company_c01;
      fetch company_c01 into var_company_desc;
      if company_c01%notfound then
         var_found := false;
      end if;
      close company_c01;
      if var_found = false then
         raise_application_error(-20000, 'Company ' || var_sap_company_code || ' not found');
      end if;

      /*-*/
      /* Report start */
      /*-*/
      xlxml_object.BeginReport;

      /*-*/
      /* Process the report sheets */
      /*-*/
      doDetail(1);
      doDetail(2);
      doDetail(3);
      doDetail(4);
      doDetail(5);
      doDetail(6);
      doDetail(7);

      /*-*/
      /* Return the status */
      /*-*/
      return '*OK';

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Application error */
      /*-*/
      when ApplicationError then
         return substr(SQLERRM, 1, 512);

      /*-*/
      /* Error trap */
      /*-*/
      when others then
         return substr(SQLERRM, 1, 512);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end main;

   /**********************************************/
   /* This procedure performs the detail routine */
   /**********************************************/
   procedure doDetail(par_level in number) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_level number;
      var_control_code varchar2(10);
      var_wrk_string varchar2(2048 char);
      var_wrk_array varchar2(4000 char);
      var_dynamic_sql varchar2(32767 char);
      var_lvl_literal varchar2(128 char);
      var_col_literal varchar2(8192 char);
      var_srt_literal varchar2(2048 char);
      var_grp_literal varchar2(2048 char);
      var_for_literal varchar2(2048 char);
      var_tab_literal varchar2(2048 char);
      var_sum_desc_1 varchar2(128 char);
      var_sum_desc_2 varchar2(128 char);
      var_sum_desc_3 varchar2(128 char);
      var_sum_desc_4 varchar2(128 char);
      var_sum_desc_5 varchar2(128 char);
      var_sum_desc_6 varchar2(128 char);
      var_sum_desc_7 varchar2(128 char);
      var_sum_desc_8 varchar2(128 char);
      var_sum_desc_9 varchar2(128 char);
      var_sum_desc_10 varchar2(128 char);
      var_sum_desc_11 varchar2(128 char);
      var_sum_desc_12 varchar2(128 char);
      var_sum_desc_13 varchar2(128 char);
      var_sum_desc_14 varchar2(128 char);
      var_sum_desc_15 varchar2(128 char);
      var_sum_sort_1 varchar2(128 char);
      var_sum_sort_2 varchar2(128 char);
      var_sum_sort_3 varchar2(128 char);
      var_sum_sort_4 varchar2(128 char);
      var_sum_sort_5 varchar2(128 char);
      var_sum_sort_6 varchar2(128 char);
      var_sum_sort_7 varchar2(128 char);
      var_sum_sort_8 varchar2(128 char);
      var_sum_sort_9 varchar2(128 char);
      var_sum_sort_10 varchar2(128 char);
      var_sum_sort_11 varchar2(128 char);
      var_sum_sort_12 varchar2(128 char);
      var_sum_sort_13 varchar2(128 char);
      var_sum_sort_14 varchar2(128 char);
      var_sum_sort_15 varchar2(128 char);
      var_det_desc varchar2(128 char);
      var_det_sort varchar2(128 char);
      var_cur_billed_qty number;
      var_cur_billed_bps number;
      var_ytd_billed_qty number;
      var_ytd_billed_bps number;
      var_ytd_op_qty number;
      var_ytd_op_bps number;
      var_ytg_op_qty number;
      var_ytg_op_bps number;
      var_cur_for_qty number;
      var_cur_for_bps number;
      var_ytd_for_qty number;
      var_ytd_for_bps number;
      var_ytg_for_qty number;
      var_ytg_for_bps number;
      type typCursor is ref cursor;
      pld_sal_format04_c01 typCursor;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the report information */
      /*-*/
      clearReport;

      /*-*/
      /* Initialise the query literals */
      /*-*/
      var_control_code := '70001176';
      var_level := par_level;
      if var_level < 1 or var_level > 7 then
         var_level := 1;
      end if;
      if var_level = 1 then
         var_sum_str := 1;
         var_sum_end := 6;
         tblSummary(5).adjust := true;
         tblSummary(6).adjust := true;
         var_lvl_literal := 'Summary';
         var_col_literal := 'max(t01.cust_name_en_level_1) as sum_desc_1,
                             case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                  else max(t03.mkt_sgmnt_desc) end as sum_desc_2,
                             case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                       case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                            else max(t03.mkt_sgmnt_desc) end
                                  else max(t03.supply_sgmnt_desc) end as sum_desc_3,
                             case when max(t03.sap_brand_flag_code) = ''000'' then
                                       case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                 case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                      else max(t03.mkt_sgmnt_desc) end
                                            else max(t03.supply_sgmnt_desc) end
                                  else max(t03.brand_flag_desc) end as sum_desc_4,
                             case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                       case when max(t03.sap_brand_flag_code) = ''000'' then
                                                 case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                           case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                else max(t03.mkt_sgmnt_desc) end
                                                      else max(t03.supply_sgmnt_desc) end
                                            else max(t03.brand_flag_desc) end
                                  else max(t03.brand_sub_flag_desc) end as sum_desc_5,
                             case when max(t03.sap_prdct_pack_size_code) = ''000'' then
                                       case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                                 case when max(t03.sap_brand_flag_code) = ''000'' then
                                                           case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                                     case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                          else max(t03.mkt_sgmnt_desc) end
                                                                else max(t03.supply_sgmnt_desc) end
                                                      else max(t03.brand_flag_desc) end
                                            else max(t03.brand_sub_flag_desc) end
                                  else max(t03.prdct_pack_size_desc) end as sum_desc_6,
                             null as sum_desc_7,
                             null as sum_desc_8,
                             null as sum_desc_9,
                             null as sum_desc_10,
                             null as sum_desc_11,
                             null as sum_desc_12,
                             null as sum_desc_13,
                             null as sum_desc_14,
                             null as sum_desc_15,
                             max(t01.cust_name_en_level_1) as sum_sort_1,
                             case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                  else max(t03.mkt_sgmnt_desc) end as sum_sort_2,
                             case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                       case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                            else max(t03.mkt_sgmnt_desc) end
                                  else max(t03.supply_sgmnt_desc) end as sum_sort_3,
                             case when max(t03.sap_brand_flag_code) = ''000'' then
                                       case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                 case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                      else max(t03.mkt_sgmnt_desc) end
                                            else max(t03.supply_sgmnt_desc) end
                                  else max(t03.brand_flag_desc) end as sum_sort_4,
                             case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                       case when max(t03.sap_brand_flag_code) = ''000'' then
                                                 case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                           case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                else max(t03.mkt_sgmnt_desc) end
                                                      else max(t03.supply_sgmnt_desc) end
                                            else max(t03.brand_flag_desc) end
                                  else max(t03.brand_sub_flag_desc) end as sum_sort_5,
                             case when max(t03.sap_prdct_pack_size_code) = ''000'' then
                                       case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                                 case when max(t03.sap_brand_flag_code) = ''000'' then
                                                           case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                                     case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                          else max(t03.mkt_sgmnt_desc) end
                                                                else max(t03.supply_sgmnt_desc) end
                                                      else max(t03.brand_flag_desc) end
                                            else max(t03.brand_sub_flag_desc) end
                                  else max(t03.prdct_pack_size_desc) end as sum_sort_6,
                             null as sum_sort_7,
                             null as sum_sort_8,
                             null as sum_sort_9,
                             null as sum_sort_10,
                             null as sum_sort_11,
                             null as sum_sort_12,
                             null as sum_sort_13,
                             null as sum_sort_14,
                             null as sum_sort_15,
                             max(''('' || t03.sap_material_code || '') '' || t03.material_desc_en) as det_desc,
                             max(t03.material_desc_en || t03.sap_material_code) as det_sort,';
         var_grp_literal := 't01.sap_cust_code_level_1,
                             t03.sap_mkt_sgmnt_code,
                             t03.sap_supply_sgmnt_code,
                             t03.sap_brand_flag_code,
                             t03.sap_brand_sub_flag_code,
                             t03.sap_prdct_pack_size_code,
                             t03.sap_material_code';
         var_srt_literal := 'sum_sort_1 asc,
                             sum_sort_2 asc,
                             sum_sort_3 asc,
                             sum_sort_4 asc,
                             sum_sort_5 asc,
                             sum_sort_6 asc,
                             det_sort asc';
      elsif var_level = 2 then
         var_sum_str := 2;
         var_sum_end := 7;
         tblSummary(6).adjust := true;
         tblSummary(7).adjust := true;
         var_lvl_literal := 'Region';
         var_col_literal := 'max(''CHANNEL : '' || t01.cust_name_en_level_1) as sum_desc_1,
                             max(t01.cust_name_en_level_2) as sum_desc_2,
                             case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                  else max(t03.mkt_sgmnt_desc) end as sum_desc_3,
                             case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                       case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                            else max(t03.mkt_sgmnt_desc) end
                                  else max(t03.supply_sgmnt_desc) end as sum_desc_4,
                             case when max(t03.sap_brand_flag_code) = ''000'' then
                                       case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                 case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                      else max(t03.mkt_sgmnt_desc) end
                                            else max(t03.supply_sgmnt_desc) end
                                  else max(t03.brand_flag_desc) end as sum_desc_5,
                             case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                       case when max(t03.sap_brand_flag_code) = ''000'' then
                                                 case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                           case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                else max(t03.mkt_sgmnt_desc) end
                                                      else max(t03.supply_sgmnt_desc) end
                                            else max(t03.brand_flag_desc) end
                                  else max(t03.brand_sub_flag_desc) end as sum_desc_6,
                             case when max(t03.sap_prdct_pack_size_code) = ''000'' then
                                       case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                                 case when max(t03.sap_brand_flag_code) = ''000'' then
                                                           case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                                     case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                          else max(t03.mkt_sgmnt_desc) end
                                                                else max(t03.supply_sgmnt_desc) end
                                                      else max(t03.brand_flag_desc) end
                                            else max(t03.brand_sub_flag_desc) end
                                  else max(t03.prdct_pack_size_desc) end as sum_desc_7,
                             null as sum_desc_8,
                             null as sum_desc_9,
                             null as sum_desc_10,
                             null as sum_desc_11,
                             null as sum_desc_12,
                             null as sum_desc_13,
                             null as sum_desc_14,
                             null as sum_desc_15,
                             max(t01.cust_name_en_level_1) as sum_sort_1,
                             max(t01.cust_name_en_level_2) as sum_sort_2,
                             case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                  else max(t03.mkt_sgmnt_desc) end as sum_sort_3,
                             case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                       case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                            else max(t03.mkt_sgmnt_desc) end
                                  else max(t03.supply_sgmnt_desc) end as sum_sort_4,
                             case when max(t03.sap_brand_flag_code) = ''000'' then
                                       case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                 case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                      else max(t03.mkt_sgmnt_desc) end
                                            else max(t03.supply_sgmnt_desc) end
                                  else max(t03.brand_flag_desc) end as sum_sort_5,
                             case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                       case when max(t03.sap_brand_flag_code) = ''000'' then
                                                 case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                           case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                else max(t03.mkt_sgmnt_desc) end
                                                      else max(t03.supply_sgmnt_desc) end
                                            else max(t03.brand_flag_desc) end
                                  else max(t03.brand_sub_flag_desc) end as sum_sort_6,
                             case when max(t03.sap_prdct_pack_size_code) = ''000'' then
                                       case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                                 case when max(t03.sap_brand_flag_code) = ''000'' then
                                                           case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                                     case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                          else max(t03.mkt_sgmnt_desc) end
                                                                else max(t03.supply_sgmnt_desc) end
                                                      else max(t03.brand_flag_desc) end
                                            else max(t03.brand_sub_flag_desc) end
                                  else max(t03.prdct_pack_size_desc) end as sum_sort_7,
                             null as sum_sort_8,
                             null as sum_sort_9,
                             null as sum_sort_10,
                             null as sum_sort_11,
                             null as sum_sort_12,
                             null as sum_sort_13,
                             null as sum_sort_14,
                             null as sum_sort_15,
                             max(''('' || t03.sap_material_code || '') '' || t03.material_desc_en) as det_desc,
                             max(t03.material_desc_en || t03.sap_material_code) as det_sort,';
         var_grp_literal := 't01.sap_cust_code_level_1,
                             t01.sap_cust_code_level_2,
                             t03.sap_mkt_sgmnt_code,
                             t03.sap_supply_sgmnt_code,
                             t03.sap_brand_flag_code,
                             t03.sap_brand_sub_flag_code,
                             t03.sap_prdct_pack_size_code,
                             t03.sap_material_code';
         var_srt_literal := 'sum_sort_1 asc,
                             sum_sort_2 asc,
                             sum_sort_3 asc,
                             sum_sort_4 asc,
                             sum_sort_5 asc,
                             sum_sort_6 asc,
                             sum_sort_7 asc,
                             det_sort asc';
      elsif var_level = 3 then
         var_sum_str := 3;
         var_sum_end := 8;
         tblSummary(7).adjust := true;
         tblSummary(8).adjust := true;
         var_lvl_literal := 'District';
         var_col_literal := 'max(''CHANNEL : '' || t01.cust_name_en_level_1) as sum_desc_1,
                             max(''REGION : '' || t01.cust_name_en_level_2) as sum_desc_2,
                             max(t01.cust_name_en_level_3) as sum_desc_3,
                             case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                  else max(t03.mkt_sgmnt_desc) end as sum_desc_4,
                             case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                       case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                            else max(t03.mkt_sgmnt_desc) end
                                  else max(t03.supply_sgmnt_desc) end as sum_desc_5,
                             case when max(t03.sap_brand_flag_code) = ''000'' then
                                       case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                 case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                      else max(t03.mkt_sgmnt_desc) end
                                            else max(t03.supply_sgmnt_desc) end
                                  else max(t03.brand_flag_desc) end as sum_desc_6,
                             case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                       case when max(t03.sap_brand_flag_code) = ''000'' then
                                                 case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                           case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                else max(t03.mkt_sgmnt_desc) end
                                                      else max(t03.supply_sgmnt_desc) end
                                            else max(t03.brand_flag_desc) end
                                  else max(t03.brand_sub_flag_desc) end as sum_desc_7,
                             case when max(t03.sap_prdct_pack_size_code) = ''000'' then
                                       case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                                 case when max(t03.sap_brand_flag_code) = ''000'' then
                                                           case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                                     case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                          else max(t03.mkt_sgmnt_desc) end
                                                                else max(t03.supply_sgmnt_desc) end
                                                      else max(t03.brand_flag_desc) end
                                            else max(t03.brand_sub_flag_desc) end
                                  else max(t03.prdct_pack_size_desc) end as sum_desc_8,
                             null as sum_desc_9,
                             null as sum_desc_10,
                             null as sum_desc_11,
                             null as sum_desc_12,
                             null as sum_desc_13,
                             null as sum_desc_14,
                             null as sum_desc_15,
                             max(t01.cust_name_en_level_1) as sum_sort_1,
                             max(t01.cust_name_en_level_2) as sum_sort_2,
                             max(t01.cust_name_en_level_3) as sum_sort_3,
                             case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                  else max(t03.mkt_sgmnt_desc) end as sum_sort_4,
                             case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                       case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                            else max(t03.mkt_sgmnt_desc) end
                                  else max(t03.supply_sgmnt_desc) end as sum_sort_5,
                             case when max(t03.sap_brand_flag_code) = ''000'' then
                                       case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                 case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                      else max(t03.mkt_sgmnt_desc) end
                                            else max(t03.supply_sgmnt_desc) end
                                  else max(t03.brand_flag_desc) end as sum_sort_6,
                             case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                       case when max(t03.sap_brand_flag_code) = ''000'' then
                                                 case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                           case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                else max(t03.mkt_sgmnt_desc) end
                                                      else max(t03.supply_sgmnt_desc) end
                                            else max(t03.brand_flag_desc) end
                                  else max(t03.brand_sub_flag_desc) end as sum_sort_7,
                             case when max(t03.sap_prdct_pack_size_code) = ''000'' then
                                       case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                                 case when max(t03.sap_brand_flag_code) = ''000'' then
                                                           case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                                     case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                          else max(t03.mkt_sgmnt_desc) end
                                                                else max(t03.supply_sgmnt_desc) end
                                                      else max(t03.brand_flag_desc) end
                                            else max(t03.brand_sub_flag_desc) end
                                  else max(t03.prdct_pack_size_desc) end as sum_sort_8,
                             null as sum_sort_9,
                             null as sum_sort_10,
                             null as sum_sort_11,
                             null as sum_sort_12,
                             null as sum_sort_13,
                             null as sum_sort_14,
                             null as sum_sort_15,
                             max(''('' || t03.sap_material_code || '') '' || t03.material_desc_en) as det_desc,
                             max(t03.material_desc_en || t03.sap_material_code) as det_sort,';
         var_grp_literal := 't01.sap_cust_code_level_1,
                             t01.sap_cust_code_level_2,
                             t01.sap_cust_code_level_3,
                             t03.sap_mkt_sgmnt_code,
                             t03.sap_supply_sgmnt_code,
                             t03.sap_brand_flag_code,
                             t03.sap_brand_sub_flag_code,
                             t03.sap_prdct_pack_size_code,
                             t03.sap_material_code';
         var_srt_literal := 'sum_sort_1 asc,
                             sum_sort_2 asc,
                             sum_sort_3 asc,
                             sum_sort_4 asc,
                             sum_sort_5 asc,
                             sum_sort_6 asc,
                             sum_sort_7 asc,
                             sum_sort_8 asc,
                             det_sort asc';
      elsif var_level = 4 then
         var_sum_str := 4;
         var_sum_end := 9;
         tblSummary(8).adjust := true;
         tblSummary(9).adjust := true;
         var_lvl_literal := 'Area';
         var_col_literal := 'max(''CHANNEL : '' || t01.cust_name_en_level_1) as sum_desc_1,
                             max(''REGION : '' || t01.cust_name_en_level_2) as sum_desc_2,
                             max(''DISTRICT : '' || t01.cust_name_en_level_3) as sum_desc_3,
                             max(t01.cust_name_en_level_4) as sum_desc_4,
                             case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                  else max(t03.mkt_sgmnt_desc) end  as sum_desc_5,
                             case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                       case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                            else max(t03.mkt_sgmnt_desc) end
                                  else max(t03.supply_sgmnt_desc) end as sum_desc_6,
                             case when max(t03.sap_brand_flag_code) = ''000'' then
                                       case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                 case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                      else max(t03.mkt_sgmnt_desc) end
                                            else max(t03.supply_sgmnt_desc) end
                                  else max(t03.brand_flag_desc) end as sum_desc_7,
                             case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                       case when max(t03.sap_brand_flag_code) = ''000'' then
                                                 case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                           case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                else max(t03.mkt_sgmnt_desc) end
                                                      else max(t03.supply_sgmnt_desc) end
                                            else max(t03.brand_flag_desc) end
                                  else max(t03.brand_sub_flag_desc) end as sum_desc_8,
                             case when max(t03.sap_prdct_pack_size_code) = ''000'' then
                                       case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                                 case when max(t03.sap_brand_flag_code) = ''000'' then
                                                           case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                                     case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                          else max(t03.mkt_sgmnt_desc) end
                                                                else max(t03.supply_sgmnt_desc) end
                                                      else max(t03.brand_flag_desc) end
                                            else max(t03.brand_sub_flag_desc) end
                                  else max(t03.prdct_pack_size_desc) end as sum_desc_9,
                             null as sum_desc_10,
                             null as sum_desc_11,
                             null as sum_desc_12,
                             null as sum_desc_13,
                             null as sum_desc_14,
                             null as sum_desc_15,
                             max(t01.cust_name_en_level_1) as sum_sort_1,
                             max(t01.cust_name_en_level_2) as sum_sort_2,
                             max(t01.cust_name_en_level_3) as sum_sort_3,
                             max(t01.cust_name_en_level_4) as sum_sort_4,
                             case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                  else max(t03.mkt_sgmnt_desc) end as sum_sort_5,
                             case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                       case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                            else max(t03.mkt_sgmnt_desc) end
                                  else max(t03.supply_sgmnt_desc) end as sum_sort_6,
                             case when max(t03.sap_brand_flag_code) = ''000'' then
                                       case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                 case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                      else max(t03.mkt_sgmnt_desc) end
                                            else max(t03.supply_sgmnt_desc) end
                                  else max(t03.brand_flag_desc) end as sum_sort_7,
                             case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                       case when max(t03.sap_brand_flag_code) = ''000'' then
                                                 case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                           case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                else max(t03.mkt_sgmnt_desc) end
                                                      else max(t03.supply_sgmnt_desc) end
                                            else max(t03.brand_flag_desc) end
                                  else max(t03.brand_sub_flag_desc) end as sum_sort_8,
                             case when max(t03.sap_prdct_pack_size_code) = ''000'' then
                                       case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                                 case when max(t03.sap_brand_flag_code) = ''000'' then
                                                           case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                                     case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                          else max(t03.mkt_sgmnt_desc) end
                                                                else max(t03.supply_sgmnt_desc) end
                                                      else max(t03.brand_flag_desc) end
                                            else max(t03.brand_sub_flag_desc) end
                                  else max(t03.prdct_pack_size_desc) end as sum_sort_9,
                             null as sum_sort_10,
                             null as sum_sort_11,
                             null as sum_sort_12,
                             null as sum_sort_13,
                             null as sum_sort_14,
                             null as sum_sort_15,
                             max(''('' || t03.sap_material_code || '') '' || t03.material_desc_en) as det_desc,
                             max(t03.material_desc_en || t03.sap_material_code) as det_sort,';
         var_grp_literal := 't01.sap_cust_code_level_1,
                             t01.sap_cust_code_level_2,
                             t01.sap_cust_code_level_3,
                             t01.sap_cust_code_level_4,
                             t03.sap_mkt_sgmnt_code,
                             t03.sap_supply_sgmnt_code,
                             t03.sap_brand_flag_code,
                             t03.sap_brand_sub_flag_code,
                             t03.sap_prdct_pack_size_code,
                             t03.sap_material_code';
         var_srt_literal := 'sum_sort_1 asc,
                             sum_sort_2 asc,
                             sum_sort_3 asc,
                             sum_sort_4 asc,
                             sum_sort_5 asc,
                             sum_sort_6 asc,
                             sum_sort_7 asc,
                             sum_sort_8 asc,
                             sum_sort_9 asc,
                             det_sort asc';
      elsif var_level = 5 then
         var_sum_str := 5;
         var_sum_end := 10;
         tblSummary(9).adjust := true;
         tblSummary(10).adjust := true;
         var_lvl_literal := 'Salesman';
         var_col_literal := 'max(''CHANNEL : '' || t01.cust_name_en_level_1) as sum_desc_1,
                             max(''REGION : '' || t01.cust_name_en_level_2) as sum_desc_2,
                             max(''DISTRICT : '' || t01.cust_name_en_level_3) as sum_desc_3,
                             max(''AREA : '' || t01.cust_name_en_level_4) as sum_desc_4,
                             max(t01.cust_name_en_level_5) as sum_desc_5,
                             case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                  else max(t03.mkt_sgmnt_desc) end as sum_desc_6,
                             case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                       case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                            else max(t03.mkt_sgmnt_desc) end
                                  else max(t03.supply_sgmnt_desc) end as sum_desc_7,
                             case when max(t03.sap_brand_flag_code) = ''000'' then
                                       case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                 case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                      else max(t03.mkt_sgmnt_desc) end
                                            else max(t03.supply_sgmnt_desc) end
                                  else max(t03.brand_flag_desc) end as sum_desc_8,
                             case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                       case when max(t03.sap_brand_flag_code) = ''000'' then
                                                 case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                           case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                else max(t03.mkt_sgmnt_desc) end
                                                      else max(t03.supply_sgmnt_desc) end
                                            else max(t03.brand_flag_desc) end
                                  else max(t03.brand_sub_flag_desc) end as sum_desc_9,
                             case when max(t03.sap_prdct_pack_size_code) = ''000'' then
                                       case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                                 case when max(t03.sap_brand_flag_code) = ''000'' then
                                                           case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                                     case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                          else max(t03.mkt_sgmnt_desc) end
                                                                else max(t03.supply_sgmnt_desc) end
                                                      else max(t03.brand_flag_desc) end
                                            else max(t03.brand_sub_flag_desc) end
                                  else max(t03.prdct_pack_size_desc) end as sum_desc_10,
                             null as sum_desc_11,
                             null as sum_desc_12,
                             null as sum_desc_13,
                             null as sum_desc_14,
                             null as sum_desc_15,
                             max(t01.cust_name_en_level_1) as sum_sort_1,
                             max(t01.cust_name_en_level_2) as sum_sort_2,
                             max(t01.cust_name_en_level_3) as sum_sort_3,
                             max(t01.cust_name_en_level_4) as sum_sort_4,
                             max(t01.cust_name_en_level_5) as sum_sort_5,
                             case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                  else max(t03.mkt_sgmnt_desc) end as sum_sort_6,
                             case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                       case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                            else max(t03.mkt_sgmnt_desc) end
                                  else max(t03.supply_sgmnt_desc) end as sum_sort_7,
                             case when max(t03.sap_brand_flag_code) = ''000'' then
                                       case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                 case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                      else max(t03.mkt_sgmnt_desc) end
                                            else max(t03.supply_sgmnt_desc) end
                                  else max(t03.brand_flag_desc) end as sum_sort_8,
                             case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                       case when max(t03.sap_brand_flag_code) = ''000'' then
                                                 case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                           case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                else max(t03.mkt_sgmnt_desc) end
                                                      else max(t03.supply_sgmnt_desc) end
                                            else max(t03.brand_flag_desc) end
                                  else max(t03.brand_sub_flag_desc) end as sum_sort_9,
                             case when max(t03.sap_prdct_pack_size_code) = ''000'' then
                                       case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                                 case when max(t03.sap_brand_flag_code) = ''000'' then
                                                           case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                                     case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                          else max(t03.mkt_sgmnt_desc) end
                                                                else max(t03.supply_sgmnt_desc) end
                                                      else max(t03.brand_flag_desc) end
                                            else max(t03.brand_sub_flag_desc) end
                                  else max(t03.prdct_pack_size_desc) end as sum_sort_10,
                             null as sum_sort_11,
                             null as sum_sort_12,
                             null as sum_sort_13,
                             null as sum_sort_14,
                             null as sum_sort_15,
                             max(''('' || t03.sap_material_code || '') '' || t03.material_desc_en) as det_desc,
                             max(t03.material_desc_en || t03.sap_material_code) as det_sort,';
         var_grp_literal := 't01.sap_cust_code_level_1,
                             t01.sap_cust_code_level_2,
                             t01.sap_cust_code_level_3,
                             t01.sap_cust_code_level_4,
                             t01.sap_cust_code_level_5,
                             t03.sap_mkt_sgmnt_code,
                             t03.sap_supply_sgmnt_code,
                             t03.sap_brand_flag_code,
                             t03.sap_brand_sub_flag_code,
                             t03.sap_prdct_pack_size_code,
                             t03.sap_material_code';
         var_srt_literal := 'sum_sort_1 asc,
                             sum_sort_2 asc,
                             sum_sort_3 asc,
                             sum_sort_4 asc,
                             sum_sort_5 asc,
                             sum_sort_6 asc,
                             sum_sort_7 asc,
                             sum_sort_8 asc,
                             sum_sort_9 asc,
                             sum_sort_10 asc,
                             det_sort asc';
      elsif var_level = 6 then
         var_sum_str := 1;
         var_sum_end := 5;
         tblSummary(4).adjust := true;
         tblSummary(5).adjust := true;
         var_lvl_literal := 'Packsize';
         var_col_literal := 'case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                  else max(t03.mkt_sgmnt_desc) end as sum_desc_1,
                             case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                       case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                            else max(t03.mkt_sgmnt_desc) end
                                  else max(t03.supply_sgmnt_desc) end as sum_desc_2,
                             case when max(t03.sap_brand_flag_code) = ''000'' then
                                       case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                 case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                      else max(t03.mkt_sgmnt_desc) end
                                            else max(t03.supply_sgmnt_desc) end
                                  else max(t03.brand_flag_desc) end as sum_desc_3,
                             case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                       case when max(t03.sap_brand_flag_code) = ''000'' then
                                                 case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                           case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                else max(t03.mkt_sgmnt_desc) end
                                                      else max(t03.supply_sgmnt_desc) end
                                            else max(t03.brand_flag_desc) end
                                  else max(t03.brand_sub_flag_desc) end as sum_desc_4,
                             case when max(t03.sap_prdct_pack_size_code) = ''000'' then
                                       case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                                 case when max(t03.sap_brand_flag_code) = ''000'' then
                                                           case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                                     case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                          else max(t03.mkt_sgmnt_desc) end
                                                                else max(t03.supply_sgmnt_desc) end
                                                      else max(t03.brand_flag_desc) end
                                            else max(t03.brand_sub_flag_desc) end
                                  else max(t03.prdct_pack_size_desc) end as sum_desc_5,
                             null as sum_desc_6,
                             null as sum_desc_7,
                             null as sum_desc_8,
                             null as sum_desc_9,
                             null as sum_desc_10,
                             null as sum_desc_11,
                             null as sum_desc_12,
                             null as sum_desc_13,
                             null as sum_desc_14,
                             null as sum_desc_15,
                             case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                  else max(t03.mkt_sgmnt_desc) end as sum_sort_1,
                             case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                       case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                            else max(t03.mkt_sgmnt_desc) end
                                  else max(t03.supply_sgmnt_desc) end as sum_sort_2,
                             case when max(t03.sap_brand_flag_code) = ''000'' then
                                       case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                 case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                      else max(t03.mkt_sgmnt_desc) end
                                            else max(t03.supply_sgmnt_desc) end
                                  else max(t03.brand_flag_desc) end as sum_sort_3,
                             case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                       case when max(t03.sap_brand_flag_code) = ''000'' then
                                                 case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                           case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                else max(t03.mkt_sgmnt_desc) end
                                                      else max(t03.supply_sgmnt_desc) end
                                            else max(t03.brand_flag_desc) end
                                  else max(t03.brand_sub_flag_desc) end as sum_sort_4,
                             case when max(t03.sap_prdct_pack_size_code) = ''000'' then
                                       case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                                 case when max(t03.sap_brand_flag_code) = ''000'' then
                                                           case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                                     case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                          else max(t03.mkt_sgmnt_desc) end
                                                                else max(t03.supply_sgmnt_desc) end
                                                      else max(t03.brand_flag_desc) end
                                            else max(t03.brand_sub_flag_desc) end
                                  else max(t03.prdct_pack_size_desc) end as sum_sort_5,
                             null as sum_sort_6,
                             null as sum_sort_7,
                             null as sum_sort_8,
                             null as sum_sort_9,
                             null as sum_sort_10,
                             null as sum_sort_11,
                             null as sum_sort_12,
                             null as sum_sort_13,
                             null as sum_sort_14,
                             null as sum_sort_15,
                             max(t01.cust_name_en_level_5) as det_desc,
                             max(t01.cust_name_en_level_5) as det_sort,';
         var_grp_literal := 't03.sap_mkt_sgmnt_code,
                             t03.sap_supply_sgmnt_code,
                             t03.sap_brand_flag_code,
                             t03.sap_brand_sub_flag_code,
                             t03.sap_prdct_pack_size_code,
                             t01.sap_cust_code_level_5';
         var_srt_literal := 'sum_sort_1 asc,
                             sum_sort_2 asc,
                             sum_sort_3 asc,
                             sum_sort_4 asc,
                             sum_sort_5 asc,
                             det_sort asc';
      elsif var_level = 7 then
         var_sum_str := 1;
         var_sum_end := 6;
         tblSummary(4).adjust := true;
         tblSummary(5).adjust := true;
         var_lvl_literal := 'Material';
         var_col_literal := 'case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                  else max(t03.mkt_sgmnt_desc) end as sum_desc_1,
                             case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                       case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                            else max(t03.mkt_sgmnt_desc) end
                                  else max(t03.supply_sgmnt_desc) end as sum_desc_2,
                             case when max(t03.sap_brand_flag_code) = ''000'' then
                                       case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                 case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                      else max(t03.mkt_sgmnt_desc) end
                                            else max(t03.supply_sgmnt_desc) end
                                  else max(t03.brand_flag_desc) end as sum_desc_3,
                             case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                       case when max(t03.sap_brand_flag_code) = ''000'' then
                                                 case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                           case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                else max(t03.mkt_sgmnt_desc) end
                                                      else max(t03.supply_sgmnt_desc) end
                                            else max(t03.brand_flag_desc) end
                                  else max(t03.brand_sub_flag_desc) end as sum_desc_4,
                             case when max(t03.sap_prdct_pack_size_code) = ''000'' then
                                       case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                                 case when max(t03.sap_brand_flag_code) = ''000'' then
                                                           case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                                     case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                          else max(t03.mkt_sgmnt_desc) end
                                                                else max(t03.supply_sgmnt_desc) end
                                                      else max(t03.brand_flag_desc) end
                                            else max(t03.brand_sub_flag_desc) end
                                  else max(t03.prdct_pack_size_desc) end as sum_desc_5,
                             max(''('' || t03.sap_material_code || '') '' || t03.material_desc_en) as sum_desc_6,
                             null as sum_desc_7,
                             null as sum_desc_8,
                             null as sum_desc_9,
                             null as sum_desc_10,
                             null as sum_desc_11,
                             null as sum_desc_12,
                             null as sum_desc_13,
                             null as sum_desc_14,
                             null as sum_desc_15,
                             case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                  else max(t03.mkt_sgmnt_desc) end as sum_sort_1,
                             case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                       case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                            else max(t03.mkt_sgmnt_desc) end
                                  else max(t03.supply_sgmnt_desc) end as sum_sort_2,
                             case when max(t03.sap_brand_flag_code) = ''000'' then
                                       case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                 case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                      else max(t03.mkt_sgmnt_desc) end
                                            else max(t03.supply_sgmnt_desc) end
                                  else max(t03.brand_flag_desc) end as sum_sort_3,
                             case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                       case when max(t03.sap_brand_flag_code) = ''000'' then
                                                 case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                           case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                else max(t03.mkt_sgmnt_desc) end
                                                      else max(t03.supply_sgmnt_desc) end
                                            else max(t03.brand_flag_desc) end
                                  else max(t03.brand_sub_flag_desc) end as sum_sort_4,
                             case when max(t03.sap_prdct_pack_size_code) = ''000'' then
                                       case when max(t03.sap_brand_sub_flag_code) = ''000'' then
                                                 case when max(t03.sap_brand_flag_code) = ''000'' then
                                                           case when max(t03.sap_supply_sgmnt_code) = ''000'' then
                                                                     case when max(t03.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                          else max(t03.mkt_sgmnt_desc) end
                                                                else max(t03.supply_sgmnt_desc) end
                                                      else max(t03.brand_flag_desc) end
                                            else max(t03.brand_sub_flag_desc) end
                                  else max(t03.prdct_pack_size_desc) end as sum_sort_5,
                             max(t03.material_desc_en || t03.sap_material_code) as sum_sort_6,
                             null as sum_sort_7,
                             null as sum_sort_8,
                             null as sum_sort_9,
                             null as sum_sort_10,
                             null as sum_sort_11,
                             null as sum_sort_12,
                             null as sum_sort_13,
                             null as sum_sort_14,
                             null as sum_sort_15,
                             max(t01.cust_name_en_level_5) as det_desc,
                             max(t01.cust_name_en_level_5) as det_sort,';
         var_grp_literal := 't03.sap_mkt_sgmnt_code,
                             t03.sap_supply_sgmnt_code,
                             t03.sap_brand_flag_code,
                             t03.sap_brand_sub_flag_code,
                             t03.sap_prdct_pack_size_code,
                             t03.sap_material_code,
                             t01.sap_cust_code_level_5';
         var_srt_literal := 'sum_sort_1 asc,
                             sum_sort_2 asc,
                             sum_sort_3 asc,
                             sum_sort_4 asc,
                             sum_sort_5 asc,
                             sum_sort_6 asc,
                             det_sort asc';
      end if;
      if var_for_type = 'PRD_BR' or var_for_type = 'MTH_BR' then
         var_for_literal := 'sum(t02.cur_br_qty) as cur_for_qty,
                             sum(t02.cur_br_bps) as cur_for_bps,
                             sum(t02.ytd_br_qty) as ytd_for_qty,
                             sum(t02.ytd_br_bps) as ytd_for_bps,
                             sum(t02.ytg_br_qty) as ytg_for_qty,
                             sum(t02.ytg_br_bps) as ytg_for_bps';
      else
         var_for_literal := 'sum(t02.cur_le_qty) as cur_for_qty,
                             sum(t02.cur_le_bps) as cur_for_bps,
                             sum(t02.ytd_le_qty) as ytd_for_qty,
                             sum(t02.ytd_le_bps) as ytd_for_bps,
                             sum(t02.ytg_le_qty) as ytg_for_qty,
                             sum(t02.ytg_le_bps) as ytg_for_bps';
      end if;
      if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
         var_tab_literal := 'pld_sal_format0401';
      else
         var_tab_literal := 'pld_sal_format0402';
      end if;

      /*-*/
      /* Initialise the detail query */
      /*-*/
      var_dynamic_sql := 'select ' || var_col_literal || '
                                 sum(t02.cur_billed_qty) as cur_billed_qty,
                                 sum(t02.cur_billed_bps) as cur_billed_bps,
                                 sum(t02.ytd_billed_qty) as ytd_billed_qty,
                                 sum(t02.ytd_billed_bps) as ytd_billed_bps,
                                 sum(t02.ytd_op_qty) as ytd_op_qty,
                                 sum(t02.ytd_op_bps) as ytd_op_bps,
                                 sum(t02.ytg_op_qty) as ytg_op_qty,
                                 sum(t02.ytg_op_bps) as ytg_op_bps,
                                 ' || var_for_literal || '
                            from sales_force_geo_hier t01,
                                 ' || var_tab_literal || ' t02,
                                 material_dim t03
                           where t01.sap_cust_code_level_1 = :A
                             and t01.sap_hier_cust_code = t02.sap_hier_cust_code
                             and t01.sap_sales_org_code = t02.sap_sales_org_code
                             and t01.sap_distbn_chnl_code = t02.sap_distbn_chnl_code
                             and t01.sap_division_code = t02.sap_division_code
                             and t02.sap_material_code = t03.sap_material_code
                        group by  ' || var_grp_literal || '
                        order by ' || var_srt_literal;

      /*-*/
      /* New sheet when required */
      /*-*/
      xlxml_object.AddSheet(var_lvl_literal);

      /*-*/
      /* Report heading line 1 */
      /*-*/
      var_wrk_string := 'Sales Force Reporting - ' || var_lvl_literal || ' - Quantity and Base Price Value (Yen Millions)';
      xlxml_object.SetRange('A1:A1', 'A1:S1', xlxml_object.GetHeadingType(1), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 2 */
      /*-*/
      var_wrk_string := var_extract_status || ' ' || var_sales_status;
      xlxml_object.SetRange('A2:A2', 'A2:S2', xlxml_object.TYPE_HEADING_SM, -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 3 */
      /*-*/
      var_wrk_string := 'Company: ' || var_company_desc;
      if var_for_type = 'PRD_BR' then
         var_wrk_string := var_wrk_string || ' (Period - BR Forecast)';
      elsif var_for_type = 'PRD_LE' then
         var_wrk_string := var_wrk_string || ' (Period - LE Forecast)';
      elsif var_for_type = 'MTH_BR' then
         var_wrk_string := var_wrk_string || ' (Month - BR Forecast)';
      elsif var_for_type = 'MTH_LE' then
         var_wrk_string := var_wrk_string || ' (Month - LE Forecast)';
      end if;
      xlxml_object.SetRange('A3:A3', 'A3:S3', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 4 */
      /*-*/
      if var_for_type = 'PRD_BR' then
         var_wrk_string := 'Current Period: ' || substr(to_char(var_current_YYYYPP,'FM000000'),1,4) || '/' || substr(to_char(var_current_YYYYPP,'FM000000'),5,6) || ' Completed period actuals only';
      elsif var_for_type = 'PRD_LE' then
         var_wrk_string := 'Current Period: ' || substr(to_char(var_current_YYYYPP,'FM000000'),1,4) || '/' || substr(to_char(var_current_YYYYPP,'FM000000'),5,6) || ' Completed period actuals only';
      elsif var_for_type = 'MTH_BR' then
         var_wrk_string := 'Current Month: ' || substr(to_char(var_current_YYYYMM,'FM000000'),1,4) || '/' || substr(to_char(var_current_YYYYMM,'FM000000'),5,6) || ' Completed month actuals only';
      elsif var_for_type = 'MTH_LE' then
         var_wrk_string := 'Current Month: ' || substr(to_char(var_current_YYYYMM,'FM000000'),1,4) || '/' || substr(to_char(var_current_YYYYMM,'FM000000'),5,6) || ' Completed month actuals only';
      end if;
      xlxml_object.SetRange('A4:A4', 'A4:S4', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 5 */
      /*-*/
      xlxml_object.SetRange('A5:A5', null, xlxml_object.GetHeadingType(7), -1, 0, false, null);
      xlxml_object.SetRange('B5:B5', 'B5:G5', xlxml_object.GetHeadingType(7), -2, 0, false, 'Current');
      xlxml_object.SetRange('H5:H5', 'H5:K5', xlxml_object.GetHeadingType(7), -2, 0, false, 'YTD');
      xlxml_object.SetRange('L5:L5', 'L5:O5', xlxml_object.GetHeadingType(7), -2, 0, false, 'YTG');
      xlxml_object.SetRange('P5:P5', 'P5:S5', xlxml_object.GetHeadingType(7), -2, 0, false, 'YEE');

      /*-*/
      /* Report heading line 6 */
      /*-*/
      xlxml_object.SetRange('A6:A6', null, xlxml_object.GetHeadingType(7), -1, 0, false, 'Report Hierarchy');
      xlxml_object.SetRange('B6:B6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'For/QTY');
      xlxml_object.SetRange('C6:C6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Act/QTY');
      xlxml_object.SetRange('D6:D6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'QTY %');
      xlxml_object.SetRange('E6:E6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'For/BPS');
      xlxml_object.SetRange('F6:F6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Act/BPS');
      xlxml_object.SetRange('G6:G6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'BPS %');
      xlxml_object.SetRange('H6:H6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'QTY');
      xlxml_object.SetRange('I6:I6', null, xlxml_object.GetHeadingType(7), -2, 0, false, '% Plan');
      xlxml_object.SetRange('J6:J6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'BPS');
      xlxml_object.SetRange('K6:K6', null, xlxml_object.GetHeadingType(7), -2, 0, false, '% Plan');
      xlxml_object.SetRange('L6:L6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'QTY');
      xlxml_object.SetRange('M6:M6', null, xlxml_object.GetHeadingType(7), -2, 0, false, '% Plan');
      xlxml_object.SetRange('N6:N6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'BPS');
      xlxml_object.SetRange('O6:O6', null, xlxml_object.GetHeadingType(7), -2, 0, false, '% Plan');
      xlxml_object.SetRange('P6:P6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'QTY');
      xlxml_object.SetRange('Q6:Q6', null, xlxml_object.GetHeadingType(7), -2, 0, false, '% Plan');
      xlxml_object.SetRange('R6:R6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'BPS');
      xlxml_object.SetRange('S6:S6', null, xlxml_object.GetHeadingType(7), -2, 0, false, '% Plan');

      /*-*/
      /* Report heading borders */
      /*-*/
      xlxml_object.SetHeadingBorder('B5:G5', 'ALL');
      xlxml_object.SetHeadingBorder('H5:K5', 'ALL');
      xlxml_object.SetHeadingBorder('L5:O5', 'ALL');
      xlxml_object.SetHeadingBorder('P5:S5', 'ALL');
      xlxml_object.SetHeadingBorder('A6:A6', 'TLR');
      xlxml_object.SetHeadingBorder('B6:B6', 'TLR');
      xlxml_object.SetHeadingBorder('C6:C6', 'TLR');
      xlxml_object.SetHeadingBorder('D6:D6', 'TLR');
      xlxml_object.SetHeadingBorder('E6:E6', 'TLR');
      xlxml_object.SetHeadingBorder('F6:F6', 'TLR');
      xlxml_object.SetHeadingBorder('G6:G6', 'TLR');
      xlxml_object.SetHeadingBorder('H6:H6', 'TLR');
      xlxml_object.SetHeadingBorder('I6:I6', 'TLR');
      xlxml_object.SetHeadingBorder('J6:J6', 'TLR');
      xlxml_object.SetHeadingBorder('K6:K6', 'TLR');
      xlxml_object.SetHeadingBorder('L6:L6', 'TLR');
      xlxml_object.SetHeadingBorder('M6:M6', 'TLR');
      xlxml_object.SetHeadingBorder('N6:N6', 'TLR');
      xlxml_object.SetHeadingBorder('O6:O6', 'TLR');
      xlxml_object.SetHeadingBorder('P6:P6', 'TLR');
      xlxml_object.SetHeadingBorder('Q6:Q6', 'TLR');
      xlxml_object.SetHeadingBorder('R6:R6', 'TLR');
      xlxml_object.SetHeadingBorder('S6:S6', 'TLR');

      /*-*/
      /* Initialise the row count */
      /*-*/
      var_row_count := 6;

      /*-*/
      /* Retrieve the detail rows */
      /*-*/
      open pld_sal_format04_c01 for var_dynamic_sql using var_control_code;
      loop
         fetch pld_sal_format04_c01 into var_sum_desc_1,
                                         var_sum_desc_2,
                                         var_sum_desc_3,
                                         var_sum_desc_4,
                                         var_sum_desc_5,
                                         var_sum_desc_6,
                                         var_sum_desc_7,
                                         var_sum_desc_8,
                                         var_sum_desc_9,
                                         var_sum_desc_10,
                                         var_sum_desc_11,
                                         var_sum_desc_12,
                                         var_sum_desc_13,
                                         var_sum_desc_14,
                                         var_sum_desc_15,
                                         var_sum_sort_1,
                                         var_sum_sort_2,
                                         var_sum_sort_3,
                                         var_sum_sort_4,
                                         var_sum_sort_5,
                                         var_sum_sort_6,
                                         var_sum_sort_7,
                                         var_sum_sort_8,
                                         var_sum_sort_9,
                                         var_sum_sort_10,
                                         var_sum_sort_11,
                                         var_sum_sort_12,
                                         var_sum_sort_13,
                                         var_sum_sort_14,
                                         var_sum_sort_15,
                                         var_det_desc,
                                         var_det_sort,
                                         var_cur_billed_qty,
                                         var_cur_billed_bps,
                                         var_ytd_billed_qty,
                                         var_ytd_billed_bps,
                                         var_ytd_op_qty,
                                         var_ytd_op_bps,
                                         var_ytg_op_qty,
                                         var_ytg_op_bps,
                                         var_cur_for_qty,
                                         var_cur_for_bps,
                                         var_ytd_for_qty,
                                         var_ytd_for_bps,
                                         var_ytg_for_qty,
                                         var_ytg_for_bps;
         if pld_sal_format04_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Set the summary sort values */
         /*-*/
         tblSummary(1).current_value := var_sum_sort_1;
         tblSummary(2).current_value := var_sum_sort_2;
         tblSummary(3).current_value := var_sum_sort_3;
         tblSummary(4).current_value := var_sum_sort_4;
         tblSummary(5).current_value := var_sum_sort_5;
         tblSummary(6).current_value := var_sum_sort_6;
         tblSummary(7).current_value := var_sum_sort_7;
         tblSummary(8).current_value := var_sum_sort_8;
         tblSummary(9).current_value := var_sum_sort_9;
         tblSummary(10).current_value := var_sum_sort_10;
         tblSummary(11).current_value := var_sum_sort_11;
         tblSummary(12).current_value := var_sum_sort_12;
         tblSummary(13).current_value := var_sum_sort_13;
         tblSummary(14).current_value := var_sum_sort_14;
         tblSummary(15).current_value := var_sum_sort_15;

         /*-*/
         /* Set the summary description values */
         /*-*/
         tblSummary(1).description := var_sum_desc_1;
         tblSummary(2).description := var_sum_desc_2;
         tblSummary(3).description := var_sum_desc_3;
         tblSummary(4).description := var_sum_desc_4;
         tblSummary(5).description := var_sum_desc_5;
         tblSummary(6).description := var_sum_desc_6;
         tblSummary(7).description := var_sum_desc_7;
         tblSummary(8).description := var_sum_desc_8;
         tblSummary(9).description := var_sum_desc_9;
         tblSummary(10).description := var_sum_desc_10;
         tblSummary(11).description := var_sum_desc_11;
         tblSummary(12).description := var_sum_desc_12;
         tblSummary(13).description := var_sum_desc_13;
         tblSummary(14).description := var_sum_desc_14;
         tblSummary(15).description := var_sum_desc_15;

         /*-*/
         /* Adjust the descriptions as required */
         /*-*/
         for idx in 2..var_sum_end loop
            if tblSummary(idx).adjust = true then
               if tblSummary(idx).description != tblSummary(idx-1).description then
                  tblSummary(idx).description := tblSummary(idx-1).description || ' ' || tblSummary(idx).description;
               end if;
            end if;
         end loop;

         /*-*/
         /* Check for summary level changes and process when required */
         /*-*/
         checkSummary;
         if var_sum_level <> 0 then
            if var_details = true then
               doTotal;
            end if;
            doHeading;
         end if;

         /*-*/
         /* Accumulate the summary level data */
         /*-*/
         for idx in 1..var_sum_end loop
            tblSummary(idx).wrk_cur_billed_qty := tblSummary(idx).wrk_cur_billed_qty + var_cur_billed_qty;
            tblSummary(idx).wrk_cur_billed_bps := tblSummary(idx).wrk_cur_billed_bps + var_cur_billed_bps;
            tblSummary(idx).wrk_ytd_billed_qty := tblSummary(idx).wrk_ytd_billed_qty + var_ytd_billed_qty;
            tblSummary(idx).wrk_ytd_billed_bps := tblSummary(idx).wrk_ytd_billed_bps + var_ytd_billed_bps;
            tblSummary(idx).wrk_ytd_op_qty := tblSummary(idx).wrk_ytd_op_qty + var_ytd_op_qty;
            tblSummary(idx).wrk_ytd_op_bps := tblSummary(idx).wrk_ytd_op_bps + var_ytd_op_bps;
            tblSummary(idx).wrk_ytg_op_qty := tblSummary(idx).wrk_ytg_op_qty + var_ytg_op_qty;
            tblSummary(idx).wrk_ytg_op_bps := tblSummary(idx).wrk_ytg_op_bps + var_ytg_op_bps;
            tblSummary(idx).wrk_cur_for_qty := tblSummary(idx).wrk_cur_for_qty + var_cur_for_qty;
            tblSummary(idx).wrk_cur_for_bps := tblSummary(idx).wrk_cur_for_bps + var_cur_for_bps;
            tblSummary(idx).wrk_ytd_for_qty := tblSummary(idx).wrk_ytd_for_qty + var_ytd_for_qty;
            tblSummary(idx).wrk_ytd_for_bps := tblSummary(idx).wrk_ytd_for_bps + var_ytd_for_bps;
            tblSummary(idx).wrk_ytg_for_qty := tblSummary(idx).wrk_ytg_for_qty + var_ytg_for_qty;
            tblSummary(idx).wrk_ytg_for_bps := tblSummary(idx).wrk_ytg_for_bps + var_ytg_for_bps;
         end loop;

         /*-*/
         /* Set the control information */
         /*-*/
         var_details := true;
         var_row_count := var_row_count + 1;

         /*-*/
         /* Detail description */
         /*-*/
         xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                               null, xlxml_object.TYPE_DETAIL, -1, var_sum_end, false, var_det_desc);

         /*-*/
         /* Current forecast/actual quantity */
         /*-*/
         var_wrk_array := to_char(var_cur_for_qty,'FM9999999999999999999990');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_cur_billed_qty,'FM9999999999999999999990');
         if var_cur_billed_qty <> 0 and var_cur_for_qty <> 0 then
            var_wrk_string := to_char(round((var_cur_billed_qty / var_cur_for_qty) * 100, 2),'FM9999990.00');
         elsif var_cur_billed_qty = 0 and var_cur_for_qty = 0 then
            var_wrk_string := 'NS/NF';
         elsif var_cur_billed_qty = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NF';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Current forecast/actual BPS */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_cur_for_bps/1000000,'FM9999999999999990.000000');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_cur_billed_bps/1000000,'FM9999999999999990.000000');
         if var_cur_billed_bps <> 0 and var_cur_for_bps <> 0 then
            var_wrk_string := to_char(round((var_cur_billed_bps / var_cur_for_bps) * 100, 2),'FM9999990.00');
         elsif var_cur_billed_bps = 0 and var_cur_for_bps = 0 then
            var_wrk_string := 'NS/NF';
         elsif var_cur_billed_bps = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NF';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTD actual quantity */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_ytd_billed_qty,'FM9999999999999999999990');
         if var_ytd_billed_qty <> 0 and var_ytd_op_qty <> 0 then
            var_wrk_string := to_char(round((var_ytd_billed_qty / var_ytd_op_qty) * 100, 2),'FM9999990.00');
         elsif var_ytd_billed_qty = 0 and var_ytd_op_qty = 0 then
            var_wrk_string := 'NS/NP';
         elsif var_ytd_billed_qty = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTD actual BPS */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_ytd_billed_bps/1000000,'FM9999999999999990.000000');
         if var_ytd_billed_bps <> 0 and var_ytd_op_bps <> 0 then
            var_wrk_string := to_char(round((var_ytd_billed_bps / var_ytd_op_bps) * 100, 2),'FM9999990.00');
         elsif var_ytd_billed_bps = 0 and var_ytd_op_bps = 0 then
            var_wrk_string := 'NS/NP';
         elsif var_ytd_billed_bps = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTG forecast quantity */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_ytg_for_qty,'FM9999999999999999999990');
         if var_ytg_for_qty <> 0 and var_ytg_op_qty <> 0 then
            var_wrk_string := to_char(round((var_ytg_for_qty / var_ytg_op_qty) * 100, 2),'FM9999990.00');
         elsif var_ytg_for_qty = 0 and var_ytg_op_qty = 0 then
            var_wrk_string := 'NF/NP';
         elsif var_ytg_for_qty = 0 then
            var_wrk_string := 'NF';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTG forecast BPS */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_ytg_for_bps/1000000,'FM9999999999999990.000000');
         if var_ytg_for_bps <> 0 and var_ytg_op_bps <> 0 then
            var_wrk_string := to_char(round((var_ytg_for_bps / var_ytg_op_bps) * 100, 2),'FM9999990.00');
         elsif var_ytg_for_bps = 0 and var_ytg_op_bps = 0 then
            var_wrk_string := 'NF/NP';
         elsif var_ytg_for_bps = 0 then
            var_wrk_string := 'NF';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YEE actual/forecast quantity */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_ytd_billed_qty + var_ytg_for_qty,'FM9999999999999999999990');
         if (var_ytd_billed_qty + var_ytg_for_qty) <> 0 and (var_ytd_op_qty + var_ytg_op_qty) <> 0 then
            var_wrk_string := to_char(round(((var_ytd_billed_qty + var_ytg_for_qty) / (var_ytd_op_qty + var_ytg_op_qty)) * 100, 2),'FM9999990.00');
         elsif (var_ytd_billed_qty + var_ytg_for_qty) = 0 and (var_ytd_op_qty + var_ytg_op_qty) = 0 then
            var_wrk_string := 'NE/NP';
         elsif (var_ytd_billed_qty + var_ytg_for_qty) = 0 then
            var_wrk_string := 'NE';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YEE actual/forecast BPS */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_ytd_billed_bps/1000000 + var_ytg_for_bps/1000000,'FM9999999999999990.000000');
         if (var_ytd_billed_bps + var_ytg_for_bps) <> 0 and (var_ytd_op_bps + var_ytg_op_bps) <> 0 then
            var_wrk_string := to_char(round(((var_ytd_billed_bps + var_ytg_for_bps) / (var_ytd_op_bps + var_ytg_op_bps)) * 100, 2),'FM9999990.00');
         elsif (var_ytd_billed_bps + var_ytg_for_bps) = 0 and (var_ytd_op_bps + var_ytg_op_bps) = 0 then
            var_wrk_string := 'NE/NP';
         elsif (var_ytd_billed_bps + var_ytg_for_bps) = 0 then
            var_wrk_string := 'NE';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Create the detail row */
         /*-*/
         xlxml_object.SetRangeArray('B' || to_char(var_row_count,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990'),
                                    'B' || to_char(var_row_count,'FM999999990') || ':S' || to_char(var_row_count,'FM999999990'),
                                    xlxml_object.TYPE_DETAIL, -9, var_wrk_array);

      end loop;
      close pld_sal_format04_c01;

      /*-*/
      /* Process last total */
      /*-*/
      if var_details = true then
         var_sum_level := 1;
         doTotal;
         doFormat;
         doBorder;
         xlxml_object.SetFreezeCell('B7');
      end if;

      /*-*/
      /* Report when no details found */
      /*-*/
      if var_details = false then
         xlxml_object.SetRange('A7:A7', 'A7:S7', xlxml_object.TYPE_DETAIL, -2, 0, false, 'NO DETAILS EXIST');
         xlxml_object.SetRangeBorder('A7:S7');
      end if;

      /*-*/
      /* Report print settings */
      /*-*/
      xlxml_object.SetPrintData('$1:$6', '$A:$A', 2, 1, 0);
      if var_print_xml is not null then
         xlxml_object.SetPrintDataXML(var_print_xml);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doDetail;

   /****************************************************/
   /* This procedure performs the clear report routine */
   /****************************************************/
   procedure clearReport is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the control variables */
      /*-*/
      var_sum_level := 0;
      var_row_count := 0;
      var_details := false;

      /*-*/
      /* Clear the summary array */
      /*-*/
      for idx in 1..SUMMARY_MAX loop
         tblSummary(idx).current_value := null;
         tblSummary(idx).saved_value := '**********';
         tblSummary(idx).saved_row := 0;
         tblSummary(idx).description := null;
         tblSummary(idx).adjust := false;
         tblSummary(idx).wrk_cur_billed_qty := 0;
         tblSummary(idx).wrk_cur_billed_bps := 0;
         tblSummary(idx).wrk_ytd_billed_qty := 0;
         tblSummary(idx).wrk_ytd_billed_bps := 0;
         tblSummary(idx).wrk_ytd_op_qty := 0;
         tblSummary(idx).wrk_ytd_op_bps := 0;
         tblSummary(idx).wrk_ytg_op_qty := 0;
         tblSummary(idx).wrk_ytg_op_bps := 0;
         tblSummary(idx).wrk_cur_for_qty := 0;
         tblSummary(idx).wrk_cur_for_bps := 0;
         tblSummary(idx).wrk_ytd_for_qty := 0;
         tblSummary(idx).wrk_ytd_for_bps := 0;
         tblSummary(idx).wrk_ytg_for_qty := 0;
         tblSummary(idx).wrk_ytg_for_bps := 0;
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clearReport;

   /*****************************************************/
   /* This procedure performs the check summary routine */
   /*****************************************************/
   procedure checkSummary is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Find the highest summary level change */
      /*-*/
      var_sum_level := 0;
      for idx in reverse 1..var_sum_end loop
         if tblSummary(idx).current_value <> tblSummary(idx).saved_value then
            var_sum_level := idx;
         end if;
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end checkSummary;

   /*********************************************/
   /* This procedure performs the total routine */
   /*********************************************/
   procedure doTotal is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_wrk_string varchar2(2048 char);
      var_wrk_array varchar2(4000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the summary level in reverse order from the bottom to the changed level */
      /*-*/
      for idx in reverse var_sum_level..var_sum_end loop

         /*-*/
         /* Current forecast/actual quantity */
         /*-*/
         var_wrk_array := '"=subtotal(9,B' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,C' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':C' || to_char(var_row_count,'FM999999990') || ')"';
         if tblSummary(idx).wrk_cur_billed_qty <> 0 and tblSummary(idx).wrk_cur_for_qty <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).wrk_cur_billed_qty / tblSummary(idx).wrk_cur_for_qty) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).wrk_cur_billed_qty = 0 and tblSummary(idx).wrk_cur_for_qty = 0 then
            var_wrk_string := 'NS/NF';
         elsif tblSummary(idx).wrk_cur_billed_qty = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NF';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Current forecast/actual BPS */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,E' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':E' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,F' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':F' || to_char(var_row_count,'FM999999990') || ')"';
         if tblSummary(idx).wrk_cur_billed_bps <> 0 and tblSummary(idx).wrk_cur_for_bps <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).wrk_cur_billed_bps / tblSummary(idx).wrk_cur_for_bps) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).wrk_cur_billed_bps = 0 and tblSummary(idx).wrk_cur_for_bps = 0 then
            var_wrk_string := 'NS/NF';
         elsif tblSummary(idx).wrk_cur_billed_bps = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NF';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTD actual quantity */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,H' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':H' || to_char(var_row_count,'FM999999990') || ')"';
         if tblSummary(idx).wrk_ytd_billed_qty <> 0 and tblSummary(idx).wrk_ytd_op_qty <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).wrk_ytd_billed_qty / tblSummary(idx).wrk_ytd_op_qty) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).wrk_ytd_billed_qty = 0 and tblSummary(idx).wrk_ytd_op_qty = 0 then
            var_wrk_string := 'NS/NP';
         elsif tblSummary(idx).wrk_ytd_billed_qty = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTD actual BPS */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,J' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':J' || to_char(var_row_count,'FM999999990') || ')"';
         if tblSummary(idx).wrk_ytd_billed_bps <> 0 and tblSummary(idx).wrk_ytd_op_bps <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).wrk_ytd_billed_bps / tblSummary(idx).wrk_ytd_op_bps) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).wrk_ytd_billed_bps = 0 and tblSummary(idx).wrk_ytd_op_bps = 0 then
            var_wrk_string := 'NS/NP';
         elsif tblSummary(idx).wrk_ytd_billed_bps = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTG forecast quantity */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,L' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':L' || to_char(var_row_count,'FM999999990') || ')"';
         if tblSummary(idx).wrk_ytg_for_qty <> 0 and tblSummary(idx).wrk_ytg_op_qty <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).wrk_ytg_for_qty / tblSummary(idx).wrk_ytg_op_qty) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).wrk_ytg_for_qty = 0 and tblSummary(idx).wrk_ytg_op_qty = 0 then
            var_wrk_string := 'NF/NP';
         elsif tblSummary(idx).wrk_ytg_for_qty = 0 then
            var_wrk_string := 'NF';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTG forecast BPS */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,N' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':N' || to_char(var_row_count,'FM999999990') || ')"';
         if tblSummary(idx).wrk_ytg_for_bps <> 0 and tblSummary(idx).wrk_ytg_op_bps <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).wrk_ytg_for_bps / tblSummary(idx).wrk_ytg_op_bps) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).wrk_ytg_for_bps = 0 and tblSummary(idx).wrk_ytg_op_bps = 0 then
            var_wrk_string := 'NF/NP';
         elsif tblSummary(idx).wrk_ytg_for_bps = 0 then
            var_wrk_string := 'NF';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YEE actual/forecast quantity */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,P' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':P' || to_char(var_row_count,'FM999999990') || ')"';
         if (tblSummary(idx).wrk_ytd_billed_qty + tblSummary(idx).wrk_ytg_for_qty) <> 0 and (tblSummary(idx).wrk_ytd_op_qty + tblSummary(idx).wrk_ytg_op_qty) <> 0 then
            var_wrk_string := to_char(round(((tblSummary(idx).wrk_ytd_billed_qty + tblSummary(idx).wrk_ytg_for_qty) / (tblSummary(idx).wrk_ytd_op_qty + tblSummary(idx).wrk_ytg_op_qty)) * 100, 2),'FM9999990.00');
         elsif (tblSummary(idx).wrk_ytd_billed_qty + tblSummary(idx).wrk_ytg_for_qty) = 0 and (tblSummary(idx).wrk_ytd_op_qty + tblSummary(idx).wrk_ytg_op_qty) = 0 then
            var_wrk_string := 'NE/NP';
         elsif (tblSummary(idx).wrk_ytd_billed_qty + tblSummary(idx).wrk_ytg_for_qty) = 0 then
            var_wrk_string := 'NE';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YEE actual/forecast BPS */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,R' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':R' || to_char(var_row_count,'FM999999990') || ')"';
         if (tblSummary(idx).wrk_ytd_billed_bps + tblSummary(idx).wrk_ytg_for_bps) <> 0 and (tblSummary(idx).wrk_ytd_op_bps + tblSummary(idx).wrk_ytg_op_bps) <> 0 then
            var_wrk_string := to_char(round(((tblSummary(idx).wrk_ytd_billed_bps + tblSummary(idx).wrk_ytg_for_bps) / (tblSummary(idx).wrk_ytd_op_bps + tblSummary(idx).wrk_ytg_op_bps)) * 100, 2),'FM9999990.00');
         elsif (tblSummary(idx).wrk_ytd_billed_bps + tblSummary(idx).wrk_ytg_for_bps) = 0 and (tblSummary(idx).wrk_ytd_op_bps + tblSummary(idx).wrk_ytg_op_bps) = 0 then
            var_wrk_string := 'NE/NP';
         elsif (tblSummary(idx).wrk_ytd_billed_bps + tblSummary(idx).wrk_ytg_for_bps) = 0 then
            var_wrk_string := 'NE';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Create the summary row based on position */
         /*-*/
         if idx < var_sum_str then
            xlxml_object.SetRangeArray('B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':B' || to_char(tblSummary(idx).saved_row,'FM999999990'),
                                       'B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':S' || to_char(tblSummary(idx).saved_row,'FM999999990'),
                                       xlxml_object.TYPE_HEADING, -9, var_wrk_array);
         else
            xlxml_object.SetRangeArray('B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':B' || to_char(tblSummary(idx).saved_row,'FM999999990'),
                                       'B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':S' || to_char(tblSummary(idx).saved_row,'FM999999990'),
                                       xlxml_object.GetSummaryType(idx-(var_sum_str-1)), -9, var_wrk_array);
            xlxml_object.SetRowGroup(to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':' || to_char(var_row_count,'FM999999990'));
         end if;

      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doTotal;

   /***********************************************/
   /* This procedure performs the heading routine */
   /***********************************************/
   procedure doHeading is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_wrk_indent number(2,0);
      var_wrk_bullet boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the summary level in forward order from the changed level to the bottom */
      /*-*/
      for idx in var_sum_level..var_sum_end loop

         /*-*/
         /* Create the new summary heading row */
         /*-*/
         var_row_count := var_row_count + 1;
         if idx = 1 then
            var_wrk_indent := 0;
            var_wrk_bullet := false;
         else
            var_wrk_indent := idx - 1;
            var_wrk_bullet := true;
         end if;
         if idx < var_sum_str then
            xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                                  null, xlxml_object.TYPE_HEADING, -1, var_wrk_indent, var_wrk_bullet, tblSummary(idx).description);
         else
            xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                                  null, xlxml_object.GetSummaryType(idx-(var_sum_str-1)), -1, var_wrk_indent, var_wrk_bullet, tblSummary(idx).description);
         end if;

         /*-*/
         /* Reset the summary control values */
         /*-*/
         tblSummary(idx).saved_value := tblSummary(idx).current_value;
         tblSummary(idx).saved_row := var_row_count;
         tblSummary(idx).wrk_cur_billed_qty := 0;
         tblSummary(idx).wrk_cur_billed_bps := 0;
         tblSummary(idx).wrk_ytd_billed_qty := 0;
         tblSummary(idx).wrk_ytd_billed_bps := 0;
         tblSummary(idx).wrk_ytd_op_qty := 0;
         tblSummary(idx).wrk_ytd_op_bps := 0;
         tblSummary(idx).wrk_ytg_op_qty := 0;
         tblSummary(idx).wrk_ytg_op_bps := 0;
         tblSummary(idx).wrk_cur_for_qty := 0;
         tblSummary(idx).wrk_cur_for_bps := 0;
         tblSummary(idx).wrk_ytd_for_qty := 0;
         tblSummary(idx).wrk_ytd_for_bps := 0;
         tblSummary(idx).wrk_ytg_for_qty := 0;
         tblSummary(idx).wrk_ytg_for_bps := 0;

      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doHeading;

   /**********************************************/
   /* This procedure performs the format routine */
   /**********************************************/
   procedure doFormat is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Report column formats */
      /*-*/
      xlxml_object.SetRangeFormat('B7:B' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('C7:C' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('D7:D' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('E7:E' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('F7:F' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('G7:G' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('H7:H' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('I7:I' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('J7:J' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('K7:K' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('L7:L' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('M7:M' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('N7:N' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('O7:O' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('P7:P' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('Q7:Q' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('R7:R' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('S7:S' || to_char(var_row_count,'FM999999990'), 2);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doFormat;

   /**********************************************/
   /* This procedure performs the border routine */
   /**********************************************/
   procedure doBorder is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Report column borders */
      /*-*/
      xlxml_object.SetRangeBorder('A7:A' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('B7:B' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('C7:C' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('D7:D' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('E7:E' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('F7:F' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('G7:G' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('H7:H' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('I7:I' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('J7:J' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('K7:K' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('L7:L' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('M7:M' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('N7:N' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('O7:O' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('P7:P' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('Q7:Q' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('R7:R' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('S7:S' || to_char(var_row_count,'FM999999990'));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doBorder;

end mfjpln_sal_format04_excel01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mfjpln_sal_format04_excel01 for pld_rep_app.mfjpln_sal_format04_excel01;
grant execute on mfjpln_sal_format04_excel01 to public;
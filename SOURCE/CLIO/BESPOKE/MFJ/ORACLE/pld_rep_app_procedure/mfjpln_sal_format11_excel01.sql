/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_sal_format11_excel01                        */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : October 2005                                       */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_sal_format11_excel01 as

/**DESCRIPTION**
 Standard Sales Report - SAP billing date aggregations.

 **PARAMETERS**
 par_sap_company_code = SAP company code (mandatory)
 par_sap_bus_sgmnt_code = SAP business segment code (mandatory)
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
 2. A different sort is used for each business segment (hard-coded)

 **LEGEND**
 NSQ = No sales quantity
 NSV = No sales value
 NPQ = No plan quantity
 NPV = No plan value
 NFQ = No forecast quantity
 NFV = No forecast value
 NLQ = No last year quantity
 NLV = No last year value

**/
   
   /*-*/
   /* Public declarations */
   /*-*/
   function main(par_sap_company_code in varchar2,
                 par_sap_bus_sgmnt_code in varchar2,
                 par_for_type in varchar2,
                 par_print_xml in varchar2) return varchar2;

end mfjpln_sal_format11_excel01;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_sal_format11_excel01 as

   /*-*/
   /* Private global declarations */
   /*-*/
   procedure doDetail;
   procedure clearReport;
   procedure checkSummary;
   procedure doTotal;
   procedure doHeading;
   procedure doFormat;
   procedure doBorder;

   /*-*/
   /* Private global variables */
   /*-*/
   SUMMARY_MAX number(2,0) := 7;
   var_sum_level number(2,0);
   var_row_count number(15,0);
   var_details boolean;
   var_sap_company_code varchar2(6 char);
   var_sap_bus_sgmnt_code varchar2(4 char);
   var_for_type varchar2(6 char);
   type rcdSummary is record(current_value varchar2(256 char),
                             saved_value varchar2(256 char),
                             saved_row number(9,0),
                             description varchar2(128 char),
                             wrk_billed_qty number(22,0),
                             wrk_billed_gsv number(22,0),
                             wrk_ly_qty number(22,0),
                             wrk_ly_gsv number(22,0),
                             wrk_op_qty number(22,0),
                             wrk_op_gsv number(22,0),
                             wrk_fc_qty number(22,0),
                             wrk_fc_gsv number(22,0));
   type typSummary is table of rcdSummary index by binary_integer;
   tblSummary typSummary;

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_sap_company_code in varchar2,
                 par_sap_bus_sgmnt_code in varchar2,
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
      var_company_desc varchar2(60 char);
      var_bus_sgmnt_desc varchar2(30 char);
      var_found boolean;
      var_wrk_string varchar2(2048 char);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor company_c01 is 
         select company.company_desc
         from company
         where company.sap_company_code = var_sap_company_code;

      cursor bus_sgmnt_c01 is 
         select bus_sgmnt.bus_sgmnt_desc
         from bus_sgmnt
         where bus_sgmnt.sap_bus_sgmnt_code = var_sap_bus_sgmnt_code;

      cursor pld_sal_format1100_c01 is 
         select pld_sal_format1100.extract_date,
                pld_sal_format1100.logical_date,
                pld_sal_format1100.current_YYYYPP,
                pld_sal_format1100.current_YYYYMM,
                pld_sal_format1100.extract_status,
                pld_sal_format1100.sales_date,
                pld_sal_format1100.sales_status,
                pld_sal_format1100.prd_asofdays,
                pld_sal_format1100.prd_percent,
                pld_sal_format1100.mth_asofdays,
                pld_sal_format1100.mth_percent
         from pld_sal_format1100;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the report information */
      /*-*/
      clearReport;

      /*-*/
      /* Set the parameter values */
      /*-*/
      var_sap_company_code := par_sap_company_code;
      var_sap_bus_sgmnt_code := par_sap_bus_sgmnt_code;
      var_for_type := par_for_type;

      /*-*/
      /* Retrieve the format control */
      /*-*/
      var_found := true;
      open pld_sal_format1100_c01;
      fetch pld_sal_format1100_c01 into var_extract_date,
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
      if pld_sal_format1100_c01%notfound then
         var_found := false;
      end if;
      close pld_sal_format1100_c01;
      if var_found = false then
         raise_application_error(-20000, 'Format control row PLD_SAL_FORMAT1100 not found');
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
      /* Retrieve the business segment */
      /*-*/
      var_found := true;
      open bus_sgmnt_c01;
      fetch bus_sgmnt_c01 into var_bus_sgmnt_desc;
      if bus_sgmnt_c01%notfound then
         var_found := false;
      end if;
      close bus_sgmnt_c01;
      if var_found = false then
         raise_application_error(-20000, 'Business segment ' || var_sap_bus_sgmnt_code || ' not found');
      end if;

      /*-*/
      /* Report start */
      /*-*/
      xlxml_object.BeginReport;

      /*-*/
      /* Report heading line 1 */
      /*-*/
      if var_for_type = 'PRD_BR' then
         var_wrk_string := 'Standard Sales Report - Period - BR Forecast (Yen Millions) - Delivery Date';
      elsif var_for_type = 'PRD_LE' then
         var_wrk_string := 'Standard Sales Report - Period - LE Forecast (Yen Millions) - Delivery Date';
      elsif var_for_type = 'MTH_BR' then
         var_wrk_string := 'Standard Sales Report - Month - BR Forecast (Yen Millions) - Delivery Date';
      elsif var_for_type = 'MTH_LE' then
         var_wrk_string := 'Standard Sales Report - Month - LE Forecast (Yen Millions) - Delivery Date';
      end if;
      xlxml_object.SetRange('A1:A1', 'A1:Q1', xlxml_object.GetHeadingType(1), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 2 */
      /*-*/
      var_wrk_string := var_extract_status || ' ' || var_sales_status;
      xlxml_object.SetRange('A2:A2', 'A2:Q2', xlxml_object.TYPE_HEADING_SM, -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 3 */
      /*-*/
      var_wrk_string := 'Company: ' || var_company_desc || ' Business Segment: ' || var_bus_sgmnt_desc;
      xlxml_object.SetRange('A3:A3', 'A3:Q3', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 4 */
      /*-*/
      if var_for_type = 'PRD_BR' then
         var_wrk_string := var_prd_asofdays;
      elsif var_for_type = 'PRD_LE' then
         var_wrk_string := var_prd_asofdays;
      elsif var_for_type = 'MTH_BR' then
         var_wrk_string := var_mth_asofdays;
      elsif var_for_type = 'MTH_LE' then
         var_wrk_string := var_mth_asofdays;
      end if;
      xlxml_object.SetRange('A4:A4', 'A4:Q4', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 5 */
      /*-*/
      xlxml_object.SetRange('A5:A5', null, xlxml_object.GetHeadingType(7), -1, 0, false, null);
      xlxml_object.SetRange('B5:B5', 'B5:C5', xlxml_object.GetHeadingType(7), -2, 0, false, 'Daily');
      if var_for_type = 'PRD_BR' then
         var_wrk_string := 'PTD';
      elsif var_for_type = 'PRD_LE' then
         var_wrk_string := 'PTD';
      elsif var_for_type = 'MTH_BR' then
         var_wrk_string := 'MTD';
      elsif var_for_type = 'MTH_LE' then
         var_wrk_string := 'MTD';
      end if;
      xlxml_object.SetRange('D5:D5', 'D5:E5', xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
      xlxml_object.SetRange('F5:F5', 'F5:I5', xlxml_object.GetHeadingType(7), -2, 0, false, 'Plan');
      if var_for_type = 'PRD_BR' then
         var_wrk_string := 'BR';
      elsif var_for_type = 'PRD_LE' then
         var_wrk_string := 'LE';
      elsif var_for_type = 'MTH_BR' then
         var_wrk_string := 'BR';
      elsif var_for_type = 'MTH_LE' then
         var_wrk_string := 'LE';
      end if;
      xlxml_object.SetRange('J5:J5', 'J5:M5', xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
      if var_for_type = 'PRD_BR' then
         var_wrk_string := 'SPLY';
      elsif var_for_type = 'PRD_LE' then
         var_wrk_string := 'SPLY';
      elsif var_for_type = 'MTH_BR' then
         var_wrk_string := 'SMLY';
      elsif var_for_type = 'MTH_LE' then
         var_wrk_string := 'SMLY';
      end if;
      xlxml_object.SetRange('N5:N5', 'N5:Q5', xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 6 */
      /*-*/
      xlxml_object.SetRange('A6:A6', null, xlxml_object.GetHeadingType(7), -1, 0, false, 'Material Hierarchy');
      if var_for_type = 'PRD_BR' then
         var_wrk_string := 'QTY' || chr(9) ||
                           'GSV' || chr(9) ||
                           'QTY' || chr(9) ||
                           'GSV' || chr(9) ||
                           'QTY' || chr(9) ||
                           'QTY % Plan' || chr(9) ||
                           'GSV' || chr(9) ||
                           'GSV % Plan' || chr(9) ||
                           'QTY' || chr(9) ||
                           'QTY % BR' || chr(9) ||
                           'GSV' || chr(9) ||
                           'GSV % BR' || chr(9) ||
                           'QTY' || chr(9) ||
                           'QTY % SPLY' || chr(9) ||
                           'GSV' || chr(9) ||
                           'GSV % SPLY';
      elsif var_for_type = 'PRD_LE' then
         var_wrk_string := 'QTY' || chr(9) ||
                           'GSV' || chr(9) ||
                           'QTY' || chr(9) ||
                           'GSV' || chr(9) ||
                           'QTY' || chr(9) ||
                           'QTY % Plan' || chr(9) ||
                           'GSV' || chr(9) ||
                           'GSV % Plan' || chr(9) ||
                           'QTY' || chr(9) ||
                           'QTY % LE' || chr(9) ||
                           'GSV' || chr(9) ||
                           'GSV % LE' || chr(9) ||
                           'QTY' || chr(9) ||
                           'QTY % SPLY' || chr(9) ||
                           'GSV' || chr(9) ||
                           'GSV % SPLY';
      elsif var_for_type = 'MTH_BR' then
         var_wrk_string := 'QTY' || chr(9) ||
                           'GSV' || chr(9) ||
                           'QTY' || chr(9) ||
                           'GSV' || chr(9) ||
                           'QTY' || chr(9) ||
                           'QTY % Plan' || chr(9) ||
                           'GSV' || chr(9) ||
                           'GSV % Plan' || chr(9) ||
                           'QTY' || chr(9) ||
                           'QTY % BR' || chr(9) ||
                           'GSV' || chr(9) ||
                           'GSV % BR' || chr(9) ||
                           'QTY' || chr(9) ||
                           'QTY % SMLY' || chr(9) ||
                           'GSV' || chr(9) ||
                           'GSV % SMLY';
      elsif var_for_type = 'MTH_LE' then
         var_wrk_string := 'QTY' || chr(9) ||
                           'GSV' || chr(9) ||
                           'QTY' || chr(9) ||
                           'GSV' || chr(9) ||
                           'QTY' || chr(9) ||
                           'QTY % Plan' || chr(9) ||
                           'GSV' || chr(9) ||
                           'GSV % Plan' || chr(9) ||
                           'QTY' || chr(9) ||
                           'QTY % LE' || chr(9) ||
                           'GSV' || chr(9) ||
                           'GSV % LE' || chr(9) ||
                           'QTY' || chr(9) ||
                           'QTY % SMLY' || chr(9) ||
                           'GSV' || chr(9) ||
                           'GSV % SMLY';
      end if;
      xlxml_object.SetRangeArray('B6:B6', 'B6:Q6', xlxml_object.GetHeadingType(7), -2, var_wrk_string);

      /*-*/
      /* Report heading borders */
      /*-*/
      xlxml_object.SetHeadingBorder('B5:C5', 'ALL');
      xlxml_object.SetHeadingBorder('D5:E5', 'ALL');
      xlxml_object.SetHeadingBorder('F5:I5', 'ALL');
      xlxml_object.SetHeadingBorder('J5:M5', 'ALL');
      xlxml_object.SetHeadingBorder('N5:Q5', 'ALL');
      xlxml_object.SetHeadingBorder('A5:A6', 'TLR');
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

      /*-*/
      /* Initialise the row count */
      /*-*/
      var_row_count := 6;

      /*-*/
      /* Process the report detail */
      /*-*/
      doDetail;

      /*-*/
      /* Process the summary level totals when details exist */
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
         xlxml_object.SetRange('A7:A7', 'A7:Q7', xlxml_object.TYPE_DETAIL, -2, 0, false, 'NO DETAILS EXIST');
         xlxml_object.SetRangeBorder('A7:Q7');
      end if;

      /*-*/
      /* Report print settings */
      /*-*/
      xlxml_object.SetPrintData('$1:$6', '$A:$A', 2, 1, 0);
      if par_print_xml is not null then
         xlxml_object.SetPrintDataXML(par_print_xml);
      end if;

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
   procedure doDetail is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_srt_literal varchar2(2048 char);
      var_typ_literal varchar2(256 char);
      var_for_literal varchar2(256 char);
      var_lst_literal varchar2(256 char);
      var_day_billed_qty number(22,0);
      var_day_billed_gsv number(22,0);
      var_wrk_billed_qty number(22,0);
      var_wrk_billed_gsv number(22,0);
      var_wrk_ly_qty number(22,0);
      var_wrk_ly_gsv number(22,0);
      var_wrk_op_qty number(22,0);
      var_wrk_op_gsv number(22,0);
      var_wrk_fc_qty number(22,0);
      var_wrk_fc_gsv number(22,0);
      var_bus_sgmnt_desc varchar2(128 char);
      var_mkt_sgmnt_desc varchar2(128 char);
      var_supply_sgmnt_desc varchar2(128 char);
      var_brand_flag_desc varchar2(128 char);
      var_brand_sub_flag_desc varchar2(128 char);
      var_prdct_pack_size_desc varchar2(128 char);
      var_sap_rep_item_code varchar2(18 char);
      var_rep_item_desc_en varchar2(40 char);
      var_rep_desc varchar2(60 char);
      var_sap_material_code varchar2(18 char);
      var_material_desc_en varchar2(40 char);
      var_material_desc_ja varchar2(40 char);
      var_sort_desc varchar2(60 char);
      var_wrk_string varchar2(2048 char);
      var_wrk_array varchar2(4000 char);
      var_dynamic_sql varchar2(32767 char);
      type typCursor is ref cursor;
      pld_sal_format11_c01 typCursor;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the sort literal based on business segment code */
      /* 01 = Snackfood */
      /* 02 = Food */
      /* 05 = Petcare */
      /*-*/
      if var_sap_bus_sgmnt_code = '01' then
         var_srt_literal := 'mkt_sgmnt_text asc,
                             brand_flag_text asc,
                             supply_sgmnt_text asc,
                             brand_sub_flag_text asc,
                             prdct_pack_size_text asc,
                             rep_desc asc,
                             sort_desc asc';
      elsif var_sap_bus_sgmnt_code = '02' then
         var_srt_literal := 'brand_flag_text asc,
                             mkt_sgmnt_text asc,
                             supply_sgmnt_text asc,
                             brand_sub_flag_text asc,
                             prdct_pack_size_text asc,
                             rep_desc asc,
                             sort_desc asc';
      elsif var_sap_bus_sgmnt_code = '05' then
         var_srt_literal := 'mkt_sgmnt_text asc,
                             supply_sgmnt_text asc,
                             brand_flag_text asc,
                             brand_sub_flag_text asc,
                             prdct_pack_size_text asc,
                             rep_desc asc,
                             sort_desc asc';
      else
         var_srt_literal := 'mkt_sgmnt_text asc,
                             supply_sgmnt_text asc,
                             brand_flag_text asc,
                             brand_sub_flag_text asc,
                             prdct_pack_size_text asc,
                             rep_desc asc,
                             sort_desc asc';
      end if;

      /*-*/
      /* Initialise the type and forecast literals */
      /*-*/
      if var_for_type = 'PRD_BR' then
         var_typ_literal := 'prd';
         var_for_literal := 'br';
         var_lst_literal := 'sply';
      elsif var_for_type = 'PRD_LE' then
         var_typ_literal := 'prd';
         var_for_literal := 'le';
         var_lst_literal := 'sply';
      elsif var_for_type = 'MTH_BR' then
         var_typ_literal := 'mth';
         var_for_literal := 'br';
         var_lst_literal := 'smly';
      elsif var_for_type = 'MTH_LE' then
         var_typ_literal := 'mth';
         var_for_literal := 'le';
         var_lst_literal := 'smly';
      end if;

      /*-*/
      /* Initialise the detail query */
      /*-*/
      var_dynamic_sql := 'select t01.day_billed_qty,
                                 t01.day_billed_gsv,
                                 t01.' || var_typ_literal || '_billed_qty,
                                 t01.' || var_typ_literal || '_billed_gsv,
                                 t01.' || var_typ_literal || '_' || var_lst_literal || '_qty,
                                 t01.' || var_typ_literal || '_' || var_lst_literal || '_gsv,
                                 t01.' || var_typ_literal || '_op_qty,
                                 t01.' || var_typ_literal || '_op_gsv,
                                 t01.' || var_typ_literal || '_' || var_for_literal || '_qty,
                                 t01.' || var_typ_literal || '_' || var_for_literal || '_gsv,
                                 t02.bus_sgmnt_desc as bus_sgmnt_text,
                                 case when t02.sap_mkt_sgmnt_code = ''00'' then ''NOT APPLICABLE''
                                      else t02.mkt_sgmnt_desc end as mkt_sgmnt_text,
                                 case when t02.sap_supply_sgmnt_code = ''000'' then
                                           case when t02.sap_mkt_sgmnt_code = ''00'' then ''NOT APPLICABLE''
                                                else t02.mkt_sgmnt_desc end 
                                      else t02.supply_sgmnt_desc end as supply_sgmnt_text,
                                 case when t02.sap_brand_flag_code = ''000'' then
                                           case when t02.sap_supply_sgmnt_code = ''000'' then
                                                     case when t02.sap_mkt_sgmnt_code = ''00'' then ''NOT APPLICABLE''
                                                          else t02.mkt_sgmnt_desc end 
                                                else t02.supply_sgmnt_desc end 
                                      else t02.brand_flag_desc end as brand_flag_text,
                                 case when t02.sap_brand_sub_flag_code = ''000'' then
                                           case when t02.sap_brand_flag_code = ''000'' then
                                                     case when t02.sap_supply_sgmnt_code = ''000'' then
                                                               case when t02.sap_mkt_sgmnt_code = ''00'' then ''NOT APPLICABLE''
                                                                    else t02.mkt_sgmnt_desc end 
                                                          else t02.supply_sgmnt_desc end 
                                                else t02.brand_flag_desc end
                                      else t02.brand_sub_flag_desc end as brand_sub_flag_text,
                                 case when t02.sap_prdct_pack_size_code = ''000'' then
                                           case when t02.sap_brand_sub_flag_code = ''000'' then
                                                     case when t02.sap_brand_flag_code = ''000'' then
                                                               case when t02.sap_supply_sgmnt_code = ''000'' then
                                                                         case when t02.sap_mkt_sgmnt_code = ''00'' then ''NOT APPLICABLE''
                                                                              else t02.mkt_sgmnt_desc end 
                                                                    else t02.supply_sgmnt_desc end 
                                                          else t02.brand_flag_desc end
                                                else t02.brand_sub_flag_desc end
                                      else t02.prdct_pack_size_desc end as prdct_pack_size_text,
                                 t02.sap_rep_item_code,
                                 t02.rep_item_desc_en,
                                 nvl(t02.rep_item_desc_en || t02.sap_rep_item_code,''NO REPRESENTATIVE ITEM'') as rep_desc,
                                 t02.sap_material_code,
                                 t02.material_desc_en,
                                 t02.material_desc_ja,
                                 t02.material_desc_en || t02.sap_material_code as sort_desc
                            from pld_sal_format1101 t01, material_dim t02
                           where t01.sap_material_code = t02.sap_material_code(+)
                             and t01.sap_company_code = :A
                             and t02.sap_bus_sgmnt_code = :B
                             and (t01.day_billed_qty <> 0 or
                                  t01.day_billed_gsv <> 0 or
                                  t01.' || var_typ_literal || '_billed_qty <> 0 or
                                  t01.' || var_typ_literal || '_billed_gsv <> 0 or
                                  t01.' || var_typ_literal || '_op_qty <> 0 or
                                  t01.' || var_typ_literal || '_op_gsv <> 0 or
                                  t01.' || var_typ_literal || '_' || var_for_literal || '_qty <> 0 or
                                  t01.' || var_typ_literal || '_' || var_for_literal || '_gsv <> 0 or
                                  t01.' || var_typ_literal || '_' || var_lst_literal || '_qty <> 0 or
                                  t01.' || var_typ_literal || '_' || var_lst_literal || '_gsv <> 0)
                        order by ' || var_srt_literal;

      /*-*/
      /* Retrieve the detail rows */
      /*-*/
      open pld_sal_format11_c01 for var_dynamic_sql using var_sap_company_code, var_sap_bus_sgmnt_code;
      loop
         fetch pld_sal_format11_c01 into var_day_billed_qty,
                                         var_day_billed_gsv,
                                         var_wrk_billed_qty,
                                         var_wrk_billed_gsv,
                                         var_wrk_ly_qty,
                                         var_wrk_ly_gsv,
                                         var_wrk_op_qty,
                                         var_wrk_op_gsv,
                                         var_wrk_fc_qty,
                                         var_wrk_fc_gsv,
                                         var_bus_sgmnt_desc,
                                         var_mkt_sgmnt_desc,
                                         var_supply_sgmnt_desc,
                                         var_brand_flag_desc,
                                         var_brand_sub_flag_desc,
                                         var_prdct_pack_size_desc,
                                         var_sap_rep_item_code,
                                         var_rep_item_desc_en,
                                         var_rep_desc,
                                         var_sap_material_code,
                                         var_material_desc_en,
                                         var_material_desc_ja,
                                         var_sort_desc;
         if pld_sal_format11_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Set the summary level values */
         /*-*/
         if var_sap_bus_sgmnt_code = '01' then
            tblSummary(1).current_value := var_bus_sgmnt_desc;
            tblSummary(2).current_value := var_mkt_sgmnt_desc;
            tblSummary(3).current_value := var_brand_flag_desc;
            tblSummary(4).current_value := var_supply_sgmnt_desc;
            tblSummary(5).current_value := var_brand_sub_flag_desc;
            tblSummary(6).current_value := var_prdct_pack_size_desc;
         elsif var_sap_bus_sgmnt_code = '02' then
            tblSummary(1).current_value := var_bus_sgmnt_desc;
            tblSummary(2).current_value := var_brand_flag_desc;
            tblSummary(3).current_value := var_mkt_sgmnt_desc;
            tblSummary(4).current_value := var_supply_sgmnt_desc;
            tblSummary(5).current_value := var_brand_sub_flag_desc;
            tblSummary(6).current_value := var_prdct_pack_size_desc;
         elsif var_sap_bus_sgmnt_code = '05' then
            tblSummary(1).current_value := var_bus_sgmnt_desc;
            tblSummary(2).current_value := var_mkt_sgmnt_desc;
            tblSummary(3).current_value := var_supply_sgmnt_desc;
            tblSummary(4).current_value := var_brand_flag_desc;
            tblSummary(5).current_value := var_brand_sub_flag_desc;
            tblSummary(6).current_value := var_prdct_pack_size_desc;
         else
            tblSummary(1).current_value := var_bus_sgmnt_desc;
            tblSummary(2).current_value := var_mkt_sgmnt_desc;
            tblSummary(3).current_value := var_supply_sgmnt_desc;
            tblSummary(4).current_value := var_brand_flag_desc;
            tblSummary(5).current_value := var_brand_sub_flag_desc;
            tblSummary(6).current_value := var_prdct_pack_size_desc;
         end if;
         tblSummary(7).current_value := var_rep_desc;

         /*-*/
         /* Adjust the low level descriptions */
         /*-*/
         if var_brand_sub_flag_desc <> var_brand_flag_desc then
            var_brand_sub_flag_desc := var_brand_flag_desc || ' ' || var_brand_sub_flag_desc;
         end if;
         if var_prdct_pack_size_desc <> var_brand_sub_flag_desc then
            var_prdct_pack_size_desc := var_brand_sub_flag_desc || ' ' || var_prdct_pack_size_desc;
         end if;

         /*-*/
         /* Set the summary level descriptions */
         /*-*/
         if var_sap_bus_sgmnt_code = '01' then
            tblSummary(1).description := var_bus_sgmnt_desc;
            tblSummary(2).description := var_mkt_sgmnt_desc;
            tblSummary(3).description := var_brand_flag_desc;
            tblSummary(4).description := var_supply_sgmnt_desc;
            tblSummary(5).description := var_brand_sub_flag_desc;
            tblSummary(6).description := var_prdct_pack_size_desc;
         elsif var_sap_bus_sgmnt_code = '02' then
            tblSummary(1).description := var_bus_sgmnt_desc;
            tblSummary(2).description := var_brand_flag_desc;
            tblSummary(3).description := var_mkt_sgmnt_desc;
            tblSummary(4).description := var_supply_sgmnt_desc;
            tblSummary(5).description := var_brand_sub_flag_desc;
            tblSummary(6).description := var_prdct_pack_size_desc;
         elsif var_sap_bus_sgmnt_code = '05' then
            tblSummary(1).description := var_bus_sgmnt_desc;
            tblSummary(2).description := var_mkt_sgmnt_desc;
            tblSummary(3).description := var_supply_sgmnt_desc;
            tblSummary(4).description := var_brand_flag_desc;
            tblSummary(5).description := var_brand_sub_flag_desc;
            tblSummary(6).description := var_prdct_pack_size_desc;
         else
            tblSummary(1).description := var_bus_sgmnt_desc;
            tblSummary(2).description := var_mkt_sgmnt_desc;
            tblSummary(3).description := var_supply_sgmnt_desc;
            tblSummary(4).description := var_brand_flag_desc;
            tblSummary(5).description := var_brand_sub_flag_desc;
            tblSummary(6).description := var_prdct_pack_size_desc;
         end if;
         if not(var_sap_rep_item_code is null) then
            tblSummary(7).description := '(' || var_sap_rep_item_code || ') ' || var_rep_item_desc_en;
         else
            tblSummary(7).description := var_rep_desc;
         end if;

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
         for idx in 1..SUMMARY_MAX loop
            tblSummary(idx).wrk_billed_qty := tblSummary(idx).wrk_billed_qty + var_wrk_billed_qty;
            tblSummary(idx).wrk_billed_gsv := tblSummary(idx).wrk_billed_gsv + var_wrk_billed_gsv;
            tblSummary(idx).wrk_ly_qty := tblSummary(idx).wrk_ly_qty + var_wrk_ly_qty;
            tblSummary(idx).wrk_ly_gsv := tblSummary(idx).wrk_ly_gsv + var_wrk_ly_gsv;
            tblSummary(idx).wrk_op_qty := tblSummary(idx).wrk_op_qty + var_wrk_op_qty;
            tblSummary(idx).wrk_op_gsv := tblSummary(idx).wrk_op_gsv + var_wrk_op_gsv;
            tblSummary(idx).wrk_fc_qty := tblSummary(idx).wrk_fc_qty + var_wrk_fc_qty;
            tblSummary(idx).wrk_fc_gsv := tblSummary(idx).wrk_fc_gsv + var_wrk_fc_gsv;
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
                               null, xlxml_object.TYPE_DETAIL, -1, SUMMARY_MAX, false, '(' || var_sap_material_code || ') ' || var_material_desc_en);

         /*-*/
         /* Detail daily and PTD/MTD sales */
         /*-*/
         var_wrk_array := to_char(var_day_billed_qty,'FM9999999999999999999990');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_day_billed_gsv/1000000,'FM9999999999999990.000000');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_billed_qty,'FM9999999999999999999990');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_billed_gsv/1000000,'FM9999999999999990.000000');

         /*-*/
         /* Detail plan quantity */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_op_qty,'FM9999999999999999999990');
         if var_wrk_billed_qty <> 0 and var_wrk_op_qty <> 0 then
            var_wrk_string := to_char(round((var_wrk_billed_qty / var_wrk_op_qty) * 100, 2),'FM9999990.00');
         elsif var_wrk_billed_qty = 0 and var_wrk_op_qty = 0 then
            var_wrk_string := 'NSQ/NPQ';
         elsif var_wrk_billed_qty = 0 then
            var_wrk_string := 'NSQ';
         else
            var_wrk_string := 'NPQ';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Detail plan value */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_op_gsv/1000000,'FM9999999999999990.000000');
         if var_wrk_billed_gsv <> 0 and var_wrk_op_gsv <> 0 then
            var_wrk_string := to_char(round((var_wrk_billed_gsv / var_wrk_op_gsv) * 100, 2),'FM9999990.00');
         elsif var_wrk_billed_gsv = 0 and var_wrk_op_gsv = 0 then
            var_wrk_string := 'NSV/NPV';
         elsif var_wrk_billed_gsv = 0 then
            var_wrk_string := 'NSV';
         else
            var_wrk_string := 'NPV';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Detail BR/LE quantity */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_fc_qty,'FM9999999999999999999990');
         if var_wrk_billed_qty <> 0 and var_wrk_fc_qty <> 0 then
            var_wrk_string := to_char(round((var_wrk_billed_qty / var_wrk_fc_qty) * 100, 2),'FM9999990.00');
         elsif var_wrk_billed_qty = 0 and var_wrk_fc_qty = 0 then
            var_wrk_string := 'NSQ/NFQ';
         elsif var_wrk_billed_qty = 0 then
            var_wrk_string := 'NSQ';
         else
            var_wrk_string := 'NFQ';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Detail BR/LE value */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_fc_gsv/1000000,'FM9999999999999990.000000');
         if var_wrk_billed_gsv <> 0 and var_wrk_fc_gsv <> 0 then
            var_wrk_string := to_char(round((var_wrk_billed_gsv / var_wrk_fc_gsv) * 100, 2),'FM9999990.00');
         elsif var_wrk_billed_gsv = 0 and var_wrk_fc_gsv = 0 then
            var_wrk_string := 'NSV/NFV';
         elsif var_wrk_billed_gsv = 0 then
            var_wrk_string := 'NSV';
         else
            var_wrk_string := 'NFV';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Detail SPLY/SMLY quantity */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_ly_qty,'FM9999999999999999999990');
         if var_wrk_billed_qty <> 0 and var_wrk_ly_qty <> 0 then
            var_wrk_string := to_char(round((var_wrk_billed_qty / var_wrk_ly_qty) * 100, 2),'FM9999990.00');
         elsif var_wrk_billed_qty = 0 and var_wrk_ly_qty = 0 then
            var_wrk_string := 'NSQ/NLQ';
         elsif var_wrk_billed_qty = 0 then
            var_wrk_string := 'NSQ';
         else
            var_wrk_string := 'NLQ';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Detail SPLY/SMLY value */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_ly_gsv/1000000,'FM9999999999999990.000000');
         if var_wrk_billed_gsv <> 0 and var_wrk_ly_gsv <> 0 then
            var_wrk_string := to_char(round((var_wrk_billed_gsv / var_wrk_ly_gsv) * 100, 2),'FM9999990.00');
         elsif var_wrk_billed_gsv = 0 and var_wrk_ly_gsv = 0 then
            var_wrk_string := 'NSV/NLV';
         elsif var_wrk_billed_gsv = 0 then
            var_wrk_string := 'NSV';
         else
            var_wrk_string := 'NLV';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Create the detail row */
         /*-*/
         xlxml_object.SetRangeArray('B' || to_char(var_row_count,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990'),
                                    'B' || to_char(var_row_count,'FM999999990') || ':Q' || to_char(var_row_count,'FM999999990'),
                                    xlxml_object.TYPE_DETAIL, -9, var_wrk_array);

      end loop;
      close pld_sal_format11_c01;

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
         tblSummary(idx).wrk_billed_qty := 0;
         tblSummary(idx).wrk_billed_gsv := 0;
         tblSummary(idx).wrk_ly_qty := 0;
         tblSummary(idx).wrk_ly_gsv := 0;
         tblSummary(idx).wrk_op_qty := 0;
         tblSummary(idx).wrk_op_gsv := 0;
         tblSummary(idx).wrk_fc_qty := 0;
         tblSummary(idx).wrk_fc_gsv := 0;
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
      for idx in reverse 1..SUMMARY_MAX loop
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
      for idx in reverse var_sum_level..SUMMARY_MAX loop

         /*-*/
         /* Summary daily and PTD/MTD sales */
         /*-*/
         var_wrk_array := '"=subtotal(9,B' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,C' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':C' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,D' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':D' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,E' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':E' || to_char(var_row_count,'FM999999990') || ')"';

         /*-*/
         /* Summary plan quantity */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,F' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':F' || to_char(var_row_count,'FM999999990') || ')"';
         if tblSummary(idx).wrk_billed_qty <> 0 and tblSummary(idx).wrk_op_qty <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).wrk_billed_qty / tblSummary(idx).wrk_op_qty) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).wrk_billed_qty = 0 and tblSummary(idx).wrk_op_qty = 0 then
            var_wrk_string := 'NSQ/NPQ';
         elsif tblSummary(idx).wrk_billed_qty = 0 then
            var_wrk_string := 'NSQ';
         else
            var_wrk_string := 'NPQ';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Summary plan value */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,H' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':H' || to_char(var_row_count,'FM999999990') || ')"';
         if tblSummary(idx).wrk_billed_gsv <> 0 and tblSummary(idx).wrk_op_gsv <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).wrk_billed_gsv / tblSummary(idx).wrk_op_gsv) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).wrk_billed_gsv = 0 and tblSummary(idx).wrk_op_gsv = 0 then
            var_wrk_string := 'NSV/NPV';
         elsif tblSummary(idx).wrk_billed_gsv = 0 then
            var_wrk_string := 'NSV';
         else
            var_wrk_string := 'NPV';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Summary BR/LE quantity */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,J' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':J' || to_char(var_row_count,'FM999999990') || ')"';
         if tblSummary(idx).wrk_billed_qty <> 0 and tblSummary(idx).wrk_fc_qty <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).wrk_billed_qty / tblSummary(idx).wrk_fc_qty) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).wrk_billed_qty = 0 and tblSummary(idx).wrk_fc_qty = 0 then
            var_wrk_string := 'NSQ/NFQ';
         elsif tblSummary(idx).wrk_billed_qty = 0 then
            var_wrk_string := 'NSQ';
         else
            var_wrk_string := 'NFQ';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Summary BR/LE value */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,L' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':L' || to_char(var_row_count,'FM999999990') || ')"';
         if tblSummary(idx).wrk_billed_gsv <> 0 and tblSummary(idx).wrk_fc_gsv <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).wrk_billed_gsv / tblSummary(idx).wrk_fc_gsv) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).wrk_billed_gsv = 0 and tblSummary(idx).wrk_fc_gsv = 0 then
            var_wrk_string := 'NSV/NFV';
         elsif tblSummary(idx).wrk_billed_gsv = 0 then
            var_wrk_string := 'NSV';
         else
            var_wrk_string := 'NFV';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Detail SPLY/SMLY quantity */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,N' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':N' || to_char(var_row_count,'FM999999990') || ')"';
         if tblSummary(idx).wrk_billed_qty <> 0 and tblSummary(idx).wrk_ly_qty <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).wrk_billed_qty / tblSummary(idx).wrk_ly_qty) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).wrk_billed_qty = 0 and tblSummary(idx).wrk_ly_qty = 0 then
            var_wrk_string := 'NSQ/NLQ';
         elsif tblSummary(idx).wrk_billed_qty = 0 then
            var_wrk_string := 'NSQ';
         else
            var_wrk_string := 'NLQ';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Detail SPLY/SMLY value */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,P' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':P' || to_char(var_row_count,'FM999999990') || ')"';
         if tblSummary(idx).wrk_billed_gsv <> 0 and tblSummary(idx).wrk_ly_gsv <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).wrk_billed_gsv / tblSummary(idx).wrk_ly_gsv) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).wrk_billed_gsv = 0 and tblSummary(idx).wrk_ly_gsv = 0 then
            var_wrk_string := 'NSV/NLV';
         elsif tblSummary(idx).wrk_billed_gsv = 0 then
            var_wrk_string := 'NSV';
         else
            var_wrk_string := 'NLV';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Create the total row */
         /*-*/
         xlxml_object.SetRangeArray('B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':B' || to_char(tblSummary(idx).saved_row,'FM999999990'),
                                    'B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':Q' || to_char(tblSummary(idx).saved_row,'FM999999990'),
                                    xlxml_object.GetSummaryType(idx), -9, var_wrk_array);

         /*-*/
         /* Outline the summary level */
         /*-*/
         xlxml_object.SetRowGroup(to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':' || to_char(var_row_count,'FM999999990'));

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
      for idx in var_sum_level..SUMMARY_MAX loop

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
         xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                               null, xlxml_object.GetSummaryType(idx), -1, var_wrk_indent, var_wrk_bullet, tblSummary(idx).description);

         /*-*/
         /* Set the summary control values */
         /*-*/
         tblSummary(idx).saved_value := tblSummary(idx).current_value;
         tblSummary(idx).saved_row := var_row_count;
         tblSummary(idx).wrk_billed_qty := 0;
         tblSummary(idx).wrk_billed_gsv := 0;
         tblSummary(idx).wrk_ly_qty := 0;
         tblSummary(idx).wrk_ly_gsv := 0;
         tblSummary(idx).wrk_op_qty := 0;
         tblSummary(idx).wrk_op_gsv := 0;
         tblSummary(idx).wrk_fc_qty := 0;
         tblSummary(idx).wrk_fc_gsv := 0;

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
      xlxml_object.SetRangeFormat('C7:C' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('D7:D' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('E7:E' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('F7:F' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('G7:G' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('H7:H' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('I7:I' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('J7:J' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('K7:K' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('L7:L' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('M7:M' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('N7:N' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('O7:O' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('P7:P' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('Q7:Q' || to_char(var_row_count,'FM999999990'), 2);

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

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doBorder;

end mfjpln_sal_format11_excel01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mfjpln_sal_format11_excel01 for pld_rep_app.mfjpln_sal_format11_excel01;
grant execute on mfjpln_sal_format11_excel01 to public;
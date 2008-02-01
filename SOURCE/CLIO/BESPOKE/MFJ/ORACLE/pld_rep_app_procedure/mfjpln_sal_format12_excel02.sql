/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_sal_format12_excel02                        */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : October 2005                                       */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_sal_format12_excel02 as

/**DESCRIPTION**
 Combined Business YEE - SAP billing date aggregations.

 **PARAMETERS**
 par_sap_company_code = SAP company code (mandatory)
 par_for_type = Forecast type (mandatory)
                  PRD_BR = Period BR forecast
                  PRD_LE = Period LE forecast
                  MTH_BR = Month BR forecast
                  MTH_LE = Month LE forecast
 par_val_type = Value type (mandatory)
                  QTY = quantity
                  TON = tonnes
                  BPS = base price sale
                  GSV = gross sale value
 par_print_xml = Print xml data string (optional)
                   Format = SetPrintOverride Orientation='1' FitWidthPages='1' Zoom='0'
                   Orientation = 1(Portrait) 2(Landscape)
                   FitWidthPages = number 0 to 999
                   Zoom = number 0 to 100 (overrides FitWidthPages)

 **NOTES**
 1. NOT APPLICABLE descriptions are replaced based on the SAP codes (hard-coded)
 2. The material is ignored when there are no sales or no forecast

 **LEGEND**
 NS = No sales
 NP = No plan
 NF = No forecast
 NL = No last year

**/
   
   /*-*/
   /* Public declarations */
   /*-*/
   function main(par_sap_company_code in varchar2,
                 par_for_type in varchar2,
                 par_val_type in varchar2,
                 par_print_xml in varchar2) return varchar2;

end mfjpln_sal_format12_excel02;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_sal_format12_excel02 as

   /*-*/
   /* Private global declarations */
   /*-*/
   procedure doDetail(par_sap_bus_sgmnt_code in varchar2);
   procedure clearReport;
   procedure checkSummary;
   procedure doTotal;
   procedure doHeading;
   procedure doFormat;
   procedure doBorder;

   /*-*/
   /* Private global variables */
   /*-*/
   SUMMARY_MAX number(2,0) := 5;
   var_sum_level number(2,0);
   var_row_count number(15,0);
   var_details boolean;
   var_sap_company_code varchar2(6 char);
   var_for_type varchar2(6 char);
   var_val_type varchar2(3 char);
   var_previous_YYYYPP number(6,0);
   var_previous_YYYYMM number(6,0);
   type rcdSummary is record(current_value varchar2(256 char),
                             saved_value varchar2(256 char),
                             saved_row number(9,0),
                             description varchar2(128 char),
                             ytd_ty_val number(22,6),
                             ytd_ly_val number(22,6),
                             ytd_op_val number(22,6),
                             ytd_fc_val number(22,6),
                             ytg_ly_val number(22,6),
                             ytg_op_val number(22,6),
                             ytg_fc_val number(22,6));
   type typSummary is table of rcdSummary index by binary_integer;
   tblSummary typSummary;

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_sap_company_code in varchar2,
                 par_for_type in varchar2,
                 par_val_type in varchar2,
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
      var_found boolean;
      var_wrk_string varchar2(2048 char);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor company_c01 is 
         select company.company_desc
         from company
         where company.sap_company_code = var_sap_company_code;

      cursor pld_sal_format1200_c01 is 
         select pld_sal_format1200.extract_date,
                pld_sal_format1200.logical_date,
                pld_sal_format1200.current_YYYYPP,
                pld_sal_format1200.current_YYYYMM,
                pld_sal_format1200.extract_status,
                pld_sal_format1200.sales_date,
                pld_sal_format1200.sales_status,
                pld_sal_format1200.prd_asofdays,
                pld_sal_format1200.prd_percent,
                pld_sal_format1200.mth_asofdays,
                pld_sal_format1200.mth_percent
         from pld_sal_format1200;

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
      var_for_type := par_for_type;
      var_val_type := par_val_type;

      /*-*/
      /* Retrieve the format control */
      /*-*/
      var_found := true;
      open pld_sal_format1200_c01;
      fetch pld_sal_format1200_c01 into var_extract_date,
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
      if pld_sal_format1200_c01%notfound then
         var_found := false;
      end if;
      close pld_sal_format1200_c01;
      if var_found = false then
         raise_application_error(-20000, 'Format control row PLD_SAL_FORMAT1200 not found');
      end if;
      var_previous_YYYYPP := mfjpln_control.previousPeriod(var_current_YYYYPP, false);
      var_previous_YYYYMM := mfjpln_control.previousMonth(var_current_YYYYMM, false);

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
      /* Report heading line 1 */
      /*-*/
      var_wrk_string := 'Combined Business YEE';
      if var_for_type = 'PRD_BR' then
         var_wrk_string := var_wrk_string || ' - Period - BR Forecast';
      elsif var_for_type = 'PRD_LE' then
         var_wrk_string := var_wrk_string || ' - Period - LE Forecast';
      elsif var_for_type = 'MTH_BR' then
         var_wrk_string := var_wrk_string || ' - Month - BR Forecast';
      elsif var_for_type = 'MTH_LE' then
         var_wrk_string := var_wrk_string || ' - Month - LE Forecast';
      end if;
      if var_val_type = 'QTY' then
         var_wrk_string := var_wrk_string || ' - Quantity - Delivery Date';
      elsif var_val_type = 'TON' then
         var_wrk_string := var_wrk_string || ' - Tonnes - Delivery Date';
      elsif var_val_type = 'BPS' then
         var_wrk_string := var_wrk_string || ' - Base Price Value (Yen Millions) - Delivery Date';
      elsif var_val_type = 'GSV' then
         var_wrk_string := var_wrk_string || ' - Gross Sales Value (Yen Millions) - Delivery Date';
      end if;
      if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
         xlxml_object.SetRange('A1:A1', 'A1:W1', xlxml_object.GetHeadingType(1), -2, 0, false, var_wrk_string);
      elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
         xlxml_object.SetRange('A1:A1', 'A1:V1', xlxml_object.GetHeadingType(1), -2, 0, false, var_wrk_string);
      end if;

      /*-*/
      /* Report heading line 2 */
      /*-*/
      var_wrk_string := var_extract_status || ' ' || var_sales_status;
      if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
         xlxml_object.SetRange('A2:A2', 'A2:W2', xlxml_object.TYPE_HEADING_SM, -2, 0, false, var_wrk_string);
      elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
         xlxml_object.SetRange('A2:A2', 'A2:V2', xlxml_object.TYPE_HEADING_SM, -2, 0, false, var_wrk_string);
      end if;

      /*-*/
      /* Report heading line 3 */
      /*-*/
      var_wrk_string := 'Company: ' || var_company_desc;
      if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
         xlxml_object.SetRange('A3:A3', 'A3:W3', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);
      elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
         xlxml_object.SetRange('A3:A3', 'A3:V3', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);
      end if;

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
      if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
         xlxml_object.SetRange('A4:A4', 'A4:W4', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);
      elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
         xlxml_object.SetRange('A4:A4', 'A4:V4', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);
      end if;

      /*-*/
      /* Report heading line 5 */
      /*-*/
      if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
         xlxml_object.SetRange('A5:A5', null, xlxml_object.GetHeadingType(7), -1, 0, false, null);
         xlxml_object.SetRange('B5:B5', 'B5:N5', xlxml_object.GetHeadingType(7), -2, 0, false, 'Periods');
         xlxml_object.SetRange('O5:O5', 'O5:Q5', xlxml_object.GetHeadingType(7), -2, 0, false, 'YTD');
         xlxml_object.SetRange('R5:R5', 'R5:T5', xlxml_object.GetHeadingType(7), -2, 0, false, 'YTG');
         xlxml_object.SetRange('U5:U5', 'U5:W5', xlxml_object.GetHeadingType(7), -2, 0, false, 'YEE');
      elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
         xlxml_object.SetRange('A5:A5', null, xlxml_object.GetHeadingType(7), -1, 0, false, null);
         xlxml_object.SetRange('B5:B5', 'B5:M5', xlxml_object.GetHeadingType(7), -2, 0, false, 'Months');
         xlxml_object.SetRange('N5:N5', 'N5:P5', xlxml_object.GetHeadingType(7), -2, 0, false, 'YTD');
         xlxml_object.SetRange('Q5:Q5', 'Q5:S5', xlxml_object.GetHeadingType(7), -2, 0, false, 'YTG');
         xlxml_object.SetRange('T5:T5', 'T5:V5', xlxml_object.GetHeadingType(7), -2, 0, false, 'YEE');
      end if;

      /*-*/
      /* Report heading line 6 */
      /*-*/
      xlxml_object.SetRange('A6:A6', null, xlxml_object.GetHeadingType(7), -1, 0, false, 'Material Hierarchy');
      if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
         var_wrk_string := 'P01' || chr(9) ||
                           'P02' || chr(9) ||
                           'P03' || chr(9) ||
                           'P04' || chr(9) ||
                           'P05' || chr(9) ||
                           'P06' || chr(9) ||
                           'P07' || chr(9) ||
                           'P08' || chr(9) ||
                           'P09' || chr(9) ||
                           'P10' || chr(9) ||
                           'P11' || chr(9) ||
                           'P12' || chr(9) ||
                           'P13' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %';
         xlxml_object.SetRangeArray('B6:B6', 'B6:W6', xlxml_object.GetHeadingType(7), -2, var_wrk_string);
      elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
         var_wrk_string := 'M01' || chr(9) ||
                           'M02' || chr(9) ||
                           'M03' || chr(9) ||
                           'M04' || chr(9) ||
                           'M05' || chr(9) ||
                           'M06' || chr(9) ||
                           'M07' || chr(9) ||
                           'M08' || chr(9) ||
                           'M09' || chr(9) ||
                           'M10' || chr(9) ||
                           'M11' || chr(9) ||
                           'M12' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %';
         xlxml_object.SetRangeArray('B6:B6', 'B6:V6', xlxml_object.GetHeadingType(7), -2, var_wrk_string);
      end if;

      /*-*/
      /* Report heading borders */
      /*-*/
      if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
         xlxml_object.SetHeadingBorder('B5:N5', 'ALL');
         xlxml_object.SetHeadingBorder('O5:Q5', 'ALL');
         xlxml_object.SetHeadingBorder('R5:T5', 'ALL');
         xlxml_object.SetHeadingBorder('U5:W5', 'ALL');
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
         xlxml_object.SetHeadingBorder('R6:R6', 'TLR');
         xlxml_object.SetHeadingBorder('S6:S6', 'TLR');
         xlxml_object.SetHeadingBorder('T6:T6', 'TLR');
         xlxml_object.SetHeadingBorder('U6:U6', 'TLR');
         xlxml_object.SetHeadingBorder('V6:V6', 'TLR');
         xlxml_object.SetHeadingBorder('W6:W6', 'TLR');
      elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
         xlxml_object.SetHeadingBorder('B5:M5', 'ALL');
         xlxml_object.SetHeadingBorder('N5:P5', 'ALL');
         xlxml_object.SetHeadingBorder('Q5:S5', 'ALL');
         xlxml_object.SetHeadingBorder('T5:V5', 'ALL');
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
         xlxml_object.SetHeadingBorder('R6:R6', 'TLR');
         xlxml_object.SetHeadingBorder('S6:S6', 'TLR');
         xlxml_object.SetHeadingBorder('T6:T6', 'TLR');
         xlxml_object.SetHeadingBorder('U6:U6', 'TLR');
         xlxml_object.SetHeadingBorder('V6:V6', 'TLR');
      end if;

      /*-*/
      /* Initialise the row count */
      /*-*/
      var_row_count := 6;

      /*-*/
      /* Process the report details */
      /* 01 = Snackfood */
      /* 02 = Food */
      /* 05 = Petcare */
      /*-*/
      doDetail('01');
      doDetail('02');
      doDetail('05');

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
         if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
            xlxml_object.SetRange('A7:A7', 'A7:W7', xlxml_object.TYPE_DETAIL, -2, 0, false, 'NO DETAILS EXIST');
            xlxml_object.SetRangeBorder('A7:W7');
         elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
            xlxml_object.SetRange('A7:A7', 'A7:V7', xlxml_object.TYPE_DETAIL, -2, 0, false, 'NO DETAILS EXIST');
            xlxml_object.SetRangeBorder('A7:V7');
         end if;
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
   procedure doDetail(par_sap_bus_sgmnt_code in varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_grp_literal varchar2(2048 char);
      var_srt_literal varchar2(2048 char);
      var_for_literal varchar2(256 char);
      var_val_literal varchar2(256 char);
      var_prd_literal varchar2(6 char);
      var_p01_literal varchar2(6 char);
      var_p02_literal varchar2(6 char);
      var_p03_literal varchar2(6 char);
      var_p04_literal varchar2(6 char);
      var_p05_literal varchar2(6 char);
      var_p06_literal varchar2(6 char);
      var_p07_literal varchar2(6 char);
      var_p08_literal varchar2(6 char);
      var_p09_literal varchar2(6 char);
      var_p10_literal varchar2(6 char);
      var_p11_literal varchar2(6 char);
      var_p12_literal varchar2(6 char);
      var_p13_literal varchar2(6 char);
      var_mth_literal varchar2(6 char);
      var_m01_literal varchar2(6 char);
      var_m02_literal varchar2(6 char);
      var_m03_literal varchar2(6 char);
      var_m04_literal varchar2(6 char);
      var_m05_literal varchar2(6 char);
      var_m06_literal varchar2(6 char);
      var_m07_literal varchar2(6 char);
      var_m08_literal varchar2(6 char);
      var_m09_literal varchar2(6 char);
      var_m10_literal varchar2(6 char);
      var_m11_literal varchar2(6 char);
      var_m12_literal varchar2(6 char);
      var_ytd_ty_val number(22,6);
      var_ytd_ly_val number(22,6);
      var_ytd_op_val number(22,6);
      var_ytd_fc_val number(22,6);
      var_ytg_ly_val number(22,6);
      var_ytg_op_val number(22,6);
      var_ytg_fc_val number(22,6);
      var_w01_val number(22,6);
      var_w02_val number(22,6);
      var_w03_val number(22,6);
      var_w04_val number(22,6);
      var_w05_val number(22,6);
      var_w06_val number(22,6);
      var_w07_val number(22,6);
      var_w08_val number(22,6);
      var_w09_val number(22,6);
      var_w10_val number(22,6);
      var_w11_val number(22,6);
      var_w12_val number(22,6);
      var_w13_val number(22,6);
      var_bus_sgmnt_desc varchar2(128 char);
      var_mkt_sgmnt_desc varchar2(128 char);
      var_supply_sgmnt_desc varchar2(128 char);
      var_brand_flag_desc varchar2(128 char);
      var_brand_sub_flag_desc varchar2(128 char);
      var_wrk_string varchar2(2048 char);
      var_wrk_array varchar2(4000 char);
      var_dynamic_sql varchar2(32767 char);
      type typCursor is ref cursor;
      pld_sal_format12_c01 typCursor;

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
      if par_sap_bus_sgmnt_code = '01' then
         var_grp_literal := 't02.sap_bus_sgmnt_code,
                             t02.sap_mkt_sgmnt_code,
                             t02.sap_brand_flag_code,
                             t02.sap_supply_sgmnt_code,
                             t02.sap_brand_sub_flag_code';
         var_srt_literal := 'bus_sgmnt_text asc,
                             mkt_sgmnt_text asc,
                             brand_flag_text asc,
                             supply_sgmnt_text asc,
                             brand_sub_flag_text asc';
      elsif par_sap_bus_sgmnt_code = '02' then
         var_grp_literal := 't02.sap_bus_sgmnt_code,
                             t02.sap_brand_flag_code,
                             t02.sap_mkt_sgmnt_code,
                             t02.sap_supply_sgmnt_code,
                             t02.sap_brand_sub_flag_code';
         var_srt_literal := 'bus_sgmnt_text asc,
                             brand_flag_text asc,
                             mkt_sgmnt_text asc,
                             supply_sgmnt_text asc,
                             brand_sub_flag_text asc';
      elsif par_sap_bus_sgmnt_code = '05' then
         var_grp_literal := 't02.sap_bus_sgmnt_code,
                             t02.sap_mkt_sgmnt_code,
                             t02.sap_supply_sgmnt_code,
                             t02.sap_brand_flag_code,
                             t02.sap_brand_sub_flag_code';
         var_srt_literal := 'bus_sgmnt_text asc,
                             mkt_sgmnt_text asc,
                             supply_sgmnt_text asc,
                             brand_flag_text asc,
                             brand_sub_flag_text asc';
      else
         var_grp_literal := 't02.sap_bus_sgmnt_code,
                             t02.sap_mkt_sgmnt_code,
                             t02.sap_supply_sgmnt_code,
                             t02.sap_brand_flag_code,
                             t02.sap_brand_sub_flag_code';
         var_srt_literal := 'bus_sgmnt_text asc,
                             mkt_sgmnt_text asc,
                             supply_sgmnt_text asc,
                             brand_flag_text asc,
                             brand_sub_flag_text asc';
      end if;

      /*-*/
      /* Initialise the forecast literal */
      /*-*/
      if var_for_type = 'PRD_BR' then
         var_for_literal := 'br';
      elsif var_for_type = 'PRD_LE' then
         var_for_literal := 'le';
      elsif var_for_type = 'MTH_BR' then
         var_for_literal := 'br';
      elsif var_for_type = 'MTH_LE' then
         var_for_literal := 'le';
      end if;

      /*-*/
      /* Initialise the value literal */
      /*-*/
      if var_val_type = 'QTY' then
         var_val_literal := 'qty';
      elsif var_val_type = 'TON' then
         var_val_literal := 'ton';
      elsif var_val_type = 'BPS' then
         var_val_literal := 'bps';
      elsif var_val_type = 'GSV' then
         var_val_literal := 'gsv';
      end if;

      /*-*/
      /* Initialise the period literals */
      /*-*/
      var_prd_literal := to_char(var_previous_YYYYPP,'FM000000');
      var_p01_literal := substr(to_char(var_previous_YYYYPP,'FM000000'),1,4) || '01';
      var_p02_literal := substr(to_char(var_previous_YYYYPP,'FM000000'),1,4) || '02';
      var_p03_literal := substr(to_char(var_previous_YYYYPP,'FM000000'),1,4) || '03';
      var_p04_literal := substr(to_char(var_previous_YYYYPP,'FM000000'),1,4) || '04';
      var_p05_literal := substr(to_char(var_previous_YYYYPP,'FM000000'),1,4) || '05';
      var_p06_literal := substr(to_char(var_previous_YYYYPP,'FM000000'),1,4) || '06';
      var_p07_literal := substr(to_char(var_previous_YYYYPP,'FM000000'),1,4) || '07';
      var_p08_literal := substr(to_char(var_previous_YYYYPP,'FM000000'),1,4) || '08';
      var_p09_literal := substr(to_char(var_previous_YYYYPP,'FM000000'),1,4) || '09';
      var_p10_literal := substr(to_char(var_previous_YYYYPP,'FM000000'),1,4) || '10';
      var_p11_literal := substr(to_char(var_previous_YYYYPP,'FM000000'),1,4) || '11';
      var_p12_literal := substr(to_char(var_previous_YYYYPP,'FM000000'),1,4) || '12';
      var_p13_literal := substr(to_char(var_previous_YYYYPP,'FM000000'),1,4) || '13';

      /*-*/
      /* Initialise the month literals */
      /*-*/
      var_mth_literal := to_char(var_previous_YYYYMM,'FM000000');
      var_m01_literal := substr(to_char(var_previous_YYYYMM,'FM000000'),1,4) || '01';
      var_m02_literal := substr(to_char(var_previous_YYYYMM,'FM000000'),1,4) || '02';
      var_m03_literal := substr(to_char(var_previous_YYYYMM,'FM000000'),1,4) || '03';
      var_m04_literal := substr(to_char(var_previous_YYYYMM,'FM000000'),1,4) || '04';
      var_m05_literal := substr(to_char(var_previous_YYYYMM,'FM000000'),1,4) || '05';
      var_m06_literal := substr(to_char(var_previous_YYYYMM,'FM000000'),1,4) || '06';
      var_m07_literal := substr(to_char(var_previous_YYYYMM,'FM000000'),1,4) || '07';
      var_m08_literal := substr(to_char(var_previous_YYYYMM,'FM000000'),1,4) || '08';
      var_m09_literal := substr(to_char(var_previous_YYYYMM,'FM000000'),1,4) || '09';
      var_m10_literal := substr(to_char(var_previous_YYYYMM,'FM000000'),1,4) || '10';
      var_m11_literal := substr(to_char(var_previous_YYYYMM,'FM000000'),1,4) || '11';
      var_m12_literal := substr(to_char(var_previous_YYYYMM,'FM000000'),1,4) || '12';

      /*-*/
      /* Initialise the detail query */
      /*-*/
      if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
         var_dynamic_sql := 'select sum(t01.ytd_ty_val),
                                    sum(t01.ytd_ly_val),
                                    sum(t01.ytd_op_val),
                                    sum(t01.ytd_fc_val),
                                    sum(t01.ytg_ly_val),
                                    sum(t01.ytg_op_val),
                                    sum(t01.ytg_fc_val),
                                    sum(t01.w01_val),
                                    sum(t01.w02_val),
                                    sum(t01.w03_val),
                                    sum(t01.w04_val),
                                    sum(t01.w05_val),
                                    sum(t01.w06_val),
                                    sum(t01.w07_val),
                                    sum(t01.w08_val),
                                    sum(t01.w09_val),
                                    sum(t01.w10_val),
                                    sum(t01.w11_val),
                                    sum(t01.w12_val),
                                    sum(t01.w13_val),
                                    max(t02.bus_sgmnt_desc) as bus_sgmnt_text,
                                    case when max(t02.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                         else max(t02.mkt_sgmnt_desc) end as mkt_sgmnt_text,
                                    case when max(t02.sap_supply_sgmnt_code) = ''000'' then
                                              case when max(t02.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                   else max(t02.mkt_sgmnt_desc) end 
                                         else max(t02.supply_sgmnt_desc) end as supply_sgmnt_text,
                                    case when max(t02.sap_brand_flag_code) = ''000'' then
                                              case when max(t02.sap_supply_sgmnt_code) = ''000'' then
                                                        case when max(t02.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                        else max(t02.mkt_sgmnt_desc) end 
                                                   else max(t02.supply_sgmnt_desc) end 
                                         else max(t02.brand_flag_desc) end as brand_flag_text,
                                    case when max(t02.sap_brand_sub_flag_code) = ''000'' then
                                              case when max(t02.sap_brand_flag_code) = ''000'' then
                                                        case when max(t02.sap_supply_sgmnt_code) = ''000'' then
                                                                  case when max(t02.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                       else max(t02.mkt_sgmnt_desc) end 
                                                             else max(t02.supply_sgmnt_desc) end 
                                                   else max(t02.brand_flag_desc) end
                                         else max(t02.brand_sub_flag_desc) end as brand_sub_flag_text
                               from (select t11.sap_material_code sap_material_code,
                                            t11.ytd_ty_' || var_val_literal || ' ytd_ty_val,
                                            t11.ytd_ly_' || var_val_literal || ' ytd_ly_val,
                                            t11.ytd_op_' || var_val_literal || ' ytd_op_val,
                                            t11.ytd_' || var_for_literal || '_' || var_val_literal || ' ytd_fc_val,
                                            t11.ytg_ly_' || var_val_literal || ' ytg_ly_val,
                                            t11.ytg_op_' || var_val_literal || ' ytg_op_val,
                                            t11.ytg_' || var_for_literal || '_' || var_val_literal || ' ytg_fc_val,
                                            nvl(t12.w01_val,0) w01_val,
                                            nvl(t12.w02_val,0) w02_val,
                                            nvl(t12.w03_val,0) w03_val,
                                            nvl(t12.w04_val,0) w04_val,
                                            nvl(t12.w05_val,0) w05_val,
                                            nvl(t12.w06_val,0) w06_val,
                                            nvl(t12.w07_val,0) w07_val,
                                            nvl(t12.w08_val,0) w08_val,
                                            nvl(t12.w09_val,0) w09_val,
                                            nvl(t12.w10_val,0) w10_val,
                                            nvl(t12.w11_val,0) w11_val,
                                            nvl(t12.w12_val,0) w12_val,
                                            nvl(t12.w13_val,0) w13_val
                                       from pld_sal_format1201 t11, (select t22.sap_company_code sap_company_code,
                                                                            t22.sap_material_code sap_material_code,
                                                                            sum(case when t22.billing_YYYYPP = ' || var_p01_literal || ' and t22.billing_YYYYPP <= ' || var_prd_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYPP = ' || var_p01_literal || ' and t22.billing_YYYYPP > ' || var_prd_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w01_val,' ||
                                                                          ' sum(case when t22.billing_YYYYPP = ' || var_p02_literal || ' and t22.billing_YYYYPP <= ' || var_prd_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYPP = ' || var_p02_literal || ' and t22.billing_YYYYPP > ' || var_prd_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w02_val,' ||
                                                                          ' sum(case when t22.billing_YYYYPP = ' || var_p03_literal || ' and t22.billing_YYYYPP <= ' || var_prd_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYPP = ' || var_p03_literal || ' and t22.billing_YYYYPP > ' || var_prd_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w03_val,' ||
                                                                          ' sum(case when t22.billing_YYYYPP = ' || var_p04_literal || ' and t22.billing_YYYYPP <= ' || var_prd_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYPP = ' || var_p04_literal || ' and t22.billing_YYYYPP > ' || var_prd_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w04_val,' ||
                                                                          ' sum(case when t22.billing_YYYYPP = ' || var_p05_literal || ' and t22.billing_YYYYPP <= ' || var_prd_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYPP = ' || var_p05_literal || ' and t22.billing_YYYYPP > ' || var_prd_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w05_val,' ||
                                                                          ' sum(case when t22.billing_YYYYPP = ' || var_p06_literal || ' and t22.billing_YYYYPP <= ' || var_prd_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYPP = ' || var_p06_literal || ' and t22.billing_YYYYPP > ' || var_prd_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w06_val,' ||
                                                                          ' sum(case when t22.billing_YYYYPP = ' || var_p07_literal || ' and t22.billing_YYYYPP <= ' || var_prd_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYPP = ' || var_p07_literal || ' and t22.billing_YYYYPP > ' || var_prd_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w07_val,' ||
                                                                          ' sum(case when t22.billing_YYYYPP = ' || var_p08_literal || ' and t22.billing_YYYYPP <= ' || var_prd_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYPP = ' || var_p08_literal || ' and t22.billing_YYYYPP > ' || var_prd_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w08_val,' ||
                                                                          ' sum(case when t22.billing_YYYYPP = ' || var_p09_literal || ' and t22.billing_YYYYPP <= ' || var_prd_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYPP = ' || var_p09_literal || ' and t22.billing_YYYYPP > ' || var_prd_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w09_val,' ||
                                                                          ' sum(case when t22.billing_YYYYPP = ' || var_p10_literal || ' and t22.billing_YYYYPP <= ' || var_prd_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYPP = ' || var_p10_literal || ' and t22.billing_YYYYPP > ' || var_prd_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w10_val,' ||
                                                                          ' sum(case when t22.billing_YYYYPP = ' || var_p11_literal || ' and t22.billing_YYYYPP <= ' || var_prd_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYPP = ' || var_p11_literal || ' and t22.billing_YYYYPP > ' || var_prd_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w11_val,' ||
                                                                          ' sum(case when t22.billing_YYYYPP = ' || var_p12_literal || ' and t22.billing_YYYYPP <= ' || var_prd_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYPP = ' || var_p12_literal || ' and t22.billing_YYYYPP > ' || var_prd_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w12_val,' ||
                                                                          ' sum(case when t22.billing_YYYYPP = ' || var_p13_literal || ' and t22.billing_YYYYPP <= ' || var_prd_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYPP = ' || var_p13_literal || ' and t22.billing_YYYYPP > ' || var_prd_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w13_val' ||
                                                                     ' from pld_sal_format1203 t22
                                                                      where t22.sap_company_code = :A
                                                                   group by t22.sap_company_code,
                                                                            t22.sap_material_code) t12
                                      where t11.sap_company_code = t12.sap_company_code(+)
                                        and t11.sap_material_code = t12.sap_material_code(+)
                                        and t11.sap_company_code = :B) t01, material_dim t02
                              where t01.sap_material_code = t02.sap_material_code(+)
                                and t02.sap_bus_sgmnt_code = :C
                                and (t01.ytd_ty_val <> 0 or
                                     t01.ytd_ly_val <> 0 or
                                     t01.ytd_op_val <> 0 or
                                     t01.ytd_fc_val <> 0 or
                                     t01.ytg_ly_val <> 0 or
                                     t01.ytg_op_val <> 0 or
                                     t01.ytg_fc_val <> 0 or
                                     t01.w01_val <> 0 or
                                     t01.w02_val <> 0 or
                                     t01.w03_val <> 0 or
                                     t01.w04_val <> 0 or
                                     t01.w05_val <> 0 or
                                     t01.w06_val <> 0 or
                                     t01.w07_val <> 0 or
                                     t01.w08_val <> 0 or
                                     t01.w09_val <> 0 or
                                     t01.w10_val <> 0 or
                                     t01.w11_val <> 0 or
                                     t01.w12_val <> 0 or
                                     t01.w13_val <> 0)
                           group by ' || var_grp_literal || '
                           order by ' || var_srt_literal;

      elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
         var_dynamic_sql := 'select sum(t01.ytd_ty_val),
                                    sum(t01.ytd_ly_val),
                                    sum(t01.ytd_op_val),
                                    sum(t01.ytd_fc_val),
                                    sum(t01.ytg_ly_val),
                                    sum(t01.ytg_op_val),
                                    sum(t01.ytg_fc_val),
                                    sum(t01.w01_val),
                                    sum(t01.w02_val),
                                    sum(t01.w03_val),
                                    sum(t01.w04_val),
                                    sum(t01.w05_val),
                                    sum(t01.w06_val),
                                    sum(t01.w07_val),
                                    sum(t01.w08_val),
                                    sum(t01.w09_val),
                                    sum(t01.w10_val),
                                    sum(t01.w11_val),
                                    sum(t01.w12_val),
                                    max(t02.bus_sgmnt_desc) as bus_sgmnt_text,
                                    case when max(t02.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                         else max(t02.mkt_sgmnt_desc) end as mkt_sgmnt_text,
                                    case when max(t02.sap_supply_sgmnt_code) = ''000'' then
                                              case when max(t02.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                   else max(t02.mkt_sgmnt_desc) end 
                                         else max(t02.supply_sgmnt_desc) end as supply_sgmnt_text,
                                    case when max(t02.sap_brand_flag_code) = ''000'' then
                                              case when max(t02.sap_supply_sgmnt_code) = ''000'' then
                                                        case when max(t02.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                        else max(t02.mkt_sgmnt_desc) end 
                                                   else max(t02.supply_sgmnt_desc) end 
                                         else max(t02.brand_flag_desc) end as brand_flag_text,
                                    case when max(t02.sap_brand_sub_flag_code) = ''000'' then
                                              case when max(t02.sap_brand_flag_code) = ''000'' then
                                                        case when max(t02.sap_supply_sgmnt_code) = ''000'' then
                                                                  case when max(t02.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                       else max(t02.mkt_sgmnt_desc) end 
                                                             else max(t02.supply_sgmnt_desc) end 
                                                   else max(t02.brand_flag_desc) end
                                         else max(t02.brand_sub_flag_desc) end as brand_sub_flag_text
                               from (select t11.sap_material_code sap_material_code,
                                            t11.ytd_ty_' || var_val_literal || ' ytd_ty_val,
                                            t11.ytd_ly_' || var_val_literal || ' ytd_ly_val,
                                            t11.ytd_op_' || var_val_literal || ' ytd_op_val,
                                            t11.ytd_' || var_for_literal || '_' || var_val_literal || ' ytd_fc_val,
                                            t11.ytg_ly_' || var_val_literal || ' ytg_ly_val,
                                            t11.ytg_op_' || var_val_literal || ' ytg_op_val,
                                            t11.ytg_' || var_for_literal || '_' || var_val_literal || ' ytg_fc_val,
                                            nvl(t12.w01_val,0) w01_val,
                                            nvl(t12.w02_val,0) w02_val,
                                            nvl(t12.w03_val,0) w03_val,
                                            nvl(t12.w04_val,0) w04_val,
                                            nvl(t12.w05_val,0) w05_val,
                                            nvl(t12.w06_val,0) w06_val,
                                            nvl(t12.w07_val,0) w07_val,
                                            nvl(t12.w08_val,0) w08_val,
                                            nvl(t12.w09_val,0) w09_val,
                                            nvl(t12.w10_val,0) w10_val,
                                            nvl(t12.w11_val,0) w11_val,
                                            nvl(t12.w12_val,0) w12_val
                                       from pld_sal_format1202 t11, (select t22.sap_company_code sap_company_code,
                                                                            t22.sap_material_code sap_material_code,
                                                                            sum(case when t22.billing_YYYYMM = ' || var_m01_literal || ' and t22.billing_YYYYMM <= ' || var_mth_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYMM = ' || var_m01_literal || ' and t22.billing_YYYYMM > ' || var_mth_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w01_val,' ||
                                                                          ' sum(case when t22.billing_YYYYMM = ' || var_m02_literal || ' and t22.billing_YYYYMM <= ' || var_mth_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYMM = ' || var_m02_literal || ' and t22.billing_YYYYMM > ' || var_mth_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w02_val,' ||
                                                                          ' sum(case when t22.billing_YYYYMM = ' || var_m03_literal || ' and t22.billing_YYYYMM <= ' || var_mth_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYMM = ' || var_m03_literal || ' and t22.billing_YYYYMM > ' || var_mth_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w03_val,' ||
                                                                          ' sum(case when t22.billing_YYYYMM = ' || var_m04_literal || ' and t22.billing_YYYYMM <= ' || var_mth_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYMM = ' || var_m04_literal || ' and t22.billing_YYYYMM > ' || var_mth_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w04_val,' ||
                                                                          ' sum(case when t22.billing_YYYYMM = ' || var_m05_literal || ' and t22.billing_YYYYMM <= ' || var_mth_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYMM = ' || var_m05_literal || ' and t22.billing_YYYYMM > ' || var_mth_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w05_val,' ||
                                                                          ' sum(case when t22.billing_YYYYMM = ' || var_m06_literal || ' and t22.billing_YYYYMM <= ' || var_mth_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYMM = ' || var_m06_literal || ' and t22.billing_YYYYMM > ' || var_mth_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w06_val,' ||
                                                                          ' sum(case when t22.billing_YYYYMM = ' || var_m07_literal || ' and t22.billing_YYYYMM <= ' || var_mth_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYMM = ' || var_m07_literal || ' and t22.billing_YYYYMM > ' || var_mth_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w07_val,' ||
                                                                          ' sum(case when t22.billing_YYYYMM = ' || var_m08_literal || ' and t22.billing_YYYYMM <= ' || var_mth_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYMM = ' || var_m08_literal || ' and t22.billing_YYYYMM > ' || var_mth_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w08_val,' ||
                                                                          ' sum(case when t22.billing_YYYYMM = ' || var_m09_literal || ' and t22.billing_YYYYMM <= ' || var_mth_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYMM = ' || var_m09_literal || ' and t22.billing_YYYYMM > ' || var_mth_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w09_val,' ||
                                                                          ' sum(case when t22.billing_YYYYMM = ' || var_m10_literal || ' and t22.billing_YYYYMM <= ' || var_mth_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYMM = ' || var_m10_literal || ' and t22.billing_YYYYMM > ' || var_mth_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w10_val,' ||
                                                                          ' sum(case when t22.billing_YYYYMM = ' || var_m11_literal || ' and t22.billing_YYYYMM <= ' || var_mth_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYMM = ' || var_m11_literal || ' and t22.billing_YYYYMM > ' || var_mth_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w11_val,' ||
                                                                          ' sum(case when t22.billing_YYYYMM = ' || var_m12_literal || ' and t22.billing_YYYYMM <= ' || var_mth_literal || ' then t22.ty_' || var_val_literal ||
                                                                                   ' when t22.billing_YYYYMM = ' || var_m12_literal || ' and t22.billing_YYYYMM > ' || var_mth_literal || ' then t22.' || var_for_literal || '_' || var_val_literal || ' end) w12_val' ||
                                                                     ' from pld_sal_format1204 t22
                                                                      where t22.sap_company_code = :A
                                                                   group by t22.sap_company_code,
                                                                            t22.sap_material_code) t12
                                      where t11.sap_company_code = t12.sap_company_code(+)
                                        and t11.sap_material_code = t12.sap_material_code(+)
                                        and t11.sap_company_code = :B) t01, material_dim t02
                              where t01.sap_material_code = t02.sap_material_code(+)
                                and t02.sap_bus_sgmnt_code = :C
                                and (t01.ytd_ty_val <> 0 or
                                     t01.ytd_ly_val <> 0 or
                                     t01.ytd_op_val <> 0 or
                                     t01.ytd_fc_val <> 0 or
                                     t01.ytg_ly_val <> 0 or
                                     t01.ytg_op_val <> 0 or
                                     t01.ytg_fc_val <> 0 or
                                     t01.w01_val <> 0 or
                                     t01.w02_val <> 0 or
                                     t01.w03_val <> 0 or
                                     t01.w04_val <> 0 or
                                     t01.w05_val <> 0 or
                                     t01.w06_val <> 0 or
                                     t01.w07_val <> 0 or
                                     t01.w08_val <> 0 or
                                     t01.w09_val <> 0 or
                                     t01.w10_val <> 0 or
                                     t01.w11_val <> 0 or
                                     t01.w12_val <> 0)
                           group by ' || var_grp_literal || '
                           order by ' || var_srt_literal;
      end if;

      /*-*/
      /* Retrieve the detail rows */
      /*-*/
      open pld_sal_format12_c01 for var_dynamic_sql using var_sap_company_code, var_sap_company_code, par_sap_bus_sgmnt_code;
      loop
         if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
            fetch pld_sal_format12_c01 into var_ytd_ty_val,
                                            var_ytd_ly_val,
                                            var_ytd_op_val,
                                            var_ytd_fc_val,
                                            var_ytg_ly_val,
                                            var_ytg_op_val,
                                            var_ytg_fc_val,
                                            var_w01_val,
                                            var_w02_val,
                                            var_w03_val,
                                            var_w04_val,
                                            var_w05_val,
                                            var_w06_val,
                                            var_w07_val,
                                            var_w08_val,
                                            var_w09_val,
                                            var_w10_val,
                                            var_w11_val,
                                            var_w12_val,
                                            var_w13_val,
                                            var_bus_sgmnt_desc,
                                            var_mkt_sgmnt_desc,
                                            var_supply_sgmnt_desc,
                                            var_brand_flag_desc,
                                            var_brand_sub_flag_desc;
         elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
            fetch pld_sal_format12_c01 into var_ytd_ty_val,
                                            var_ytd_ly_val,
                                            var_ytd_op_val,
                                            var_ytd_fc_val,
                                            var_ytg_ly_val,
                                            var_ytg_op_val,
                                            var_ytg_fc_val,
                                            var_w01_val,
                                            var_w02_val,
                                            var_w03_val,
                                            var_w04_val,
                                            var_w05_val,
                                            var_w06_val,
                                            var_w07_val,
                                            var_w08_val,
                                            var_w09_val,
                                            var_w10_val,
                                            var_w11_val,
                                            var_w12_val,
                                            var_bus_sgmnt_desc,
                                            var_mkt_sgmnt_desc,
                                            var_supply_sgmnt_desc,
                                            var_brand_flag_desc,
                                            var_brand_sub_flag_desc;
         end if;
         if pld_sal_format12_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Set the summary level values */
         /*-*/
         if par_sap_bus_sgmnt_code = '01' then
            tblSummary(1).current_value := 'Business Total';
            tblSummary(2).current_value := var_bus_sgmnt_desc;
            tblSummary(3).current_value := var_mkt_sgmnt_desc;
            tblSummary(4).current_value := var_brand_flag_desc;
            tblSummary(5).current_value := var_supply_sgmnt_desc;
         elsif par_sap_bus_sgmnt_code = '02' then
            tblSummary(1).current_value := 'Business Total';
            tblSummary(2).current_value := var_bus_sgmnt_desc;
            tblSummary(3).current_value := var_brand_flag_desc;
            tblSummary(4).current_value := var_mkt_sgmnt_desc;
            tblSummary(5).current_value := var_supply_sgmnt_desc;
         elsif par_sap_bus_sgmnt_code = '05' then
            tblSummary(1).current_value := 'Business Total';
            tblSummary(2).current_value := var_bus_sgmnt_desc;
            tblSummary(3).current_value := var_mkt_sgmnt_desc;
            tblSummary(4).current_value := var_supply_sgmnt_desc;
            tblSummary(5).current_value := var_brand_flag_desc;
         else
            tblSummary(1).current_value := 'Business Total';
            tblSummary(2).current_value := var_bus_sgmnt_desc;
            tblSummary(3).current_value := var_mkt_sgmnt_desc;
            tblSummary(4).current_value := var_supply_sgmnt_desc;
            tblSummary(5).current_value := var_brand_flag_desc;
         end if;

         /*-*/
         /* Adjust the low level descriptions */
         /*-*/
         if var_brand_sub_flag_desc <> var_brand_flag_desc then
            var_brand_sub_flag_desc := var_brand_flag_desc || ' ' || var_brand_sub_flag_desc;
         end if;

         /*-*/
         /* Set the summary level descriptions */
         /*-*/
         if par_sap_bus_sgmnt_code = '01' then
            tblSummary(1).description := 'Business Total';
            tblSummary(2).description := var_bus_sgmnt_desc;
            tblSummary(3).description := var_mkt_sgmnt_desc;
            tblSummary(4).description := var_brand_flag_desc;
            tblSummary(5).description := var_supply_sgmnt_desc;
         elsif par_sap_bus_sgmnt_code = '02' then
            tblSummary(1).description := 'Business Total';
            tblSummary(2).description := var_bus_sgmnt_desc;
            tblSummary(3).description := var_brand_flag_desc;
            tblSummary(4).description := var_mkt_sgmnt_desc;
            tblSummary(5).description := var_supply_sgmnt_desc;
         elsif par_sap_bus_sgmnt_code = '05' then
            tblSummary(1).description := 'Business Total';
            tblSummary(2).description := var_bus_sgmnt_desc;
            tblSummary(3).description := var_mkt_sgmnt_desc;
            tblSummary(4).description := var_supply_sgmnt_desc;
            tblSummary(5).description := var_brand_flag_desc;
         else
            tblSummary(1).description := 'Business Total';
            tblSummary(2).description := var_bus_sgmnt_desc;
            tblSummary(3).description := var_mkt_sgmnt_desc;
            tblSummary(4).description := var_supply_sgmnt_desc;
            tblSummary(5).description := var_brand_flag_desc;
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
            tblSummary(idx).ytd_ty_val := tblSummary(idx).ytd_ty_val + var_ytd_ty_val;
            tblSummary(idx).ytd_ly_val := tblSummary(idx).ytd_ly_val + var_ytd_ly_val;
            tblSummary(idx).ytd_op_val := tblSummary(idx).ytd_op_val + var_ytd_op_val;
            tblSummary(idx).ytd_fc_val := tblSummary(idx).ytd_fc_val + var_ytd_fc_val;
            tblSummary(idx).ytg_ly_val := tblSummary(idx).ytg_ly_val + var_ytg_ly_val;
            tblSummary(idx).ytg_op_val := tblSummary(idx).ytg_op_val + var_ytg_op_val;
            tblSummary(idx).ytg_fc_val := tblSummary(idx).ytg_fc_val + var_ytg_fc_val;
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
                               null, xlxml_object.TYPE_DETAIL, -1, 5, false, var_brand_sub_flag_desc);

         /*-*/
         /* Period/month values */
         /*-*/
         if var_val_type = 'QTY' then
            var_wrk_string := to_char(var_w01_val,'FM9999999999999999999990');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w02_val,'FM9999999999999999999990');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w03_val,'FM9999999999999999999990');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w04_val,'FM9999999999999999999990');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w05_val,'FM9999999999999999999990');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w06_val,'FM9999999999999999999990');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w07_val,'FM9999999999999999999990');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w08_val,'FM9999999999999999999990');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w09_val,'FM9999999999999999999990');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w10_val,'FM9999999999999999999990');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w11_val,'FM9999999999999999999990');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w12_val,'FM9999999999999999999990');
            if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
               var_wrk_string := var_wrk_string || chr(9) || to_char(var_w13_val,'FM9999999999999999999990');
            end if;
         elsif var_val_type = 'TON' then
            var_wrk_string := to_char(var_w01_val,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w02_val,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w03_val,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w04_val,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w05_val,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w06_val,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w07_val,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w08_val,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w09_val,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w10_val,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w11_val,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w12_val,'FM9999999999999990.000000');
            if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
               var_wrk_string := var_wrk_string || chr(9) || to_char(var_w13_val,'FM9999999999999990.000000');
            end if;
         elsif var_val_type = 'BPS' then
            var_wrk_string := to_char(var_w01_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w02_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w03_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w04_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w05_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w06_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w07_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w08_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w09_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w10_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w11_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w12_val/1000000,'FM9999999999999990.000000');
            if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
               var_wrk_string := var_wrk_string || chr(9) || to_char(var_w13_val/1000000,'FM9999999999999990.000000');
            end if;
         elsif var_val_type = 'GSV' then
            var_wrk_string := to_char(var_w01_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w02_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w03_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w04_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w05_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w06_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w07_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w08_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w09_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w10_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w11_val/1000000,'FM9999999999999990.000000');
            var_wrk_string := var_wrk_string || chr(9) || to_char(var_w12_val/1000000,'FM9999999999999990.000000');
            if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
               var_wrk_string := var_wrk_string || chr(9) || to_char(var_w13_val/1000000,'FM9999999999999990.000000');
            end if;
         end if;
         var_wrk_array := var_wrk_string;

         /*-*/
         /* YTD value */
         /*-*/
         if var_val_type = 'QTY' then
            var_wrk_string := to_char(var_ytd_ty_val,'FM9999999999999999999990');
         elsif var_val_type = 'TON' then
            var_wrk_string := to_char(var_ytd_ty_val,'FM9999999999999990.000000');
         elsif var_val_type = 'BPS' then
            var_wrk_string := to_char(var_ytd_ty_val/1000000,'FM9999999999999990.000000');
         elsif var_val_type = 'GSV' then
            var_wrk_string := to_char(var_ytd_ty_val/1000000,'FM9999999999999990.000000');
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTD % Plan */
         /*-*/
         if var_ytd_ty_val <> 0 and var_ytd_op_val <> 0 then
            var_wrk_string := to_char(round((var_ytd_ty_val / var_ytd_op_val) * 100, 2),'FM9999990.00');
         elsif var_ytd_ty_val = 0 and var_ytd_op_val = 0 then
            var_wrk_string := 'NS/NP';
         elsif var_ytd_ty_val = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTD % Growth */
         /*-*/
         if var_ytd_ty_val <> 0 and var_ytd_ly_val <> 0 then
            var_wrk_string := to_char(round((var_ytd_ty_val / var_ytd_ly_val) * 100, 2),'FM9999990.00');
         elsif var_ytd_ty_val = 0 and var_ytd_ly_val = 0 then
            var_wrk_string := 'NS/NL';
         elsif var_ytd_ty_val = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NL';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTG value */
         /*-*/
         if var_val_type = 'QTY' then
            var_wrk_string := to_char(var_ytg_fc_val,'FM9999999999999999999990');
         elsif var_val_type = 'TON' then
            var_wrk_string := to_char(var_ytg_fc_val,'FM9999999999999990.000000');
         elsif var_val_type = 'BPS' then
            var_wrk_string := to_char(var_ytg_fc_val/1000000,'FM9999999999999990.000000');
         elsif var_val_type = 'GSV' then
            var_wrk_string := to_char(var_ytg_fc_val/1000000,'FM9999999999999990.000000');
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTG % Plan */
         /*-*/
         if var_ytg_fc_val <> 0 and var_ytg_op_val <> 0 then
            var_wrk_string := to_char(round((var_ytg_fc_val / var_ytg_op_val) * 100, 2),'FM9999990.00');
         elsif var_ytg_fc_val = 0 and var_ytg_op_val = 0 then
            var_wrk_string := 'NF/NP';
         elsif var_ytg_fc_val = 0 then
            var_wrk_string := 'NF';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTG % Growth */
         /*-*/
         if var_ytg_fc_val <> 0 and var_ytg_ly_val <> 0 then
            var_wrk_string := to_char(round((var_ytg_fc_val / var_ytg_ly_val) * 100, 2),'FM9999990.00');
         elsif var_ytg_fc_val = 0 and var_ytg_ly_val = 0 then
            var_wrk_string := 'NS/NL';
         elsif var_ytg_fc_val = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NL';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YEE value */
         /*-*/
         if var_val_type = 'QTY' then
            var_wrk_string := to_char(var_ytd_ty_val + var_ytg_fc_val,'FM9999999999999999999990');
         elsif var_val_type = 'TON' then
            var_wrk_string := to_char(var_ytd_ty_val + var_ytg_fc_val,'FM9999999999999990.000000');
         elsif var_val_type = 'BPS' then
            var_wrk_string := to_char((var_ytd_ty_val + var_ytg_fc_val) / 1000000,'FM9999999999999990.000000');
         elsif var_val_type = 'GSV' then
            var_wrk_string := to_char((var_ytd_ty_val + var_ytg_fc_val) / 1000000,'FM9999999999999990.000000');
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YEE % Plan */
         /*-*/
         if (var_ytd_ty_val + var_ytg_fc_val) <> 0 and (var_ytd_op_val + var_ytg_op_val) <> 0 then
            var_wrk_string := to_char(round(((var_ytd_ty_val + var_ytg_fc_val) / (var_ytd_op_val + var_ytg_op_val)) * 100, 2),'FM9999990.00');
         elsif (var_ytd_ty_val + var_ytg_fc_val) = 0 and (var_ytd_op_val + var_ytg_op_val) = 0 then
            var_wrk_string := 'NF/NP';
         elsif (var_ytd_ty_val + var_ytg_fc_val) = 0 then
            var_wrk_string := 'NF';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YEE % Growth */
         /*-*/
         if (var_ytd_ty_val + var_ytg_fc_val) <> 0 and (var_ytd_ly_val + var_ytg_ly_val) <> 0 then
            var_wrk_string := to_char(round(((var_ytd_ty_val + var_ytg_fc_val) / (var_ytd_ly_val + var_ytg_ly_val)) * 100, 2),'FM9999990.00');
         elsif (var_ytd_ty_val + var_ytg_fc_val) = 0 and (var_ytd_ly_val + var_ytg_ly_val) = 0 then
            var_wrk_string := 'NS/NL';
         elsif (var_ytd_ty_val + var_ytg_fc_val) = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NL';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Create the detail row */
         /*-*/
         if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
            xlxml_object.SetRangeArray('B' || to_char(var_row_count,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990'),
                                       'B' || to_char(var_row_count,'FM999999990') || ':W' || to_char(var_row_count,'FM999999990'),
                                       xlxml_object.TYPE_DETAIL, -9, var_wrk_array);
         elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
            xlxml_object.SetRangeArray('B' || to_char(var_row_count,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990'),
                                       'B' || to_char(var_row_count,'FM999999990') || ':V' || to_char(var_row_count,'FM999999990'),
                                       xlxml_object.TYPE_DETAIL, -9, var_wrk_array);
         end if;

      end loop;
      close pld_sal_format12_c01;

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
         tblSummary(idx).ytd_ty_val := 0;
         tblSummary(idx).ytd_ly_val := 0;
         tblSummary(idx).ytd_op_val := 0;
         tblSummary(idx).ytd_fc_val := 0;
         tblSummary(idx).ytg_ly_val := 0;
         tblSummary(idx).ytg_op_val := 0;
         tblSummary(idx).ytg_fc_val := 0;
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
         /* Period/month values */
         /*-*/
         var_wrk_string := '"=subtotal(9,B' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,C' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':C' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,D' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':D' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,E' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':E' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,F' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':F' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,G' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':G' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,H' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':H' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,I' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':I' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,J' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':J' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,K' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':K' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,L' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':L' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,M' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':M' || to_char(var_row_count,'FM999999990') || ')"';
         if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
            var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,N' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':N' || to_char(var_row_count,'FM999999990') || ')"';
         end if;
         var_wrk_array := var_wrk_string;

         /*-*/
         /* YTD value */
         /*-*/
         if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
            var_wrk_string := '"=subtotal(9,O' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':O' || to_char(var_row_count,'FM999999990') || ')"';
         elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
            var_wrk_string := '"=subtotal(9,N' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':N' || to_char(var_row_count,'FM999999990') || ')"';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTD % Plan */
         /*-*/
         if tblSummary(idx).ytd_ty_val <> 0 and tblSummary(idx).ytd_op_val <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).ytd_ty_val / tblSummary(idx).ytd_op_val) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).ytd_ty_val = 0 and tblSummary(idx).ytd_op_val = 0 then
            var_wrk_string := 'NS/NP';
         elsif tblSummary(idx).ytd_ty_val = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTD % Growth */
         /*-*/
         if tblSummary(idx).ytd_ty_val <> 0 and tblSummary(idx).ytd_ly_val <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).ytd_ty_val / tblSummary(idx).ytd_ly_val) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).ytd_ty_val = 0 and tblSummary(idx).ytd_ly_val = 0 then
            var_wrk_string := 'NS/NL';
         elsif tblSummary(idx).ytd_ty_val = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NL';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTG value */
         /*-*/
         if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
            var_wrk_string := '"=subtotal(9,R' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':R' || to_char(var_row_count,'FM999999990') || ')"';
         elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
            var_wrk_string := '"=subtotal(9,Q' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':Q' || to_char(var_row_count,'FM999999990') || ')"';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTG % Plan */
         /*-*/
         if tblSummary(idx).ytg_fc_val <> 0 and tblSummary(idx).ytg_op_val <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).ytg_fc_val / tblSummary(idx).ytg_op_val) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).ytg_fc_val = 0 and tblSummary(idx).ytg_op_val = 0 then
            var_wrk_string := 'NF/NP';
         elsif tblSummary(idx).ytg_fc_val = 0 then
            var_wrk_string := 'NF';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTG % Growth */
         /*-*/
         if tblSummary(idx).ytg_fc_val <> 0 and tblSummary(idx).ytg_ly_val <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).ytg_fc_val / tblSummary(idx).ytg_ly_val) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).ytg_fc_val = 0 and tblSummary(idx).ytg_ly_val = 0 then
            var_wrk_string := 'NS/NL';
         elsif tblSummary(idx).ytg_fc_val = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NL';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YEE value */
         /*-*/
         if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
            var_wrk_string := '"=subtotal(9,U' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':U' || to_char(var_row_count,'FM999999990') || ')"';
         elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
            var_wrk_string := '"=subtotal(9,T' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':T' || to_char(var_row_count,'FM999999990') || ')"';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YEE % Plan */
         /*-*/
         if (tblSummary(idx).ytd_ty_val + tblSummary(idx).ytg_fc_val) <> 0 and (tblSummary(idx).ytd_op_val + tblSummary(idx).ytg_op_val) <> 0 then
            var_wrk_string := to_char(round(((tblSummary(idx).ytd_ty_val + tblSummary(idx).ytg_fc_val) / (tblSummary(idx).ytd_op_val + tblSummary(idx).ytg_op_val)) * 100, 2),'FM9999990.00');
         elsif (tblSummary(idx).ytd_ty_val + tblSummary(idx).ytg_fc_val) = 0 and (tblSummary(idx).ytd_op_val + tblSummary(idx).ytg_op_val) = 0 then
            var_wrk_string := 'NF/NP';
         elsif (tblSummary(idx).ytd_ty_val + tblSummary(idx).ytg_fc_val) = 0 then
            var_wrk_string := 'NF';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YEE % Growth */
         /*-*/
         if (tblSummary(idx).ytd_ty_val + tblSummary(idx).ytg_fc_val) <> 0 and (tblSummary(idx).ytd_ly_val + tblSummary(idx).ytg_ly_val) <> 0 then
            var_wrk_string := to_char(round(((tblSummary(idx).ytd_ty_val + tblSummary(idx).ytg_fc_val) / (tblSummary(idx).ytd_ly_val + tblSummary(idx).ytg_ly_val)) * 100, 2),'FM9999990.00');
         elsif (tblSummary(idx).ytd_ty_val + tblSummary(idx).ytg_fc_val) = 0 and (tblSummary(idx).ytd_ly_val + tblSummary(idx).ytg_ly_val) = 0 then
            var_wrk_string := 'NS/NL';
         elsif (tblSummary(idx).ytd_ty_val + tblSummary(idx).ytg_fc_val) = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NL';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Create the summary row */
         /*-*/
         if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
            xlxml_object.SetRangeArray('B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':B' || to_char(tblSummary(idx).saved_row,'FM999999990'),
                                       'B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':W' || to_char(tblSummary(idx).saved_row,'FM999999990'),
                                       xlxml_object.GetSummaryType(idx), -9, var_wrk_array);
         elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
            xlxml_object.SetRangeArray('B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':B' || to_char(tblSummary(idx).saved_row,'FM999999990'),
                                       'B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':V' || to_char(tblSummary(idx).saved_row,'FM999999990'),
                                       xlxml_object.GetSummaryType(idx), -9, var_wrk_array);
         end if;

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
         tblSummary(idx).ytd_ty_val := 0;
         tblSummary(idx).ytd_ly_val := 0;
         tblSummary(idx).ytd_op_val := 0;
         tblSummary(idx).ytd_fc_val := 0;
         tblSummary(idx).ytg_ly_val := 0;
         tblSummary(idx).ytg_op_val := 0;
         tblSummary(idx).ytg_fc_val := 0;

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
      if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
         if var_val_type = 'QTY' then
            xlxml_object.SetRangeFormat('B7:B' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('C7:C' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('D7:D' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('E7:E' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('F7:F' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('G7:G' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('H7:H' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('I7:I' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('J7:J' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('K7:K' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('L7:L' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('M7:M' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('N7:N' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('O7:O' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('R7:R' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('U7:U' || to_char(var_row_count,'FM999999990'), 0);
         elsif var_val_type = 'TON' then
            xlxml_object.SetRangeFormat('B7:B' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('C7:C' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('D7:D' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('E7:E' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('F7:F' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('G7:G' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('H7:H' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('I7:I' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('J7:J' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('K7:K' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('L7:L' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('M7:M' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('N7:N' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('O7:O' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('R7:R' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('U7:U' || to_char(var_row_count,'FM999999990'), 2);
         elsif var_val_type = 'BPS' then
            xlxml_object.SetRangeFormat('B7:B' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('C7:C' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('D7:D' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('E7:E' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('F7:F' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('G7:G' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('H7:H' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('I7:I' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('J7:J' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('K7:K' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('L7:L' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('M7:M' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('N7:N' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('O7:O' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('R7:R' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('U7:U' || to_char(var_row_count,'FM999999990'), 2);
         elsif var_val_type = 'GSV' then
            xlxml_object.SetRangeFormat('B7:B' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('C7:C' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('D7:D' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('E7:E' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('F7:F' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('G7:G' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('H7:H' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('I7:I' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('J7:J' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('K7:K' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('L7:L' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('M7:M' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('N7:N' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('O7:O' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('R7:R' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('U7:U' || to_char(var_row_count,'FM999999990'), 2);
         end if;
         xlxml_object.SetRangeFormat('P7:P' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('Q7:Q' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('S7:S' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('T7:T' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('V7:V' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('W7:W' || to_char(var_row_count,'FM999999990'), 2);
      elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
         if var_val_type = 'QTY' then
            xlxml_object.SetRangeFormat('B7:B' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('C7:C' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('D7:D' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('E7:E' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('F7:F' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('G7:G' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('H7:H' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('I7:I' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('J7:J' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('K7:K' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('L7:L' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('M7:M' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('N7:N' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('Q7:Q' || to_char(var_row_count,'FM999999990'), 0);
            xlxml_object.SetRangeFormat('T7:T' || to_char(var_row_count,'FM999999990'), 0);
         elsif var_val_type = 'TON' then
            xlxml_object.SetRangeFormat('B7:B' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('C7:C' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('D7:D' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('E7:E' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('F7:F' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('G7:G' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('H7:H' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('I7:I' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('J7:J' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('K7:K' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('L7:L' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('M7:M' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('N7:N' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('Q7:Q' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('T7:T' || to_char(var_row_count,'FM999999990'), 2);
         elsif var_val_type = 'BPS' then
            xlxml_object.SetRangeFormat('B7:B' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('C7:C' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('D7:D' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('E7:E' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('F7:F' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('G7:G' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('H7:H' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('I7:I' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('J7:J' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('K7:K' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('L7:L' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('M7:M' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('N7:N' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('Q7:Q' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('T7:T' || to_char(var_row_count,'FM999999990'), 2);
         elsif var_val_type = 'GSV' then
            xlxml_object.SetRangeFormat('B7:B' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('C7:C' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('D7:D' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('E7:E' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('F7:F' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('G7:G' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('H7:H' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('I7:I' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('J7:J' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('K7:K' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('L7:L' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('M7:M' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('N7:N' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('Q7:Q' || to_char(var_row_count,'FM999999990'), 2);
            xlxml_object.SetRangeFormat('T7:T' || to_char(var_row_count,'FM999999990'), 2);
         end if;
         xlxml_object.SetRangeFormat('O7:O' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('P7:P' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('R7:R' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('S7:S' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('U7:U' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('V7:V' || to_char(var_row_count,'FM999999990'), 2);
      end if;

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
      xlxml_object.SetRangeBorder('T7:T' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('U7:U' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('V7:V' || to_char(var_row_count,'FM999999990'));
      if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
         xlxml_object.SetRangeBorder('W7:W' || to_char(var_row_count,'FM999999990'));
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doBorder;

end mfjpln_sal_format12_excel02;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mfjpln_sal_format12_excel02 for pld_rep_app.mfjpln_sal_format12_excel02;
grant execute on mfjpln_sal_format12_excel02 to public;
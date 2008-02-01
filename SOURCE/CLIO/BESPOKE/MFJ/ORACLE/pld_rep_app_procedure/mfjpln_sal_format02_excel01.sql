/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_sal_format02_excel01                        */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : June 2003                                          */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_sal_format02_excel01 as

/**DESCRIPTION**
 YTD Performance Report - Invoice date aggregations.

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
 2. The material is ignored when there are no sales or no forecast and no inventory

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

end mfjpln_sal_format02_excel01;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_sal_format02_excel01 as

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
                             ytg_fc_val number(22,6),
                             act_ty_val number(22,6),
                             act_op_val number(22,6),
                             act_fc_val number(22,6));
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

      cursor pld_sal_format0200_c01 is 
         select pld_sal_format0200.extract_date,
                pld_sal_format0200.logical_date,
                pld_sal_format0200.current_YYYYPP,
                pld_sal_format0200.current_YYYYMM,
                pld_sal_format0200.extract_status,
                pld_sal_format0200.sales_date,
                pld_sal_format0200.sales_status,
                pld_sal_format0200.prd_asofdays,
                pld_sal_format0200.prd_percent,
                pld_sal_format0200.mth_asofdays,
                pld_sal_format0200.mth_percent
         from pld_sal_format0200;

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
      open pld_sal_format0200_c01;
      fetch pld_sal_format0200_c01 into var_extract_date,
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
      if pld_sal_format0200_c01%notfound then
         var_found := false;
      end if;
      close pld_sal_format0200_c01;
      if var_found = false then
         raise_application_error(-20000, 'Format control row PLD_SAL_FORMAT0200 not found');
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
      var_wrk_string := 'YTD Performance Report';
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
         var_wrk_string := var_wrk_string || ' - Quantity - Invoice Date';
      elsif var_val_type = 'TON' then
         var_wrk_string := var_wrk_string || ' - Tonnes - Invoice Date';
      elsif var_val_type = 'BPS' then
         var_wrk_string := var_wrk_string || ' - Base Price Value (Yen Millions) - Invoice Date';
      elsif var_val_type = 'GSV' then
         var_wrk_string := var_wrk_string || ' - Gross Sales Value (Yen Millions) - Invoice Date';
      end if;
      xlxml_object.SetRange('A1:A1', 'A1:M1', xlxml_object.GetHeadingType(1), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 2 */
      /*-*/
      var_wrk_string := var_extract_status || ' ' || var_sales_status;
      xlxml_object.SetRange('A2:A2', 'A2:M2', xlxml_object.TYPE_HEADING_SM, -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 3 */
      /*-*/
      var_wrk_string := 'Company: ' || var_company_desc;
      xlxml_object.SetRange('A3:A3', 'A3:M3', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);

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
      xlxml_object.SetRange('A4:A4', 'A4:M4', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 5 */
      /*-*/
      xlxml_object.SetRange('A5:A5', null, xlxml_object.GetHeadingType(7), -1, 0, false, null);
      xlxml_object.SetRange('B5:B5', 'B5:D5', xlxml_object.GetHeadingType(7), -2, 0, false, 'Actual');
      xlxml_object.SetRange('E5:E5', 'E5:G5', xlxml_object.GetHeadingType(7), -2, 0, false, 'YTD');
      xlxml_object.SetRange('H5:H5', 'H5:J5', xlxml_object.GetHeadingType(7), -2, 0, false, 'YTG');
      xlxml_object.SetRange('K5:K5', 'K5:M5', xlxml_object.GetHeadingType(7), -2, 0, false, 'YEE');

      /*-*/
      /* Report heading line 6 */
      /*-*/
      xlxml_object.SetRange('A6:A6', null, xlxml_object.GetHeadingType(7), -1, 0, false, 'Material Hierarchy');
      if var_for_type = 'PRD_BR' then
         var_wrk_string := 'Value' || chr(9) ||
                           '% BR' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %';
      elsif var_for_type = 'PRD_LE' then
         var_wrk_string := 'Value' || chr(9) ||
                           '% LE' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %';
      elsif var_for_type = 'MTH_BR' then
         var_wrk_string := 'Value' || chr(9) ||
                           '% BR' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %';
      elsif var_for_type = 'MTH_LE' then
         var_wrk_string := 'Value' || chr(9) ||
                           '% LE' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %' || chr(9) ||
                           'Value' || chr(9) ||
                           '% Plan' || chr(9) ||
                           'Growth %';
      end if;
      xlxml_object.SetRangeArray('B6:B6', 'B6:M6', xlxml_object.GetHeadingType(7), -2, var_wrk_string);

      /*-*/
      /* Report heading borders */
      /*-*/
      xlxml_object.SetHeadingBorder('B5:D5', 'ALL');
      xlxml_object.SetHeadingBorder('E5:G5', 'ALL');
      xlxml_object.SetHeadingBorder('H5:J5', 'ALL');
      xlxml_object.SetHeadingBorder('K5:M5', 'ALL');
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
   procedure doDetail(par_sap_bus_sgmnt_code in varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_grp_literal varchar2(2048 char);
      var_srt_literal varchar2(2048 char);
      var_for_literal varchar2(10 char);
      var_val_literal varchar2(10 char);
      var_ytd_ty_val number(22,6);
      var_ytd_ly_val number(22,6);
      var_ytd_op_val number(22,6);
      var_ytd_fc_val number(22,6);
      var_ytg_ly_val number(22,6);
      var_ytg_op_val number(22,6);
      var_ytg_fc_val number(22,6);
      var_act_ty_val number(22,6);
      var_act_op_val number(22,6);
      var_act_fc_val number(22,6);
      var_bus_sgmnt_desc varchar2(128 char);
      var_mkt_sgmnt_desc varchar2(128 char);
      var_supply_sgmnt_desc varchar2(128 char);
      var_brand_flag_desc varchar2(128 char);
      var_brand_sub_flag_desc varchar2(128 char);
      var_wrk_string varchar2(2048 char);
      var_wrk_array varchar2(4000 char);
      var_dynamic_sql varchar2(32767 char);
      type typCursor is ref cursor;
      pld_sal_format02_c01 typCursor;

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
                                    sum(t01.act_ty_val),
                                    sum(t01.act_op_val),
                                    sum(t01.act_fc_val),
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
                                            nvl(t12.act_ty_val,0) act_ty_val,
                                            nvl(t12.act_op_val,0) act_op_val,
                                            nvl(t12.act_fc_val,0) act_fc_val
                                       from pld_sal_format0201 t11, (select t22.sap_company_code sap_company_code,
                                                                            t22.sap_material_code sap_material_code,
                                                                            t22.ty_' || var_val_literal || ' act_ty_val,
                                                                            t22.op_' || var_val_literal || ' act_op_val,
                                                                            t22.' || var_for_literal || '_' || var_val_literal || ' act_fc_val
                                                                       from pld_sal_format0203 t22
                                                                      where t22.sap_company_code = :A
                                                                        and t22.billing_YYYYPP = :B) t12
                                      where t11.sap_company_code = t12.sap_company_code(+)
                                        and t11.sap_material_code = t12.sap_material_code(+)
                                        and t11.sap_company_code = :C) t01, material_dim t02
                              where t01.sap_material_code = t02.sap_material_code(+)
                                and t02.sap_bus_sgmnt_code = :D
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
                                    sum(t01.act_ty_val),
                                    sum(t01.act_op_val),
                                    sum(t01.act_fc_val),
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
                                            nvl(t12.act_ty_val,0) act_ty_val,
                                            nvl(t12.act_op_val,0) act_op_val,
                                            nvl(t12.act_fc_val,0) act_fc_val
                                       from pld_sal_format0202 t11, (select t22.sap_company_code sap_company_code,
                                                                            t22.sap_material_code sap_material_code,
                                                                            t22.ty_' || var_val_literal || ' act_ty_val,
                                                                            t22.op_' || var_val_literal || ' act_op_val,
                                                                            t22.' || var_for_literal || '_' || var_val_literal || ' act_fc_val
                                                                       from pld_sal_format0204 t22
                                                                      where t22.sap_company_code = :A
                                                                        and t22.billing_YYYYMM = :B) t12
                                      where t11.sap_company_code = t12.sap_company_code(+)
                                        and t11.sap_material_code = t12.sap_material_code(+)
                                        and t11.sap_company_code = :C) t01, material_dim t02
                              where t01.sap_material_code = t02.sap_material_code(+)
                                and t02.sap_bus_sgmnt_code = :D
                           group by ' || var_grp_literal || '
                           order by ' || var_srt_literal;
      end if;

      /*-*/
      /* Retrieve the detail rows */
      /*-*/
      if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
         open pld_sal_format02_c01 for var_dynamic_sql using var_sap_company_code, var_previous_YYYYPP, var_sap_company_code, par_sap_bus_sgmnt_code;
      elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
         open pld_sal_format02_c01 for var_dynamic_sql using var_sap_company_code, var_previous_YYYYMM, var_sap_company_code, par_sap_bus_sgmnt_code;
      end if;
      loop
         fetch pld_sal_format02_c01 into var_ytd_ty_val,
                                         var_ytd_ly_val,
                                         var_ytd_op_val,
                                         var_ytd_fc_val,
                                         var_ytg_ly_val,
                                         var_ytg_op_val,
                                         var_ytg_fc_val,
                                         var_act_ty_val,
                                         var_act_op_val,
                                         var_act_fc_val,
                                         var_bus_sgmnt_desc,
                                         var_mkt_sgmnt_desc,
                                         var_supply_sgmnt_desc,
                                         var_brand_flag_desc,
                                         var_brand_sub_flag_desc;
         if pld_sal_format02_c01%notfound then
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
            tblSummary(idx).act_ty_val := tblSummary(idx).act_ty_val + var_act_ty_val;
            tblSummary(idx).act_op_val := tblSummary(idx).act_op_val + var_act_op_val;
            tblSummary(idx).act_fc_val := tblSummary(idx).act_fc_val + var_act_fc_val;
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
         /* Actual value */
         /*-*/
         if var_val_type = 'QTY' then
            var_wrk_string := to_char(var_act_ty_val,'FM9999999999999999999990');
         elsif var_val_type = 'TON' then
            var_wrk_string := to_char(var_act_ty_val,'FM9999999999999990.000000');
         elsif var_val_type = 'BPS' then
            var_wrk_string := to_char(var_act_ty_val/1000000,'FM9999999999999990.000000');
         elsif var_val_type = 'GSV' then
            var_wrk_string := to_char(var_act_ty_val/1000000,'FM9999999999999990.000000');
         end if;
         var_wrk_array := var_wrk_string;

         /*-*/
         /* Actual % Forecast (BR/LE) */
         /*-*/
         if var_act_ty_val <> 0 and var_act_fc_val <> 0 then
            var_wrk_string := to_char(round((var_act_ty_val / var_act_fc_val) * 100, 2),'FM9999990.00');
         elsif var_act_ty_val = 0 and var_act_fc_val = 0 then
            var_wrk_string := 'NS/NF';
         elsif var_act_ty_val = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NF';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Actual % Plan */
         /*-*/
         if var_act_ty_val <> 0 and var_act_op_val <> 0 then
            var_wrk_string := to_char(round((var_act_ty_val / var_act_op_val) * 100, 2),'FM9999990.00');
         elsif var_act_ty_val = 0 and var_act_op_val = 0 then
            var_wrk_string := 'NS/NP';
         elsif var_act_ty_val = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

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
         xlxml_object.SetRangeArray('B' || to_char(var_row_count,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990'),
                                    'B' || to_char(var_row_count,'FM999999990') || ':M' || to_char(var_row_count,'FM999999990'),
                                    xlxml_object.TYPE_DETAIL, -9, var_wrk_array);

      end loop;
      close pld_sal_format02_c01;

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
         tblSummary(idx).act_ty_val := 0;
         tblSummary(idx).act_op_val := 0;
         tblSummary(idx).act_fc_val := 0;
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
         /* Actual value */
         /*-*/
         var_wrk_string := '"=subtotal(9,B' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_string;

         /*-*/
         /* Actual % Forecast (BR/LE) */
         /*-*/
         if tblSummary(idx).act_ty_val <> 0 and tblSummary(idx).act_fc_val <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).act_ty_val / tblSummary(idx).act_fc_val) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).act_ty_val = 0 and tblSummary(idx).act_fc_val = 0 then
            var_wrk_string := 'NS/NF';
         elsif tblSummary(idx).act_ty_val = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NF';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Actual % Plan */
         /*-*/
         if tblSummary(idx).act_ty_val <> 0 and tblSummary(idx).act_op_val <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).act_ty_val / tblSummary(idx).act_op_val) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).act_ty_val = 0 and tblSummary(idx).act_op_val = 0 then
            var_wrk_string := 'NS/NP';
         elsif tblSummary(idx).act_ty_val = 0 then
            var_wrk_string := 'NS';
         else
            var_wrk_string := 'NP';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* YTD value */
         /*-*/
         var_wrk_string := '"=subtotal(9,E' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':E' || to_char(var_row_count,'FM999999990') || ')"';
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
         var_wrk_string := '"=subtotal(9,H' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':H' || to_char(var_row_count,'FM999999990') || ')"';
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
         var_wrk_string := '"=subtotal(9,K' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':K' || to_char(var_row_count,'FM999999990') || ')"';
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
         xlxml_object.SetRangeArray('B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':B' || to_char(tblSummary(idx).saved_row,'FM999999990'),
                                    'B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':M' || to_char(tblSummary(idx).saved_row,'FM999999990'),
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
         /* Reset the summary control values */
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
         tblSummary(idx).act_ty_val := 0;
         tblSummary(idx).act_op_val := 0;
         tblSummary(idx).act_fc_val := 0;

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
      if var_val_type = 'QTY' then
         xlxml_object.SetRangeFormat('B7:B' || to_char(var_row_count,'FM999999990'), 0);
         xlxml_object.SetRangeFormat('E7:E' || to_char(var_row_count,'FM999999990'), 0);
         xlxml_object.SetRangeFormat('H7:H' || to_char(var_row_count,'FM999999990'), 0);
         xlxml_object.SetRangeFormat('K7:K' || to_char(var_row_count,'FM999999990'), 0);
      elsif var_val_type = 'TON' then
         xlxml_object.SetRangeFormat('B7:B' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('E7:E' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('H7:H' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('K7:K' || to_char(var_row_count,'FM999999990'), 2);
      elsif var_val_type = 'BPS' then
         xlxml_object.SetRangeFormat('B7:B' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('E7:E' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('H7:H' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('K7:K' || to_char(var_row_count,'FM999999990'), 2);
      elsif var_val_type = 'GSV' then
         xlxml_object.SetRangeFormat('B7:B' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('E7:E' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('H7:H' || to_char(var_row_count,'FM999999990'), 2);
         xlxml_object.SetRangeFormat('K7:K' || to_char(var_row_count,'FM999999990'), 2);
      end if;
      xlxml_object.SetRangeFormat('C7:C' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('D7:D' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('F7:F' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('G7:G' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('I7:I' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('J7:J' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('L7:L' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('M7:M' || to_char(var_row_count,'FM999999990'), 2);

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

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doBorder;

end mfjpln_sal_format02_excel01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mfjpln_sal_format02_excel01 for pld_rep_app.mfjpln_sal_format02_excel01;
grant execute on mfjpln_sal_format02_excel01 to public;
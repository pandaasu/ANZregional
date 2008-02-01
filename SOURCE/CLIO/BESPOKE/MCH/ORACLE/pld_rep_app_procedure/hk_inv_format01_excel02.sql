/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : HK Planning Reports                                */
/* Package : hk_inv_format01_excel02                            */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : June 2003                                          */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_inv_format01_excel02 as

/**DESCRIPTION**
 Finished Goods Inventory Shortage Exception Report - Invoice date aggregations.

 **PARAMETERS**
 par_sap_company_code = SAP company code (mandatory)
 par_sap_bus_sgmnt_code = SAP business segment code (mandatory)
 par_for_type = Forecast type (mandatory)
                  PRD_BR = Period BR forecast
                  PRD_RB = Period ROB forecast
                  MTH_BR = Month BR forecast
                  MTH_RB = Month ROB forecast
 par_print_xml = Print xml data string (optional)
                   Format = SetPrintOverride Orientation='1' FitWidthPages='1' Zoom='0'
                   Orientation = 1(Portrait) 2(Landscape)
                   FitWidthPages = number 0 to 999
                   Zoom = number 0 to 100 (overrides FitWidthPages)

 **NOTES**
 1. Intransit is sap_plant_code = 'HK00' (hard-coded)
 2. Finished goods is sap_material_type_code = 'FERT' and material_type_flag_sfp != 'Y' (hard-coded)
 3. Not Applicable descriptions are replaced based on the SAP codes (hard-coded)

 **LEGEND**
 NS = No sales
 NF = No forecast in current period or month
 FF = No forecast in current period or month but forecast in future period or month

**/
   
   /*-*/
   /* Public declarations */
   /*-*/
   function main(par_sap_company_code in varchar2,
                 par_sap_bus_sgmnt_code in varchar2,
                 par_for_type in varchar2,
                 par_print_xml in varchar2) return varchar2;

end hk_inv_format01_excel02;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_inv_format01_excel02 as

   /*-*/
   /* Private global declarations */
   /*-*/
   procedure doDetail;
   procedure clearReport;
   procedure doFormat;
   procedure doBorder;

   /*-*/
   /* Private global variables */
   /*-*/
   var_row_count number(15,0);
   var_details boolean;
   var_sap_company_code varchar2(6 char);
   var_sap_bus_sgmnt_code varchar2(4 char);
   var_for_type varchar2(6 char);
   var_stock_short_cover number(2,0);
   var_lst_column varchar2(2 char);
   type rcdWarehouse is record(sap_plant_code varchar2(4 char), column_id varchar2(2 char));
   type typWarehouse is table of rcdWarehouse index by binary_integer;
   tblWarehouse typWarehouse;

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
      var_inventory_date date;
      var_inventory_status varchar2(256 char);
      var_sales_date date;
      var_sales_status varchar2(256 char);
      var_prd_asofdays varchar2(128 char);
      var_prd_percent number(5,2);
      var_mth_asofdays varchar2(128 char);
      var_mth_percent number(5,2);
      var_company_desc varchar2(60 char);
      var_bus_sgmnt_desc varchar2(30 char);
      var_sap_plant_code varchar2(4 char);
      var_found boolean;
      var_wrk_count number(15,0);
      var_wrk_column number(4,0);
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

      cursor pld_inv_format0100_c01 is 
         select pld_inv_format0100.extract_date,
                pld_inv_format0100.logical_date,
                pld_inv_format0100.current_YYYYPP,
                pld_inv_format0100.current_YYYYMM,
                pld_inv_format0100.extract_status,
                pld_inv_format0100.inventory_date,
                pld_inv_format0100.inventory_status,
                pld_inv_format0100.sales_date,
                pld_inv_format0100.sales_status,
                pld_inv_format0100.prd_asofdays,
                pld_inv_format0100.prd_percent,
                pld_inv_format0100.mth_asofdays,
                pld_inv_format0100.mth_percent
         from pld_inv_format0100
         where pld_inv_format0100.sap_company_code = var_sap_company_code;

      cursor pld_inv_format0102_c01 is 
         select pld_inv_format0102.sap_plant_code
         from pld_inv_format0102, material_dim
         where pld_inv_format0102.sap_material_code = material_dim.sap_material_code(+)
           and material_dim.sap_bus_sgmnt_code = var_sap_bus_sgmnt_code
           and material_dim.sap_material_type_code = 'FERT'
           and material_dim.material_type_flag_sfp != 'Y'
           and pld_inv_format0102.sap_company_code = var_sap_company_code
           and pld_inv_format0102.inv_sal_qty <> 0
         group by pld_inv_format0102.sap_plant_code
         order by pld_inv_format0102.sap_plant_code asc;

      cursor pld_rep_parameter_c01 is 
         select to_number(par_value)
           from pld_rep_parameter
          where par_group = 'STOCK_SHORT_COVER'
            and par_code = var_sap_bus_sgmnt_code;

      cursor pld_rep_parameter_c02 is 
         select to_number(par_value)
           from pld_rep_parameter
          where par_group = 'STOCK_SHORT_COVER'
            and par_code = 'DEFAULT';

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
      open pld_inv_format0100_c01;
      fetch pld_inv_format0100_c01 into var_extract_date,
                                        var_logical_date,
                                        var_current_YYYYPP,
                                        var_current_YYYYMM,
                                        var_extract_status,
                                        var_inventory_date,
                                        var_inventory_status,
                                        var_sales_date,
                                        var_sales_status,
                                        var_prd_asofdays,
                                        var_prd_percent,
                                        var_mth_asofdays,
                                        var_mth_percent;
      if pld_inv_format0100_c01%notfound then
         var_found := false;
      end if;
      close pld_inv_format0100_c01;
      if var_found = false then
         raise_application_error(-20000, 'Format control row PLD_INV_FORMAT0100 not found');
      end if;

      /*-*/
      /* Retrieve the stock short cover parameter */
      /*-*/
      open pld_rep_parameter_c01;
      fetch pld_rep_parameter_c01 into var_stock_short_cover;
      if pld_rep_parameter_c01%notfound then
         open pld_rep_parameter_c02;
         fetch pld_rep_parameter_c02 into var_stock_short_cover;
         if pld_rep_parameter_c02%notfound then
            var_stock_short_cover := 2;
         end if;
         close pld_rep_parameter_c02;
      end if;
      close pld_rep_parameter_c01;

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
      /* Retrieve the warehouse data */
      /*-*/
      var_wrk_count := 0;
      var_wrk_column := 14;
      var_lst_column := 'N';
      open pld_inv_format0102_c01;
      loop
         fetch pld_inv_format0102_c01 into var_sap_plant_code;
         if pld_inv_format0102_c01%notfound then
            exit;
         end if;
         var_wrk_count := var_wrk_count + 1;
         var_wrk_column := var_wrk_column + 1;
         tblWarehouse(var_wrk_count).sap_plant_code := var_sap_plant_code;
         tblWarehouse(var_wrk_count).column_id := xlxml_object.GetColumnId(var_wrk_column);
         var_lst_column := tblWarehouse(var_wrk_count).column_id;
      end loop;
      close pld_inv_format0102_c01;

      /*-*/
      /* Report start */
      /*-*/
      xlxml_object.BeginReport;

      /*-*/
      /* Report heading line 1 */
      /*-*/
      if var_for_type = 'PRD_BR' then
         var_wrk_string := 'Finished Goods Inventory Shortage Exceptions Report (less than ' || to_char(var_stock_short_cover,'FM90') || ' weeks cover) - Period - BR Forecast (HK$ Thousands)';
      elsif var_for_type = 'PRD_RB' then
         var_wrk_string := 'Finished Goods Inventory Shortage Exceptions Report (less than ' || to_char(var_stock_short_cover,'FM90') || ' weeks cover) - Period - ROB Forecast (HK$ Thousands)';
      elsif var_for_type = 'MTH_BR' then
         var_wrk_string := 'Finished Goods Inventory Shortage Exceptions Report (less than ' || to_char(var_stock_short_cover,'FM90') || ' weeks cover) - Month - BR Forecast (HK$ Thousands)';
      elsif var_for_type = 'MTH_RB' then
         var_wrk_string := 'Finished Goods Inventory Shortage Exceptions Report (less than ' || to_char(var_stock_short_cover,'FM90') || ' weeks cover) - Month - ROB Forecast (HK$ Thousands)';
      end if;
      xlxml_object.SetRange('A1:A1', 'A1:' || var_lst_column || '1', xlxml_object.GetHeadingType(1), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 2 */
      /*-*/
      var_wrk_string := var_extract_status || ' ' || var_inventory_status || ' ' || var_sales_status;
      xlxml_object.SetRange('A2:A2', 'A2:' || var_lst_column || '2', xlxml_object.TYPE_HEADING_SM, -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 3 */
      /*-*/
      var_wrk_string := 'Company: ' || var_company_desc || ' Business Segment: ' || var_bus_sgmnt_desc;
      xlxml_object.SetRange('A3:A3', 'A3:' || var_lst_column || '3', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 4 */
      /*-*/
      if var_for_type = 'PRD_BR' then
         var_wrk_string := var_prd_asofdays;
      elsif var_for_type = 'PRD_RB' then
         var_wrk_string := var_prd_asofdays;
      elsif var_for_type = 'MTH_BR' then
         var_wrk_string := var_mth_asofdays;
      elsif var_for_type = 'MTH_RB' then
         var_wrk_string := var_mth_asofdays;
      end if;
      xlxml_object.SetRange('A4:A4', 'A4:' || var_lst_column || '4', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 5 */
      /*-*/
      xlxml_object.SetRangeType('A5:C5', xlxml_object.GetHeadingType(2));
      xlxml_object.SetRange('D5:D5', 'D5:G5', xlxml_object.GetHeadingType(2), -2, 0, false, 'Total Inventory');
      xlxml_object.SetRange('H5:H5', 'H5:' || var_lst_column || '5', xlxml_object.GetHeadingType(2), -2, 0, false, 'Warehouses');

      /*-*/
      /* Report heading line 6 */
      /*-*/
      xlxml_object.SetRangeType('A6:A6', xlxml_object.GetHeadingType(7));
      xlxml_object.SetRange('B6:B6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Forecast');
      xlxml_object.SetRange('C6:C6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Progress %');
      xlxml_object.SetRange('D6:D6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Total');
      xlxml_object.SetRange('E6:E6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Total');
      xlxml_object.SetRange('F6:F6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Intransit');
      xlxml_object.SetRange('G6:G6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Onshore');
      xlxml_object.SetRange('H6:H6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Total');
      xlxml_object.SetRange('I6:I6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Total');
      xlxml_object.SetRange('J6:J6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Held');
      xlxml_object.SetRange('K6:K6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Unknown');
      xlxml_object.SetRange('L6:L6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Ageing');
      xlxml_object.SetRange('M6:M6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Saleable');
      xlxml_object.SetRange('N6:N6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Saleable');

      /*-*/
      /* Report heading line 7 */
      /*-*/
      xlxml_object.SetRange('A7:A7', null, xlxml_object.GetHeadingType(7), -1, 0, false, 'Material Hierarchy');
      xlxml_object.SetRange('B7:B7', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Quantity');
      xlxml_object.SetRange('C7:C7', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Forecast');
      xlxml_object.SetRange('D7:D7', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Value');
      xlxml_object.SetRange('E7:E7', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Quantity');
      xlxml_object.SetRange('F7:F7', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Quantity');
      xlxml_object.SetRange('G7:G7', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Cover');
      xlxml_object.SetRange('H7:H7', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Value');
      xlxml_object.SetRange('I7:I7', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Quantity');
      xlxml_object.SetRange('J7:J7', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Quantity');
      xlxml_object.SetRange('K7:K7', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Quantity');
      xlxml_object.SetRange('L7:L7', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Quantity');
      xlxml_object.SetRange('M7:M7', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Quantity');
      xlxml_object.SetRange('N7:N7', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Cover');

      /*-*/
      /* Report heading line 6/7 - Warehouses */
      /*-*/
      for idx in 1..tblWarehouse.count loop
         xlxml_object.SetRange(tblWarehouse(idx).column_id || '6:' || tblWarehouse(idx).column_id || '6', null,
                               xlxml_object.GetHeadingType(7), -2, 0, false, tblWarehouse(idx).sap_plant_code);
         xlxml_object.SetRange(tblWarehouse(idx).column_id || '7:' || tblWarehouse(idx).column_id || '7', null,
                               xlxml_object.GetHeadingType(7), -2, 0, false, 'Saleable');
      end loop;
      xlxml_object.SetRangeType('N6:N7', xlxml_object.TYPE_HEADING_HI);

      /*-*/
      /* Report heading borders */
      /*-*/
      xlxml_object.SetHeadingBorder('D5:G5', 'ALL');
      xlxml_object.SetHeadingBorder('H5:' || var_lst_column || '5', 'ALL');
      xlxml_object.SetHeadingBorder('A6:A7', 'TLR');
      xlxml_object.SetHeadingBorder('B6:B7', 'TLR');
      xlxml_object.SetHeadingBorder('C6:C7', 'TLR');
      xlxml_object.SetHeadingBorder('D6:D7', 'TLR');
      xlxml_object.SetHeadingBorder('E6:E7', 'TLR');
      xlxml_object.SetHeadingBorder('F6:F7', 'TLR');
      xlxml_object.SetHeadingBorder('G6:G7', 'TLR');
      xlxml_object.SetHeadingBorder('H6:H7', 'TLR');
      xlxml_object.SetHeadingBorder('I6:I7', 'TLR');
      xlxml_object.SetHeadingBorder('J6:J7', 'TLR');
      xlxml_object.SetHeadingBorder('K6:K7', 'TLR');
      xlxml_object.SetHeadingBorder('L6:L7', 'TLR');
      xlxml_object.SetHeadingBorder('M6:M7', 'TLR');
      xlxml_object.SetHeadingBorder('N6:N7', 'TLR');
      for idx in 1..tblWarehouse.count loop
         xlxml_object.SetHeadingBorder(tblWarehouse(idx).column_id || '6:' || tblWarehouse(idx).column_id || '7', 'TLR');
      end loop;

      /*-*/
      /* Initialise the row count */
      /*-*/
      var_row_count := 7;

      /*-*/
      /* Process the report detail */
      /*-*/
      doDetail;

      /*-*/
      /* Report borders when details exist */
      /*-*/
      if var_details = true then
         doFormat;
         doBorder;
         xlxml_object.SetFreezeCell('B8');
      end if;

      /*-*/
      /* Report when no details found */
      /*-*/
      if var_details = false then
         xlxml_object.SetRange('A8:A8', 'A8:' || var_lst_column || '8', xlxml_object.TYPE_DETAIL, -2, 0, false, 'NO EXCEPTIONS EXIST');
         xlxml_object.SetRangeBorder('A8:' || var_lst_column || '8');
      end if;

      /*-*/
      /* Report print settings */
      /*-*/
      xlxml_object.SetPrintData('$1:$7', '$A:$A', 2, 1, 0);
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
      var_typ_literal varchar2(256 char);
      var_for_literal varchar2(256 char);
      var_wrk_billed_qty number;
      var_wrk_fc_qty number;
      var_wrk_ft_qty number;
      var_wrk_tot_value number;
      var_wrk_tot_qty number;
      var_wrk_int_qty number;
      var_wrk_ons_cover number;
      var_wrk_war_value number;
      var_wrk_war_qty number;
      var_wrk_hld_qty number;
      var_wrk_unk_qty number;
      var_wrk_age_qty number;
      var_wrk_sal_qty number;
      var_wrk_sal_cover number;
      var_sap_material_code varchar2(18 char);
      var_material_desc_en varchar2(40 char);
      var_sort_desc varchar2(60 char);
      var_sap_plant_code varchar2(4 char);
      var_war_inv_sal_qty number;
      var_wrk_string varchar2(2048 char);
      var_wrk_array varchar2(4000 char);
      var_dynamic_sql varchar2(32767 char);
      var_found boolean;
      type typCursor is ref cursor;
      pld_inv_format0101_c01 typCursor;

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor pld_inv_format0102_c01 is 
         select pld_inv_format0102.sap_plant_code,
                pld_inv_format0102.inv_sal_qty
         from pld_inv_format0102
         where pld_inv_format0102.sap_company_code = var_sap_company_code
           and pld_inv_format0102.sap_material_code = var_sap_material_code
         order by pld_inv_format0102.sap_plant_code asc;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the type and forecast literals */
      /*-*/
      if var_for_type = 'PRD_BR' then
         var_typ_literal := 'prd';
         var_for_literal := 'br';
      elsif var_for_type = 'PRD_RB' then
         var_typ_literal := 'prd';
         var_for_literal := 'rb';
      elsif var_for_type = 'MTH_BR' then
         var_typ_literal := 'mth';
         var_for_literal := 'br';
      elsif var_for_type = 'MTH_RB' then
         var_typ_literal := 'mth';
         var_for_literal := 'rb';
      end if;

      /*-*/
      /* Initialise the detail query */
      /*-*/
      var_dynamic_sql := 'select t01.' || var_typ_literal || '_billed_qty,
                                 t01.' || var_typ_literal || '_' || var_for_literal || '_qty,
                                 t01.' || var_typ_literal || '_fut_' || var_for_literal || '_qty,
                                 t01.inv_tot_value,
                                 t01.inv_tot_qty,
                                 t01.inv_int_qty,
                                 t01.inv_' || var_typ_literal || '_' || var_for_literal || '_ons_cover,
                                 t01.inv_war_value,
                                 t01.inv_war_qty,
                                 t01.inv_hld_qty,
                                 t01.inv_unk_qty,
                                 t01.inv_age_qty,
                                 t01.inv_sal_qty,
                                 t01.inv_' || var_typ_literal || '_' || var_for_literal || '_sal_cover,
                                 t02.sap_material_code,
                                 t02.material_desc_en,
                                 t02.material_desc_en || t02.sap_material_code as sort_desc
                            from pld_inv_format0101 t01, material_dim t02
                           where t01.sap_material_code = t02.sap_material_code(+)
                             and t01.sap_company_code = :A
                             and t02.sap_bus_sgmnt_code = :B
                             and t02.sap_material_type_code = ''FERT''
                             and t02.material_type_flag_sfp != ''Y''
                             and (t01.' || var_typ_literal || '_' || var_for_literal || '_qty <> 0 or
                                  t01.' || var_typ_literal || '_fut_' || var_for_literal || '_qty <> 0)
                             and t01.inv_' || var_typ_literal || '_' || var_for_literal || '_sal_cover < :C
                         order by t01.inv_' || var_typ_literal || '_' || var_for_literal || '_sal_cover asc,
                                  sort_desc asc';

      /*-*/
      /* Retrieve the detail rows */
      /*-*/
      open pld_inv_format0101_c01 for var_dynamic_sql using var_sap_company_code, var_sap_bus_sgmnt_code, var_stock_short_cover;
      loop
         fetch pld_inv_format0101_c01 into var_wrk_billed_qty,
                                           var_wrk_fc_qty,
                                           var_wrk_ft_qty,
                                           var_wrk_tot_value,
                                           var_wrk_tot_qty,
                                           var_wrk_int_qty,
                                           var_wrk_ons_cover,
                                           var_wrk_war_value,
                                           var_wrk_war_qty,
                                           var_wrk_hld_qty,
                                           var_wrk_unk_qty,
                                           var_wrk_age_qty,
                                           var_wrk_sal_qty,
                                           var_wrk_sal_cover,
                                           var_sap_material_code,
                                           var_material_desc_en,
                                           var_sort_desc;
         if pld_inv_format0101_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Set the control information */
         /*-*/
         var_details := true;
         var_row_count := var_row_count + 1;

         /*-*/
         /* Detail description */
         /*-*/
         xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                               null, xlxml_object.TYPE_DETAIL, -1, 0, false, '(' || var_sap_material_code || ') ' || var_material_desc_en);

         /*-*/
         /* Detail forecast quantity */
         /*-*/
         var_wrk_array := to_char(var_wrk_fc_qty,'FM9999999999999999999990');

         /*-*/
         /* Detail progress % */
         /*-*/
         if var_wrk_billed_qty <> 0 and var_wrk_fc_qty <> 0 then
            var_wrk_string := to_char(round((var_wrk_billed_qty / var_wrk_fc_qty) * 100, 2),'FM9999990.00');
         elsif var_wrk_billed_qty = 0 and var_wrk_fc_qty = 0 then
            if var_wrk_ft_qty = 0 then
               var_wrk_string := 'NS/NF';
            else
               var_wrk_string := 'NS/FF';
            end if;
         elsif var_wrk_billed_qty = 0 then
            var_wrk_string := 'NS';
         elsif var_wrk_ft_qty = 0 then
            var_wrk_string := 'NF';
         else
            var_wrk_string := 'FF';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Detail inventory */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_tot_value/1000,'FM9999999999999990.00000');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_tot_qty,'FM9999999999999999999990');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_int_qty,'FM9999999999999999999990');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_ons_cover,'FM9999990.00');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_war_value/1000,'FM9999999999999990.00000');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_war_qty,'FM9999999999999999999990');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_hld_qty,'FM9999999999999999999990');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_unk_qty,'FM9999999999999999999990');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_age_qty,'FM9999999999999999999990');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_sal_qty,'FM9999999999999999999990');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_sal_cover,'FM9999990.00');

         /*-*/
         /* Detail warehouse saleable cases */
         /*-*/
         var_found := false;
         open pld_inv_format0102_c01;
         loop
            fetch pld_inv_format0102_c01 into var_sap_plant_code,
                                              var_war_inv_sal_qty;
            if pld_inv_format0102_c01%notfound then
               exit;
            end if;
            var_found := true;
            for idx in 1..tblWarehouse.count loop
               if tblWarehouse(idx).sap_plant_code = var_sap_plant_code then
                  var_wrk_array := var_wrk_array || chr(9) || to_char(var_war_inv_sal_qty,'FM9999999999999999999990');
                  exit;
               end if;
            end loop;
         end loop;
         close pld_inv_format0102_c01;
         if var_found = false then
            for idx in 1..tblWarehouse.count loop
               var_wrk_array := var_wrk_array || chr(9) || '0';
            end loop;
         end if;

         /*-*/
         /* Create the detail row */
         /*-*/
         xlxml_object.SetRangeArray('B' || to_char(var_row_count,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990'),
                                    'B' || to_char(var_row_count,'FM999999990') || ':' || var_lst_column || to_char(var_row_count,'FM999999990'),
                                    xlxml_object.TYPE_DETAIL, -9, var_wrk_array);

      end loop;
      close pld_inv_format0101_c01;

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
      var_row_count := 0;
      var_details := false;

      /*-*/
      /* Clear the warehouse array */
      /*-*/
      tblWarehouse.Delete;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clearReport;

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
      xlxml_object.SetRangeFormat('B8:B' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('C8:C' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('D8:D' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('E8:E' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('F8:F' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('G8:G' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('H8:H' || to_char(var_row_count,'FM999999990'), 2);
      xlxml_object.SetRangeFormat('I8:I' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('J8:J' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('K8:K' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('L8:L' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('M8:M' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('N8:N' || to_char(var_row_count,'FM999999990'), 2);
      for idx in 1..tblWarehouse.count loop
         xlxml_object.SetRangeFormat(tblWarehouse(idx).column_id || '8:' || tblWarehouse(idx).column_id || to_char(var_row_count,'FM999999990'), 0);
      end loop;

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
      /* Report data borders */
      /*-*/
      xlxml_object.SetRangeBorder('A8:A' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('B8:B' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('C8:C' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('D8:D' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('E8:E' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('F8:F' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('G8:G' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('H8:H' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('I8:I' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('J8:J' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('K8:K' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('L8:L' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('M8:M' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('N8:N' || to_char(var_row_count,'FM999999990'));
      for idx in 1..tblWarehouse.count loop
         xlxml_object.SetRangeBorder(tblWarehouse(idx).column_id || '8:' || tblWarehouse(idx).column_id || to_char(var_row_count,'FM999999990'));
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doBorder;

end hk_inv_format01_excel02;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_inv_format01_excel02 for pld_rep_app.hk_inv_format01_excel02;
grant execute on hk_inv_format01_excel02 to public;
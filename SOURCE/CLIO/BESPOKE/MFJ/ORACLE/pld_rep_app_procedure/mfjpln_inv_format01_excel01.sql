/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_inv_format01_excel01                        */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : June 2003                                          */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_inv_format01_excel01 as

/**DESCRIPTION**
 Standard Inventory Report - Invoice date aggregations.

 **PARAMETERS**
 par_sap_company_code = SAP company code (mandatory)
 par_sap_bus_sgmnt_code = SAP business segment code (mandatory)
 par_for_type = Forecast type (mandatory)
                  PRD_BR = Period BR forecast
                  PRD_LE = Period LE forecast
                  MTH_BR = Month BR forecast
                  MTH_LE = Month LE forecast
 par_inv_type = Inventory type (mandatory)
                  F = Finished goods
                  B = Bulk
 par_print_xml = Print xml data string (optional)
                   Format = SetPrintOverride Orientation='1' FitWidthPages='1' Zoom='0'
                   Orientation = 1(Portrait) 2(Landscape)
                   FitWidthPages = number 0 to 999
                   Zoom = number 0 to 100 (overrides FitWidthPages)

 **NOTES**
 1. Intransit is sap_plant_code = 'JP01' (hard-coded)
 2. Finished goods is sap_material_type_code = 'FERT' and material_type_flag_sfp != 'Y' (hard-coded)
 3. Bulk is sap_material_type_code = 'ROH' or (sap_material_type_code = 'FERT' and material_type_flag_sfp = 'Y') (hard-coded)
 4. NOT APPLICABLE descriptions are replaced based on the SAP codes (hard-coded)
 5. The doCover procedure must be synchronised with mfjpln_inv_format01_extract cover calculation
 6. A different sort is used for each business segment (hard-coded)

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
                 par_inv_type in varchar2,
                 par_print_xml in varchar2) return varchar2;

end mfjpln_inv_format01_excel01;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_inv_format01_excel01 as

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
   procedure doAccumulate(par_sap_material_code in varchar2);
   procedure doCover(par_summary in number);

   /*-*/
   /* Private global variables */
   /*-*/
   SUMMARY_MAX number(2,0) := 6;
   var_sum_level number(2,0);
   var_row_count number(15,0);
   var_details boolean;
   var_sap_company_code varchar2(6 char);
   var_sap_bus_sgmnt_code varchar2(4 char);
   var_for_type varchar2(6 char);
   var_inv_type varchar2(1 char);
   var_lst_column varchar2(2 char);
   type rcdSummary is record(current_value varchar2(256 char),
                             saved_value varchar2(256 char),
                             saved_row number(9,0),
                             description varchar2(128 char),
                             wrk_billed_qty number(22,0),
                             wrk_fc_qty number(22,0),
                             wrk_ft_qty number(22,0),
                             wrk_ons_qty number(22,3),
                             wrk_ons_cover number(9,2),
                             wrk_sal_qty number(22,3),
                             wrk_sal_cover number(9,2));
   type typSummary is table of rcdSummary index by binary_integer;
   tblSummary typSummary;
   type rcdWarehouse is record(sap_plant_code varchar2(4 char), column_id varchar2(2 char));
   type typWarehouse is table of rcdWarehouse index by binary_integer;
   tblWarehouse typWarehouse;

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_sap_company_code in varchar2,
                 par_sap_bus_sgmnt_code in varchar2,
                 par_for_type in varchar2,
                 par_inv_type in varchar2,
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
      var_sales_status varchar2(256);
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
         from pld_inv_format0100;

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

      cursor pld_inv_format0102_c02 is 
         select pld_inv_format0102.sap_plant_code
         from pld_inv_format0102, material_dim
         where pld_inv_format0102.sap_material_code = material_dim.sap_material_code(+)
           and material_dim.sap_bus_sgmnt_code = var_sap_bus_sgmnt_code
           and (material_dim.sap_material_type_code = 'ROH' or
                (material_dim.sap_material_type_code = 'FERT' and material_dim.material_type_flag_sfp = 'Y'))
           and pld_inv_format0102.sap_company_code = var_sap_company_code
           and pld_inv_format0102.inv_sal_qty <> 0
         group by pld_inv_format0102.sap_plant_code
         order by pld_inv_format0102.sap_plant_code asc;

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
      var_inv_type := par_inv_type;

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
      /* Adjust the summary maximum for finished goods */
      /*-*/
      if var_inv_type = 'F' then
         SUMMARY_MAX := 7;
      end if;

      /*-*/
      /* Retrieve the warehouse data */
      /*-*/
      var_wrk_count := 0;
      var_wrk_column := 14;
      var_lst_column := 'N';
      if var_inv_type = 'F' then
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
      else
         open pld_inv_format0102_c02;
         loop
            fetch pld_inv_format0102_c02 into var_sap_plant_code;
            if pld_inv_format0102_c02%notfound then
               exit;
            end if;
            var_wrk_count := var_wrk_count + 1;
            var_wrk_column := var_wrk_column + 1;
            tblWarehouse(var_wrk_count).sap_plant_code := var_sap_plant_code;
            tblWarehouse(var_wrk_count).column_id := xlxml_object.GetColumnId(var_wrk_column);
            var_lst_column := tblWarehouse(var_wrk_count).column_id;
         end loop;
         close pld_inv_format0102_c02;
      end if;

      /*-*/
      /* Report start */
      /*-*/
      xlxml_object.BeginReport;

      /*-*/
      /* Report heading line 1 */
      /*-*/
      if var_for_type = 'PRD_BR' then
         if var_inv_type = 'F' then
            var_wrk_string := 'Standard Finished Goods Inventory Report - Period - BR Forecast (Yen Millions)';
         else
            var_wrk_string := 'Standard Bulk Inventory Report - Period - BR Forecast (Yen Millions)';
         end if;
      elsif var_for_type = 'PRD_LE' then
         if var_inv_type = 'F' then
            var_wrk_string := 'Standard Finished Goods Inventory Report - Period - LE Forecast (Yen Millions)';
         else
            var_wrk_string := 'Standard Bulk Inventory Report - Period - LE Forecast (Yen Millions)';
         end if;
      elsif var_for_type = 'MTH_BR' then
         if var_inv_type = 'F' then
            var_wrk_string := 'Standard Finished Goods Inventory Report - Month - BR Forecast (Yen Millions)';
         else
            var_wrk_string := 'Standard Bulk Inventory Report - Month - BR Forecast (Yen Millions)';
         end if;
      elsif var_for_type = 'MTH_LE' then
         if var_inv_type = 'F' then
            var_wrk_string := 'Standard Finished Goods Inventory Report - Month - LE Forecast (Yen Millions)';
         else
            var_wrk_string := 'Standard Bulk Inventory Report - Month - LE Forecast (Yen Millions)';
         end if;
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
      elsif var_for_type = 'PRD_LE' then
         var_wrk_string := var_prd_asofdays;
      elsif var_for_type = 'MTH_BR' then
         var_wrk_string := var_mth_asofdays;
      elsif var_for_type = 'MTH_LE' then
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
         var_sum_level := 1;
         doTotal;
         doFormat;
         doBorder;
         xlxml_object.SetFreezeCell('B8');
      end if;

      /*-*/
      /* Report when no details found */
      /*-*/
      if var_details = false then
         xlxml_object.SetRange('A8:A8', 'A8:' || var_lst_column || '8', xlxml_object.TYPE_DETAIL, -2, 0, false, 'NO DETAILS EXIST');
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
      var_srt_literal varchar2(2048 char);
      var_typ_literal varchar2(256 char);
      var_for_literal varchar2(256 char);
      var_opr_literal varchar2(256 char);
      var_wrk_billed_qty number(22,0);
      var_wrk_fc_qty number(22,0);
      var_wrk_ft_qty number(22,0);
      var_wrk_tot_value number(22,0);
      var_wrk_tot_qty number(22,3);
      var_wrk_int_qty number(22,3);
      var_wrk_ons_cover number(9,2);
      var_wrk_war_value number(22,0);
      var_wrk_war_qty number(22,3);
      var_wrk_hld_qty number(22,3);
      var_wrk_unk_qty number(22,3);
      var_wrk_age_qty number(22,3);
      var_wrk_sal_qty number(22,3);
      var_wrk_sal_cover number(9,2);
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
      var_sap_base_uom_code varchar2(3 char);
      var_material_desc_en varchar2(40 char);
      var_material_desc_ja varchar2(40 char);
      var_sort_desc varchar2(60 char);
      var_sap_plant_code varchar2(4 char);
      var_war_inv_sal_qty number(22,3);
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
                             prdct_pack_size_text asc,';
      elsif var_sap_bus_sgmnt_code = '02' then
         var_srt_literal := 'brand_flag_text asc,
                             mkt_sgmnt_text asc,
                             supply_sgmnt_text asc,
                             brand_sub_flag_text asc,
                             prdct_pack_size_text asc,';
      elsif var_sap_bus_sgmnt_code = '05' then
         var_srt_literal := 'mkt_sgmnt_text asc,
                             supply_sgmnt_text asc,
                             brand_flag_text asc,
                             brand_sub_flag_text asc,
                             prdct_pack_size_text asc,';
      else
         var_srt_literal := 'mkt_sgmnt_text asc,
                             supply_sgmnt_text asc,
                             brand_flag_text asc,
                             brand_sub_flag_text asc,
                             prdct_pack_size_text asc,';
      end if;
      if var_inv_type = 'F' then
         var_srt_literal := var_srt_literal || ' rep_desc asc, sort_desc asc';
      else
         var_srt_literal := var_srt_literal || ' sort_desc asc';
      end if;

      /*-*/
      /* Initialise the type and forecast literals */
      /*-*/
      if var_for_type = 'PRD_BR' then
         var_typ_literal := 'prd';
         var_for_literal := 'br';
      elsif var_for_type = 'PRD_LE' then
         var_typ_literal := 'prd';
         var_for_literal := 'le';
      elsif var_for_type = 'MTH_BR' then
         var_typ_literal := 'mth';
         var_for_literal := 'br';
      elsif var_for_type = 'MTH_LE' then
         var_typ_literal := 'mth';
         var_for_literal := 'le';
      end if;

      /*-*/
      /* Initialise the operator literal */
      /*-*/
      if var_inv_type = 'F' then
         var_opr_literal := 't02.sap_material_type_code = ''FERT'' and t02.material_type_flag_sfp != ''Y''';
      else
         var_opr_literal := '(t02.sap_material_type_code = ''ROH'' or (t02.sap_material_type_code = ''FERT'' and t02.material_type_flag_sfp = ''Y''))';
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
                                 t02.bus_sgmnt_desc,
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
                                 t02.sap_base_uom_code,
                                 t02.material_desc_en,
                                 t02.material_desc_ja,
                                 t02.material_desc_en || t02.sap_material_code as sort_desc
                            from pld_inv_format0101 t01, material_dim t02
                           where t01.sap_material_code = t02.sap_material_code(+)
                             and t01.sap_company_code = :A
                             and t02.sap_bus_sgmnt_code = :B
                             and ' || var_opr_literal || '
                             and (t01.' || var_typ_literal || '_billed_qty <> 0 or
                                  t01.' || var_typ_literal || '_' || var_for_literal || '_qty <> 0 or
                                  t01.' || var_typ_literal || '_fut_' || var_for_literal || '_qty <> 0 or
                                  t01.inv_tot_value <> 0 or
                                  t01.inv_tot_qty <> 0 or
                                  t01.inv_int_qty <> 0 or
                                  t01.inv_war_value <> 0 or
                                  t01.inv_war_qty <> 0 or
                                  t01.inv_hld_qty <> 0 or
                                  t01.inv_unk_qty <> 0 or
                                  t01.inv_age_qty <> 0 or
                                  t01.inv_sal_qty <> 0)
                        order by ' || var_srt_literal;

      /*-*/
      /* Retrieve the detail rows */
      /*-*/
      open pld_inv_format0101_c01 for var_dynamic_sql using var_sap_company_code, var_sap_bus_sgmnt_code;
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
                                           var_sap_base_uom_code,
                                           var_material_desc_en,
                                           var_material_desc_ja,
                                           var_sort_desc;
         if pld_inv_format0101_c01%notfound then
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
         if var_inv_type = 'F' then
            tblSummary(7).current_value := var_rep_desc;
         end if;

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
         if var_inv_type = 'F' then
            if not(var_sap_rep_item_code is null) then
               tblSummary(7).description := '(' || var_sap_rep_item_code || ') ' || var_rep_item_desc_en;
            else
               tblSummary(7).description := 'NO REPRESENTATIVE ITEM';
            end if;
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
            tblSummary(idx).wrk_fc_qty := tblSummary(idx).wrk_fc_qty + var_wrk_fc_qty;
            tblSummary(idx).wrk_ft_qty := tblSummary(idx).wrk_ft_qty + var_wrk_ft_qty;
            tblSummary(idx).wrk_ons_qty := tblSummary(idx).wrk_ons_qty + var_wrk_tot_qty;
            tblSummary(idx).wrk_sal_qty := tblSummary(idx).wrk_sal_qty + var_wrk_sal_qty;
         end loop;

         /*-*/
         /* Accumulate the summary level forecast data */
         /*-*/
         doAccumulate(var_sap_material_code);

         /*-*/
         /* Set the control information */
         /*-*/
         var_details := true;
         var_row_count := var_row_count + 1;

         /*-*/
         /* Detail description */
         /*-*/
         if var_inv_type = 'F' then
            xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                                  null, xlxml_object.TYPE_DETAIL, -1, SUMMARY_MAX, false, '(' || var_sap_material_code || ') ' || var_material_desc_en);
         else
            xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                                  null, xlxml_object.TYPE_DETAIL, -1, SUMMARY_MAX, false, '(' || var_sap_material_code || ') ' || var_material_desc_en || ' (' || var_sap_base_uom_code || ')');
         end if;

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
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_tot_value/1000000,'FM9999999999999990.000000');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_tot_qty,'FM9999999999999999999990');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_int_qty,'FM9999999999999999999990');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_ons_cover,'FM9999990.00');
         var_wrk_array := var_wrk_array || chr(9) || to_char(var_wrk_war_value/1000000,'FM9999999999999990.000000');
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
      var_sum_level := 0;
      var_row_count := 0;
      var_details := false;

      /**/
      /* Clear temporary table */
      /**/
      delete from pld_inv_work0101;

      /*-*/
      /* Clear the warehouse array */
      /*-*/
      tblWarehouse.Delete;

      /*-*/
      /* Clear the summary array */
      /*-*/
      for idx in 1..SUMMARY_MAX loop
         tblSummary(idx).current_value := null;
         tblSummary(idx).saved_value := '**********';
         tblSummary(idx).saved_row := 0;
         tblSummary(idx).description := null;
         tblSummary(idx).wrk_billed_qty := 0;
         tblSummary(idx).wrk_fc_qty := 0;
         tblSummary(idx).wrk_ft_qty := 0;
         tblSummary(idx).wrk_ons_qty := 0;
         tblSummary(idx).wrk_ons_cover := 0;
         tblSummary(idx).wrk_sal_qty := 0;
         tblSummary(idx).wrk_sal_cover := 0;
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
         /* Summary forecast quantity */
         /*-*/
         var_wrk_array := '"=subtotal(9,B' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990') || ')"';

         /*-*/
         /* Summary progress % */
         /*-*/
         if tblSummary(idx).wrk_billed_qty <> 0 and tblSummary(idx).wrk_fc_qty <> 0 then
            var_wrk_string := to_char(round((tblSummary(idx).wrk_billed_qty / tblSummary(idx).wrk_fc_qty) * 100, 2),'FM9999990.00');
         elsif tblSummary(idx).wrk_billed_qty = 0 and tblSummary(idx).wrk_fc_qty = 0 then
            if tblSummary(idx).wrk_ft_qty = 0 then
               var_wrk_string := 'NS/NF';
            else
               var_wrk_string := 'NS/FF';
            end if;
         elsif tblSummary(idx).wrk_billed_qty = 0 then
            var_wrk_string := 'NS';
         elsif tblSummary(idx).wrk_ft_qty = 0 then
            var_wrk_string := 'NF';
         else
            var_wrk_string := 'FF';
         end if;
         var_wrk_array := var_wrk_array || chr(9) || var_wrk_string;

         /*-*/
         /* Summary saleable cover */
         /*-*/
         doCover(idx);

         /*-*/
         /* Summary inventory */
         /*-*/
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,D' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':D' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,E' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':E' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,F' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':F' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_array || chr(9) || to_char(tblSummary(idx).wrk_ons_cover,'FM9999990.00');
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,H' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':H' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,I' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':I' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,J' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':J' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,K' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':K' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,L' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':L' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,M' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':M' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_array := var_wrk_array || chr(9) || to_char(tblSummary(idx).wrk_sal_cover,'FM9999990.00');

         /*-*/
         /* Summary warehouse saleable cases */
         /*-*/
         for idxx in 1..tblWarehouse.count loop
            var_wrk_array := var_wrk_array || chr(9) || '"=subtotal(9,' || tblWarehouse(idxx).column_id || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':' || tblWarehouse(idxx).column_id || to_char(var_row_count,'FM999999990') || ')"';
         end loop;

         /*-*/
         /* Create the summary row */
         /*-*/
         xlxml_object.SetRangeArray('B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':B' || to_char(tblSummary(idx).saved_row,'FM999999990'),
                                    'B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':' || var_lst_column || to_char(tblSummary(idx).saved_row,'FM999999990'),
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
         tblSummary(idx).wrk_billed_qty := 0;
         tblSummary(idx).wrk_fc_qty := 0;
         tblSummary(idx).wrk_ft_qty := 0;
         tblSummary(idx).wrk_ons_qty := 0;
         tblSummary(idx).wrk_ons_cover := 0;
         tblSummary(idx).wrk_sal_qty := 0;
         tblSummary(idx).wrk_sal_cover := 0;

         /**/
         /* Delete the summary forecast work values */
         /**/
         delete from pld_inv_work0101 where summary = idx;
         commit;

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

   /**********************************************************/
   /* This procedure performs the accumuate forecast routine */
   /**********************************************************/
   procedure doAccumulate(par_sap_material_code in varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_typ_literal varchar2(256 char);
      var_for_literal varchar2(256 char);
      var_fil_literal varchar2(256 char);
      var_billing_YYYYNN number(6,0);
      var_fc_qty number(22,0);
      var_dynamic_sql varchar2(32767 char);
      type typCursor is ref cursor;
      pld_inv_format0134_c01 typCursor;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the type and forecast literals */
      /*-*/
      if var_for_type = 'PRD_BR' then
         var_typ_literal := 'PP';
         var_for_literal := 'br';
         var_fil_literal := '03';
      elsif var_for_type = 'PRD_LE' then
         var_typ_literal := 'PP';
         var_for_literal := 'le';
         var_fil_literal := '03';
      elsif var_for_type = 'MTH_BR' then
         var_typ_literal := 'MM';
         var_for_literal := 'br';
         var_fil_literal := '04';
      elsif var_for_type = 'MTH_LE' then
         var_typ_literal := 'MM';
         var_for_literal := 'le';
         var_fil_literal := '04';
      end if;

      /*-*/
      /* Initialise the query */
      /*-*/
      var_dynamic_sql := 'select t01.billing_YYYY' || var_typ_literal || ',
                                 t01.' || var_for_literal || '_qty
                            from pld_inv_format01' || var_fil_literal || ' t01
                           where t01.sap_company_code = :A
                             and t01.sap_material_code = :B
                           order by t01.billing_YYYY' || var_typ_literal || ' asc';

      /*-*/
      /* Retrieve the forecast rows */
      /*-*/
      open pld_inv_format0134_c01 for var_dynamic_sql using var_sap_company_code, par_sap_material_code;
      loop
         fetch pld_inv_format0134_c01 into var_billing_YYYYNN,
                                           var_fc_qty;
         if pld_inv_format0134_c01%notfound then
            exit;
         end if;
         for idx in 1..SUMMARY_MAX loop
            update pld_inv_work0101
               set fc_qty = fc_qty + var_fc_qty
               where summary = idx
                 and billing_YYYYNN = var_billing_YYYYNN;
            if sql%notfound then
               insert into pld_inv_work0101
                  (summary, billing_YYYYNN, fc_qty)
                  values(idx, var_billing_YYYYNN, var_fc_qty);
            end if;
         end loop;
      end loop; 
      close pld_inv_format0134_c01;

      /*-*/
      /* Commit the work file */
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doAccumulate;

   /*******************************************************/
   /* This procedure performs the calculate cover routine */
   /*******************************************************/
   procedure doCover(par_summary in number) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_current_YYYYNN number(6,0);
      var_wrk_percent number(5,2);
      var_ons_qty number(22,3);
      var_sal_qty number(22,3);
      var_YYYYNN number(6,0);
      var_fc_qty number(22,0);
      var_wrk_pct number(9,7);
      var_for_pct number(9,7);
      var_for_qty number(22,3);
      var_fc_ons_start boolean;
      var_fc_sal_start boolean;

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor pld_inv_work0101_c01 is 
         select pld_inv_work0101.billing_YYYYNN,
                pld_inv_work0101.fc_qty
         from pld_inv_work0101
         where pld_inv_work0101.summary = par_summary
         order by pld_inv_work0101.billing_YYYYNN asc;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the control variables */
      /*-*/
      if var_for_type = 'PRD_BR' or var_for_type = 'PRD_LE' then
         select current_YYYYPP into var_current_YYYYNN from pld_inv_format0100;
         select prd_percent into var_wrk_percent from pld_inv_format0100;
      elsif var_for_type = 'MTH_BR' or var_for_type = 'MTH_LE' then
         select current_YYYYMM into var_current_YYYYNN from pld_inv_format0100;
         select mth_percent into var_wrk_percent from pld_inv_format0100;
      end if;

      /*-*/
      /* Process the summary period forecast values */
      /*-*/
      var_fc_ons_start := false;
      var_fc_sal_start := false;
      var_ons_qty := tblSummary(par_summary).wrk_ons_qty;
      var_sal_qty := tblSummary(par_summary).wrk_sal_qty;
      open pld_inv_work0101_c01;
      loop
         fetch pld_inv_work0101_c01 into var_YYYYNN,
                                         var_fc_qty;
         if pld_inv_work0101_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Summary onshore weeks cover */
         /*-*/
         if var_ons_qty > 0 then
            if var_fc_qty <> 0 then
               var_for_pct := 1;
               if var_YYYYNN = var_current_YYYYNN then
                  var_for_pct := 1 - (var_wrk_percent / 100);
               end if;
               var_for_qty := var_fc_qty * var_for_pct;
               var_wrk_pct := 1;
               if var_ons_qty - var_for_qty < 0 then
                  var_wrk_pct := var_ons_qty / var_for_qty;
               end if;
               var_ons_qty := var_ons_qty - var_for_qty;
               tblSummary(par_summary).wrk_ons_cover := tblSummary(par_summary).wrk_ons_cover + round((4 * var_for_pct) * var_wrk_pct, 2);
               var_fc_ons_start := true;
            else
               if var_fc_ons_start = true then
                  tblSummary(par_summary).wrk_ons_cover := tblSummary(par_summary).wrk_ons_cover + 4;
               end if;
            end if;
         end if;

         /*-*/
         /* Summary saleble weeks cover */
         /*-*/
         if var_sal_qty > 0 then
            if var_fc_qty <> 0 then
               var_for_pct := 1;
               if var_YYYYNN = var_current_YYYYNN then
                  var_for_pct := 1 - (var_wrk_percent / 100);
               end if;
               var_for_qty := var_fc_qty * var_for_pct;
               var_wrk_pct := 1;
               if var_sal_qty - var_for_qty < 0 then
                  var_wrk_pct := var_sal_qty / var_for_qty;
               end if;
               var_sal_qty := var_sal_qty - var_for_qty;
               tblSummary(par_summary).wrk_sal_cover := tblSummary(par_summary).wrk_sal_cover + round((4 * var_for_pct) * var_wrk_pct, 2);
               var_fc_sal_start := true;
            else
               if var_fc_sal_start = true then
                  tblSummary(par_summary).wrk_sal_cover := tblSummary(par_summary).wrk_sal_cover + 4;
               end if;
            end if;
         end if;

      end loop;
      close pld_inv_work0101_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doCover;

end mfjpln_inv_format01_excel01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mfjpln_inv_format01_excel01 for pld_rep_app.mfjpln_inv_format01_excel01;
grant execute on mfjpln_inv_format01_excel01 to public;
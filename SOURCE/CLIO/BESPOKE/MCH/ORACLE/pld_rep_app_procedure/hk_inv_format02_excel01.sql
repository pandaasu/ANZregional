/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : HK Planning Reports                                */
/* Package : hk_inv_format02_excel01                            */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : June 2003                                          */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_inv_format02_excel01 as

/**DESCRIPTION**
 Forecast Product Unrestricted Inventory Report - Invoice date aggregations.

 **PARAMETERS**
 par_sap_company_code = SAP company code (mandatory)
 par_sap_bus_sgmnt_code = SAP business segment code (mandatory)
 par_for_type = Forecast type (mandatory)
                  PRD_BR = Period BR forecast
                  PRD_RB = Period ROB forecast
                  MTH_BR = Month BR forecast
                  MTH_RB = Month ROB forecast
 par_srt_type = Sort type (mandatory)
                  DIS = Disposition
                  MAT = Material
 par_print_xml = Print xml data string (optional)
                   Format = SetPrintOverride Orientation='1' FitWidthPages='1' Zoom='0'
                   Orientation = 1(Portrait) 2(Landscape)
                   FitWidthPages = number 0 to 999
                   Zoom = number 0 to 100 (overrides FitWidthPages)

 **NOTES**
 1. The material is ignored when there is no unrestricted quantity and value

**/
   
   /*-*/
   /* Public declarations */
   /*-*/
   function main(par_sap_company_code in varchar2,
                 par_sap_bus_sgmnt_code in varchar2,
                 par_for_type in varchar2,
                 par_srt_type in varchar2,
                 par_print_xml in varchar2) return varchar2;

end hk_inv_format02_excel01;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_inv_format02_excel01 as

   /*-*/
   /* Private global declarations */
   /*-*/
   procedure doDetail;
   procedure doDetailDate(par_inv_exp_date in date, par_sap_material_code in varchar2, par_inv_class01 in varchar2);
   procedure clearReport;
   procedure checkSummary;
   procedure doTotal;
   procedure doHeading;
   procedure doFormat;
   procedure doBorder;

   /*-*/
   /* Private global variables */
   /*-*/
   SUMMARY_MAX number(2,0) := 2;
   var_sum_level number(2,0);
   var_row_count number(15,0);
   var_details boolean;
   var_sap_company_code varchar2(6 char);
   var_sap_bus_sgmnt_code varchar2(4 char);
   var_for_type varchar2(6 char);
   var_srt_type varchar2(3 char);
   var_for_literal varchar2(256 char);
   var_lst_column varchar2(2 char);
   type rcdSummary is record(current_value varchar2(256 char),
                             saved_value varchar2(256 char),
                             saved_row number(9,0),
                             description varchar2(128 char));
   type typSummary is table of rcdSummary index by binary_integer;
   tblSummary typSummary;
   type rcdWarehouse is record(sap_plant_code varchar2(4 char),
                               column_id1 varchar2(2 char),
                               column_id2 varchar2(2 char),
                               inv_unr_qty number,
                               inv_unr_val number);
   type typWarehouse is table of rcdWarehouse index by binary_integer;
   tblWarehouse typWarehouse;

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_sap_company_code in varchar2,
                 par_sap_bus_sgmnt_code in varchar2,
                 par_for_type in varchar2,
                 par_srt_type in varchar2,
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
      var_current_YYYYPP number(6,0);
      var_current_YYYYMM number(6,0);
      var_extract_status varchar2(256 char);
      var_inventory_date date;
      var_inventory_status varchar2(256 char);
      var_company_desc varchar2(60 char);
      var_bus_sgmnt_desc varchar2(30 char);
      var_sap_plant_code varchar2(4 char);
      var_found boolean;
      var_wrk_count number(15,0);
      var_wrk_column number(4,0);
      var_wrk_string varchar2(4096 char);
      var_dynamic_sql varchar2(32767 char);
      type typCursor is ref cursor;
      pld_inv_format0202_c01 typCursor;

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

      cursor pld_inv_format0200_c01 is 
         select pld_inv_format0200.extract_date,
                pld_inv_format0200.current_YYYYPP,
                pld_inv_format0200.current_YYYYMM,
                pld_inv_format0200.extract_status,
                pld_inv_format0200.inventory_date,
                pld_inv_format0200.inventory_status
         from pld_inv_format0200
         where pld_inv_format0200.sap_company_code = var_sap_company_code;

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
      var_srt_type := par_srt_type;
      if var_for_type = 'PRD_BR' then
         var_for_literal := 'prd_br';
      elsif var_for_type = 'PRD_RB' then
         var_for_literal := 'prd_rb';
      elsif var_for_type = 'MTH_BR' then
         var_for_literal := 'mth_br';
      elsif var_for_type = 'MTH_RB' then
         var_for_literal := 'mth_rb';
      end if;

      /*-*/
      /* Retrieve the format control */
      /*-*/
      var_found := true;
      open pld_inv_format0200_c01;
      fetch pld_inv_format0200_c01 into var_extract_date,
                                        var_current_YYYYPP,
                                        var_current_YYYYMM,
                                        var_extract_status,
                                        var_inventory_date,
                                        var_inventory_status;
      if pld_inv_format0200_c01%notfound then
         var_found := false;
      end if;
      close pld_inv_format0200_c01;
      if var_found = false then
         raise_application_error(-20000, 'Format control row PLD_INV_FORMAT0200 not found');
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
      /* Retrieve the warehouse information */
      /*-*/
      var_dynamic_sql := 'select t01.sap_plant_code
                            from pld_inv_format0202 t01, material_dim t02
                           where t01.sap_material_code = t02.sap_material_code(+)
                             and t01.sap_company_code = :A
                             and t02.sap_bus_sgmnt_code = :B
                             and (t01.inv_unr_qty <> 0 or
                                  t01.inv_unr_val <> 0)
                             and exists (select ''x'' from pld_inv_format0201 t11
                                          where t11.sap_company_code = t01.sap_company_code
                                            and t11.sap_material_code = t01.sap_material_code
                                            and t11.' || var_for_literal || '_qty <> 0)
                        group by t01.sap_plant_code
                        order by t01.sap_plant_code asc';
      var_wrk_count := 0;
      var_wrk_column := 3;
      var_lst_column := 'C';
      open pld_inv_format0202_c01 for var_dynamic_sql using var_sap_company_code, var_sap_bus_sgmnt_code;
      loop
         fetch pld_inv_format0202_c01 into var_sap_plant_code;
         if pld_inv_format0202_c01%notfound then
            exit;
         end if;
         var_wrk_count := var_wrk_count + 1;
         var_wrk_column := var_wrk_column + 1;
         tblWarehouse(var_wrk_count).sap_plant_code := var_sap_plant_code;
         tblWarehouse(var_wrk_count).column_id1 := xlxml_object.getColumnId(var_wrk_column);
         var_wrk_column := var_wrk_column + 1;
         tblWarehouse(var_wrk_count).column_id2 := xlxml_object.getColumnId(var_wrk_column);
         var_lst_column := tblWarehouse(var_wrk_count).column_id2;
         tblWarehouse(var_wrk_count).inv_unr_qty := 0;
         tblWarehouse(var_wrk_count).inv_unr_val := 0;
      end loop;
      close pld_inv_format0202_c01;

      /*-*/
      /* Report start */
      /*-*/
      xlxml_object.BeginReport;

      /*-*/
      /* Report heading line 1 */
      /*-*/
      if var_for_type = 'PRD_BR' then
         var_wrk_string := 'Forecast Product Unrestricted Inventory Report - Period - BR Forecast (HK$ Thousands)';
      elsif var_for_type = 'PRD_RB' then
         var_wrk_string := 'Forecast Product Unrestricted Inventory Report - Period - ROB Forecast (HK$ Thousands)';
      elsif var_for_type = 'MTH_BR' then
         var_wrk_string := 'Forecast Product Unrestricted Inventory Report - Month - BR Forecast (HK$ Thousands)';
      elsif var_for_type = 'MTH_RB' then
         var_wrk_string := 'Forecast Product Unrestricted Inventory Report - Month - ROB Forecast (HK$ Thousands)';
      end if;
      xlxml_object.SetRange('A1:A1', 'A1:' || var_lst_column || '1', xlxml_object.GetHeadingType(1), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 2 */
      /*-*/
      var_wrk_string := var_extract_status || ' ' || var_inventory_status;
      xlxml_object.SetRange('A2:A2', 'A2:' || var_lst_column || '2', xlxml_object.TYPE_HEADING_SM, -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 3 */
      /*-*/
      var_wrk_string := 'Company: ' || var_company_desc || ' Business Segment: ' || var_bus_sgmnt_desc;
      xlxml_object.SetRange('A3:A3', 'A3:' || var_lst_column || '3', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 4/5 - Description */
      /*-*/
      xlxml_object.SetRangeType('A4:A4', xlxml_object.GetHeadingType(7));
      xlxml_object.SetRange('A5:A5', null, xlxml_object.GetHeadingType(7), -1, 0, false, 'Material Hierarchy');

      /*-*/
      /* Report heading line 4/5 - Totals */
      /*-*/
      xlxml_object.SetRange('B4:B4', 'B4:C4', xlxml_object.GetHeadingType(2), -2, 0, false, 'Total Inventory');
      xlxml_object.SetRange('B5:B5', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'QTY');
      xlxml_object.SetRange('C5:C5', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Value');

      /*-*/
      /* Report heading line 4/5 - Warehouses */
      /*-*/
      for idx in 1..tblWarehouse.count loop
         xlxml_object.SetRange(tblWarehouse(idx).column_id1 || '4:' || tblWarehouse(idx).column_id1 || '4',
                               tblWarehouse(idx).column_id1 || '4:' || tblWarehouse(idx).column_id2 || '4',
                               xlxml_object.GetHeadingType(2), -2, 0, false, tblWarehouse(idx).sap_plant_code);
         xlxml_object.SetRange(tblWarehouse(idx).column_id1 || '5:' || tblWarehouse(idx).column_id1 || '5',
                               null, xlxml_object.GetHeadingType(7), -2, 0, false, 'QTY');
         xlxml_object.SetRange(tblWarehouse(idx).column_id2 || '5:' || tblWarehouse(idx).column_id2 || '5',
                               null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Value');
      end loop;

      /*-*/
      /* Report heading borders */
      /*-*/
      xlxml_object.SetHeadingBorder('A5:A5', 'TLR');
      xlxml_object.SetHeadingBorder('B4:C4', 'ALL');
      xlxml_object.SetHeadingBorder('B5:B5', 'TLR');
      xlxml_object.SetHeadingBorder('C5:C5', 'TLR');
      for idx in 1..tblWarehouse.count loop
         xlxml_object.SetHeadingBorder(tblWarehouse(idx).column_id1 || '4:' || tblWarehouse(idx).column_id2 || '4', 'ALL');
         xlxml_object.SetHeadingBorder(tblWarehouse(idx).column_id1 || '5:' || tblWarehouse(idx).column_id1 || '5', 'TLR');
         xlxml_object.SetHeadingBorder(tblWarehouse(idx).column_id2 || '5:' || tblWarehouse(idx).column_id2 || '5', 'TLR');
      end loop;

      /*-*/
      /* Initialise the row count */
      /*-*/
      var_row_count := 5;

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
         xlxml_object.SetFreezeCell('B6');
      end if;

      /*-*/
      /* Report when no details found */
      /*-*/
      if var_details = false then
         xlxml_object.SetRange('A6:A6', 'A6:' || var_lst_column || '6', xlxml_object.TYPE_DETAIL, -2, 0, false, 'NO INFORMATION EXISTS');
         xlxml_object.SetRangeBorder('A6:' || var_lst_column || '6');
      end if;

      /*-*/
      /* Report print settings */
      /*-*/
      xlxml_object.SetPrintData('$1:$5', '$A:$A', 2, 1, 0);
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
      var_grp_literal varchar2(256 char);
      var_srt_literal varchar2(256 char);
      var_inv_class01 varchar2(3 char);
      var_inv_exp_date date;
      var_sap_material_code varchar2(18 char);
      var_material_desc_en varchar2(40 char);
      var_sort_desc varchar2(60 char);
      var_class_description varchar2(60 char);
      var_wrk_string varchar2(2048 char);
      var_dynamic_sql varchar2(32767 char);
      type typCursor is ref cursor;
      pld_inv_format0202_c01 typCursor;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the group and sort literals */
      /*-*/
      if var_srt_type = 'DIS' then
         var_grp_literal := 't01.inv_class01,
                             t01.sap_material_code,
                             t01.inv_exp_date';
         var_srt_literal := 't01.inv_class01 asc,
                             sort_desc asc,
                             t01.inv_exp_date desc';
      else
         var_grp_literal := 't01.sap_material_code,
                             t01.inv_class01,
                             t01.inv_exp_date';
         var_srt_literal := 'sort_desc asc,
                             t01.inv_class01 asc,
                             t01.inv_exp_date desc';
      end if;

      /*-*/
      /* Retrieve the unrestricted inventory with forecasts */
      /*-*/
      var_dynamic_sql := 'select t01.inv_class01,
                                 t01.inv_exp_date,
                                 t01.sap_material_code,
                                 max(t02.material_desc_en),
                                 max(t02.material_desc_en) || max(t02.sap_material_code) as sort_desc
                            from pld_inv_format0202 t01, material_dim t02
                           where t01.sap_material_code = t02.sap_material_code(+)
                             and t01.sap_company_code = :A
                             and t02.sap_bus_sgmnt_code = :B
                             and (t01.inv_unr_qty <> 0 or
                                  t01.inv_unr_val <> 0)
                             and exists (select ''x'' from pld_inv_format0201 t11
                                          where t11.sap_company_code = t01.sap_company_code
                                            and t11.sap_material_code = t01.sap_material_code
                                            and t11.' || var_for_literal || '_qty <> 0)
                        group by ' || var_grp_literal || '
                        order by ' || var_srt_literal;

      /*-*/
      /* Retrieve the unrestricted inventory rows */
      /*-*/
      open pld_inv_format0202_c01 for var_dynamic_sql using var_sap_company_code, var_sap_bus_sgmnt_code;
      loop
         fetch pld_inv_format0202_c01 into var_inv_class01,
                                           var_inv_exp_date,
                                           var_sap_material_code,
                                           var_material_desc_en,
                                           var_sort_desc;
         if pld_inv_format0202_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Set the summary level values */
         /*-*/
         if var_srt_type = 'DIS' then
            tblSummary(1).current_value := var_inv_class01;
            tblSummary(2).current_value := var_sort_desc;
         else
            tblSummary(1).current_value := var_sort_desc;
            tblSummary(2).current_value := var_inv_class01;
         end if;

         /*-*/
         /* Set the classification descriptions */
         /*-*/
         if var_inv_class01 = 'C01' then
            var_class_description := 'AVAILABLE';
         elsif var_inv_class01 = 'C02' then
            var_class_description := 'WARNING';
         else
            var_class_description := 'AGEING';
         end if;

         /*-*/
         /* Set the summary level descriptions */
         /*-*/
         if var_srt_type = 'DIS' then
            tblSummary(1).description := var_class_description;
            tblSummary(2).description := '(' || var_sap_material_code || ') ' || var_material_desc_en;
         else
            tblSummary(1).description := '(' || var_sap_material_code || ') ' || var_material_desc_en;
            tblSummary(2).description := var_class_description;
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
         /* Perform the detail line */
         /*-*/
         doDetailDate(var_inv_exp_date, var_sap_material_code, var_inv_class01);

      end loop;
      close pld_inv_format0202_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doDetail;

   /***************************************************/
   /* This procedure performs the detail date routine */
   /***************************************************/
   procedure doDetailDate(par_inv_exp_date in date, par_sap_material_code in varchar2, par_inv_class01 in varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_sap_plant_code varchar2(4 char);
      var_inv_unr_qty number;
      var_inv_unr_val number;
      var_wrk_string varchar2(2048 char);
      var_wrk_array varchar2(4000 char);
      var_dynamic_sql varchar2(32767 char);
      type typCursor is ref cursor;
      pld_inv_format0202_c02 typCursor;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the control information */
      /*-*/
      var_details := true;
      var_row_count := var_row_count + 1;

      /*-*/
      /* Detail description */
      /*-*/
      if to_char(par_inv_exp_date,'YYYYMMDD') = '19000101' then
         xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                               null, xlxml_object.TYPE_DETAIL, -1, 2, false, 'NO DATE');
      elsif to_char(par_inv_exp_date,'YYYYMMDD') = '19000102' then
         xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                               null, xlxml_object.TYPE_DETAIL, 51, 2, false, '9999-01-01');
      else
         xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                               null, xlxml_object.TYPE_DETAIL, 51, 2, false, to_char(par_inv_exp_date,'YYYY-MM-DD'));
      end if;

      /*-*/
      /* Clear the warehouse values */
      /*-*/
      for idx in 1..tblWarehouse.count loop
         tblWarehouse(idx).inv_unr_qty := 0;
         tblWarehouse(idx).inv_unr_val := 0;
      end loop;

      /*-*/
      /* Retrieve the unrestricted warehouse rows */
      /*-*/
      var_dynamic_sql := 'select t01.sap_plant_code,
                                 t01.inv_unr_qty,
                                 t01.inv_unr_val
                            from pld_inv_format0202 t01
                           where t01.sap_company_code = :A
                             and t01.sap_material_code = :B
                             and t01.inv_class01 = :C
                             and t01.inv_exp_date = :D
                             and (t01.inv_unr_qty <> 0 or
                                  t01.inv_unr_val <> 0)
                        order by t01.sap_plant_code asc';
      open pld_inv_format0202_c02 for var_dynamic_sql using var_sap_company_code, par_sap_material_code, par_inv_class01, par_inv_exp_date;
      loop
         fetch pld_inv_format0202_c02 into var_sap_plant_code,
                                           var_inv_unr_qty,
                                           var_inv_unr_val;
         if pld_inv_format0202_c02%notfound then
            exit;
         end if;
         for idx in 1..tblWarehouse.count loop
            if tblWarehouse(idx).sap_plant_code = var_sap_plant_code then
               tblWarehouse(idx).inv_unr_qty := var_inv_unr_qty;
               tblWarehouse(idx).inv_unr_val := var_inv_unr_val;
            end if;
         end loop;
      end loop;
      close pld_inv_format0202_c02;

      /*-*/
      /* Set the total values */
      /*-*/
      var_wrk_string := null;
      for idx in 1..tblWarehouse.count loop
         if var_wrk_string is null then
            var_wrk_string := '"=' || tblWarehouse(idx).column_id1 || to_char(var_row_count, 'FM999999990');
         else
            var_wrk_string := var_wrk_string || '+' || tblWarehouse(idx).column_id1 || to_char(var_row_count, 'FM999999990');
         end if;
      end loop;
      var_wrk_array := var_wrk_string || '"';
      var_wrk_string := null;
      for idx in 1..tblWarehouse.count loop
         if var_wrk_string is null then
            var_wrk_string := '"=' || tblWarehouse(idx).column_id2 || to_char(var_row_count, 'FM999999990');
         else
            var_wrk_string := var_wrk_string || '+' || tblWarehouse(idx).column_id2 || to_char(var_row_count, 'FM999999990');
         end if;
      end loop;
      var_wrk_array := var_wrk_array || chr(9) || var_wrk_string || '"';

      /*-*/
      /* Set the warehouse values */
      /*-*/
      for idx in 1..tblWarehouse.count loop
         var_wrk_array := var_wrk_array || chr(9) || to_char(tblWarehouse(idx).inv_unr_qty,'FM999999999999990') || chr(9) || to_char(tblWarehouse(idx).inv_unr_val/1000,'FM999999990.00000');
      end loop;

      /*-*/
      /* Create the detail row */
      /*-*/
      xlxml_object.SetRangeArray('B' || to_char(var_row_count,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990'),
                                 'B' || to_char(var_row_count,'FM999999990') || ':' || var_lst_column || to_char(var_row_count,'FM999999990'),
                                 xlxml_object.TYPE_DETAIL, -9, var_wrk_array);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doDetailDate;

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

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the summary level in reverse order from the bottom to the changed level */
      /*-*/
      for idx in reverse var_sum_level..SUMMARY_MAX loop

         /*-*/
         /* Summary data */
         /*-*/
         var_wrk_string := '"=subtotal(9,B' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990') || ')"';
         var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,C' || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':C' || to_char(var_row_count,'FM999999990') || ')"';
         for idx01 in 1..tblWarehouse.count loop
            var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,' || tblWarehouse(idx01).column_id1 || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':' || tblWarehouse(idx01).column_id1 || to_char(var_row_count,'FM999999990') || ')"';
            var_wrk_string := var_wrk_string || chr(9) || '"=subtotal(9,' || tblWarehouse(idx01).column_id2 || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':' || tblWarehouse(idx01).column_id2 || to_char(var_row_count,'FM999999990') || ')"';
         end loop;
         xlxml_object.SetRangeArray('B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':B' || to_char(tblSummary(idx).saved_row,'FM999999990'),
                                    'B' || to_char(tblSummary(idx).saved_row,'FM999999990') || ':' || var_lst_column || to_char(tblSummary(idx).saved_row,'FM999999990'),
                                    xlxml_object.GetSummaryType(idx), -9, var_wrk_string);

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
            var_wrk_bullet := false;
         end if;
         xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                               null, xlxml_object.GetSummaryType(idx), -1, var_wrk_indent, var_wrk_bullet, tblSummary(idx).description);

         /*-*/
         /* Reset the summary control values */
         /*-*/
         tblSummary(idx).saved_value := tblSummary(idx).current_value;
         tblSummary(idx).saved_row := var_row_count;

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
      xlxml_object.SetRangeFormat('B6:B' || to_char(var_row_count,'FM999999990'), 0);
      xlxml_object.SetRangeFormat('C6:C' || to_char(var_row_count,'FM999999990'), 2);
      for idx in 1..tblWarehouse.count loop
         xlxml_object.SetRangeFormat(tblWarehouse(idx).column_id1 || '6:' || tblWarehouse(idx).column_id1 || to_char(var_row_count,'FM999999990'), 0);
         xlxml_object.SetRangeFormat(tblWarehouse(idx).column_id2 || '6:' || tblWarehouse(idx).column_id2 || to_char(var_row_count,'FM999999990'), 2);
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
      xlxml_object.SetRangeBorder('A6:A' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('B6:B' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('C6:C' || to_char(var_row_count,'FM999999990'));
      for idx in 1..tblWarehouse.count loop
         xlxml_object.SetRangeBorder(tblWarehouse(idx).column_id1 || '6:' || tblWarehouse(idx).column_id1 || to_char(var_row_count,'FM999999990'));
         xlxml_object.SetRangeBorder(tblWarehouse(idx).column_id2 || '6:' || tblWarehouse(idx).column_id2 || to_char(var_row_count,'FM999999990'));
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doBorder;

end hk_inv_format02_excel01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_inv_format02_excel01 for pld_rep_app.hk_inv_format02_excel01;
grant execute on hk_inv_format02_excel01 to public;
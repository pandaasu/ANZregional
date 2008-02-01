/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_for_format02_excel02                        */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : September 2003                                     */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_for_format02_excel02 as

/**DESCRIPTION**
 Forecast Accuracy Material Report - Invoice date aggregations.

 **PARAMETERS**
 All parameters are extracted from the global temporary table
 pld_variable.

 **NOTES**
 This report always uses data summarised to the rep_item level

**/
   
   /*-*/
   /* Public declarations */
   /*-*/
   function main return varchar2;

end mfjpln_for_format02_excel02;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_for_format02_excel02 as

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
   var_row_head number(15,0);
   var_row_count number(15,0);
   var_details boolean;
   var_for_type varchar2(3 char);
   var_for_str number(6,0);
   var_for_end number(6,0);
   var_for_accuracy_number number(3,0);
   var_material_count number(15,0);
   var_sap_bus_sgmnt_code varchar2(4 char);
   var_brand_flag_count number(15,0);
   var_brand_sub_flag_count number(15,0);
   var_prdct_pack_size_count number(15,0);
   var_multi_pack_qty_count number(15,0);
   var_cnsmr_pack_frmt_count number(15,0);
   var_planning_type varchar2(60 char);
   var_planning_src_unit varchar2(255 char);
   var_planning_status varchar2(1 char);
   var_planning_category varchar2(1 char);
   var_print_xml varchar2(255 char);
   var_lst_column varchar2(2 char);
   type rcdForecast is record(for_category varchar2(1 char), for_yyyynn varchar2(6 char), aso_yyyynn varchar2(6 char), column_id varchar2(2 char));
   type typForecast is table of rcdForecast index by binary_integer;
   tblForecast typForecast;

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main return varchar2 is

      /*-*/
      /* Exception definitions */
      /*-*/
      ApplicationError exception;
      pragma exception_init(ApplicationError, -20000);

      /*-*/
      /* Variable definitions */
      /*-*/
      var_bus_sgmnt_desc varchar2(255 char);
      var_brand_flag_desc varchar2(255 char);
      var_brand_sub_flag_desc varchar2(255 char);
      var_prdct_pack_size_desc varchar2(255 char);
      var_multi_pack_qty_desc varchar2(255 char);
      var_cnsmr_pack_frmt_desc varchar2(255 char);
      var_planning_type_desc varchar2(255 char);
      var_planning_src_unit_desc varchar2(255 char);
      var_planning_status_desc varchar2(255 char);
      var_planning_category_desc varchar2(255 char);
      var_current_yyyypp number(6,0);
      var_current_yyyymm number(6,0);
      var_cat01_yyyynn number(6,0);
      var_cat02_yyyynn number(6,0);
      var_cat03_yyyynn number(6,0);
      var_found boolean;
      var_wrk_index number(3,0);
      var_wrk_count number(15,0);
      var_wrk_column number(4,0);
      var_wrk_number number(6,0);
      var_wrk_num01 number(4,0);
      var_wrk_num02 number(2,0);
      var_bck_number number(6,0);
      var_bck_num01 number(4,0);
      var_bck_num02 number(2,0);
      var_wrk_string varchar2(2048 char);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor bus_sgmnt_c01 is 
         select t01.bus_sgmnt_desc
         from bus_sgmnt t01
         where t01.sap_bus_sgmnt_code = var_sap_bus_sgmnt_code;
      cursor brand_flag_c01 is 
         select t01.brand_flag_desc
         from brand_flag t01,
              pld_variable t02
         where t02.var_type = 'BRAND_FLAG'
           and t02.var_code = t01.sap_brand_flag_code
         order by t01.brand_flag_desc asc;
      cursor brand_sub_flag_c01 is 
         select t01.brand_sub_flag_desc
         from brand_sub_flag t01,
              pld_variable t02
         where t02.var_type = 'BRAND_SUB_FLAG'
           and t02.var_code = t01.sap_brand_sub_flag_code
         order by t01.brand_sub_flag_desc asc;
      cursor prdct_pack_size_c01 is 
         select t01.prdct_pack_size_desc
         from prdct_pack_size t01,
              pld_variable t02
         where t02.var_type = 'PRDCT_PACK_SIZE'
           and t02.var_code = t01.sap_prdct_pack_size_code
         order by t01.prdct_pack_size_desc asc;
      cursor multi_pack_qty_c01 is 
         select t01.multi_pack_qty_desc
         from multi_pack_qty t01,
              pld_variable t02
         where t02.var_type = 'MULTI_PACK_QTY'
           and t02.var_code = t01.sap_multi_pack_qty_code
         order by t01.multi_pack_qty_desc asc;
      cursor cnsmr_pack_frmt_c01 is 
         select t01.cnsmr_pack_frmt_desc
         from cnsmr_pack_frmt t01,
              pld_variable t02
         where t02.var_type = 'CNSMR_PACK_FRMT'
           and t02.var_code = t01.sap_cnsmr_pack_frmt_code
         order by t01.cnsmr_pack_frmt_desc asc;
      cursor mars_date_c01 is 
         select mars_period,
                (year_num * 100) + month_num
           from mars_date
          where to_char(calendar_date,'YYYYMMDD') = (select to_char(extract_date,'YYYYMMDD')
                                                      from pld_for_format0200);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the report information */
      /*-*/
      clearReport;

      /*-*/
      /* Set the variable values */
      /*-*/
      var_brand_flag_count := 0;
      select count(*) into var_brand_flag_count from pld_variable where var_type = 'BRAND_FLAG';
      var_brand_sub_flag_count := 0;
      select count(*) into var_brand_sub_flag_count from pld_variable where var_type = 'BRAND_SUB_FLAG';
      var_prdct_pack_size_count := 0;
      select count(*) into var_prdct_pack_size_count from pld_variable where var_type = 'PRDCT_PACK_SIZE';
      var_multi_pack_qty_count := 0;
      select count(*) into var_multi_pack_qty_count from pld_variable where var_type = 'MULTI_PACK_QTY';
      var_cnsmr_pack_frmt_count := 0;
      select count(*) into var_cnsmr_pack_frmt_count from pld_variable where var_type = 'CNSMR_PACK_FRMT';
      var_material_count := 0;
      select count(*) into var_material_count from pld_variable where var_type = 'MATERIAL';
      begin
         select var_code into var_for_type from pld_variable where var_type = 'FOR_TYPE';
      exception
         when others then
            var_for_type := 'PRD';
      end;
      begin
         select to_number(var_code) into var_for_str from pld_variable where var_type = 'FCST_STR';
      exception
         when others then
            var_for_str := 0;
      end;
      begin
         select to_number(var_code) into var_for_end from pld_variable where var_type = 'FCST_END';
      exception
         when others then
            var_for_end := 0;
      end;
      begin
         select to_number(var_code) into var_for_accuracy_number from pld_variable where var_type = 'FCST_ACC_NUMBER';
      exception
         when others then
            var_for_accuracy_number := 3;
      end;
      begin
         select var_code into var_sap_bus_sgmnt_code from pld_variable where var_type = 'BUS_SGMNT';
      exception
         when others then
            var_sap_bus_sgmnt_code := null;
      end;
      begin
         select var_code into var_planning_type from pld_variable where var_type = 'PLANNING_TYPE';
      exception
         when others then
            var_planning_type := null;
      end;
      begin
         select var_code into var_planning_src_unit from pld_variable where var_type = 'PLANNING_SRC_UNIT';
      exception
         when others then
            var_planning_src_unit := null;
      end;
      begin
         select var_code into var_planning_status from pld_variable where var_type = 'PLANNING_STATUS';
      exception
         when others then
            var_planning_status := null;
      end;
      begin
         select var_code into var_planning_category from pld_variable where var_type = 'PLANNING_CATEGORY';
      exception
         when others then
            var_planning_category := null;
      end;
      begin
         select var_code into var_print_xml from pld_variable where var_type = 'PRINT_XML';
      exception
         when others then
            var_print_xml := null;
      end;

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
      /* Retrieve the product type when required */
      /*-*/
      var_planning_type_desc := 'ALL';
      if var_planning_type is not null then
         var_planning_type_desc := var_planning_type;
      end if;

      /*-*/
      /* Set the source unit description */
      /*-*/
      var_planning_src_unit_desc := 'ALL';
      if var_planning_src_unit is not null then
         var_planning_src_unit_desc := var_planning_src_unit;
      end if;

      /*-*/
      /* Set the product status description */
      /*-*/
      var_planning_status_desc := 'ALL';
      if var_planning_status is not null then
         if var_planning_status = '0' then
            var_planning_status_desc := 'Active';
         else
            var_planning_status_desc := 'Inactive';
         end if;
      end if;

      /*-*/
      /* Set the product category description */
      /*-*/
      var_planning_category_desc := 'ALL';
      if var_planning_category is not null then
         if var_planning_category = 'X' then
            var_planning_category_desc := 'None';
         else
            var_planning_category_desc := var_planning_category;
         end if;
      end if;

      /*-*/
      /* Retrieve the current period and month information date for the extract */
      /* Calculate the category periods/months */
      /*-*/
      open mars_date_c01;
      fetch mars_date_c01 into var_current_yyyypp,
                               var_current_yyyymm;
      if mars_date_c01%notfound then
         raise_application_error(-20000, 'No mars date found for extract date from pld_for_format0200');
      end if;
      close mars_date_c01;
      if var_for_type = 'PRD' then
         var_wrk_num01 := to_number(substr(to_char(var_current_yyyypp,'FM000000'),1,4));
         var_wrk_num02 := to_number(substr(to_char(var_current_yyyypp,'FM000000'),5,2));
         if var_wrk_num02 >= 9 then
            var_cat01_yyyynn := (var_wrk_num01 * 100) + 9;
            var_cat02_yyyynn := (var_wrk_num01 * 100) + 1;
            var_cat03_yyyynn := ((var_wrk_num01 - 1) * 100) + 9;
         else
            var_cat01_yyyynn := (var_wrk_num01 * 100) + 1;
            var_cat02_yyyynn := ((var_wrk_num01 - 1) * 100) + 9;
            var_cat03_yyyynn := ((var_wrk_num01 - 1) * 100) + 1;
         end if;
      elsif var_for_type = 'MTH' then
         var_wrk_num01 := to_number(substr(to_char(var_current_yyyymm,'FM000000'),1,4));
         var_wrk_num02 := to_number(substr(to_char(var_current_yyyymm,'FM000000'),5,2));
         if var_wrk_num02 >= 9 then
            var_cat01_yyyynn := (var_wrk_num01 * 100) + 9;
            var_cat02_yyyynn := (var_wrk_num01 * 100) + 1;
            var_cat03_yyyynn := ((var_wrk_num01 - 1) * 100) + 9;
         else
            var_cat01_yyyynn := (var_wrk_num01 * 100) + 1;
            var_cat02_yyyynn := ((var_wrk_num01 - 1) * 100) + 9;
            var_cat03_yyyynn := ((var_wrk_num01 - 1) * 100) + 1;
         end if;
      end if;

      /*-*/
      /* Retrieve the forecast column data */
      /*-*/
      var_wrk_column := 8;
      var_lst_column := 'H';
      if var_for_type = 'PRD' then
         var_wrk_count := 13;
      elsif var_for_type = 'MTH' then
         var_wrk_count := 12;
      end if;
      var_wrk_num01 := to_number(substr(to_char(var_for_str,'FM000000'),1,4));
      var_wrk_num02 := to_number(substr(to_char(var_for_str,'FM000000'),5,2));
      var_bck_num01 := var_wrk_num01;
      var_bck_num02 := var_wrk_num02;
      var_bck_num02 := var_bck_num02 - var_for_accuracy_number;
      if var_bck_num02 < 1 then
         var_bck_num01 := var_bck_num01 - 1;
         var_bck_num02 := var_wrk_count + var_bck_num02;
      end if;
      var_wrk_index := 0;
      for idx in 1..var_wrk_count loop
         var_wrk_number := (var_wrk_num01 * 100) + var_wrk_num02;
         var_bck_number := (var_bck_num01 * 100) + var_bck_num02;
         if var_wrk_number <= var_for_end then
            if idx = 1 then
               if var_wrk_number >= var_cat01_yyyynn then
                  var_wrk_column := var_wrk_column + 1;
                  var_wrk_index := var_wrk_index + 1;
                  tblForecast(var_wrk_index).for_category := '1';
                  tblForecast(var_wrk_index).for_yyyynn := 0;
                  tblForecast(var_wrk_index).aso_yyyynn := 0;
                  tblForecast(var_wrk_index).column_id := xlxml_object.GetColumnId(var_wrk_column);
                  var_lst_column := tblForecast(var_wrk_index).column_id;
               elsif var_wrk_number >= var_cat02_yyyynn then
                  var_wrk_column := var_wrk_column + 1;
                  var_wrk_index := var_wrk_index + 1;
                  tblForecast(var_wrk_index).for_category := '2';
                  tblForecast(var_wrk_index).for_yyyynn := 0;
                  tblForecast(var_wrk_index).aso_yyyynn := 0;
                  tblForecast(var_wrk_index).column_id := xlxml_object.GetColumnId(var_wrk_column);
                  var_lst_column := tblForecast(var_wrk_index).column_id;
               else
                  var_wrk_column := var_wrk_column + 1;
                  var_wrk_index := var_wrk_index + 1;
                  tblForecast(var_wrk_index).for_category := '3';
                  tblForecast(var_wrk_index).for_yyyynn := 0;
                  tblForecast(var_wrk_index).aso_yyyynn := 0;
                  tblForecast(var_wrk_index).column_id := xlxml_object.GetColumnId(var_wrk_column);
                  var_lst_column := tblForecast(var_wrk_index).column_id;
               end if;
            elsif var_wrk_number = var_cat01_yyyynn then
               var_wrk_column := var_wrk_column + 1;
               var_wrk_index := var_wrk_index + 1;
               tblForecast(var_wrk_index).for_category := '1';
               tblForecast(var_wrk_index).for_yyyynn := 0;
               tblForecast(var_wrk_index).aso_yyyynn := 0;
               tblForecast(var_wrk_index).column_id := xlxml_object.GetColumnId(var_wrk_column);
               var_lst_column := tblForecast(var_wrk_index).column_id;
            elsif var_wrk_number = var_cat02_yyyynn then
               var_wrk_column := var_wrk_column + 1;
               var_wrk_index := var_wrk_index + 1;
               tblForecast(var_wrk_index).for_category := '2';
               tblForecast(var_wrk_index).for_yyyynn := 0;
               tblForecast(var_wrk_index).aso_yyyynn := 0;
               tblForecast(var_wrk_index).column_id := xlxml_object.GetColumnId(var_wrk_column);
               var_lst_column := tblForecast(var_wrk_index).column_id;
            elsif var_wrk_number = var_cat03_yyyynn then
               var_wrk_column := var_wrk_column + 1;
               var_wrk_index := var_wrk_index + 1;
               tblForecast(var_wrk_index).for_category := '3';
               tblForecast(var_wrk_index).for_yyyynn := 0;
               tblForecast(var_wrk_index).aso_yyyynn := 0;
               tblForecast(var_wrk_index).column_id := xlxml_object.GetColumnId(var_wrk_column);
               var_lst_column := tblForecast(var_wrk_index).column_id;
            end if;
            var_wrk_column := var_wrk_column + 1;
            var_wrk_index := var_wrk_index + 1;
            tblForecast(var_wrk_index).for_category := '0';
            tblForecast(var_wrk_index).for_yyyynn := to_char(var_wrk_number,'FM000000');
            tblForecast(var_wrk_index).aso_yyyynn := to_char(var_bck_number,'FM000000');
            tblForecast(var_wrk_index).column_id := xlxml_object.GetColumnId(var_wrk_column);
            var_lst_column := tblForecast(var_wrk_index).column_id;
            var_wrk_num02 := var_wrk_num02 + 1;
            if var_wrk_num02 > var_wrk_count then
               var_wrk_num01 := var_wrk_num01 + 1;
               var_wrk_num02 := 1;
            end if;
            var_bck_num02 := var_bck_num02 + 1;
            if var_bck_num02 > var_wrk_count then
               var_bck_num01 := var_bck_num01 + 1;
               var_bck_num02 := 1;
            end if;
         end if;
      end loop;

      /*-*/
      /* Report start */
      /*-*/
      xlxml_object.BeginReport;

      /*-*/
      /* Report heading line 1 */
      /*-*/
      var_wrk_string := 'Forecast Accuracy Material Report - Invoice Date';
      var_wrk_string := var_wrk_string || ' - ' || var_bus_sgmnt_desc;
      if var_for_type = 'PRD' then
         var_wrk_string := var_wrk_string || ' - Period';
      elsif var_for_type = 'MTH' then
         var_wrk_string := var_wrk_string || ' - Month';
      end if;
      xlxml_object.SetRange('A1:A1', 'A1:' || var_lst_column || '1', xlxml_object.GetHeadingType(1), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 2 */
      /*-*/
      var_wrk_string := 'Selections';
      xlxml_object.SetRange('A2:A2', 'A2:' || var_lst_column || '2', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);
      var_row_head := 2;

      /*-*/
      /* Materials not selected */
      /*-*/
      if var_material_count = 0 then

         /*-*/
         /* Report heading line - brand selections */
         /*-*/
         if var_brand_flag_count = 0 then
            var_brand_flag_desc := 'ALL';
            var_row_head := var_row_head + 1;
            var_wrk_string := 'Brands: ' || var_brand_flag_desc;
            xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
         else
            if var_brand_flag_count > 1 then
               var_row_head := var_row_head + 1;
               var_wrk_string := 'Brands';
               xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
            end if;
            open brand_flag_c01;
            loop
               fetch brand_flag_c01 into var_brand_flag_desc;
               if brand_flag_c01%notfound then
                  exit;
               end if;
               var_row_head := var_row_head + 1;
               if var_brand_flag_count = 1 then
                  var_wrk_string := 'Brand: ' || var_brand_flag_desc;
               else
                  var_wrk_string := var_brand_flag_desc;
               end if;
               xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
            end loop;
            close brand_flag_c01;
         end if;

         /*-*/
         /* Report heading line - sub brand selections */
         /*-*/
         if var_brand_sub_flag_count = 0 then
            var_brand_sub_flag_desc := 'ALL';
            var_row_head := var_row_head + 1;
            var_wrk_string := 'Sub Brands: ' || var_brand_sub_flag_desc;
            xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
         else
            if var_brand_sub_flag_count > 1 then
               var_row_head := var_row_head + 1;
               var_wrk_string := 'Sub Brands';
               xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
            end if;
            open brand_sub_flag_c01;
            loop
               fetch brand_sub_flag_c01 into var_brand_sub_flag_desc;
               if brand_sub_flag_c01%notfound then
                  exit;
               end if;
               var_row_head := var_row_head + 1;
               if var_brand_sub_flag_count = 1 then
                  var_wrk_string := 'Sub Brand: ' || var_brand_sub_flag_desc;
               else
                  var_wrk_string := var_brand_sub_flag_desc;
               end if;
               xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
            end loop;
            close brand_sub_flag_c01;
         end if;

         /*-*/
         /* Report heading line - packsize selections */
         /*-*/
         if var_prdct_pack_size_count = 0 then
            var_prdct_pack_size_desc := 'ALL';
            var_row_head := var_row_head + 1;
            var_wrk_string := 'Packsizes: ' || var_prdct_pack_size_desc;
            xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
         else
            if var_prdct_pack_size_count > 1 then
               var_row_head := var_row_head + 1;
               var_wrk_string := 'Packsizes';
               xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
            end if;
            open prdct_pack_size_c01;
            loop
               fetch prdct_pack_size_c01 into var_prdct_pack_size_desc;
               if prdct_pack_size_c01%notfound then
                  exit;
               end if;
               var_row_head := var_row_head + 1;
               if var_prdct_pack_size_count = 1 then
                  var_wrk_string := 'Packsize: ' || var_prdct_pack_size_desc;
               else
                  var_wrk_string := var_prdct_pack_size_desc;
               end if;
               xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
            end loop;
            close prdct_pack_size_c01;
         end if;

         /*-*/
         /* Report heading line - multipack selections */
         /*-*/
         if var_multi_pack_qty_count = 0 then
            var_multi_pack_qty_desc := 'ALL';
            var_row_head := var_row_head + 1;
            var_wrk_string := 'Multipacks: ' || var_multi_pack_qty_desc;
            xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
         else
            if var_multi_pack_qty_count > 1 then
               var_row_head := var_row_head + 1;
               var_wrk_string := 'Multipacks';
               xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
            end if;
            open multi_pack_qty_c01;
            loop
               fetch multi_pack_qty_c01 into var_multi_pack_qty_desc;
               if multi_pack_qty_c01%notfound then
                  exit;
               end if;
               var_row_head := var_row_head + 1;
               if var_multi_pack_qty_count = 1 then
                  var_wrk_string := 'Multipack: ' || var_multi_pack_qty_desc;
               else
                  var_wrk_string := var_multi_pack_qty_desc;
               end if;
               xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
            end loop;
            close multi_pack_qty_c01;
         end if;

         /*-*/
         /* Report heading line - package selections */
         /*-*/
         if var_cnsmr_pack_frmt_count = 0 then
            var_cnsmr_pack_frmt_desc := 'ALL';
            var_row_head := var_row_head + 1;
            var_wrk_string := 'Packages: ' || var_cnsmr_pack_frmt_desc;
            xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
         else
            if var_cnsmr_pack_frmt_count > 1 then
               var_row_head := var_row_head + 1;
               var_wrk_string := 'Packages';
               xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
            end if;
            open cnsmr_pack_frmt_c01;
            loop
               fetch cnsmr_pack_frmt_c01 into var_cnsmr_pack_frmt_desc;
               if cnsmr_pack_frmt_c01%notfound then
                  exit;
               end if;
               var_row_head := var_row_head + 1;
               if var_cnsmr_pack_frmt_count = 1 then
                  var_wrk_string := 'Package: ' || var_cnsmr_pack_frmt_desc;
               else
                  var_wrk_string := var_cnsmr_pack_frmt_desc;
               end if;
               xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
            end loop;
            close cnsmr_pack_frmt_c01;
         end if;

         /*-*/
         /* Report heading line */
         /*-*/
         if var_planning_type is not null then
            var_row_head := var_row_head + 1;
            var_wrk_string := 'Type: ' || var_planning_type_desc;
            xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
         end if;

         /*-*/
         /* Report heading line */
         /*-*/
         if var_planning_src_unit is not null then
            var_row_head := var_row_head + 1;
            var_wrk_string := 'Source Unit: ' || var_planning_src_unit_desc;
            xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
         end if;

         /*-*/
         /* Report heading line */
         /*-*/
         if var_planning_status is not null then
            var_row_head := var_row_head + 1;
            var_wrk_string := 'Status: ' || var_planning_status_desc;
            xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
         end if;

         /*-*/
         /* Report heading line */
         /*-*/
         if var_planning_category is not null then
            var_row_head := var_row_head + 1;
            var_wrk_string := 'Category: ' || var_planning_category_desc;
            xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
         end if;

         /*-*/
         /* Report heading line */
         /*-*/
         if var_row_head = 2 then
            var_row_head := var_row_head + 1;
            var_wrk_string := 'All Materials';
            xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
         end if;

      else

         /*-*/
         /* Report heading line */
         /*-*/
         var_row_head := var_row_head + 1;
         var_wrk_string := 'Listed Materials';
         xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);

      end if;

      /*-*/
      /* Report heading line */
      /*-*/
      var_row_head := var_row_head + 1;
      if var_for_type = 'PRD' then
         var_wrk_string := 'Target Forecast: ' || to_char(var_for_accuracy_number,'FM990') || ' periods before';
      elsif var_for_type = 'MTH' then
         var_wrk_string := 'Target Forecast: ' || to_char(var_for_accuracy_number,'FM990') || ' months before';
      end if;
      xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
      xlxml_object.SetHeadingBorder('A2:' || var_lst_column || to_char(var_row_head,'FM999999990'), 'TB');

      /*-*/
      /* Report heading line */
      /*-*/
      var_row_head := var_row_head + 1;
      xlxml_object.SetRangeType('A' || to_char(var_row_head,'FM999999990') || ':H' || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(2));
      xlxml_object.SetHeadingBorder('A' || to_char(var_row_head,'FM999999990') || ':H' || to_char(var_row_head,'FM999999990'), 'ALL');
      xlxml_object.SetRange('I' || to_char(var_row_head,'FM999999990') || ':I' || to_char(var_row_head,'FM999999990'), 'I' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(2), -2, 0, false, 'Single Forecast Accuracy (%)');
      xlxml_object.SetHeadingBorder('I' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), 'ALL');

      /*-*/
      /* Report heading line */
      /*-*/
      var_row_head := var_row_head + 1;
      xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), null, xlxml_object.GetHeadingType(7), -2, 0, false, 'GRD Code');
      xlxml_object.SetRange('B' || to_char(var_row_head,'FM999999990') || ':B' || to_char(var_row_head,'FM999999990'), null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Product');
      xlxml_object.SetRange('C' || to_char(var_row_head,'FM999999990') || ':C' || to_char(var_row_head,'FM999999990'), null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Brand');
      xlxml_object.SetRange('D' || to_char(var_row_head,'FM999999990') || ':D' || to_char(var_row_head,'FM999999990'), null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Sub Brand');
      xlxml_object.SetRange('E' || to_char(var_row_head,'FM999999990') || ':E' || to_char(var_row_head,'FM999999990'), null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Packsize');
      xlxml_object.SetRange('F' || to_char(var_row_head,'FM999999990') || ':F' || to_char(var_row_head,'FM999999990'), null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Multipack');
      xlxml_object.SetRange('G' || to_char(var_row_head,'FM999999990') || ':G' || to_char(var_row_head,'FM999999990'), null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Package');
      xlxml_object.SetRange('H' || to_char(var_row_head,'FM999999990') || ':H' || to_char(var_row_head,'FM999999990'), null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Source Units');
      for idx in 1..tblForecast.count loop
         if tblForecast(idx).for_category <> '0' then
            xlxml_object.SetRange(tblForecast(idx).column_id || to_char(var_row_head,'FM999999990') || ':' || tblForecast(idx).column_id || to_char(var_row_head,'FM999999990'), null,
                                  xlxml_object.GetHeadingType(7), -2, 0, false, 'Category');
         else
            xlxml_object.SetRange(tblForecast(idx).column_id || to_char(var_row_head,'FM999999990') || ':' || tblForecast(idx).column_id || to_char(var_row_head,'FM999999990'), null,
                                  xlxml_object.GetHeadingType(7), -2, 0, false, tblForecast(idx).for_yyyynn);
         end if;
      end loop;
      xlxml_object.SetHeadingBorder('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'TLR');
      xlxml_object.SetHeadingBorder('B' || to_char(var_row_head,'FM999999990') || ':B' || to_char(var_row_head,'FM999999990'), 'TLR');
      xlxml_object.SetHeadingBorder('C' || to_char(var_row_head,'FM999999990') || ':C' || to_char(var_row_head,'FM999999990'), 'TLR');
      xlxml_object.SetHeadingBorder('D' || to_char(var_row_head,'FM999999990') || ':D' || to_char(var_row_head,'FM999999990'), 'TLR');
      xlxml_object.SetHeadingBorder('E' || to_char(var_row_head,'FM999999990') || ':E' || to_char(var_row_head,'FM999999990'), 'TLR');
      xlxml_object.SetHeadingBorder('F' || to_char(var_row_head,'FM999999990') || ':F' || to_char(var_row_head,'FM999999990'), 'TLR');
      xlxml_object.SetHeadingBorder('G' || to_char(var_row_head,'FM999999990') || ':G' || to_char(var_row_head,'FM999999990'), 'TLR');
      xlxml_object.SetHeadingBorder('H' || to_char(var_row_head,'FM999999990') || ':H' || to_char(var_row_head,'FM999999990'), 'TLR');
      for idx in 1..tblForecast.count loop
         xlxml_object.SetHeadingBorder(tblForecast(idx).column_id || to_char(var_row_head,'FM999999990') || ':' || tblForecast(idx).column_id || to_char(var_row_head,'FM999999990'), 'TLR');
      end loop;

      /*-*/
      /* Initialise the row count */
      /*-*/
      var_row_count := var_row_head;

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
         xlxml_object.SetFreezeCell('A' || to_char(var_row_head + 1,'FM999999990'));
      end if;

      /*-*/
      /* Report when no details found */
      /*-*/
      if var_details = false then
         xlxml_object.SetRange('A' || to_char(var_row_head + 1,'FM999999990') || ':A' || to_char(var_row_head + 1,'FM999999990'), 'A' || to_char(var_row_head + 1,'FM999999990') || ':' || var_lst_column || to_char(var_row_head + 1,'FM999999990'), xlxml_object.TYPE_DETAIL, -2, 0, false, 'NO DETAILS EXIST');
         xlxml_object.SetRangeBorder('A' || to_char(var_row_head + 1,'FM999999990') || ':' || var_lst_column || to_char(var_row_head + 1,'FM999999990'));
      end if;

      /*-*/
      /* Report print settings */
      /*-*/
      xlxml_object.SetPrintData('$1:$' || to_char(var_row_head,'FM999999990'), '$A:$A', 2, 1, 0);
      if var_print_xml is not null then
         xlxml_object.SetPrintDataXML(var_print_xml);
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
      var_fil_literal varchar2(2048 char);
      var_slt_literal varchar2(2048 char);
      var_for_literal01 varchar2(2048 char);
      var_for_literal02 varchar2(2048 char);
      var_w101_val number(22,0);
      var_w102_val number(22,0);
      var_w103_val number(22,0);
      var_w104_val number(22,0);
      var_w105_val number(22,0);
      var_w106_val number(22,0);
      var_w107_val number(22,0);
      var_w108_val number(22,0);
      var_w109_val number(22,0);
      var_w110_val number(22,0);
      var_w111_val number(22,0);
      var_w112_val number(22,0);
      var_w113_val number(22,0);
      var_w201_val number(22,0);
      var_w202_val number(22,0);
      var_w203_val number(22,0);
      var_w204_val number(22,0);
      var_w205_val number(22,0);
      var_w206_val number(22,0);
      var_w207_val number(22,0);
      var_w208_val number(22,0);
      var_w209_val number(22,0);
      var_w210_val number(22,0);
      var_w211_val number(22,0);
      var_w212_val number(22,0);
      var_w213_val number(22,0);
      var_sav_w101_val number(22,0);
      var_sav_w102_val number(22,0);
      var_sav_w103_val number(22,0);
      var_sav_w104_val number(22,0);
      var_sav_w105_val number(22,0);
      var_sav_w106_val number(22,0);
      var_sav_w107_val number(22,0);
      var_sav_w108_val number(22,0);
      var_sav_w109_val number(22,0);
      var_sav_w110_val number(22,0);
      var_sav_w111_val number(22,0);
      var_sav_w112_val number(22,0);
      var_sav_w113_val number(22,0);
      var_sav_w201_val number(22,0);
      var_sav_w202_val number(22,0);
      var_sav_w203_val number(22,0);
      var_sav_w204_val number(22,0);
      var_sav_w205_val number(22,0);
      var_sav_w206_val number(22,0);
      var_sav_w207_val number(22,0);
      var_sav_w208_val number(22,0);
      var_sav_w209_val number(22,0);
      var_sav_w210_val number(22,0);
      var_sav_w211_val number(22,0);
      var_sav_w212_val number(22,0);
      var_sav_w213_val number(22,0);
      var_sap_material_code varchar2(18 char);
      var_material_desc_en varchar2(40 char);
      var_brand_flag_desc varchar2(128 char);
      var_brand_sub_flag_desc varchar2(128 char);
      var_prdct_pack_size_desc varchar2(128 char);
      var_multi_pack_qty_desc varchar2(128 char);
      var_cnsmr_pack_frmt_desc varchar2(128 char);
      var_planning_cat_cur varchar2(1 char);
      var_planning_cat_prv varchar2(1 char);
      var_planning_cat_old varchar2(1 char);
      var_wrk_src_unit varchar2(255 char);
      var_sav_sap_material_code varchar2(18 char);
      var_sav_material_desc_en varchar2(40 char);
      var_sav_brand_flag_desc varchar2(128 char);
      var_sav_brand_sub_flag_desc varchar2(128 char);
      var_sav_prdct_pack_size_desc varchar2(128 char);
      var_sav_multi_pack_qty_desc varchar2(128 char);
      var_sav_cnsmr_pack_frmt_desc varchar2(128 char);
      var_sav_planning_cat_cur varchar2(1 char);
      var_sav_planning_cat_prv varchar2(1 char);
      var_sav_planning_cat_old varchar2(1 char);
      var_saved_row number(15,0);
      var_wrk_count number(3,0);
      var_wrk_string varchar2(2048 char);
      var_wrk_array varchar2(4000 char);
      var_dynamic_sql varchar2(32767 char);
      type typCursor is ref cursor;
      dynamic_c01 typCursor;
      type typSrcUnit is table of varchar2(255 char) index by binary_integer;
      tblSrcUnit typSrcUnit;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the material list when no materials supplied
      /*-*/
      if var_material_count = 0 then

         /*-*/
         /* Build the selection string
         /*-*/
         var_slt_literal := null;
         if var_sap_bus_sgmnt_code is not null then
            var_slt_literal := var_slt_literal || ' and t01.sap_bus_sgmnt_code = ''' || var_sap_bus_sgmnt_code || '''';
         end if;
         if var_planning_type is not null then
            var_slt_literal := var_slt_literal || ' and t02.planning_type = ''' || var_planning_type || '''';
         end if;
         if var_planning_src_unit is not null then
            var_slt_literal := var_slt_literal || ' and t02.planning_src_unit = ''' || var_planning_src_unit || '''';
         end if;
         if var_planning_status is not null then
            var_slt_literal := var_slt_literal || ' and t02.planning_status = ''' || var_planning_status || '''';
         end if;
         if var_planning_category is not null then
            var_slt_literal := var_slt_literal || ' and t02.planning_category = ''' || var_planning_category || '''';
         end if;
         if var_brand_flag_count <> 0 then
            var_fil_literal := var_fil_literal || ', pld_variable t81';
            var_slt_literal := var_slt_literal || ' and (t81.var_type = ''BRAND_FLAG'' and t81.var_code = t01.sap_brand_flag_code)';
         end if;
         if var_brand_sub_flag_count <> 0 then
            var_fil_literal := var_fil_literal || ', pld_variable t82';
            var_slt_literal := var_slt_literal || ' and (t82.var_type = ''BRAND_SUB_FLAG'' and t82.var_code = t01.sap_brand_sub_flag_code)';
         end if;
         if var_prdct_pack_size_count <> 0 then
            var_fil_literal := var_fil_literal || ', pld_variable t83';
            var_slt_literal := var_slt_literal || ' and (t83.var_type = ''PRDCT_PACK_SIZE'' and t83.var_code = t01.sap_prdct_pack_size_code)';
         end if;
         if var_multi_pack_qty_count <> 0 then
            var_fil_literal := var_fil_literal || ', pld_variable t84';
            var_slt_literal := var_slt_literal || ' and (t84.var_type = ''MULTI_PACK_QTY'' and t84.var_code = t01.sap_multi_pack_qty_code)';
         end if;
         if var_cnsmr_pack_frmt_count <> 0 then
            var_fil_literal := var_fil_literal || ', pld_variable t85';
            var_slt_literal := var_slt_literal || ' and (t85.var_type = ''CNSMR_PACK_FRMT'' and t85.var_code = t01.sap_cnsmr_pack_frmt_code)';
         end if;

         /*-*/
         /* Retrieve the materials that satisfy the selections
         /*-*/
         var_dynamic_sql := 'select t03.sap_material_code
                               from material_dim t01,
                                    pld_for_format0201 t02,
                                    material_dim t03' || var_fil_literal || '
                              where t01.sap_material_code = t02.sap_material_code
                                and t01.sap_rep_item_code = t03.sap_material_code' || var_slt_literal || '
                           group by t03.sap_material_code';
         open dynamic_c01 for var_dynamic_sql;
         loop
            fetch dynamic_c01 into var_sap_material_code;
            if dynamic_c01%notfound then
               exit;
            end if;
            insert into pld_variable
                (var_type,
                var_code)
            values('REPORTED',
                   var_sap_material_code);
         end loop;
         close dynamic_c01;
         commit;

      else

         /*-*/
         /* Retrieve the materials that satisfy the selections
         /*-*/
         var_dynamic_sql := 'select t03.sap_material_code
                               from pld_variable t01,
                                    material_dim t02,
                                    material_dim t03
                              where t01.var_type = ''MATERIAL''
                                and t01.var_code = t02.sap_material_code
                                and t02.sap_rep_item_code = t03.sap_material_code
                           group by t03.sap_material_code';
         open dynamic_c01 for var_dynamic_sql;
         loop
            fetch dynamic_c01 into var_sap_material_code;
            if dynamic_c01%notfound then
               exit;
            end if;
            insert into pld_variable
                (var_type,
                var_code)
            values('REPORTED',
                   var_sap_material_code);
         end loop;
         close dynamic_c01;
         commit;

      end if;

      /*-*/
      /* Initialise the detail query based on forecast type */
      /*-*/
      if var_for_type = 'PRD' then

         /*-*/
         /* Initialise the forecast literal */
         /*-*/
         var_for_literal01 := null;
         var_for_literal02 := null;
         var_wrk_count := 1;
         for idx in 1..tblForecast.count loop
            if tblForecast(idx).for_category = '0' then
               var_for_literal01 := var_for_literal01 || ', sum(case when t01.fcst_yyyypp = ' || tblForecast(idx).for_yyyynn || ' and t01.casting_yyyypp = ' || tblForecast(idx).aso_yyyynn || ' then t01.case_qty end) w' || to_char(var_wrk_count,'FM00') || '_qty';
               var_for_literal02 := var_for_literal02 || ', sum(case when t01.fcst_yyyypp = ' || tblForecast(idx).for_yyyynn || ' then t01.case_qty end) w' || to_char(var_wrk_count,'FM00') || '_qty';
               var_wrk_count := var_wrk_count + 1;
            end if;
         end loop;
         for idx in var_wrk_count..13 loop
            var_for_literal01 := var_for_literal01 || ', sum(0) w' || to_char(idx,'FM00') || '_qty';
            var_for_literal02 := var_for_literal02 || ', sum(0) w' || to_char(idx,'FM00') || '_qty';
         end loop;

         /*-*/
         /* Initialise the dynamic literal - summary */
         /*-*/
         var_dynamic_sql := 'select t02.sap_material_code,
                                    max(t02.material_desc_en),
                                    max(t02.brand_flag_desc),
                                    max(t02.brand_sub_flag_desc),
                                    max(t02.prdct_pack_size_desc),
                                    max(t02.multi_pack_qty_desc),
                                    max(t02.cnsmr_pack_frmt_desc),
                                    t04.planning_src_unit,
                                    min(t05.planning_category),
                                    min(t05.planning_cat_prv),
                                    min(t05.planning_cat_old),
                                    nvl(sum(t06.w01_qty),0),
                                    nvl(sum(t06.w02_qty),0),
                                    nvl(sum(t06.w03_qty),0),
                                    nvl(sum(t06.w04_qty),0),
                                    nvl(sum(t06.w05_qty),0),
                                    nvl(sum(t06.w06_qty),0),
                                    nvl(sum(t06.w07_qty),0),
                                    nvl(sum(t06.w08_qty),0),
                                    nvl(sum(t06.w09_qty),0),
                                    nvl(sum(t06.w10_qty),0),
                                    nvl(sum(t06.w11_qty),0),
                                    nvl(sum(t06.w12_qty),0),
                                    nvl(sum(t06.w13_qty),0),
                                    nvl(sum(t07.w01_qty),0),
                                    nvl(sum(t07.w02_qty),0),
                                    nvl(sum(t07.w03_qty),0),
                                    nvl(sum(t07.w04_qty),0),
                                    nvl(sum(t07.w05_qty),0),
                                    nvl(sum(t07.w06_qty),0),
                                    nvl(sum(t07.w07_qty),0),
                                    nvl(sum(t07.w08_qty),0),
                                    nvl(sum(t07.w09_qty),0),
                                    nvl(sum(t07.w10_qty),0),
                                    nvl(sum(t07.w11_qty),0),
                                    nvl(sum(t07.w12_qty),0),
                                    nvl(sum(t07.w13_qty),0)
                               from pld_variable t01,
                                    material_dim t02,
                                    material_dim t03,
                                    pld_for_format0201 t04,
                                    (select t02.sap_rep_item_code sap_rep_item_code,
                                            min(t01.planning_category) planning_category,
                                            min(t01.planning_cat_prv) planning_cat_prv,
                                            min(t01.planning_cat_old) planning_cat_old
                                       from pld_for_format0201 t01,
                                            material_dim t02
                                      where t01.sap_material_code = t02.sap_material_code
                                   group by t02.sap_rep_item_code) t05,
                                    (select t01.sap_material_code sap_material_code
                                            ' || var_for_literal01 || '
                                       from pld_for_format0203 t01
                                      where t01.casting_yyyypp <> 999999
                                        and t01.fcst_yyyypp >= ' || to_char(var_for_str,'FM000000') || '
                                        and t01.fcst_yyyypp <= ' || to_char(var_for_end,'FM000000') || '
                                   group by t01.sap_material_code) t06,
                                    (select t01.sap_material_code sap_material_code
                                            ' || var_for_literal02 || '
                                       from pld_for_format0203 t01
                                      where t01.casting_yyyypp = 999999
                                        and t01.fcst_yyyypp >= ' || to_char(var_for_str,'FM000000') || '
                                        and t01.fcst_yyyypp <= ' || to_char(var_for_end,'FM000000') || '
                                   group by t01.sap_material_code) t07
                              where t01.var_type = ''REPORTED''
                                and t01.var_code = t02.sap_material_code
                                and t02.sap_material_code = t03.sap_rep_item_code
                                and t02.sap_material_code = t05.sap_rep_item_code
                                and t03.sap_material_code = t04.sap_material_code
                                and t03.sap_material_code = t06.sap_material_code(+)
                                and t03.sap_material_code = t07.sap_material_code(+)
                                and t04.planning_src_unit is not null
                                and (nvl(t05.planning_category,''X'') <> ''X'' or
                                     nvl(t05.planning_cat_prv,''X'') <> ''X'' or
                                     nvl(t05.planning_cat_old,''X'') <> ''X'')
                                and (nvl(t06.w01_qty,0) <> 0 or
                                     nvl(t06.w02_qty,0) <> 0 or
                                     nvl(t06.w03_qty,0) <> 0 or
                                     nvl(t06.w04_qty,0) <> 0 or
                                     nvl(t06.w05_qty,0) <> 0 or
                                     nvl(t06.w06_qty,0) <> 0 or
                                     nvl(t06.w07_qty,0) <> 0 or
                                     nvl(t06.w08_qty,0) <> 0 or
                                     nvl(t06.w09_qty,0) <> 0 or
                                     nvl(t06.w10_qty,0) <> 0 or
                                     nvl(t06.w11_qty,0) <> 0 or
                                     nvl(t06.w12_qty,0) <> 0 or
                                     nvl(t06.w13_qty,0) <> 0 or
                                     nvl(t07.w01_qty,0) <> 0 or
                                     nvl(t07.w02_qty,0) <> 0 or
                                     nvl(t07.w03_qty,0) <> 0 or
                                     nvl(t07.w04_qty,0) <> 0 or
                                     nvl(t07.w05_qty,0) <> 0 or
                                     nvl(t07.w06_qty,0) <> 0 or
                                     nvl(t07.w07_qty,0) <> 0 or
                                     nvl(t07.w08_qty,0) <> 0 or
                                     nvl(t07.w09_qty,0) <> 0 or
                                     nvl(t07.w10_qty,0) <> 0 or
                                     nvl(t07.w11_qty,0) <> 0 or
                                     nvl(t07.w12_qty,0) <> 0 or
                                     nvl(t07.w13_qty,0) <> 0)
                           group by t02.sap_material_code,
                                    t04.planning_src_unit
                           order by t02.sap_material_code asc,
                                    t04.planning_src_unit asc';

      elsif var_for_type = 'MTH' then

         /*-*/
         /* Initialise the forecast and actual literals */
         /*-*/
         var_for_literal01 := null;
         var_for_literal02 := null;
         var_wrk_count := 1;
         for idx in 1..tblForecast.count loop
            if tblForecast(idx).for_category = '0' then
               var_for_literal01 := var_for_literal01 || ', sum(case when t01.fcst_yyyymm = ' || tblForecast(idx).for_yyyynn || ' and t01.casting_yyyymm = ' || tblForecast(idx).aso_yyyynn || ' then t01.case_qty end) w' || to_char(var_wrk_count,'FM00') || '_qty';
               var_for_literal02 := var_for_literal02 || ', sum(case when t01.fcst_yyyymm = ' || tblForecast(idx).for_yyyynn || ' then t01.case_qty end) w' || to_char(var_wrk_count,'FM00') || '_qty';
               var_wrk_count := var_wrk_count + 1;
            end if;
         end loop;
         for idx in var_wrk_count..12 loop
            var_for_literal01 := var_for_literal01 || ', sum(0) w' || to_char(idx,'FM00') || '_qty';
            var_for_literal02 := var_for_literal02 || ', sum(0) w' || to_char(idx,'FM00') || '_qty';
         end loop;

         /*-*/
         /* Initialise the dynamic literal - summary */
         /*-*/
         var_dynamic_sql := 'select t02.sap_material_code,
                                    max(t02.material_desc_en),
                                    max(t02.brand_flag_desc),
                                    max(t02.brand_sub_flag_desc),
                                    max(t02.prdct_pack_size_desc),
                                    max(t02.multi_pack_qty_desc),
                                    max(t02.cnsmr_pack_frmt_desc),
                                    t04.planning_src_unit,
                                    min(t05.planning_category),
                                    min(t05.planning_cat_prv),
                                    min(t05.planning_cat_old),
                                    nvl(sum(t06.w01_qty),0),
                                    nvl(sum(t06.w02_qty),0),
                                    nvl(sum(t06.w03_qty),0),
                                    nvl(sum(t06.w04_qty),0),
                                    nvl(sum(t06.w05_qty),0),
                                    nvl(sum(t06.w06_qty),0),
                                    nvl(sum(t06.w07_qty),0),
                                    nvl(sum(t06.w08_qty),0),
                                    nvl(sum(t06.w09_qty),0),
                                    nvl(sum(t06.w10_qty),0),
                                    nvl(sum(t06.w11_qty),0),
                                    nvl(sum(t06.w12_qty),0),
                                    nvl(sum(t07.w01_qty),0),
                                    nvl(sum(t07.w02_qty),0),
                                    nvl(sum(t07.w03_qty),0),
                                    nvl(sum(t07.w04_qty),0),
                                    nvl(sum(t07.w05_qty),0),
                                    nvl(sum(t07.w06_qty),0),
                                    nvl(sum(t07.w07_qty),0),
                                    nvl(sum(t07.w08_qty),0),
                                    nvl(sum(t07.w09_qty),0),
                                    nvl(sum(t07.w10_qty),0),
                                    nvl(sum(t07.w11_qty),0),
                                    nvl(sum(t07.w12_qty),0)
                               from pld_variable t01,
                                    material_dim t02,
                                    material_dim t03,
                                    pld_for_format0201 t04,
                                    (select t02.sap_rep_item_code sap_rep_item_code,
                                            min(t01.planning_category) planning_category,
                                            min(t01.planning_cat_prv) planning_cat_prv,
                                            min(t01.planning_cat_old) planning_cat_old
                                       from pld_for_format0201 t01,
                                            material_dim t02
                                      where t01.sap_material_code = t02.sap_material_code
                                   group by t02.sap_rep_item_code) t05,
                                    (select t01.sap_material_code sap_material_code
                                            ' || var_for_literal01 || '
                                       from pld_for_format0204 t01
                                      where t01.casting_yyyymm <> 999999
                                        and t01.fcst_yyyymm >= ' || to_char(var_for_str,'FM000000') || '
                                        and t01.fcst_yyyymm <= ' || to_char(var_for_end,'FM000000') || '
                                   group by t01.sap_material_code) t06,
                                    (select t01.sap_material_code sap_material_code
                                            ' || var_for_literal02 || '
                                       from pld_for_format0204 t01
                                      where t01.casting_yyyymm = 999999
                                        and t01.fcst_yyyymm >= ' || to_char(var_for_str,'FM000000') || '
                                        and t01.fcst_yyyymm <= ' || to_char(var_for_end,'FM000000') || '
                                   group by t01.sap_material_code) t07
                              where t01.var_type = ''REPORTED''
                                and t01.var_code = t02.sap_material_code
                                and t02.sap_material_code = t03.sap_rep_item_code
                                and t02.sap_material_code = t05.sap_rep_item_code
                                and t03.sap_material_code = t04.sap_material_code
                                and t03.sap_material_code = t06.sap_material_code(+)
                                and t03.sap_material_code = t07.sap_material_code(+)
                                and t04.planning_src_unit is not null
                                and (nvl(t05.planning_category,''X'') <> ''X'' or
                                     nvl(t05.planning_cat_prv,''X'') <> ''X'' or
                                     nvl(t05.planning_cat_old,''X'') <> ''X'')
                                and (nvl(t06.w01_qty,0) <> 0 or
                                     nvl(t06.w02_qty,0) <> 0 or
                                     nvl(t06.w03_qty,0) <> 0 or
                                     nvl(t06.w04_qty,0) <> 0 or
                                     nvl(t06.w05_qty,0) <> 0 or
                                     nvl(t06.w06_qty,0) <> 0 or
                                     nvl(t06.w07_qty,0) <> 0 or
                                     nvl(t06.w08_qty,0) <> 0 or
                                     nvl(t06.w09_qty,0) <> 0 or
                                     nvl(t06.w10_qty,0) <> 0 or
                                     nvl(t06.w11_qty,0) <> 0 or
                                     nvl(t06.w12_qty,0) <> 0 or
                                     nvl(t07.w01_qty,0) <> 0 or
                                     nvl(t07.w02_qty,0) <> 0 or
                                     nvl(t07.w03_qty,0) <> 0 or
                                     nvl(t07.w04_qty,0) <> 0 or
                                     nvl(t07.w05_qty,0) <> 0 or
                                     nvl(t07.w06_qty,0) <> 0 or
                                     nvl(t07.w07_qty,0) <> 0 or
                                     nvl(t07.w08_qty,0) <> 0 or
                                     nvl(t07.w09_qty,0) <> 0 or
                                     nvl(t07.w10_qty,0) <> 0 or
                                     nvl(t07.w11_qty,0) <> 0 or
                                     nvl(t07.w12_qty,0) <> 0)
                           group by t02.sap_material_code,
                                    t04.planning_src_unit
                           order by t02.sap_material_code asc,
                                    t04.planning_src_unit asc';

      end if;

      /*-*/
      /* Retrieve the detail rows */
      /*-*/
      var_sav_sap_material_code := '******************';
      open dynamic_c01 for var_dynamic_sql;
      loop
         if var_for_type = 'PRD' then
            fetch dynamic_c01 into var_sap_material_code,
                                   var_material_desc_en,
                                   var_brand_flag_desc,
                                   var_brand_sub_flag_desc,
                                   var_prdct_pack_size_desc,
                                   var_multi_pack_qty_desc,
                                   var_cnsmr_pack_frmt_desc,
                                   var_wrk_src_unit,
                                   var_planning_cat_cur,
                                   var_planning_cat_prv,
                                   var_planning_cat_old,
                                   var_w101_val,
                                   var_w102_val,
                                   var_w103_val,
                                   var_w104_val,
                                   var_w105_val,
                                   var_w106_val,
                                   var_w107_val,
                                   var_w108_val,
                                   var_w109_val,
                                   var_w110_val,
                                   var_w111_val,
                                   var_w112_val,
                                   var_w113_val,
                                   var_w201_val,
                                   var_w202_val,
                                   var_w203_val,
                                   var_w204_val,
                                   var_w205_val,
                                   var_w206_val,
                                   var_w207_val,
                                   var_w208_val,
                                   var_w209_val,
                                   var_w210_val,
                                   var_w211_val,
                                   var_w212_val,
                                   var_w213_val;
         elsif var_for_type = 'MTH' then
            fetch dynamic_c01 into var_sap_material_code,
                                   var_material_desc_en,
                                   var_brand_flag_desc,
                                   var_brand_sub_flag_desc,
                                   var_prdct_pack_size_desc,
                                   var_multi_pack_qty_desc,
                                   var_cnsmr_pack_frmt_desc,
                                   var_wrk_src_unit,
                                   var_planning_cat_cur,
                                   var_planning_cat_prv,
                                   var_planning_cat_old,
                                   var_w101_val,
                                   var_w102_val,
                                   var_w103_val,
                                   var_w104_val,
                                   var_w105_val,
                                   var_w106_val,
                                   var_w107_val,
                                   var_w108_val,
                                   var_w109_val,
                                   var_w110_val,
                                   var_w111_val,
                                   var_w112_val,
                                   var_w201_val,
                                   var_w202_val,
                                   var_w203_val,
                                   var_w204_val,
                                   var_w205_val,
                                   var_w206_val,
                                   var_w207_val,
                                   var_w208_val,
                                   var_w209_val,
                                   var_w210_val,
                                   var_w211_val,
                                   var_w212_val;
         end if;
         if dynamic_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Output the SAP material code summary when required */
         /*-*/
         if var_sap_material_code <> var_sav_sap_material_code then

            /*-*/
            /* Change of summary material */
            /*-*/
            if var_sav_sap_material_code <> '******************' then

               /*-*/
               /* Border the previous material when required */
               /*-*/
               if var_details = true then
                  xlxml_object.SetRangeBorder('A' || to_char(var_saved_row,'FM999999990') || ':' || var_lst_column || to_char(var_row_count,'FM999999990'));
               end if;

               /*-*/
               /* Set the control information */
               /*-*/
               var_details := true;
               var_row_count := var_row_count + 1;
               var_saved_row := var_row_count;

               /*-*/
               /* Detail fixed columns */
               /*-*/
               var_wrk_array := var_sav_sap_material_code;
               var_wrk_array := var_wrk_array || chr(9) || var_sav_material_desc_en;
               var_wrk_array := var_wrk_array || chr(9) || var_sav_brand_flag_desc;
               var_wrk_array := var_wrk_array || chr(9) || var_sav_brand_sub_flag_desc;
               var_wrk_array := var_wrk_array || chr(9) || var_sav_prdct_pack_size_desc;
               var_wrk_array := var_wrk_array || chr(9) || var_sav_multi_pack_qty_desc;
               var_wrk_array := var_wrk_array || chr(9) || var_sav_cnsmr_pack_frmt_desc;
               var_wrk_array := var_wrk_array || chr(9);
               if tblSrcUnit.count >= 1 then
                  var_wrk_array := var_wrk_array || tblSrcUnit(1);
               end if;

               /*-*/
               /* Detail variable columns */
               /*-*/
               var_wrk_count := 0;
               for idx in 1..tblForecast.count loop
                  if tblForecast(idx).for_category = '0' then
                     var_wrk_count := var_wrk_count + 1;
                     if var_wrk_count = 1 then
                        if var_sav_w101_val <> 0 then
                           var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w201_val / var_sav_w101_val) * 100, 2),'FM9999990.00');
                        else
                           if var_sav_w201_val <> 0 then
                              var_wrk_array := var_wrk_array || chr(9) || 'NF';
                           else
                              var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                           end if;
                        end if;
                     elsif var_wrk_count = 2 then
                        if var_sav_w102_val <> 0 then
                           var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w202_val / var_sav_w102_val) * 100, 2),'FM9999990.00');
                        else
                           if var_sav_w202_val <> 0 then
                              var_wrk_array := var_wrk_array || chr(9) || 'NF';
                           else
                              var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                           end if;
                        end if;
                     elsif var_wrk_count = 3 then
                        if var_sav_w103_val <> 0 then
                           var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w203_val / var_sav_w103_val) * 100, 2),'FM9999990.00');
                        else
                           if var_sav_w203_val <> 0 then
                              var_wrk_array := var_wrk_array || chr(9) || 'NF';
                           else
                              var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                           end if;
                        end if;
                     elsif var_wrk_count = 4 then
                        if var_sav_w104_val <> 0 then
                           var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w204_val / var_sav_w104_val) * 100, 2),'FM9999990.00');
                        else
                           if var_sav_w204_val <> 0 then
                              var_wrk_array := var_wrk_array || chr(9) || 'NF';
                           else
                              var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                           end if;
                        end if;
                     elsif var_wrk_count = 5 then
                        if var_sav_w105_val <> 0 then
                           var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w205_val / var_sav_w105_val) * 100, 2),'FM9999990.00');
                        else
                           if var_sav_w205_val <> 0 then
                              var_wrk_array := var_wrk_array || chr(9) || 'NF';
                           else
                              var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                           end if;
                        end if;
                     elsif var_wrk_count = 6 then
                        if var_sav_w106_val <> 0 then
                           var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w206_val / var_sav_w106_val) * 100, 2),'FM9999990.00');
                        else
                           if var_sav_w206_val <> 0 then
                              var_wrk_array := var_wrk_array || chr(9) || 'NF';
                           else
                              var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                           end if;
                        end if;
                     elsif var_wrk_count = 7 then
                        if var_sav_w107_val <> 0 then
                           var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w207_val / var_sav_w107_val) * 100, 2),'FM9999990.00');
                        else
                           if var_sav_w207_val <> 0 then
                              var_wrk_array := var_wrk_array || chr(9) || 'NF';
                           else
                              var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                           end if;
                        end if;
                     elsif var_wrk_count = 8 then
                        if var_sav_w108_val <> 0 then
                           var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w208_val / var_sav_w108_val) * 100, 2),'FM9999990.00');
                        else
                           if var_sav_w208_val <> 0 then
                              var_wrk_array := var_wrk_array || chr(9) || 'NF';
                           else
                              var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                           end if;
                        end if;
                     elsif var_wrk_count = 9 then
                        if var_sav_w109_val <> 0 then
                           var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w209_val / var_sav_w109_val) * 100, 2),'FM9999990.00');
                        else
                           if var_sav_w209_val <> 0 then
                              var_wrk_array := var_wrk_array || chr(9) || 'NF';
                           else
                              var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                           end if;
                        end if;
                     elsif var_wrk_count = 10 then
                        if var_sav_w110_val <> 0 then
                           var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w210_val / var_sav_w110_val) * 100, 2),'FM9999990.00');
                        else
                           if var_sav_w210_val <> 0 then
                              var_wrk_array := var_wrk_array || chr(9) || 'NF';
                           else
                              var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                           end if;
                        end if;
                     elsif var_wrk_count = 11 then
                        if var_sav_w111_val <> 0 then
                           var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w211_val / var_sav_w111_val) * 100, 2),'FM9999990.00');
                        else
                           if var_sav_w211_val <> 0 then
                              var_wrk_array := var_wrk_array || chr(9) || 'NF';
                           else
                              var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                           end if;
                        end if;
                     elsif var_wrk_count = 12 then
                        if var_sav_w112_val <> 0 then
                           var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w212_val / var_sav_w112_val) * 100, 2),'FM9999990.00');
                        else
                           if var_sav_w212_val <> 0 then
                              var_wrk_array := var_wrk_array || chr(9) || 'NF';
                           else
                              var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                           end if;
                        end if;
                     elsif var_wrk_count = 13 then
                        if var_sav_w113_val <> 0 then
                           var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w213_val / var_sav_w113_val) * 100, 2),'FM9999990.00');
                        else
                           if var_sav_w213_val <> 0 then
                              var_wrk_array := var_wrk_array || chr(9) || 'NF';
                           else
                              var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                           end if;
                        end if;
                     end if;
                  elsif tblForecast(idx).for_category = '1' then
                     var_wrk_array := var_wrk_array || chr(9) || var_sav_planning_cat_cur;
                  elsif tblForecast(idx).for_category = '2' then
                     var_wrk_array := var_wrk_array || chr(9) || var_sav_planning_cat_prv;
                  elsif tblForecast(idx).for_category = '3' then
                     var_wrk_array := var_wrk_array || chr(9) || var_sav_planning_cat_old;
                  end if;
               end loop;

               /*-*/
               /* Create the detail row */
               /*-*/
               xlxml_object.SetRangeArray('A' || to_char(var_row_count,'FM999999990') || ':A' || to_char(var_row_count,'FM999999990'),
                                          'A' || to_char(var_row_count,'FM999999990') || ':' || var_lst_column || to_char(var_row_count,'FM999999990'),
                                          xlxml_object.TYPE_DETAIL, -9, var_wrk_array);

               /*-*/
               /* Detail variable additional source unit columns */
               /*-*/
               for idx in 2..tblSrcUnit.count loop

                  var_row_count := var_row_count + 1;
                  var_wrk_array := chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9);
                  var_wrk_array := var_wrk_array || tblSrcUnit(idx);
                  for idx1 in 1..tblForecast.count loop
                     var_wrk_array := var_wrk_array || chr(9);
                  end loop;

                  /*-*/
                  /* Create the detail row */
                  /*-*/
                  xlxml_object.SetRangeArray('A' || to_char(var_row_count,'FM999999990') || ':A' || to_char(var_row_count,'FM999999990'),
                                             'A' || to_char(var_row_count,'FM999999990') || ':' || var_lst_column || to_char(var_row_count,'FM999999990'),
                                             xlxml_object.TYPE_DETAIL, -9, var_wrk_array);

               end loop;

            end if;

            /*-*/
            /* Initialise the material summary data */
            /*-*/
            var_sav_sap_material_code := var_sap_material_code;
            var_sav_material_desc_en := var_material_desc_en;
            var_sav_brand_flag_desc := var_brand_flag_desc;
            var_sav_brand_sub_flag_desc := var_brand_sub_flag_desc;
            var_sav_prdct_pack_size_desc := var_prdct_pack_size_desc;
            var_sav_multi_pack_qty_desc := var_multi_pack_qty_desc;
            var_sav_cnsmr_pack_frmt_desc := var_cnsmr_pack_frmt_desc;
            var_sav_planning_cat_cur := 'X';
            var_sav_planning_cat_prv := 'X';
            var_sav_planning_cat_old := 'X';
            var_sav_w101_val := 0;
            var_sav_w102_val := 0;
            var_sav_w103_val := 0;
            var_sav_w104_val := 0;
            var_sav_w105_val := 0;
            var_sav_w106_val := 0;
            var_sav_w107_val := 0;
            var_sav_w108_val := 0;
            var_sav_w109_val := 0;
            var_sav_w110_val := 0;
            var_sav_w111_val := 0;
            var_sav_w112_val := 0;
            var_sav_w113_val := 0;
            var_sav_w201_val := 0;
            var_sav_w202_val := 0;
            var_sav_w203_val := 0;
            var_sav_w204_val := 0;
            var_sav_w205_val := 0;
            var_sav_w206_val := 0;
            var_sav_w207_val := 0;
            var_sav_w208_val := 0;
            var_sav_w209_val := 0;
            var_sav_w210_val := 0;
            var_sav_w211_val := 0;
            var_sav_w212_val := 0;
            var_sav_w213_val := 0;
            tblSrcUnit.delete;

         end if;

         /*-*/
         /* Set the summary category values */
         /*-*/
         if var_planning_cat_cur < var_sav_planning_cat_cur then
            var_sav_planning_cat_cur := var_planning_cat_cur;
         end if;
         if var_planning_cat_prv < var_sav_planning_cat_prv then
            var_sav_planning_cat_prv := var_planning_cat_prv;
         end if;
         if var_planning_cat_old< var_sav_planning_cat_old then
            var_sav_planning_cat_old := var_planning_cat_old;
         end if;

         /*-*/
         /* Accumulate the summary material values */
         /*-*/
         var_sav_w101_val := var_sav_w101_val + var_w101_val;
         var_sav_w102_val := var_sav_w102_val + var_w102_val;
         var_sav_w103_val := var_sav_w103_val + var_w103_val;
         var_sav_w104_val := var_sav_w104_val + var_w104_val;
         var_sav_w105_val := var_sav_w105_val + var_w105_val;
         var_sav_w106_val := var_sav_w106_val + var_w106_val;
         var_sav_w107_val := var_sav_w107_val + var_w107_val;
         var_sav_w108_val := var_sav_w108_val + var_w108_val;
         var_sav_w109_val := var_sav_w109_val + var_w109_val;
         var_sav_w110_val := var_sav_w110_val + var_w110_val;
         var_sav_w111_val := var_sav_w111_val + var_w111_val;
         var_sav_w112_val := var_sav_w112_val + var_w112_val;
         if var_for_type = 'PRD' then
            var_sav_w113_val := var_sav_w113_val + var_w113_val;
         end if;
         var_sav_w201_val := var_sav_w201_val + var_w201_val;
         var_sav_w202_val := var_sav_w202_val + var_w202_val;
         var_sav_w203_val := var_sav_w203_val + var_w203_val;
         var_sav_w204_val := var_sav_w204_val + var_w204_val;
         var_sav_w205_val := var_sav_w205_val + var_w205_val;
         var_sav_w206_val := var_sav_w206_val + var_w206_val;
         var_sav_w207_val := var_sav_w207_val + var_w207_val;
         var_sav_w208_val := var_sav_w208_val + var_w208_val;
         var_sav_w209_val := var_sav_w209_val + var_w209_val;
         var_sav_w210_val := var_sav_w210_val + var_w210_val;
         var_sav_w211_val := var_sav_w211_val + var_w211_val;
         var_sav_w212_val := var_sav_w212_val + var_w212_val;
         if var_for_type = 'PRD' then
            var_sav_w213_val := var_sav_w213_val + var_w213_val;
         end if;

         /*-*/
         /* Load the source unit table */
         /*-*/
         tblSrcUnit(tblSrcUnit.count + 1) := var_wrk_src_unit;

      end loop;
      close dynamic_c01;

      /*-*/
      /* Last summary material when required */
      /*-*/
      if var_sav_sap_material_code <> '******************' then

         /*-*/
         /* Border the previous material when required */
         /*-*/
         if var_details = true then
            xlxml_object.SetRangeBorder('A' || to_char(var_saved_row,'FM999999990') || ':' || var_lst_column || to_char(var_row_count,'FM999999990'));
         end if;

         /*-*/
         /* Set the control information */
         /*-*/
         var_details := true;
         var_row_count := var_row_count + 1;
         var_saved_row := var_row_count;

         /*-*/
         /* Detail fixed columns */
         /*-*/
         var_wrk_array := var_sav_sap_material_code;
         var_wrk_array := var_wrk_array || chr(9) || var_sav_material_desc_en;
         var_wrk_array := var_wrk_array || chr(9) || var_sav_brand_flag_desc;
         var_wrk_array := var_wrk_array || chr(9) || var_sav_brand_sub_flag_desc;
         var_wrk_array := var_wrk_array || chr(9) || var_sav_prdct_pack_size_desc;
         var_wrk_array := var_wrk_array || chr(9) || var_sav_multi_pack_qty_desc;
         var_wrk_array := var_wrk_array || chr(9) || var_sav_cnsmr_pack_frmt_desc;
         var_wrk_array := var_wrk_array || chr(9);
         if tblSrcUnit.count >= 1 then
            var_wrk_array := var_wrk_array || tblSrcUnit(1);
         end if;

         /*-*/
         /* Detail variable columns */
         /*-*/
         var_wrk_count := 0;
         for idx in 1..tblForecast.count loop
            if tblForecast(idx).for_category = '0' then
               var_wrk_count := var_wrk_count + 1;
               if var_wrk_count = 1 then
                  if var_sav_w101_val <> 0 then
                     var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w201_val / var_sav_w101_val) * 100, 2),'FM9999990.00');
                  else
                     if var_sav_w201_val <> 0 then
                        var_wrk_array := var_wrk_array || chr(9) || 'NF';
                     else
                        var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                     end if;
                  end if;
               elsif var_wrk_count = 2 then
                  if var_sav_w102_val <> 0 then
                     var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w202_val / var_sav_w102_val) * 100, 2),'FM9999990.00');
                  else
                     if var_sav_w202_val <> 0 then
                        var_wrk_array := var_wrk_array || chr(9) || 'NF';
                     else
                        var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                     end if;
                  end if;
               elsif var_wrk_count = 3 then
                  if var_sav_w103_val <> 0 then
                     var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w203_val / var_sav_w103_val) * 100, 2),'FM9999990.00');
                  else
                     if var_sav_w203_val <> 0 then
                        var_wrk_array := var_wrk_array || chr(9) || 'NF';
                     else
                        var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                     end if;
                  end if;
               elsif var_wrk_count = 4 then
                  if var_sav_w104_val <> 0 then
                    var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w204_val / var_sav_w104_val) * 100, 2),'FM9999990.00');
                  else
                     if var_sav_w204_val <> 0 then
                        var_wrk_array := var_wrk_array || chr(9) || 'NF';
                     else
                        var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                     end if;
                  end if;
               elsif var_wrk_count = 5 then
                  if var_sav_w105_val <> 0 then
                     var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w205_val / var_sav_w105_val) * 100, 2),'FM9999990.00');
                  else
                     if var_sav_w205_val <> 0 then
                        var_wrk_array := var_wrk_array || chr(9) || 'NF';
                     else
                        var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                     end if;
                  end if;
               elsif var_wrk_count = 6 then
                  if var_sav_w106_val <> 0 then
                     var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w206_val / var_sav_w106_val) * 100, 2),'FM9999990.00');
                  else
                     if var_sav_w206_val <> 0 then
                        var_wrk_array := var_wrk_array || chr(9) || 'NF';
                     else
                        var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                     end if;
                  end if;
               elsif var_wrk_count = 7 then
                  if var_sav_w107_val <> 0 then
                     var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w207_val / var_sav_w107_val) * 100, 2),'FM9999990.00');
                  else
                     if var_sav_w207_val <> 0 then
                        var_wrk_array := var_wrk_array || chr(9) || 'NF';
                     else
                        var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                     end if;
                  end if;
               elsif var_wrk_count = 8 then
                  if var_sav_w108_val <> 0 then
                     var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w208_val / var_sav_w108_val) * 100, 2),'FM9999990.00');
                  else
                     if var_sav_w208_val <> 0 then
                        var_wrk_array := var_wrk_array || chr(9) || 'NF';
                     else
                        var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                     end if;
                  end if;
               elsif var_wrk_count = 9 then
                  if var_sav_w109_val <> 0 then
                     var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w209_val / var_sav_w109_val) * 100, 2),'FM9999990.00');
                  else
                     if var_sav_w209_val <> 0 then
                        var_wrk_array := var_wrk_array || chr(9) || 'NF';
                     else
                        var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                     end if;
                  end if;
               elsif var_wrk_count = 10 then
                  if var_sav_w110_val <> 0 then
                     var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w210_val / var_sav_w110_val) * 100, 2),'FM9999990.00');
                  else
                     if var_sav_w210_val <> 0 then
                        var_wrk_array := var_wrk_array || chr(9) || 'NF';
                     else
                        var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                     end if;
                  end if;
               elsif var_wrk_count = 11 then
                  if var_sav_w111_val <> 0 then
                     var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w211_val / var_sav_w111_val) * 100, 2),'FM9999990.00');
                  else
                     if var_sav_w211_val <> 0 then
                        var_wrk_array := var_wrk_array || chr(9) || 'NF';
                     else
                        var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                     end if;
                  end if;
               elsif var_wrk_count = 12 then
                  if var_sav_w112_val <> 0 then
                     var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w212_val / var_sav_w112_val) * 100, 2),'FM9999990.00');
                  else
                     if var_sav_w212_val <> 0 then
                        var_wrk_array := var_wrk_array || chr(9) || 'NF';
                     else
                        var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                     end if;
                  end if;
               elsif var_wrk_count = 13 then
                  if var_sav_w113_val <> 0 then
                     var_wrk_array := var_wrk_array || chr(9) || to_char(round((var_sav_w213_val / var_sav_w113_val) * 100, 2),'FM9999990.00');
                  else
                     if var_sav_w213_val <> 0 then
                        var_wrk_array := var_wrk_array || chr(9) || 'NF';
                     else
                        var_wrk_array := var_wrk_array || chr(9) || 'NS/NF';
                     end if;
                  end if;
               end if;
            elsif tblForecast(idx).for_category = '1' then
               var_wrk_array := var_wrk_array || chr(9) || var_sav_planning_cat_cur;
            elsif tblForecast(idx).for_category = '2' then
               var_wrk_array := var_wrk_array || chr(9) || var_sav_planning_cat_prv;
            elsif tblForecast(idx).for_category = '3' then
               var_wrk_array := var_wrk_array || chr(9) || var_sav_planning_cat_old;
            end if;
         end loop;

         /*-*/
         /* Create the detail row */
         /*-*/
         xlxml_object.SetRangeArray('A' || to_char(var_row_count,'FM999999990') || ':A' || to_char(var_row_count,'FM999999990'),
                                    'A' || to_char(var_row_count,'FM999999990') || ':' || var_lst_column || to_char(var_row_count,'FM999999990'),
                                    xlxml_object.TYPE_DETAIL, -9, var_wrk_array);

         /*-*/
         /* Detail variable additional source unit columns */
         /*-*/
         for idx in 2..tblSrcUnit.count loop

            var_row_count := var_row_count + 1;
            var_wrk_array := chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9);
            var_wrk_array := var_wrk_array || tblSrcUnit(idx);
            for idx1 in 1..tblForecast.count loop
               var_wrk_array := var_wrk_array || chr(9);
            end loop;

            /*-*/
            /* Create the detail row */
            /*-*/
            xlxml_object.SetRangeArray('A' || to_char(var_row_count,'FM999999990') || ':A' || to_char(var_row_count,'FM999999990'),
                                       'A' || to_char(var_row_count,'FM999999990') || ':' || var_lst_column || to_char(var_row_count,'FM999999990'),
                                       xlxml_object.TYPE_DETAIL, -9, var_wrk_array);

         end loop;

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
      var_row_count := 0;
      var_details := false;

      /*-*/
      /* Clear the forecast array */
      /*-*/
      tblForecast.Delete;

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
      xlxml_object.SetRangeFormat('A' || to_char(var_row_head + 1,'FM999999990') || ':A' || to_char(var_row_count,'FM999999990'), -1);
      xlxml_object.SetRangeFormat('B' || to_char(var_row_head + 1,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990'), -1);
      xlxml_object.SetRangeFormat('C' || to_char(var_row_head + 1,'FM999999990') || ':C' || to_char(var_row_count,'FM999999990'), -1);
      xlxml_object.SetRangeFormat('D' || to_char(var_row_head + 1,'FM999999990') || ':D' || to_char(var_row_count,'FM999999990'), -1);
      xlxml_object.SetRangeFormat('E' || to_char(var_row_head + 1,'FM999999990') || ':E' || to_char(var_row_count,'FM999999990'), -1);
      xlxml_object.SetRangeFormat('F' || to_char(var_row_head + 1,'FM999999990') || ':F' || to_char(var_row_count,'FM999999990'), -1);
      xlxml_object.SetRangeFormat('G' || to_char(var_row_head + 1,'FM999999990') || ':G' || to_char(var_row_count,'FM999999990'), -1);
      xlxml_object.SetRangeFormat('H' || to_char(var_row_head + 1,'FM999999990') || ':H' || to_char(var_row_count,'FM999999990'), -1);
      for idx in 1..tblForecast.count loop
         if tblForecast(idx).for_category = '0' then
            xlxml_object.SetRangeFormat(tblForecast(idx).column_id || to_char(var_row_head + 1,'FM999999990') || ':' || tblForecast(idx).column_id || to_char(var_row_count,'FM999999990'), 2);
         else
            xlxml_object.SetRangeFormat(tblForecast(idx).column_id || to_char(var_row_head + 1,'FM999999990') || ':' || tblForecast(idx).column_id || to_char(var_row_count,'FM999999990'), -2);
         end if;
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
      xlxml_object.SetRangeBorder('A' || to_char(var_row_head + 1,'FM999999990') || ':A' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('B' || to_char(var_row_head + 1,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('C' || to_char(var_row_head + 1,'FM999999990') || ':C' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('D' || to_char(var_row_head + 1,'FM999999990') || ':D' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('E' || to_char(var_row_head + 1,'FM999999990') || ':E' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('F' || to_char(var_row_head + 1,'FM999999990') || ':F' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('G' || to_char(var_row_head + 1,'FM999999990') || ':G' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('H' || to_char(var_row_head + 1,'FM999999990') || ':H' || to_char(var_row_count,'FM999999990'));
      for idx in 1..tblForecast.count loop
         xlxml_object.SetRangeBorder(tblForecast(idx).column_id || to_char(var_row_head + 1,'FM999999990') || ':' || tblForecast(idx).column_id || to_char(var_row_count,'FM999999990'));
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doBorder;

end mfjpln_for_format02_excel02;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mfjpln_for_format02_excel02 for pld_rep_app.mfjpln_for_format02_excel02;
grant execute on mfjpln_for_format02_excel02 to public;
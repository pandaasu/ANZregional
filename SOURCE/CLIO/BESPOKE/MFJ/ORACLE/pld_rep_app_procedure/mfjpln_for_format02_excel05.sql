/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_for_format02_excel05                        */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : September 2003                                     */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_for_format02_excel05 as

/**DESCRIPTION**
 Forecast Variant Brand Report - Invoice date aggregations.

 **PARAMETERS**
 none

 **NOTES**
 none

**/
   
   /*-*/
   /* Public declarations */
   /*-*/
   function main return varchar2;

end mfjpln_for_format02_excel05;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_for_format02_excel05 as

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
   SUMMARY_MAX number(2,0) := 3;
   var_sum_level number(2,0);
   var_row_head number(15,0);
   var_row_count number(15,0);
   var_details boolean;
   var_for_type varchar2(3 char);
   var_aso_str number(6,0);
   var_aso_end number(6,0);
   var_for_str number(6,0);
   var_for_end number(6,0);
   var_brand_flag_count number(15,0);
   var_brand_sub_flag_count number(15,0);
   var_prdct_pack_size_count number(15,0);
   var_sap_bus_sgmnt_code varchar2(4 char);
   var_planning_type varchar2(60 char);
   var_planning_status varchar2(1 char);
   var_print_xml varchar2(255 char);
   var_lst_column varchar2(2 char);
   type rcdSummary is record(current_value varchar2(256 char),
                             saved_value varchar2(256 char),
                             saved_sequence number(15,0),
                             saved_row number(9,0),
                             saved_end number(9,0),
                             description varchar2(128 char));
   type typSummary is table of rcdSummary index by binary_integer;
   tblSummary typSummary;
   type rcdForecast is record(for_yyyynn varchar2(6 char), column_id varchar2(2 char));
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
      var_planning_type_desc varchar2(255 char);
      var_planning_status_desc varchar2(255 char);
      var_found boolean;
      var_wrk_count number(15,0);
      var_wrk_column number(4,0);
      var_wrk_number number(6,0);
      var_wrk_num01 number(4,0);
      var_wrk_num02 number(2,0);
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
      begin
         select var_code into var_for_type from pld_variable where var_type = 'FOR_TYPE';
      exception
         when others then
            var_for_type := 'PRD';
      end;
      begin
         select to_number(var_code) into var_aso_str from pld_variable where var_type = 'ASOF_STR';
      exception
         when others then
            var_aso_str := 0;
      end;
      begin
         select to_number(var_code) into var_aso_end from pld_variable where var_type = 'ASOF_END';
      exception
         when others then
            var_aso_end := 0;
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
         select var_code into var_planning_status from pld_variable where var_type = 'PLANNING_STATUS';
      exception
         when others then
            var_planning_status := null;
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
      /* Retrieve the forecast column data */
      /*-*/
      var_wrk_column := 2;
      var_lst_column := 'B';
      var_wrk_num01 := to_number(substr(to_char(var_for_str,'FM000000'),1,4));
      var_wrk_num02 := to_number(substr(to_char(var_for_str,'FM000000'),5,2));
      if var_for_type = 'PRD' then
         var_wrk_count := 13;
      elsif var_for_type = 'MTH' then
         var_wrk_count := 12;
      end if;
      for idx in 1..var_wrk_count loop
         var_wrk_number := (var_wrk_num01 * 100) + var_wrk_num02;
         if var_wrk_number <= var_for_end then
            var_wrk_column := var_wrk_column + 1;
            tblForecast(idx).for_yyyynn := to_char(var_wrk_number,'FM000000');
            tblForecast(idx).column_id := xlxml_object.GetColumnId(var_wrk_column);
            var_lst_column := tblForecast(idx).column_id;
            var_wrk_num02 := var_wrk_num02 + 1;
            if var_wrk_num02 > var_wrk_count then
               var_wrk_num01 := var_wrk_num01 + 1;
               var_wrk_num02 := 1;
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
      var_wrk_string := 'Forecast Variant Brand Report - Invoice Date';
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
      xlxml_object.SetHeadingBorder('A2:' || var_lst_column || '2', 'TB');
      var_row_head := 2;

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
      /* Report heading line - product type */
      /*-*/
      var_row_head := var_row_head + 1;
      var_wrk_string := 'Product Type: ' || var_planning_type_desc;
      xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line - product status */
      /*-*/
      var_row_head := var_row_head + 1;
      var_wrk_string := 'Product Status: ' || var_planning_status_desc;
      xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'A' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, var_wrk_string);
      xlxml_object.SetHeadingBorder('A2:' || var_lst_column || to_char(var_row_head,'FM999999990'), 'TB');

      /*-*/
      /* Report heading line */
      /*-*/
      var_row_head := var_row_head + 1;
      xlxml_object.SetRangeType('A' || to_char(var_row_head,'FM999999990') || ':B' || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(2));
      xlxml_object.SetRange('C' || to_char(var_row_head,'FM999999990') || ':C' || to_char(var_row_head,'FM999999990'), 'C' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), xlxml_object.GetHeadingType(2), -2, 0, false, 'Forecasts');
      xlxml_object.SetHeadingBorder('C' || to_char(var_row_head,'FM999999990') || ':' || var_lst_column || to_char(var_row_head,'FM999999990'), 'ALL');

      /*-*/
      /* Report heading line */
      /*-*/
      var_row_head := var_row_head + 1;
      xlxml_object.SetRange('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), null, xlxml_object.GetHeadingType(7), -1, 0, false, 'Material Hierarchy');
      xlxml_object.SetRange('B' || to_char(var_row_head,'FM999999990') || ':B' || to_char(var_row_head,'FM999999990'), null, xlxml_object.GetHeadingType(7), -2, 0, false, 'Asof Date');
      for idx in 1..tblForecast.count loop
         xlxml_object.SetRange(tblForecast(idx).column_id || to_char(var_row_head,'FM999999990') || ':' || tblForecast(idx).column_id || to_char(var_row_head,'FM999999990'), null,
                               xlxml_object.GetHeadingType(7), -2, 0, false, tblForecast(idx).for_yyyynn);
      end loop;
      xlxml_object.SetHeadingBorder('A' || to_char(var_row_head,'FM999999990') || ':A' || to_char(var_row_head,'FM999999990'), 'TLR');
      xlxml_object.SetHeadingBorder('B' || to_char(var_row_head,'FM999999990') || ':B' || to_char(var_row_head,'FM999999990'), 'TLR');
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
         xlxml_object.SetFreezeCell('C' || to_char(var_row_head + 1,'FM999999990'));
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
      var_for_literal varchar2(2048 char);
      var_w01_val number(22,0);
      var_w02_val number(22,0);
      var_w03_val number(22,0);
      var_w04_val number(22,0);
      var_w05_val number(22,0);
      var_w06_val number(22,0);
      var_w07_val number(22,0);
      var_w08_val number(22,0);
      var_w09_val number(22,0);
      var_w10_val number(22,0);
      var_w11_val number(22,0);
      var_w12_val number(22,0);
      var_w13_val number(22,0);
      var_sap_material_code varchar2(18 char);
      var_brand_flag_desc varchar2(255 char);
      var_brand_sub_flag_desc varchar2(255 char);
      var_prdct_pack_size_desc varchar2(255 char);
      var_asof_yyyynn number(6,0);
      var_sequence number(15,0);
      var_sav_sequence number(15,0);
      var_wrk_level number(2,0);
      var_sav_level number(2,0);
      var_description varchar2(255 char);
      var_wrk_string varchar2(2048 char);
      var_wrk_array varchar2(4000 char);
      var_dynamic_sql varchar2(32767 char);
      type typCursor is ref cursor;
      dynamic_c01 typCursor;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Build the selection string */
      /*-*/
      var_fil_literal := null;
      var_slt_literal := null;
      if var_sap_bus_sgmnt_code is not null then
         var_slt_literal := var_slt_literal || ' and t01.sap_bus_sgmnt_code = ''' || var_sap_bus_sgmnt_code || '''';
      end if;
      if var_planning_type is not null then
         var_slt_literal := var_slt_literal || ' and t02.planning_type = ''' || var_planning_type || '''';
      end if;
      if var_planning_status is not null then
         var_slt_literal := var_slt_literal || ' and t02.planning_status = ''' || var_planning_status || '''';
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

      /*-*/
      /* Retrieve the materials that match the selections */
      /*-*/
      var_dynamic_sql := 'select t01.sap_material_code
                            from material_dim t01,
                                 pld_for_format0201 t02' || var_fil_literal || '
                           where t01.sap_material_code = t02.sap_material_code' || var_slt_literal;
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

      /*-*/
      /* Initialise the detail query based on forecast type */
      /*-*/
      if var_for_type = 'PRD' then

         /*-*/
         /* Initialise the forecast literal */
         /*-*/
         var_for_literal := null;
         for idx in 1..13 loop
            if idx <= tblForecast.count then
               var_for_literal := var_for_literal || ', nvl(sum(case when t01.fcst_yyyypp = ' || tblForecast(idx).for_yyyynn || ' then t01.case_qty end),0) w' || to_char(idx,'FM00') || '_qty';
            else
               var_for_literal := var_for_literal || ', sum(0) w' || to_char(idx,'FM00') || '_qty';
            end if;
         end loop;

         /*-*/
         /* Initialise the dynamic literal */
         /*-*/
         var_dynamic_sql := 'select nvl(case when max(t02.sap_brand_flag_code) = ''000'' then
                                                  case when max(t02.sap_supply_sgmnt_code) = ''000'' then
                                                            case when max(t02.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                            else max(t02.mkt_sgmnt_desc) end 
                                                       else max(t02.supply_sgmnt_desc) end 
                                             else max(t02.brand_flag_desc) end,''**NOTHING**'') as brand_flag_text,
                                    nvl(case when max(t02.sap_brand_sub_flag_code) = ''000'' then
                                                  case when max(t02.sap_brand_flag_code) = ''000'' then
                                                            case when max(t02.sap_supply_sgmnt_code) = ''000'' then
                                                                      case when max(t02.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                           else max(t02.mkt_sgmnt_desc) end 
                                                                 else max(t02.supply_sgmnt_desc) end 
                                                       else max(t02.brand_flag_desc) end
                                             else max(t02.brand_sub_flag_desc) end,''**NOTHING**'') as brand_sub_flag_text,
                                    nvl(case when max(t02.sap_prdct_pack_size_code) = ''000'' then
                                                  case when max(t02.sap_brand_sub_flag_code) = ''000'' then
                                                            case when max(t02.sap_brand_flag_code) = ''000'' then
                                                                      case when max(t02.sap_supply_sgmnt_code) = ''000'' then
                                                                                case when max(t02.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                                     else max(t02.mkt_sgmnt_desc) end 
                                                                           else max(t02.supply_sgmnt_desc) end 
                                                                 else max(t02.brand_flag_desc) end
                                                       else max(t02.brand_sub_flag_desc) end
                                             else max(t02.prdct_pack_size_desc) end,''**NOTHING**'') as prdct_pack_size_text,
                                    nvl(t04.asof_yyyypp,0),
                                    nvl(sum(t04.w01_qty),0),
                                    nvl(sum(t04.w02_qty),0),
                                    nvl(sum(t04.w03_qty),0),
                                    nvl(sum(t04.w04_qty),0),
                                    nvl(sum(t04.w05_qty),0),
                                    nvl(sum(t04.w06_qty),0),
                                    nvl(sum(t04.w07_qty),0),
                                    nvl(sum(t04.w08_qty),0),
                                    nvl(sum(t04.w09_qty),0),
                                    nvl(sum(t04.w10_qty),0),
                                    nvl(sum(t04.w11_qty),0),
                                    nvl(sum(t04.w12_qty),0),
                                    nvl(sum(t04.w13_qty),0)
                               from pld_variable t01,
                                    material_dim t02,
                                    pld_for_format0201 t03,
                                    (select t01.sap_material_code sap_material_code,
                                            t01.casting_yyyypp asof_yyyypp
                                            ' || var_for_literal || '
                                       from pld_for_format0203 t01
                                      where ((t01.casting_yyyypp >= ' || to_char(var_aso_str,'FM000000') || ' and
                                              t01.casting_yyyypp <= ' || to_char(var_aso_end,'FM000000') || ') or
                                             t01.casting_yyyypp = 999999)
                                        and (t01.fcst_yyyypp >= ' || to_char(var_for_str,'FM000000') || ' and
                                             t01.fcst_yyyypp <= ' || to_char(var_for_end,'FM000000') || ')
                                      group by t01.sap_material_code,
                                               t01.casting_yyyypp) t04
                              where t01.var_type = ''REPORTED''
                                and t01.var_code = t02.sap_material_code
                                and t02.sap_material_code = t03.sap_material_code
                                and t02.sap_material_code = t04.sap_material_code(+)
                                and (nvl(t04.w01_qty,0) <> 0 or
                                     nvl(t04.w02_qty,0) <> 0 or
                                     nvl(t04.w03_qty,0) <> 0 or
                                     nvl(t04.w04_qty,0) <> 0 or
                                     nvl(t04.w05_qty,0) <> 0 or
                                     nvl(t04.w06_qty,0) <> 0 or
                                     nvl(t04.w07_qty,0) <> 0 or
                                     nvl(t04.w08_qty,0) <> 0 or
                                     nvl(t04.w09_qty,0) <> 0 or
                                     nvl(t04.w10_qty,0) <> 0 or
                                     nvl(t04.w11_qty,0) <> 0 or
                                     nvl(t04.w12_qty,0) <> 0 or
                                     nvl(t04.w13_qty,0) <> 0)
                           group by t02.sap_brand_flag_code,
                                    t02.sap_brand_sub_flag_code,
                                    t02.sap_prdct_pack_size_code,            
                                    t04.asof_yyyypp
                           order by brand_flag_text asc,
                                    brand_sub_flag_text asc,
                                    prdct_pack_size_text asc,
                                    t04.asof_yyyypp asc';


      elsif var_for_type = 'MTH' then

         /*-*/
         /* Initialise the forecast and actual literals */
         /*-*/
         var_for_literal := null;
         for idx in 1..13 loop
            if idx <= tblForecast.count then
               var_for_literal := var_for_literal || ', nvl(sum(case when t01.fcst_yyyymm = ' || tblForecast(idx).for_yyyynn || ' then t01.case_qty end),0) w' || to_char(idx,'FM00') || '_qty';
            else
               var_for_literal := var_for_literal || ', sum(0) w' || to_char(idx,'FM00') || '_qty';
            end if;
         end loop;

         /*-*/
         /* Initialise the dynamic literal */
         /*-*/
         var_dynamic_sql := 'select nvl(case when max(t02.sap_brand_flag_code) = ''000'' then
                                                  case when max(t02.sap_supply_sgmnt_code) = ''000'' then
                                                            case when max(t02.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                            else max(t02.mkt_sgmnt_desc) end 
                                                       else max(t02.supply_sgmnt_desc) end 
                                             else max(t02.brand_flag_desc) end,''**NOTHING**'') as brand_flag_text,
                                    nvl(case when max(t02.sap_brand_sub_flag_code) = ''000'' then
                                                  case when max(t02.sap_brand_flag_code) = ''000'' then
                                                            case when max(t02.sap_supply_sgmnt_code) = ''000'' then
                                                                      case when max(t02.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                           else max(t02.mkt_sgmnt_desc) end 
                                                                 else max(t02.supply_sgmnt_desc) end 
                                                       else max(t02.brand_flag_desc) end
                                             else max(t02.brand_sub_flag_desc) end,''**NOTHING**'') as brand_sub_flag_text,
                                    nvl(case when max(t02.sap_prdct_pack_size_code) = ''000'' then
                                                  case when max(t02.sap_brand_sub_flag_code) = ''000'' then
                                                            case when max(t02.sap_brand_flag_code) = ''000'' then
                                                                      case when max(t02.sap_supply_sgmnt_code) = ''000'' then
                                                                                case when max(t02.sap_mkt_sgmnt_code) = ''00'' then ''NOT APPLICABLE''
                                                                                     else max(t02.mkt_sgmnt_desc) end 
                                                                           else max(t02.supply_sgmnt_desc) end 
                                                                 else max(t02.brand_flag_desc) end
                                                       else max(t02.brand_sub_flag_desc) end
                                             else max(t02.prdct_pack_size_desc) end,''**NOTHING**'') as prdct_pack_size_text,
                                    nvl(t04.asof_yyyymm,0),
                                    nvl(sum(t04.w01_qty),0),
                                    nvl(sum(t04.w02_qty),0),
                                    nvl(sum(t04.w03_qty),0),
                                    nvl(sum(t04.w04_qty),0),
                                    nvl(sum(t04.w05_qty),0),
                                    nvl(sum(t04.w06_qty),0),
                                    nvl(sum(t04.w07_qty),0),
                                    nvl(sum(t04.w08_qty),0),
                                    nvl(sum(t04.w09_qty),0),
                                    nvl(sum(t04.w10_qty),0),
                                    nvl(sum(t04.w11_qty),0),
                                    nvl(sum(t04.w12_qty),0),
                                    nvl(sum(t04.w13_qty),0)
                               from pld_variable t01,
                                    material_dim t02,
                                    pld_for_format0201 t03,
                                    (select t01.sap_material_code sap_material_code,
                                            t01.casting_yyyymm asof_yyyymm
                                            ' || var_for_literal || '
                                       from pld_for_format0204 t01
                                      where ((t01.casting_yyyymm >= ' || to_char(var_aso_str,'FM000000') || ' and
                                              t01.casting_yyyymm <= ' || to_char(var_aso_end,'FM000000') || ') or
                                             t01.casting_yyyymm = 999999)
                                        and (t01.fcst_yyyymm >= ' || to_char(var_for_str,'FM000000') || ' and
                                             t01.fcst_yyyymm <= ' || to_char(var_for_end,'FM000000') || ')
                                      group by t01.sap_material_code,
                                               t01.casting_yyyymm) t04
                              where t01.var_type = ''REPORTED''
                                and t01.var_code = t02.sap_material_code
                                and t02.sap_material_code = t03.sap_material_code
                                and t02.sap_material_code = t04.sap_material_code(+)
                                and (nvl(t04.w01_qty,0) <> 0 or
                                     nvl(t04.w02_qty,0) <> 0 or
                                     nvl(t04.w03_qty,0) <> 0 or
                                     nvl(t04.w04_qty,0) <> 0 or
                                     nvl(t04.w05_qty,0) <> 0 or
                                     nvl(t04.w06_qty,0) <> 0 or
                                     nvl(t04.w07_qty,0) <> 0 or
                                     nvl(t04.w08_qty,0) <> 0 or
                                     nvl(t04.w09_qty,0) <> 0 or
                                     nvl(t04.w10_qty,0) <> 0 or
                                     nvl(t04.w11_qty,0) <> 0 or
                                     nvl(t04.w12_qty,0) <> 0 or
                                     nvl(t04.w13_qty,0) <> 0)
                           group by t02.sap_brand_flag_code,
                                    t02.sap_brand_sub_flag_code,
                                    t02.sap_prdct_pack_size_code,            
                                    t04.asof_yyyymm
                           order by brand_flag_text asc,
                                    brand_sub_flag_text asc,
                                    prdct_pack_size_text asc,
                                    t04.asof_yyyymm asc';

      end if;

      /*-*/
      /* Retrieve the detail rows */
      /*-*/
      var_sequence := 0;
      open dynamic_c01 for var_dynamic_sql;
      loop
         fetch dynamic_c01 into var_brand_flag_desc,
                                var_brand_sub_flag_desc,
                                var_prdct_pack_size_desc,
                                var_asof_yyyynn,
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
                                var_w13_val;
         if dynamic_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Set the summary level values */
         /*-*/
         tblSummary(1).current_value := var_brand_flag_desc;
         tblSummary(2).current_value := var_brand_sub_flag_desc;
         tblSummary(3).current_value := var_prdct_pack_size_desc;

         /*-*/
         /* Adjust the low level descriptions */
         /*-*/
         if var_brand_sub_flag_desc <> var_brand_flag_desc then
            var_brand_sub_flag_desc := var_brand_flag_desc || ' ' || var_brand_sub_flag_desc;
         end if;

         /*-*/
         /* Set the summary level descriptions */
         /*-*/
         tblSummary(1).description := var_brand_flag_desc;
         tblSummary(2).description := var_brand_sub_flag_desc;
         tblSummary(3).description := var_prdct_pack_size_desc;

         /*-*/
         /* Check for summary level changes and process when required */
         /*-*/
         var_sum_level := 0;
         for idx in reverse 1..SUMMARY_MAX loop
            if tblSummary(idx).current_value <> tblSummary(idx).saved_value then
               var_sum_level := idx;
            end if;
         end loop;
         if var_sum_level <> 0 then
            for idx in var_sum_level..SUMMARY_MAX loop
               var_sequence := var_sequence + 1;
               tblSummary(idx).saved_value := tblSummary(idx).current_value;
               tblSummary(idx).saved_sequence := var_sequence;
            end loop;
         end if;

         /*-*/
         /* Update the summary rows */
         /*-*/
         for idx in 1..SUMMARY_MAX loop
            update pld_for_work0202
               set fcst_qty01 = fcst_qty01 + var_w01_val,
                   fcst_qty02 = fcst_qty02 + var_w02_val,
                   fcst_qty03 = fcst_qty03 + var_w03_val,
                   fcst_qty04 = fcst_qty04 + var_w04_val,
                   fcst_qty05 = fcst_qty05 + var_w05_val,
                   fcst_qty06 = fcst_qty06 + var_w06_val,
                   fcst_qty07 = fcst_qty07 + var_w07_val,
                   fcst_qty08 = fcst_qty08 + var_w08_val,
                   fcst_qty09 = fcst_qty09 + var_w09_val,
                   fcst_qty10 = fcst_qty10 + var_w10_val,
                   fcst_qty11 = fcst_qty11 + var_w11_val,
                   fcst_qty12 = fcst_qty12 + var_w12_val,
                   fcst_qty13 = fcst_qty13 + var_w13_val
               where sequence = tblSummary(idx).saved_sequence
                 and asof_yyyynn = var_asof_yyyynn;
            if sql%notfound then
               insert into pld_for_work0202
                  (sequence,
                   sum_level,
                   description,
                   asof_yyyynn,
                   fcst_qty01,
                   fcst_qty02,
                   fcst_qty03,
                   fcst_qty04,
                   fcst_qty05,
                   fcst_qty06,
                   fcst_qty07,
                   fcst_qty08,
                   fcst_qty09,
                   fcst_qty10,
                   fcst_qty11,
                   fcst_qty12,
                   fcst_qty13)
                  values(tblSummary(idx).saved_sequence,
                         idx,
                         tblSummary(idx).description,
                         var_asof_yyyynn,
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
                         var_w13_val);
            end if;
         end loop;
         commit;

      end loop;
      close dynamic_c01;

      /*-*/
      /* Reset the summary array */
      /*-*/
      for idx in 1..SUMMARY_MAX loop
         tblSummary(idx).current_value := null;
         tblSummary(idx).saved_value := null;
         tblSummary(idx).saved_sequence := 0;
         tblSummary(idx).saved_row := 0;
         tblSummary(idx).saved_end := 0;
         tblSummary(idx).description := null;
      end loop;

      /*-*/
      /* Initialise the dynamic literal (temporary work table) - detail/summary */
      /*-*/
      var_dynamic_sql := 'select t01.sequence,
                                 t01.asof_yyyynn,
                                 t01.sum_level,
                                 t01.description,
                                 t01.fcst_qty01,
                                 t01.fcst_qty02,
                                 t01.fcst_qty03,
                                 t01.fcst_qty04,
                                 t01.fcst_qty05,
                                 t01.fcst_qty06,
                                 t01.fcst_qty07,
                                 t01.fcst_qty08,
                                 t01.fcst_qty09,
                                 t01.fcst_qty10,
                                 t01.fcst_qty11,
                                 t01.fcst_qty12,
                                 t01.fcst_qty13
                            from pld_for_work0202 t01
                        order by t01.sequence asc,
                                 t01.asof_yyyynn asc';

      /*-*/
      /* Retrieve the detail rows */
      /*-*/
      var_sav_level := 0;
      var_sav_sequence := 0;
      open dynamic_c01 for var_dynamic_sql;
      loop
         fetch dynamic_c01 into var_sequence,
                                var_asof_yyyynn,
                                var_wrk_level,
                                var_description,
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
                                var_w13_val;
         if dynamic_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Border the sequence when required */
         /*-*/
         if var_sequence <> var_sav_sequence then
            if var_sav_sequence <> 0 then
               xlxml_object.SetRangeBorder('A' || to_char(tblSummary(var_sav_level).saved_row,'FM999999990') || ':' || var_lst_column || to_char(var_row_count,'FM999999990'));
            end if;
            var_sav_sequence := var_sequence;
         else
            var_description := null;
         end if;

         /*-*/
         /* Outline the summary level when required */
         /*-*/
         if var_wrk_level <> var_sav_level then
            if var_wrk_level > var_sav_level and var_sav_level <> 0 then
               tblSummary(var_sav_level).saved_end := var_row_count + 1;
            end if;
            if var_wrk_level < SUMMARY_MAX then
               if var_wrk_level < var_sav_level and var_details = true then
                  for idx in reverse var_wrk_level..SUMMARY_MAX - 1 loop
                     xlxml_object.SetRowGroup(to_char(tblSummary(idx).saved_end,'FM999999990') || ':' || to_char(var_row_count,'FM999999990'));
                  end loop;
               end if;
            end if;
            tblSummary(var_wrk_level).saved_row := var_row_count + 1;
            var_sav_level := var_wrk_level;
         end if;

         /*-*/
         /* Set the details indicator */
         /*-*/
         if var_wrk_level = SUMMARY_MAX then
            var_details := true;
         end if;

         /*-*/
         /* Increment the row count */
         /*-*/
         var_row_count := var_row_count + 1;

         /*-*/
         /* Detail/summary Fixed columns */
         /*-*/
         if var_asof_yyyynn = 999999 then
            var_wrk_string := 'ACTUALS';
         else
            var_wrk_string := to_char(var_asof_yyyynn,'FM000000');
         end if;
         if var_wrk_level = SUMMARY_MAX then
            xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                                  null, xlxml_object.TYPE_DETAIL, -1, (var_wrk_level - 1), false, var_description);
            xlxml_object.SetRange('B' || to_char(var_row_count, 'FM999999990') || ':B' || to_char(var_row_count, 'FM999999990'),
                                  null, xlxml_object.TYPE_DETAIL, -2, var_wrk_level - 1, false, var_wrk_string);
         else
            xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                                  null, xlxml_object.GetSummaryType(var_wrk_level), -1, var_wrk_level - 1, false, var_description);
            xlxml_object.SetRange('B' || to_char(var_row_count, 'FM999999990') || ':B' || to_char(var_row_count, 'FM999999990'),
                                  null, xlxml_object.GetSummaryType(var_wrk_level), -2, var_wrk_level - 1, false, var_wrk_string);
         end if;

         /*-*/
         /* Detail/summary variable forecast columns */
         /* **note** forecast time less than asof time values are to be ignored (ie. use blank not zero)
         /*-*/
         var_wrk_array := null;
         if tblForecast.count >= 1 then
            if var_asof_yyyynn <> 999999 and tblForecast(1).for_yyyynn < var_asof_yyyynn then
               var_wrk_array := var_wrk_array;
            else
               var_wrk_array := var_wrk_array || to_char(var_w01_val,'FM9999999999999999999990');
            end if;
         end if;
         if tblForecast.count >= 2 then
            if var_asof_yyyynn <> 999999 and tblForecast(2).for_yyyynn < var_asof_yyyynn then
               var_wrk_array := var_wrk_array || chr(9);
            else
               var_wrk_array := var_wrk_array || chr(9) || to_char(var_w02_val,'FM9999999999999999999990');
            end if;
         end if;
         if tblForecast.count >= 3 then
            if var_asof_yyyynn <> 999999 and tblForecast(3).for_yyyynn < var_asof_yyyynn then
               var_wrk_array := var_wrk_array || chr(9);
            else
               var_wrk_array := var_wrk_array || chr(9) || to_char(var_w03_val,'FM9999999999999999999990');
            end if;
         end if;
         if tblForecast.count >= 4 then
            if var_asof_yyyynn <> 999999 and tblForecast(4).for_yyyynn < var_asof_yyyynn then
               var_wrk_array := var_wrk_array || chr(9);
            else
               var_wrk_array := var_wrk_array || chr(9) || to_char(var_w04_val,'FM9999999999999999999990');
            end if;
         end if;
         if tblForecast.count >= 5 then
            if var_asof_yyyynn <> 999999 and tblForecast(5).for_yyyynn < var_asof_yyyynn then
               var_wrk_array := var_wrk_array || chr(9);
            else
               var_wrk_array := var_wrk_array || chr(9) || to_char(var_w05_val,'FM9999999999999999999990');
            end if;
         end if;
         if tblForecast.count >= 6 then
            if var_asof_yyyynn <> 999999 and tblForecast(6).for_yyyynn < var_asof_yyyynn then
               var_wrk_array := var_wrk_array || chr(9);
            else
               var_wrk_array := var_wrk_array || chr(9) || to_char(var_w06_val,'FM9999999999999999999990');
            end if;
         end if;
         if tblForecast.count >= 7 then
            if var_asof_yyyynn <> 999999 and tblForecast(7).for_yyyynn < var_asof_yyyynn then
               var_wrk_array := var_wrk_array || chr(9);
            else
               var_wrk_array := var_wrk_array || chr(9) || to_char(var_w07_val,'FM9999999999999999999990');
            end if;
         end if;
         if tblForecast.count >= 8 then
            if var_asof_yyyynn <> 999999 and tblForecast(8).for_yyyynn < var_asof_yyyynn then
               var_wrk_array := var_wrk_array || chr(9);
            else
               var_wrk_array := var_wrk_array || chr(9) || to_char(var_w08_val,'FM9999999999999999999990');
            end if;
         end if;
         if tblForecast.count >= 9 then
            if var_asof_yyyynn <> 999999 and tblForecast(9).for_yyyynn < var_asof_yyyynn then
               var_wrk_array := var_wrk_array || chr(9);
            else
               var_wrk_array := var_wrk_array || chr(9) || to_char(var_w09_val,'FM9999999999999999999990');
            end if;
         end if;
         if tblForecast.count >= 10 then
            if var_asof_yyyynn <> 999999 and tblForecast(10).for_yyyynn < var_asof_yyyynn then
               var_wrk_array := var_wrk_array || chr(9);
            else
               var_wrk_array := var_wrk_array || chr(9) || to_char(var_w10_val,'FM9999999999999999999990');
            end if;
         end if;
         if tblForecast.count >= 11 then
            if var_asof_yyyynn <> 999999 and tblForecast(11).for_yyyynn < var_asof_yyyynn then
               var_wrk_array := var_wrk_array || chr(9);
            else
               var_wrk_array := var_wrk_array || chr(9) || to_char(var_w11_val,'FM9999999999999999999990');
            end if;
         end if;
         if tblForecast.count >= 12 then
            if var_asof_yyyynn <> 999999 and tblForecast(12).for_yyyynn < var_asof_yyyynn then
               var_wrk_array := var_wrk_array || chr(9);
            else
               var_wrk_array := var_wrk_array || chr(9) || to_char(var_w12_val,'FM9999999999999999999990');
            end if;
         end if;
         if var_for_type = 'PRD' then
            if tblForecast.count >= 13 then
               if var_asof_yyyynn <> 999999 and tblForecast(13).for_yyyynn < var_asof_yyyynn then
                  var_wrk_array := var_wrk_array || chr(9);
               else
                  var_wrk_array := var_wrk_array || chr(9) || to_char(var_w13_val,'FM9999999999999999999990');
               end if;
            end if;
         end if;

         /*-*/
         /* Create the detail/summary row */
         /*-*/
         if var_wrk_level = SUMMARY_MAX then
            xlxml_object.SetRangeArray('C' || to_char(var_row_count,'FM999999990') || ':C' || to_char(var_row_count,'FM999999990'),
                                       'C' || to_char(var_row_count,'FM999999990') || ':' || var_lst_column || to_char(var_row_count,'FM999999990'),
                                       xlxml_object.TYPE_DETAIL, -9, var_wrk_array);
         else
            xlxml_object.SetRangeArray('C' || to_char(var_row_count,'FM999999990') || ':C' || to_char(var_row_count,'FM999999990'),
                                       'C' || to_char(var_row_count,'FM999999990') || ':' || var_lst_column || to_char(var_row_count,'FM999999990'),
                                       xlxml_object.GetSummaryType(var_wrk_level), -9, var_wrk_array);
         end if;

      end loop;
      close dynamic_c01;

      /*-*/
      /* Outline the summary levels */
      /*-*/
      if var_details = true then
         for idx in reverse 1..SUMMARY_MAX - 1 loop
            xlxml_object.SetRowGroup(to_char(tblSummary(idx).saved_end,'FM999999990') || ':' || to_char(var_row_count,'FM999999990'));
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
      /* Clear the summary array */
      /*-*/
      for idx in 1..SUMMARY_MAX loop
         tblSummary(idx).current_value := null;
         tblSummary(idx).saved_value := '**********';
         tblSummary(idx).saved_sequence := 0;
         tblSummary(idx).saved_row := 0;
         tblSummary(idx).saved_end := 0;
         tblSummary(idx).description := null;
      end loop;

      /*-*/
      /* Clear the forecast array */
      /*-*/
      tblForecast.Delete;

      /**/
      /* Clear temporary table */
      /**/
      delete from pld_for_work0202;

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
      for idx in 1..tblForecast.count loop
         xlxml_object.SetRangeFormat(tblForecast(idx).column_id || to_char(var_row_head + 1,'FM999999990') || ':' || tblForecast(idx).column_id || to_char(var_row_count,'FM999999990'), 0);
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
      for idx in 1..tblForecast.count loop
         xlxml_object.SetRangeBorder(tblForecast(idx).column_id || to_char(var_row_head + 1,'FM999999990') || ':' || tblForecast(idx).column_id || to_char(var_row_count,'FM999999990'));
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doBorder;

end mfjpln_for_format02_excel05;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mfjpln_for_format02_excel05 for pld_rep_app.mfjpln_for_format02_excel05;
grant execute on mfjpln_for_format02_excel05 to public;
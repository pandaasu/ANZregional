/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_inv_format02_excel05                        */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : June 2003                                          */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_inv_format02_excel05 as

/**DESCRIPTION**
 Finished Goods Ageing Inventory Report - Invoice date aggregations.

 **PARAMETERS**
 par_sap_company_code = SAP company code (mandatory)
 par_sap_bus_sgmnt_code = SAP business segment code (mandatory)
 par_val_type = Value type (mandatory)
                  QTY = quantity
                  CST = cost
 par_print_xml = Print xml data string (optional)
                   Format = SetPrintOverride Orientation='1' FitWidthPages='1' Zoom='0'
                   Orientation = 1(Portrait) 2(Landscape)
                   FitWidthPages = number 0 to 999
                   Zoom = number 0 to 100 (overrides FitWidthPages)

 **NOTES**
 1. Finished goods is sap_material_type_code = 'FERT' and material_type_flag_sfp != 'Y' (hard-coded)

**/
   
   /*-*/
   /* Public declarations */
   /*-*/
   function main(par_sap_company_code in varchar2,
                 par_sap_bus_sgmnt_code in varchar2,
                 par_val_type in varchar2,
                 par_print_xml in varchar2) return varchar2;

end mfjpln_inv_format02_excel05;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_inv_format02_excel05 as

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
   SUMMARY_MAX number(2,0) := 3;
   var_sum_level number(2,0);
   var_row_count number(15,0);
   var_details boolean;
   var_sap_company_code varchar2(6 char);
   var_sap_bus_sgmnt_code varchar2(4 char);
   var_val_type varchar2(3 char);
   var_br_YYYYPP number(6,0);
   var_min_date date;
   var_max_date date;
   var_lst_column varchar2(2 char);
   var_min_column varchar2(2 char);
   var_max_column varchar2(2 char);
   type rcdSummary is record(current_value varchar2(256 char),
                             saved_value varchar2(256 char),
                             saved_row number(9,0),
                             description varchar2(128 char));
   type typSummary is table of rcdSummary index by binary_integer;
   tblSummary typSummary;
   type rcdWeek is record(mars_week varchar2(7 char),
                          calendar_date date,
                          column_id varchar2(2 char),
                          inv_qty number(22,0),
                          inv_val number(22,0));
   type typWeek is table of rcdWeek index by binary_integer;
   tblWeek typWeek;

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_sap_company_code in varchar2,
                 par_sap_bus_sgmnt_code in varchar2,
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
      var_current_YYYYPP number(6,0);
      var_current_YYYYMM number(6,0);
      var_extract_status varchar2(256 char);
      var_inventory_date date;
      var_inventory_status varchar2(256 char);
      var_company_desc varchar2(60 char);
      var_bus_sgmnt_desc varchar2(30 char);
      var_mars_week varchar2(7 char);
      var_sav_period varchar2(6 char);
      var_str_column varchar2(2 char);
      var_end_column varchar2(2 char);
      var_calendar_date date;
      var_found boolean;
      var_wrk_min number(15,0);
      var_wrk_max number(15,0);
      var_wrk_count number(15,0);
      var_wrk_column number(4,0);
      var_wrk_string varchar2(4096 char);

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
         from pld_inv_format0200;

      cursor mars_date_c01 is 
         select to_char(mars_date.mars_week,'FM0000000'),
                max(mars_date.calendar_date)
         from mars_date
         where trunc(mars_date.calendar_date) >= trunc(var_inventory_date)
         group by mars_date.mars_week
         order by mars_date.mars_week asc;

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
      var_val_type := par_val_type;

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
      var_br_YYYYPP := var_current_YYYYPP;

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
      var_wrk_min := 26;
      var_wrk_max := 52;
      if var_sap_bus_sgmnt_code = '01' then
         var_wrk_min := 12;
         var_wrk_max := 32;
      elsif var_sap_bus_sgmnt_code = '02' then
         var_wrk_min := 12;
         var_wrk_max := 32;
      elsif var_sap_bus_sgmnt_code = '05' then
         var_wrk_min := 26;
         var_wrk_max := 52;
      end if;
      var_min_date := to_date('01011901','DDMMYYYY');
      var_max_date := var_inventory_date;
      var_wrk_count := 0;
      var_wrk_column := 2;
      var_lst_column := 'B';
      var_min_column := 'B';
      open mars_date_c01;
      loop
         fetch mars_date_c01 into var_mars_week,
                                  var_calendar_date;
         if mars_date_c01%notfound then
            exit;
         end if;
         if var_wrk_count >= var_wrk_max then
            exit;
         end if;
         var_wrk_count := var_wrk_count + 1;
         var_wrk_column := var_wrk_column + 1;
         tblWeek(var_wrk_count).mars_week := var_mars_week;
         tblWeek(var_wrk_count).calendar_date := var_calendar_date;
         tblWeek(var_wrk_count).column_id := xlxml_object.getColumnId(var_wrk_column);
         tblWeek(var_wrk_count).inv_qty := 0;
         tblWeek(var_wrk_count).inv_val := 0;
         if var_wrk_count = var_wrk_min then
            var_min_column := tblWeek(var_wrk_count).column_id;
         end if;
         if var_wrk_count = var_wrk_min + 1 then
            var_max_column := tblWeek(var_wrk_count).column_id;
         end if;
         var_lst_column := tblWeek(var_wrk_count).column_id;
         var_max_date := var_calendar_date;
      end loop;
      close mars_date_c01;

      /*-*/
      /* Report start */
      /*-*/
      xlxml_object.BeginReport;

      /*-*/
      /* Report heading line 1 */
      /*-*/
      if var_val_type = 'QTY' then
         var_wrk_string := 'Finished Goods Ageing Inventory Report - (Quantity)';
      else
         var_wrk_string := 'Finished Goods Ageing Inventory Report - (Yen Millions)';
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
      var_wrk_string := 'Company: ' || var_company_desc || '    Business Segment: ' || var_bus_sgmnt_desc;
      xlxml_object.SetRange('A3:A3', 'A3:' || var_lst_column || '3', xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 4/5/6 - Description */
      /*-*/
      xlxml_object.SetRangeType('A4:A4', xlxml_object.GetHeadingType(7));
      xlxml_object.SetRangeType('A5:A5', xlxml_object.GetHeadingType(7));
      xlxml_object.SetRange('A6:A6', null, xlxml_object.GetHeadingType(7), -1, 0, false, 'Material Hierarchy');

      /*-*/
      /* Report heading line 4/5/6 - Forecast */
      /*-*/
      xlxml_object.SetRangeType('B4:B4', xlxml_object.GetHeadingType(7));
      xlxml_object.SetRangeType('B5:B5', xlxml_object.GetHeadingType(7));
      xlxml_object.SetRange('B6:B6', null, xlxml_object.GetHeadingType(7), -2, 0, false, 'For/Qty');

      /*-*/
      /* Report heading line 4/5/6 - Periods/Weeks */
      /*-*/
      var_sav_period := '999999';
      var_str_column := 'C';
      var_end_column := 'C';
      for idx in 1..tblWeek.count loop
         if substr(tblWeek(idx).mars_week,1,6) <> var_sav_period then
            if var_sav_period <> '999999' then
               xlxml_object.SetRange(var_str_column || '4:' || var_str_column || '4',
                                     var_str_column || '4:' || var_end_column || '4', xlxml_object.GetHeadingType(2), -2, 0, false, var_sav_period);
            end if;
            var_sav_period := substr(tblWeek(idx).mars_week,1,6);
            var_str_column := tblWeek(idx).column_id;
         end if;
         var_end_column := tblWeek(idx).column_id;
         xlxml_object.SetRange(tblWeek(idx).column_id || '5:' || tblWeek(idx).column_id || '5',
                               null, xlxml_object.GetHeadingType(7), -2, 0, false, 'W' || substr(tblWeek(idx).mars_week,7,1));
      end loop;
      if var_sav_period <> '999999' then
         xlxml_object.SetRange(var_str_column || '4:' || var_str_column || '4',
                               var_str_column || '4:' || var_end_column || '4', xlxml_object.GetHeadingType(2), -2, 0, false, var_sav_period);
      end if;
      xlxml_object.SetRange('C6:C6', 'C6:' || var_min_column || '6', xlxml_object.TYPE_HEADING_HI, -2, 0, false, 'Unsaleable');
      xlxml_object.SetRange(var_max_column || '6:' || var_max_column || '6', var_max_column || '6:' || var_lst_column || '6', xlxml_object.GetHeadingType(7), -2, 0, false, 'Ageing');

      /*-*/
      /* Report heading borders */
      /*-*/
      xlxml_object.SetHeadingBorder('A6:A6', 'TLR');
      xlxml_object.SetHeadingBorder('B6:B6', 'TLR');
      var_sav_period := '999999';
      var_str_column := 'C';
      var_end_column := 'C';
      for idx in 1..tblWeek.count loop
         if substr(tblWeek(idx).mars_week,1,6) <> var_sav_period then
            if var_sav_period <> '999999' then
               xlxml_object.SetHeadingBorder(var_str_column || '4:' || var_end_column || '4', 'ALL');
            end if;
            var_sav_period := substr(tblWeek(idx).mars_week,1,6);
            var_str_column := tblWeek(idx).column_id;
         end if;
         var_end_column := tblWeek(idx).column_id;
         xlxml_object.SetHeadingBorder(tblWeek(idx).column_id || '5:' || tblWeek(idx).column_id || '5', 'ALL');
      end loop;
      if var_sav_period <> '999999' then
         xlxml_object.SetHeadingBorder(var_str_column || '4:' || var_end_column || '4', 'ALL');
      end if;
      xlxml_object.SetHeadingBorder('C6:' || var_min_column || '6', 'TLR');
      xlxml_object.SetHeadingBorder(var_max_column || '6:' || var_lst_column || '6', 'TLR');

      /*-*/
      /* Initialise the row count */
      /*-*/
      var_row_count := 6;

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
         xlxml_object.SetFreezeCell('C7');
      end if;

      /*-*/
      /* Report when no details found */
      /*-*/
      if var_details = false then
         xlxml_object.SetRange('A7:A7', 'A7:' || var_lst_column || '7', xlxml_object.TYPE_DETAIL, -2, 0, false, 'NO INFORMATION EXISTS');
         xlxml_object.SetRangeBorder('A7:' || var_lst_column || '7');
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
      var_grp_literal varchar2(256 char);
      var_srt_literal varchar2(256 char);
      var_inv_exp_date date;
      var_inv_qty number(22,0);
      var_inv_val number(22,0);
      var_for_qty number(22,0);
      var_bus_sgmnt_desc varchar2(128 char);
      var_brand_flag_desc varchar2(128 char);
      var_sap_brand_sub_flag_code varchar2(32 char);
      var_sap_prdct_pack_size_code varchar2(32 char);
      var_sap_rep_item_code varchar2(18 char);
      var_rep_item_desc_en varchar2(40 char);
      var_rep_desc varchar2(60 char);
      var_sap_material_code varchar2(18 char);
      var_material_desc_en varchar2(128 char);
      var_material_desc_ja varchar2(128 char);
      var_sort_desc varchar2(128 char);
      var_sav_material_code varchar2(18 char);
      var_sav_bus_sgmnt_desc varchar2(128 char);
      var_sav_brand_flag_desc varchar2(128 char);
      var_sav_rep_desc varchar2(128 char);
      var_sav_material_desc varchar2(128 char);
      var_sav_for_qty number(22,0);
      var_wrk_string varchar2(4096 char);
      var_dynamic_sql varchar2(32767 char);
      type typCursor is ref cursor;
      pld_inv_format0202_c01 typCursor;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the group and sort literal based on business segment code */
      /* 01 = Snackfood */
      /* 02 = Food */
      /* 05 = Petcare */
      /*-*/
      if var_sap_bus_sgmnt_code = '01' then
         var_grp_literal := 't01.sap_material_code,
                             t01.inv_exp_date';
         var_srt_literal := 'brand_flag_text asc,
                             rep_desc asc,
                             sap_brand_sub_flag_code asc,
                             sap_prdct_pack_size_code asc,
                             sort_desc asc';
      elsif var_sap_bus_sgmnt_code = '02' then
         var_grp_literal := 't01.sap_material_code,
                             t01.inv_exp_date';
         var_srt_literal := 'brand_flag_text asc,
                             rep_desc asc,
                             sap_brand_sub_flag_code asc,
                             sap_prdct_pack_size_code asc,
                             sort_desc asc';
      elsif var_sap_bus_sgmnt_code = '05' then
         var_grp_literal := 't01.sap_material_code,
                             t01.inv_exp_date';
         var_srt_literal := 'brand_flag_text asc,
                             rep_desc asc,
                             sap_brand_sub_flag_code asc,
                             sap_prdct_pack_size_code asc,
                             sort_desc asc';
      else
         var_grp_literal := 't01.sap_material_code,
                             t01.inv_exp_date';
         var_srt_literal := 'brand_flag_text asc,
                             rep_desc asc,
                             sap_brand_sub_flag_code asc,
                             sap_prdct_pack_size_code asc,
                             sort_desc asc';
      end if;

      /*-*/
      /* Retrieve the unrestricted inventory with forecasts */
      /*-*/
      var_dynamic_sql := 'select t01.bus_sgmnt_desc as bus_sgmnt_text,
                                 case when t01.sap_brand_flag_code = ''000'' then
                                           case when t01.sap_supply_sgmnt_code = ''000'' then
                                                     case when t01.sap_mkt_sgmnt_code = ''00'' then ''NOT APPLICABLE''
                                                          else t01.mkt_sgmnt_desc end 
                                                else t01.supply_sgmnt_desc end 
                                      else t01.brand_flag_desc end as brand_flag_text,
                                 t01.sap_brand_sub_flag_code as sap_brand_sub_flag_code,
                                 t01.sap_prdct_pack_size_code as sap_prdct_pack_size_code,
                                 t01.sap_rep_item_code,
                                 t01.rep_item_desc_en,
                                 nvl(t01.rep_item_desc_en || t01.sap_rep_item_code,''NO REPRESENTATIVE ITEM'') as rep_desc,
                                 t01.sap_material_code,
                                 t01.material_desc_en,
                                 t01.material_desc_ja,
                                 t01.material_desc_en || t01.sap_material_code as sort_desc,
                                 t02.inv_exp_date,
                                 t02.inv_qty,
                                 t02.inv_cst,
                                 nvl(t03.for_qty,0)
                            from material_dim t01,
                                 (select t01.sap_material_code as sap_material_code,
                                         t01.inv_exp_date as inv_exp_date,
                                         sum(t01.inv_unr_qty + t01.inv_res_qty) as inv_qty,
                                         sum(t01.inv_unr_val + t01.inv_res_val) as inv_cst
                                    from pld_inv_format0202 t01
                                   where t01.sap_company_code = :A
                                     and trunc(t01.inv_exp_date) >= :B
                                     and trunc(t01.inv_exp_date) <= :C
                                group by ' || var_grp_literal || ') t02,
                                 (select t01.sap_material_code as sap_material_code, 
                                         sum(t01.br_qty) as for_qty
                                    from fcst_period_02_fact t01
                                   where t01.sap_sales_dtl_sales_org_code = :D
                                     and t01.billing_YYYYPP = :E
                                group by t01.sap_material_code) t03
                           where t01.sap_material_code = t02.sap_material_code
                             and t02.sap_material_code = t03.sap_material_code(+)
                             and t01.sap_bus_sgmnt_code = :F
                             and t01.sap_material_type_code = ''FERT''
                             and t01.material_type_flag_sfp != ''Y''
                        order by ' || var_srt_literal;

      /*-*/
      /* Retrieve the unrestricted inventory rows */
      /*-*/
      var_sav_material_code := '****';
      open pld_inv_format0202_c01 for var_dynamic_sql using var_sap_company_code, trunc(var_min_date), trunc(var_max_date), var_sap_company_code, var_br_YYYYPP, var_sap_bus_sgmnt_code;
      loop
         fetch pld_inv_format0202_c01 into var_bus_sgmnt_desc,
                                           var_brand_flag_desc,
                                           var_sap_brand_sub_flag_code,
                                           var_sap_prdct_pack_size_code,
                                           var_sap_rep_item_code,
                                           var_rep_item_desc_en,
                                           var_rep_desc,
                                           var_sap_material_code,
                                           var_material_desc_en,
                                           var_material_desc_ja,
                                           var_sort_desc,
                                           var_inv_exp_date,
                                           var_inv_qty,
                                           var_inv_val,
                                           var_for_qty;
         if pld_inv_format0202_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Change of material code */
         /*-*/
         if var_sap_material_code <> var_sav_material_code then

            /*-*/
            /* Output the material code when required */
            /*-*/
            if var_sav_material_code <> '****' then

               /*-*/
               /* Set the summary level values */
               /*-*/
               if var_sap_bus_sgmnt_code = '01' then
                  tblSummary(1).current_value := var_sav_bus_sgmnt_desc;
                  tblSummary(2).current_value := var_sav_brand_flag_desc;
               elsif var_sap_bus_sgmnt_code = '02' then
                  tblSummary(1).current_value := var_sav_bus_sgmnt_desc;
                  tblSummary(2).current_value := var_sav_brand_flag_desc;
               elsif var_sap_bus_sgmnt_code = '05' then
                  tblSummary(1).current_value := var_sav_bus_sgmnt_desc;
                  tblSummary(2).current_value := var_sav_brand_flag_desc;
               else
                  tblSummary(1).current_value := var_sav_bus_sgmnt_desc;
                  tblSummary(2).current_value := var_sav_brand_flag_desc;
               end if;
               tblSummary(3).current_value := var_sav_rep_desc;

               /*-*/
               /* Set the summary level descriptions */
               /*-*/
               if var_sap_bus_sgmnt_code = '01' then
                  tblSummary(1).description := var_sav_bus_sgmnt_desc;
                  tblSummary(2).description := var_sav_brand_flag_desc;
               elsif var_sap_bus_sgmnt_code = '02' then
                  tblSummary(1).description := var_sav_bus_sgmnt_desc;
                  tblSummary(2).description := var_sav_brand_flag_desc;
               elsif var_sap_bus_sgmnt_code = '05' then
                  tblSummary(1).description := var_sav_bus_sgmnt_desc;
                  tblSummary(2).description := var_sav_brand_flag_desc;
               else
                  tblSummary(1).description := var_sav_bus_sgmnt_desc;
                  tblSummary(2).description := var_sav_brand_flag_desc;
               end if;
               tblSummary(3).description := var_sav_rep_desc;

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
               /* Set the control information */
               /*-*/
               var_details := true;
               var_row_count := var_row_count + 1;

               /*-*/
               /* Detail description */
               /*-*/
               xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                                     null, xlxml_object.TYPE_DETAIL, -1, SUMMARY_MAX, false, var_sav_material_desc);

               /*-*/
               /* Set the week values */
               /*-*/
               var_wrk_string := null;
               if var_sav_for_qty <> 0 then
                  var_wrk_string := to_char(var_sav_for_qty,'FM999999999999990');
               end if;
               for idx in 1..tblWeek.count loop
                  var_wrk_string := var_wrk_string || chr(9);
                  if var_val_type = 'QTY' then
                     if tblWeek(idx).inv_qty <> 0 then
                        var_wrk_string := var_wrk_string || to_char(tblWeek(idx).inv_qty,'FM999999999999990');
                     end if;
                  else
                     if tblWeek(idx).inv_val <> 0 then
                        var_wrk_string := var_wrk_string || to_char(tblWeek(idx).inv_val/1000000,'FM999999990.000000');
                     end if;
                  end if;
               end loop;

               /*-*/
               /* Create the detail row */
               /*-*/
               xlxml_object.SetRangeArray('B' || to_char(var_row_count,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990'),
                                          'B' || to_char(var_row_count,'FM999999990') || ':' || var_lst_column || to_char(var_row_count,'FM999999990'),
                                          xlxml_object.TYPE_DETAIL, -9, var_wrk_string);

            end if;

            /*-*/
            /* Save the material */
            /*-*/
            var_sav_material_code := var_sap_material_code;

            /*-*/
            /* Set the detail descriptions */
            /*-*/
            var_sav_bus_sgmnt_desc := var_bus_sgmnt_desc;
            var_sav_brand_flag_desc := var_brand_flag_desc;
            if not(var_sap_rep_item_code is null) then
               var_sav_rep_desc := '(' || var_sap_rep_item_code || ') ' || var_rep_item_desc_en;
            else
               var_sav_rep_desc := 'NO REPRESENTATIVE ITEM';
            end if;
            var_sav_material_desc := '(' || var_sap_material_code || ') ' || var_material_desc_en;
            var_sav_for_qty := var_for_qty;

            /*-*/
            /* Clear the week values */
            /*-*/
            for idx in 1..tblWeek.count loop
               tblWeek(idx).inv_qty := 0;
               tblWeek(idx).inv_val := 0;
            end loop;

         end if;

         /*-*/
         /* Accumulate the week data */
         /* **note** the query only returns dates less than or equal to maximum in array */
         /*-*/
         for idx in 1..tblWeek.count loop
            if trunc(var_inv_exp_date) <= trunc(tblWeek(idx).calendar_date) then
               tblWeek(idx).inv_qty := tblWeek(idx).inv_qty + var_inv_qty;
               tblWeek(idx).inv_val := tblWeek(idx).inv_val + var_inv_val;
               exit;
            end if;
         end loop;

      end loop;
      close pld_inv_format0202_c01;

      /*-*/
      /* Output the last material code when required */
      /*-*/
      if var_sav_material_code <> '****' then

         /*-*/
         /* Set the summary level values */
         /*-*/
         if var_sap_bus_sgmnt_code = '01' then
            tblSummary(1).current_value := var_sav_bus_sgmnt_desc;
            tblSummary(2).current_value := var_sav_brand_flag_desc;
         elsif var_sap_bus_sgmnt_code = '02' then
            tblSummary(1).current_value := var_sav_bus_sgmnt_desc;
            tblSummary(2).current_value := var_sav_brand_flag_desc;
         elsif var_sap_bus_sgmnt_code = '05' then
            tblSummary(1).current_value := var_sav_bus_sgmnt_desc;
            tblSummary(2).current_value := var_sav_brand_flag_desc;
         else
            tblSummary(1).current_value := var_sav_bus_sgmnt_desc;
            tblSummary(2).current_value := var_sav_brand_flag_desc;
         end if;
         tblSummary(3).current_value := var_sav_rep_desc;

         /*-*/
         /* Set the summary level descriptions */
         /*-*/
         if var_sap_bus_sgmnt_code = '01' then
            tblSummary(1).description := var_sav_bus_sgmnt_desc;
            tblSummary(2).description := var_sav_brand_flag_desc;
         elsif var_sap_bus_sgmnt_code = '02' then
            tblSummary(1).description := var_sav_bus_sgmnt_desc;
            tblSummary(2).description := var_sav_brand_flag_desc;
         elsif var_sap_bus_sgmnt_code = '05' then
            tblSummary(1).description := var_sav_bus_sgmnt_desc;
            tblSummary(2).description := var_sav_brand_flag_desc;
         else
            tblSummary(1).description := var_sav_bus_sgmnt_desc;
            tblSummary(2).description := var_sav_brand_flag_desc;
         end if;
         tblSummary(3).description := var_sav_rep_desc;

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
         /* Set the control information */
         /*-*/
         var_details := true;
         var_row_count := var_row_count + 1;

         /*-*/
         /* Detail description */
         /*-*/
         xlxml_object.SetRange('A' || to_char(var_row_count, 'FM999999990') || ':A' || to_char(var_row_count, 'FM999999990'),
                                null, xlxml_object.TYPE_DETAIL, -1, SUMMARY_MAX, false, var_sav_material_desc);

         /*-*/
         /* Set the week values */
         /*-*/
         var_wrk_string := null;
         if var_sav_for_qty <> 0 then
            var_wrk_string := to_char(var_sav_for_qty,'FM999999999999990');
         end if;
         for idx in 1..tblWeek.count loop
            var_wrk_string := var_wrk_string || chr(9);
            if var_val_type = 'QTY' then
               if tblWeek(idx).inv_qty <> 0 then
                  var_wrk_string := var_wrk_string || to_char(tblWeek(idx).inv_qty,'FM999999999999990');
               end if;
            else
               if tblWeek(idx).inv_val <> 0 then
                  var_wrk_string := var_wrk_string || to_char(tblWeek(idx).inv_val/1000000,'FM999999990.000000');
               end if;
            end if;
         end loop;

         /*-*/
         /* Create the detail row */
         /*-*/
         xlxml_object.SetRangeArray('B' || to_char(var_row_count,'FM999999990') || ':B' || to_char(var_row_count,'FM999999990'),
                                    'B' || to_char(var_row_count,'FM999999990') || ':' || var_lst_column || to_char(var_row_count,'FM999999990'),
                                    xlxml_object.TYPE_DETAIL, -9, var_wrk_string);

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
      /* Clear the week array */
      /*-*/
      tblWeek.Delete;

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
      var_wrk_string varchar2(4096 char);

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
         for idx01 in 1..tblWeek.count loop
            var_wrk_string := var_wrk_string || chr(9);
            var_wrk_string := var_wrk_string || '"=subtotal(9,' || tblWeek(idx01).column_id || to_char(tblSummary(idx).saved_row + 1,'FM999999990') || ':' || tblWeek(idx01).column_id || to_char(var_row_count,'FM999999990') || ')"';
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
      xlxml_object.SetRangeFormat('B7:B' || to_char(var_row_count,'FM999999990'), 0);
      for idx in 1..tblWeek.count loop
         if var_val_type = 'QTY' then
            xlxml_object.SetRangeFormat(tblWeek(idx).column_id || '7:' || tblWeek(idx).column_id || to_char(var_row_count,'FM999999990'), 0);
         else
            xlxml_object.SetRangeFormat(tblWeek(idx).column_id || '7:' || tblWeek(idx).column_id || to_char(var_row_count,'FM999999990'), 2);
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
      xlxml_object.SetRangeBorder('A7:A' || to_char(var_row_count,'FM999999990'));
      xlxml_object.SetRangeBorder('B7:B' || to_char(var_row_count,'FM999999990'));
      for idx in 1..tblWeek.count loop
         xlxml_object.SetRangeBorder(tblWeek(idx).column_id || '7:' || tblWeek(idx).column_id || to_char(var_row_count,'FM999999990'));
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end doBorder;

end mfjpln_inv_format02_excel05;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mfjpln_inv_format02_excel05 for pld_rep_app.mfjpln_inv_format02_excel05;
grant execute on mfjpln_inv_format02_excel05 to public;
/******************/
/* Package Header */
/******************/
create or replace package dw_forecast_loading as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : dw_forecast_loading
 Owner   : dw_app

 Description
 -----------
 Dimensional Data Store - Forecast Loading

 This package contain the procedures for forecast load data. The package exposes the
 following procedures.

 1. SELECT_LOAD

    This procedure is used to retrieve the forecast load into an excel spreadsheet.

 2. DELETE_LOAD

    This procedure is used to delete the forecast load.

 3. CREATE_PERIOD_LOAD

    This procedure is used to create a forecast period load data set.

 4. UPDATE_PERIOD_LOAD

    This procedure is used to update the forecast period load from an excel spreadsheet.

 5. ACCEPT_PERIOD_LOAD

    This procedure is used to accept the forecast period load and update the operational data store.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/06   Steve Gregan   Created
 2006/12   Steve Gregan   Added grand totals for QTY/BPS/GSV
 2006/12   Steve Gregan   Disabled links to planning database (Mercia)
 2007/12   Steve Gregan   Enabled BR forecast creation and loading for
                          casting period equal to CLIO previous period
 2008/12   Steve Gregan   Modified to fix XML parsing cdata section bug

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure select_load(par_identifier in varchar2);
   procedure delete_load(par_identifier in varchar2);
   function create_period_load(par_identifier in varchar2,
                               par_description in varchar2,
                               par_replace in varchar2,
                               par_type in varchar2,
                               par_split_division in varchar2,
                               par_split_brand in varchar2,
                               par_split_sub_brand in varchar2,
                               par_source in varchar2,
                               par_material_list in varchar2,
                               par_user in varchar2) return varchar2;
   procedure update_period_load(par_user in varchar2);
   procedure accept_period_load(par_identifier in varchar2, par_user in varchar2);

end dw_forecast_loading;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_forecast_loading as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   var_wrkr number;

   /*-*/
   /* Private declarations
   /*-*/
   function validate_load(par_identifier in varchar2) return varchar2;
   procedure read_txt_stream(par_stream in varchar2);
   procedure read_xml_stream(par_source in varchar2, par_stream in clob);
   procedure read_xml_child(par_source in varchar2, par_xml_node in xmlDom.domNode);

   /***************************************************/
   /* This procedure performs the select load routine */
   /***************************************************/
   procedure select_load(par_identifier in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_identifier fcst_load_header.load_identifier%type;
      var_cast_yyyynn fcst_load_header.fcst_cast_yyyynn%type;
      var_wrk_string varchar2(4000 char);
      var_row_count number;
      var_end_count number;
      var_fcst_time varchar2(128);
      var_fcst_type varchar2(128);
      var_fcst_source varchar2(128);
      var_fcst_material_list varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_header is 
         select t01.*,
                nvl(t02.company_desc,'*UNKNOWN') as company_desc,
                nvl(t03.sales_org_desc,'*UNKNOWN') as sales_org_desc,
                nvl(t04.distbn_chnl_desc,'*UNKNOWN') as distbn_chnl_desc,
                nvl(t05.division_desc,'*UNKNOWN') as division_desc,
                nvl(t06.fcst_split_text,'*UNKNOWN') as fcst_split_text
           from fcst_load_header t01,
                company_dim t02,
                sales_org_dim t03,
                distbn_chnl_dim t04,
                division_dim t05,
                fcst_split t06
          where t01.sap_sales_org_code = t02.sap_company_code(+)
            and t01.sap_sales_org_code = t03.sap_sales_org_code(+)
            and t01.sap_distbn_chnl_code = t04.sap_distbn_chnl_code(+)
            and t01.sap_division_code = t05.sap_division_code(+)
            and t01.fcst_split_division = t06.fcst_split_division(+)
            and t01.fcst_split_brand = t06.fcst_split_brand(+)
            and t01.fcst_split_sub_brand = t06.fcst_split_sub_brand(+)
            and t01.load_identifier = var_identifier;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

      cursor csr_fcst_load_count is 
         select count(*) as material_count
           from fcst_load_detail t01
          where t01.load_identifier = rcd_fcst_load_header.load_identifier;
      rcd_fcst_load_count csr_fcst_load_count%rowtype;

      cursor csr_fcst_load_detail is 
         select t01.*,
                nvl(t02.material_desc_en,'*UNKNOWN') as material_desc_en,
                nvl(t02.material_desc_ja,'*UNKNOWN') as material_desc_ja
           from fcst_load_detail t01,
                material_dim t02
          where t01.sap_material_code = t02.sap_material_code(+)
            and t01.load_identifier = rcd_fcst_load_header.load_identifier
          order by t01.sap_material_code asc;
      rcd_fcst_load_detail csr_fcst_load_detail%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_identifier := upper(par_identifier);
      if var_identifier is null then
         raise_application_error(-20000, 'Forecast load identifier must be specified');
      end if;

      /*-*/
      /* Forecast load header must exist
      /*-*/
      open csr_fcst_load_header;
      fetch csr_fcst_load_header into rcd_fcst_load_header;
      if csr_fcst_load_header%notfound then
         raise_application_error(-20000, 'Forecast load (' || var_identifier || ') does not exist');
      end if;
      close csr_fcst_load_header;

      /*-*/
      /* Set the forecast literals
      /*-*/
      var_fcst_time := rcd_fcst_load_header.fcst_time;
      if rcd_fcst_load_header.fcst_time = '*MTH' then
         var_fcst_time := 'Month';
      end if;
      if rcd_fcst_load_header.fcst_time = '*PRD' then
         var_fcst_time := 'Period';
      end if;
      var_fcst_type := rcd_fcst_load_header.fcst_type;
      if rcd_fcst_load_header.fcst_type = '*BR' then
         var_fcst_type := 'Business Review';
      end if;
      if rcd_fcst_load_header.fcst_type = '*OP1' then
         var_fcst_type := 'Operating Plan - This Year';
      end if;
      if rcd_fcst_load_header.fcst_type = '*OP2' then
         var_fcst_type := 'Operating Plan - Next Year';
      end if;
      var_fcst_source := rcd_fcst_load_header.fcst_source;
      var_fcst_material_list := rcd_fcst_load_header.fcst_material_list;
      if rcd_fcst_load_header.fcst_source = '*PLN' then
         var_fcst_source := 'Planning System';
      end if;
      if rcd_fcst_load_header.fcst_source = '*TXQ' then
         var_fcst_source := 'Text File (Quantity Only)';
         var_fcst_material_list := '*FILE';
      end if;
      if rcd_fcst_load_header.fcst_source = '*TXV' then
         var_fcst_source := 'Text File (Quantity and Values)';
         var_fcst_material_list := '*FILE';
      end if;

      /*-*/
      /* Retrieve load detail material count
      /*-*/
      open csr_fcst_load_count;
      fetch csr_fcst_load_count into rcd_fcst_load_count;
      if csr_fcst_load_count%notfound then
         rcd_fcst_load_count.material_count := 0;
      end if;
      close csr_fcst_load_count;

      /*-*/
      /* Add the selection sheet
      /*-*/
      lics_spreadsheet.addSheet('Selection',false);

      /*-*/
      /* Set the selection data
      /*-*/
      lics_spreadsheet.setRange('A1:A1',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Selections');
      lics_spreadsheet.setHeadingBorder('A1:A1',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      lics_spreadsheet.setRange('A2:A2',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Identifier: '||rcd_fcst_load_header.load_identifier);
      lics_spreadsheet.setRange('A3:A3',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Description: '||rcd_fcst_load_header.load_description);
      lics_spreadsheet.setRange('A4:A4',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Status: '||rcd_fcst_load_header.load_status);
      lics_spreadsheet.setRange('A5:A5',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Replacement: '||rcd_fcst_load_header.load_replace);
      lics_spreadsheet.setRange('A6:A6',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Forecast Split: '||rcd_fcst_load_header.fcst_split_text);
      lics_spreadsheet.setRange('A7:A7',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Forecast Time: '||var_fcst_time);
      lics_spreadsheet.setRange('A8:A8',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Forecast Type: '||var_fcst_type);
      lics_spreadsheet.setRange('A9:A9',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Forecast Source: '||var_fcst_source);
      lics_spreadsheet.setRange('A10:A10',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Forecast Casting: '||to_char(rcd_fcst_load_header.fcst_cast_yyyynn,'fm000000'));
      lics_spreadsheet.setRange('A11:A11',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Forecast Materials: '||var_fcst_material_list);
      lics_spreadsheet.setRange('A12:A12',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Forecast Split Key Information');
      lics_spreadsheet.setRange('A13:A13',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Sales Organisation: '||rcd_fcst_load_header.sap_sales_org_code||' '||rcd_fcst_load_header.sales_org_desc);
      lics_spreadsheet.setRange('A14:A14',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Distribution Channel: '||rcd_fcst_load_header.sap_distbn_chnl_code||' '||rcd_fcst_load_header.distbn_chnl_desc);
      lics_spreadsheet.setRange('A15:A15',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Division: '||rcd_fcst_load_header.sap_division_code||' '||rcd_fcst_load_header.division_desc);
      lics_spreadsheet.setRange('A16:A16',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Sales Division Customer: '||nvl(rcd_fcst_load_header.sap_sales_div_cust_code,'N/A'));
      lics_spreadsheet.setRange('A17:A17',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Sales Division Sales Organisation: '||nvl(rcd_fcst_load_header.sap_sales_div_sales_org_code,'N/A'));
      lics_spreadsheet.setRange('A18:A18',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Sales Division Distribution Channel: '||nvl(rcd_fcst_load_header.sap_sales_div_distbn_chnl_code,'N/A'));
      lics_spreadsheet.setRange('A19:A19',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Sales Division Division: '||nvl(rcd_fcst_load_header.sap_sales_div_division_code,'N/A'));
      lics_spreadsheet.setRangeBorder('A2:A19',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);

      /*-*/
      /* Set the legend data
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         lics_spreadsheet.setRange('A21:A21',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Forecast Data Values');
         lics_spreadsheet.setRange('B21:B21',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Legend');
         lics_spreadsheet.setRange('C21:C21',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Type');
         lics_spreadsheet.setHeadingBorder('A21:C21',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRange('A22:A22',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The forecast quantity');
         lics_spreadsheet.setRange('B22:B22',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'QTY');
         lics_spreadsheet.setRange('C22:C22',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Data Entry');
         lics_spreadsheet.setRange('A23:A23',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The material list price');
         lics_spreadsheet.setRange('B23:B23',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'PRC');
         lics_spreadsheet.setRange('C23:C23',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Data Entry');
         lics_spreadsheet.setRange('A24:A24',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The base price value = QTY*PRC');
         lics_spreadsheet.setRange('B24:B24',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'BPS');
         lics_spreadsheet.setRange('C24:C24',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Calculated');
         lics_spreadsheet.setRange('A25:A25',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The general discount price (negative number)');
         lics_spreadsheet.setRange('B25:B25',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'DIS');
         lics_spreadsheet.setRange('C25:C25',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Data Entry');
         lics_spreadsheet.setRange('A26:A26',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The average volume discount % (positive number) (eg. 20% = .20)');
         lics_spreadsheet.setRange('B26:B26',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'VOL');
         lics_spreadsheet.setRange('C26:C26',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Data Entry');
         lics_spreadsheet.setRange('A27:A27',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The gross sales value = QTY*round((PRC+DIS)-((PRC+DIS)*VOL),0)');
         lics_spreadsheet.setRange('B27:B27',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'GSV');
         lics_spreadsheet.setRange('C27:C27',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Calculated');
         lics_spreadsheet.setRangeBorder('A22:C27',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      else
         lics_spreadsheet.setRange('A21:A21',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Forecast Data Values');
         lics_spreadsheet.setRange('B21:B21',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Legend');
         lics_spreadsheet.setRange('C21:C21',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Type');
         lics_spreadsheet.setHeadingBorder('A21:C21',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRange('A22:A22',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The forecast quantity');
         lics_spreadsheet.setRange('B22:B22',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'QTY');
         lics_spreadsheet.setRange('C22:C22',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Data Entry');
         lics_spreadsheet.setRange('A23:A23',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The base price value');
         lics_spreadsheet.setRange('B23:B23',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'BPS');
         lics_spreadsheet.setRange('C23:C23',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Data Entry');
         lics_spreadsheet.setRange('A24:A24',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The gross sales value');
         lics_spreadsheet.setRange('B24:B24',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'GSV');
         lics_spreadsheet.setRange('C24:C24',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Data Entry');
         lics_spreadsheet.setRangeBorder('A22:C24',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      end if;

      /*-*/
      /* Add the forecast sheet
      /*-*/
      lics_spreadsheet.addSheet('Forecasting',false);

      /*-*/
      /* Set the sheet heading
      /*-*/
      lics_spreadsheet.setRange('A1:A1','A1:R1',lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Forecast - '||var_fcst_time||' - '||var_fcst_type||' - Casting Period '||to_char(rcd_fcst_load_header.fcst_cast_yyyynn,'fm000000'));

      /*-*/
      /* Set the company heading
      /*-*/
      lics_spreadsheet.setRange('A2:A2','A2:R2', lics_spreadsheet.getHeadingType(2),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Company: '||rcd_fcst_load_header.company_desc);

      /*-*/
      /* Set the forecast heading
      /*-*/
      var_wrk_string := 'Material'||chr(9)||'Description'||chr(9)||'Data'||chr(9);
      var_cast_yyyynn := rcd_fcst_load_header.fcst_cast_yyyynn;
      for idx in 1..13 loop
         if substr(to_char(var_cast_yyyynn,'fm000000'),5,2) = '13' then
            var_cast_yyyynn := var_cast_yyyynn + 88;
         else
            var_cast_yyyynn := var_cast_yyyynn + 1;
         end if;
         var_wrk_string := var_wrk_string||to_char(var_cast_yyyynn,'FM000000')||chr(9);
      end loop;
      var_wrk_string := var_wrk_string||'Total'||chr(9)||'Error Message';
      lics_spreadsheet.setRangeArray('A3:A3','A3:R3',lics_spreadsheet.getHeadingType(7),lics_spreadsheet.FORMAT_CHAR_CENTRE,false,var_wrk_string);
      lics_spreadsheet.setHeadingBorder('A3:R3',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);

      /*-*/
      /* Initialise the row count
      /*-*/
      var_row_count := 3;

      /*-*/
      /* Exit when no detail lines
      /*-*/
      if rcd_fcst_load_count.material_count = 0 then
         lics_spreadsheet.setRange('A4:A4','A4:R4',lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'NO DETAILS EXIST');
         lics_spreadsheet.setRangeBorder('A4:R4',lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         return;
      end if;

      /*-*/
      /* Set the cell freeze
      /*-*/
      lics_spreadsheet.setFreezeCell('D4');

      /*-*/
      /* Set the data identifier start
      /*-*/
      var_row_count := var_row_count + 1;
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                'A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),
                                lics_spreadsheet.TYPE_MARKER,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'<XLSHEET IDENTIFIER="'||rcd_fcst_load_header.load_identifier||'">');
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_MEDIUM);

      /*-*/
      /* Define the QTY row
      /*-*/
      var_row_count := var_row_count + 1;
      var_wrk_string := '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0';
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'QTY');
      lics_spreadsheet.setRangeArray('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),
                                     'D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),
                                     lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,true,var_wrk_string);
      lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
      lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);

      /*-*/
      /* Define the PRC row when required
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         var_row_count := var_row_count + 1;
         var_wrk_string := '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0';
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'PRC');
         lics_spreadsheet.setRangeArray('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),
                                        'D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),
                                        lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_DECIMAL_0,true,var_wrk_string);
         lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,null);
         lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      end if;

      /*-*/
      /* Define the BPS row
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         var_row_count := var_row_count + 1;
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'BPS');
         lics_spreadsheet.setRange('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=D'||to_char(var_row_count-2,'FM999999990')||'*D'||to_char(var_row_count-1,'FM999999990')||'');
         lics_spreadsheet.setRangeFill('D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.FILL_RIGHT);
         lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
         lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      else
         var_row_count := var_row_count + 1;
         var_wrk_string := '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0';
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'BPS');
         lics_spreadsheet.setRangeArray('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),
                                        'D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),
                                        lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_DECIMAL_0,true,var_wrk_string);
         lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
         lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      end if;

      /*-*/
      /* Define the DIS row when required
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         var_row_count := var_row_count + 1;
         var_wrk_string := '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0';
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'DIS');
         lics_spreadsheet.setRangeArray('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),
                                        'D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),
                                        lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_DECIMAL_0,true,var_wrk_string);
         lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,null);
         lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      end if;

      /*-*/
      /* Define the VOL row when required
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         var_row_count := var_row_count + 1;
         var_wrk_string := '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0';
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'VOL');
         lics_spreadsheet.setRangeArray('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),
                                        'D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),
                                        lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_DECIMAL_2,true,var_wrk_string);
         lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_DECIMAL_2,0,false,null);
         lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      end if;

      /*-*/
      /* Define the GSV row
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         var_row_count := var_row_count + 1;
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'GSV');
         lics_spreadsheet.setRange('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=D'||to_char(var_row_count-5,'FM999999990')||'*round((D'||to_char(var_row_count-4,'FM999999990')||'+D'||to_char(var_row_count-2,'FM999999990')||')-((D'||to_char(var_row_count-4,'FM999999990')||'+D'||to_char(var_row_count-2,'FM999999990')||')*D'||to_char(var_row_count-1,'FM999999990')||'),0)');
         lics_spreadsheet.setRangeFill('D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.FILL_RIGHT);
         lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
         lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      else
         var_row_count := var_row_count + 1;
         var_wrk_string := '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0';
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'GSV');
         lics_spreadsheet.setRangeArray('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),
                                        'D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),
                                        lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_DECIMAL_0,true,var_wrk_string);
         lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
         lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      end if;

      /*-*/
      /* Define the borders
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count-5,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('B'||to_char(var_row_count-5,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('C'||to_char(var_row_count-5,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('R'||to_char(var_row_count-5,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_MEDIUM);
      else
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count-2,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('B'||to_char(var_row_count-2,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('C'||to_char(var_row_count-2,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('R'||to_char(var_row_count-2,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_MEDIUM);
      end if;

      /*-*/
      /* Define the copy
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         lics_spreadsheet.setRangeCopy('A'||to_char(var_row_count-5,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),rcd_fcst_load_count.material_count-1,lics_spreadsheet.COPY_DOWN);
      else
         lics_spreadsheet.setRangeCopy('A'||to_char(var_row_count-2,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),rcd_fcst_load_count.material_count-1,lics_spreadsheet.COPY_DOWN);
      end if;

      /*-*/
      /* Set the data identifier end 
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         var_row_count := var_row_count + ((rcd_fcst_load_count.material_count-1)*6) + 1;
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                   'A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),
                                   lics_spreadsheet.TYPE_MARKER,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'</XLSHEET>');
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_MEDIUM);

      else
         var_row_count := var_row_count + ((rcd_fcst_load_count.material_count-1)*3) + 1;
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                   'A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),
                                   lics_spreadsheet.TYPE_MARKER,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'</XLSHEET>');
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_MEDIUM);
      end if;
      var_end_count := var_row_count;

      /*-*/
      /* Set the print settings
      /*-*/
      lics_spreadsheet.setPrintData('$1:$3','$A:$A',2,1,0);

      /*-*/
      /* Output the forecast values
      /*-*/
      var_row_count := 4;

      /*-*/
      /* Retrieve the forecast load detail
      /*-*/
      open csr_fcst_load_detail;
      loop
         fetch csr_fcst_load_detail into rcd_fcst_load_detail;
         if csr_fcst_load_detail%notfound then
            exit;
         end if;

         /*-*/
         /* Output the QTY row
         /*-*/
         var_row_count := var_row_count + 1;
         var_wrk_string := rcd_fcst_load_detail.sap_material_code||chr(9)||
                           rcd_fcst_load_detail.material_desc_en||chr(9)||
                           'QTY'||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_01,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_02,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_03,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_04,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_05,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_06,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_07,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_08,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_09,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_10,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_11,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_12,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_13,'fm999999990');
         lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                        null,null,null,false,var_wrk_string);
         if not(rcd_fcst_load_detail.err_message is null) then
            lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                      lics_spreadsheet.TYPE_NONE,lics_spreadsheet.FORMAT_NONE,0,false,rcd_fcst_load_detail.err_message);
         end if;

         /*-*/
         /* Output the PRC row when required
         /*-*/
         if rcd_fcst_load_header.fcst_source != '*TXV' then
            var_row_count := var_row_count + 1;
            var_wrk_string := chr(9)||
                              chr(9)||
                              'PRC'||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_01,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_02,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_03,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_04,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_05,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_06,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_07,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_08,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_09,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_10,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_11,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_12,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_13,'fm999999990');
            lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                           null,null,null,false,var_wrk_string);
         end if;

         /*-*/
         /* Output the BPS row
         /*-*/
         if rcd_fcst_load_header.fcst_source != '*TXV' then
            var_row_count := var_row_count + 1;
         else
            var_row_count := var_row_count + 1;
            var_wrk_string := chr(9)||
                              chr(9)||
                              'BPS'||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_01,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_02,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_03,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_04,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_05,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_06,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_07,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_08,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_09,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_10,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_11,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_12,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_13,'fm999999990');
            lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                           null,null,null,false,var_wrk_string);
         end if;

         /*-*/
         /* Output the DIS row when required
         /*-*/
         if rcd_fcst_load_header.fcst_source != '*TXV' then
            var_row_count := var_row_count + 1;
            var_wrk_string := chr(9)||
                              chr(9)||
                              'DIS'||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_01,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_02,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_03,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_04,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_05,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_06,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_07,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_08,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_09,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_10,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_11,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_12,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_13,'fm999999990');
            lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                           null,null,null,false,var_wrk_string);
         end if;

         /*-*/
         /* Output the VOL row when required
         /*-*/
         if rcd_fcst_load_header.fcst_source != '*TXV' then
            var_row_count := var_row_count + 1;
            var_wrk_string := chr(9)||
                              chr(9)||
                              'VOL'||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_01,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_02,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_03,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_04,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_05,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_06,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_07,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_08,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_09,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_10,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_11,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_12,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_13,'fm999999990.00');
            lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                           null,null,null,false,var_wrk_string);
         end if;

         /*-*/
         /* Output the GSV row
         /*-*/
         if rcd_fcst_load_header.fcst_source != '*TXV' then
            var_row_count := var_row_count + 1;
         else
            var_row_count := var_row_count + 1;
            var_wrk_string := chr(9)||
                              chr(9)||
                              'GSV'||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_01,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_02,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_03,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_04,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_05,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_06,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_07,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_08,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_09,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_10,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_11,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_12,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_13,'fm999999990');
            lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                           null,null,null,false,var_wrk_string);
         end if;

      end loop;
      close csr_fcst_load_detail;

      /*-*/
      /* Define the QTY total row
      /*-*/
      var_row_count := var_end_count + 1;
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                'A'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_RIGHT,0,false,'Grand Totals:');
      lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'QTY');
      lics_spreadsheet.setRange('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",D4:D'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('E'||to_char(var_row_count,'FM999999990')||':E'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",E4:E'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('F'||to_char(var_row_count,'FM999999990')||':F'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",F4:F'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('G'||to_char(var_row_count,'FM999999990')||':G'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",G4:G'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('H'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",H4:H'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('I'||to_char(var_row_count,'FM999999990')||':I'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",I4:I'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('J'||to_char(var_row_count,'FM999999990')||':J'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",J4:J'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('K'||to_char(var_row_count,'FM999999990')||':K'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",K4:K'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('L'||to_char(var_row_count,'FM999999990')||':L'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",L4:L'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('M'||to_char(var_row_count,'FM999999990')||':M'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",M4:M'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('N'||to_char(var_row_count,'FM999999990')||':N'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",N4:N'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('O'||to_char(var_row_count,'FM999999990')||':O'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",O4:O'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('P'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",P4:P'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
      lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);

      /*-*/
      /* Define the BPS total row
      /*-*/
      var_row_count := var_row_count + 1;
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                'A'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'BPS');
      lics_spreadsheet.setRange('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",D4:D'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('E'||to_char(var_row_count,'FM999999990')||':E'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",E4:E'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('F'||to_char(var_row_count,'FM999999990')||':F'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",F4:F'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('G'||to_char(var_row_count,'FM999999990')||':G'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",G4:G'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('H'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",H4:H'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('I'||to_char(var_row_count,'FM999999990')||':I'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",I4:I'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('J'||to_char(var_row_count,'FM999999990')||':J'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",J4:J'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('K'||to_char(var_row_count,'FM999999990')||':K'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",K4:K'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('L'||to_char(var_row_count,'FM999999990')||':L'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",L4:L'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('M'||to_char(var_row_count,'FM999999990')||':M'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",M4:M'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('N'||to_char(var_row_count,'FM999999990')||':N'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",N4:N'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('O'||to_char(var_row_count,'FM999999990')||':O'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",O4:O'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('P'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",P4:P'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
      lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);

      /*-*/
      /* Define the GSV total row
      /*-*/
      var_row_count := var_row_count + 1;
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                'A'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'GSV');
      lics_spreadsheet.setRange('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",D4:D'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('E'||to_char(var_row_count,'FM999999990')||':E'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",E4:E'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('F'||to_char(var_row_count,'FM999999990')||':F'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",F4:F'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('G'||to_char(var_row_count,'FM999999990')||':G'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",G4:G'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('H'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",H4:H'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('I'||to_char(var_row_count,'FM999999990')||':I'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",I4:I'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('J'||to_char(var_row_count,'FM999999990')||':J'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",J4:J'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('K'||to_char(var_row_count,'FM999999990')||':K'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",K4:K'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('L'||to_char(var_row_count,'FM999999990')||':L'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",L4:L'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('M'||to_char(var_row_count,'FM999999990')||':M'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",M4:M'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('N'||to_char(var_row_count,'FM999999990')||':N'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",N4:N'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('O'||to_char(var_row_count,'FM999999990')||':O'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",O4:O'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('P'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",P4:P'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
      lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      /*-*/
      /* Define the total borders
      /*-*/
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count-2,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      lics_spreadsheet.setRangeBorder('C'||to_char(var_row_count-2,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      lics_spreadsheet.setRangeBorder('R'||to_char(var_row_count-2,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_MEDIUM);

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_FORECAST_LOADING - SELECT_LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_load;

   /***************************************************/
   /* This procedure performs the delete load routine */
   /***************************************************/
   procedure delete_load(par_identifier in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_identifier fcst_load_header.load_identifier%type;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_header is 
         select *
           from fcst_load_header t01
          where t01.load_identifier = var_identifier
            for update nowait;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_identifier := upper(par_identifier);
      if var_identifier is null then
         raise_application_error(-20000, 'Forecast load identifier must be specified');
      end if;

      /*-*/
      /* Attempt to lock the forecast header row
      /* notes - must still exist
      /*         must not be locked
      /*-*/
      var_available := true;
      begin
         open csr_fcst_load_header;
         fetch csr_fcst_load_header into rcd_fcst_load_header;
         if csr_fcst_load_header%notfound then
            var_available := false;
         end if;
      exception
         when others then
            var_available := false;
      end;
      if csr_fcst_load_header%isopen then
         close csr_fcst_load_header;
      end if;

      /*-*/
      /* Release the header lock when not available
      /* 1. Cursor row locks are not released until commit or rollback
      /* 2. Cursor close does not release row locks
      /*-*/
      if var_available = false then
         raise_application_error(-20000, 'Forecast load (' || var_identifier || ') does not exist or is already locked');
      end if;

      /*-*/
      /* Delete the forecast load detail
      /*-*/
      delete from fcst_load_detail
       where load_identifier = rcd_fcst_load_header.load_identifier;

      /*-*/
      /* Delete the forecast load header
      /*-*/
      delete from fcst_load_header
       where load_identifier = rcd_fcst_load_header.load_identifier;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_FORECAST_LOADING - DELETE_LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_load;

   /*********************************************************/
   /* This function performs the create period load routine */
   /*********************************************************/
   function create_period_load(par_identifier in varchar2,
                               par_description in varchar2,
                               par_replace in varchar2,
                               par_type in varchar2,
                               par_split_division in varchar2,
                               par_split_brand in varchar2,
                               par_split_sub_brand in varchar2,
                               par_source in varchar2,
                               par_material_list in varchar2,
                               par_user in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      rcd_fcst_load_header fcst_load_header%rowtype;
      rcd_fcst_load_detail fcst_load_detail%rowtype;
      var_title varchar2(128);
      var_message varchar2(4000);
      var_cast_yyyynn rcd_fcst_load_header.fcst_cast_yyyynn%type;
      var_from_yyyynn rcd_fcst_load_header.fcst_cast_yyyynn%type;
      var_str_yyyynn rcd_fcst_load_header.fcst_cast_yyyynn%type;
      var_end_yyyynn rcd_fcst_load_header.fcst_cast_yyyynn%type;
      var_identifier fcst_load_header.load_identifier%type;
      var_description fcst_load_header.load_description%type;
      var_replace rcd_fcst_load_header.load_replace%type;
      var_split_division fcst_load_header.fcst_split_division%type;
      var_split_brand fcst_load_header.fcst_split_brand%type;
      var_split_sub_brand fcst_load_header.fcst_split_sub_brand%type;
      var_type rcd_fcst_load_header.fcst_type%type;
      var_source rcd_fcst_load_header.fcst_source%type;
      var_material_list rcd_fcst_load_header.fcst_material_list%type;
      var_user rcd_fcst_load_header.crt_user%type;
      type typ_wrkv is table of number index by binary_integer;
      tbl_wrkn typ_wrkv;
      tbl_wrkp typ_wrkv;
      tbl_wrkd typ_wrkv;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_check is 
         select *
           from fcst_load_header t01
          where t01.load_identifier = var_identifier;
      rcd_fcst_load_check csr_fcst_load_check%rowtype;

      cursor csr_fcst_split is 
         select t01.sap_sales_org_code,
                t01.sap_distbn_chnl_code,
                t01.sap_division_code,
                t01.sap_sales_div_cust_code,
                t01.sap_sales_div_sales_org_code,
                t01.sap_sales_div_distbn_chnl_code,
                t01.sap_sales_div_division_code
           from fcst_split t01
          where t01.fcst_split_division = var_split_division
            and t01.fcst_split_brand = var_split_brand
            and t01.fcst_split_sub_brand = var_split_sub_brand;
      rcd_fcst_split csr_fcst_split%rowtype;

      cursor csr_mars_date is
         select t01.mars_period
           from mars_date t01
          where to_char(t01.calendar_date,'yyyymmdd') = to_char(sysdate,'yyyymmdd');
      rcd_mars_date csr_mars_date%rowtype;

      cursor csr_fcst_text14_detail is
         select t01.sap_material_code,
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
           from fcst_data t01;
      rcd_fcst_text14_detail csr_fcst_text14_detail%rowtype;

      cursor csr_fcst_text40_detail is
         select t01.sap_material_code,
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
                t01.fcst_qty13,
                t01.fcst_bps01,
                t01.fcst_bps02,
                t01.fcst_bps03,
                t01.fcst_bps04,
                t01.fcst_bps05,
                t01.fcst_bps06,
                t01.fcst_bps07,
                t01.fcst_bps08,
                t01.fcst_bps09,
                t01.fcst_bps10,
                t01.fcst_bps11,
                t01.fcst_bps12,
                t01.fcst_bps13,
                t01.fcst_gsv01,
                t01.fcst_gsv02,
                t01.fcst_gsv03,
                t01.fcst_gsv04,
                t01.fcst_gsv05,
                t01.fcst_gsv06,
                t01.fcst_gsv07,
                t01.fcst_gsv08,
                t01.fcst_gsv09,
                t01.fcst_gsv10,
                t01.fcst_gsv11,
                t01.fcst_gsv12,
                t01.fcst_gsv13
           from fcst_data t01;
      rcd_fcst_text40_detail csr_fcst_text40_detail%rowtype;

      cursor csr_material_price_list is
         select t04.mars_period as str_yyyynn,
                nvl(t05.mars_period,999999) as end_yyyynn,
                ((t02.material_list_price/t02.material_list_price_per_units)*nvl(t03.denominator_x_conv,1))/nvl(t03.numerator_y_conv,1) as material_price 
           from material_dim t01,
                material_list_price t02, 
                material_uom t03,
                mars_date t04,
                mars_date t05
          where decode(t01.sap_rep_item_code,null,t01.sap_material_code,t01.sap_rep_item_code) = t02.sap_material_code
            and t02.sap_material_code = t03.sap_material_code(+)
            and t02.material_list_price_uom_code = t03.alt_uom_code(+)
            and t02.material_list_price_valid_from = t04.calendar_date
            and t02.material_list_price_valid_to = t05.calendar_date(+)
            and t01.sap_material_code = rcd_fcst_load_detail.sap_material_code
            and t02.sap_sales_org_code = rcd_fcst_load_header.sap_sales_org_code
            and t02.sap_distbn_chnl_code is null
            and t02.sap_cndtn_type_code = 'PR00'
            and (t04.mars_period <= var_str_yyyynn or
                 (t05.mars_period is null or t05.mars_period >= var_end_yyyynn))
          order by t04.mars_period asc,
                   t05.mars_period asc;
      rcd_material_price_list csr_material_price_list%rowtype;

      cursor csr_material_price_gdsc is 
         select t04.mars_period as str_yyyynn,
                nvl(t05.mars_period,999999) as end_yyyynn,
                ((t02.material_list_price/t02.material_list_price_per_units)*nvl(t03.denominator_x_conv,1))/nvl(t03.numerator_y_conv,1) as material_price 
           from material_dim t01,
                material_list_price t02, 
                material_uom t03,
                mars_date t04,
                mars_date t05
          where decode(t01.sap_rep_item_code,null,t01.sap_material_code,t01.sap_rep_item_code) = t02.sap_material_code
            and t02.sap_material_code = t03.sap_material_code(+)
            and t02.material_list_price_uom_code = t03.alt_uom_code(+)
            and t02.material_list_price_valid_from = t04.calendar_date
            and t02.material_list_price_valid_to = t05.calendar_date(+)
            and t01.sap_material_code = rcd_fcst_load_detail.sap_material_code
            and t02.sap_sales_org_code = rcd_fcst_load_header.sap_sales_org_code
            and t02.sap_distbn_chnl_code = rcd_fcst_load_header.sap_distbn_chnl_code
            and t02.sap_cndtn_type_code = 'ZK30'
            and (t04.mars_period <= var_str_yyyynn or
                 (t05.mars_period is null or t05.mars_period >= var_end_yyyynn))
          order by t04.mars_period asc,
                   t05.mars_period asc;
      rcd_material_price_gdsc csr_material_price_gdsc%rowtype;

      cursor csr_material_price_vdsc is 
         select nvl(decode(sum(t01.sales_dtl_price_value_12),0,0,
                           decode(sum(t01.sales_dtl_price_value_13),0,0,
                                  round(sum(sales_dtl_price_value_12)/sum(sales_dtl_price_value_13),2)*-1)),0) as material_price
           from sales_period_03_fact t01
          where t01.sap_material_code = rcd_fcst_load_detail.sap_material_code
            and t01.sap_sales_dtl_sales_org_code = rcd_fcst_load_header.sap_sales_org_code
            and t01.sap_sales_dtl_distbn_chnl_code = rcd_fcst_load_header.sap_distbn_chnl_code
            and t01.sap_billing_yyyypp = rcd_fcst_load_header.fcst_cast_yyyynn
            and t01.sales_dtl_price_value_12 != 0;
      rcd_material_price_vdsc csr_material_price_vdsc%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'CLIO - Forecast Loading - Create Period Load';
      var_message := null;

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_identifier := upper(par_identifier);
      var_description := par_description;
      var_replace := par_replace;
      var_type := par_type;
      var_split_division := par_split_division;
      var_split_brand := par_split_brand;
      var_split_sub_brand := par_split_sub_brand;
      var_source := par_source;
      var_material_list := upper(par_material_list);
      var_user := upper(par_user);
      if var_identifier is null then
         var_message := var_message || chr(13) || 'Forecast load identifier must be specified';
      end if;
      if var_description is null then
         var_message := var_message || chr(13) || 'Forecast load description must be specified';
      end if;
      if var_replace != '*SPLIT' and var_replace != '*MATERIAL' then
         var_message := var_message || chr(13) || 'Forecast load replacement must be *SPLIT or *MATERIAL';
      end if;
      if var_type != '*BR1' and var_type != '*BR2' and var_type != '*OP1' and var_type != '*OP2' then
         var_message := var_message || chr(13) || 'Forecast type must be *BR, *OP1 or *OP2';
      end if;
      if var_type = '*OP1' or var_type = '*OP2' then
         if var_source != '*TXQ' and var_source != '*TXV' then
            var_message := var_message || chr(13) || 'Forecast source must be Text File for Operating Plan';
         end if;
      end if;
      if var_split_division is null then
         var_message := var_message || chr(13) || 'Forecast split division must be specified';
      end if;
      if var_split_brand is null then
         var_message := var_message || chr(13) || 'Forecast split brand must be specified';
      end if;
      if var_split_sub_brand is null then
         var_message := var_message || chr(13) || 'Forecast split sub brand must be specified';
      end if;
      if var_source != '*PLN' and var_source != '*TXQ' and var_source != '*TXV' then
         var_message := var_message || chr(13) || 'Forecast data source must be *PLN, *TXQ or *TXV';
      end if;
      if var_source = '*PLN' then
         if var_material_list is null then
            var_material_list := '*ALL';
         end if;
         if var_material_list != '*ALL' then
            read_txt_stream(var_material_list);
         end if;
      end if;
      if var_source = '*TXQ' or var_source = '*TXV' then
         var_material_list := '*ALL';
         read_xml_stream(var_source,lics_form.get_clob('FOR_STREAM'));
      end if;
      if var_user is null then
         var_user := user;
      end if;

      /*-*/
      /* Validate the database
      /*-*/
      if var_message is null then

         /*-*/
         /* Forecast load header must not exist
         /*-*/
         open csr_fcst_load_check;
         fetch csr_fcst_load_check into rcd_fcst_load_check;
         if csr_fcst_load_check%found then
            var_message := var_message || chr(13) || 'Forecast load (' || upper(par_identifier) || ') already exists';
         end if;
         close csr_fcst_load_check;

         /*-*/
         /* Forecast split must exist
         /*-*/
         open csr_fcst_split;
         fetch csr_fcst_split into rcd_fcst_split;
         if csr_fcst_split%notfound then
            var_message := var_message || chr(13) || 'Forecast split (' || var_split_division || '/' || var_split_brand || '/' || var_split_sub_brand || ') does not exist';
         end if;
         close csr_fcst_split;

         /*-*/
         /* Retrieve the current period (ie. sysdate)
         /*-*/
         open csr_mars_date;
         fetch csr_mars_date into rcd_mars_date;
         if csr_mars_date%notfound then
            var_message := var_message || chr(13) || 'Mars date (' || to_char(sysdate,'yyyy/mm/dd') || ') does not exist';
         end if;
         close csr_mars_date;
         if var_type = '*BR1' then
            if var_source != '*PLN' then
               var_cast_yyyynn := rcd_mars_date.mars_period - 1;
               if substr(to_char(var_cast_yyyynn,'fm000000'),5,2) = '00' then
                  var_cast_yyyynn := var_cast_yyyynn - 87;
               end if;
            end if;
         end if;
         if var_type = '*BR2' then
            if var_source != '*PLN' then
               var_cast_yyyynn := rcd_mars_date.mars_period;
            end if;
         end if;
         if var_type = '*OP1' then
            var_cast_yyyynn := trunc((rcd_mars_date.mars_period/100))*100;
         end if;
         if var_type = '*OP2' then
            var_cast_yyyynn := trunc((rcd_mars_date.mars_period/100)+1)*100;
         end if;
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Set the BR type
      /*-*/
      if var_type = '*BR1' or var_type = '*BR2' then
         var_type := '*BR';
      end if;

      /*-*/
      /* Calculate the start and end periods and load the period array
      /*-*/
      var_str_yyyynn := var_cast_yyyynn;
      var_end_yyyynn := var_cast_yyyynn;
      for idx in 1..13 loop
         if substr(to_char(var_end_yyyynn,'fm000000'),5,2) = '13' then
            var_end_yyyynn := var_end_yyyynn + 88;
         else
            var_end_yyyynn := var_end_yyyynn + 1;
         end if;
         if idx = 1 then
            var_str_yyyynn := var_end_yyyynn;
         end if;
         tbl_wrkn(idx) := var_end_yyyynn;
      end loop;

      /*-*/
      /* Insert the new forecast load header
      /*-*/
      rcd_fcst_load_header.load_identifier := var_identifier;
      rcd_fcst_load_header.load_description := var_description;
      rcd_fcst_load_header.load_status := '*CREATING';
      rcd_fcst_load_header.load_replace := var_replace;
      rcd_fcst_load_header.fcst_split_division := var_split_division;
      rcd_fcst_load_header.fcst_split_brand := var_split_brand;
      rcd_fcst_load_header.fcst_split_sub_brand := var_split_sub_brand;
      rcd_fcst_load_header.fcst_material_list := var_material_list;
      rcd_fcst_load_header.fcst_time := '*PRD';
      rcd_fcst_load_header.fcst_type := var_type;
      rcd_fcst_load_header.fcst_source := var_source;
      rcd_fcst_load_header.fcst_cast_yyyynn := var_cast_yyyynn;
      rcd_fcst_load_header.sap_sales_org_code := rcd_fcst_split.sap_sales_org_code;
      rcd_fcst_load_header.sap_distbn_chnl_code := rcd_fcst_split.sap_distbn_chnl_code;
      rcd_fcst_load_header.sap_division_code := rcd_fcst_split.sap_division_code;
      rcd_fcst_load_header.sap_sales_div_cust_code := rcd_fcst_split.sap_sales_div_cust_code;
      rcd_fcst_load_header.sap_sales_div_sales_org_code := rcd_fcst_split.sap_sales_div_sales_org_code;
      rcd_fcst_load_header.sap_sales_div_distbn_chnl_code := rcd_fcst_split.sap_sales_div_distbn_chnl_code;
      rcd_fcst_load_header.sap_sales_div_division_code := rcd_fcst_split.sap_sales_div_division_code;
      rcd_fcst_load_header.crt_user := var_user;
      rcd_fcst_load_header.crt_date := sysdate;
      rcd_fcst_load_header.upd_user := var_user;
      rcd_fcst_load_header.upd_date := sysdate;
      insert into fcst_load_header
         (load_identifier,
          load_description,
          load_status,
          load_replace,
          fcst_split_division,
          fcst_split_brand,
          fcst_split_sub_brand,
          fcst_material_list,
          fcst_time,
          fcst_type,
          fcst_source,
          fcst_cast_yyyynn,
          sap_sales_org_code,
          sap_distbn_chnl_code,
          sap_division_code,
          sap_sales_div_cust_code,
          sap_sales_div_sales_org_code,
          sap_sales_div_distbn_chnl_code,
          sap_sales_div_division_code,
          crt_user,
          crt_date,
          upd_user,
          upd_date)
         values(rcd_fcst_load_header.load_identifier,
                rcd_fcst_load_header.load_description,
                rcd_fcst_load_header.load_status,
                rcd_fcst_load_header.load_replace,
                rcd_fcst_load_header.fcst_split_division,
                rcd_fcst_load_header.fcst_split_brand,
                rcd_fcst_load_header.fcst_split_sub_brand,
                rcd_fcst_load_header.fcst_material_list,
                rcd_fcst_load_header.fcst_time,
                rcd_fcst_load_header.fcst_type,
                rcd_fcst_load_header.fcst_source,
                rcd_fcst_load_header.fcst_cast_yyyynn,
                rcd_fcst_load_header.sap_sales_org_code,
                rcd_fcst_load_header.sap_distbn_chnl_code,
                rcd_fcst_load_header.sap_division_code,
                rcd_fcst_load_header.sap_sales_div_cust_code,
                rcd_fcst_load_header.sap_sales_div_sales_org_code,
                rcd_fcst_load_header.sap_sales_div_distbn_chnl_code,
                rcd_fcst_load_header.sap_sales_div_division_code,
                rcd_fcst_load_header.crt_user,
                rcd_fcst_load_header.crt_date,
                rcd_fcst_load_header.upd_user,
                rcd_fcst_load_header.upd_date);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve the forecast quantity types
      /*-*/
      if var_source = '*TXQ' then

         open csr_fcst_text14_detail;
         loop
            fetch csr_fcst_text14_detail into rcd_fcst_text14_detail;
            if csr_fcst_text14_detail%notfound then
               exit;
            end if;

            /*-*/
            /* Set the forecast load detail
            /*-*/
            rcd_fcst_load_detail.load_identifier := rcd_fcst_load_header.load_identifier;
            rcd_fcst_load_detail.err_message := null;
            rcd_fcst_load_detail.sap_material_code := rcd_fcst_text14_detail.sap_material_code;
            rcd_fcst_load_detail.fcst_qty_01 := rcd_fcst_text14_detail.fcst_qty01;
            rcd_fcst_load_detail.fcst_qty_02 := rcd_fcst_text14_detail.fcst_qty02;
            rcd_fcst_load_detail.fcst_qty_03 := rcd_fcst_text14_detail.fcst_qty03;
            rcd_fcst_load_detail.fcst_qty_04 := rcd_fcst_text14_detail.fcst_qty04;
            rcd_fcst_load_detail.fcst_qty_05 := rcd_fcst_text14_detail.fcst_qty05;
            rcd_fcst_load_detail.fcst_qty_06 := rcd_fcst_text14_detail.fcst_qty06;
            rcd_fcst_load_detail.fcst_qty_07 := rcd_fcst_text14_detail.fcst_qty07;
            rcd_fcst_load_detail.fcst_qty_08 := rcd_fcst_text14_detail.fcst_qty08;
            rcd_fcst_load_detail.fcst_qty_09 := rcd_fcst_text14_detail.fcst_qty09;
            rcd_fcst_load_detail.fcst_qty_10 := rcd_fcst_text14_detail.fcst_qty10;
            rcd_fcst_load_detail.fcst_qty_11 := rcd_fcst_text14_detail.fcst_qty11;
            rcd_fcst_load_detail.fcst_qty_12 := rcd_fcst_text14_detail.fcst_qty12;
            rcd_fcst_load_detail.fcst_qty_13 := rcd_fcst_text14_detail.fcst_qty13;

            /*-*/
            /* Retrieve the average volume discount
            /*-*/
            open csr_material_price_vdsc;
            fetch csr_material_price_vdsc into rcd_material_price_vdsc;
            if csr_material_price_vdsc%notfound then
               rcd_material_price_vdsc.material_price := 0;
            end if;
            close csr_material_price_vdsc;

            /*-*/
            /* Retrieve the list price
            /*-*/
            for idx in 1..13 loop
               tbl_wrkp(idx) := 0;
	    end loop;
            open csr_material_price_list;
            loop
               fetch csr_material_price_list into rcd_material_price_list;
               if csr_material_price_list%notfound then
                  exit;
               end if;
               for idx in 1..13 loop
                  if rcd_material_price_list.str_yyyynn <= tbl_wrkn(idx) and
                     rcd_material_price_list.end_yyyynn >= tbl_wrkn(idx) then
                     tbl_wrkp(idx) := rcd_material_price_list.material_price;
                  end if;
               end loop;
            end loop;
            close csr_material_price_list;

            /*-*/
            /* Retrieve the general discount
            /*-*/
            for idx in 1..13 loop
               tbl_wrkd(idx) := 0;
	    end loop;
            open csr_material_price_gdsc;
            loop
               fetch csr_material_price_gdsc into rcd_material_price_gdsc;
               if csr_material_price_gdsc%notfound then
                  exit;
               end if;
               for idx in 1..13 loop
                  if rcd_material_price_gdsc.str_yyyynn <= tbl_wrkn(idx) and
                     rcd_material_price_gdsc.end_yyyynn >= tbl_wrkn(idx) then
                     tbl_wrkd(idx) := rcd_material_price_gdsc.material_price;
                  end if;
               end loop;
            end loop;
            close csr_material_price_gdsc;

            /*-*/
            /* Set the forecast load value data
            /*-*/
            rcd_fcst_load_detail.fcst_prc_01 := tbl_wrkp(1);
            rcd_fcst_load_detail.fcst_prc_02 := tbl_wrkp(2);
            rcd_fcst_load_detail.fcst_prc_03 := tbl_wrkp(3);
            rcd_fcst_load_detail.fcst_prc_04 := tbl_wrkp(4);
            rcd_fcst_load_detail.fcst_prc_05 := tbl_wrkp(5);
            rcd_fcst_load_detail.fcst_prc_06 := tbl_wrkp(6);
            rcd_fcst_load_detail.fcst_prc_07 := tbl_wrkp(7);
            rcd_fcst_load_detail.fcst_prc_08 := tbl_wrkp(8);
            rcd_fcst_load_detail.fcst_prc_09 := tbl_wrkp(9);
            rcd_fcst_load_detail.fcst_prc_10 := tbl_wrkp(10);
            rcd_fcst_load_detail.fcst_prc_11 := tbl_wrkp(11);
            rcd_fcst_load_detail.fcst_prc_12 := tbl_wrkp(12);
            rcd_fcst_load_detail.fcst_prc_13 := tbl_wrkp(13);
            /*-*/
            rcd_fcst_load_detail.fcst_dis_01 := tbl_wrkd(1);
            rcd_fcst_load_detail.fcst_dis_02 := tbl_wrkd(2);
            rcd_fcst_load_detail.fcst_dis_03 := tbl_wrkd(3);
            rcd_fcst_load_detail.fcst_dis_04 := tbl_wrkd(4);
            rcd_fcst_load_detail.fcst_dis_05 := tbl_wrkd(5);
            rcd_fcst_load_detail.fcst_dis_06 := tbl_wrkd(6);
            rcd_fcst_load_detail.fcst_dis_07 := tbl_wrkd(7);
            rcd_fcst_load_detail.fcst_dis_08 := tbl_wrkd(8);
            rcd_fcst_load_detail.fcst_dis_09 := tbl_wrkd(9);
            rcd_fcst_load_detail.fcst_dis_10 := tbl_wrkd(10);
            rcd_fcst_load_detail.fcst_dis_11 := tbl_wrkd(11);
            rcd_fcst_load_detail.fcst_dis_12 := tbl_wrkd(12);
            rcd_fcst_load_detail.fcst_dis_13 := tbl_wrkd(13);
            /*-*/
            rcd_fcst_load_detail.fcst_vol_01 := rcd_material_price_vdsc.material_price;
            rcd_fcst_load_detail.fcst_vol_02 := rcd_material_price_vdsc.material_price;
            rcd_fcst_load_detail.fcst_vol_03 := rcd_material_price_vdsc.material_price;
            rcd_fcst_load_detail.fcst_vol_04 := rcd_material_price_vdsc.material_price;
            rcd_fcst_load_detail.fcst_vol_05 := rcd_material_price_vdsc.material_price;
            rcd_fcst_load_detail.fcst_vol_06 := rcd_material_price_vdsc.material_price;
            rcd_fcst_load_detail.fcst_vol_07 := rcd_material_price_vdsc.material_price;
            rcd_fcst_load_detail.fcst_vol_08 := rcd_material_price_vdsc.material_price;
            rcd_fcst_load_detail.fcst_vol_09 := rcd_material_price_vdsc.material_price;
            rcd_fcst_load_detail.fcst_vol_10 := rcd_material_price_vdsc.material_price;
            rcd_fcst_load_detail.fcst_vol_11 := rcd_material_price_vdsc.material_price;
            rcd_fcst_load_detail.fcst_vol_12 := rcd_material_price_vdsc.material_price;
            rcd_fcst_load_detail.fcst_vol_13 := rcd_material_price_vdsc.material_price;
            /*-*/
            rcd_fcst_load_detail.fcst_bps_01 := rcd_fcst_load_detail.fcst_qty_01*tbl_wrkp(1);
            rcd_fcst_load_detail.fcst_bps_02 := rcd_fcst_load_detail.fcst_qty_02*tbl_wrkp(2);
            rcd_fcst_load_detail.fcst_bps_03 := rcd_fcst_load_detail.fcst_qty_03*tbl_wrkp(3);
            rcd_fcst_load_detail.fcst_bps_04 := rcd_fcst_load_detail.fcst_qty_04*tbl_wrkp(4);
            rcd_fcst_load_detail.fcst_bps_05 := rcd_fcst_load_detail.fcst_qty_05*tbl_wrkp(5);
            rcd_fcst_load_detail.fcst_bps_06 := rcd_fcst_load_detail.fcst_qty_06*tbl_wrkp(6);
            rcd_fcst_load_detail.fcst_bps_07 := rcd_fcst_load_detail.fcst_qty_07*tbl_wrkp(7);
            rcd_fcst_load_detail.fcst_bps_08 := rcd_fcst_load_detail.fcst_qty_08*tbl_wrkp(8);
            rcd_fcst_load_detail.fcst_bps_09 := rcd_fcst_load_detail.fcst_qty_09*tbl_wrkp(9);
            rcd_fcst_load_detail.fcst_bps_10 := rcd_fcst_load_detail.fcst_qty_10*tbl_wrkp(10);
            rcd_fcst_load_detail.fcst_bps_11 := rcd_fcst_load_detail.fcst_qty_11*tbl_wrkp(11);
            rcd_fcst_load_detail.fcst_bps_12 := rcd_fcst_load_detail.fcst_qty_12*tbl_wrkp(12);
            rcd_fcst_load_detail.fcst_bps_13 := rcd_fcst_load_detail.fcst_qty_13*tbl_wrkp(13);
            /*-*/
            rcd_fcst_load_detail.fcst_gsv_01 := rcd_fcst_load_detail.fcst_qty_01*round((tbl_wrkp(1)+tbl_wrkd(1))-((tbl_wrkp(1)+tbl_wrkd(1))*rcd_fcst_load_detail.fcst_vol_01),0);
            rcd_fcst_load_detail.fcst_gsv_02 := rcd_fcst_load_detail.fcst_qty_02*round((tbl_wrkp(2)+tbl_wrkd(2))-((tbl_wrkp(2)+tbl_wrkd(2))*rcd_fcst_load_detail.fcst_vol_02),0);
            rcd_fcst_load_detail.fcst_gsv_03 := rcd_fcst_load_detail.fcst_qty_03*round((tbl_wrkp(3)+tbl_wrkd(3))-((tbl_wrkp(3)+tbl_wrkd(3))*rcd_fcst_load_detail.fcst_vol_03),0);
            rcd_fcst_load_detail.fcst_gsv_04 := rcd_fcst_load_detail.fcst_qty_04*round((tbl_wrkp(4)+tbl_wrkd(4))-((tbl_wrkp(4)+tbl_wrkd(4))*rcd_fcst_load_detail.fcst_vol_04),0);
            rcd_fcst_load_detail.fcst_gsv_05 := rcd_fcst_load_detail.fcst_qty_05*round((tbl_wrkp(5)+tbl_wrkd(5))-((tbl_wrkp(5)+tbl_wrkd(5))*rcd_fcst_load_detail.fcst_vol_05),0);
            rcd_fcst_load_detail.fcst_gsv_06 := rcd_fcst_load_detail.fcst_qty_06*round((tbl_wrkp(6)+tbl_wrkd(6))-((tbl_wrkp(6)+tbl_wrkd(6))*rcd_fcst_load_detail.fcst_vol_06),0);
            rcd_fcst_load_detail.fcst_gsv_07 := rcd_fcst_load_detail.fcst_qty_07*round((tbl_wrkp(7)+tbl_wrkd(7))-((tbl_wrkp(7)+tbl_wrkd(7))*rcd_fcst_load_detail.fcst_vol_07),0);
            rcd_fcst_load_detail.fcst_gsv_08 := rcd_fcst_load_detail.fcst_qty_08*round((tbl_wrkp(8)+tbl_wrkd(8))-((tbl_wrkp(8)+tbl_wrkd(8))*rcd_fcst_load_detail.fcst_vol_08),0);
            rcd_fcst_load_detail.fcst_gsv_09 := rcd_fcst_load_detail.fcst_qty_09*round((tbl_wrkp(9)+tbl_wrkd(9))-((tbl_wrkp(9)+tbl_wrkd(9))*rcd_fcst_load_detail.fcst_vol_09),0);
            rcd_fcst_load_detail.fcst_gsv_10 := rcd_fcst_load_detail.fcst_qty_10*round((tbl_wrkp(10)+tbl_wrkd(10))-((tbl_wrkp(10)+tbl_wrkd(10))*rcd_fcst_load_detail.fcst_vol_10),0);
            rcd_fcst_load_detail.fcst_gsv_11 := rcd_fcst_load_detail.fcst_qty_11*round((tbl_wrkp(11)+tbl_wrkd(11))-((tbl_wrkp(11)+tbl_wrkd(11))*rcd_fcst_load_detail.fcst_vol_11),0);
            rcd_fcst_load_detail.fcst_gsv_12 := rcd_fcst_load_detail.fcst_qty_12*round((tbl_wrkp(12)+tbl_wrkd(12))-((tbl_wrkp(12)+tbl_wrkd(12))*rcd_fcst_load_detail.fcst_vol_12),0);
            rcd_fcst_load_detail.fcst_gsv_13 := rcd_fcst_load_detail.fcst_qty_13*round((tbl_wrkp(13)+tbl_wrkd(13))-((tbl_wrkp(13)+tbl_wrkd(13))*rcd_fcst_load_detail.fcst_vol_13),0);

            /*-*/
            /* Insert the forecast load detail
            /*-*/
            insert into fcst_load_detail
               (load_identifier,
                sap_material_code,
                fcst_qty_01,
                fcst_qty_02,
                fcst_qty_03,
                fcst_qty_04,
                fcst_qty_05,
                fcst_qty_06,
                fcst_qty_07,
                fcst_qty_08,
                fcst_qty_09,
                fcst_qty_10,
                fcst_qty_11,
                fcst_qty_12,
                fcst_qty_13,
                fcst_prc_01,
                fcst_prc_02,
                fcst_prc_03,
                fcst_prc_04,
                fcst_prc_05,
                fcst_prc_06,
                fcst_prc_07,
                fcst_prc_08,
                fcst_prc_09,
                fcst_prc_10,
                fcst_prc_11,
                fcst_prc_12,
                fcst_prc_13,
                fcst_dis_01,
                fcst_dis_02,
                fcst_dis_03,
                fcst_dis_04,
                fcst_dis_05,
                fcst_dis_06,
                fcst_dis_07,
                fcst_dis_08,
                fcst_dis_09,
                fcst_dis_10,
                fcst_dis_11,
                fcst_dis_12,
                fcst_dis_13,
                fcst_vol_01,
                fcst_vol_02,
                fcst_vol_03,
                fcst_vol_04,
                fcst_vol_05,
                fcst_vol_06,
                fcst_vol_07,
                fcst_vol_08,
                fcst_vol_09,
                fcst_vol_10,
                fcst_vol_11,
                fcst_vol_12,
                fcst_vol_13,
                fcst_bps_01,
                fcst_bps_02,
                fcst_bps_03,
                fcst_bps_04,
                fcst_bps_05,
                fcst_bps_06,
                fcst_bps_07,
                fcst_bps_08,
                fcst_bps_09,
                fcst_bps_10,
                fcst_bps_11,
                fcst_bps_12,
                fcst_bps_13,
                fcst_gsv_01,
                fcst_gsv_02,
                fcst_gsv_03,
                fcst_gsv_04,
                fcst_gsv_05,
                fcst_gsv_06,
                fcst_gsv_07,
                fcst_gsv_08,
                fcst_gsv_09,
                fcst_gsv_10,
                fcst_gsv_11,
                fcst_gsv_12,
                fcst_gsv_13,
                err_message)
               values (rcd_fcst_load_detail.load_identifier,
                       rcd_fcst_load_detail.sap_material_code,
                       rcd_fcst_load_detail.fcst_qty_01,
                       rcd_fcst_load_detail.fcst_qty_02,
                       rcd_fcst_load_detail.fcst_qty_03,
                       rcd_fcst_load_detail.fcst_qty_04,
                       rcd_fcst_load_detail.fcst_qty_05,
                       rcd_fcst_load_detail.fcst_qty_06,
                       rcd_fcst_load_detail.fcst_qty_07,
                       rcd_fcst_load_detail.fcst_qty_08,
                       rcd_fcst_load_detail.fcst_qty_09,
                       rcd_fcst_load_detail.fcst_qty_10,
                       rcd_fcst_load_detail.fcst_qty_11,
                       rcd_fcst_load_detail.fcst_qty_12,
                       rcd_fcst_load_detail.fcst_qty_13,
                       rcd_fcst_load_detail.fcst_prc_01,
                       rcd_fcst_load_detail.fcst_prc_02,
                       rcd_fcst_load_detail.fcst_prc_03,
                       rcd_fcst_load_detail.fcst_prc_04,
                       rcd_fcst_load_detail.fcst_prc_05,
                       rcd_fcst_load_detail.fcst_prc_06,
                       rcd_fcst_load_detail.fcst_prc_07,
                       rcd_fcst_load_detail.fcst_prc_08,
                       rcd_fcst_load_detail.fcst_prc_09,
                       rcd_fcst_load_detail.fcst_prc_10,
                       rcd_fcst_load_detail.fcst_prc_11,
                       rcd_fcst_load_detail.fcst_prc_12,
                       rcd_fcst_load_detail.fcst_prc_13,
                       rcd_fcst_load_detail.fcst_dis_01,
                       rcd_fcst_load_detail.fcst_dis_02,
                       rcd_fcst_load_detail.fcst_dis_03,
                       rcd_fcst_load_detail.fcst_dis_04,
                       rcd_fcst_load_detail.fcst_dis_05,
                       rcd_fcst_load_detail.fcst_dis_06,
                       rcd_fcst_load_detail.fcst_dis_07,
                       rcd_fcst_load_detail.fcst_dis_08,
                       rcd_fcst_load_detail.fcst_dis_09,
                       rcd_fcst_load_detail.fcst_dis_10,
                       rcd_fcst_load_detail.fcst_dis_11,
                       rcd_fcst_load_detail.fcst_dis_12,
                       rcd_fcst_load_detail.fcst_dis_13,
                       rcd_fcst_load_detail.fcst_vol_01,
                       rcd_fcst_load_detail.fcst_vol_02,
                       rcd_fcst_load_detail.fcst_vol_03,
                       rcd_fcst_load_detail.fcst_vol_04,
                       rcd_fcst_load_detail.fcst_vol_05,
                       rcd_fcst_load_detail.fcst_vol_06,
                       rcd_fcst_load_detail.fcst_vol_07,
                       rcd_fcst_load_detail.fcst_vol_08,
                       rcd_fcst_load_detail.fcst_vol_09,
                       rcd_fcst_load_detail.fcst_vol_10,
                       rcd_fcst_load_detail.fcst_vol_11,
                       rcd_fcst_load_detail.fcst_vol_12,
                       rcd_fcst_load_detail.fcst_vol_13,
                       rcd_fcst_load_detail.fcst_bps_01,
                       rcd_fcst_load_detail.fcst_bps_02,
                       rcd_fcst_load_detail.fcst_bps_03,
                       rcd_fcst_load_detail.fcst_bps_04,
                       rcd_fcst_load_detail.fcst_bps_05,
                       rcd_fcst_load_detail.fcst_bps_06,
                       rcd_fcst_load_detail.fcst_bps_07,
                       rcd_fcst_load_detail.fcst_bps_08,
                       rcd_fcst_load_detail.fcst_bps_09,
                       rcd_fcst_load_detail.fcst_bps_10,
                       rcd_fcst_load_detail.fcst_bps_11,
                       rcd_fcst_load_detail.fcst_bps_12,
                       rcd_fcst_load_detail.fcst_bps_13,
                       rcd_fcst_load_detail.fcst_gsv_01,
                       rcd_fcst_load_detail.fcst_gsv_02,
                       rcd_fcst_load_detail.fcst_gsv_03,
                       rcd_fcst_load_detail.fcst_gsv_04,
                       rcd_fcst_load_detail.fcst_gsv_05,
                       rcd_fcst_load_detail.fcst_gsv_06,
                       rcd_fcst_load_detail.fcst_gsv_07,
                       rcd_fcst_load_detail.fcst_gsv_08,
                       rcd_fcst_load_detail.fcst_gsv_09,
                       rcd_fcst_load_detail.fcst_gsv_10,
                       rcd_fcst_load_detail.fcst_gsv_11,
                       rcd_fcst_load_detail.fcst_gsv_12,
                       rcd_fcst_load_detail.fcst_gsv_13,
                       rcd_fcst_load_detail.err_message);

         end loop;
         close csr_fcst_text14_detail;

      /*-*/
      /* Retrieve the forecast quantity/value type
      /*-*/
      else

         open csr_fcst_text40_detail;
         loop
            fetch csr_fcst_text40_detail into rcd_fcst_text40_detail;
            if csr_fcst_text40_detail%notfound then
               exit;
            end if;

            /*-*/
            /* Set the forecast load detail
            /*-*/
            rcd_fcst_load_detail.load_identifier := rcd_fcst_load_header.load_identifier;
            rcd_fcst_load_detail.err_message := null;
            rcd_fcst_load_detail.sap_material_code := rcd_fcst_text40_detail.sap_material_code;
            /*-*/
            rcd_fcst_load_detail.fcst_qty_01 := rcd_fcst_text40_detail.fcst_qty01;
            rcd_fcst_load_detail.fcst_qty_02 := rcd_fcst_text40_detail.fcst_qty02;
            rcd_fcst_load_detail.fcst_qty_03 := rcd_fcst_text40_detail.fcst_qty03;
            rcd_fcst_load_detail.fcst_qty_04 := rcd_fcst_text40_detail.fcst_qty04;
            rcd_fcst_load_detail.fcst_qty_05 := rcd_fcst_text40_detail.fcst_qty05;
            rcd_fcst_load_detail.fcst_qty_06 := rcd_fcst_text40_detail.fcst_qty06;
            rcd_fcst_load_detail.fcst_qty_07 := rcd_fcst_text40_detail.fcst_qty07;
            rcd_fcst_load_detail.fcst_qty_08 := rcd_fcst_text40_detail.fcst_qty08;
            rcd_fcst_load_detail.fcst_qty_09 := rcd_fcst_text40_detail.fcst_qty09;
            rcd_fcst_load_detail.fcst_qty_10 := rcd_fcst_text40_detail.fcst_qty10;
            rcd_fcst_load_detail.fcst_qty_11 := rcd_fcst_text40_detail.fcst_qty11;
            rcd_fcst_load_detail.fcst_qty_12 := rcd_fcst_text40_detail.fcst_qty12;
            rcd_fcst_load_detail.fcst_qty_13 := rcd_fcst_text40_detail.fcst_qty13;
            /*-*/
            rcd_fcst_load_detail.fcst_prc_01 := 0;
            rcd_fcst_load_detail.fcst_prc_02 := 0;
            rcd_fcst_load_detail.fcst_prc_03 := 0;
            rcd_fcst_load_detail.fcst_prc_04 := 0;
            rcd_fcst_load_detail.fcst_prc_05 := 0;
            rcd_fcst_load_detail.fcst_prc_06 := 0;
            rcd_fcst_load_detail.fcst_prc_07 := 0;
            rcd_fcst_load_detail.fcst_prc_08 := 0;
            rcd_fcst_load_detail.fcst_prc_09 := 0;
            rcd_fcst_load_detail.fcst_prc_10 := 0;
            rcd_fcst_load_detail.fcst_prc_11 := 0;
            rcd_fcst_load_detail.fcst_prc_12 := 0;
            rcd_fcst_load_detail.fcst_prc_13 := 0;
            /*-*/
            rcd_fcst_load_detail.fcst_dis_01 := 0;
            rcd_fcst_load_detail.fcst_dis_02 := 0;
            rcd_fcst_load_detail.fcst_dis_03 := 0;
            rcd_fcst_load_detail.fcst_dis_04 := 0;
            rcd_fcst_load_detail.fcst_dis_05 := 0;
            rcd_fcst_load_detail.fcst_dis_06 := 0;
            rcd_fcst_load_detail.fcst_dis_07 := 0;
            rcd_fcst_load_detail.fcst_dis_08 := 0;
            rcd_fcst_load_detail.fcst_dis_09 := 0;
            rcd_fcst_load_detail.fcst_dis_10 := 0;
            rcd_fcst_load_detail.fcst_dis_11 := 0;
            rcd_fcst_load_detail.fcst_dis_12 := 0;
            rcd_fcst_load_detail.fcst_dis_13 := 0;
            /*-*/
            rcd_fcst_load_detail.fcst_vol_01 := 0;
            rcd_fcst_load_detail.fcst_vol_02 := 0;
            rcd_fcst_load_detail.fcst_vol_03 := 0;
            rcd_fcst_load_detail.fcst_vol_04 := 0;
            rcd_fcst_load_detail.fcst_vol_05 := 0;
            rcd_fcst_load_detail.fcst_vol_06 := 0;
            rcd_fcst_load_detail.fcst_vol_07 := 0;
            rcd_fcst_load_detail.fcst_vol_08 := 0;
            rcd_fcst_load_detail.fcst_vol_09 := 0;
            rcd_fcst_load_detail.fcst_vol_10 := 0;
            rcd_fcst_load_detail.fcst_vol_11 := 0;
            rcd_fcst_load_detail.fcst_vol_12 := 0;
            rcd_fcst_load_detail.fcst_vol_13 := 0;
            /*-*/
            rcd_fcst_load_detail.fcst_bps_01 := rcd_fcst_text40_detail.fcst_bps01;
            rcd_fcst_load_detail.fcst_bps_02 := rcd_fcst_text40_detail.fcst_bps02;
            rcd_fcst_load_detail.fcst_bps_03 := rcd_fcst_text40_detail.fcst_bps03;
            rcd_fcst_load_detail.fcst_bps_04 := rcd_fcst_text40_detail.fcst_bps04;
            rcd_fcst_load_detail.fcst_bps_05 := rcd_fcst_text40_detail.fcst_bps05;
            rcd_fcst_load_detail.fcst_bps_06 := rcd_fcst_text40_detail.fcst_bps06;
            rcd_fcst_load_detail.fcst_bps_07 := rcd_fcst_text40_detail.fcst_bps07;
            rcd_fcst_load_detail.fcst_bps_08 := rcd_fcst_text40_detail.fcst_bps08;
            rcd_fcst_load_detail.fcst_bps_09 := rcd_fcst_text40_detail.fcst_bps09;
            rcd_fcst_load_detail.fcst_bps_10 := rcd_fcst_text40_detail.fcst_bps10;
            rcd_fcst_load_detail.fcst_bps_11 := rcd_fcst_text40_detail.fcst_bps11;
            rcd_fcst_load_detail.fcst_bps_12 := rcd_fcst_text40_detail.fcst_bps12;
            rcd_fcst_load_detail.fcst_bps_13 := rcd_fcst_text40_detail.fcst_bps13;
            /*-*/
            rcd_fcst_load_detail.fcst_gsv_01 := rcd_fcst_text40_detail.fcst_gsv01;
            rcd_fcst_load_detail.fcst_gsv_02 := rcd_fcst_text40_detail.fcst_gsv02;
            rcd_fcst_load_detail.fcst_gsv_03 := rcd_fcst_text40_detail.fcst_gsv03;
            rcd_fcst_load_detail.fcst_gsv_04 := rcd_fcst_text40_detail.fcst_gsv04;
            rcd_fcst_load_detail.fcst_gsv_05 := rcd_fcst_text40_detail.fcst_gsv05;
            rcd_fcst_load_detail.fcst_gsv_06 := rcd_fcst_text40_detail.fcst_gsv06;
            rcd_fcst_load_detail.fcst_gsv_07 := rcd_fcst_text40_detail.fcst_gsv07;
            rcd_fcst_load_detail.fcst_gsv_08 := rcd_fcst_text40_detail.fcst_gsv08;
            rcd_fcst_load_detail.fcst_gsv_09 := rcd_fcst_text40_detail.fcst_gsv09;
            rcd_fcst_load_detail.fcst_gsv_10 := rcd_fcst_text40_detail.fcst_gsv10;
            rcd_fcst_load_detail.fcst_gsv_11 := rcd_fcst_text40_detail.fcst_gsv11;
            rcd_fcst_load_detail.fcst_gsv_12 := rcd_fcst_text40_detail.fcst_gsv12;
            rcd_fcst_load_detail.fcst_gsv_13 := rcd_fcst_text40_detail.fcst_gsv13;

            /*-*/
            /* Insert the forecast load detail
            /*-*/
            insert into fcst_load_detail
               (load_identifier,
                sap_material_code,
                fcst_qty_01,
                fcst_qty_02,
                fcst_qty_03,
                fcst_qty_04,
                fcst_qty_05,
                fcst_qty_06,
                fcst_qty_07,
                fcst_qty_08,
                fcst_qty_09,
                fcst_qty_10,
                fcst_qty_11,
                fcst_qty_12,
                fcst_qty_13,
                fcst_prc_01,
                fcst_prc_02,
                fcst_prc_03,
                fcst_prc_04,
                fcst_prc_05,
                fcst_prc_06,
                fcst_prc_07,
                fcst_prc_08,
                fcst_prc_09,
                fcst_prc_10,
                fcst_prc_11,
                fcst_prc_12,
                fcst_prc_13,
                fcst_dis_01,
                fcst_dis_02,
                fcst_dis_03,
                fcst_dis_04,
                fcst_dis_05,
                fcst_dis_06,
                fcst_dis_07,
                fcst_dis_08,
                fcst_dis_09,
                fcst_dis_10,
                fcst_dis_11,
                fcst_dis_12,
                fcst_dis_13,
                fcst_vol_01,
                fcst_vol_02,
                fcst_vol_03,
                fcst_vol_04,
                fcst_vol_05,
                fcst_vol_06,
                fcst_vol_07,
                fcst_vol_08,
                fcst_vol_09,
                fcst_vol_10,
                fcst_vol_11,
                fcst_vol_12,
                fcst_vol_13,
                fcst_bps_01,
                fcst_bps_02,
                fcst_bps_03,
                fcst_bps_04,
                fcst_bps_05,
                fcst_bps_06,
                fcst_bps_07,
                fcst_bps_08,
                fcst_bps_09,
                fcst_bps_10,
                fcst_bps_11,
                fcst_bps_12,
                fcst_bps_13,
                fcst_gsv_01,
                fcst_gsv_02,
                fcst_gsv_03,
                fcst_gsv_04,
                fcst_gsv_05,
                fcst_gsv_06,
                fcst_gsv_07,
                fcst_gsv_08,
                fcst_gsv_09,
                fcst_gsv_10,
                fcst_gsv_11,
                fcst_gsv_12,
                fcst_gsv_13,
                err_message)
               values (rcd_fcst_load_detail.load_identifier,
                       rcd_fcst_load_detail.sap_material_code,
                       rcd_fcst_load_detail.fcst_qty_01,
                       rcd_fcst_load_detail.fcst_qty_02,
                       rcd_fcst_load_detail.fcst_qty_03,
                       rcd_fcst_load_detail.fcst_qty_04,
                       rcd_fcst_load_detail.fcst_qty_05,
                       rcd_fcst_load_detail.fcst_qty_06,
                       rcd_fcst_load_detail.fcst_qty_07,
                       rcd_fcst_load_detail.fcst_qty_08,
                       rcd_fcst_load_detail.fcst_qty_09,
                       rcd_fcst_load_detail.fcst_qty_10,
                       rcd_fcst_load_detail.fcst_qty_11,
                       rcd_fcst_load_detail.fcst_qty_12,
                       rcd_fcst_load_detail.fcst_qty_13,
                       rcd_fcst_load_detail.fcst_prc_01,
                       rcd_fcst_load_detail.fcst_prc_02,
                       rcd_fcst_load_detail.fcst_prc_03,
                       rcd_fcst_load_detail.fcst_prc_04,
                       rcd_fcst_load_detail.fcst_prc_05,
                       rcd_fcst_load_detail.fcst_prc_06,
                       rcd_fcst_load_detail.fcst_prc_07,
                       rcd_fcst_load_detail.fcst_prc_08,
                       rcd_fcst_load_detail.fcst_prc_09,
                       rcd_fcst_load_detail.fcst_prc_10,
                       rcd_fcst_load_detail.fcst_prc_11,
                       rcd_fcst_load_detail.fcst_prc_12,
                       rcd_fcst_load_detail.fcst_prc_13,
                       rcd_fcst_load_detail.fcst_dis_01,
                       rcd_fcst_load_detail.fcst_dis_02,
                       rcd_fcst_load_detail.fcst_dis_03,
                       rcd_fcst_load_detail.fcst_dis_04,
                       rcd_fcst_load_detail.fcst_dis_05,
                       rcd_fcst_load_detail.fcst_dis_06,
                       rcd_fcst_load_detail.fcst_dis_07,
                       rcd_fcst_load_detail.fcst_dis_08,
                       rcd_fcst_load_detail.fcst_dis_09,
                       rcd_fcst_load_detail.fcst_dis_10,
                       rcd_fcst_load_detail.fcst_dis_11,
                       rcd_fcst_load_detail.fcst_dis_12,
                       rcd_fcst_load_detail.fcst_dis_13,
                       rcd_fcst_load_detail.fcst_vol_01,
                       rcd_fcst_load_detail.fcst_vol_02,
                       rcd_fcst_load_detail.fcst_vol_03,
                       rcd_fcst_load_detail.fcst_vol_04,
                       rcd_fcst_load_detail.fcst_vol_05,
                       rcd_fcst_load_detail.fcst_vol_06,
                       rcd_fcst_load_detail.fcst_vol_07,
                       rcd_fcst_load_detail.fcst_vol_08,
                       rcd_fcst_load_detail.fcst_vol_09,
                       rcd_fcst_load_detail.fcst_vol_10,
                       rcd_fcst_load_detail.fcst_vol_11,
                       rcd_fcst_load_detail.fcst_vol_12,
                       rcd_fcst_load_detail.fcst_vol_13,
                       rcd_fcst_load_detail.fcst_bps_01,
                       rcd_fcst_load_detail.fcst_bps_02,
                       rcd_fcst_load_detail.fcst_bps_03,
                       rcd_fcst_load_detail.fcst_bps_04,
                       rcd_fcst_load_detail.fcst_bps_05,
                       rcd_fcst_load_detail.fcst_bps_06,
                       rcd_fcst_load_detail.fcst_bps_07,
                       rcd_fcst_load_detail.fcst_bps_08,
                       rcd_fcst_load_detail.fcst_bps_09,
                       rcd_fcst_load_detail.fcst_bps_10,
                       rcd_fcst_load_detail.fcst_bps_11,
                       rcd_fcst_load_detail.fcst_bps_12,
                       rcd_fcst_load_detail.fcst_bps_13,
                       rcd_fcst_load_detail.fcst_gsv_01,
                       rcd_fcst_load_detail.fcst_gsv_02,
                       rcd_fcst_load_detail.fcst_gsv_03,
                       rcd_fcst_load_detail.fcst_gsv_04,
                       rcd_fcst_load_detail.fcst_gsv_05,
                       rcd_fcst_load_detail.fcst_gsv_06,
                       rcd_fcst_load_detail.fcst_gsv_07,
                       rcd_fcst_load_detail.fcst_gsv_08,
                       rcd_fcst_load_detail.fcst_gsv_09,
                       rcd_fcst_load_detail.fcst_gsv_10,
                       rcd_fcst_load_detail.fcst_gsv_11,
                       rcd_fcst_load_detail.fcst_gsv_12,
                       rcd_fcst_load_detail.fcst_gsv_13,
                       rcd_fcst_load_detail.err_message);

         end loop;
         close csr_fcst_text40_detail;

      end if;

      /*-*/
      /* Validate the forecast load
      /*-*/
      rcd_fcst_load_header.load_status := validate_load(rcd_fcst_load_header.load_identifier);

      /*-*/
      /* Update the forecast load header status
      /*-*/
      update fcst_load_header
         set load_status = rcd_fcst_load_header.load_status
       where load_identifier = rcd_fcst_load_header.load_identifier;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_period_load;

   /**********************************************************/
   /* This procedure performs the update period load routine */
   /**********************************************************/
   procedure update_period_load(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_user fcst_load_header.crt_user%type;
      var_identifier fcst_load_header.load_identifier%type;
      var_material_code fcst_load_detail.sap_material_code%type;
      var_available boolean;
      var_qty boolean;
      var_prc boolean;
      var_bps boolean;
      var_dis boolean;
      var_vol boolean;
      var_gsv boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_header is 
         select *
           from fcst_load_header t01
          where t01.load_identifier = var_identifier
            for update nowait;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

      cursor csr_fcst_load_detail is
         select *
           from fcst_load_detail t01
          where t01.load_identifier = rcd_fcst_load_header.load_identifier
            and t01.sap_material_code = var_material_code;
      rcd_fcst_load_detail csr_fcst_load_detail%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_user := upper(par_user);
      if var_user is null then
         var_user := user;
      end if;

      /*-*/
      /* Spreadsheet validation
      /*-*/
      if lics_spreadsheet.read_sheet_count = 0 then
         raise_application_error(-20000, 'No spreadsheet data to update');
      end if;
      if lics_spreadsheet.read_sheet_count > 1 then
         raise_application_error(-20000, 'Only one spreadsheet can be updated at one time');
      end if;

      /*-*/
      /* Retrieve the sheet data
      /*-*/
      for sidx in 1..lics_spreadsheet.read_sheet_count loop

         /*-*/
         /* Retrieve the load identifier
         /*-*/
         var_identifier := lics_spreadsheet.read_sheet_identifier(sidx);

         /*-*/
         /* Attempt to lock the forecast header row
         /* notes - must still exist
         /*         must not be locked
         /*-*/
         var_available := true;
         begin
            open csr_fcst_load_header;
            fetch csr_fcst_load_header into rcd_fcst_load_header;
            if csr_fcst_load_header%notfound then
               var_available := false;
            end if;
         exception
            when others then
               var_available := false;
         end;
         if csr_fcst_load_header%isopen then
            close csr_fcst_load_header;
         end if;

         /*-*/
         /* Release the header lock when not available
         /* 1. Cursor row locks are not released until commit or rollback
         /* 2. Cursor close does not release row locks
         /*-*/
         if var_available = false then
            raise_application_error(-20000, 'Forecast load (' || var_identifier || ') does not exist or is already locked');
         end if;

         /*-*/
         /* Reset the data type indicators
         /*-*/
         var_qty := true;
         var_prc := true;
         var_bps := true;
         var_dis := true;
         var_vol := true;
         var_gsv := true;

         /*-*/
         /* Retrieve the sheet rows
         /*-*/
         for ridx in 1..lics_spreadsheet.read_row_count(sidx) loop

            /*-*/
            /* Sheet row must have 18 columns
            /*-*/
            if lics_spreadsheet.read_cell_count(sidx,ridx) != 18 then
               raise_application_error(-20000, 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') row (' || ridx || ') does not have 18 columns');
            end if;

            /*-*/
            /* Process the forecast data type
            /*-*/
            case lics_spreadsheet.read_cell_string(sidx,ridx,3)

               /*-*/
               /* Forecast data type - QTY
               /*-*/
               when 'QTY' then

                  /*-*/
                  /* Spreadsheet format must conform
                  /*-*/
                  if var_qty != true or
                     var_prc != true or
                     var_bps != true or
                     var_dis != true or
                     var_vol != true or
                     var_gsv != true then
                     raise_application_error(-20000, 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') row (' || ridx || ') data sequence error (QTY)');
                  end if;

                  /*-*/
                  /* Reset the data type indicators
                  /*-*/
                  if rcd_fcst_load_header.fcst_source != '*TXV' then
                     var_qty := true;
                     var_prc := false;
                     var_bps := false;
                     var_dis := false;
                     var_vol := false;
                     var_gsv := false;
                  else
                     var_qty := true;
                     var_prc := true;
                     var_bps := false;
                     var_dis := false;
                     var_vol := false;
                     var_gsv := false;
                  end if;

                  /*-*/
                  /* Forecast load detail row must exist
                  /*-*/
                  var_material_code := lics_spreadsheet.read_cell_string(sidx,ridx,1);
                  open csr_fcst_load_detail;
                  fetch csr_fcst_load_detail into rcd_fcst_load_detail;
                  if csr_fcst_load_detail%notfound then
                     raise_application_error(-20000, 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') material (' || var_material_code || ') does not exist');
                  end if;
                  close csr_fcst_load_detail;

                  /*-*/
                  /* Set the new quantity values
                  /*-*/
                  rcd_fcst_load_detail.fcst_qty_01 := lics_spreadsheet.read_cell_number(sidx,ridx,4);
                  rcd_fcst_load_detail.fcst_qty_02 := lics_spreadsheet.read_cell_number(sidx,ridx,5);
                  rcd_fcst_load_detail.fcst_qty_03 := lics_spreadsheet.read_cell_number(sidx,ridx,6);
                  rcd_fcst_load_detail.fcst_qty_04 := lics_spreadsheet.read_cell_number(sidx,ridx,7);
                  rcd_fcst_load_detail.fcst_qty_05 := lics_spreadsheet.read_cell_number(sidx,ridx,8);
                  rcd_fcst_load_detail.fcst_qty_06 := lics_spreadsheet.read_cell_number(sidx,ridx,9);
                  rcd_fcst_load_detail.fcst_qty_07 := lics_spreadsheet.read_cell_number(sidx,ridx,10);
                  rcd_fcst_load_detail.fcst_qty_08 := lics_spreadsheet.read_cell_number(sidx,ridx,11);
                  rcd_fcst_load_detail.fcst_qty_09 := lics_spreadsheet.read_cell_number(sidx,ridx,12);
                  rcd_fcst_load_detail.fcst_qty_10 := lics_spreadsheet.read_cell_number(sidx,ridx,13);
                  rcd_fcst_load_detail.fcst_qty_11 := lics_spreadsheet.read_cell_number(sidx,ridx,14);
                  rcd_fcst_load_detail.fcst_qty_12 := lics_spreadsheet.read_cell_number(sidx,ridx,15);
                  rcd_fcst_load_detail.fcst_qty_13 := lics_spreadsheet.read_cell_number(sidx,ridx,16);

               /*-*/
               /* Forecast data type - PRC
               /*-*/
               when 'PRC' then

                  /*-*/
                  /* Value text file does not allow PRC
                  /*-*/
                  if rcd_fcst_load_header.fcst_source = '*TXV' then
                     raise_application_error(-20000, 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') row (' || ridx || ') data error (PRC) - not allowed');
                  end if;

                  /*-*/
                  /* Spreadsheet format must conform
                  /*-*/
                  if var_qty != true or
                     var_prc != false or
                     var_bps != false or
                     var_dis != false or
                     var_vol != false or
                     var_gsv != false then
                     raise_application_error(-20000, 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') row (' || ridx || ') data sequence error (PRC)');
                  end if;

                  /*-*/
                  /* Set the data type indicator
                  /*-*/
                  var_prc := true;

                  /*-*/
                  /* Set the new price values
                  /*-*/
                  rcd_fcst_load_detail.fcst_prc_01 := lics_spreadsheet.read_cell_number(sidx,ridx,4);
                  rcd_fcst_load_detail.fcst_prc_02 := lics_spreadsheet.read_cell_number(sidx,ridx,5);
                  rcd_fcst_load_detail.fcst_prc_03 := lics_spreadsheet.read_cell_number(sidx,ridx,6);
                  rcd_fcst_load_detail.fcst_prc_04 := lics_spreadsheet.read_cell_number(sidx,ridx,7);
                  rcd_fcst_load_detail.fcst_prc_05 := lics_spreadsheet.read_cell_number(sidx,ridx,8);
                  rcd_fcst_load_detail.fcst_prc_06 := lics_spreadsheet.read_cell_number(sidx,ridx,9);
                  rcd_fcst_load_detail.fcst_prc_07 := lics_spreadsheet.read_cell_number(sidx,ridx,10);
                  rcd_fcst_load_detail.fcst_prc_08 := lics_spreadsheet.read_cell_number(sidx,ridx,11);
                  rcd_fcst_load_detail.fcst_prc_09 := lics_spreadsheet.read_cell_number(sidx,ridx,12);
                  rcd_fcst_load_detail.fcst_prc_10 := lics_spreadsheet.read_cell_number(sidx,ridx,13);
                  rcd_fcst_load_detail.fcst_prc_11 := lics_spreadsheet.read_cell_number(sidx,ridx,14);
                  rcd_fcst_load_detail.fcst_prc_12 := lics_spreadsheet.read_cell_number(sidx,ridx,15);
                  rcd_fcst_load_detail.fcst_prc_13 := lics_spreadsheet.read_cell_number(sidx,ridx,16);

               /*-*/
               /* Forecast data type - BPS
               /*-*/
               when 'BPS' then

                  /*-*/
                  /* Spreadsheet format must conform
                  /*-*/
                  if var_qty != true or
                     var_prc != true or
                     var_bps != false or
                     var_dis != false or
                     var_vol != false or
                     var_gsv != false then
                     raise_application_error(-20000, 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') row (' || ridx || ') data sequence error (BPS)');
                  end if;

                  /*-*/
                  /* Set the data type indicator
                  /*-*/
                  var_bps := true;
                  if rcd_fcst_load_header.fcst_source = '*TXV' then
                     var_dis := true;
                     var_vol := true;
                  end if;

                  /*-*/
                  /* Set the new BPS values
                  /*-*/
                  if rcd_fcst_load_header.fcst_source != '*TXV' then
                     rcd_fcst_load_detail.fcst_bps_01 := rcd_fcst_load_detail.fcst_qty_01*rcd_fcst_load_detail.fcst_prc_01;
                     rcd_fcst_load_detail.fcst_bps_02 := rcd_fcst_load_detail.fcst_qty_02*rcd_fcst_load_detail.fcst_prc_02;
                     rcd_fcst_load_detail.fcst_bps_03 := rcd_fcst_load_detail.fcst_qty_03*rcd_fcst_load_detail.fcst_prc_03;
                     rcd_fcst_load_detail.fcst_bps_04 := rcd_fcst_load_detail.fcst_qty_04*rcd_fcst_load_detail.fcst_prc_04;
                     rcd_fcst_load_detail.fcst_bps_05 := rcd_fcst_load_detail.fcst_qty_05*rcd_fcst_load_detail.fcst_prc_05;
                     rcd_fcst_load_detail.fcst_bps_06 := rcd_fcst_load_detail.fcst_qty_06*rcd_fcst_load_detail.fcst_prc_06;
                     rcd_fcst_load_detail.fcst_bps_07 := rcd_fcst_load_detail.fcst_qty_07*rcd_fcst_load_detail.fcst_prc_07;
                     rcd_fcst_load_detail.fcst_bps_08 := rcd_fcst_load_detail.fcst_qty_08*rcd_fcst_load_detail.fcst_prc_08;
                     rcd_fcst_load_detail.fcst_bps_09 := rcd_fcst_load_detail.fcst_qty_09*rcd_fcst_load_detail.fcst_prc_09;
                     rcd_fcst_load_detail.fcst_bps_10 := rcd_fcst_load_detail.fcst_qty_10*rcd_fcst_load_detail.fcst_prc_10;
                     rcd_fcst_load_detail.fcst_bps_11 := rcd_fcst_load_detail.fcst_qty_11*rcd_fcst_load_detail.fcst_prc_11;
                     rcd_fcst_load_detail.fcst_bps_12 := rcd_fcst_load_detail.fcst_qty_12*rcd_fcst_load_detail.fcst_prc_12;
                     rcd_fcst_load_detail.fcst_bps_13 := rcd_fcst_load_detail.fcst_qty_13*rcd_fcst_load_detail.fcst_prc_13;
                  else
                     rcd_fcst_load_detail.fcst_bps_01 := lics_spreadsheet.read_cell_number(sidx,ridx,4);
                     rcd_fcst_load_detail.fcst_bps_02 := lics_spreadsheet.read_cell_number(sidx,ridx,5);
                     rcd_fcst_load_detail.fcst_bps_03 := lics_spreadsheet.read_cell_number(sidx,ridx,6);
                     rcd_fcst_load_detail.fcst_bps_04 := lics_spreadsheet.read_cell_number(sidx,ridx,7);
                     rcd_fcst_load_detail.fcst_bps_05 := lics_spreadsheet.read_cell_number(sidx,ridx,8);
                     rcd_fcst_load_detail.fcst_bps_06 := lics_spreadsheet.read_cell_number(sidx,ridx,9);
                     rcd_fcst_load_detail.fcst_bps_07 := lics_spreadsheet.read_cell_number(sidx,ridx,10);
                     rcd_fcst_load_detail.fcst_bps_08 := lics_spreadsheet.read_cell_number(sidx,ridx,11);
                     rcd_fcst_load_detail.fcst_bps_09 := lics_spreadsheet.read_cell_number(sidx,ridx,12);
                     rcd_fcst_load_detail.fcst_bps_10 := lics_spreadsheet.read_cell_number(sidx,ridx,13);
                     rcd_fcst_load_detail.fcst_bps_11 := lics_spreadsheet.read_cell_number(sidx,ridx,14);
                     rcd_fcst_load_detail.fcst_bps_12 := lics_spreadsheet.read_cell_number(sidx,ridx,15);
                     rcd_fcst_load_detail.fcst_bps_13 := lics_spreadsheet.read_cell_number(sidx,ridx,16);
                  end if;

               /*-*/
               /* Forecast data type - DIS
               /*-*/
               when 'DIS' then

                  /*-*/
                  /* Value text file does not allow DIS
                  /*-*/
                  if rcd_fcst_load_header.fcst_source = '*TXV' then
                     raise_application_error(-20000, 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') row (' || ridx || ') data error (DIS) - not allowed');
                  end if;

                  /*-*/
                  /* Spreadsheet format must conform
                  /*-*/
                  if var_qty != true or
                     var_prc != true or
                     var_bps != true or
                     var_dis != false or
                     var_vol != false or
                     var_gsv != false then
                     raise_application_error(-20000, 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') row (' || ridx || ') data sequence error (DIS)');
                  end if;

                  /*-*/
                  /* Set the data type indicator
                  /*-*/
                  var_dis := true;

                  /*-*/
                  /* Set the new general discount values
                  /*-*/
                  rcd_fcst_load_detail.fcst_dis_01 := lics_spreadsheet.read_cell_number(sidx,ridx,4);
                  rcd_fcst_load_detail.fcst_dis_02 := lics_spreadsheet.read_cell_number(sidx,ridx,5);
                  rcd_fcst_load_detail.fcst_dis_03 := lics_spreadsheet.read_cell_number(sidx,ridx,6);
                  rcd_fcst_load_detail.fcst_dis_04 := lics_spreadsheet.read_cell_number(sidx,ridx,7);
                  rcd_fcst_load_detail.fcst_dis_05 := lics_spreadsheet.read_cell_number(sidx,ridx,8);
                  rcd_fcst_load_detail.fcst_dis_06 := lics_spreadsheet.read_cell_number(sidx,ridx,9);
                  rcd_fcst_load_detail.fcst_dis_07 := lics_spreadsheet.read_cell_number(sidx,ridx,10);
                  rcd_fcst_load_detail.fcst_dis_08 := lics_spreadsheet.read_cell_number(sidx,ridx,11);
                  rcd_fcst_load_detail.fcst_dis_09 := lics_spreadsheet.read_cell_number(sidx,ridx,12);
                  rcd_fcst_load_detail.fcst_dis_10 := lics_spreadsheet.read_cell_number(sidx,ridx,13);
                  rcd_fcst_load_detail.fcst_dis_11 := lics_spreadsheet.read_cell_number(sidx,ridx,14);
                  rcd_fcst_load_detail.fcst_dis_12 := lics_spreadsheet.read_cell_number(sidx,ridx,15);
                  rcd_fcst_load_detail.fcst_dis_13 := lics_spreadsheet.read_cell_number(sidx,ridx,16);

               /*-*/
               /* Forecast data type - VOL
               /*-*/
               when 'VOL' then

                  /*-*/
                  /* Value text file does not allow VOL
                  /*-*/
                  if rcd_fcst_load_header.fcst_source = '*TXV' then
                     raise_application_error(-20000, 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') row (' || ridx || ') data error (VOL) - not allowed');
                  end if;

                  /*-*/
                  /* Spreadsheet format must conform
                  /*-*/
                  if var_qty != true or
                     var_prc != true or
                     var_bps != true or
                     var_dis != true or
                     var_vol != false or
                     var_gsv != false then
                     raise_application_error(-20000, 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') row (' || ridx || ') data sequence error (VOL)');
                  end if;

                  /*-*/
                  /* Set the data type indicator
                  /*-*/
                  var_vol := true;

                  /*-*/
                  /* Set the new volume discount values
                  /*-*/
                  rcd_fcst_load_detail.fcst_vol_01 := lics_spreadsheet.read_cell_number(sidx,ridx,4);
                  rcd_fcst_load_detail.fcst_vol_02 := lics_spreadsheet.read_cell_number(sidx,ridx,5);
                  rcd_fcst_load_detail.fcst_vol_03 := lics_spreadsheet.read_cell_number(sidx,ridx,6);
                  rcd_fcst_load_detail.fcst_vol_04 := lics_spreadsheet.read_cell_number(sidx,ridx,7);
                  rcd_fcst_load_detail.fcst_vol_05 := lics_spreadsheet.read_cell_number(sidx,ridx,8);
                  rcd_fcst_load_detail.fcst_vol_06 := lics_spreadsheet.read_cell_number(sidx,ridx,9);
                  rcd_fcst_load_detail.fcst_vol_07 := lics_spreadsheet.read_cell_number(sidx,ridx,10);
                  rcd_fcst_load_detail.fcst_vol_08 := lics_spreadsheet.read_cell_number(sidx,ridx,11);
                  rcd_fcst_load_detail.fcst_vol_09 := lics_spreadsheet.read_cell_number(sidx,ridx,12);
                  rcd_fcst_load_detail.fcst_vol_10 := lics_spreadsheet.read_cell_number(sidx,ridx,13);
                  rcd_fcst_load_detail.fcst_vol_11 := lics_spreadsheet.read_cell_number(sidx,ridx,14);
                  rcd_fcst_load_detail.fcst_vol_12 := lics_spreadsheet.read_cell_number(sidx,ridx,15);
                  rcd_fcst_load_detail.fcst_vol_13 := lics_spreadsheet.read_cell_number(sidx,ridx,16);

               /*-*/
               /* Forecast data type - GSV
               /*-*/
               when 'GSV' then

                  /*-*/
                  /* Spreadsheet format must conform
                  /*-*/
                  if var_qty != true or
                     var_prc != true or
                     var_bps != true or
                     var_dis != true or
                     var_vol != true or
                     var_gsv != false then
                     raise_application_error(-20000, 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') row (' || ridx || ') data sequence error (GSV)');
                  end if;

                  /*-*/
                  /* Set the data type indicator
                  /*-*/
                  var_gsv := true;

                  /*-*/
                  /* Set the new GSV values
                  /*-*/
                  if rcd_fcst_load_header.fcst_source != '*TXV' then
                     rcd_fcst_load_detail.fcst_gsv_01 := rcd_fcst_load_detail.fcst_qty_01*round((rcd_fcst_load_detail.fcst_prc_01+rcd_fcst_load_detail.fcst_dis_01)-((rcd_fcst_load_detail.fcst_prc_01+rcd_fcst_load_detail.fcst_dis_01)*rcd_fcst_load_detail.fcst_vol_01),0);
                     rcd_fcst_load_detail.fcst_gsv_02 := rcd_fcst_load_detail.fcst_qty_02*round((rcd_fcst_load_detail.fcst_prc_02+rcd_fcst_load_detail.fcst_dis_02)-((rcd_fcst_load_detail.fcst_prc_02+rcd_fcst_load_detail.fcst_dis_02)*rcd_fcst_load_detail.fcst_vol_02),0);
                     rcd_fcst_load_detail.fcst_gsv_03 := rcd_fcst_load_detail.fcst_qty_03*round((rcd_fcst_load_detail.fcst_prc_03+rcd_fcst_load_detail.fcst_dis_03)-((rcd_fcst_load_detail.fcst_prc_03+rcd_fcst_load_detail.fcst_dis_03)*rcd_fcst_load_detail.fcst_vol_03),0);
                     rcd_fcst_load_detail.fcst_gsv_04 := rcd_fcst_load_detail.fcst_qty_04*round((rcd_fcst_load_detail.fcst_prc_04+rcd_fcst_load_detail.fcst_dis_04)-((rcd_fcst_load_detail.fcst_prc_04+rcd_fcst_load_detail.fcst_dis_04)*rcd_fcst_load_detail.fcst_vol_04),0);
                     rcd_fcst_load_detail.fcst_gsv_05 := rcd_fcst_load_detail.fcst_qty_05*round((rcd_fcst_load_detail.fcst_prc_05+rcd_fcst_load_detail.fcst_dis_05)-((rcd_fcst_load_detail.fcst_prc_05+rcd_fcst_load_detail.fcst_dis_05)*rcd_fcst_load_detail.fcst_vol_05),0);
                     rcd_fcst_load_detail.fcst_gsv_06 := rcd_fcst_load_detail.fcst_qty_06*round((rcd_fcst_load_detail.fcst_prc_06+rcd_fcst_load_detail.fcst_dis_06)-((rcd_fcst_load_detail.fcst_prc_06+rcd_fcst_load_detail.fcst_dis_06)*rcd_fcst_load_detail.fcst_vol_06),0);
                     rcd_fcst_load_detail.fcst_gsv_07 := rcd_fcst_load_detail.fcst_qty_07*round((rcd_fcst_load_detail.fcst_prc_07+rcd_fcst_load_detail.fcst_dis_07)-((rcd_fcst_load_detail.fcst_prc_07+rcd_fcst_load_detail.fcst_dis_07)*rcd_fcst_load_detail.fcst_vol_07),0);
                     rcd_fcst_load_detail.fcst_gsv_08 := rcd_fcst_load_detail.fcst_qty_08*round((rcd_fcst_load_detail.fcst_prc_08+rcd_fcst_load_detail.fcst_dis_08)-((rcd_fcst_load_detail.fcst_prc_08+rcd_fcst_load_detail.fcst_dis_08)*rcd_fcst_load_detail.fcst_vol_08),0);
                     rcd_fcst_load_detail.fcst_gsv_09 := rcd_fcst_load_detail.fcst_qty_09*round((rcd_fcst_load_detail.fcst_prc_09+rcd_fcst_load_detail.fcst_dis_09)-((rcd_fcst_load_detail.fcst_prc_09+rcd_fcst_load_detail.fcst_dis_09)*rcd_fcst_load_detail.fcst_vol_09),0);
                     rcd_fcst_load_detail.fcst_gsv_10 := rcd_fcst_load_detail.fcst_qty_10*round((rcd_fcst_load_detail.fcst_prc_10+rcd_fcst_load_detail.fcst_dis_10)-((rcd_fcst_load_detail.fcst_prc_10+rcd_fcst_load_detail.fcst_dis_10)*rcd_fcst_load_detail.fcst_vol_10),0);
                     rcd_fcst_load_detail.fcst_gsv_11 := rcd_fcst_load_detail.fcst_qty_11*round((rcd_fcst_load_detail.fcst_prc_11+rcd_fcst_load_detail.fcst_dis_11)-((rcd_fcst_load_detail.fcst_prc_11+rcd_fcst_load_detail.fcst_dis_11)*rcd_fcst_load_detail.fcst_vol_11),0);
                     rcd_fcst_load_detail.fcst_gsv_12 := rcd_fcst_load_detail.fcst_qty_12*round((rcd_fcst_load_detail.fcst_prc_12+rcd_fcst_load_detail.fcst_dis_12)-((rcd_fcst_load_detail.fcst_prc_12+rcd_fcst_load_detail.fcst_dis_12)*rcd_fcst_load_detail.fcst_vol_12),0);
                     rcd_fcst_load_detail.fcst_gsv_13 := rcd_fcst_load_detail.fcst_qty_13*round((rcd_fcst_load_detail.fcst_prc_13+rcd_fcst_load_detail.fcst_dis_13)-((rcd_fcst_load_detail.fcst_prc_13+rcd_fcst_load_detail.fcst_dis_13)*rcd_fcst_load_detail.fcst_vol_13),0);
                  else
                     rcd_fcst_load_detail.fcst_gsv_01 := lics_spreadsheet.read_cell_number(sidx,ridx,4);
                     rcd_fcst_load_detail.fcst_gsv_02 := lics_spreadsheet.read_cell_number(sidx,ridx,5);
                     rcd_fcst_load_detail.fcst_gsv_03 := lics_spreadsheet.read_cell_number(sidx,ridx,6);
                     rcd_fcst_load_detail.fcst_gsv_04 := lics_spreadsheet.read_cell_number(sidx,ridx,7);
                     rcd_fcst_load_detail.fcst_gsv_05 := lics_spreadsheet.read_cell_number(sidx,ridx,8);
                     rcd_fcst_load_detail.fcst_gsv_06 := lics_spreadsheet.read_cell_number(sidx,ridx,9);
                     rcd_fcst_load_detail.fcst_gsv_07 := lics_spreadsheet.read_cell_number(sidx,ridx,10);
                     rcd_fcst_load_detail.fcst_gsv_08 := lics_spreadsheet.read_cell_number(sidx,ridx,11);
                     rcd_fcst_load_detail.fcst_gsv_09 := lics_spreadsheet.read_cell_number(sidx,ridx,12);
                     rcd_fcst_load_detail.fcst_gsv_10 := lics_spreadsheet.read_cell_number(sidx,ridx,13);
                     rcd_fcst_load_detail.fcst_gsv_11 := lics_spreadsheet.read_cell_number(sidx,ridx,14);
                     rcd_fcst_load_detail.fcst_gsv_12 := lics_spreadsheet.read_cell_number(sidx,ridx,15);
                     rcd_fcst_load_detail.fcst_gsv_13 := lics_spreadsheet.read_cell_number(sidx,ridx,16);
                  end if;

                  /*-*/
                  /* Delete/update the forecast load detail row as required
                  /*-*/
                  if rcd_fcst_load_detail.fcst_qty_01 = 0 and
                     rcd_fcst_load_detail.fcst_qty_02 = 0 and
                     rcd_fcst_load_detail.fcst_qty_03 = 0 and
                     rcd_fcst_load_detail.fcst_qty_04 = 0 and
                     rcd_fcst_load_detail.fcst_qty_05 = 0 and
                     rcd_fcst_load_detail.fcst_qty_06 = 0 and
                     rcd_fcst_load_detail.fcst_qty_07 = 0 and
                     rcd_fcst_load_detail.fcst_qty_08 = 0 and
                     rcd_fcst_load_detail.fcst_qty_09 = 0 and
                     rcd_fcst_load_detail.fcst_qty_10 = 0 and
                     rcd_fcst_load_detail.fcst_qty_11 = 0 and
                     rcd_fcst_load_detail.fcst_qty_12 = 0 and
                     rcd_fcst_load_detail.fcst_qty_13 = 0 then
                     delete from fcst_load_detail
                      where load_identifier = rcd_fcst_load_detail.load_identifier
                        and sap_material_code = rcd_fcst_load_detail.sap_material_code;
                  else
                     update fcst_load_detail
                        set fcst_qty_01 = rcd_fcst_load_detail.fcst_qty_01,
                            fcst_qty_02 = rcd_fcst_load_detail.fcst_qty_02,
                            fcst_qty_03 = rcd_fcst_load_detail.fcst_qty_03,
                            fcst_qty_04 = rcd_fcst_load_detail.fcst_qty_04,
                            fcst_qty_05 = rcd_fcst_load_detail.fcst_qty_05,
                            fcst_qty_06 = rcd_fcst_load_detail.fcst_qty_06,
                            fcst_qty_07 = rcd_fcst_load_detail.fcst_qty_07,
                            fcst_qty_08 = rcd_fcst_load_detail.fcst_qty_08,
                            fcst_qty_09 = rcd_fcst_load_detail.fcst_qty_09,
                            fcst_qty_10 = rcd_fcst_load_detail.fcst_qty_10,
                            fcst_qty_11 = rcd_fcst_load_detail.fcst_qty_11,
                            fcst_qty_12 = rcd_fcst_load_detail.fcst_qty_12,
                            fcst_qty_13 = rcd_fcst_load_detail.fcst_qty_13,
                            fcst_prc_01 = rcd_fcst_load_detail.fcst_prc_01,
                            fcst_prc_02 = rcd_fcst_load_detail.fcst_prc_02,
                            fcst_prc_03 = rcd_fcst_load_detail.fcst_prc_03,
                            fcst_prc_04 = rcd_fcst_load_detail.fcst_prc_04,
                            fcst_prc_05 = rcd_fcst_load_detail.fcst_prc_05,
                            fcst_prc_06 = rcd_fcst_load_detail.fcst_prc_06,
                            fcst_prc_07 = rcd_fcst_load_detail.fcst_prc_07,
                            fcst_prc_08 = rcd_fcst_load_detail.fcst_prc_08,
                            fcst_prc_09 = rcd_fcst_load_detail.fcst_prc_09,
                            fcst_prc_10 = rcd_fcst_load_detail.fcst_prc_10,
                            fcst_prc_11 = rcd_fcst_load_detail.fcst_prc_11,
                            fcst_prc_12 = rcd_fcst_load_detail.fcst_prc_12,
                            fcst_prc_13 = rcd_fcst_load_detail.fcst_prc_13,
                            fcst_dis_01 = rcd_fcst_load_detail.fcst_dis_01,
                            fcst_dis_02 = rcd_fcst_load_detail.fcst_dis_02,
                            fcst_dis_03 = rcd_fcst_load_detail.fcst_dis_03,
                            fcst_dis_04 = rcd_fcst_load_detail.fcst_dis_04,
                            fcst_dis_05 = rcd_fcst_load_detail.fcst_dis_05,
                            fcst_dis_06 = rcd_fcst_load_detail.fcst_dis_06,
                            fcst_dis_07 = rcd_fcst_load_detail.fcst_dis_07,
                            fcst_dis_08 = rcd_fcst_load_detail.fcst_dis_08,
                            fcst_dis_09 = rcd_fcst_load_detail.fcst_dis_09,
                            fcst_dis_10 = rcd_fcst_load_detail.fcst_dis_10,
                            fcst_dis_11 = rcd_fcst_load_detail.fcst_dis_11,
                            fcst_dis_12 = rcd_fcst_load_detail.fcst_dis_12,
                            fcst_dis_13 = rcd_fcst_load_detail.fcst_dis_13,
                            fcst_vol_01 = rcd_fcst_load_detail.fcst_vol_01,
                            fcst_vol_02 = rcd_fcst_load_detail.fcst_vol_02,
                            fcst_vol_03 = rcd_fcst_load_detail.fcst_vol_03,
                            fcst_vol_04 = rcd_fcst_load_detail.fcst_vol_04,
                            fcst_vol_05 = rcd_fcst_load_detail.fcst_vol_05,
                            fcst_vol_06 = rcd_fcst_load_detail.fcst_vol_06,
                            fcst_vol_07 = rcd_fcst_load_detail.fcst_vol_07,
                            fcst_vol_08 = rcd_fcst_load_detail.fcst_vol_08,
                            fcst_vol_09 = rcd_fcst_load_detail.fcst_vol_09,
                            fcst_vol_10 = rcd_fcst_load_detail.fcst_vol_10,
                            fcst_vol_11 = rcd_fcst_load_detail.fcst_vol_11,
                            fcst_vol_12 = rcd_fcst_load_detail.fcst_vol_12,
                            fcst_vol_13 = rcd_fcst_load_detail.fcst_vol_13,
                            fcst_bps_01 = rcd_fcst_load_detail.fcst_bps_01,
                            fcst_bps_02 = rcd_fcst_load_detail.fcst_bps_02,
                            fcst_bps_03 = rcd_fcst_load_detail.fcst_bps_03,
                            fcst_bps_04 = rcd_fcst_load_detail.fcst_bps_04,
                            fcst_bps_05 = rcd_fcst_load_detail.fcst_bps_05,
                            fcst_bps_06 = rcd_fcst_load_detail.fcst_bps_06,
                            fcst_bps_07 = rcd_fcst_load_detail.fcst_bps_07,
                            fcst_bps_08 = rcd_fcst_load_detail.fcst_bps_08,
                            fcst_bps_09 = rcd_fcst_load_detail.fcst_bps_09,
                            fcst_bps_10 = rcd_fcst_load_detail.fcst_bps_10,
                            fcst_bps_11 = rcd_fcst_load_detail.fcst_bps_11,
                            fcst_bps_12 = rcd_fcst_load_detail.fcst_bps_12,
                            fcst_bps_13 = rcd_fcst_load_detail.fcst_bps_13,
                            fcst_gsv_01 = rcd_fcst_load_detail.fcst_gsv_01,
                            fcst_gsv_02 = rcd_fcst_load_detail.fcst_gsv_02,
                            fcst_gsv_03 = rcd_fcst_load_detail.fcst_gsv_03,
                            fcst_gsv_04 = rcd_fcst_load_detail.fcst_gsv_04,
                            fcst_gsv_05 = rcd_fcst_load_detail.fcst_gsv_05,
                            fcst_gsv_06 = rcd_fcst_load_detail.fcst_gsv_06,
                            fcst_gsv_07 = rcd_fcst_load_detail.fcst_gsv_07,
                            fcst_gsv_08 = rcd_fcst_load_detail.fcst_gsv_08,
                            fcst_gsv_09 = rcd_fcst_load_detail.fcst_gsv_09,
                            fcst_gsv_10 = rcd_fcst_load_detail.fcst_gsv_10,
                            fcst_gsv_11 = rcd_fcst_load_detail.fcst_gsv_11,
                            fcst_gsv_12 = rcd_fcst_load_detail.fcst_gsv_12,
                            fcst_gsv_13 = rcd_fcst_load_detail.fcst_gsv_13
                      where load_identifier = rcd_fcst_load_detail.load_identifier
                        and sap_material_code = rcd_fcst_load_detail.sap_material_code;
                  end if;
               else raise_application_error(-20000, 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') row (' || ridx || ') data type (' || lics_spreadsheet.read_cell_string(sidx,ridx,3) || ') not recognised');
            end case;

         end loop;

         /*-*/
         /* Validate the forecast load
         /*-*/
         rcd_fcst_load_header.load_status := validate_load(rcd_fcst_load_header.load_identifier);

         /*-*/
         /* Update the forecast load header
         /*-*/
         update fcst_load_header
            set load_status = rcd_fcst_load_header.load_status,
                upd_user = var_user,
                upd_date = sysdate
          where load_identifier = rcd_fcst_load_header.load_identifier;

      end loop;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_FORECAST_LOADING - UPDATE_PERIOD_LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_period_load;

   /**********************************************************/
   /* This procedure performs the accept period load routine */
   /**********************************************************/
   procedure accept_period_load(par_identifier in varchar2, par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      rcd_fcst_period fcst_period%rowtype;
      var_user fcst_load_header.crt_user%type;
      var_identifier fcst_load_header.load_identifier%type;
      var_fcst_type_code rcd_fcst_period.fcst_type_code%type;
      var_fcst_price_type_code rcd_fcst_period.fcst_price_type_code%type;
      var_available boolean;
      var_yyyynn number;
      var_castnn number;
      type typ_wrkv is table of number index by binary_integer;
      tbl_wrkn typ_wrkv;
      tbl_wrkq typ_wrkv;
      tbl_wrkb typ_wrkv;
      tbl_wrkg typ_wrkv;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_mars_date is
         select *
           from mars_date t01
          where to_char(t01.calendar_date,'yyyymmdd') = to_char(sysdate,'yyyymmdd');
      rcd_mars_date csr_mars_date%rowtype;

      cursor csr_fcst_load_header is 
         select *
           from fcst_load_header t01
          where t01.load_identifier = var_identifier
            for update nowait;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

      cursor csr_fcst_load_detail is
         select *
           from fcst_load_detail t01
          where t01.load_identifier = rcd_fcst_load_header.load_identifier
            and (t01.fcst_qty_01 != 0 or
                 t01.fcst_qty_02 != 0 or
                 t01.fcst_qty_03 != 0 or
                 t01.fcst_qty_04 != 0 or
                 t01.fcst_qty_05 != 0 or
                 t01.fcst_qty_06 != 0 or
                 t01.fcst_qty_07 != 0 or
                 t01.fcst_qty_08 != 0 or
                 t01.fcst_qty_09 != 0 or
                 t01.fcst_qty_10 != 0 or
                 t01.fcst_qty_11 != 0 or
                 t01.fcst_qty_12 != 0 or
                 t01.fcst_qty_13 != 0)
          order by t01.sap_material_code asc;
      rcd_fcst_load_detail csr_fcst_load_detail%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_identifier := upper(par_identifier);
      if var_identifier is null then
         raise_application_error(-20000, 'Forecast load identifier must be specified');
      end if;
      var_user := upper(par_user);
      if var_user is null then
         var_user := user;
      end if;

      /*-*/
      /* Attempt to lock the forecast header row
      /* notes - must still exist
      /*         must not be locked
      /*-*/
      var_available := true;
      begin
         open csr_fcst_load_header;
         fetch csr_fcst_load_header into rcd_fcst_load_header;
         if csr_fcst_load_header%notfound then
            var_available := false;
         end if;
      exception
         when others then
            var_available := false;
      end;
      if csr_fcst_load_header%isopen then
         close csr_fcst_load_header;
      end if;

      /*-*/
      /* Release the header lock when not available
      /* 1. Cursor row locks are not released until commit or rollback
      /* 2. Cursor close does not release row locks
      /*-*/
      if var_available = false then
         raise_application_error(-20000, 'Forecast load (' || var_identifier || ') does not exist or is already locked');
      end if;

      /*-*/
      /* Forecast load must be *VALID
      /*-*/
      if rcd_fcst_load_header.load_status != '*VALID' then
         raise_application_error(-20000, 'Forecast load (' || var_identifier || ') must be *VALID status');
      end if;

      /*-*/
      /* Forecast load must be a period load
      /*-*/
      if rcd_fcst_load_header.fcst_time != '*PRD' then
         raise_application_error(-20000, 'Forecast load (' || var_identifier || ') must be period load');
      end if;

      /*-*/
      /* Forecast load casting period must match CLIO
      /*-*/
      open csr_mars_date;
      fetch csr_mars_date into rcd_mars_date;
      if csr_mars_date%notfound then
         raise_application_error(-20000, 'Mars date (' || to_char(sysdate,'yyyy/mm/dd') || ') does not exist');
      end if;
      close csr_mars_date;
      if rcd_fcst_load_header.fcst_type = '*BR' then
         var_castnn := rcd_mars_date.mars_period - 1;
         if substr(to_char(var_castnn,'fm000000'),5,2) = '00' then
            var_castnn := var_castnn - 87;
         end if;
         if rcd_fcst_load_header.fcst_cast_yyyynn < var_castnn then
            raise_application_error(-20000, ' Business review casting period ('||to_char(rcd_fcst_load_header.fcst_cast_yyyynn)||') must not be less than CLIO previous period ('||to_char(var_castnn)||')');
         end if;
      end if;
      if rcd_fcst_load_header.fcst_type = '*OP1' then
         if rcd_fcst_load_header.fcst_cast_yyyynn != rcd_mars_date.mars_year*100 then
            raise_application_error(-20000, 'Operating plan (this year) casting period ('||to_char(rcd_fcst_load_header.fcst_cast_yyyynn)||') does not match CLIO casting period ('||to_char(rcd_mars_date.mars_year*100)||'00)');
         end if;
      end if;
      if rcd_fcst_load_header.fcst_type = '*OP2' then
         if rcd_fcst_load_header.fcst_cast_yyyynn != (rcd_mars_date.mars_year+1)*100 then
            raise_application_error(-20000, 'Operating plan (next year) casting period ('||to_char(rcd_fcst_load_header.fcst_cast_yyyynn)||') does not match CLIO casting period ('||to_char((rcd_mars_date.mars_year+1)*100)||'00)');
         end if;
      end if;

      /*-*/
      /* Update the forecast load header
      /*-*/
      update fcst_load_header
         set load_status = '*LOADED',
             upd_user = var_user,
             upd_date = sysdate
       where load_identifier = rcd_fcst_load_header.load_identifier;

      /*-*/
      /* Set the forecast type variable
      /*-*/
      if rcd_fcst_load_header.fcst_time = '*PRD' then
         if rcd_fcst_load_header.fcst_type = '*BR' then
            var_fcst_type_code := 3;
         end if;
         if rcd_fcst_load_header.fcst_type = '*OP1' then
            var_fcst_type_code := 4;
         end if;
         if rcd_fcst_load_header.fcst_type = '*OP2' then
            var_fcst_type_code := 4;
         end if;
      end if;

      /*-*/
      /* Delete any existing forecasts for the split definition as required
      /* **notes** 1. a null sales division customer code will delete all forecasts for the sales detail
      /*           2. replace *SPLIT will delete all existing forecasts for the split
      /*           3. replace *MATERIAL will delete all existing forecasts for the load materials only
      /*-*/
      if rcd_fcst_load_header.load_replace = '*SPLIT' then
         if rcd_fcst_load_header.sap_sales_div_cust_code is null then
            delete from fcst_period
             where fcst_type_code = var_fcst_type_code
               and fcst_price_type_code in (1,2)
               and casting_yyyypp = rcd_fcst_load_header.fcst_cast_yyyynn
               and sap_sales_dtl_sales_org_code = rcd_fcst_load_header.sap_sales_org_code
               and sap_sales_dtl_distbn_chnl_code = rcd_fcst_load_header.sap_distbn_chnl_code
               and sap_sales_dtl_division_code = rcd_fcst_load_header.sap_division_code;
          else
            delete from fcst_period
             where fcst_type_code = var_fcst_type_code
               and fcst_price_type_code in (1,2)
               and casting_yyyypp = rcd_fcst_load_header.fcst_cast_yyyynn
               and sap_sales_dtl_sales_org_code = rcd_fcst_load_header.sap_sales_org_code
               and sap_sales_dtl_distbn_chnl_code = rcd_fcst_load_header.sap_distbn_chnl_code
               and sap_sales_dtl_division_code = rcd_fcst_load_header.sap_division_code
               and sap_sales_div_cust_code = rcd_fcst_load_header.sap_sales_div_cust_code
               and sap_sales_div_sales_org_code = rcd_fcst_load_header.sap_sales_div_sales_org_code
               and sap_sales_div_distbn_chnl_code = rcd_fcst_load_header.sap_sales_div_distbn_chnl_code
               and sap_sales_div_division_code = rcd_fcst_load_header.sap_sales_div_division_code;
          end if;
       else
         if rcd_fcst_load_header.sap_sales_div_cust_code is null then
            delete from fcst_period
             where fcst_type_code = var_fcst_type_code
               and fcst_price_type_code in (1,2)
               and casting_yyyypp = rcd_fcst_load_header.fcst_cast_yyyynn
               and sap_sales_dtl_sales_org_code = rcd_fcst_load_header.sap_sales_org_code
               and sap_sales_dtl_distbn_chnl_code = rcd_fcst_load_header.sap_distbn_chnl_code
               and sap_sales_dtl_division_code = rcd_fcst_load_header.sap_division_code
               and sap_material_code in (select sap_material_code
                                           from fcst_load_detail
                                          where load_identifier = rcd_fcst_load_header.load_identifier);
          else
            delete from fcst_period
             where fcst_type_code = var_fcst_type_code
               and fcst_price_type_code in (1,2)
               and casting_yyyypp = rcd_fcst_load_header.fcst_cast_yyyynn
               and sap_sales_dtl_sales_org_code = rcd_fcst_load_header.sap_sales_org_code
               and sap_sales_dtl_distbn_chnl_code = rcd_fcst_load_header.sap_distbn_chnl_code
               and sap_sales_dtl_division_code = rcd_fcst_load_header.sap_division_code
               and sap_sales_div_cust_code = rcd_fcst_load_header.sap_sales_div_cust_code
               and sap_sales_div_sales_org_code = rcd_fcst_load_header.sap_sales_div_sales_org_code
               and sap_sales_div_distbn_chnl_code = rcd_fcst_load_header.sap_sales_div_distbn_chnl_code
               and sap_sales_div_division_code = rcd_fcst_load_header.sap_sales_div_division_code
               and sap_material_code in (select sap_material_code
                                           from fcst_load_detail
                                          where load_identifier = rcd_fcst_load_header.load_identifier);
          end if;
       end if;

      /*-*/
      /* Load the period array
      /*-*/
      var_yyyynn := rcd_fcst_load_header.fcst_cast_yyyynn;
      for idx in 1..13 loop
         if substr(to_char(var_yyyynn,'fm000000'),5,2) = '13' then
            var_yyyynn := var_yyyynn + 88;
         else
            var_yyyynn := var_yyyynn + 1;
         end if;
         tbl_wrkn(idx) := var_yyyynn;
      end loop;

      /*-*/
      /* Retrieve the forecast load details
      /*-*/
      open csr_fcst_load_detail;
      loop
         fetch csr_fcst_load_detail into rcd_fcst_load_detail;
         if csr_fcst_load_detail%notfound then
            exit;
         end if;

         /*-*/
         /* Set the forecast arrays
         /*-*/
         tbl_wrkq(1) := rcd_fcst_load_detail.fcst_qty_01;
         tbl_wrkq(2) := rcd_fcst_load_detail.fcst_qty_02;
         tbl_wrkq(3) := rcd_fcst_load_detail.fcst_qty_03;
         tbl_wrkq(4) := rcd_fcst_load_detail.fcst_qty_04;
         tbl_wrkq(5) := rcd_fcst_load_detail.fcst_qty_05;
         tbl_wrkq(6) := rcd_fcst_load_detail.fcst_qty_06;
         tbl_wrkq(7) := rcd_fcst_load_detail.fcst_qty_07;
         tbl_wrkq(8) := rcd_fcst_load_detail.fcst_qty_08;
         tbl_wrkq(9) := rcd_fcst_load_detail.fcst_qty_09;
         tbl_wrkq(10) := rcd_fcst_load_detail.fcst_qty_10;
         tbl_wrkq(11) := rcd_fcst_load_detail.fcst_qty_11;
         tbl_wrkq(12) := rcd_fcst_load_detail.fcst_qty_12;
         tbl_wrkq(13) := rcd_fcst_load_detail.fcst_qty_13;
         /*-*/
         tbl_wrkb(1) := rcd_fcst_load_detail.fcst_bps_01;
         tbl_wrkb(2) := rcd_fcst_load_detail.fcst_bps_02;
         tbl_wrkb(3) := rcd_fcst_load_detail.fcst_bps_03;
         tbl_wrkb(4) := rcd_fcst_load_detail.fcst_bps_04;
         tbl_wrkb(5) := rcd_fcst_load_detail.fcst_bps_05;
         tbl_wrkb(6) := rcd_fcst_load_detail.fcst_bps_06;
         tbl_wrkb(7) := rcd_fcst_load_detail.fcst_bps_07;
         tbl_wrkb(8) := rcd_fcst_load_detail.fcst_bps_08;
         tbl_wrkb(9) := rcd_fcst_load_detail.fcst_bps_09;
         tbl_wrkb(10) := rcd_fcst_load_detail.fcst_bps_10;
         tbl_wrkb(11) := rcd_fcst_load_detail.fcst_bps_11;
         tbl_wrkb(12) := rcd_fcst_load_detail.fcst_bps_12;
         tbl_wrkb(13) := rcd_fcst_load_detail.fcst_bps_13;
         /*-*/
         tbl_wrkg(1) := rcd_fcst_load_detail.fcst_gsv_01;
         tbl_wrkg(2) := rcd_fcst_load_detail.fcst_gsv_02;
         tbl_wrkg(3) := rcd_fcst_load_detail.fcst_gsv_03;
         tbl_wrkg(4) := rcd_fcst_load_detail.fcst_gsv_04;
         tbl_wrkg(5) := rcd_fcst_load_detail.fcst_gsv_05;
         tbl_wrkg(6) := rcd_fcst_load_detail.fcst_gsv_06;
         tbl_wrkg(7) := rcd_fcst_load_detail.fcst_gsv_07;
         tbl_wrkg(8) := rcd_fcst_load_detail.fcst_gsv_08;
         tbl_wrkg(9) := rcd_fcst_load_detail.fcst_gsv_09;
         tbl_wrkg(10) := rcd_fcst_load_detail.fcst_gsv_10;
         tbl_wrkg(11) := rcd_fcst_load_detail.fcst_gsv_11;
         tbl_wrkg(12) := rcd_fcst_load_detail.fcst_gsv_12;
         tbl_wrkg(13) := rcd_fcst_load_detail.fcst_gsv_13;

         /*-*/
         /* Set the forecast period data
         /*-*/
         rcd_fcst_period.fcst_type_code := var_fcst_type_code;
         rcd_fcst_period.fcst_price_type_code := null;
         rcd_fcst_period.casting_yyyypp := rcd_fcst_load_header.fcst_cast_yyyynn;
         rcd_fcst_period.fcst_yyyypp := 0;
         rcd_fcst_period.sap_sales_dtl_sales_org_code := rcd_fcst_load_header.sap_sales_org_code;
         rcd_fcst_period.sap_sales_dtl_distbn_chnl_code := rcd_fcst_load_header.sap_distbn_chnl_code;
         rcd_fcst_period.sap_sales_dtl_division_code := rcd_fcst_load_header.sap_division_code;
         rcd_fcst_period.sap_sales_div_cust_code := rcd_fcst_load_header.sap_sales_div_cust_code;
         rcd_fcst_period.sap_sales_div_sales_org_code := rcd_fcst_load_header.sap_sales_div_sales_org_code;
         rcd_fcst_period.sap_sales_div_distbn_chnl_code := rcd_fcst_load_header.sap_sales_div_distbn_chnl_code;
         rcd_fcst_period.sap_sales_div_division_code := rcd_fcst_load_header.sap_sales_div_division_code;
         rcd_fcst_period.sap_material_code := rcd_fcst_load_detail.sap_material_code;
         rcd_fcst_period.fcst_value := 0;
         rcd_fcst_period.fcst_qty := 0;
         rcd_fcst_period.fcst_period_lupdp := var_user;
         rcd_fcst_period.fcst_period_lupdt := sysdate;

         /*-*/
         /* Load the forecast period BPS data
         /*-*/
         rcd_fcst_period.fcst_price_type_code := 1;
         for idx in 1..13 loop
            rcd_fcst_period.fcst_yyyypp := tbl_wrkn(idx);
            rcd_fcst_period.fcst_value := tbl_wrkb(idx);
            rcd_fcst_period.fcst_qty := tbl_wrkq(idx);
            insert into fcst_period
               (fcst_type_code,
                fcst_price_type_code,
                casting_yyyypp,
                fcst_yyyypp,
                sap_sales_dtl_sales_org_code,
                sap_sales_dtl_distbn_chnl_code,
                sap_sales_dtl_division_code,
                sap_sales_div_cust_code,
                sap_sales_div_sales_org_code,
                sap_sales_div_distbn_chnl_code,
                sap_sales_div_division_code,
                sap_material_code,
                fcst_value,
                fcst_qty,
                fcst_period_lupdp,
                fcst_period_lupdt)
               values (rcd_fcst_period.fcst_type_code,
                       rcd_fcst_period.fcst_price_type_code,
                       rcd_fcst_period.casting_yyyypp,
                       rcd_fcst_period.fcst_yyyypp,
                       rcd_fcst_period.sap_sales_dtl_sales_org_code,
                       rcd_fcst_period.sap_sales_dtl_distbn_chnl_code,
                       rcd_fcst_period.sap_sales_dtl_division_code,
                       rcd_fcst_period.sap_sales_div_cust_code,
                       rcd_fcst_period.sap_sales_div_sales_org_code,
                       rcd_fcst_period.sap_sales_div_distbn_chnl_code,
                       rcd_fcst_period.sap_sales_div_division_code,
                       rcd_fcst_period.sap_material_code,
                       rcd_fcst_period.fcst_value,
                       rcd_fcst_period.fcst_qty,
                       rcd_fcst_period.fcst_period_lupdp,
                       rcd_fcst_period.fcst_period_lupdt);
         end loop;

         /*-*/
         /* Load the forecast period GSV data
         /*-*/
         rcd_fcst_period.fcst_price_type_code := 2;
         for idx in 1..13 loop
            rcd_fcst_period.fcst_yyyypp := tbl_wrkn(idx);
            rcd_fcst_period.fcst_value := tbl_wrkg(idx);
            rcd_fcst_period.fcst_qty := tbl_wrkq(idx);
            insert into fcst_period
               (fcst_type_code,
                fcst_price_type_code,
                casting_yyyypp,
                fcst_yyyypp,
                sap_sales_dtl_sales_org_code,
                sap_sales_dtl_distbn_chnl_code,
                sap_sales_dtl_division_code,
                sap_sales_div_cust_code,
                sap_sales_div_sales_org_code,
                sap_sales_div_distbn_chnl_code,
                sap_sales_div_division_code,
                sap_material_code,
                fcst_value,
                fcst_qty,
                fcst_period_lupdp,
                fcst_period_lupdt)
               values (rcd_fcst_period.fcst_type_code,
                       rcd_fcst_period.fcst_price_type_code,
                       rcd_fcst_period.casting_yyyypp,
                       rcd_fcst_period.fcst_yyyypp,
                       rcd_fcst_period.sap_sales_dtl_sales_org_code,
                       rcd_fcst_period.sap_sales_dtl_distbn_chnl_code,
                       rcd_fcst_period.sap_sales_dtl_division_code,
                       rcd_fcst_period.sap_sales_div_cust_code,
                       rcd_fcst_period.sap_sales_div_sales_org_code,
                       rcd_fcst_period.sap_sales_div_distbn_chnl_code,
                       rcd_fcst_period.sap_sales_div_division_code,
                       rcd_fcst_period.sap_material_code,
                       rcd_fcst_period.fcst_value,
                       rcd_fcst_period.fcst_qty,
                       rcd_fcst_period.fcst_period_lupdp,
                       rcd_fcst_period.fcst_period_lupdt);
         end loop;

      end loop;
      close csr_fcst_load_detail;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_FORECAST_LOADING - ACCEPT_PERIOD_LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end accept_period_load;

   /*****************************************************/
   /* This procedure performs the validate load routine */
   /*****************************************************/
   function validate_load(par_identifier in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_errors boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_header is 
         select *
           from fcst_load_header t01
          where t01.load_identifier = par_identifier;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

      cursor csr_fcst_load_detail is
         select t01.*,
                nvl(t02.material_sts_code,'*NONE') as material_sts_code,
                t02.fcst_split_division,
                t02.fcst_split_brand,
                t02.fcst_split_sub_brand
           from fcst_load_detail t01,
                (select t01.sap_material_code,
                        t01.material_sts_code,
                        decode(t04.level_code,'X',t04.fcst_split_division,
                                              decode(t03.level_code,'X',t03.fcst_split_division,
                                                     decode(t02.level_code,'X',t02.fcst_split_division,null))) as fcst_split_division,
                        decode(t04.level_code,'X',t04.fcst_split_brand,
                                              decode(t03.level_code,'X',t03.fcst_split_brand,
                                                     decode(t02.level_code,'X',t02.fcst_split_brand,null))) as fcst_split_brand,
                        decode(t04.level_code,'X',t04.fcst_split_sub_brand,
                                              decode(t03.level_code,'X',t03.fcst_split_sub_brand,
                                                     decode(t02.level_code,'X',t02.fcst_split_sub_brand,null))) as fcst_split_sub_brand
                   from material_dim t01,
                        (select 'X' as level_code,
                                t01.fcst_split_division,
                                t01.fcst_split_brand,
                                t01.fcst_split_sub_brand,
                                t02.sap_material_code
                           from fcst_split t01,
                                material_dim t02
                          where t01.fcst_split_division = t02.sap_material_division_code
                            and t01.fcst_split_brand = '*ALL'
                            and t01.fcst_split_sub_brand = '*ALL') t02,
                        (select 'X' as level_code,
                                t01.fcst_split_division,
                                t01.fcst_split_brand,
                                t01.fcst_split_sub_brand,
                                t02.sap_material_code
                           from fcst_split t01,
                                material_dim t02
                          where t01.fcst_split_division = t02.sap_material_division_code
                            and t01.fcst_split_brand = t02.sap_brand_flag_code
                            and t01.fcst_split_sub_brand = '*ALL') t03,
                        (select 'X' as level_code,
                                t01.fcst_split_division,
                                t01.fcst_split_brand,
                                t01.fcst_split_sub_brand,
                                t02.sap_material_code
                           from fcst_split t01,
                                material_dim t02
                          where t01.fcst_split_division = t02.sap_material_division_code
                            and t01.fcst_split_brand = t02.sap_brand_flag_code
                            and t01.fcst_split_sub_brand = t02.sap_brand_sub_flag_code) t04
                  where t01.sap_material_code = t02.sap_material_code(+)
                    and t01.sap_material_code = t03.sap_material_code(+)
                    and t01.sap_material_code = t04.sap_material_code(+)) t02
          where t01.sap_material_code = t02.sap_material_code(+)
            and t01.load_identifier = rcd_fcst_load_header.load_identifier;
      rcd_fcst_load_detail csr_fcst_load_detail%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the forecast header row
      /*-*/
      open csr_fcst_load_header;
      fetch csr_fcst_load_header into rcd_fcst_load_header;
      if csr_fcst_load_header%notfound then
         raise_application_error(-20000, 'Forecast load (' || par_identifier || ') does not exist');
      end if;
      close csr_fcst_load_header;

      /*-*/
      /* Reset the error indicator
      /*-*/
      var_errors := false;

      /*-*/
      /* Retrieve the forecast load details
      /*-*/
      open csr_fcst_load_detail;
      loop
         fetch csr_fcst_load_detail into rcd_fcst_load_detail;
         if csr_fcst_load_detail%notfound then
            exit;
         end if;

         /*-*/
         /* Set the forecast load detail
         /*-*/
         rcd_fcst_load_detail.err_message := null;

         /*-*/
         /* Validate the forecast material
         /*-*/
         if rcd_fcst_load_detail.material_sts_code = '*NONE' then
            if rcd_fcst_load_detail.err_message is null then
               rcd_fcst_load_detail.err_message := 'Material ('||rcd_fcst_load_detail.sap_material_code||')';
            end if;
            rcd_fcst_load_detail.err_message := rcd_fcst_load_detail.err_message||' - does not exist in CLIO';
            var_errors := true;
         end if;
         if rcd_fcst_load_detail.material_sts_code != 'ACTIVE' then
            if rcd_fcst_load_detail.err_message is null then
               rcd_fcst_load_detail.err_message := 'Material ('||rcd_fcst_load_detail.sap_material_code||')';
            end if;
            rcd_fcst_load_detail.err_message := rcd_fcst_load_detail.err_message||' - is not active in CLIO';
            var_errors := true;
         end if;
         if rcd_fcst_load_detail.fcst_split_division != rcd_fcst_load_header.fcst_split_division or
            rcd_fcst_load_detail.fcst_split_brand != rcd_fcst_load_header.fcst_split_brand or
            rcd_fcst_load_detail.fcst_split_sub_brand != rcd_fcst_load_header.fcst_split_sub_brand then
            if rcd_fcst_load_detail.err_message is null then
               rcd_fcst_load_detail.err_message := 'Material ('||rcd_fcst_load_detail.sap_material_code||')';
            end if;
            rcd_fcst_load_detail.err_message := rcd_fcst_load_detail.err_message||' - does not belong to the forecast load split';
            var_errors := true;
         end if;

         /*-*/
         /* Validate the forecast data
         /*-*/
         if rcd_fcst_load_detail.fcst_qty_01 = 0 and
            rcd_fcst_load_detail.fcst_qty_02 = 0 and
            rcd_fcst_load_detail.fcst_qty_03 = 0 and
            rcd_fcst_load_detail.fcst_qty_04 = 0 and
            rcd_fcst_load_detail.fcst_qty_05 = 0 and
            rcd_fcst_load_detail.fcst_qty_06 = 0 and
            rcd_fcst_load_detail.fcst_qty_07 = 0 and
            rcd_fcst_load_detail.fcst_qty_08 = 0 and
            rcd_fcst_load_detail.fcst_qty_09 = 0 and
            rcd_fcst_load_detail.fcst_qty_10 = 0 and
            rcd_fcst_load_detail.fcst_qty_11 = 0 and
            rcd_fcst_load_detail.fcst_qty_12 = 0 and
            rcd_fcst_load_detail.fcst_qty_13 = 0 then
            if rcd_fcst_load_detail.err_message is null then
               rcd_fcst_load_detail.err_message := 'Material ('||rcd_fcst_load_detail.sap_material_code||')';
            end if;
            rcd_fcst_load_detail.err_message := rcd_fcst_load_detail.err_message||' - does not have any forecast quantities';
            var_errors := true;
         end if;

         if rcd_fcst_load_header.fcst_source = '*PLN' or rcd_fcst_load_header.fcst_source = '*TXQ' then
            if (rcd_fcst_load_detail.fcst_qty_01 != 0 and rcd_fcst_load_detail.fcst_prc_01 = 0) or
               (rcd_fcst_load_detail.fcst_qty_02 != 0 and rcd_fcst_load_detail.fcst_prc_02 = 0) or
               (rcd_fcst_load_detail.fcst_qty_03 != 0 and rcd_fcst_load_detail.fcst_prc_03 = 0) or
               (rcd_fcst_load_detail.fcst_qty_04 != 0 and rcd_fcst_load_detail.fcst_prc_04 = 0) or
               (rcd_fcst_load_detail.fcst_qty_05 != 0 and rcd_fcst_load_detail.fcst_prc_05 = 0) or
               (rcd_fcst_load_detail.fcst_qty_06 != 0 and rcd_fcst_load_detail.fcst_prc_06 = 0) or
               (rcd_fcst_load_detail.fcst_qty_07 != 0 and rcd_fcst_load_detail.fcst_prc_07 = 0) or
               (rcd_fcst_load_detail.fcst_qty_08 != 0 and rcd_fcst_load_detail.fcst_prc_08 = 0) or
               (rcd_fcst_load_detail.fcst_qty_09 != 0 and rcd_fcst_load_detail.fcst_prc_09 = 0) or
               (rcd_fcst_load_detail.fcst_qty_10 != 0 and rcd_fcst_load_detail.fcst_prc_10 = 0) or
               (rcd_fcst_load_detail.fcst_qty_11 != 0 and rcd_fcst_load_detail.fcst_prc_11 = 0) or
               (rcd_fcst_load_detail.fcst_qty_12 != 0 and rcd_fcst_load_detail.fcst_prc_12 = 0) or
               (rcd_fcst_load_detail.fcst_qty_13 != 0 and rcd_fcst_load_detail.fcst_prc_13 = 0) then
               if rcd_fcst_load_detail.err_message is null then
                  rcd_fcst_load_detail.err_message := 'Material ('||rcd_fcst_load_detail.sap_material_code||')';
               end if;
               rcd_fcst_load_detail.err_message := rcd_fcst_load_detail.err_message||' - does not have pricing data for some forecast quantities';
               var_errors := true;
            end if;
         end if;

         if rcd_fcst_load_header.fcst_source = '*TXV' then
            if ((rcd_fcst_load_detail.fcst_qty_01 != 0 or rcd_fcst_load_detail.fcst_bps_01 != 0 or rcd_fcst_load_detail.fcst_gsv_01 != 0) and
                (rcd_fcst_load_detail.fcst_qty_01 = 0 or rcd_fcst_load_detail.fcst_bps_01 = 0 or rcd_fcst_load_detail.fcst_gsv_01 = 0)) or
               ((rcd_fcst_load_detail.fcst_qty_02 != 0 or rcd_fcst_load_detail.fcst_bps_02 != 0 or rcd_fcst_load_detail.fcst_gsv_02 != 0) and
                (rcd_fcst_load_detail.fcst_qty_02 = 0 or rcd_fcst_load_detail.fcst_bps_02 = 0 or rcd_fcst_load_detail.fcst_gsv_02 = 0)) or
               ((rcd_fcst_load_detail.fcst_qty_03 != 0 or rcd_fcst_load_detail.fcst_bps_03 != 0 or rcd_fcst_load_detail.fcst_gsv_03 != 0) and
                (rcd_fcst_load_detail.fcst_qty_03 = 0 or rcd_fcst_load_detail.fcst_bps_03 = 0 or rcd_fcst_load_detail.fcst_gsv_03 = 0)) or
               ((rcd_fcst_load_detail.fcst_qty_04 != 0 or rcd_fcst_load_detail.fcst_bps_04 != 0 or rcd_fcst_load_detail.fcst_gsv_04 != 0) and
                (rcd_fcst_load_detail.fcst_qty_04 = 0 or rcd_fcst_load_detail.fcst_bps_04 = 0 or rcd_fcst_load_detail.fcst_gsv_04 = 0)) or
               ((rcd_fcst_load_detail.fcst_qty_05 != 0 or rcd_fcst_load_detail.fcst_bps_05 != 0 or rcd_fcst_load_detail.fcst_gsv_05 != 0) and
                (rcd_fcst_load_detail.fcst_qty_05 = 0 or rcd_fcst_load_detail.fcst_bps_05 = 0 or rcd_fcst_load_detail.fcst_gsv_05 = 0)) or
               ((rcd_fcst_load_detail.fcst_qty_06 != 0 or rcd_fcst_load_detail.fcst_bps_06 != 0 or rcd_fcst_load_detail.fcst_gsv_06 != 0) and
                (rcd_fcst_load_detail.fcst_qty_06 = 0 or rcd_fcst_load_detail.fcst_bps_06 = 0 or rcd_fcst_load_detail.fcst_gsv_06 = 0)) or
               ((rcd_fcst_load_detail.fcst_qty_07 != 0 or rcd_fcst_load_detail.fcst_bps_07 != 0 or rcd_fcst_load_detail.fcst_gsv_07 != 0) and
                (rcd_fcst_load_detail.fcst_qty_07 = 0 or rcd_fcst_load_detail.fcst_bps_07 = 0 or rcd_fcst_load_detail.fcst_gsv_07 = 0)) or
               ((rcd_fcst_load_detail.fcst_qty_08 != 0 or rcd_fcst_load_detail.fcst_bps_08 != 0 or rcd_fcst_load_detail.fcst_gsv_08 != 0) and
                (rcd_fcst_load_detail.fcst_qty_08 = 0 or rcd_fcst_load_detail.fcst_bps_08 = 0 or rcd_fcst_load_detail.fcst_gsv_08 = 0)) or
               ((rcd_fcst_load_detail.fcst_qty_09 != 0 or rcd_fcst_load_detail.fcst_bps_09 != 0 or rcd_fcst_load_detail.fcst_gsv_09 != 0) and
                (rcd_fcst_load_detail.fcst_qty_09 = 0 or rcd_fcst_load_detail.fcst_bps_09 = 0 or rcd_fcst_load_detail.fcst_gsv_09 = 0)) or
               ((rcd_fcst_load_detail.fcst_qty_10 != 0 or rcd_fcst_load_detail.fcst_bps_10 != 0 or rcd_fcst_load_detail.fcst_gsv_10 != 0) and
                (rcd_fcst_load_detail.fcst_qty_10 = 0 or rcd_fcst_load_detail.fcst_bps_10 = 0 or rcd_fcst_load_detail.fcst_gsv_10 = 0)) or
               ((rcd_fcst_load_detail.fcst_qty_11 != 0 or rcd_fcst_load_detail.fcst_bps_11 != 0 or rcd_fcst_load_detail.fcst_gsv_11 != 0) and
                (rcd_fcst_load_detail.fcst_qty_11 = 0 or rcd_fcst_load_detail.fcst_bps_11 = 0 or rcd_fcst_load_detail.fcst_gsv_11 = 0)) or
               ((rcd_fcst_load_detail.fcst_qty_12 != 0 or rcd_fcst_load_detail.fcst_bps_12 != 0 or rcd_fcst_load_detail.fcst_gsv_12 != 0) and
                (rcd_fcst_load_detail.fcst_qty_12 = 0 or rcd_fcst_load_detail.fcst_bps_12 = 0 or rcd_fcst_load_detail.fcst_gsv_12 = 0)) or
               ((rcd_fcst_load_detail.fcst_qty_13 != 0 or rcd_fcst_load_detail.fcst_bps_13 != 0 or rcd_fcst_load_detail.fcst_gsv_13 != 0) and
                (rcd_fcst_load_detail.fcst_qty_13 = 0 or rcd_fcst_load_detail.fcst_bps_13 = 0 or rcd_fcst_load_detail.fcst_gsv_13 = 0)) then
               if rcd_fcst_load_detail.err_message is null then
                  rcd_fcst_load_detail.err_message := 'Material ('||rcd_fcst_load_detail.sap_material_code||')';
               end if;
               rcd_fcst_load_detail.err_message := rcd_fcst_load_detail.err_message||' - does not have forecast QTY or BPS or GSV values for all used periods';
               var_errors := true;
            end if;
         end if;

         /*-*/
         /* Update the forecast load detail row
         /*-*/
         update fcst_load_detail
            set err_message = rcd_fcst_load_detail.err_message
          where load_identifier = rcd_fcst_load_detail.load_identifier
            and sap_material_code = rcd_fcst_load_detail.sap_material_code;

      end loop;
      close csr_fcst_load_detail;

      /*-*/
      /* Retrurn the new forecast load header status
      /*-*/
      if var_errors = false then
         rcd_fcst_load_header.load_status := '*VALID';
      else
         rcd_fcst_load_header.load_status := '*ERROR';
      end if;
      return rcd_fcst_load_header.load_status;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_load;

   /********************************************************/
   /* This procedure performs the read text stream routine */
   /********************************************************/
   procedure read_txt_stream(par_stream in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_value varchar2(1024);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the forecast data
      /*-*/
      delete from fcst_data;
      commit;

      /*-*/
      /* Strip the comma delimited stream
      /*-*/
      var_value := null;
      for idx in 1..length(par_stream) loop
         if substr(par_stream,idx,1) = ',' then
            if not(var_value is null) then
               if length(var_value) > 18 then
                  raise_application_error(-20000, 'Material list - Material code ('||var_value||') exceeds maximum length 18');
               end if;
               insert into fcst_data
                  (sap_material_code,
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
                   fcst_qty13,
                   fcst_bps01,
                   fcst_bps02,
                   fcst_bps03,
                   fcst_bps04,
                   fcst_bps05,
                   fcst_bps06,
                   fcst_bps07,
                   fcst_bps08,
                   fcst_bps09,
                   fcst_bps10,
                   fcst_bps11,
                   fcst_bps12,
                   fcst_bps13,
                   fcst_gsv01,
                   fcst_gsv02,
                   fcst_gsv03,
                   fcst_gsv04,
                   fcst_gsv05,
                   fcst_gsv06,
                   fcst_gsv07,
                   fcst_gsv08,
                   fcst_gsv09,
                   fcst_gsv10,
                   fcst_gsv11,
                   fcst_gsv12,
                   fcst_gsv13)
                  values(var_value,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0);
            end if;
            var_value := null;
         else
            var_value := var_value||substr(par_stream,idx,1);
         end if;
      end loop;
      if not(var_value is null) then
         if length(var_value) > 18 then
            raise_application_error(-20000, 'Material list - Material code ('||var_value||') exceeds maximum length 18');
         end if;
         insert into fcst_data
            (sap_material_code,
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
             fcst_qty13,
             fcst_bps01,
             fcst_bps02,
             fcst_bps03,
             fcst_bps04,
             fcst_bps05,
             fcst_bps06,
             fcst_bps07,
             fcst_bps08,
             fcst_bps09,
             fcst_bps10,
             fcst_bps11,
             fcst_bps12,
             fcst_bps13,
             fcst_gsv01,
             fcst_gsv02,
             fcst_gsv03,
             fcst_gsv04,
             fcst_gsv05,
             fcst_gsv06,
             fcst_gsv07,
             fcst_gsv08,
             fcst_gsv09,
             fcst_gsv10,
             fcst_gsv11,
             fcst_gsv12,
             fcst_gsv13)
            values(var_value,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0);
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_txt_stream;

   /*******************************************************/
   /* This procedure performs the read xml stream routine */
   /*******************************************************/
   procedure read_xml_stream(par_source in varchar2, par_stream in clob) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_xml_element xmlDom.domElement;
      obj_xml_node xmlDom.domNode;
      var_index number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the forecast data
      /*-*/
      delete from fcst_data;
      commit;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,par_stream);
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve and process the primary node
      /*-*/
      var_wrkr := 0;
      obj_xml_element := xmlDom.getDocumentElement(obj_xml_document);
      obj_xml_node := xmlDom.makeNode(obj_xml_element);
      read_xml_child(par_source, obj_xml_node);

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_xml_stream;

   /******************************************************/
   /* This procedure performs the read xml child routine */
   /******************************************************/
   procedure read_xml_child(par_source in varchar2, par_xml_node in xmlDom.domNode) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_element xmlDom.domElement;
      obj_xml_node xmlDom.domNode;
      obj_xml_node_list xmlDom.domNodeList;
      rcd_fcst_data fcst_data%rowtype;
      var_string varchar2(32767);
      var_char varchar2(1);
      var_value varchar2(4000);
      var_index number;
      type typ_wrkw is table of number index by binary_integer;
      tbl_wrkw typ_wrkw;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the attribute node
      /*-*/
      case upper(xmlDom.getNodeName(par_xml_node))
         when 'TXTSTREAM' then
            null;
         when 'XR' then
            var_wrkr := var_wrkr + 1;
         when '#CDATA-SECTION' then
            rcd_fcst_data.sap_material_code := '*ROW';
            for idx in 1..39 loop
               tbl_wrkw(idx) := 0;
	    end loop;
            var_string := rtrim(ltrim(xmlDom.getNodeValue(par_xml_node),'['),']');
            if not(var_string is null) then
               var_value := null;
               var_index := 0;
               for idx in 1..length(var_string) loop
                  var_char := substr(var_string,idx,1);
                  if var_char = chr(9) then
                     if rcd_fcst_data.sap_material_code = '*ROW' then
                        if length(var_value) > 18 then
                           raise_application_error(-20000, 'Text file data row '||var_wrkr||' - Material code ('||var_value||') exceeds maximum length 18');
                        end if;
                        rcd_fcst_data.sap_material_code := var_value;
                     else
                        var_index := var_index + 1;
                        begin
                           if substr(var_value,length(var_value),1) = '-' then
                              tbl_wrkw(var_index) := to_number('-' || substr(var_value,1,length(var_value) - 1));
                           else
                              tbl_wrkw(var_index) := to_number(var_value);
                           end if;
                        exception
                           when others then
                              raise_application_error(-20000, 'Text file data row '||var_wrkr||' column '||var_index||' - Invalid number ('||var_value||')');
                        end;
                     end if;
                     var_value := null;
                  else
                     var_value := var_value||var_char;
                  end if;
               end loop;
               if rcd_fcst_data.sap_material_code = '*ROW' then
                  if length(var_value) > 18 then
                     raise_application_error(-20000, 'Text file data row '||var_wrkr||' - Material code ('||var_value||') exceeds maximum length 18');
                  end if;
                  rcd_fcst_data.sap_material_code := var_value;
               else
                  var_index := var_index + 1;
                  begin
                     if substr(var_value,length(var_value),1) = '-' then
                        tbl_wrkw(var_index) := to_number('-' || substr(var_value,1,length(var_value) - 1));
                     else
                        tbl_wrkw(var_index) := to_number(var_value);
                     end if;
                  exception
                     when others then
                        raise_application_error(-20000, 'Text file data row '||var_wrkr||' column '||var_index||' - Invalid number ('||var_value||')');
                  end;
               end if;
            end if;
            if par_source = '*TXQ' then
               if var_index != 13 then
                  raise_application_error(-20000, 'Text file data (quantity only) row '||var_wrkr||' - Column count must be equal to 14');
               end if;
            end if;
            if par_source = '*TXV' then
               if var_index != 39 then
                  raise_application_error(-20000, 'Text file data (quantity/value) row '||var_wrkr||' - Column count must be equal to 40');
               end if;
            end if;
            rcd_fcst_data.fcst_qty01 := tbl_wrkw(1);
            rcd_fcst_data.fcst_qty02 := tbl_wrkw(2);
            rcd_fcst_data.fcst_qty03 := tbl_wrkw(3);
            rcd_fcst_data.fcst_qty04 := tbl_wrkw(4);
            rcd_fcst_data.fcst_qty05 := tbl_wrkw(5);
            rcd_fcst_data.fcst_qty06 := tbl_wrkw(6);
            rcd_fcst_data.fcst_qty07 := tbl_wrkw(7);
            rcd_fcst_data.fcst_qty08 := tbl_wrkw(8);
            rcd_fcst_data.fcst_qty09 := tbl_wrkw(9);
            rcd_fcst_data.fcst_qty10 := tbl_wrkw(10);
            rcd_fcst_data.fcst_qty11 := tbl_wrkw(11);
            rcd_fcst_data.fcst_qty12 := tbl_wrkw(12);
            rcd_fcst_data.fcst_qty13 := tbl_wrkw(13);
            rcd_fcst_data.fcst_bps01 := tbl_wrkw(14);
            rcd_fcst_data.fcst_bps02 := tbl_wrkw(15);
            rcd_fcst_data.fcst_bps03 := tbl_wrkw(16);
            rcd_fcst_data.fcst_bps04 := tbl_wrkw(17);
            rcd_fcst_data.fcst_bps05 := tbl_wrkw(18);
            rcd_fcst_data.fcst_bps06 := tbl_wrkw(19);
            rcd_fcst_data.fcst_bps07 := tbl_wrkw(20);
            rcd_fcst_data.fcst_bps08 := tbl_wrkw(21);
            rcd_fcst_data.fcst_bps09 := tbl_wrkw(22);
            rcd_fcst_data.fcst_bps10 := tbl_wrkw(23);
            rcd_fcst_data.fcst_bps11 := tbl_wrkw(24);
            rcd_fcst_data.fcst_bps12 := tbl_wrkw(25);
            rcd_fcst_data.fcst_bps13 := tbl_wrkw(26);
            rcd_fcst_data.fcst_gsv01 := tbl_wrkw(27);
            rcd_fcst_data.fcst_gsv02 := tbl_wrkw(28);
            rcd_fcst_data.fcst_gsv03 := tbl_wrkw(29);
            rcd_fcst_data.fcst_gsv04 := tbl_wrkw(30);
            rcd_fcst_data.fcst_gsv05 := tbl_wrkw(31);
            rcd_fcst_data.fcst_gsv06 := tbl_wrkw(32);
            rcd_fcst_data.fcst_gsv07 := tbl_wrkw(33);
            rcd_fcst_data.fcst_gsv08 := tbl_wrkw(34);
            rcd_fcst_data.fcst_gsv09 := tbl_wrkw(35);
            rcd_fcst_data.fcst_gsv10 := tbl_wrkw(36);
            rcd_fcst_data.fcst_gsv11 := tbl_wrkw(37);
            rcd_fcst_data.fcst_gsv12 := tbl_wrkw(38);
            rcd_fcst_data.fcst_gsv13 := tbl_wrkw(39);
            insert into fcst_data
               (sap_material_code,
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
                fcst_qty13,
                fcst_bps01,
                fcst_bps02,
                fcst_bps03,
                fcst_bps04,
                fcst_bps05,
                fcst_bps06,
                fcst_bps07,
                fcst_bps08,
                fcst_bps09,
                fcst_bps10,
                fcst_bps11,
                fcst_bps12,
                fcst_bps13,
                fcst_gsv01,
                fcst_gsv02,
                fcst_gsv03,
                fcst_gsv04,
                fcst_gsv05,
                fcst_gsv06,
                fcst_gsv07,
                fcst_gsv08,
                fcst_gsv09,
                fcst_gsv10,
                fcst_gsv11,
                fcst_gsv12,
                fcst_gsv13)
               values(rcd_fcst_data.sap_material_code,
                      rcd_fcst_data.fcst_qty01,
                      rcd_fcst_data.fcst_qty02,
                      rcd_fcst_data.fcst_qty03,
                      rcd_fcst_data.fcst_qty04,
                      rcd_fcst_data.fcst_qty05,
                      rcd_fcst_data.fcst_qty06,
                      rcd_fcst_data.fcst_qty07,
                      rcd_fcst_data.fcst_qty08,
                      rcd_fcst_data.fcst_qty09,
                      rcd_fcst_data.fcst_qty10,
                      rcd_fcst_data.fcst_qty11,
                      rcd_fcst_data.fcst_qty12,
                      rcd_fcst_data.fcst_qty13,
                      rcd_fcst_data.fcst_bps01,
                      rcd_fcst_data.fcst_bps02,
                      rcd_fcst_data.fcst_bps03,
                      rcd_fcst_data.fcst_bps04,
                      rcd_fcst_data.fcst_bps05,
                      rcd_fcst_data.fcst_bps06,
                      rcd_fcst_data.fcst_bps07,
                      rcd_fcst_data.fcst_bps08,
                      rcd_fcst_data.fcst_bps09,
                      rcd_fcst_data.fcst_bps10,
                      rcd_fcst_data.fcst_bps11,
                      rcd_fcst_data.fcst_bps12,
                      rcd_fcst_data.fcst_bps13,
                      rcd_fcst_data.fcst_gsv01,
                      rcd_fcst_data.fcst_gsv02,
                      rcd_fcst_data.fcst_gsv03,
                      rcd_fcst_data.fcst_gsv04,
                      rcd_fcst_data.fcst_gsv05,
                      rcd_fcst_data.fcst_gsv06,
                      rcd_fcst_data.fcst_gsv07,
                      rcd_fcst_data.fcst_gsv08,
                      rcd_fcst_data.fcst_gsv09,
                      rcd_fcst_data.fcst_gsv10,
                      rcd_fcst_data.fcst_gsv11,
                      rcd_fcst_data.fcst_gsv12,
                      rcd_fcst_data.fcst_gsv13);
         else raise_application_error(-20000, 'read_xml_stream - Type (' || xmlDom.getNodeName(par_xml_node) || ') not recognised');
      end case;

      /*-*/
      /* Process the child nodes
      /*-*/
      obj_xml_node_list := xmlDom.getChildNodes(par_xml_node);
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         read_xml_child(par_source, obj_xml_node);
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_xml_child;

end dw_forecast_loading;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_forecast_loading for dw_app.dw_forecast_loading;
grant execute on dw_forecast_loading to public;

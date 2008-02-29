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
    2008/02   Steve Gregan   Created from Mars Japan version and modified for Mars China

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure select_load(par_identifier in varchar2);
   procedure delete_load(par_identifier in varchar2);
   procedure create_planning_load(par_cast_date in varchar2,
                                  par_fcst_str_date in varchar2,
                                  par_fcst_end_date in varchar2);

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
         raise_application_error(-20000, 'FATAL ERROR - DW_FORECAST_LOADING - SELECT_LOAD - ' || substr(SQLERRM, 1, 1024));

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
         raise_application_error(-20000, 'FATAL ERROR - DW_FORECAST_LOADING - DELETE_LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_load;

   /************************************************************/
   /* This procedure performs the create planning load routine */
   /************************************************************/
   procedure create_planning_load(par_cast_date in varchar2,
                                  par_fcst_str_date in varchar2,
                                  par_fcst_end_date in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      rcd_fcst_load_header fcst_load_header%rowtype;
      rcd_fcst_load_detail fcst_load_detail%rowtype;
      var_work_date date;
      var_cast_date date;
      var_fcst_str_date date;
      var_fcst_end_date date;
      var_cast_yyyymmdd rcd_fcst_load_header.cast_yyyymmdd%type;
      var_cast_yyyypp rcd_fcst_load_header.cast_yyyypp%type;
      var_cast_yyyyppw rcd_fcst_load_header.cast_yyyyppw%type;
      var_fcst_str_yyyymmdd rcd_fcst_load_header.fcst_str_yyyymmdd%type;
      var_fcst_str_yyyypp rcd_fcst_load_header.fcst_str_yyyypp%type;
      var_fcst_str_yyyyppw rcd_fcst_load_header.fcst_str_yyyyppw%type;
      var_fcst_end_yyyymmdd rcd_fcst_load_header.fcst_end_yyyymmdd%type;
      var_fcst_end_yyyypp rcd_fcst_load_header.fcst_end_yyyypp%type;
      var_fcst_end_yyyyppw rcd_fcst_load_header.fcst_end_yyyyppw%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_mars_date is
         select t01.mars_period,
                t01.mars_week
           from mars_date t01
          where trunc(t01.calendar_date) = trunc(var_work_date);
      rcd_mars_date csr_mars_date%rowtype;

      cursor csr_fcst_data is
         select t01.*,
                decode(t02.sap_bus_sgmnt_code,'01','*SNACKFOOD','05','*PETCARE','*NONE') as plan_group
           from fcst_data t01,
                material_dim t02
          where t01.material_code = t02.sap_material_code(+);
      rcd_fcst_data csr_fcst_data%rowtype;

      cursor csr_material is
         select decode(t01.sap_bus_sgmnt_code,'01','*SNACKFOOD','05','*PETCARE','*NONE') as plan_group
           from material_dim t01
          where t01.sap_material_code = rcd_fcst_load_detail.material_code;
      rcd_material csr_material%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Validate the parameter values
      /*-*/
      if par_cast_date is null then
         raise_application_error(-20000, 'Casting date parameter must be supplied');
      end if;
      if par_fcst_str_date is null then
         raise_application_error(-20000, 'Forecasting start date parameter must be supplied');
      end if;
      if par_fcst_end_date is null then
         raise_application_error(-20000, 'Forecasting end date parameter must be supplied');
      end if;
      /*-*/
      begin
         var_cast_date := to_date(par_cast_date,'yyyymmdd');
      exception
         when others then
            raise_application_error(-20000, 'Casting date parameter (' || par_cast_date || ') - unable to convert to date format YYYYMMDD');
      end;
      /*-*/
      begin
         var_fcst_str_date := to_date(par_fcst_str_date,'yyyymmdd');
      exception
         when others then
            raise_application_error(-20000, 'Forecasting start date parameter (' || par_fcst_str_date || ') - unable to convert to date format YYYYMMDD');
      end;
      /*-*/
      begin
         var_fcst_end_date := to_date(par_fcst_end_date,'yyyymmdd');
      exception
         when others then
            raise_application_error(-20000, 'Forecasting end date parameter (' || par_fcst_end_date || ') - unable to convert to date format YYYYMMDD');
      end;

      /*-*/
      /* Retrieve the period and week information
      /*-*/
      var_work_date := var_cast_date;
      open csr_mars_date;
      fetch csr_mars_date into rcd_mars_date;
      if csr_mars_date%notfound then
         raise_application_error(-20000, 'Casting date (' || to_char(var_cast_date,'yyyy/mm/dd') || ') does not exist in Mars Date Table');
      end if;
      close csr_mars_date;
      var_cast_yyyymmdd := to_char(var_cast_date,'yyyymmdd');
      var_cast_yyyypp := rcd_mars_date.mars_period;
      var_cast_yyyyppw := rcd_mars_date.mars_week;
      /*-*/
      var_work_date := var_fcst_str_date;
      open csr_mars_date;
      fetch csr_mars_date into rcd_mars_date;
      if csr_mars_date%notfound then
         raise_application_error(-20000, 'Forecast start date (' || to_char(var_fcst_str_date,'yyyy/mm/dd') || ') does not exist in Mars Date Table');
      end if;
      close csr_mars_date;
      var_fcst_str_yyyymmdd := to_char(var_fcst_str_date,'yyyymmdd');
      var_fcst_str_yyyypp := rcd_mars_date.mars_period;
      var_fcst_str_yyyyppw := rcd_mars_date.mars_week;
      /*-*/
      var_work_date := var_fcst_end_date;
      open csr_mars_date;
      fetch csr_mars_date into rcd_mars_date;
      if csr_mars_date%notfound then
         raise_application_error(-20000, 'Forecast end date (' || to_char(var_fcst_end_date,'yyyy/mm/dd') || ') does not exist in Mars Date Table'_;
      end if;
      close csr_mars_date;
      var_fcst_end_yyyymmdd := to_char(var_fcst_end_date,'yyyymmdd');
      var_fcst_end_yyyypp := rcd_mars_date.mars_period;
      var_fcst_end_yyyyppw := rcd_mars_date.mars_week;

      /*-*/
      /* Initialise the forecast load header
      /*-*/
      rcd_fcst_load_header.load_identifier := 'DOMESTIC_'||var_cast_yyyyppw;
      rcd_fcst_load_header.load_description := 'Domestic Volume Forecasts';
      rcd_fcst_load_header.load_status := '*CREATING';
      rcd_fcst_load_header.load_selected := '*NO';
      rcd_fcst_load_header.fcst_type := '*DOMESTIC';
      rcd_fcst_load_header.cast_yyyymmdd := var_cast_yyyymmdd;
      rcd_fcst_load_header.cast_yyyypp := var_cast_yyyypp;
      rcd_fcst_load_header.cast_yyyyppw := var_cast_yyyyppw;
      rcd_fcst_load_header.fcst_str_yyyymmdd := var_fcst_str_yyyymmdd;
      rcd_fcst_load_header.fcst_str_yyyypp := var_fcst_str_yyyypp;
      rcd_fcst_load_header.fcst_str_yyyyppw := var_fcst_str_yyyyppw;
      rcd_fcst_load_header.fcst_end_yyyymmdd := var_fcst_end_yyyymmdd;
      rcd_fcst_load_header.fcst_end_yyyypp := var_fcst_end_yyyypp;
      rcd_fcst_load_header.fcst_end_yyyyppw := var_fcst_end_yyyyppw;
      rcd_fcst_load_header.sap_sales_org_code := rcd_fcst_split.sap_sales_org_code;
      rcd_fcst_load_header.sap_distbn_chnl_code := rcd_fcst_split.sap_distbn_chnl_code;
      rcd_fcst_load_header.sap_division_code := rcd_fcst_split.sap_division_code;
      rcd_fcst_load_header.sap_sales_div_cust_code := rcd_fcst_split.sap_sales_div_cust_code;
      rcd_fcst_load_header.sap_sales_div_sales_org_code := rcd_fcst_split.sap_sales_div_sales_org_code;
      rcd_fcst_load_header.sap_sales_div_distbn_chnl_code := rcd_fcst_split.sap_sales_div_distbn_chnl_code;
      rcd_fcst_load_header.sap_sales_div_division_code := rcd_fcst_split.sap_sales_div_division_code;
      rcd_fcst_load_header.crt_user := user;
      rcd_fcst_load_header.crt_date := sysdate;
      rcd_fcst_load_header.upd_user := user;
      rcd_fcst_load_header.upd_date := sysdate;

      /*-*/
      /* Delete the existing forecast load
      /*-*/
      delete from fcst_load_detail where load_identifier = rcd_fcst_load_header.load_identifier;
      delete from fcst_load_header where load_identifier = rcd_fcst_load_header.load_identifier;

      /*-*/
      /* Insert the forecast load header
      /*-*/
      insert into fcst_load_header
         (load_identifier,
          load_description,
          load_status,
          load_selected,
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
                rcd_fcst_load_header.load_selected,
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
      /* Retrieve the forecast data
      /*-*/
      open csr_fcst_data;
      loop
         fetch csr_fcst_data into rcd_fcst_data;
         if csr_fcst_data%notfound then
            exit;
         end if;

         /*-*/
         /* Set the forecast load detail
         /*-*/
         rcd_fcst_load_detail.load_identifier := rcd_fcst_load_header.load_identifier;
         rcd_fcst_load_detail.material_code := rcd_fcst_data.material_code;
         rcd_fcst_load_detail.plant_code := rcd_fcst_data.plant_code;
         rcd_fcst_load_detail.fcst_yyyyppdd := rcd_fcst_data.fcst_yyyyppdd;
         rcd_fcst_load_detail.fcst_yyyypp := rcd_fcst_data.fcst_yyyypp;
         rcd_fcst_load_detail.fcst_yyyyppw := rcd_fcst_data.fcst_yyyyppw;
         rcd_fcst_load_detail.fcst_qty := rcd_fcst_data.fcst_qty;
         rcd_fcst_load_detail.fcst_prc := 0;
         rcd_fcst_load_detail.fcst_gsv := 0;
         rcd_fcst_load_detail.plan_group := rcd_fcst_data.plan_group;
         rcd_fcst_load_detail.err_message := null;

         /*-*/
         /* Insert the forecast load detail
         /*-*/
         insert into fcst_load_detail
            (load_identifier,
             material_code,
             fcst_yyyypp,
             fcst_yyyyppw,
             fcst_qty,
             fcst_prc,
             fcst_gsv,
             err_message)
            values (rcd_fcst_load_detail.load_identifier,
                    rcd_fcst_load_detail.material_code,
                    rcd_fcst_load_detail.fcst_yyyypp,
                    rcd_fcst_load_detail.fcst_yyyyppw,
                    rcd_fcst_load_detail.fcst_qty,
                    rcd_fcst_load_detail.fcst_prc,
                    rcd_fcst_load_detail.fcst_gsv,
                    rcd_fcst_load_detail.err_message);

      end loop;
      close csr_fcst_data;

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

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'DW_FORECAST_LOADING - CREATE_PLANNING_LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_planning_load;

   /*****************************************************/
   /* This procedure performs the validate load routine */
   /*****************************************************/
   function validate_load(par_identifier in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_errors boolean;
      var_material_save varchar2(18 char);
      var_wrk_yyyypp number;
      type rcd_wrkv is record(yyyypp number, price number);
      type tab_wrkv is table of rcd_wrkv index by binary_integer;
      tbl_wrkn typ_wrkv;

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
           from fcst_load_detail t01,
                (select t01.sap_material_code,
                        t01.material_sts_code
                   from material_dim t01) t02
          where t01.sap_material_code = t02.sap_material_code(+)
            and t01.load_identifier = rcd_fcst_load_header.load_identifier
          order by material_code asc
                   fcst_yyyypp asc;
      rcd_fcst_load_detail csr_fcst_load_detail%rowtype;

      cursor csr_material_price is
         select t04.mars_period as str_yyyypp,
                nvl(t05.mars_period,999999) as end_yyyypp,
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
            and (t04.mars_period <= var_fcst_str_yyyypp or
                 (t05.mars_period is null or t05.mars_period >= var_fcst_end_yyyypp))
          order by t04.mars_period asc,
                   t05.mars_period asc;
      rcd_material_price csr_material_price%rowtype;

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
      /* Load the forecast period array
      /*-*/
      tbl_wrkn.delete;
      var_wrk_yyyypp := rcd_fcst_load_header.fcst_str_yyyypp;
      loop
         if var_wrk_yyyypp > rcd_fcst_load_header.fcst_end_yyyypp then
            exit;
         end if;
         tbl_wrkn(tbl_wrkn.count+1).yyyypp := var_wrk_yyyypp;
         tbl_wrkn(tbl_wrkn.count).price := 0;
         if substr(to_char(var_wrk_yyyypp,'fm000000'),5,2) = '13' then
            var_wrk_yyyypp := var_wrk_yyyypp + 88;
         else
            var_wrk_yyyypp := var_wrk_yyyypp + 1;
         end if;
      end loop;

      /*-*/
      /* Reset the error indicator
      /*-*/
      var_errors := false;

      /*-*/
      /* Retrieve the forecast load details
      /*-*/
      var_material_save := null;
      open csr_fcst_load_detail;
      loop
         fetch csr_fcst_load_detail into rcd_fcst_load_detail;
         if csr_fcst_load_detail%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve the material price data for new material
         /*-*/
         if rcd_fcst_load_detail.material_code != var_material_save then
            for idx in 1..tbl_wrkn.count loop
               tbl_wrkn(idx).price := 0;
	    end loop;
            open csr_material_price;
            loop
               fetch csr_material_price into rcd_material_price;
               if csr_material_price%notfound then
                  exit;
               end if;
               for idx in 1..tbl_wrkn.count loop
                  if rcd_material_price.str_yyyypp <= tbl_wrkn(idx).yyyypp and
                     rcd_material_price.end_yyyypp >= tbl_wrkn(idx).yyyypp then
                     tbl_wrkn(idx).price := rcd_material_price.material_price;
                  end if;
               end loop;
            end loop;
            close csr_material_price;
            var_material_save := rcd_fcst_load_detail.material_code;
         end if;

         /*-*/
         /* Retrieve the detail price and calculate the gsv
         /*-*/
         rcd_fcst_load_detail.fcst_prc := 0;
         for idx in 1..tbl_wrkn.count loop
            if tbl_wrkn(idx).yyyypp = rcd_fcst_load_detail.fcst_yyyypp then
               rcd_fcst_load_detail.fcst_prc := tbl_wrkn(idx).price;
               exit;
            end if;
	 end loop;
         rcd_fcst_load_detail.fcst_gsv := rcd_fcst_load_detail.fcst_qty * rcd_fcst_load_detail.fcst_prc;

         /*-*/
         /* Set the forecast load detail
         /*-*/
         rcd_fcst_load_detail.err_message := null;

         /*-*/
         /* Validate the forecast material
         /*-*/
         if rcd_fcst_load_detail.material_sts_code = '*NONE' then
            if rcd_fcst_load_detail.err_message is null then
               rcd_fcst_load_detail.err_message := 'Material ('||rcd_fcst_load_detail.material_code||')';
            end if;
            rcd_fcst_load_detail.err_message := rcd_fcst_load_detail.err_message||' - does not exist in CLIO';
            var_errors := true;
         end if;
         if rcd_fcst_load_detail.material_sts_code != 'ACTIVE' then
            if rcd_fcst_load_detail.err_message is null then
               rcd_fcst_load_detail.err_message := 'Material ('||rcd_fcst_load_detail.material_code||')';
            end if;
            rcd_fcst_load_detail.err_message := rcd_fcst_load_detail.err_message||' - is not active in CLIO';
            var_errors := true;
         end if;

         /*-*/
         /* Validate the forecast data
         /*-*/
         if rcd_fcst_load_detail.fcst_qty = 0 then
            if rcd_fcst_load_detail.err_message is null then
               rcd_fcst_load_detail.err_message := 'Material ('||rcd_fcst_load_detail.material_code||')';
            end if;
            rcd_fcst_load_detail.err_message := rcd_fcst_load_detail.err_message||' - does not have a forecast quantity';
            var_errors := true;
         end if;
         if rcd_fcst_load_detail.fcst_prc = 0 then
            if rcd_fcst_load_detail.err_message is null then
               rcd_fcst_load_detail.err_message := 'Material ('||rcd_fcst_load_detail.material_code||')';
            end if;
            rcd_fcst_load_detail.err_message := rcd_fcst_load_detail.err_message||' - does not have pricing data for this period';
            var_errors := true;
         end if;

         /*-*/
         /* Update the forecast load detail row
         /*-*/
         update fcst_load_detail
            set fcst_prc = rcd_fcst_load_detail.fcst_prc,
                fcst_gsv = rcd_fcst_load_detail.fcst_gsv,
                err_message = rcd_fcst_load_detail.err_message
          where load_identifier = rcd_fcst_load_detail.load_identifier
            and material_code = rcd_fcst_load_detail.material_code
            and plant_code = rcd_fcst_load_detail.plant_code
            and fcst_yyyymmdd = rcd_fcst_load_detail.fcst_yyyymmdd;

      end loop;
      close csr_fcst_load_detail;

      /*-*/
      /* Return the new forecast load header status
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
            var_string := xmlDom.getNodeValue(par_xml_node);
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

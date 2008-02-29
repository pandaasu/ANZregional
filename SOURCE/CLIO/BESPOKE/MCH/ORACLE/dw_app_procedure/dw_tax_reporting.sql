/*****************/
/* Package Types */
/*****************/
create or replace type dw_tax_reporting_table as table of varchar2(2000 char);
/

/******************/
/* Package Header */
/******************/
create or replace package dw_tax_reporting as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : clio
    Package : dw_tax_reporting
    Owner   : dw_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Dimensional Data Store - China Tax Reporting

    The package implements the China Tax Reporting functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/01   Steve Gregan   Created
    2008/02   Steve Gregan   Added gold tax file download
    2008/03   Steve Gregan   Added chinese UOM description to gold tax file download

   *******************************************************************************/

   /**/
   /* Public declarations
   /**/
   procedure stock_transfer(par_tax_01 in varchar2,
                            par_tax_02 in varchar2,
                            par_sup_plant in varchar2,
                            par_sup_locn in varchar2,
                            par_rcv_plant in varchar2,
                            par_gidate_01 in varchar2,
                            par_gidate_02 in varchar2);

   procedure sample_pricing(par_del_plant in varchar2,
                            par_pddate_01 in varchar2,
                            par_pddate_02 in varchar2,
                            par_ord_type in varchar2);

   function gold_tax_file(par_tax_01 in varchar2,
                          par_tax_02 in varchar2,
                          par_sup_plant in varchar2,
                          par_sup_locn in varchar2,
                          par_rcv_plant in varchar2,
                          par_gidate_01 in varchar2,
                          par_gidate_02 in varchar2) return dw_tax_reporting_table;

end dw_tax_reporting;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_tax_reporting as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /******************************************************/
   /* This procedure performs the stock transfer routine */
   /******************************************************/
   procedure stock_transfer(par_tax_01 in varchar2,
                            par_tax_02 in varchar2,
                            par_sup_plant in varchar2,
                            par_sup_locn in varchar2,
                            par_rcv_plant in varchar2,
                            par_gidate_01 in varchar2,
                            par_gidate_02 in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_fidx number;
      var_tidx number;
      var_query varchar2(32767 char);
      var_wrk_string varchar2(4000 char);
      var_row_count number;
      var_tax_01 varchar2(256 char);
      var_tax_02 varchar2(256 char);
      var_sup_plant varchar2(256 char);
      var_sup_locn varchar2(256 char);
      var_rcv_plant varchar2(256 char);
      var_gidate_01 varchar2(256 char);
      var_gidate_02 varchar2(256 char);
      type typ_record is record(qry_ord_number varchar2(256 char),
                                qry_ord_line varchar2(256 char),
                                qry_gi_date date,
                                qry_sup_plant varchar2(256 char),
                                qry_sup_locn varchar2(256 char),
                                qry_rcv_plant varchar2(256 char),
                                qry_matl_code varchar2(256 char),
                                qry_matl_desc varchar2(256 char),
                                qry_ord_qty number,
                                qry_ord_uom varchar2(256 char),
                                qry_dsp_price number,
                                qry_dsp_value number,
                                qry_tax_rate number,
                                qry_tax_value number,
                                qry_tot_value number);
      type typ_table is table of typ_record index by binary_integer;
      tbl_report typ_table;
      type typ_cursor is ref cursor;
      csr_report typ_cursor;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Load the parameter values
      /*-*/
      var_tax_01 := par_tax_01;
      var_tax_02 := par_tax_02;
      /*-*/
      var_found := false;
      var_fidx := 0;
      var_tidx := 0;
      for idx in 1..length(par_sup_plant) loop
         if substr(par_sup_plant,idx,1) != ',' then
            if var_found = false then
               var_found := true; 
               var_fidx := idx;
            end if;
            var_tidx := idx;
         end if;
      end loop;
      var_sup_plant := substr(par_sup_plant,var_fidx,(var_tidx-var_fidx)+1);
      var_sup_plant := replace(var_sup_plant,',',''',''');
      /*-*/
      var_found := false;
      var_fidx := 0;
      var_tidx := 0;
      for idx in 1..length(par_sup_locn) loop
         if substr(par_sup_locn,idx,1) != ',' then
            if var_found = false then
               var_found := true; 
               var_fidx := idx;
            end if;
            var_tidx := idx;
         end if;
      end loop;
      var_sup_locn := substr(par_sup_locn,var_fidx,(var_tidx-var_fidx)+1);
      var_sup_locn := replace(var_sup_locn,',',''',''');
      /*-*/
      var_found := false;
      var_fidx := 0;
      var_tidx := 0;
      for idx in 1..length(par_rcv_plant) loop
         if substr(par_rcv_plant,idx,1) != ',' then
            if var_found = false then
               var_found := true; 
               var_fidx := idx;
            end if;
            var_tidx := idx;
         end if;
      end loop;
      var_rcv_plant := substr(par_rcv_plant,var_fidx,(var_tidx-var_fidx)+1);
      var_rcv_plant := replace(var_rcv_plant,',',''',''');
      /*-*/
      var_gidate_01 := par_gidate_01;
      var_gidate_02 := par_gidate_02;

      /*-*/
      /* Load the query statement
      /*-*/
      var_query := 'select *
                      from (select t01.vbeln as qry_ord_number,
                                   lads_trim_code(t01.posnr) as qry_ord_line,
                                   lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') as qry_gi_date,
                                   t01.werks as qry_sup_plant,
                                   t01.lgort as qry_sup_locn,
                                   t02.werks2 as qry_rcv_plant,
                                   lads_trim_code(t01.matnr) as qry_matl_code,
                                   nvl(t09.material_desc,t01.arktx) as qry_matl_desc,
                                   t01.lfimg as qry_ord_qty,
                                   t01.vrkme as qry_ord_uom,
                                   t05.kbetr as qry_dsp_price,
                                   t05.kbetr * decode(t01.vrkme, ''EA'', nvl(lads_to_number(t01.lfimg),0)*nvl(cs_each,1),
                                                                 ''SB'', nvl(lads_to_number(t01.lfimg),0)/nvl(sb_each,1)*nvl(cs_each,1),
                                                                 ''PCE'', nvl(lads_to_number(t01.lfimg),0)/nvl(pc_each,1)*nvl(cs_each,1),
                                                                 nvl(lads_to_number(t01.lfimg),0)) as qry_dsp_value,
                                   decode(t04.taxm1, 0, 0,
                                                     1, 0.17,
                                                     2, 0.13,
                                                     0) as qry_tax_rate,
                                   t05.kbetr * decode(t01.vrkme, ''EA'', nvl(lads_to_number(t01.lfimg),0)*nvl(cs_each,1),
                                                                 ''SB'', nvl(lads_to_number(t01.lfimg),0)/nvl(sb_each,1)*nvl(cs_each,1),
                                                                 ''PCE'', nvl(lads_to_number(t01.lfimg),0)/nvl(pc_each,1)*nvl(cs_each,1),
                                                                 nvl(lads_to_number(t01.lfimg),0)) * decode(t04.taxm1, 0, 0,
                                                                                                                       1, 0.17,
                                                                                                                       2, 0.13,
                                                                                                                       0) as qry_tax_value,
                                   t05.kbetr * decode(t01.vrkme, ''EA'', nvl(lads_to_number(t01.lfimg),0)*nvl(cs_each,1),
                                                                 ''SB'', nvl(lads_to_number(t01.lfimg),0)/nvl(sb_each,1)*nvl(cs_each,1),
                                                                 ''PCE'', nvl(lads_to_number(t01.lfimg),0)/nvl(pc_each,1)*nvl(cs_each,1),
                                                                 nvl(lads_to_number(t01.lfimg),0)) * decode(t04.taxm1, 0, 1,
                                                                                                                       1, 1.17,
                                                                                                                       2, 1.13,
                                                                                                                       1) as qry_tot_value
                              from lads_del_det t01,
                                   lads_del_hdr t02,
                                   lads_del_tim t03,
                                   (select lads_trim_code(matnr) sap_material_code, 
                                           max(taxm1) taxm1 
                                      from lads_mat_tax
                                     where aland = ''CN''
                                       and taty1 = ''MWST''
                                     group by lads_trim_code(matnr)) t04,
                                   (select lads_trim_code(t11.matnr) sap_material_code,
                                           lads_to_date(t11.datab,''yyyymmdd'') valid_from,
                                           lads_to_date(t11.datbi,''yyyymmdd'') valid_to,
                                           t12.kbetr
                                      from lads_prc_lst_hdr t11,
                                           lads_prc_lst_det t12
                                      where t11.vakey = t12.vakey
                                        and t11.kschl = t12.kschl
                                        and t11.datab = t12.datab
                                        and t11.knumh = t12.knumh
                                        and t11.vkorg in (''135'',''234'')
                                        and t11.kschl = ''ZCD0''
                                        and t12.konwa = ''CNY''
                                        and t12.kpein = 1
                                        and t12.kmein = ''EA''
                                        and t11.matnr is not null) t05,
                                    (select ltrim(t21.matnr,''0'') as matnr,
                                            max(round((1/ t21.umrez) * t21.umren)) as cs_each
                                       from lads_mat_uom t21
                                      where t21.meinh = ''CS''
                                      group by ltrim(t21.matnr,''0'')) t06,
                                    (select ltrim(t31.matnr,''0'') as matnr,
                                            max(round((1/ t31.umrez) * t31.umren)) as sb_each
                                       from lads_mat_uom t31
                                      where t31.meinh = ''SB''
                                      group by ltrim(t31.matnr,''0'')) t07,
                                    (select ltrim(t41.matnr,''0'') as matnr,
                                            max(round((1/ t41.umrez) * t41.umren)) as pc_each
                                       from lads_mat_uom t41
                                      where t41.meinh = ''PCE''
                                      group by ltrim(t41.matnr,''0'')) t08,
                                    (select lads_trim_code(matnr) as sap_material_code,
                                            decode(max(mkt_text),null,max(sls_text),max(mkt_text)) as material_desc
                                       from (select t51.matnr,
                                                    t51.maktx as sls_text,
                                                    null as mkt_text
                                               from lads_mat_mkt t51
                                              where t51.spras_iso = ''ZH''
                                              union all
                                             select t51.matnr,
                                                    null as sls_txt,
                                                    substr(max(t52.tdline),1,40) as mkt_text
                                               from lads_mat_txh t51,
                                                    lads_mat_txl t52
                                              where t51.matnr = t52.matnr(+)
                                                and t51.txhseq = t52.txhseq(+)
                                                and trim(substr(t51.tdname,19,6)) = ''137 10''
                                                and t51.tdobject = ''MVKE''
                                                and t52.txlseq = 1
                                                and t51.spras_iso = ''ZH''
                                              group by t51.matnr)
                                      group by matnr) t09
                              where t01.vbeln = t02.vbeln(+)
                                and (t01.hievw is null or t01.hievw = ''5'')
                                and t02.lads_status = ''1''
                                and t02.lfart = ''ZNL''
                                and t02.vbeln = t03.vbeln(+)
                                and ''006'' = t03.qualf(+)
                                and lads_trim_code(t01.matnr) = t04.sap_material_code
                                and t01.lfimg <> 0
                                and t04.taxm1 >= ''<TAX01>'' and taxm1 <= ''<TAX02>''
                                and upper(t01.werks) in (''<SUPPLANT>'')
                                and upper(t01.lgort) in (''<SUPLOCN>'')
                                and upper(t02.werks2) in (''<RCVPLANT>'')
                                and lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') >= to_date(''<GIDATE01>'', ''yyyymmdd'')
                                and lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') <= to_date(''<GIDATE02>'', ''yyyymmdd'')
                                and lads_trim_code(t01.matnr) = t05.sap_material_code
                                and (lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') >= t05.valid_from or t05.valid_from is null)
                                and (lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') <= t05.valid_to or t05.valid_to is null)         
                                and lads_trim_code(t01.matnr) = t06.matnr(+)
                                and lads_trim_code(t01.matnr) = t07.matnr(+)
                                and lads_trim_code(t01.matnr) = t08.matnr(+)
                                and lads_trim_code(t01.matnr) = t09.sap_material_code(+)
                              union all   
                             select t01.vbeln as qry_ord_number,
                                    lads_trim_code(t01.posnr) as qry_ord_line,
                                    lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') as qry_gi_date,
                                    t01.werks as qry_sup_plant,
                                    t01.lgort as qry_sup_locn,
                                    t02.werks2 as qry_rcv_plant,
                                    lads_trim_code(t01.matnr) as qry_matl_code,
                                    nvl(t09.material_desc,t01.arktx) as qry_matl_desc,
                                    t01.lfimg as qry_ord_qty,
                                    t01.vrkme as qry_ord_uom,
                                    null as qry_dsp_price,
                                    null as qry_dsp_value,
                                    decode(t04.taxm1, 0, 0,
                                                      1, 0.17,
                                                      2, 0.13,
                                                      0) as qry_tax_rate,
                                    null as qry_tax_value,
                                    null as qry_tot_value
                               from lads_del_det t01,
                                    lads_del_hdr t02,
                                    lads_del_tim t03,
                                    (select lads_trim_code(matnr) sap_material_code, 
                                            max(taxm1) taxm1 
                                       from lads_mat_tax
                                      where aland = ''CN''
                                        and taty1 = ''MWST''
                                      group by lads_trim_code(matnr)) t04,
                                    (select lads_trim_code(matnr) as sap_material_code,
                                            decode(max(mkt_text),null,max(sls_text),max(mkt_text)) as material_desc
                                       from (select t51.matnr,
                                                    t51.maktx as sls_text,
                                                    null as mkt_text
                                               from lads_mat_mkt t51
                                              where t51.spras_iso = ''ZH''
                                              union all
                                             select t51.matnr,
                                                    null as sls_txt,
                                                    substr(max(t52.tdline),1,40) as mkt_text
                                               from lads_mat_txh t51,
                                                    lads_mat_txl t52
                                              where t51.matnr = t52.matnr(+)
                                                and t51.txhseq = t52.txhseq(+)
                                                and trim(substr(t51.tdname,19,6)) = ''137 10''
                                                and t51.tdobject = ''MVKE''
                                                and t52.txlseq = 1
                                                and t51.spras_iso = ''ZH''
                                              group by t51.matnr)
                                      group by matnr) t09
                              where t01.vbeln = t02.vbeln(+)
                                and (t01.hievw is null or t01.hievw = ''5'')
                                and t02.lads_status = ''1''
                                and t02.lfart = ''ZNL''
                                and t02.vbeln = t03.vbeln(+)
                                and ''006'' = t03.qualf(+)
                                and lads_trim_code(t01.matnr) = t04.sap_material_code
                                and t01.lfimg <> 0
                                and t04.taxm1 >= ''<TAX01>'' and taxm1 <= ''<TAX02>''
                                and upper(t01.werks) in ('' <SUPPLANT>'')
                                and upper(t01.lgort) in (''<SUPLOCN>'')
                                and upper(t02.werks2) in (''<RCVPLANT>'')
                                and lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') >= to_date(''<GIDATE01>'', ''yyyymmdd'')
                                and lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') <= to_date(''<GIDATE02>'', ''yyyymmdd'')
                                and lads_trim_code(t01.matnr) = t09.sap_material_code (+)
                                and not exists (select t12.kbetr
                                                  from lads_prc_lst_hdr t11,
                                                       lads_prc_lst_det t12
                                                 where t11.vakey = t12.vakey
                                                   and t11.kschl = t12.kschl
                                                   and t11.datab = t12.datab
                                                   and t11.knumh = t12.knumh
                                                   and t11.vkorg in (''135'',''234'')
                                                   and t11.kschl = ''ZCD0''
                                                   and t12.konwa = ''CNY''
                                                   and t12.kpein = 1
                                                   and t12.kmein = ''EA''
                                                   and t11.matnr is not null
                                                   and lads_trim_code(t01.matnr) = lads_trim_code(t11.matnr)
                                                   and (lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') >= lads_to_date(t11.datab,''yyyymmdd'') or lads_to_date(t11.datab,''yyyymmdd'') is null)
                                                   and (lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') <= lads_to_date(t11.datbi,''yyyymmdd'') or lads_to_date(t11.datbi,''yyyymmdd'') is null)))
                     order by qry_sup_plant,
                              qry_sup_locn,
                              qry_rcv_plant,
                              qry_gi_date,
                              qry_tax_rate';
      var_query := replace(var_query,'<TAX01>',var_tax_01);
      var_query := replace(var_query,'<TAX02>',var_tax_02);
      var_query := replace(var_query,'<SUPPLANT>',var_sup_plant);
      var_query := replace(var_query,'<SUPLOCN>',var_sup_locn);
      var_query := replace(var_query,'<RCVPLANT>',var_rcv_plant);
      var_query := replace(var_query,'<GIDATE01>',var_gidate_01);
      var_query := replace(var_query,'<GIDATE02>',var_gidate_02);

      /*-*/
      /* Retrieve the report data in to the array
      /*-*/
      /*-*/
      tbl_report.delete;
      open csr_report for var_query;
      fetch csr_report bulk collect into tbl_report;
      close csr_report;

      /*-*/
      /* Add the selection sheet
      /*-*/
      lics_spreadsheet.addSheet('Selections',false);

      /*-*/
      /* Set the selection data
      /*-*/
      lics_spreadsheet.setRange('A1:A1',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Selections');
      lics_spreadsheet.setHeadingBorder('A1:A1',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      lics_spreadsheet.setRange('A2:A2',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Tax Classification Range: '||par_tax_01||' to '||par_tax_02);
      lics_spreadsheet.setRange('A3:A3',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Supply Plants: '||par_sup_plant);
      lics_spreadsheet.setRange('A4:A4',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Supply Storage Locations: '||par_sup_locn);
      lics_spreadsheet.setRange('A5:A5',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Receiving Plants: '||par_rcv_plant);
      lics_spreadsheet.setRange('A6:A6',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Goods Issued Date Range: '||par_gidate_01||' to '||par_gidate_02);
      lics_spreadsheet.setRangeBorder('A2:A6',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);

      /*-*/
      /* Add the report sheet
      /*-*/
      lics_spreadsheet.addSheet('Report',false);

      /*-*/
      /* Set the sheet heading
      /*-*/
      lics_spreadsheet.setRange('A1:A1','A1:O1',lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Stock Transfer Tax Report');

      /*-*/
      /* Set the report heading
      /*-*/
      lics_spreadsheet.setRange('A2:A2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'ODN No');
      lics_spreadsheet.setRange('B2:B2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Item');
      lics_spreadsheet.setRange('C2:C2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'GI date');
      lics_spreadsheet.setRange('D2:D2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'S_Plant');
      lics_spreadsheet.setRange('E2:E2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'S_Location');
      lics_spreadsheet.setRange('F2:F2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'R_Plant');
      lics_spreadsheet.setRange('G2:G2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Material No');
      lics_spreadsheet.setRange('H2:H2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Material Decription');
      lics_spreadsheet.setRange('I2:I2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'ODN Qty');
      lics_spreadsheet.setRange('J2:J2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'UOM');
      lics_spreadsheet.setRange('K2:K2',null,lics_spreadsheet.TYPE_HEADING_HI,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Dispatch Price');
      lics_spreadsheet.setRange('L2:L2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Value');
      lics_spreadsheet.setRange('M2:M2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Tax Rate');
      lics_spreadsheet.setRange('N2:N2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Tax Amount');
      lics_spreadsheet.setRange('O2:O2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Total Amount');
      lics_spreadsheet.setHeadingBorder('A2:O2',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);

      /*-*/
      /* Initialise the row count
      /*-*/
      var_row_count := 2;

      /*-*/
      /* Exit when no detail lines
      /*-*/
      if tbl_report.count = 0 then
         lics_spreadsheet.setRange('A3:A3','A3:O3',lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'NO DETAILS EXIST');
         lics_spreadsheet.setRangeBorder('A3:O3',lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         return;
      end if;

      /*-*/
      /* Set the cell freeze
      /*-*/
      lics_spreadsheet.setFreezeCell('A3');

      /*-*/
      /* Define the data row
      /*-*/
      var_row_count := 3;
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('E'||to_char(var_row_count,'FM999999990')||':E'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('F'||to_char(var_row_count,'FM999999990')||':F'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('G'||to_char(var_row_count,'FM999999990')||':G'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('K'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('I'||to_char(var_row_count,'FM999999990')||':I'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('J'||to_char(var_row_count,'FM999999990')||':J'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('K'||to_char(var_row_count,'FM999999990')||':K'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('L'||to_char(var_row_count,'FM999999990')||':L'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('M'||to_char(var_row_count,'FM999999990')||':M'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('N'||to_char(var_row_count,'FM999999990')||':N'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('O'||to_char(var_row_count,'FM999999990')||':O'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);

      /*-*/
      /* Define the borders
      /*-*/
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':O'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);

      /*-*/
      /* Define the copy
      /*-*/
      lics_spreadsheet.setRangeCopy('A'||to_char(var_row_count,'FM999999990')||':O'||to_char(var_row_count,'FM999999990'),tbl_report.count-1,lics_spreadsheet.COPY_DOWN);

      /*-*/
      /* Output the forecast material data
      /*-*/
      var_row_count := 2;

      /*-*/
      /* Retrieve the report data
      /*-*/
      /*-*/
      for idx in 1..tbl_report.count loop

         /*-*/
         /* Output the report line
         /*-*/
         var_row_count := var_row_count + 1;
         var_wrk_string := tbl_report(idx).qry_ord_number||chr(9)||
                           tbl_report(idx).qry_ord_line||chr(9)||
                           tbl_report(idx).qry_gi_date||chr(9)||
                           tbl_report(idx).qry_sup_plant||chr(9)||
                           tbl_report(idx).qry_sup_plant||chr(9)||
                           tbl_report(idx).qry_rcv_plant||chr(9)||
                           tbl_report(idx).qry_matl_code||chr(9)||
                           tbl_report(idx).qry_matl_desc||chr(9)||
                           tbl_report(idx).qry_ord_qty||chr(9)||
                           tbl_report(idx).qry_ord_uom||chr(9)||
                           tbl_report(idx).qry_dsp_price||chr(9)||
                           tbl_report(idx).qry_dsp_value||chr(9)||
                           to_char(tbl_report(idx).qry_tax_rate*100)||'%'||chr(9)||
                           tbl_report(idx).qry_tax_value||chr(9)||
                           tbl_report(idx).qry_tot_value;
         lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                        null,null,null,false,var_wrk_string);

      end loop;

      /*-*/
      /* Set the print settings
      /*-*/
      lics_spreadsheet.setPrintData('$1:$2','$A:$A',2,1,0);

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
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_TAX_REPORTING - STOCK TRANSFER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end stock_transfer;

   /******************************************************/
   /* This procedure performs the sample pricing routine */
   /******************************************************/
   procedure sample_pricing(par_del_plant in varchar2,
                            par_pddate_01 in varchar2,
                            par_pddate_02 in varchar2,
                            par_ord_type in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_fidx number;
      var_tidx number;
      var_query varchar2(32767 char);
      var_wrk_string varchar2(4000 char);
      var_row_count number;
      var_del_plant varchar2(256 char);
      var_pddate_01 varchar2(256 char);
      var_pddate_02 varchar2(256 char);
      var_ord_type varchar2(256 char);
      type typ_record is record(qry_region varchar2(256 char),
                                qry_cluster varchar2(256 char),
                                qry_area varchar2(256 char),
                                qry_sale_city varchar2(256 char),
                                qry_cust_code varchar2(256 char),
                                qry_cust_desc varchar2(256 char),
                                qry_del_plant_code varchar2(256 char),
                                qry_del_plant_desc varchar2(256 char),
                                qry_ord_type varchar2(256 char),
                                qry_ord_number varchar2(256 char),
                                qry_matl_code varchar2(256 char),
                                qry_matl_desc varchar2(256 char),
                                qry_brand_desc varchar2(256 char),
                                qry_pod_qty number,
                                qry_ord_uom varchar2(256 char),
                                qry_pod_base_qty number,
                                qry_dsp_price number,
                                qry_dsp_value number,
                                qry_tax_rate number);
      type typ_table is table of typ_record index by binary_integer;
      tbl_report typ_table;
      type typ_cursor is ref cursor;
      csr_report typ_cursor;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Load the parameter values
      /*-*/
      var_found := false;
      var_fidx := 0;
      var_tidx := 0;
      for idx in 1..length(par_del_plant) loop
         if substr(par_del_plant,idx,1) != ',' then
            if var_found = false then
               var_found := true; 
               var_fidx := idx;
            end if;
            var_tidx := idx;
         end if;
      end loop;
      var_del_plant := substr(par_del_plant,var_fidx,(var_tidx-var_fidx)+1);
      var_del_plant := replace(var_del_plant,',',''',''');
      /*-*/
      var_pddate_01 := par_pddate_01;
      var_pddate_02 := par_pddate_02;
      /*-*/
      var_found := false;
      var_fidx := 0;
      var_tidx := 0;
      for idx in 1..length(par_ord_type) loop
         if substr(par_ord_type,idx,1) != ',' then
            if var_found = false then
               var_found := true; 
               var_fidx := idx;
            end if;
            var_tidx := idx;
         end if;
      end loop;
      var_ord_type := substr(par_ord_type,var_fidx,(var_tidx-var_fidx)+1);
      var_ord_type := replace(var_ord_type,',',''',''');

      /*-*/
      /* Load the query statement
      /*-*/
      var_query := 'select *
                      from (select t03.cust_name_en_level_1 as qry_region,
                                   t03.cust_name_en_level_2 as qry_cluster,
                                   t03.cust_name_en_level_3 as qry_area,
                                   t03.cust_name_en_level_4 as qry_sale_city,
                                   t01.sap_sold_to_cust_code as qry_cust_code,
                                   t03.cust_name_en_level_5 as qry_cust_desc,
                                   t01.sap_plant_code as qry_del_plant_code,
                                   t05.plant_desc as qry_del_plant_desc,
                                   t01.sap_order_type_code as qry_ord_type,
                                   t01.ord_doc_num as qry_ord_number,
                                   t01.sap_material_code as qry_matl_code,
                                   t04.material_desc_en as qry_matl_desc,
                                   t04.brand_flag_desc as qry_brand_desc,
                                   t01.pod_qty as qry_pod_qty,
                                   t01.sap_ord_qty_uom_code as qry_ord_uom,
                                   t01.pod_base_uom_qty as qry_pod_base_qty,
                                   t07.dispatch_price as qry_dsp_price,
                                   t07.dispatch_price*t01.pod_base_uom_qty as qry_dsp_value,
                                   decode(t06.taxm1, 0, 0,
                                                     1, 0.17,
                                                     2, 0.13,
                                                     0) as qry_tax_rate
                              from order_fact t01,
                                   lads_sal_ord_gen t02,
                                   std_hier t03,
                                   material_dim t04,
                                   plant_dim t05,
                                   (select lads_trim_code(matnr) sap_material_code, 
                                           max(taxm1) taxm1 
                                      from lads_mat_tax
                                     where aland = ''CN''
                                       and taty1 = ''MWST''
                                     group by lads_trim_code(matnr)) t06,
                                   (select lads_trim_code(t11.matnr) sap_material_code,
                                           lads_to_date(t11.datab,''yyyymmdd'') valid_from,
                                           lads_to_date(t11.datbi,''yyyymmdd'') valid_to,
                                           t12.kbetr dispatch_price
                                      from lads_prc_lst_hdr t11,
                                           lads_prc_lst_det t12
                                     where t11.vakey = t12.vakey
                                       and t11.kschl = t12.kschl
                                       and t11.datab = t12.datab
                                       and t11.knumh = t12.knumh
                                       and t11.vkorg in (''135'',''234'')
                                       and t11.kschl = ''ZCD0''
                                       and t12.konwa = ''CNY''
                                       and t12.kpein = 1
                                       and t12.kmein = ''EA''
                                       and t11.matnr is not null) t07,
                                   lads_cus_pfr t08
                             where t01.sap_plant_code in (''<DELPLANT>'')
                               and trunc(t01.pod_date) >= trunc(to_date(''<PDDATE01>'', ''yyyymmdd''))
                               and trunc(t01.pod_date) <= trunc(to_date(''<PDDATE02>'', ''yyyymmdd''))
                               and t01.sap_sales_hdr_sales_org_code = ''135''
                               and t01.sap_sales_hdr_distbn_chnl_code = ''10''
                               and t01.sap_sales_hdr_division_code = ''51''
                               and t01.sap_order_type_code in (''<ORDTYPE>'')
                               and t01.ord_doc_num = t02.belnr
                               and t01.ord_doc_line_num = t02.posex
                               and decode(t01.sap_order_type_code, ''ZOR'', ''ZTAN'', '''') <> t02.pstyv
                               and t01.sap_material_code = t04.sap_material_code(+)
                               and t01.sap_plant_code = t05.sap_plant_code(+)
                               and t01.sap_material_code = t06.sap_material_code(+)
                               and t01.sap_material_code = t07.sap_material_code
                               and (t01.pod_date >= t07.valid_from  or t07.valid_from is null)
                               and (t01.pod_date <= t07.valid_to or t07.valid_to is null)
                               and ''00''||t01.sap_sold_to_cust_code = t08.kunnr(+)
                               and ''ZA'' = t08.parvw(+)
                               and lads_trim_code(t08.kunnr) = t03.sap_hier_cust_code(+)
                             union all

                            select t03.cust_name_en_level_1 as qry_region,
                                   t03.cust_name_en_level_2 as qry_cluster,
                                   t03.cust_name_en_level_3 as qry_area,
                                   t03.cust_name_en_level_4 as qry_sale_city,
                                   t01.sap_sold_to_cust_code as qry_cust_code,
                                   t03.cust_name_en_level_5 as qry_cust_desc,
                                   t01.sap_plant_code as qry_del_plant_code,
                                   t05.plant_desc as qry_del_plant_desc,
                                   t01.sap_order_type_code as qry_ord_type,
                                   t01.ord_doc_num as qry_ord_number,
                                   t01.sap_material_code as qry_matl_code,
                                   t04.material_desc_en as qry_matl_desc,
                                   t04.brand_flag_desc as qry_brand_desc,
                                   t01.pod_qty as qry_pod_qty,
                                   t01.sap_ord_qty_uom_code as qry_ord_uom,
                                   t01.pod_base_uom_qty as qry_pod_base_qty,
                                   null as qry_dsp_price,
                                   null as qry_dsp_value,
                                   decode(t06.taxm1, 0, 0,
                                                     1, 0.17,
                                                     2, 0.13,
                                                     0) as qry_tax_rate
                              from order_fact t01,
                                   lads_sal_ord_gen t02,
                                   std_hier t03,
                                   material_dim t04,
                                   plant_dim t05,
                                   (select lads_trim_code(matnr) sap_material_code, 
                                           max(taxm1) taxm1 
                                      from lads_mat_tax
                                     where aland = ''CN''
                                       and taty1 = ''MWST''
                                     group by lads_trim_code(matnr)) t06,
                                   lads_cus_pfr t08
                             where t01.sap_plant_code in (''<DELPLANT>'')
                               and trunc(t01.pod_date) >= trunc(to_date(''<PDDATE01>'', ''yyyymmdd''))
                               and trunc(t01.pod_date) <= trunc(to_date(''<PDDATE02>'', ''yyyymmdd''))
                               and t01.sap_sales_hdr_sales_org_code = ''135''
                               and t01.sap_sales_hdr_distbn_chnl_code = ''10'' 
                               and t01.sap_sales_hdr_division_code = ''51''
                               and t01.sap_order_type_code in (''<ORDTYPE>'')
                               and t01.ord_doc_num = t02.belnr
                               and t01.ord_doc_line_num = t02.posex
                               and decode(t01.sap_order_type_code, ''ZOR'', ''ZTAN'', '''') <> t02.pstyv
                               and t01.sap_material_code = t04.sap_material_code(+)
                               and t01.sap_plant_code = t05.sap_plant_code(+)
                               and t01.sap_material_code = t06.sap_material_code(+)
                               and ''00''||t01.sap_sold_to_cust_code = t08.kunnr(+)
                               and ''ZA'' = t08.parvw(+)
                               and lads_trim_code(t08.kunnr) = t03.sap_hier_cust_code(+)
                               and not exists (select t12.kbetr
                                                 from lads_prc_lst_hdr t11,
                                                      lads_prc_lst_det t12
                                                where t11.vakey = t12.vakey
                                                  and t11.kschl = t12.kschl
                                                  and t11.datab = t12.datab
                                                  and t11.knumh = t12.knumh
                                                  and t11.vkorg in (''135'',''234'')
                                                  and t11.kschl = ''ZCD0''
                                                  and t12.konwa = ''CNY''
                                                  and t12.kpein = 1
                                                  and t12.kmein = ''EA''
                                                  and t11.matnr is not null
                                                  and t01.sap_material_code = lads_trim_code(t11.matnr)
                                                  and (t01.pod_date >= lads_to_date(t11.datab,''yyyymmdd'') or lads_to_date(t11.datab,''yyyymmdd'') is null)
                                                  and (t01.pod_date <= lads_to_date(t11.datbi,''yyyymmdd'') or lads_to_date(t11.datbi,''yyyymmdd'') is null)))';
      var_query := replace(var_query,'<DELPLANT>',var_del_plant);
      var_query := replace(var_query,'<PDDATE01>',var_pddate_01);
      var_query := replace(var_query,'<PDDATE02>',var_pddate_02);
      var_query := replace(var_query,'<ORDTYPE>',var_ord_type);

      /*-*/
      /* Retrieve the report data in to the array
      /*-*/
      /*-*/
      tbl_report.delete;
      open csr_report for var_query;
      fetch csr_report bulk collect into tbl_report;
      close csr_report;

      /*-*/
      /* Add the selection sheet
      /*-*/
      lics_spreadsheet.addSheet('Selections',false);

      /*-*/
      /* Set the selection data
      /*-*/
      lics_spreadsheet.setRange('A1:A1',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Selections');
      lics_spreadsheet.setHeadingBorder('A1:A1',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      lics_spreadsheet.setRange('A2:A2',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Delivery Plants: '||par_del_plant);
      lics_spreadsheet.setRange('A3:A3',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'POD Date Range: '||par_pddate_01||' to '||par_pddate_02);
      lics_spreadsheet.setRange('A4:A4',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Order Types: '||par_ord_type);
      lics_spreadsheet.setRangeBorder('A2:A4',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);

      /*-*/
      /* Add the report sheet
      /*-*/
      lics_spreadsheet.addSheet('Report',false);

      /*-*/
      /* Set the sheet heading
      /*-*/
      lics_spreadsheet.setRange('A1:A1','A1:U1',lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Sample Pricing Tax Report');

      /*-*/
      /* Set the report heading
      /*-*/
      lics_spreadsheet.setRange('A2:A2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Region');
      lics_spreadsheet.setRange('B2:B2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Cluster');
      lics_spreadsheet.setRange('C2:C2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Area');
      lics_spreadsheet.setRange('D2:D2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Sales City');
      lics_spreadsheet.setRange('E2:E2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Customer');
      lics_spreadsheet.setRange('F2:F2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Customer Description');
      lics_spreadsheet.setRange('G2:G2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Delivery Plant');
      lics_spreadsheet.setRange('H2:H2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Plant Decription');
      lics_spreadsheet.setRange('I2:I2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Order Type');
      lics_spreadsheet.setRange('J2:J2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Sales Order');
      lics_spreadsheet.setRange('K2:K2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Material Code');
      lics_spreadsheet.setRange('L2:L2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Material Description');
      lics_spreadsheet.setRange('M2:M2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Brand');
      lics_spreadsheet.setRange('N2:N2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'QTY(sales) POD');
      lics_spreadsheet.setRange('O2:O2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'UOM(sales unit)');
      lics_spreadsheet.setRange('P2:P2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'QTY(base) POD');
      lics_spreadsheet.setRange('Q2:Q2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Dispatch price/EA per SO UOM');
      lics_spreadsheet.setRange('R2:R2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Amount');
      lics_spreadsheet.setRange('S2:S2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Tax rate');
      lics_spreadsheet.setRange('T2:T2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Cost Centre');
      lics_spreadsheet.setRange('U2:U2',null,lics_spreadsheet.TYPE_HEADING_07,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'I/O');
      lics_spreadsheet.setHeadingBorder('A2:R2',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);

      /*-*/
      /* Initialise the row count
      /*-*/
      var_row_count := 2;

      /*-*/
      /* Exit when no detail lines
      /*-*/
      if tbl_report.count = 0 then
         lics_spreadsheet.setRange('A3:A3','A3:U3',lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'NO DETAILS EXIST');
         lics_spreadsheet.setRangeBorder('A3:U3',lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         return;
      end if;

      /*-*/
      /* Set the cell freeze
      /*-*/
      lics_spreadsheet.setFreezeCell('A3');

      /*-*/
      /* Define the data row
      /*-*/
      var_row_count := 3;
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('E'||to_char(var_row_count,'FM999999990')||':E'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('F'||to_char(var_row_count,'FM999999990')||':F'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('G'||to_char(var_row_count,'FM999999990')||':G'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('K'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('I'||to_char(var_row_count,'FM999999990')||':I'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('J'||to_char(var_row_count,'FM999999990')||':J'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('K'||to_char(var_row_count,'FM999999990')||':K'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('L'||to_char(var_row_count,'FM999999990')||':L'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('M'||to_char(var_row_count,'FM999999990')||':M'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('N'||to_char(var_row_count,'FM999999990')||':N'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('O'||to_char(var_row_count,'FM999999990')||':O'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('P'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('S'||to_char(var_row_count,'FM999999990')||':S'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('T'||to_char(var_row_count,'FM999999990')||':T'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('U'||to_char(var_row_count,'FM999999990')||':U'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);

      /*-*/
      /* Define the borders
      /*-*/
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':U'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);

      /*-*/
      /* Define the copy
      /*-*/
      lics_spreadsheet.setRangeCopy('A'||to_char(var_row_count,'FM999999990')||':U'||to_char(var_row_count,'FM999999990'),tbl_report.count-1,lics_spreadsheet.COPY_DOWN);

      /*-*/
      /* Output the forecast material data
      /*-*/
      var_row_count := 2;

      /*-*/
      /* Retrieve the report data
      /*-*/
      /*-*/
      for idx in 1..tbl_report.count loop

         /*-*/
         /* Output the report line
         /*-*/
         var_row_count := var_row_count + 1;
         var_wrk_string := tbl_report(idx).qry_region||chr(9)||
                           tbl_report(idx).qry_cluster||chr(9)||
                           tbl_report(idx).qry_area||chr(9)||
                           tbl_report(idx).qry_sale_city||chr(9)||
                           tbl_report(idx).qry_cust_code||chr(9)||
                           tbl_report(idx).qry_cust_desc||chr(9)||
                           tbl_report(idx).qry_del_plant_code||chr(9)||
                           tbl_report(idx).qry_del_plant_desc||chr(9)||
                           tbl_report(idx).qry_ord_type||chr(9)||
                           tbl_report(idx).qry_ord_number||chr(9)||
                           tbl_report(idx).qry_matl_code||chr(9)||
                           tbl_report(idx).qry_matl_desc||chr(9)||
                           tbl_report(idx).qry_brand_desc||chr(9)||
                           tbl_report(idx).qry_pod_qty||chr(9)||
                           tbl_report(idx).qry_ord_uom||chr(9)||
                           tbl_report(idx).qry_pod_base_qty||chr(9)||
                           tbl_report(idx).qry_dsp_price||chr(9)||
                           tbl_report(idx).qry_dsp_value||chr(9)||
                           to_char(tbl_report(idx).qry_tax_rate*100)||'%'||chr(9)||chr(9);
         lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                        null,null,null,false,var_wrk_string);

      end loop;

      /*-*/
      /* Set the print settings
      /*-*/
      lics_spreadsheet.setPrintData('$1:$2','$A:$A',2,1,0);

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
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_TAX_REPORTING - SAMPLE PRICING - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sample_pricing;

   /****************************************************/
   /* This function performs the gold tax file routine */
   /****************************************************/
   function gold_tax_file(par_tax_01 in varchar2,
                          par_tax_02 in varchar2,
                          par_sup_plant in varchar2,
                          par_sup_locn in varchar2,
                          par_rcv_plant in varchar2,
                          par_gidate_01 in varchar2,
                          par_gidate_02 in varchar2) return dw_tax_reporting_table is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_fidx number;
      var_tidx number;
      var_query varchar2(32767 char);
      var_wrk_string varchar2(4000 char);
      var_hdr_idx number;
      var_hdr_ord_number varchar2(256 char);
      var_hdr_lin_count number;
      var_hdr_cust_name varchar2(256 char);
      var_hdr_tax_code varchar2(256 char);
      var_hdr_cust_addr varchar2(256 char);
      var_hdr_cust_bank varchar2(256 char);
      var_hdr_comment varchar2(256 char);
      var_row_count number;
      var_tax_01 varchar2(256 char);
      var_tax_02 varchar2(256 char);
      var_sup_plant varchar2(256 char);
      var_sup_locn varchar2(256 char);
      var_rcv_plant varchar2(256 char);
      var_gidate_01 varchar2(256 char);
      var_gidate_02 varchar2(256 char);
      sav_sup_plant varchar2(256 char);
      sav_rcv_plant varchar2(256 char);
      sav_tax_eye varchar2(256 char);
      var_vir_table dw_tax_reporting_table := dw_tax_reporting_table();
      type typ_record is record(qry_ord_number varchar2(256 char),
                                qry_ord_line varchar2(256 char),
                                qry_gi_date date,
                                qry_sup_plant varchar2(256 char),
                                qry_sup_locn varchar2(256 char),
                                qry_rcv_plant varchar2(256 char),
                                qry_matl_code varchar2(256 char),
                                qry_matl_desc varchar2(256 char),
                                qry_ord_qty number,
                                qry_ord_uom varchar2(256 char),
                                qry_dsp_price number,
                                qry_dsp_value number,
                                qry_tax_rate number,
                                qry_tax_value number,
                                qry_tot_value number,
                                qry_tax_eye varchar2(256 char),
                                qry_pack_frmt varchar2(256 char),
                                qry_cust_name varchar2(256 char),
                                qry_cust_addr varchar2(256 char),
                                qry_cust_bank varchar2(256 char),
                                qry_tax_code varchar2(256 char));
      type typ_table is table of typ_record index by binary_integer;
      tbl_report typ_table;
      type typ_work is table of varchar2(2000 char) index by binary_integer;
      tbl_work typ_work;
      type typ_cursor is ref cursor;
      csr_report typ_cursor;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Load the parameter values
      /*-*/
      var_tax_01 := par_tax_01;
      var_tax_02 := par_tax_02;
      /*-*/
      var_found := false;
      var_fidx := 0;
      var_tidx := 0;
      for idx in 1..length(par_sup_plant) loop
         if substr(par_sup_plant,idx,1) != ',' then
            if var_found = false then
               var_found := true; 
               var_fidx := idx;
            end if;
            var_tidx := idx;
         end if;
      end loop;
      var_sup_plant := substr(par_sup_plant,var_fidx,(var_tidx-var_fidx)+1);
      var_sup_plant := replace(var_sup_plant,',',''',''');
      /*-*/
      var_found := false;
      var_fidx := 0;
      var_tidx := 0;
      for idx in 1..length(par_sup_locn) loop
         if substr(par_sup_locn,idx,1) != ',' then
            if var_found = false then
               var_found := true; 
               var_fidx := idx;
            end if;
            var_tidx := idx;
         end if;
      end loop;
      var_sup_locn := substr(par_sup_locn,var_fidx,(var_tidx-var_fidx)+1);
      var_sup_locn := replace(var_sup_locn,',',''',''');
      /*-*/
      var_found := false;
      var_fidx := 0;
      var_tidx := 0;
      for idx in 1..length(par_rcv_plant) loop
         if substr(par_rcv_plant,idx,1) != ',' then
            if var_found = false then
               var_found := true; 
               var_fidx := idx;
            end if;
            var_tidx := idx;
         end if;
      end loop;
      var_rcv_plant := substr(par_rcv_plant,var_fidx,(var_tidx-var_fidx)+1);
      var_rcv_plant := replace(var_rcv_plant,',',''',''');
      /*-*/
      var_gidate_01 := par_gidate_01;
      var_gidate_02 := par_gidate_02;

      /*-*/
      /* Load the query statement
      /*-*/
      var_query := 'select *
                      from (select t01.vbeln as qry_ord_number,
                                   lads_trim_code(t01.posnr) as qry_ord_line,
                                   lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') as qry_gi_date,
                                   nvl(t01.werks,''NONE'') as qry_sup_plant,
                                   t01.lgort as qry_sup_locn,
                                   nvl(t02.werks2,''NONE'') as qry_rcv_plant,
                                   lads_trim_code(t01.matnr) as qry_matl_code,
                                   nvl(t09.material_desc,t01.arktx) as qry_matl_desc,
                                   t01.lfimg as qry_ord_qty,
                                  -- nvl((select dsv_value from table(lics_datastore.retrieve_value(''CHINA'',''CHINA_UOM'',t01.vrkme))),t01.vrkme) as qry_ord_uom,
                                   t01.vrkme as qry_ord_uom,
                                   t05.kbetr as qry_dsp_price,
                                   t05.kbetr * decode(t01.vrkme, ''EA'', nvl(lads_to_number(t01.lfimg),0)*nvl(cs_each,1),
                                                                 ''SB'', nvl(lads_to_number(t01.lfimg),0)/nvl(sb_each,1)*nvl(cs_each,1),
                                                                 ''PCE'', nvl(lads_to_number(t01.lfimg),0)/nvl(pc_each,1)*nvl(cs_each,1),
                                                                 nvl(lads_to_number(t01.lfimg),0)) as qry_dsp_value,
                                   decode(t04.taxm1, 0, 0,
                                                     1, 0.17,
                                                     2, 0.13,
                                                     0) as qry_tax_rate,
                                   t05.kbetr * decode(t01.vrkme, ''EA'', nvl(lads_to_number(t01.lfimg),0)*nvl(cs_each,1),
                                                                 ''SB'', nvl(lads_to_number(t01.lfimg),0)/nvl(sb_each,1)*nvl(cs_each,1),
                                                                 ''PCE'', nvl(lads_to_number(t01.lfimg),0)/nvl(pc_each,1)*nvl(cs_each,1),
                                                                 nvl(lads_to_number(t01.lfimg),0)) * decode(t04.taxm1, 0, 0,
                                                                                                                       1, 0.17,
                                                                                                                       2, 0.13,
                                                                                                                       0) as qry_tax_value,
                                   t05.kbetr * decode(t01.vrkme, ''EA'', nvl(lads_to_number(t01.lfimg),0)*nvl(cs_each,1),
                                                                 ''SB'', nvl(lads_to_number(t01.lfimg),0)/nvl(sb_each,1)*nvl(cs_each,1),
                                                                 ''PCE'', nvl(lads_to_number(t01.lfimg),0)/nvl(pc_each,1)*nvl(cs_each,1),
                                                                 nvl(lads_to_number(t01.lfimg),0)) * decode(t04.taxm1, 0, 1,
                                                                                                                       1, 1.17,
                                                                                                                       2, 1.13,
                                                                                                                       1) as qry_tot_value,
                                   decode(trim(t10.sap_bus_sgmnt_code),''01'',''0303'',''05'',''0301'',''NONE'') as qry_tax_eye,
                                   decode(t10.sap_trad_unit_config_code,''000'',''1*1'',trim(t10.trad_unit_config_abbrd_desc)) as qry_pack_frmt,
                                   nvl(t11.cust_name,''UNKNOWN'') as qry_cust_name,
                                   nvl(t11.cust_addr,''UNKNOWN'') as qry_cust_addr,
                                   nvl(t11.cust_bank,''UNKNOWN'') as qry_cust_bank,
                                   nvl(t11.tax_code,''UNKNOWN'') as qry_tax_code
                              from lads_del_det t01,
                                   lads_del_hdr t02,
                                   lads_del_tim t03,
                                   (select lads_trim_code(matnr) sap_material_code, 
                                           max(taxm1) taxm1 
                                      from lads_mat_tax
                                     where aland = ''CN''
                                       and taty1 = ''MWST''
                                     group by lads_trim_code(matnr)) t04,
                                   (select lads_trim_code(t11.matnr) sap_material_code,
                                           lads_to_date(t11.datab,''yyyymmdd'') valid_from,
                                           lads_to_date(t11.datbi,''yyyymmdd'') valid_to,
                                           t12.kbetr
                                      from lads_prc_lst_hdr t11,
                                           lads_prc_lst_det t12
                                      where t11.vakey = t12.vakey
                                        and t11.kschl = t12.kschl
                                        and t11.datab = t12.datab
                                        and t11.knumh = t12.knumh
                                        and t11.vkorg in (''135'',''234'')
                                        and t11.kschl = ''ZCD0''
                                        and t12.konwa = ''CNY''
                                        and t12.kpein = 1
                                        and t12.kmein = ''EA''
                                        and t11.matnr is not null) t05,
                                    (select ltrim(t21.matnr,''0'') as matnr,
                                            max(round((1/ t21.umrez) * t21.umren)) as cs_each
                                       from lads_mat_uom t21
                                      where t21.meinh = ''CS''
                                      group by ltrim(t21.matnr,''0'')) t06,
                                    (select ltrim(t31.matnr,''0'') as matnr,
                                            max(round((1/ t31.umrez) * t31.umren)) as sb_each
                                       from lads_mat_uom t31
                                      where t31.meinh = ''SB''
                                      group by ltrim(t31.matnr,''0'')) t07,
                                    (select ltrim(t41.matnr,''0'') as matnr,
                                            max(round((1/ t41.umrez) * t41.umren)) as pc_each
                                       from lads_mat_uom t41
                                      where t41.meinh = ''PCE''
                                      group by ltrim(t41.matnr,''0'')) t08,
                                    (select lads_trim_code(matnr) as sap_material_code,
                                            decode(max(mkt_text),null,max(sls_text),max(mkt_text)) as material_desc
                                       from (select t51.matnr,
                                                    t51.maktx as sls_text,
                                                    null as mkt_text
                                               from lads_mat_mkt t51
                                              where t51.spras_iso = ''ZH''
                                              union all
                                             select t51.matnr,
                                                    null as sls_txt,
                                                    substr(max(t52.tdline),1,40) as mkt_text
                                               from lads_mat_txh t51,
                                                    lads_mat_txl t52
                                              where t51.matnr = t52.matnr(+)
                                                and t51.txhseq = t52.txhseq(+)
                                                and trim(substr(t51.tdname,19,6)) = ''137 10''
                                                and t51.tdobject = ''MVKE''
                                                and t52.txlseq = 1
                                                and t51.spras_iso = ''ZH''
                                              group by t51.matnr)
                                      group by matnr) t09,
                                    material_dim t10,
                                    china_tax_customer t11
                              where t01.vbeln = t02.vbeln(+)
                                and (t01.hievw is null or t01.hievw = ''5'')
                                and t02.lads_status = ''1''
                                and t02.lfart = ''ZNL''
                                and t02.vbeln = t03.vbeln(+)
                                and ''006'' = t03.qualf(+)
                                and lads_trim_code(t01.matnr) = t04.sap_material_code
                                and t01.lfimg <> 0
                                and t04.taxm1 >= ''<TAX01>'' and taxm1 <= ''<TAX02>''
                                and upper(t01.werks) in (''<SUPPLANT>'')
                                and upper(t01.lgort) in (''<SUPLOCN>'')
                                and upper(t02.werks2) in (''<RCVPLANT>'')
                                and lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') >= to_date(''<GIDATE01>'', ''yyyymmdd'')
                                and lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') <= to_date(''<GIDATE02>'', ''yyyymmdd'')
                                and lads_trim_code(t01.matnr) = t05.sap_material_code
                                and (lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') >= t05.valid_from or t05.valid_from is null)
                                and (lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') <= t05.valid_to or t05.valid_to is null)         
                                and lads_trim_code(t01.matnr) = t06.matnr(+)
                                and lads_trim_code(t01.matnr) = t07.matnr(+)
                                and lads_trim_code(t01.matnr) = t08.matnr(+)
                                and lads_trim_code(t01.matnr) = t09.sap_material_code(+)
                                and lads_trim_code(t01.matnr) = t10.sap_material_code(+)
                                and t02.werks2 = t11.cust_code(+)
                              union all  
                             select t01.vbeln as qry_ord_number,
                                    lads_trim_code(t01.posnr) as qry_ord_line,
                                    lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') as qry_gi_date,
                                    nvl(t01.werks,''NONE'') as qry_sup_plant,
                                    t01.lgort as qry_sup_locn,
                                    nvl(t02.werks2,''NONE'') as qry_rcv_plant,
                                    lads_trim_code(t01.matnr) as qry_matl_code,
                                    nvl(t09.material_desc,t01.arktx) as qry_matl_desc,
                                    t01.lfimg as qry_ord_qty,
                                 --   nvl((select dsv_value from table(lics_datastore.retrieve_value(''CHINA'',''CHINA_UOM'',t01.vrkme))),t01.vrkme) as qry_ord_uom,
                                    t01.vrkme as qry_ord_uom,
                                    null as qry_dsp_price,
                                    null as qry_dsp_value,
                                    decode(t04.taxm1, 0, 0,
                                                      1, 0.17,
                                                      2, 0.13,
                                                      0) as qry_tax_rate,
                                    null as qry_tax_value,
                                    null as qry_tot_value,
                                    decode(trim(t10.sap_bus_sgmnt_code),''01'',''0303'',''05'',''0301'',''NONE'') as qry_tax_eye,
                                    decode(t10.sap_trad_unit_config_code,''000'',''1*1'',trim(t10.trad_unit_config_abbrd_desc)) as qry_pack_frmt,
                                    nvl(t11.cust_name,''UNKNOWN'') as qry_cust_name,
                                    nvl(t11.cust_addr,''UNKNOWN'') as qry_cust_addr,
                                    nvl(t11.cust_bank,''UNKNOWN'') as qry_cust_bank,
                                    nvl(t11.tax_code,''UNKNOWN'') as qry_tax_code
                               from lads_del_det t01,
                                    lads_del_hdr t02,
                                    lads_del_tim t03,
                                    (select lads_trim_code(matnr) sap_material_code, 
                                            max(taxm1) taxm1 
                                       from lads_mat_tax
                                      where aland = ''CN''
                                        and taty1 = ''MWST''
                                      group by lads_trim_code(matnr)) t04,
                                    (select lads_trim_code(matnr) as sap_material_code,
                                            decode(max(mkt_text),null,max(sls_text),max(mkt_text)) as material_desc
                                       from (select t51.matnr,
                                                    t51.maktx as sls_text,
                                                    null as mkt_text
                                               from lads_mat_mkt t51
                                              where t51.spras_iso = ''ZH''
                                              union all
                                             select t51.matnr,
                                                    null as sls_txt,
                                                    substr(max(t52.tdline),1,40) as mkt_text
                                               from lads_mat_txh t51,
                                                    lads_mat_txl t52
                                              where t51.matnr = t52.matnr(+)
                                                and t51.txhseq = t52.txhseq(+)
                                                and trim(substr(t51.tdname,19,6)) = ''137 10''
                                                and t51.tdobject = ''MVKE''
                                                and t52.txlseq = 1
                                                and t51.spras_iso = ''ZH''
                                              group by t51.matnr)
                                      group by matnr) t09,
                                    material_dim t10,
                                    china_tax_customer t11
                              where t01.vbeln = t02.vbeln(+)
                                and (t01.hievw is null or t01.hievw = ''5'')
                                and t02.lads_status = ''1''
                                and t02.lfart = ''ZNL''
                                and t02.vbeln = t03.vbeln(+)
                                and ''006'' = t03.qualf(+)
                                and lads_trim_code(t01.matnr) = t04.sap_material_code
                                and t01.lfimg <> 0
                                and t04.taxm1 >= ''<TAX01>'' and taxm1 <= ''<TAX02>''
                                and upper(t01.werks) in ('' <SUPPLANT>'')
                                and upper(t01.lgort) in (''<SUPLOCN>'')
                                and upper(t02.werks2) in (''<RCVPLANT>'')
                                and lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') >= to_date(''<GIDATE01>'', ''yyyymmdd'')
                                and lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') <= to_date(''<GIDATE02>'', ''yyyymmdd'')
                                and lads_trim_code(t01.matnr) = t09.sap_material_code(+)
                                and lads_trim_code(t01.matnr) = t10.sap_material_code(+)
                                and t02.werks2 = t11.cust_code(+)
                                and not exists (select t12.kbetr
                                                  from lads_prc_lst_hdr t11,
                                                       lads_prc_lst_det t12
                                                 where t11.vakey = t12.vakey
                                                   and t11.kschl = t12.kschl
                                                   and t11.datab = t12.datab
                                                   and t11.knumh = t12.knumh
                                                   and t11.vkorg in (''135'',''234'')
                                                   and t11.kschl = ''ZCD0''
                                                   and t12.konwa = ''CNY''
                                                   and t12.kpein = 1
                                                   and t12.kmein = ''EA''
                                                   and t11.matnr is not null
                                                   and lads_trim_code(t01.matnr) = lads_trim_code(t11.matnr)
                                                   and (lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') >= lads_to_date(t11.datab,''yyyymmdd'') or lads_to_date(t11.datab,''yyyymmdd'') is null)
                                                   and (lads_to_date(ltrim(t03.isdd,''0''),''yyyymmdd'') <= lads_to_date(t11.datbi,''yyyymmdd'') or lads_to_date(t11.datbi,''yyyymmdd'') is null)))
                     order by qry_sup_plant,
                              qry_rcv_plant,
                              qry_tax_eye,
                              qry_ord_number,
                              qry_ord_line';
      var_query := replace(var_query,'<TAX01>',var_tax_01);
      var_query := replace(var_query,'<TAX02>',var_tax_02);
      var_query := replace(var_query,'<SUPPLANT>',var_sup_plant);
      var_query := replace(var_query,'<SUPLOCN>',var_sup_locn);
      var_query := replace(var_query,'<RCVPLANT>',var_rcv_plant);
      var_query := replace(var_query,'<GIDATE01>',var_gidate_01);
      var_query := replace(var_query,'<GIDATE02>',var_gidate_02);

      /*-*/
      /* Retrieve the report data in to the array
      /*-*/
      /*-*/
      tbl_report.delete;
      open csr_report for var_query;
      fetch csr_report bulk collect into tbl_report;
      close csr_report;

      /*-*/
      /* Clear the work array
      /*-*/
      tbl_work.delete;

      /*-*/
      /* Output the title data when required
      /*-*/
      if tbl_report.count != 0 then
         var_wrk_string := '"' || lics_setting_configuration.retrieve_setting('TAX_REPORTING','GOLD_TAX_TITLE01') || '"';
         var_wrk_string := var_wrk_string || ' "' || lics_setting_configuration.retrieve_setting('TAX_REPORTING','GOLD_TAX_TITLE02') || '"';
         var_wrk_string := var_wrk_string || ' "' || to_char(lics_time.get_tz_time(sysdate,'Asia/Shanghai'),'yyyymmddhh24miss') || '"';
         tbl_work(tbl_work.count+1) := var_wrk_string;
      end if;

      /*-*/
      /* Retrieve the report data
      /*-*/
      /*-*/
      sav_sup_plant := null;
      sav_rcv_plant := null;
      sav_tax_eye := null;
      for idx in 1..tbl_report.count loop

         /*-*/
         /* Change in group
         /*-*/
         if sav_sup_plant is null or
            sav_sup_plant != tbl_report(idx).qry_sup_plant or
            sav_rcv_plant != tbl_report(idx).qry_rcv_plant or
            sav_tax_eye != tbl_report(idx).qry_tax_eye then

            /*-*/
            /* Update the previous group header when required
            /*-*/
            if not(sav_sup_plant is null) then

               /*-*/
               /* Output the heading data
               /*-*/
               var_wrk_string := '"' || var_hdr_ord_number || '"';
               var_wrk_string := var_wrk_string || ' ' || to_char(var_hdr_lin_count);
               var_wrk_string := var_wrk_string || ' "' || var_hdr_cust_name || '"';
               var_wrk_string := var_wrk_string || ' "' || var_hdr_tax_code || '"';
               var_wrk_string := var_wrk_string || ' "' || var_hdr_cust_addr || '"';
               var_wrk_string := var_wrk_string || ' "' || var_hdr_cust_bank || '"';
               var_wrk_string := var_wrk_string || ' "' || var_hdr_comment || '"';
               tbl_work(var_hdr_idx) := var_wrk_string;

            end if;

            /*-*/
            /* Initialise the new group
            /*-*/
            sav_sup_plant := tbl_report(idx).qry_sup_plant;
            sav_rcv_plant := tbl_report(idx).qry_rcv_plant;
            sav_tax_eye := tbl_report(idx).qry_tax_eye;
            tbl_work(tbl_work.count+1) := '*HEADER_ROW';
            var_hdr_idx := tbl_work.count;
            var_hdr_ord_number := tbl_report(idx).qry_ord_number;
            var_hdr_lin_count := 0;
            var_hdr_cust_name := tbl_report(idx).qry_cust_name;
            var_hdr_tax_code := tbl_report(idx).qry_tax_code;
            var_hdr_cust_addr := tbl_report(idx).qry_cust_addr;
            var_hdr_cust_bank := tbl_report(idx).qry_cust_bank;
            var_hdr_comment := null;

         end if;

         /*-*/
         /* Output the detail data
         /*-*/
         var_wrk_string := '"' || tbl_report(idx).qry_matl_desc || '"';
         var_wrk_string := var_wrk_string || ' "' || tbl_report(idx).qry_ord_uom || '"';
         var_wrk_string := var_wrk_string || ' "' || tbl_report(idx).qry_pack_frmt || '"';
         var_wrk_string := var_wrk_string || ' ' || to_char(nvl(tbl_report(idx).qry_ord_qty,0));
         var_wrk_string := var_wrk_string || ' ' || to_char(nvl(tbl_report(idx).qry_dsp_value,0));
         var_wrk_string := var_wrk_string || ' ' || to_char(nvl(tbl_report(idx).qry_tax_rate,0));
         if tbl_report(idx).qry_tax_eye = '0301' and tbl_report(idx).qry_tax_rate = 0.17 then
            var_wrk_string := var_wrk_string || ' "0309"';
         else
            var_wrk_string := var_wrk_string || ' "' || tbl_report(idx).qry_tax_eye || '"';
         end if;
         var_wrk_string := var_wrk_string || ' 0';
         tbl_work(tbl_work.count+1) := var_wrk_string;

         /*-*/
         /* Set the heading comment and line count
         /*-*/
         /*-*/
         if var_hdr_lin_count > 0 then
            if var_hdr_comment is null then
               var_hdr_comment := var_hdr_comment || tbl_report(idx).qry_ord_number;
            else
               if length(var_hdr_comment || ' ' || tbl_report(idx).qry_ord_number) <= 160 then
                  var_hdr_comment := var_hdr_comment || ' ' || tbl_report(idx).qry_ord_number;
               end if;
            end if;
         end if;
         var_hdr_lin_count := var_hdr_lin_count + 1;

      end loop;

      /*-*/
      /* Update the previous group header when required
      /*-*/
      if not(sav_sup_plant is null) then

         /*-*/
         /* Output the heading data
         /*-*/
         var_wrk_string := '"' || var_hdr_ord_number || '"';
         var_wrk_string := var_wrk_string || ' ' || to_char(var_hdr_lin_count);
         var_wrk_string := var_wrk_string || ' "' || var_hdr_cust_name || '"';
         var_wrk_string := var_wrk_string || ' "' || var_hdr_tax_code || '"';
         var_wrk_string := var_wrk_string || ' "' || var_hdr_cust_addr || '"';
         var_wrk_string := var_wrk_string || ' "' || var_hdr_cust_bank || '"';
         var_wrk_string := var_wrk_string || ' "' || var_hdr_comment || '"';
         tbl_work(var_hdr_idx) := var_wrk_string;

      end if;

      /*-*/
      /* Output the file data
      /*-*/
      for idx in 1..tbl_work.count loop
         var_vir_table.extend;
         var_vir_table(var_vir_table.last) := tbl_work(idx);
      end loop;
      return var_vir_table;

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
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_TAX_REPORTING - GOLD_TAX_FILE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end gold_tax_file;

end dw_tax_reporting;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_tax_reporting for dw_app.dw_tax_reporting;
grant execute on dw_tax_reporting to public;
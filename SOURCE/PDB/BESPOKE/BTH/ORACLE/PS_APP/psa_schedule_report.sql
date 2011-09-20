--
-- PSA_SCHEDULE_REPORT  (Package) 
--
CREATE OR REPLACE PACKAGE PS_APP.PSA_SCHEDULE_REPORT AS

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_schedule_report
    Owner   : ps_app

    Description
    -----------
    Production Scheduling Report

    This package contain the PSA report functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/08   Ben Halicki   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function select_data return psa_xml_type pipelined;
   function report_data(par_version_code in number) return psa_xls_type pipelined;

END PSA_SCHEDULE_REPORT;
/


GRANT EXECUTE ON PS_APP.PSA_SCHEDULE_REPORT TO LICS_APP;


--
-- PSA_SCHEDULE_REPORT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY PS_APP.psa_schedule_report as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***************************************************/
   /* This procedure performs the select data routine */
   /***************************************************/
   function select_data return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_ods_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_fil_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_version is
        select t01.sched_vrsn as sched_vrsn, 
               to_char(t01.creatn_datime,'yyyymmdd') as creatn_datime
          from pps_plnd_prdn_vrsn t01
         where rownum < 20
        order by t01.sched_vrsn desc;
      rcd_version csr_version%rowtype;
          
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Clear the message data
      /*-*/
      psa_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PSA_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_ods_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_ods_request,'@ACTION'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SLTRPT' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(psa_xml_object('<?xml version="1.0" encoding="UTF-8"?><PSA_RESPONSE>'));

      /*-*/
      /* Pipe the company data XML
      /*-*/
      open csr_version;
      loop
         fetch csr_version into rcd_version;
         if csr_version%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<VERCDE VERCDE="'||psa_to_xml(rcd_version.sched_vrsn)||'" VERNAM="'||psa_to_xml('('||rcd_version.sched_vrsn||') '||rcd_version.sched_vrsn)||'"/>'));
      end loop;
      close csr_version;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(psa_xml_object('</PSA_RESPONSE>'));

      /*-*/
      /* Return
      /*-*/
      return;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_SCHEDULE_REPORT - SELECT_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_data;

   /***************************************************/
   /* This procedure performs the report data routine */
   /***************************************************/
   function report_data(par_version_code in number) return psa_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_output    varchar2(2000 char);
      var_rep_date  varchar2(100 char);
      
      type rcd_head is record(head_code  varchar2(10),
                              head_desc  varchar2(32),
                              head_style varchar2(5),
                              head_totl  number);
      type typ_head is table of rcd_head index by binary_integer;
      tbl_head typ_head;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_period is
        select rownum, 
               t01.* from (select distinct t02.mars_ppww, 
                                           t02.period_num, 
                                           t02.week_num, 
                                           t02.year_num 
                             from pps_plnd_prdn_detl t01,
                                   (select 'P' || period_num || 'W' || substr(mars_week,7,1) as mars_ppww, 
                                            calendar_date, 
                                            period_num, 
                                            substr(mars_week,7,1) as week_num, 
                                            year_num from mars_date) t02
                             where trunc(t01.start_datime)=t02.calendar_date
                               and t01.sched_vrsn=par_version_code
                          order by t02.period_num, 
                                   t02.week_num, 
                                   t02.year_num) t01;
      rcd_period csr_period%rowtype;

      cursor csr_report is
            select decode (grouping(t01.trad_unit_code),1, 'TOTAL', ltrim(t01.trad_unit_code,'0')) as tdu_material_code,
                   decode (grouping(t01.trad_unit_code),1, 'Y','N') as is_total,
                   t04.bds_material_desc_en as bds_material_desc_en,   
                   t01.plant_code as plant_code,
                   t02.mars_ppww as start_ppww,
                   t03.mars_ppww as end_ppww,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Line1' then sched_qty else null end) as line_1,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Line2' then sched_qty else null end) as line_2,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Line3' then sched_qty else null end) as line_3,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Line4' then sched_qty else null end) as line_4,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Line5' then sched_qty else null end) as line_5,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Line6' then sched_qty else null end) as line_6,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Line7' then sched_qty else null end) as line_7,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Line8' then sched_qty else null end) as line_8,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Line9' then sched_qty else null end) as line_9,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Line10' then sched_qty else null end) as line_10,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Line11' then sched_qty else null end) as line_11,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Line12' then sched_qty else null end) as line_12,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Line13' then sched_qty else null end) as line_13,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Drier1' then sched_qty else null end) as drier_1,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Drier5' then sched_qty else null end) as drier_5,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Drier6' then sched_qty else null end) as drier_6,
                   sum(case when get_token(prodn_line_code,1,'/') = 'SvsDrier' then sched_qty else null end) as svs_drier,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Spray' then sched_qty else null end) as spray,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Snacks' then sched_qty else null end) as snacks,
                   sum(case when get_token(prodn_line_code,1,'/') = 'L1Repack' then sched_qty else null end) as line_1_repack,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Blending' then sched_qty else null end) as blending,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Manual' then sched_qty else null end) as manual,
                   sum(case when get_token(prodn_line_code,1,'/') = 'Repack' then sched_qty else null end) as repack,
                   sum(case when get_token(prodn_line_code,1,'/') = 'SVS' then sched_qty else null end) as svs,
                   sum(case when get_token(prodn_line_code,1,'/') = 'MLine' then sched_qty else null end) as main_line,
                   sum(sched_qty) as sched_total
            from pps_plnd_prdn_detl t01,
                 (select 'P' || period_num || 'W' || substr(mars_week,7,1) as mars_ppww, calendar_date, period_num, substr(mars_week,7,1) as week_num, year_num from mars_date) t02,
                 (select 'P' || period_num || 'W' || substr(mars_week,7,1) as mars_ppww, calendar_date, period_num, substr(mars_week,7,1) as week_num, year_num from mars_date) t03,    
                 bds_material_plant_mfanz t04
            where trunc(t01.start_datime)=t02.calendar_date
                  and trunc(t01.end_datime)=t03.calendar_date
                  and to_char(t01.trad_unit_code)=ltrim(t04.sap_material_code,'0')
                  and trim(t01.plant_code)=t04.plant_code
                  and sched_vrsn=par_version_code
                  and t03.period_num=rcd_period.period_num 
                  and t03.year_num=rcd_period.year_num
                  and t02.week_num=rcd_period.week_num
            group by rollup ((t01.trad_unit_code,t04.bds_material_desc_en, t01.plant_code, t02.mars_ppww, t03.mars_ppww))
            order by 1;
      rcd_report csr_report%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Load the heading data
      /*-*/
      tbl_head.delete;
      tbl_head(tbl_head.count+1).head_code := 'A';
      tbl_head(tbl_head.count).head_desc := 'TRADED UNIT';
      tbl_head(tbl_head.count).head_style := 's64';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'B';
      tbl_head(tbl_head.count).head_desc := 'MATERIAL DESCRIPTION';
      tbl_head(tbl_head.count).head_style := 's65';      
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'C';
      tbl_head(tbl_head.count).head_desc := 'PLANT CODE';
      tbl_head(tbl_head.count).head_style := 's65';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'D';
      tbl_head(tbl_head.count).head_desc := 'START WEEK';
      tbl_head(tbl_head.count).head_style := 's65';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'E';
      tbl_head(tbl_head.count).head_desc := 'END WEEK';
      tbl_head(tbl_head.count).head_style := 's65';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'F';
      tbl_head(tbl_head.count).head_desc := 'LINE 1';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'G';
      tbl_head(tbl_head.count).head_desc := 'LINE 2';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'H';
      tbl_head(tbl_head.count).head_desc := 'LINE 3';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'I';
      tbl_head(tbl_head.count).head_desc := 'LINE 4';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'J';
      tbl_head(tbl_head.count).head_desc := 'LINE 5';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'K';
      tbl_head(tbl_head.count).head_desc := 'LINE 6';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'L';
      tbl_head(tbl_head.count).head_desc := 'LINE 7';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'M';
      tbl_head(tbl_head.count).head_desc := 'LINE 8';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'N';
      tbl_head(tbl_head.count).head_desc := 'LINE 9';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'O';
      tbl_head(tbl_head.count).head_desc := 'LINE 10';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'P';
      tbl_head(tbl_head.count).head_desc := 'LINE 11';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'Q';
      tbl_head(tbl_head.count).head_desc := 'LINE 12';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'R';
      tbl_head(tbl_head.count).head_desc := 'LINE 13';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'S';
      tbl_head(tbl_head.count).head_desc := 'DRIER 1';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'T';
      tbl_head(tbl_head.count).head_desc := 'DRIER 5';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'U';
      tbl_head(tbl_head.count).head_desc := 'DRIER 6';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'V';
      tbl_head(tbl_head.count).head_desc := 'SVSDRIER';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'W';
      tbl_head(tbl_head.count).head_desc := 'SPRAY';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'X';
      tbl_head(tbl_head.count).head_desc := 'SNACKS';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'Y';
      tbl_head(tbl_head.count).head_desc := 'L1REPACK';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'Z';
      tbl_head(tbl_head.count).head_desc := 'BLENDING';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'AA';
      tbl_head(tbl_head.count).head_desc := 'MANUAL';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'AB';
      tbl_head(tbl_head.count).head_desc := 'REPACK';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'AC';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_desc := 'SVS';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'AD';
      tbl_head(tbl_head.count).head_desc := 'MLINE';
      tbl_head(tbl_head.count).head_style := 's66';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'AE';
      tbl_head(tbl_head.count).head_desc := 'TOTAL';
      tbl_head(tbl_head.count).head_style := 's67';
      tbl_head(tbl_head.count).head_totl := 0;
      
      var_rep_date := to_char(sysdate,'DD/MM/YYYY');

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<?xml version="1.0"?>');
      pipe row('<?mso-application progid="Excel.Sheet"?>');
      pipe row('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"');
      pipe row(' xmlns:o="urn:schemas-microsoft-com:office:office"');
      pipe row(' xmlns:x="urn:schemas-microsoft-com:office:excel"');
      pipe row(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"');
      pipe row(' xmlns:html="http://www.w3.org/TR/REC-html40">');
      pipe row(' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">');
      pipe row('  <Version>12.00</Version>');
      pipe row(' </DocumentProperties>');
      pipe row(' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">');
      pipe row('  <DownloadComponents/>');
      pipe row('  <LocationOfComponents HRef="/"/>');
      pipe row(' </OfficeDocumentSettings>');
      pipe row(' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">');
      pipe row('  <WindowHeight>11640</WindowHeight>');
      pipe row('  <WindowWidth>15195</WindowWidth>');
      pipe row('  <WindowTopX>480</WindowTopX>');
      pipe row('  <WindowTopY>120</WindowTopY>');
      pipe row('  <ActiveSheet>0</ActiveSheet>');
      pipe row('  <ProtectStructure>False</ProtectStructure>');
      pipe row('  <ProtectWindows>False</ProtectWindows>');
      pipe row(' </ExcelWorkbook>');
      pipe row(' <Styles>');
      pipe row('  <Style ss:ID="Default" ss:Name="Normal">');
      pipe row('   <Alignment ss:Vertical="Bottom"/>');
      pipe row('   <Borders/>');
      pipe row('   <Font ss:FontName="Arial"/>');
      pipe row('   <Interior/>');
      pipe row('   <NumberFormat/>');
      pipe row('   <Protection/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="m65094752">');
      pipe row('   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s62">');
      pipe row('   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s63">');
      pipe row('   <Alignment ss:Horizontal="Left" ss:Vertical="Center"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s64">');
      pipe row('   <Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s65">');
      pipe row('   <Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s66">');
      pipe row('   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s67">');
      pipe row('   <Alignment ss:Horizontal="Right" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s69">');
      pipe row('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"');
      pipe row('    ss:Bold="1"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s70">');
      pipe row('   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s71">');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s72">');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous"/>');
      pipe row('   </Borders>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s73">');
      pipe row('   <Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s74">');
      pipe row('   <Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s75">');
      pipe row('   <Alignment ss:Horizontal="Right" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s76">');
      pipe row('   <Alignment ss:Horizontal="Right" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s90">');
      pipe row('   <Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s91">');
      pipe row('   <Alignment ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s96">');
      pipe row('   <Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s97">');
      pipe row('   <Alignment ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s98">');
      pipe row('   <Alignment ss:Horizontal="Left" ss:Vertical="Center"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s99">');
      pipe row('   <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s100">');
      pipe row('   <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>');        
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s101">');
      pipe row('   <Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s102">');
      pipe row('   <Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s103">');
      pipe row('   <Alignment ss:Horizontal="Right" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s104">');
      pipe row('   <Alignment ss:Horizontal="Right" ss:Vertical="Center" ss:WrapText="1"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('   <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FFFFFF"');
      pipe row('    ss:Bold="1"/>');
      pipe row('   <Interior ss:Color="#40414C" ss:Pattern="Solid"/>');
      pipe row('  </Style>');
      pipe row('  <Style ss:ID="s105">');
      pipe row('   <Alignment ss:Horizontal="Left" ss:Vertical="Center"/>');
      pipe row('   <Borders>');
      pipe row('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
      pipe row('   </Borders>');
      pipe row('  </Style>');
      pipe row(' </Styles>');

      open csr_period;
      loop
           fetch csr_period into rcd_period;
           exit when csr_period%notfound;
           
           pipe row(' <Worksheet ss:Name="' || rcd_period.mars_ppww || '">');
           pipe row('  <Table x:FullColumns="1" x:FullRows="1">');
           pipe row('   <Column ss:StyleID="s62" ss:Width="83.25"/>');
           pipe row('   <Column ss:Width="200.25"/>');
           pipe row('   <Column ss:AutoFitWidth="0" ss:Width="65.25"/>');
           pipe row('   <Column ss:AutoFitWidth="0" ss:Width="67.5" ss:Span="1"/>');
           pipe row('   <Column ss:Index="6" ss:AutoFitWidth="0" ss:Width="49.5" ss:Span="25"/>');

           pipe row('<Row ss:AutoFitHeight="0" ss:Height="18.75">');
           pipe row('<Cell ss:MergeAcross="30" ss:StyleID="m65094752"><Data ss:Type="String">PSA Scheduling Report - Production Scheduling by Line (' || rcd_period.mars_ppww || ') - Version ' || par_version_code || ' as of ' || var_rep_date || '</Data></Cell>');
           pipe row('</Row>');
            
           pipe row('   <Row ss:AutoFitHeight="0" ss:Height="24">');     
           for idx in 1..tbl_head.count loop
                pipe row('<Cell ss:StyleID="' || tbl_head(idx).head_style || '"><Data ss:Type="String">' || tbl_head(idx).head_desc || '</Data></Cell>');
           end loop;
           pipe row ('</Row>');

           /*-*/
           /* Output the report
           /*-*/
           open csr_report;
           loop
                fetch csr_report into rcd_report;                
                if csr_report%notfound then
                    exit;
                end if;
                
                pipe row('   <Row ss:AutoFitHeight="0" ss:Height="24">');         
         
                if (rcd_report.is_total='N') then
                    pipe row('    <Cell ss:StyleID="s98"><Data ss:Type="String">' || rcd_report.tdu_material_code || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s105"><Data ss:Type="String">' || rcd_report.bds_material_desc_en || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s105"><Data ss:Type="String">' || rcd_report.plant_code || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s105"><Data ss:Type="String">' || rcd_report.start_ppww || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s105"><Data ss:Type="String">' || rcd_report.end_ppww || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.line_1 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.line_2 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.line_3 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.line_4 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.line_5 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.line_6 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.line_7 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.line_8 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.line_9 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.line_10 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.line_11 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.line_12 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.line_13 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.drier_1 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.drier_5 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.drier_6 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.svs_drier || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.spray || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.snacks || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.line_1_repack || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.blending || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.manual || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.repack || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.svs || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s99"><Data ss:Type="String">' || rcd_report.main_line || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s100"><Data ss:Type="String">' || rcd_report.sched_total || '</Data></Cell>');
                else     
                    pipe row('    <Cell ss:StyleID="s73"><Data ss:Type="String">' || rcd_report.tdu_material_code || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s74"><Data ss:Type="String">' || rcd_report.bds_material_desc_en || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s74"><Data ss:Type="String">' || rcd_report.plant_code || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s74"><Data ss:Type="String">' || rcd_report.start_ppww || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s74"><Data ss:Type="String">' || rcd_report.end_ppww || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.line_1 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.line_2 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.line_3 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.line_4 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.line_5 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.line_6 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.line_7 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.line_8 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.line_9 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.line_10 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.line_11 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.line_12 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.line_13 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.drier_1 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.drier_5 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.drier_6 || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.svs_drier || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.spray || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.snacks || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.line_1_repack || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.blending || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.manual || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.repack || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.svs || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s75"><Data ss:Type="String">' || rcd_report.main_line || '</Data></Cell>');
                    pipe row('    <Cell ss:StyleID="s76"><Data ss:Type="String">' || rcd_report.sched_total || '</Data></Cell>');        
                end if;
           
                pipe row('   </Row>');

           end loop;
           close csr_report;

          /*-*/
          /* End the sheet
          /*-*/
          pipe row('</Table>');
          pipe row('<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">');
          pipe row('<ProtectObjects>False</ProtectObjects>');
          pipe row('<ProtectScenarios>False</ProtectScenarios>');
          pipe row('</WorksheetOptions>');
          pipe row('</Worksheet>');
      
      end loop;
      close csr_period;     

      /*-*/
      /* End the sheet
      /*-*/
      pipe row('</Workbook>');
      
      /*-*/
      /* Return
      /*-*/
      return;

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
         raise_application_error(-20000, 'FATAL ERROR - PSA_SCHEDULE_REPORT - REPORT_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_data;

end psa_schedule_report;
/


GRANT EXECUTE ON PS_APP.PSA_SCHEDULE_REPORT TO LICS_APP;

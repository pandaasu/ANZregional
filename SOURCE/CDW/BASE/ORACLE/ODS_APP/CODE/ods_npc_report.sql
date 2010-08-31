/******************/
/* Package Header */
/******************/
create or replace package ods_app.ods_npc_report as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ods_npc_report
    Owner   : ods_app

    Description
    -----------
    Operational Data Stote - NPC Report

    This package contain the NPC report functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function select_data return ods_xml_type pipelined;
   function report_data(par_company_code in varchar2,
                        par_bus_sgmnt_code in varchar2,
                        par_str_yyyymm in number,
                        par_end_yyyymm in number) return ods_xls_type pipelined;
   function get_bom_data(par_company_code in varchar2,
                         par_bus_sgmnt_code in varchar2,
                         par_str_yyyymm in number,
                         par_end_yyyymm in number,
                         par_material_code in varchar2) return ods_npc_type pipelined;

end ods_npc_report;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.ods_npc_report as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***************************************************/
   /* This procedure performs the select data routine */
   /***************************************************/
   function select_data return ods_xml_type pipelined is

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
      cursor csr_company is
         select t01.company_code as comcde,
                t01.company_desc as comnam
           from company t01
          order by t01.company_code asc;
      rcd_company csr_company%rowtype;

      cursor csr_division is
         select substr(t01.z_data,5,2) as segcde,
                substr(t01.z_data,7,20) as segnam
           from sap_ref_dat t01
          where t01.z_tabname = 'TSPAT'
            and substr(t01.z_data,5,2) in ('01','02','05')
            and substr(t01.z_data,4,1) = 'E'
          order by segcde;
      rcd_division csr_division%rowtype;

      cursor csr_month is
         select t01.*
           from (select to_char(t01.year_num)||to_char(t01.month_num,'fm00') as mthcde,
                        min(to_char(t01.year_num)||'/'||to_char(t01.month_num,'fm00')) as mthnam
                   from mars_date t01
                  where t01.calendar_date >= sysdate - 730 and t01.calendar_date <= sysdate
                  group by to_char(t01.year_num)||to_char(t01.month_num,'fm00')
                  order by mthcde desc) t01
          where rownum <= 24;
      rcd_month csr_month%rowtype;

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
      ods_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('ODS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_ods_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/ODS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_ods_request,'@ACTION'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SLTRPT' then
         ods_gen_function.add_mesg_data('Invalid request action');
      end if;
      if ods_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(ods_xml_object('<?xml version="1.0" encoding="UTF-8"?><ODS_RESPONSE>'));

      /*-*/
      /* Pipe the company data XML
      /*-*/
      open csr_company;
      loop
         fetch csr_company into rcd_company;
         if csr_company%notfound then
            exit;
         end if;
         pipe row(ods_xml_object('<COMCDE COMCDE="'||ods_to_xml(rcd_company.comcde)||'" COMNAM="'||ods_to_xml('('||rcd_company.comcde||') '||rcd_company.comnam)||'"/>'));
      end loop;
      close csr_company;

      /*-*/
      /* Pipe the segment data XML
      /*-*/
      open csr_division;
      loop
         fetch csr_division into rcd_division;
         if csr_division%notfound then
            exit;
         end if;
         pipe row(ods_xml_object('<SEGCDE SEGCDE="'||ods_to_xml(rcd_division.segcde)||'" SEGNAM="'||ods_to_xml('('||rcd_division.segcde||') '||rcd_division.segnam)||'"/>'));
      end loop;
      close csr_division;

      /*-*/
      /* Pipe the month data XML
      /*-*/
      open csr_month;
      loop
         fetch csr_month into rcd_month;
         if csr_month%notfound then
            exit;
         end if;
         pipe row(ods_xml_object('<MTHCDE MTHCDE="'||ods_to_xml(rcd_month.mthcde)||'" MTHNAM="'||ods_to_xml(rcd_month.mthnam)||'"/>'));
      end loop;
      close csr_month;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(ods_xml_object('</ODS_RESPONSE>'));

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
         ods_gen_function.add_mesg_data('FATAL ERROR - ODS_NPC_REPORT - SELECT_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_data;

   /***************************************************/
   /* This procedure performs the report data routine */
   /***************************************************/
   function report_data(par_company_code in varchar2,
                                         par_bus_sgmnt_code in varchar2,
                                         par_str_yyyymm in number,
                                         par_end_yyyymm in number) return ods_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_output varchar2(2000 char);
      type rcd_head is record(head_code varchar2(10),
                              head_desc varchar2(32),
                              head_totl number);
      type typ_head is table of rcd_head index by binary_integer;
      tbl_head typ_head;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_heading is
         select t01.atwrt,
                t02.atwtb
           from sap_chr_mas_val t01,
                sap_chr_mas_dsc t02
          where t01.atnam = t02.atnam
            and t01.valseq = t02.valseq
            and t01.atnam = 'Z_APVERP01'
            and t02.spras_iso = 'EN';
      rcd_heading csr_heading%rowtype;

      cursor csr_report is
         select to_char(t01.sale_material_code) as sale_material_code,
                nvl(t02.matl_desc_en,'*UNKNOWN') as sale_material_desc,
                nvl(t02.matl_type_code,'*UNKNOWN') as sale_material_type,
                to_char(t01.sale_buom_qty) as sale_buom_qty,
                t01.sale_buom_code,
                t01.bom_plant_code,
                to_char(t01.fert_material_code) as fert_material_code,
                nvl(t03.matl_desc_en,'*UNKNOWN') as fert_material_desc,
                nvl(t03.matl_type_code,'*UNKNOWN') as fert_material_type,
                to_char(t01.fert_qty) as fert_qty,
                t01.fert_uom,
                to_char(t01.item_material_code) as item_material_code,
                nvl(t04.matl_desc_en,'*UNKNOWN') as item_material_desc,
                nvl(t04.matl_type_code,'*UNKNOWN') as item_material_type,
                to_char(t01.item_qty) as item_qty,
                t01.item_uom,
                to_char(t04.gross_wgt) as item_gross_weight,
                t04.wgt_unit_code as item_weight_unit,
                t05.pack_family_code as item_pack_family_code,
                t06.ref_desc as item_pack_family_desc,
                t05.pack_sub_family_code as item_pack_sub_family_code,
                t07.ref_desc as item_pack_sub_family_desc,
                t05.disposal_class_code as item_disposal_class_code,
                t08.atwtb as item_disposal_class_desc
           from table(ods_npc_report.get_bom_data(par_company_code,par_bus_sgmnt_code,par_str_yyyymm,par_end_yyyymm,null)) t01,
                matl_dim t02,
                matl_dim t03,
                matl_dim t04,
                (select ltrim(t01.objek,'0') as matl_code,
                        max(case when t01.atnam = 'CLFVERP01' then t01.atwrt end) as pack_family_code,
                        max(case when t01.atnam = 'CLFVERP02' then t01.atwrt end) as pack_sub_family_code,
                        max(case when t01.atnam = 'Z_APVERP01' then t01.atwrt end) as disposal_class_code
                 from sap_cla_chr t01
                 where t01.obtab = 'MARA'
                   and t01.klart = '001'
                 group by t01.objek) t05,
                (select trim(substr(t01.z_data,4,30)) as ref_code,
                        trim(substr(t01.z_data,34,30)) as ref_desc
                   from sap_ref_dat t01
                  where t01.z_tabname = '/MARS/MD_VERP01') t06,
                (select trim(substr(t01.z_data,4,30)) as ref_code,
                        trim(substr(t01.z_data,34,30)) as ref_desc
                   from sap_ref_dat t01
                  where t01.z_tabname = '/MARS/MD_VERP02') t07,
                (select t01.atwrt,
                        t02.atwtb
                   from sap_chr_mas_val t01,
                        sap_chr_mas_dsc t02
                  where t01.atnam = t02.atnam
                    and t01.valseq = t02.valseq
                    and t01.atnam = 'Z_APVERP01'
                    and t02.spras_iso = 'EN') t08
          where t01.sale_material_code = t02.matl_code(+)
            and t01.fert_material_code = t03.matl_code(+)
            and t01.item_material_code = t04.matl_code(+)
            and t01.item_material_code = t05.matl_code(+)
            and t05.pack_family_code = t06.ref_code(+)
            and t05.pack_sub_family_code = t07.ref_code(+)
            and t05.disposal_class_code = t08.atwrt(+)
          order by t01.sale_material_code asc,
                   t01.bom_sequence asc;
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
      tbl_head(tbl_head.count).head_desc := 'Sale material code';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'B';
      tbl_head(tbl_head.count).head_desc := 'Sale material desc';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'C';
      tbl_head(tbl_head.count).head_desc := 'Sale material type';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'D';
      tbl_head(tbl_head.count).head_desc := 'Sale buom qty';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'E';
      tbl_head(tbl_head.count).head_desc := 'Sale buom code';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'F';
      tbl_head(tbl_head.count).head_desc := 'BOM plant code';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'G';
      tbl_head(tbl_head.count).head_desc := 'Fert material code';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'H';
      tbl_head(tbl_head.count).head_desc := 'Fert material desc';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'I';
      tbl_head(tbl_head.count).head_desc := 'Fert material type';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'J';
      tbl_head(tbl_head.count).head_desc := 'Fert qty';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'K';
      tbl_head(tbl_head.count).head_desc := 'Fert UOM';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'L';
      tbl_head(tbl_head.count).head_desc := 'Item material code';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'M';
      tbl_head(tbl_head.count).head_desc := 'Item material desc';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'N';
      tbl_head(tbl_head.count).head_desc := 'Item material type';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'O';
      tbl_head(tbl_head.count).head_desc := 'Item qty';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'P';
      tbl_head(tbl_head.count).head_desc := 'Item UOM';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'Q';
      tbl_head(tbl_head.count).head_desc := 'Item gross wgt';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'R';
      tbl_head(tbl_head.count).head_desc := 'Item wgt unit code';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'S';
      tbl_head(tbl_head.count).head_desc := 'Item pack family code';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'T';
      tbl_head(tbl_head.count).head_desc := 'Item pack family desc';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'U';
      tbl_head(tbl_head.count).head_desc := 'Item pack sub family code';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'V';
      tbl_head(tbl_head.count).head_desc := 'Item pack sub family desc';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'W';
      tbl_head(tbl_head.count).head_desc := 'Item disposal class code';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'X';
      tbl_head(tbl_head.count).head_desc := 'Item disposal class desc';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'Y';
      tbl_head(tbl_head.count).head_desc := 'Pack weight/1000 cs';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'Z';
      tbl_head(tbl_head.count).head_desc := 'Pack weight-kg/cs';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'AA';
      tbl_head(tbl_head.count).head_desc := 'Raws weight/1000 cs';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'AB';
      tbl_head(tbl_head.count).head_desc := 'Raws weight/ cs';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'AC';
      tbl_head(tbl_head.count).head_desc := 'Time period total packs (kgm)';
      tbl_head(tbl_head.count).head_totl := 0;
      tbl_head(tbl_head.count+1).head_code := 'AD';
      tbl_head(tbl_head.count).head_desc := 'Time period total raws (tonnes)';
      tbl_head(tbl_head.count).head_totl := 0;

      open csr_heading;
      loop
         fetch csr_heading into rcd_heading;
         if csr_heading%notfound then
            exit;
         end if;
         tbl_head(tbl_head.count+1).head_code := rcd_heading.atwrt;
         tbl_head(tbl_head.count).head_desc := rcd_heading.atwtb;
         tbl_head(tbl_head.count).head_totl := 0;
      end loop;
      close csr_heading;

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<html');
      pipe row('<head>');
      pipe row('<style>br {mos-data_placement:same-cell;}</style>');
      pipe row('<!--[if gte mso 9]><xml>');
      pipe row(' <x:ExcelWorkbook>');
      pipe row('  <x:ExcelWorksheets>');
      pipe row('   <x:ExcelWorksheet>');
      pipe row('    <x:Name>NPC_Report</x:Name>');
      pipe row('    <x:WorksheetOptions>');
      pipe row('     <x:Selected/>');
      pipe row('     <x:DoNotDisplayGridlines/>');
      pipe row('     <x:FreezePanes/>');
      pipe row('     <x:FrozenNoSplit/>');
      pipe row('     <x:SplitHorizontal>2</x:SplitHorizontal>');
      pipe row('     <x:TopRowBottomPane>2</x:TopRowBottomPane>');
      pipe row('     <x:SplitVertical>2</x:SplitVertical>');
      pipe row('     <x:LeftColumnRightPane>2</x:LeftColumnRightPane>');
      pipe row('     <x:ActivePane>0</x:ActivePane>');
      pipe row('     <x:Panes>');
      pipe row('      <x:Pane>');
      pipe row('       <x:Number>0</x:Number>');
      pipe row('       <x:ActiveRow>3</x:ActiveRow>');
      pipe row('       <x:ActiveCol>1</x:ActiveCol>');
      pipe row('      </x:Pane>');
      pipe row('     </x:Panes>');
      pipe row('     <x:ProtectContents>False</x:ProtectContents>');
      pipe row('     <x:ProtectObjects>False</x:ProtectObjects>');
      pipe row('     <x:ProtectScenarios>False</x:ProtectScenarios>');
      pipe row('    </x:WorksheetOptions>');
      pipe row('   </x:ExcelWorksheet>');
      pipe row('  </x:ExcelWorksheets>');
      pipe row('  <x:ProtectStructure>False</x:ProtectStructure>');
      pipe row('  <x:ProtectWindows>False</x:ProtectWindows>');
      pipe row(' </x:ExcelWorkbook>');
      pipe row('</xml><![endif]-->');
      pipe row('</head>');
      pipe row('<body>');



      pipe row('<table>');
      pipe row('<tr><td align=center colspan='||to_char(tbl_head.count)||' style="font-family:Arial;font-size:10pt;font-weight:bold;background-color:#ccffcc;color:#000000;border:#000000 .5pt solid;">NPC Report - '||to_char(par_str_yyyymm)||' to '||to_char(par_end_yyyymm)||'</td></tr>');
      pipe row('<tr>');
      for idx in 1..tbl_head.count loop
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:10pt;font-weight:bold;background-color:#ccffcc;color:#000000;border:#000000 .5pt solid;mso-rotate:-90;">'||tbl_head(idx).head_desc||'</td>');
      end loop;
      pipe row('</tr>');

      open csr_report;
      loop
         fetch csr_report into rcd_report;
         if csr_report%notfound then
            exit;
         end if;
         pipe row('<tr>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;mso-number-format:\@;">'||rcd_report.sale_material_code||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.sale_material_desc||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.sale_material_type||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;mso-number-format:\@;">'||rcd_report.sale_buom_qty||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.sale_buom_code||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.bom_plant_code||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.fert_material_code||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.fert_material_desc||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.fert_material_type||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;mso-number-format:\@;">'||rcd_report.fert_qty||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.fert_uom||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.item_material_code||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.item_material_desc||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.item_material_type||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;mso-number-format:\@;">'||rcd_report.item_qty||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.item_uom||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;mso-number-format:\@;">'||rcd_report.item_gross_weight||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.item_weight_unit||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.item_pack_family_code||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.item_pack_family_desc||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.item_pack_sub_family_code||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.item_pack_sub_family_desc||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.item_disposal_class_code||'</td>');
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;">'||rcd_report.item_disposal_class_desc||'</td>');
         if upper(trim(rcd_report.item_material_type)) = 'VERP' then
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;mso-number-format:\@;">'||to_char(nvl(rcd_report.item_qty,0)*nvl(rcd_report.item_gross_weight,0))||'</td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;mso-number-format:\@;">'||to_char((nvl(rcd_report.item_qty,0)*nvl(rcd_report.item_gross_weight,0))/1000000)||'</td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;mso-number-format:\@;">'||to_char(((nvl(rcd_report.item_qty,0)*nvl(rcd_report.item_gross_weight,0))/1000000)*rcd_report.sale_buom_qty)||'</td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
         elsif upper(trim(rcd_report.item_material_type)) = 'ROH' then
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;mso-number-format:\@;">'||to_char(nvl(rcd_report.item_qty,0))||'</td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;mso-number-format:\@;">'||to_char(nvl(rcd_report.item_qty,0)/1000)||'</td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;mso-number-format:\@;">'||to_char((nvl(rcd_report.item_qty,0)/1000)*(nvl(rcd_report.sale_buom_qty,0)/1000))||'</td>');
         else
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
         end if;
         if upper(trim(rcd_report.item_material_type)) = 'VERP' then
            for idx in 31..tbl_head.count loop
               if rcd_report.item_disposal_class_code = tbl_head(idx).head_code then
                  tbl_head(idx).head_totl := tbl_head(idx).head_totl + ((nvl(rcd_report.item_qty,0)*nvl(rcd_report.item_gross_weight,0))/1000000)*rcd_report.sale_buom_qty;
                  pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;mso-number-format:\@;">'||to_char(((nvl(rcd_report.item_qty,0)*nvl(rcd_report.item_gross_weight,0))/1000000)*rcd_report.sale_buom_qty)||'</td>');
               else
                  pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
               end if;
            end loop;
         else
            for idx in 31..tbl_head.count loop
               pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
            end loop;
         end if;
         pipe row('</tr>');
      end loop;
      close csr_report;

      /*-*/
      /* Pipe the total linet
      /*-*/
      pipe row('<tr>');
      for idx in 1..30 loop
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
      end loop;
      for idx in 31..tbl_head.count loop
         pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:10pt;font-weight:bold;background-color:#ccffcc;color:#000000;border:#000000 .5pt solid;mso-number-format:\@;">'||to_char(tbl_head(idx).head_totl)||')</td>');
      end loop;
      pipe row('</tr>');

      /*-*/
      /* End the report
      /*-*/
      pipe row('</table>');
      pipe row('</body>');
      pipe row('</html>');

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
         raise_application_error(-20000, 'FATAL ERROR - ODS_NPC_REPORT - REPORT_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_data;

   /****************************************************/
   /* This procedure performs the get bom data routine */
   /****************************************************/
   function get_bom_data(par_company_code in varchar2,
                         par_bus_sgmnt_code in varchar2,
                         par_str_yyyymm in number,
                         par_end_yyyymm in number,
                         par_material_code in varchar2) return ods_npc_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_material_save varchar2(32);
      var_plant_save varchar2(32);
      var_level_save number;
      var_material_uom varchar2(32);
      var_base_uom varchar2(32);
      var_factor number;
      type typ_factor is table of number index by binary_integer;
      tbl_factor typ_factor;
      var_fert_index number;
      type rcd_fert is record(sale_code varchar2(32),
                              sale_qty number,
                              sale_uom varchar2(32),
                              plant_code varchar2(32),
                              fert_code varchar2(32),
                              fert_qty number,
                              fert_uom varchar2(32),
                              verp_code varchar2(32),
                              verp_qty number,
                              verp_uom varchar2(32),
                              roh_code varchar2(32),
                              roh_qty number,
                              roh_uom varchar2(32));
      type typ_fert is table of rcd_fert index by binary_integer;
      tbl_fert typ_fert;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_data is
         select t01.matl_code as sale_material_code,
                nvl(t02.matl_type_code,'*UNKNOWN') as sale_material_type,
                t01.billed_base_uom_code as sale_base_uom_code,
                round(t01.billed_qty_base_uom,3) as sale_qty_base_uom,
                t03.bom_hierarchy_rownum,
                t03.bom_hierarchy_level,
                t03.bom_hierarchy_path,
                t03.bom_material_code,
                nvl(t04.matl_type_code,'*UNKNOWN') as bom_material_type,
                t03.bom_alternative,
                t03.bom_plant,
                t03.bom_number,
                t03.bom_usage,
                t03.bom_eff_from_date,
                t03.bom_eff_to_date,
                t03.bom_base_qty,
                t03.bom_base_uom,
                t03.bom_status,
                t03.item_sequence,
                t03.item_number,
                t03.item_material_code,
                nvl(t05.matl_type_code,'*UNKNOWN') as item_material_type,
                nvl(t05.matl_desc_en,'*UNKNOWN') as item_material_desc,
                t03.item_category,
                t03.item_base_qty,
                t03.item_base_uom,
                t03.item_eff_from_date,
                t03.item_eff_to_date
           from (select t01.matl_code,
                        t01.billed_base_uom_code,
                        sum(t01.billed_qty_base_uom) as billed_qty_base_uom
                   from dw_sales_month01 t01,
                        demand_plng_grp_sales_area_dim t02,
                        cust_sales_area_dim t03
                  where t01.ship_to_cust_code = t02.cust_code(+)
                    and t01.hdr_distbn_chnl_code = t02.distbn_chnl_code(+)
                    and t01.demand_plng_grp_division_code = t02.division_code(+)
                    and t01.hdr_sales_org_code = t02.sales_org_code(+)
                    and t01.sold_to_cust_code = t03.cust_code(+)
                    and t01.hdr_distbn_chnl_code = t03.distbn_chnl_code(+) 
                    and t01.hdr_division_code = t03.division_code(+) 
                    and t01.hdr_sales_org_code = t03.sales_org_code(+)
                    and t01.company_code = par_company_code
                    and (par_material_code is null or t01.matl_code = par_material_code)
                    and t01.billing_eff_yyyymm >= par_str_yyyymm
                    and t01.billing_eff_yyyymm <= par_end_yyyymm
                    and t03.acct_assgnmnt_grp_code = '01'
                  group by t01.matl_code,
                           t01.billed_base_uom_code) t01,
                matl_dim t02,
                (select rownum as bom_hierarchy_rownum,
                        level as bom_hierarchy_level,
                        substr(sys_connect_by_path(t01.bom_material_code,'/'),2,decode(instr(sys_connect_by_path(t01.bom_material_code,'/'),'/',2,1),0,length(sys_connect_by_path(t01.bom_material_code,'/')),instr(sys_connect_by_path(t01.bom_material_code,'/'),'/',2,1)-2)) as bom_hierarchy_root,
                        sys_connect_by_path(t01.bom_material_code,'/') as bom_hierarchy_path,
                        t01.*
                   from (select t01.bom_material_code,
                                t01.bom_alternative,
                                t01.bom_plant,
                                t01.bom_number,
                                t01.bom_usage,
                                t01.bom_eff_from_date,
                                t01.bom_eff_to_date,
                                t01.bom_base_qty,
                                t01.bom_base_uom,
                                t01.bom_status,
                                t01.item_sequence,
                                t01.item_number,
                                t01.item_material_code,
                                t01.item_category,
                                t01.item_base_qty,
                                t01.item_base_uom,
                                t01.item_eff_from_date,
                                t01.item_eff_to_date
                           from (select t01.*,
                                        rank() over (partition by t01.bom_material_code,
                                                                  t01.bom_plant
                                                         order by t01.bom_eff_from_date desc,
                                                                  t01.bom_alternative desc) as rnkseq
                                   from sap_bom_data t01
                                  where trunc(t01.bom_eff_from_date) <= trunc(sysdate)) t01
                          where t01.rnkseq = 1
                            and t01.item_sequence != 0) t01
                connect by nocycle prior t01.item_material_code = t01.bom_material_code
                  order siblings by to_number(t01.item_number)) t03,
                matl_dim t04,
                matl_dim t05
          where t01.matl_code = t02.matl_code(+)
            and t01.matl_code = t03.bom_hierarchy_root(+)
            and t03.bom_material_code = t04.matl_code(+)
            and t03.item_material_code = t05.matl_code(+)
            and t02.bus_sgmnt_code = par_bus_sgmnt_code
          order by t01.matl_code asc,
                   t03.bom_hierarchy_rownum asc;
      rcd_data csr_data%rowtype;

      cursor csr_uom is
         select nvl(t01.umren,1) as mat_umren,
                nvl(t01.umrez,1) as mat_umrez
           from sap_mat_uom t01
          where t01.matnr = var_material_uom
            and t01.meinh = var_base_uom;
      rcd_uom csr_uom%rowtype;
                                                                                                                                                      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the bom data
      /*-*/
      var_material_save := '**NONE**';
      var_plant_save := '**NONE**';
      var_level_save := 0;
      tbl_factor.delete;
      tbl_fert.delete;
      open csr_data;
      loop
         fetch csr_data into rcd_data;
         if csr_data%notfound then
            exit;
         end if;

         /*-*/
         /* Pipe the bom data on material change
         /*-*/
         if rcd_data.sale_material_code != var_material_save then
            if var_material_save != '**NONE**' then
               for idx in 1..tbl_fert.count loop
                  if not(tbl_fert(idx).verp_code is null) and tbl_fert(idx).verp_code != '*FERT' then
                     pipe row(ods_npc_object(tbl_fert(idx).sale_code,
                                             tbl_fert(idx).sale_qty,
                                             tbl_fert(idx).sale_uom,
                                             idx,
                                             tbl_fert(idx).plant_code,
                                             tbl_fert(idx).fert_code,
                                             round(tbl_fert(idx).fert_qty,3),
                                             tbl_fert(idx).fert_uom,
                                             tbl_fert(idx).verp_code,
                                             round(tbl_fert(idx).verp_qty,3),
                                             tbl_fert(idx).verp_uom));
                  end if;
                  if not(tbl_fert(idx).roh_code is null) then
                     pipe row(ods_npc_object(tbl_fert(idx).sale_code,
                                             tbl_fert(idx).sale_qty,
                                             tbl_fert(idx).sale_uom,
                                             idx,
                                             tbl_fert(idx).plant_code,
                                             tbl_fert(idx).fert_code,
                                             round(tbl_fert(idx).fert_qty,3),
                                             tbl_fert(idx).fert_uom,
                                             tbl_fert(idx).roh_code,
                                             round(tbl_fert(idx).roh_qty,3),
                                             tbl_fert(idx).roh_uom));
                  end if;
               end loop;
            end if;
            var_material_save := rcd_data.sale_material_code;
            var_level_save := 0;
            tbl_factor.delete;
            tbl_fert.delete;
         end if;

         /*-*/
         /* Process the row when required
         /*-*/
         if not(rcd_data.bom_hierarchy_path is null) then

            /*-*/
            /* Calculate the factor
            /*-*/
            var_factor := 1;
            if rcd_data.bom_hierarchy_level-1 > 0 then
               for idx in 1..rcd_data.bom_hierarchy_level-1 loop
                  var_factor := var_factor * tbl_factor(idx);
               end loop;
            end if;
            tbl_factor(rcd_data.bom_hierarchy_level) := rcd_data.item_base_qty / nvl(rcd_data.bom_base_qty,0);
            if rcd_data.item_base_uom != 'EA' then
               var_material_uom := ods_expand_code(rcd_data.item_material_code);
               var_base_uom := rcd_data.item_base_uom;
               open csr_uom;
               fetch csr_uom into rcd_uom;
               if csr_uom%found then
                  tbl_factor(rcd_data.bom_hierarchy_level) := ((rcd_data.item_base_qty * rcd_uom.mat_umrez) / rcd_uom.mat_umren) / nvl(rcd_data.bom_base_qty,0);
               end if;
               close csr_uom;
            end if;

            /*-*/
            /* Process the FERT (finished good)
            /*-*/
            if rcd_data.bom_material_type = 'FERT' then
               var_fert_index := 0;
               for idx in 1..tbl_fert.count loop
                  if tbl_fert(idx).fert_code = rcd_data.bom_material_code then
                     if tbl_fert(idx).verp_code = '*FERT' then
                        var_fert_index := idx;
                        exit;
                     end if;
                  end if;
               end loop;
               if var_fert_index = 0 then
                  var_fert_index := tbl_fert.count + 1;
                  tbl_fert(var_fert_index).sale_code := rcd_data.sale_material_code;
                  tbl_fert(var_fert_index).sale_qty := rcd_data.sale_qty_base_uom;
                  tbl_fert(var_fert_index).sale_uom := rcd_data.sale_base_uom_code;
                  tbl_fert(var_fert_index).plant_code := rcd_data.bom_plant;
                  tbl_fert(var_fert_index).fert_code := rcd_data.bom_material_code;
                  tbl_fert(var_fert_index).fert_qty := rcd_data.bom_base_qty;
                  tbl_fert(var_fert_index).fert_uom := rcd_data.bom_base_uom;
                  tbl_fert(var_fert_index).verp_code := null;
                  tbl_fert(var_fert_index).verp_qty := 0;
                  tbl_fert(var_fert_index).verp_uom := null;
                  tbl_fert(var_fert_index).roh_code := null;
                  tbl_fert(var_fert_index).roh_qty := 0;
                  tbl_fert(var_fert_index).roh_uom := null;
               end if;
               if rcd_data.item_material_type = 'FERT' then
                  tbl_fert(var_fert_index).verp_code := '*FERT';
               end if;
               if rcd_data.item_material_type = 'VERP' then
                  if substr(rcd_data.item_material_desc,1,2) != 'PH' then
                     tbl_fert(var_fert_index).verp_code := rcd_data.item_material_code;
                     tbl_fert(var_fert_index).verp_qty := rcd_data.item_base_qty * var_factor;
                     tbl_fert(var_fert_index).verp_uom := rcd_data.item_base_uom;
                  end if;
               end if;
               if rcd_data.item_material_type = 'ROH' then
                  tbl_fert(var_fert_index).roh_code := rcd_data.item_material_code;
                  tbl_fert(var_fert_index).roh_qty := rcd_data.item_base_qty * var_factor;
                  tbl_fert(var_fert_index).roh_uom := rcd_data.item_base_uom;
               end if;
            end if;

            /*-*/
            /* Process the VERP (packaging)
            /*-*/
            if rcd_data.bom_material_type = 'VERP' then
               if tbl_fert.exists(var_fert_index) then
                  if rcd_data.bom_hierarchy_level <= var_level_save then
                     var_fert_index := tbl_fert.count + 1;
                     tbl_fert(var_fert_index).sale_code := tbl_fert(var_fert_index-1).sale_code;
                     tbl_fert(var_fert_index).sale_qty := tbl_fert(var_fert_index-1).sale_qty;
                     tbl_fert(var_fert_index).sale_uom := tbl_fert(var_fert_index-1).sale_uom;
                     tbl_fert(var_fert_index).plant_code := tbl_fert(var_fert_index-1).plant_code;
                     tbl_fert(var_fert_index).fert_code := tbl_fert(var_fert_index-1).fert_code;
                     tbl_fert(var_fert_index).fert_qty := tbl_fert(var_fert_index-1).fert_qty;
                     tbl_fert(var_fert_index).fert_uom := tbl_fert(var_fert_index-1).fert_uom;
                     tbl_fert(var_fert_index).verp_code := null;
                     tbl_fert(var_fert_index).verp_qty := 0;
                     tbl_fert(var_fert_index).verp_uom := null;
                     tbl_fert(var_fert_index).roh_code := null;
                     tbl_fert(var_fert_index).roh_qty := 0;
                     tbl_fert(var_fert_index).roh_uom := null;
                  end if;
                  if rcd_data.item_material_type = 'VERP' then
                     if substr(rcd_data.item_material_desc,1,2) != 'PH' then
                        tbl_fert(var_fert_index).verp_code := rcd_data.item_material_code;
                        tbl_fert(var_fert_index).verp_qty := rcd_data.item_base_qty * var_factor;
                        tbl_fert(var_fert_index).verp_uom := rcd_data.item_base_uom;
                     end if;
                  end if;
                  if rcd_data.item_material_type = 'ROH' then
                     tbl_fert(var_fert_index).roh_code := rcd_data.item_material_code;
                     tbl_fert(var_fert_index).roh_qty := rcd_data.item_base_qty * var_factor;
                     tbl_fert(var_fert_index).roh_uom := rcd_data.item_base_uom;
                  end if;
               end if;
            end if;

            /*-*/
            /* Save the current level
            /*-*/
            var_level_save := rcd_data.bom_hierarchy_level;

         end if;

      end loop;
      close csr_data;

      /*-*/
      /* Pipe the bom data when required
      /*-*/
      if var_material_save != '**NONE**' then
         for idx in 1..tbl_fert.count loop
            if not(tbl_fert(idx).verp_code is null) and tbl_fert(idx).verp_code != '*FERT' then
               pipe row(ods_npc_object(tbl_fert(idx).sale_code,
                                       tbl_fert(idx).sale_qty,
                                       tbl_fert(idx).sale_uom,
                                       idx,
                                       tbl_fert(idx).plant_code,
                                       tbl_fert(idx).fert_code,
                                       round(tbl_fert(idx).fert_qty,3),
                                       tbl_fert(idx).fert_uom,
                                       tbl_fert(idx).verp_code,
                                       round(tbl_fert(idx).verp_qty,3),
                                       tbl_fert(idx).verp_uom));
            end if;
            if not(tbl_fert(idx).roh_code is null) then
               pipe row(ods_npc_object(tbl_fert(idx).sale_code,
                                       tbl_fert(idx).sale_qty,
                                       tbl_fert(idx).sale_uom,
                                       idx,
                                       tbl_fert(idx).plant_code,
                                       tbl_fert(idx).fert_code,
                                       round(tbl_fert(idx).fert_qty,3),
                                       tbl_fert(idx).fert_uom,
                                       tbl_fert(idx).roh_code,
                                       round(tbl_fert(idx).roh_qty,3),
                                       tbl_fert(idx).roh_uom));
            end if;
         end loop;
      end if;

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
         raise_application_error(-20000, 'FATAL ERROR - ODS_NPC_REPORT - GET_BOM_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_bom_data;

end ods_npc_report;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ods_npc_report for ods_app.ods_npc_report;
grant execute on ods_app.ods_npc_report to public;
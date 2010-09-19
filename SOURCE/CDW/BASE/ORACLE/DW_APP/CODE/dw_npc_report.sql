
--create or replace type dw_xls_type as table of varchar2(2000 char);
--/

create or replace function dw_npc_report(par_company_code in varchar2,
                                         par_bus_sgmnt_code in varchar2,
                                         par_str_yyyymm in number,
                                         par_end_yyyymm in number) return dw_xls_type pipelined is

   var_output varchar2(2000 char);
   type rcd_head is record(head_code varchar2(10),
                           head_desc varchar2(32),
                           head_totl number);
   type typ_head is table of rcd_head index by binary_integer;
   tbl_head typ_head;

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
        from table(dw_sales_bom(par_company_code,par_bus_sgmnt_code,par_str_yyyymm,par_end_yyyymm,null)) t01,
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

begin

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

   pipe row('<tr>');
   for idx in 1..30 loop
      pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:8pt;background-color:#ffffff;color:#000000;"></td>');
   end loop;
   for idx in 31..tbl_head.count loop
      pipe row('<td align=left colspan=1 style="font-family:Arial;font-size:10pt;font-weight:bold;background-color:#ccffcc;color:#000000;border:#000000 .5pt solid;mso-number-format:\@;mso-rotate:-90;">'||to_char(tbl_head(idx).head_totl)||')</td>');
   end loop;
   pipe row('</tr>');

      /*-*/
      /* End the report
      /*-*/
      pipe row('</table>');
      pipe row('</body>');
      pipe row('</html>');

   return;

exception

   /**/
   /* Exception trap
   /**/
   when others then

      /*-*/
      /* Raise an exception to the calling application
      /*-*/
      raise_application_error(-20000, 'DW_NPC_REPORT - ' || substr(SQLERRM, 1, 1024));

end dw_npc_report;
/
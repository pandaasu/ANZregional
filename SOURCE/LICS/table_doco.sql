/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : table_doco
 Owner   : lics_app
 Author  : Steve Gregan
*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package table_doco as

   /*-*/
   /* Public declarations
   /*-*/
   function execute(str_prefix in varchar2) return table_type pipelined;

end table_doco;
/

/****************/
/* Package Body */
/****************/
create or replace package body table_doco as

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   function execute(str_prefix in varchar2) return table_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_work varchar2(2000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_table is 
         select upper(t01.table_name) as table_name,
                t02.comments
           from all_tables t01, all_tab_comments t02
          where t01.table_name = t02.table_name(+)
            and (str_prefix is null or upper(t01.table_name) like upper(str_prefix)||'%')
          order by t01.table_name asc;
      rcd_table csr_table%rowtype;

      cursor csr_index is 
         select lower(t01.index_name) as index_name,
                t01.index_type,
                t01.uniqueness
           from all_indexes t01
          where t01.table_name = rcd_table.table_name
       order by index_name asc;
      rcd_index csr_index%rowtype;

      cursor csr_column is 
         select lower(t01.data_type) as data_type,
                lower(t01.column_name) as column_name,
                upper(t01.char_used) as char_used,
                decode(upper(t01.nullable),'N','not null','null') as nullable,
                to_char(t01.data_length) as data_length,
                to_char(t01.char_length) as char_length,
                to_char(t01.data_precision) as data_precision,
                to_char(t01.data_scale) as data_scale,
                t02.comments
           from all_tab_columns t01, all_col_comments t02
          where t01.table_name = t02.table_name(+)
            and t01.column_name = t02.column_name(+)
            and t01.table_name = rcd_table.table_name
       order by t01.column_id asc;
      rcd_column csr_column%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<html>');
      pipe row('<meta http-equiv="content-type" content="application/vnd.ms-excel; charset=UTF-8">');
      pipe row('<head>');
      pipe row('<style>br {mos-data_placement:same-cell;}</style>');
      pipe row('<!--[if gte mso 9]><xml>');
      pipe row(' <x:ExcelWorkbook>');
      pipe row('  <x:ExcelWorksheets>');
      pipe row('   <x:ExcelWorksheet>');
      pipe row('    <x:Name>LICS Tables</x:Name>');
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
      pipe row('<table border=1>');
      pipe row('<tr><td align=center colspan=3 style="font-family:Arial;font-size:12pt;font-weight:bold;background-color:#ccffcc;color:#000000;border:#000000 .5pt solid;">'||upper(str_prefix)||' - Table Documentation</td></tr>');

      /*-*/
      /* Retrieve the tables
      /*-*/
      open csr_table;
      loop
         fetch csr_table into rcd_table;
         if csr_table%notfound then
            exit;
         end if;

         /*-*/
         /* Output the table data
         /*-*/
         pipe row('<tr><td align=center colspan=3></td></tr>');
         var_work := '<tr>';
         var_work := var_work||'<td align=left colspan=3 style="font-family:Arial;font-size:10pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>';
         var_work := var_work||'<font style="font-family:Arial;font-size:10pt;font-weight:bold;background-color:#ffffff;color:#4040FF;">Table:</font> '||rcd_table.table_name;
         var_work := var_work||' <font style="font-family:Arial;font-size:10pt;font-weight:bold;background-color:#ffffff;color:#4040FF;">Description:</font> '||rcd_table.comments;
         var_work := var_work||'</td>';
         var_work := var_work||'</tr>';
         pipe row(var_work);

         /*-*/
         /* Retrieve the indexes related to the table
         /*-*/
         open csr_index;
         loop
            fetch csr_index into rcd_index;
            if csr_index%notfound then
               exit;
            end if;
            var_work := '<tr>';
            var_work := var_work||'<td align=left colspan=3 style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>&nbsp;&nbsp;';
            var_work := var_work||'<font style="font-family:Arial;font-size:9pt;font-weight:bold;background-color:#ffffff;color:#4040FF;">Index:</font> '||rcd_index.index_name;
            var_work := var_work||' <font style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#ffffff;color:#4040FF;">Type:</font> '||rcd_index.index_type;
            var_work := var_work||' <font style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#ffffff;color:#4040FF;">Uniqueness:</font> '||rcd_index.uniqueness;
            var_work := var_work||'</td>';
            var_work := var_work||'</tr>';
            pipe row(var_work);
         end loop;
         close csr_index;

         /*-*/
         /* Retrieve the columns related to the table
         /*-*/
         var_work := '<tr>';
         var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#c0c0c0;color:#4040FF;;border:#000000 .5pt solid;" nowrap>Column</td>';
         var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#c0c0c0;color:#4040FF;;border:#000000 .5pt solid;" nowrap>Data Type</td>';
         var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#c0c0c0;color:#4040FF;;border:#000000 .5pt solid;" nowrap>Description</td>';
         var_work := var_work||'</tr>';
         pipe row(var_work);
         open csr_column;
         loop
            fetch csr_column into rcd_column;
            if csr_column%notfound then
               exit;
            end if;

            /*-*/
            /* Write the print data
            /*-*/
            var_work := '<tr>';
            if rcd_column.data_type = 'varchar2' then
               if rcd_column.char_used = 'B' then
                  var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>'||rcd_column.column_name||'</td>';
                  var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>varchar2('||rcd_column.data_length||') '||rcd_column.nullable||'</td>';
                  var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>'||rcd_column.comments||'</td>';
               else
                  var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>'||rcd_column.column_name||'</td>';
                  var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>varchar2('||rcd_column.char_length||' char) '||rcd_column.nullable||'</td>';
                  var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>'||rcd_column.comments||'</td>';
               end if;
            elsif rcd_column.data_type = 'date' then
               var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>'||rcd_column.column_name||'</td>';
               var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>date '||rcd_column.nullable||'</td>';
               var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>'||rcd_column.comments||'</td>';
            elsif rcd_column.data_type = 'number' then
               if rcd_column.data_precision is null then
                  var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>'||rcd_column.column_name||'</td>';
                  var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>number '||rcd_column.nullable||'</td>';
                  var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>'||rcd_column.comments||'</td>';
               else
                  var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>'||rcd_column.column_name||'</td>';
                  var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>number('||rcd_column.data_precision||','||rcd_column.data_scale||') '||rcd_column.nullable||'</td>';
                  var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>'||rcd_column.comments||'</td>';
               end if;
            else
               var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>'||rcd_column.column_name||'</td>';
               var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>'||rcd_column.data_type||' ('||rcd_column.data_length||') '||rcd_column.nullable||'</td>';
               var_work := var_work||'<td align=left style="font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;" nowrap>'||rcd_column.comments||'</td>';
            end if;
            var_work := var_work||'</tr>';
            pipe row(var_work);

         end loop;
         close csr_column;

      end loop;
      close csr_table;

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

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end table_doco;
/  

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_spreadsheet
 Owner   : lics_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Interface Control System - Spreadsheet

 The package implements the spreadsheet functionality.

 **note** this package assumes a single threaded execution.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/06   Steve Gregan   Created
 2007/11   Steve Gregan   Modified the XML parser for 10G behaviour

*******************************************************************************/

--set define ^;
--/

/*****************/
/* Package Types */
/*****************/
--drop type lics_spreadsheet_table;
create or replace type lics_spreadsheet_table as table of varchar2(4000 char);
/

/******************/
/* Package Header */
/******************/
create or replace package lics_spreadsheet as

   /*-*/
   /* Public type constants
   /*-*/
   TYPE_HEADING_01 varchar2(2) := 'H1';
   TYPE_HEADING_02 varchar2(2) := 'H2';
   TYPE_HEADING_03 varchar2(2) := 'H3';
   TYPE_HEADING_04 varchar2(2) := 'H4';
   TYPE_HEADING_05 varchar2(2) := 'H5';
   TYPE_HEADING_06 varchar2(2) := 'H6';
   TYPE_HEADING_07 varchar2(2) := 'H7';
   TYPE_HEADING_HI varchar2(2) := 'HH';
   TYPE_HEADING_SM varchar2(2) := 'HS';
   TYPE_SUMMARY_01 varchar2(2) := 'S1';
   TYPE_SUMMARY_02 varchar2(2) := 'S2';
   TYPE_SUMMARY_03 varchar2(2) := 'S3';
   TYPE_SUMMARY_04 varchar2(2) := 'S4';
   TYPE_SUMMARY_05 varchar2(2) := 'S5';
   TYPE_SUMMARY_06 varchar2(2) := 'S6';
   TYPE_SUMMARY_07 varchar2(2) := 'S7';
   TYPE_HEADING varchar2(2) := 'HE';
   TYPE_DETAIL varchar2(2) := 'DE';
   TYPE_PROTECT varchar2(2) := 'PR';
   TYPE_DETAIL_BOLD varchar2(2) := 'DB';
   TYPE_PROTECT_BOLD varchar2(2) := 'PB';
   TYPE_MARKER varchar2(2) := 'MA';
   TYPE_NONE varchar2(2) := 'NA';
   /*-*/
   FORMAT_CHAR_LEFT number := -1;
   FORMAT_CHAR_CENTRE number := -2;
   FORMAT_CHAR_RIGHT number := -3;
   FORMAT_NONE number := -9;
   FORMAT_DECIMAL_0 number := 0;
   FORMAT_DECIMAL_1 number := 1;
   FORMAT_DECIMAL_2 number := 2;
   FORMAT_DECIMAL_3 number := 3;
   FORMAT_DECIMAL_4 number := 4;
   FORMAT_DECIMAL_5 number := 5;
   FORMAT_DECIMAL_6 number := 6;
   FORMAT_DECIMAL_7 number := 7;
   FORMAT_DECIMAL_8 number := 8;
   FORMAT_DECIMAL_9 number := 9;
   FORMAT_DATE number := 51;
   /*-*/
   BORDER_ALL number := 1;
   BORDER_OUTLINE number := 2;
   BORDER_TOP number := 3;
   BORDER_BOTTOM number := 4;
   BORDER_LEFT number := 5;
   BORDER_RIGHT number := 6;
   BORDER_TOP_LEFT_RIGHT number := 7;
   BORDER_BOTTOM_LEFT_RIGHT number := 8;
   BORDER_TOP_BOTTOM number := 9;
   BORDER_LEFT_RIGHT number := 10;
   /*-*/
   BORDER_WEIGHT_DEFAULT number := null;
   BORDER_WEIGHT_THIN number := 1;
   BORDER_WEIGHT_MEDIUM number := 2;
   BORDER_WEIGHT_THICK number := 3;
   BORDER_WEIGHT_DOUBLE number := 4;
   /*-*/
   FILL_RIGHT number := 1;
   FILL_DOWN number := 2;
   FILL_LEFT number := 3;
   FILL_UP number := 4;
   /*-*/
   COPY_RIGHT number := 1;
   COPY_DOWN number := 2;

   /*-*/
   /* Public parent declarations
   /*-*/
   procedure write_spreadsheet(par_procedure in varchar2);
   procedure read_spreadsheet(par_procedure in varchar2);
   procedure get_data(par_buffer out varchar2);
   procedure set_data(par_buffer in varchar2);
   function get_table return lics_spreadsheet_table;

   /*-*/
   /* Public child read declarations
   /*-*/
   function read_sheet_count return number;
   function read_row_count(par_sidx in number) return number;
   function read_cell_count(par_sidx in number, par_ridx in number) return number;
   function read_sheet_identifier(par_sidx in number) return varchar2;
   function read_cell_string(par_sidx in number, par_ridx in number, par_cidx in number) return varchar2;
   function read_cell_number(par_sidx in number, par_ridx in number, par_cidx in number) return number;

   /*-*/
   /* Public child write declarations
   /*-*/
   function getHeadingType(parNumber in number) return varchar2;
   function getSummaryType(parNumber in number) return varchar2;
   function getColumnId(parNumber in number) return varchar2;
   procedure addSheet(parName in varchar2,
                      parProtect in boolean);
   procedure setRange(parRange in varchar2,
                      parMergeRange in varchar2,
                      parType in varchar2,
                      parFormat in number,
                      parIndent in number,
                      parUnlock in boolean,
                      parValue in varchar2);
   procedure setRangeArray(parRange in varchar2,
                           parFormatRange in varchar2,
                           parType in varchar2,
                           parFormat in number,
                           parUnlock in boolean,
                           parValue in varchar2);
   procedure setRangeFill(parRange in varchar2,
                          parFill in number);
   procedure setRangeCopy(parRange in varchar2,
                          parTimes in number,
                          parCopy in number);
   procedure setRangeBorder(parRange in varchar2,
                            parBorders in number,
                            parWeight in number);
   procedure setRangeType(parRange in varchar2,
                          parType in varchar2);
   procedure setRangeFormat(parRange in varchar2,
                            parFormat in number);
   procedure setHeadingBorder(parRange in varchar2,
                              parBorders in number,
                              parWeight in number);
   procedure setRowGroup(parRange in varchar2);
   procedure setFreezeCell(parRange in varchar2);
   procedure setPrintData(parRowRange in varchar2,
                          parColumnRange in varchar2,
                          parOrientation in number,
                          parFitWidthPages in number,
                          parZoom in number);
   procedure setPrintDataXML(parXML in varchar2);
   procedure addChart(parName in varchar2,
                      parTitle in varchar2,
                      parXTitle in varchar2,
                      parXNames in varchar2,
                      parYTitle in varchar2,
                      parOrientation in number);
   procedure addChartSeries(parName in varchar2,
                            parValues in varchar2);

end lics_spreadsheet;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_spreadsheet as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private parent definitions
   /*-*/
   var_wrks_status varchar2(32 char) := '*NONE';
   type rcd_wrks_dtas is record(she_iden varchar2(64 char),
                                she_rsix number,
                                she_reix number);
   type typ_wrks_dtas is table of rcd_wrks_dtas index by binary_integer;
   tbl_wrks_dtas typ_wrks_dtas;
   type rcd_wrks_dtar is record(row_csix number,
                                row_ceix number);
   type typ_wrks_dtar is table of rcd_wrks_dtar index by binary_integer;
   tbl_wrks_dtar typ_wrks_dtar;
   type typ_wrks_dtac is table of varchar2(2000 char) index by binary_integer;
   tbl_wrks_dtac typ_wrks_dtac;

   /*-*/
   /* Private child definitions
   /*-*/
   lobReference clob;
   intPosition integer;
   type typHeadingType is table of varchar2(2 char) index by binary_integer;
   tblHeadingType typHeadingType;
   type typSummaryType is table of varchar2(2 char) index by binary_integer;
   tblSummaryType typSummaryType;
   type typColumnType is table of varchar2(1 char) index by binary_integer;
   tblColumnType typColumnType;

   /*-*/
   /* Private child declarations
   /*-*/
   procedure read_xml_child(par_xml_node in xmlDom.domNode);
   procedure beginReport;
   procedure endReport;
   function getReport return varchar2;

   /*********************************************************/
   /* This procedure performs the write spreadsheet routine */
   /*********************************************************/
   procedure write_spreadsheet(par_procedure in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_procedure is null then
         raise_application_error(-20000, 'Write Spreadsheet - Spreadsheet write procedure must be supplied');
      end if;

      /*-*/
      /* Begin the report
      /*-*/
      beginReport;

      /*-*/
      /* Execute the spreadsheet write procedure
      /*-*/
      begin
         execute immediate 'begin ' || par_procedure || '; end;';
      exception
         when others then
            raise_application_error(-20000, 'Write Spreadsheet - Procedure (' || par_procedure || ') failed - ' || substr(SQLERRM, 1, 3000));
      end;

      /*-*/
      /* End the report
      /*-*/
      endReport;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end write_spreadsheet;

   /********************************************************/
   /* This procedure performs the read spreadsheet routine */
   /********************************************************/
   procedure read_spreadsheet(par_procedure in varchar2) is

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
      /* Validate the status
      /*-*/
      if var_wrks_status != '*LOADED' then
         raise_application_error(-20000, 'Read Spreadsheet - Spreadsheet data has not been loaded');
      end if;

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_procedure is null then
         raise_application_error(-20000, 'Read Spreadsheet - Spreadsheet read procedure must be supplied');
      end if;

      /*-*/
      /* Clear the value arrays
      /*-*/
      tbl_wrks_dtas.delete;
      tbl_wrks_dtar.delete;
      tbl_wrks_dtac.delete;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lobReference);
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve and process the primary node
      /*-*/
      obj_xml_element := xmlDom.getDocumentElement(obj_xml_document);
      obj_xml_node := xmlDom.makeNode(obj_xml_element);
      read_xml_child(obj_xml_node);

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Execute the spreadsheet read procedure
      /*-*/
      begin
         execute immediate 'begin ' || par_procedure || '; end;';
      exception
         when others then
            raise_application_error(-20000, 'Read Spreadsheet - Procedure (' || par_procedure || ') failed - ' || substr(SQLERRM, 1, 3000));
      end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_spreadsheet;

   /******************************************************/
   /* This procedure performs the read xml child routine */
   /******************************************************/
   procedure read_xml_child(par_xml_node in xmlDom.domNode) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_element xmlDom.domElement;
      obj_xml_node xmlDom.domNode;
      obj_xml_node_list xmlDom.domNodeList;
      var_string varchar2(32767);
      var_char varchar2(1 char);
      var_value varchar2(2000 char);
      var_index number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the attribute node
      /*-*/
      case upper(xmlDom.getNodeName(par_xml_node))
         when 'XLSTREAM' then
            null;
         when 'XLSHEET' then
            obj_xml_element := xmlDom.makeElement(par_xml_node);
            var_index := tbl_wrks_dtas.count + 1;
            tbl_wrks_dtas(var_index).she_iden := xmlDom.getAttribute(obj_xml_element,'IDENTIFIER');
            tbl_wrks_dtas(var_index).she_rsix := 0;
            tbl_wrks_dtas(var_index).she_reix := 0;
         when 'XR' then
            var_index := tbl_wrks_dtar.count + 1;
            tbl_wrks_dtar(var_index).row_csix := 0;
            tbl_wrks_dtar(var_index).row_ceix := 0;
            if tbl_wrks_dtas(tbl_wrks_dtas.count).she_rsix = 0 then
               tbl_wrks_dtas(tbl_wrks_dtas.count).she_rsix := var_index;
            end if;
            tbl_wrks_dtas(tbl_wrks_dtas.count).she_reix := var_index;
         when '#CDATA-SECTION' then
            begin
               var_string := xmlDom.getNodeValue(par_xml_node);
               var_value := null;
               for idx in 1..length(var_string) loop
                  var_char := substr(var_string,idx,1);
                  if var_char = chr(9) then
                     var_index := tbl_wrks_dtac.count + 1;
                     tbl_wrks_dtac(var_index) := var_value;
                     if tbl_wrks_dtar(tbl_wrks_dtar.count).row_csix = 0 then
                        tbl_wrks_dtar(tbl_wrks_dtar.count).row_csix := var_index;
                     end if;
                     tbl_wrks_dtar(tbl_wrks_dtar.count).row_ceix := var_index;
                     var_value := null;
                  else
                     var_value := var_value||var_char;
                  end if;
               end loop;
               var_index := tbl_wrks_dtac.count + 1;
               tbl_wrks_dtac(var_index) := var_value;
               if tbl_wrks_dtar(tbl_wrks_dtar.count).row_csix = 0 then
                  tbl_wrks_dtar(tbl_wrks_dtar.count).row_csix := var_index;
               end if;
               tbl_wrks_dtar(tbl_wrks_dtar.count).row_ceix := var_index;
            exception
               when others then
                  raise_application_error(-20000, 'Read Spreadsheet - Row (' || tbl_wrks_dtar.count || ' Cell (' || var_index || ') read failed - ' || substr(SQLERRM, 1, 1024));
            end;
            else raise_application_error(-20000, 'Read Spreadsheet - Type (' || xmlDom.getNodeName(par_xml_node) || ') not recognised');
         end case;

      /*-*/
      /* Process the child nodes
      /*-*/
      obj_xml_node_list := xmlDom.getChildNodes(par_xml_node);
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         read_xml_child(obj_xml_node);
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_xml_child;

   /************************************************/
   /* This procedure performs the get data routine */
   /************************************************/
   procedure get_data(par_buffer out varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the next buffer
      /*-*/
      par_buffer := getReport;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_data;

   /************************************************/
   /* This function performs the get table routine */
   /************************************************/
   function get_table return lics_spreadsheet_table is

      /*-*/
      /* Local definitions
      /*-*/
      var_vir_table lics_spreadsheet_table := lics_spreadsheet_table();
      strBuffer varchar2(4000 char);
      intSize binary_integer := 2000;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been created');
      end if;

      /*-*/
      /* Retrieve the clob in 2000 character chunks
      /*-*/
      loop

         /*-*/
         /* Retrieve the next chunk
         /*-*/
         begin
            dbms_lob.read(lobReference, intSize, intPosition, strBuffer);
            intPosition := intPosition + intSize;
         exception
            when no_data_found then
               intPosition := -1;
         end;
         if intPosition < 0 then
            exit;
         end if;

         /*-*/
         /* Append to the virtual table
         /*-*/
         var_vir_table.extend;
         var_vir_table(var_vir_table.last) := strBuffer;

      end loop;

      /*-*/
      /* Return the virtual table
      /*-*/
      return var_vir_table;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_table;

   /************************************************/
   /* This procedure performs the set data routine */
   /************************************************/
   procedure set_data(par_buffer in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the buffer
      /*-*/
      case par_buffer
         when '*STR' then
            if lobReference is null then
               dbms_lob.createtemporary(lobReference,true);
            end if;
            dbms_lob.trim(lobReference,0);
            var_wrks_status := '*LOADING';
         when '*END' then
            var_wrks_status := '*LOADED';
         else
            dbms_lob.writeappend(lobReference, length(par_buffer), par_buffer);
      end case;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_data;

   /*******************************************************/
   /* This function performs the read sheet count routine */
   /*******************************************************/
   function read_sheet_count return number is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the sheet count
      /*-*/
      return tbl_wrks_dtas.count;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_sheet_count;

   /*****************************************************/
   /* This function performs the read row count routine */
   /*****************************************************/
   function read_row_count(par_sidx in number) return number is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the sheet row count
      /*-*/
      if tbl_wrks_dtas.exists(par_sidx) then
         return tbl_wrks_dtas(par_sidx).she_reix - tbl_wrks_dtas(par_sidx).she_rsix + 1;
      end if;
      return 0;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_row_count;

   /******************************************************/
   /* This function performs the read cell count routine */
   /******************************************************/
   function read_cell_count(par_sidx in number, par_ridx in number) return number is

      /*-*/
      /* Variable definitions
      /*-*/
      var_ridx number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the sheet row cell count
      /*-*/
      if tbl_wrks_dtas.exists(par_sidx) then
         var_ridx := tbl_wrks_dtas(par_sidx).she_rsix + par_ridx - 1;
         if (var_ridx >= tbl_wrks_dtas(par_sidx).she_rsix and
             var_ridx <= tbl_wrks_dtas(par_sidx).she_reix) then
            if tbl_wrks_dtar.exists(var_ridx) then
               return tbl_wrks_dtar(var_ridx).row_ceix - tbl_wrks_dtar(var_ridx).row_csix + 1;
            end if;
         end if;
      end if;
      return 0;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_cell_count;

   /************************************************************/
   /* This function performs the read sheet identifier routine */
   /************************************************************/
   function read_sheet_identifier(par_sidx in number) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the sheet data when exists
      /*-*/
      if tbl_wrks_dtas.exists(par_sidx) then
         return tbl_wrks_dtas(par_sidx).she_iden;
      end if;
      return null;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_sheet_identifier;

   /*******************************************************/
   /* This function performs the read cell string routine */
   /*******************************************************/
   function read_cell_string(par_sidx in number, par_ridx in number, par_cidx in number) return varchar2 is

      /*-*/
      /* Variable definitions
      /*-*/
      var_ridx number;
      var_cidx number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the sheet row cell string value
      /*-*/
      if tbl_wrks_dtas.exists(par_sidx) then
         var_ridx := tbl_wrks_dtas(par_sidx).she_rsix + par_ridx - 1;
         if (var_ridx >= tbl_wrks_dtas(par_sidx).she_rsix and
             var_ridx <= tbl_wrks_dtas(par_sidx).she_reix) then
            var_cidx := tbl_wrks_dtar(var_ridx).row_csix + par_cidx - 1;
            if (var_cidx >= tbl_wrks_dtar(var_ridx).row_csix and
                var_cidx <= tbl_wrks_dtar(var_ridx).row_ceix) then
               if tbl_wrks_dtac.exists(var_cidx) then
                  return tbl_wrks_dtac(var_cidx);
               end if;
            end if;
         end if;
      end if;
      return null;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_cell_string;

   /*******************************************************/
   /* This function performs the read cell number routine */
   /*******************************************************/
   function read_cell_number(par_sidx in number, par_ridx in number, par_cidx in number) return number is

      /*-*/
      /* Variable definitions
      /*-*/
      var_ridx number;
      var_cidx number;
      var_return number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the sheet row cell number value
      /*-*/
      var_return := 0;
      if tbl_wrks_dtas.exists(par_sidx) then
         var_ridx := tbl_wrks_dtas(par_sidx).she_rsix + par_ridx - 1;
         if (var_ridx >= tbl_wrks_dtas(par_sidx).she_rsix and
             var_ridx <= tbl_wrks_dtas(par_sidx).she_reix) then
            var_cidx := tbl_wrks_dtar(var_ridx).row_csix + par_cidx - 1;
            if (var_cidx >= tbl_wrks_dtar(var_ridx).row_csix and
                var_cidx <= tbl_wrks_dtar(var_ridx).row_ceix) then
               if tbl_wrks_dtac.exists(var_cidx) then
                  begin
                     if substr(tbl_wrks_dtac(var_cidx),length(tbl_wrks_dtac(var_cidx)),1) = '-' then
                        var_return := to_number('-' || substr(tbl_wrks_dtac(var_cidx),1,length(tbl_wrks_dtac(var_cidx)) - 1));
                     else
                        var_return := to_number(tbl_wrks_dtac(var_cidx));
                     end if;
                  exception
                     when others then
                        var_return := 0;
                  end;
               end if;
            end if;
         end if;
      end if;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_cell_number;

   /************************************/
   /* This procedure begins the report */
   /************************************/
   procedure beginReport is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the status
      /*-*/
      var_wrks_status := '*REPORTING';

      /*-*/
      /* Clear the xml data
      /*-*/
      if lobReference is null then
         dbms_lob.createtemporary(lobReference,true);
      end if;
      dbms_lob.trim(lobReference,0);

      /*-*/
      /* Output the XML wrapper start
      /*-*/
      dbms_lob.writeappend(lobReference, length('<?xml version="1.0"?>'), '<?xml version="1.0"?>');
      dbms_lob.writeappend(lobReference, length('<XLREPORT>'), '<XLREPORT>');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end beginReport;

   /**********************************/
   /* This procedure ends the report */
   /**********************************/
   procedure endReport is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the status
      /*-*/
      var_wrks_status := '*REPORTING';

      /*-*/
      /* Output the XML wrapper end
      /*-*/
      dbms_lob.writeappend(lobReference, length('</XLREPORT>'), '</XLREPORT>');
      intPosition := 1;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end endReport;

   /**********************************/
   /* This procedure gets the report */
   /**********************************/
   function getReport return varchar2 is

      /*-*/
      /* Variable definitions
      /*-*/
      strBuffer varchar2(4000 char);
      intSize binary_integer := 4000;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been created');
      end if;

      /*-*/
      /* Return the next data buffer
      /*-*/
      begin
         dbms_lob.read(lobReference, intSize, intPosition, strBuffer);
         intPosition := intPosition + intSize;
      exception
         when no_data_found then
            strBuffer := '*END';
      end;

      /*-*/
      /* Return the xml buffer
      /*-*/
      return strBuffer;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end getReport;

   /*******************************************************/
   /* This function performs the get heading type routine */
   /*******************************************************/
   function getHeadingType(parNumber in number) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the heading type
      /*-*/
      return tblHeadingType(parNumber);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end getHeadingType;

   /*******************************************************/
   /* This function performs the get summary type routine */
   /*******************************************************/
   function getSummaryType(parNumber in number) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the heading type
      /*-*/
      return tblSummaryType(parNumber);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end getSummaryType;

   /***********************************************************/
   /* This function performs the get column idntifier routine */
   /***********************************************************/
   function getColumnId(parNumber in number) return varchar2 is

      /*-*/
      /* Variable definitions
      /*-*/
      var_return varchar2(2 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Generate the column identifier
      /*-*/
      var_return := null;
      if parNumber <= 26 then
         var_return := tblColumnType(parNumber);
      elsif parNumber <= 52 then
         var_return := 'A' || tblColumnType(parNumber-26);
      elsif parNumber <= 78 then
         var_return := 'B' || tblColumnType(parNumber-52);
      elsif parNumber <= 104 then
         var_return := 'C' || tblColumnType(parNumber-78);
      elsif parNumber <= 130 then
         var_return := 'D' || tblColumnType(parNumber-104);
      elsif parNumber <= 156 then
         var_return := 'E' || tblColumnType(parNumber-130);
      elsif parNumber <= 182 then
         var_return := 'F' || tblColumnType(parNumber-156);
      elsif parNumber <= 208 then
         var_return := 'G' || tblColumnType(parNumber-182);
      elsif parNumber <= 234 then
         var_return := 'H' || tblColumnType(parNumber-208);
      elsif parNumber <= 256 then
         var_return := 'I' || tblColumnType(parNumber-234);
      end if;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end getColumnId;
  
   /************************************************/
   /* This procedure defines the add sheet command */
   /************************************************/
   procedure addSheet(parName in varchar2,
                      parProtect in boolean) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<W1';
      strXML := strXML || ' P1="' || replace(replace(parName,'"','&#34;'),'&','&amp;') || '"';
      if parProtect = true then
         strXML := strXML || ' P2="1"';
      end if;
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end addSheet;

   /************************************************/
   /* This procedure defines the set range command */
   /************************************************/
   procedure setRange(parRange in varchar2,
                      parMergeRange in varchar2,
                      parType in varchar2,
                      parFormat in number,
                      parIndent in number,
                      parUnlock in boolean,
                      parValue in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<S1';
      strXML := strXML || ' P1="' || parRange || '"';
      if parMergeRange is not null then
         strXML := strXML || ' P2="' || parMergeRange || '"';
      end if;
      strXML := strXML || ' P3="' || parType || '"';
      strXML := strXML || ' P4="' || to_char(parFormat,'FM90') || '"';
      strXML := strXML || ' P5="' || to_char(parIndent,'FM90') || '"';
      if parUnlock = true then
         strXML := strXML || ' P6="1"';
      end if;
      strXML := strXML || '>';
      strXML := strXML || '<![CDATA[';
      strXML := strXML || parValue;
      strXML := strXML || ']]>';
      strXML := strXML || '</S1>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end setRange;

   /******************************************************/
   /* This procedure defines the set range array command */
   /******************************************************/
   procedure setRangeArray(parRange in varchar2,
                           parFormatRange in varchar2,
                           parType in varchar2,
                           parFormat in number,
                           parUnlock in boolean,
                           parValue in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<S2';
      strXML := strXML || ' P1="' || parRange || '"';
      if parFormatRange is not null then
         strXML := strXML || ' P2="' || parFormatRange || '"';
         strXML := strXML || ' P3="' || parType || '"';
         strXML := strXML || ' P4="' || to_char(parFormat,'FM90') || '"';
      end if;
      if parUnlock = true then
         strXML := strXML || ' P5="1"';
      end if;
      strXML := strXML || '>';
      strXML := strXML || '<![CDATA[';
      strXML := strXML || parValue;
      strXML := strXML || ']]>';
      strXML := strXML || '</S2>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end setRangeArray;

   /*****************************************************/
   /* This procedure defines the set range fill command */
   /*****************************************************/
   procedure setRangeFill(parRange in varchar2,
                          parFill in number) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<SA';
      strXML := strXML || ' P1="' || parRange || '"';
      strXML := strXML || ' P2="' || to_char(parFill) || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end setRangeFill;

   /*****************************************************/
   /* This procedure defines the set range copy command */
   /*****************************************************/
   procedure setRangeCopy(parRange in varchar2,
                          parTimes in number,
                          parCopy in number) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<SB';
      strXML := strXML || ' P1="' || parRange || '"';
      strXML := strXML || ' P2="' || to_char(parTimes) || '"';
      strXML := strXML || ' P3="' || to_char(parCopy) || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end setRangeCopy;

   /*******************************************************/
   /* This procedure defines the set range border command */
   /*******************************************************/
   procedure setRangeBorder(parRange in varchar2,
                            parBorders in number,
                            parWeight in number) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<S3';
      strXML := strXML || ' P1="' || parRange || '"';
      strXML := strXML || ' P2="' || to_char(parBorders) || '"';
      strXML := strXML || ' P3="' || to_char(parWeight) || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end setRangeBorder;

   /*****************************************************/
   /* This procedure defines the set range type command */
   /*****************************************************/
   procedure setRangeType(parRange in varchar2,
                          parType in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<S4';
      strXML := strXML || ' P1="' || parRange || '"';
      strXML := strXML || ' P2="' || parType || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end setRangeType;

   /*******************************************************/
   /* This procedure defines the set range format command */
   /*******************************************************/
   procedure setRangeFormat(parRange in varchar2,
                            parFormat in number) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<S5';
      strXML := strXML || ' P1="' || parRange || '"';
      strXML := strXML || ' P2="' || to_char(parFormat) || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end setRangeFormat;

   /*********************************************************/
   /* This procedure defines the set heading border command */
   /*********************************************************/
   procedure setHeadingBorder(parRange in varchar2,
                              parBorders in number,
                              parWeight in number) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<S6';
      strXML := strXML || ' P1="' || parRange || '"';
      strXML := strXML || ' P2="' || to_char(parBorders) || '"';
      strXML := strXML || ' P3="' || to_char(parWeight) || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end setHeadingBorder;

   /****************************************************/
   /* This procedure defines the set row group command */
   /****************************************************/
   procedure setRowGroup(parRange in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<S7';
      strXML := strXML || ' P1="' || parRange || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end setRowGroup;

   /******************************************************/
   /* This procedure defines the set freeze cell command */
   /******************************************************/
   procedure setFreezeCell(parRange in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<S8';
      strXML := strXML || ' P1="' || parRange || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end setFreezeCell;

   /********************************************************/
   /* This procedure defines the set print heading command */
   /********************************************************/
   procedure setPrintData(parRowRange in varchar2,
                          parColumnRange in varchar2,
                          parOrientation in number,
                          parFitWidthPages in number,
                          parZoom in number) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<S9';
      strXML := strXML || ' P1="' || parRowRange || '"';
      strXML := strXML || ' P2="' || parColumnRange || '"';
      strXML := strXML || ' P3="' || to_char(parOrientation,'FM990') || '"';
      strXML := strXML || ' P4="' || to_char(parFitWidthPages,'FM990') || '"';
      strXML := strXML || ' P5="' || to_char(parZoom,'FM990') || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end setPrintData;

   /************************************************************/
   /* This procedure defines the set print heading XML command */
   /************************************************************/
   procedure setPrintDataXML(parXML in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<' || parXML || '/>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end setPrintDataXML;

   /************************************************/
   /* This procedure defines the add chart command */
   /************************************************/
   procedure addChart(parName in varchar2,
                      parTitle in varchar2,
                      parXTitle in varchar2,
                      parXNames in varchar2,
                      parYTitle in varchar2,
                      parOrientation in number) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<W2';
      strXML := strXML || ' P1="' || replace(replace(parName,'"','&#34;'),'&','&amp;') || '"';
      strXML := strXML || ' P2="' || replace(parTitle,'"','&#34;') || '"';
      strXML := strXML || ' P3="' || replace(parXTitle,'"','&#34;') || '"';
      strXML := strXML || ' P4="' || replace(parXNames,'"','&#34;') || '"';
      strXML := strXML || ' P5="' || replace(parYTitle,'"','&#34;') || '"';
      strXML := strXML || ' P6="' || to_char(parOrientation,'FM990') || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end addChart;

   /*******************************************************/
   /* This procedure defines the add chart series command */
   /*******************************************************/
   procedure addChartSeries(parName in varchar2,
                            parValues in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*REPORTING' then
         raise_application_error(-20000, 'Report has not been started');
      end if;

      /*-*/
      /* Construct the instruction XML
      /*-*/
      strXML := '<C1';
      strXML := strXML || ' P1="' || replace(parName,'"','&#34;') || '"';
      strXML := strXML || ' P2="' || parValues || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end addChartSeries;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package variables
   /*-*/
   tblColumnType(1) := 'A';
   tblColumnType(2) := 'B';
   tblColumnType(3) := 'C';
   tblColumnType(4) := 'D';
   tblColumnType(5) := 'E';
   tblColumnType(6) := 'F';
   tblColumnType(7) := 'G';
   tblColumnType(8) := 'H';
   tblColumnType(9) := 'I';
   tblColumnType(10) := 'J';
   tblColumnType(11) := 'K';
   tblColumnType(12) := 'L';
   tblColumnType(13) := 'M';
   tblColumnType(14) := 'N';
   tblColumnType(15) := 'O';
   tblColumnType(16) := 'P';
   tblColumnType(17) := 'Q';
   tblColumnType(18) := 'R';
   tblColumnType(19) := 'S';
   tblColumnType(20) := 'T';
   tblColumnType(21) := 'U';
   tblColumnType(22) := 'V';
   tblColumnType(23) := 'W';
   tblColumnType(24) := 'X';
   tblColumnType(25) := 'Y';
   tblColumnType(26) := 'Z';
   tblHeadingType(1) := TYPE_HEADING_01;
   tblHeadingType(2) := TYPE_HEADING_02;
   tblHeadingType(3) := TYPE_HEADING_03;
   tblHeadingType(4) := TYPE_HEADING_04;
   tblHeadingType(5) := TYPE_HEADING_05;
   tblHeadingType(6) := TYPE_HEADING_06;
   tblHeadingType(7) := TYPE_HEADING_07;
   tblSummaryType(1) := TYPE_SUMMARY_01;
   tblSummaryType(2) := TYPE_SUMMARY_02;
   tblSummaryType(3) := TYPE_SUMMARY_03;
   tblSummaryType(4) := TYPE_SUMMARY_04;
   tblSummaryType(5) := TYPE_SUMMARY_05;
   tblSummaryType(6) := TYPE_SUMMARY_06;
   tblSummaryType(7) := TYPE_SUMMARY_07;

end lics_spreadsheet;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_spreadsheet for lics_app.lics_spreadsheet;
grant execute on lics_spreadsheet to public;
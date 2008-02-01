/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Reporting                                      */
/* Package : xlxml_object                                       */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : June 2003                                          */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package xlxml_object as

   /*-*/
   /* Public type constants */
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

   /*-*/
   /* Public methods */
   /*-*/
   function getHeadingType(par_number in number) return varchar2;
   function getSummaryType(par_number in number) return varchar2;
   function getColumnId(par_number in number) return varchar2;
   procedure beginReport;
   procedure addSheet(parName in varchar2);
   procedure setRange(parRange in varchar2,
                      parMergeRange in varchar2,
                      parType in varchar2,
                      parFormat in number,
                      parIndent in number,
                      parBullet in boolean,
                      parValue in varchar2);
   procedure setRangeArray(parRange in varchar2,
                           parFormatRange in varchar2,
                           parType in varchar2,
                           parFormat in number,
                           parValue in varchar2);
   procedure setRangeBorder(parRange in varchar2);
   procedure setRangeType(parRange in varchar2,
                          parType in varchar2);
   procedure setRangeFormat(parRange in varchar2,
                            parFormat in number);
   procedure setHeadingBorder(parRange in varchar2,
                              parBorders in varchar2);
   procedure setRowGroup(parRange in varchar2);
   procedure setFreezeCell(parRange in varchar2);
   procedure setPrintData(parRowRange in varchar2,
                          parColumnRange in varchar2,
                          parOrientation in number,
                          parFitWidthPages in number,
                          parZoom in number);
   procedure setPrintDataXML(parXML in varchar2);
   procedure getReport(par_XML out varchar2);
   function getSize return number;
   procedure addChart(parName in varchar2,
                      parTitle in varchar2,
                      parXTitle in varchar2,
                      parXNames in varchar2,
                      parYTitle in varchar2,
                      parOrientation in number);
   procedure addChartSeries(parName in varchar2,
                            parValues in varchar2);

end xlxml_object;
/

/****************/
/* Package Body */
/****************/
create or replace package body xlxml_object as

   /*-*/
   /* Private global variables */
   /*-*/
   lobReference clob;
   intPosition integer;
   type typHeadingType is table of varchar2(2 char) index by binary_integer;
   tblHeadingType typHeadingType;
   type typSummaryType is table of varchar2(2 char) index by binary_integer;
   tblSummaryType typSummaryType;
   type typColumnType is table of varchar2(1 char) index by binary_integer;
   tblColumnType typColumnType;

   /*******************************************************/
   /* This function performs the get heading type routine */
   /*******************************************************/
   function getHeadingType(par_number in number) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the heading type */
      /*-*/
      return tblHeadingType(par_number);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end getHeadingType;

   /*******************************************************/
   /* This function performs the get summary type routine */
   /*******************************************************/
   function getSummaryType(par_number in number) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the heading type */
      /*-*/
      return tblSummaryType(par_number);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end getSummaryType;

   /***********************************************************/
   /* This function performs the get column idntifier routine */
   /***********************************************************/
   function getColumnId(par_number in number) return varchar2 is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_return varchar2(2 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Generate the column identifier */
      /*-*/
      var_return := null;
      if par_number <= 26 then
         var_return := tblColumnType(par_number);
      elsif par_number <= 52 then
         var_return := 'A' || tblColumnType(par_number-26);
      elsif par_number <= 78 then
         var_return := 'B' || tblColumnType(par_number-52);
      elsif par_number <= 104 then
         var_return := 'C' || tblColumnType(par_number-78);
      elsif par_number <= 130 then
         var_return := 'D' || tblColumnType(par_number-104);
      elsif par_number <= 156 then
         var_return := 'E' || tblColumnType(par_number-130);
      elsif par_number <= 182 then
         var_return := 'F' || tblColumnType(par_number-156);
      elsif par_number <= 208 then
         var_return := 'G' || tblColumnType(par_number-182);
      elsif par_number <= 234 then
         var_return := 'H' || tblColumnType(par_number-208);
      elsif par_number <= 256 then
         var_return := 'I' || tblColumnType(par_number-234);
      end if;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end getColumnId;
  
   /************************************/
   /* This procedure begins the report */
   /************************************/
   procedure beginReport is

      /**/
      /* Variable definitions */
      /**/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the xml data */
      /*-*/
      if lobReference is null then 
         dbms_lob.createtemporary(lobReference,true);
      end if;
      dbms_lob.trim(lobReference,0);
      intPosition := 1;

      /*-*/
      /* Output the XML wrapper start */
      /*-*/
      dbms_lob.writeappend(lobReference, length('<?xml version="1.0"?>'), '<?xml version="1.0"?>');
      dbms_lob.writeappend(lobReference, length('<XLREPORT>'), '<XLREPORT>');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end beginReport;

   /************************************************/
   /* This procedure defines the add sheet command */
   /************************************************/
   procedure addSheet(parName in varchar2) is

      /**/
      /* Variable definitions */
      /**/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the instruction XML */
      /*-*/
      strXML := '<AddSheet';
      strXML := strXML || ' Name="' || replace(parName,'"','&#34;') || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML */
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
                      parBullet in boolean,
                      parValue in varchar2) is

      /**/
      /* Variable definitions */
      /**/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the instruction XML */
      /*-*/
      strXML := '<SetRange';
      strXML := strXML || ' range="' || parRange || '"';
      if parMergeRange is not null then
         strXML := strXML || ' mergeRange="' || parMergeRange || '"';
      end if;
      strXML := strXML || ' type="' || parType || '"';
      strXML := strXML || ' format="' || to_char(parFormat,'FM90') || '"';
      strXML := strXML || ' indent="' || to_char(parIndent,'FM90') || '"';
      if parBullet = true then
         strXML := strXML || ' bullet="1"';
      end if;
      strXML := strXML || '>';
      strXML := strXML || '<![CDATA[';
      strXML := strXML || parValue;
      strXML := strXML || ']]>';
      strXML := strXML || '</SetRange>';

      /*-*/
      /* Output the instruction XML */
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
                           parValue in varchar2) is

      /**/
      /* Variable definitions */
      /**/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the instruction XML */
      /*-*/
      strXML := '<SetRangeArray';
      strXML := strXML || ' range="' || parRange || '"';
      if parFormatRange is not null then
         strXML := strXML || ' formatRange="' || parFormatRange || '"';
         strXML := strXML || ' type="' || parType || '"';
         strXML := strXML || ' format="' || to_char(parFormat,'FM90') || '"';
      end if;
      strXML := strXML || '>';
      strXML := strXML || '<![CDATA[';
      strXML := strXML || parValue;
      strXML := strXML || ']]>';
      strXML := strXML || '</SetRangeArray>';

      /*-*/
      /* Output the instruction XML */
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end setRangeArray;

   /*******************************************************/
   /* This procedure defines the set range border command */
   /*******************************************************/
   procedure setRangeBorder(parRange in varchar2) is

      /**/
      /* Variable definitions */
      /**/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the instruction XML */
      /*-*/
      strXML := '<SetRangeBorder';
      strXML := strXML || ' range="' || parRange || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML */
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

      /**/
      /* Variable definitions */
      /**/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the instruction XML */
      /*-*/
      strXML := '<SetRangeType';
      strXML := strXML || ' range="' || parRange || '"';
      strXML := strXML || ' type="' || parType || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML */
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

      /**/
      /* Variable definitions */
      /**/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the instruction XML */
      /*-*/
      strXML := '<SetRangeFormat';
      strXML := strXML || ' range="' || parRange || '"';
      strXML := strXML || ' format="' || to_char(parFormat) || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML */
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
                              parBorders in varchar2) is

      /**/
      /* Variable definitions */
      /**/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the instruction XML */
      /*-*/
      strXML := '<SetHeadingBorder';
      strXML := strXML || ' range="' || parRange || '"';
      strXML := strXML || ' borders="' || parBorders || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML */
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

      /**/
      /* Variable definitions */
      /**/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the instruction XML */
      /*-*/
      strXML := '<SetRowGroup';
      strXML := strXML || ' range="' || parRange || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML */
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

      /**/
      /* Variable definitions */
      /**/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the instruction XML */
      /*-*/
      strXML := '<SetFreezeCell';
      strXML := strXML || ' range="' || parRange || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML */
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

      /**/
      /* Variable definitions */
      /**/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the instruction XML */
      /*-*/
      strXML := '<SetPrintData';
      strXML := strXML || ' RowRange="' || parRowRange || '"';
      strXML := strXML || ' ColumnRange="' || parColumnRange || '"';
      strXML := strXML || ' Orientation="' || to_char(parOrientation,'FM990') || '"';
      strXML := strXML || ' FitWidthPages="' || to_char(parFitWidthPages,'FM990') || '"';
      strXML := strXML || ' Zoom="' || to_char(parZoom,'FM990') || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML */
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

      /**/
      /* Variable definitions */
      /**/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the instruction XML */
      /*-*/
      strXML := '<' || parXML || '/>';

      /*-*/
      /* Output the instruction XML */
      /*-*/
      dbms_lob.writeappend(lobReference, length(strXML), strXML);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end setPrintDataXML;

   /**********************************/
   /* This procedure gets the report */
   /**********************************/
   procedure getReport(par_XML out varchar2) is

      /**/
      /* Variable definitions */
      /**/
      strBuffer varchar2(4000 char);
      intSize binary_integer := 4000;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Output the XML wrapper end when required */
      /*-*/
      if intPosition = 1 then
         dbms_lob.writeappend(lobReference, length('</XLREPORT>'), '</XLREPORT>');
      end if;

      /*-*/
      /* Return the next data buffer */
      /*-*/
      begin
         dbms_lob.read(lobReference, intSize, intPosition, strBuffer);
         intPosition := intPosition + intSize;
      exception
         when no_data_found then
            strBuffer := '**';
      end;

      /*-*/
      /* Return the xml buffer */
      /*-*/
      par_XML := strBuffer;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end getReport;

   /***********************************************/
   /* This function performs the get size routine */
   /***********************************************/
   function getSize return number is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the xml string size */
      /*-*/
      return dbms_lob.getlength(lobReference) + length('</XLREPORT>');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end getSize;

   /************************************************/
   /* This procedure defines the add chart command */
   /************************************************/
   procedure addChart(parName in varchar2,
                      parTitle in varchar2,
                      parXTitle in varchar2,
                      parXNames in varchar2,
                      parYTitle in varchar2,
                      parOrientation in number) is

      /**/
      /* Variable definitions */
      /**/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the instruction XML */
      /*-*/
      strXML := '<AddChart';
      strXML := strXML || ' Name="' || replace(parName,'"','&#34;') || '"';
      strXML := strXML || ' Title="' || replace(parTitle,'"','&#34;') || '"';
      strXML := strXML || ' XTitle="' || replace(parXTitle,'"','&#34;') || '"';
      strXML := strXML || ' XNames="' || replace(parXNames,'"','&#34;') || '"';
      strXML := strXML || ' YTitle="' || replace(parYTitle,'"','&#34;') || '"';
      strXML := strXML || ' Orientation="' || to_char(parOrientation,'FM990') || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML */
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

      /**/
      /* Variable definitions */
      /**/
      strXML varchar2(4096 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the instruction XML */
      /*-*/
      strXML := '<AddChartSeries';
      strXML := strXML || ' Name="' || replace(parName,'"','&#34;') || '"';
      strXML := strXML || ' Values="' || parValues || '"';
      strXML := strXML || '/>';

      /*-*/
      /* Output the instruction XML */
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
   /* Initialise the package variables */
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

end xlxml_object;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym xlxml_object for pld_rep_app.xlxml_object;
grant execute on xlxml_object to public;
/******************/
/* Package Header */
/******************/
create or replace package lads_table_report as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_table_report
 Owner   : lads_app
 Author  : Steve Gregan - October 2006

 DESCRIPTION
 -----------
 Local Atlas Data Store - LADS Table Report

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Steve Gregan   Created

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure generate;

end lads_table_report;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_table_report as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure print_interface(par_interface in varchar2, par_text in varchar2);
   procedure print_table(par_table in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_row_count number;

   /************************************************/
   /* This procedure performs the generate routine */
   /************************************************/
   procedure generate is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /**/
      /* Print the LADS tables
      /**/
      print_interface('ATLLAD01','Control Recipe');
      print_table('LADS_CTL_REC_HPI');
      print_table('LADS_CTL_REC_TPI');
      print_table('LADS_CTL_REC_VPI');
      print_table('LADS_CTL_REC_TXT');
      print_interface('ATLLAD02','Stock Balance');
      print_table('LADS_STK_BAL_HDR');
      print_table('LADS_STK_BAL_DET');
      print_interface('ATLLAD03','ICB LLT Intransit');
      print_table('LADS_ICB_LLT_HDR');
      print_table('LADS_ICB_LLT_DET');
      print_interface('ATLLAD04','Material');
      print_table('LADS_MAT_HDR');
      print_table('LADS_MAT_PCH');
      print_table('LADS_MAT_PCR');
      print_table('LADS_MAT_PIH');
      print_table('LADS_MAT_PIE');
      print_table('LADS_MAT_PIR');
      print_table('LADS_MAT_PIT');
      print_table('LADS_MAT_PIM');
      print_table('LADS_MAT_PID');
      print_table('LADS_MAT_MOE');
      print_table('LADS_MAT_GME');
      print_table('LADS_MAT_LCD');
      print_table('LADS_MAT_MKT');
      print_table('LADS_MAT_MRC');
      print_table('LADS_MAT_ZMC');
      print_table('LADS_MAT_MRD');
      print_table('LADS_MAT_MPM');
      print_table('LADS_MAT_MVM');
      print_table('LADS_MAT_MUM');
      print_table('LADS_MAT_MPV');
      print_table('LADS_MAT_UOM');
      print_table('LADS_MAT_UOE');
      print_table('LADS_MAT_MBE');
      print_table('LADS_MAT_MGN');
      print_table('LADS_MAT_MLG');
      print_table('LADS_MAT_SAD');
      print_table('LADS_MAT_ZSD');
      print_table('LADS_MAT_TAX');
      print_table('LADS_MAT_TXH');
      print_table('LADS_MAT_TXL');
      print_interface('ATLLAD05','Price List');
      print_table('LADS_PRC_LST_HDR');
      print_table('LADS_PRC_LST_DET');
      print_table('LADS_PRC_LST_QUA');
      print_table('LADS_PRC_LST_VAL');
      print_interface('ATLLAD06','Classification');
      print_table('LADS_CLA_HDR');
      print_table('LADS_CLA_CLS');
      print_table('LADS_CLA_CHR');
      print_interface('ATLLAD07','Classification Master');
      print_table('LADS_CLA_MAS_HDR');
      print_table('LADS_CLA_MAS_DET');
      print_interface('ATLLAD08','Master Bill Of Material');
      print_table('LADS_MAT_BOM_HDR');
      print_table('LADS_MAT_BOM_DET');
      print_interface('ATLLAD09','Stock Transfer and Purchase Order');
      print_table('LADS_STO_PO_HDR');
      print_table('LADS_STO_PO_ORG');
      print_table('LADS_STO_PO_DAT');
      print_table('LADS_STO_PO_CON');
      print_table('LADS_STO_PO_PNR');
      print_table('LADS_STO_PO_REF');
      print_table('LADS_STO_PO_DEL');
      print_table('LADS_STO_PO_PAY');
      print_table('LADS_STO_PO_HTI');
      print_table('LADS_STO_PO_HTX');
      print_table('LADS_STO_PO_GEN');
      print_table('LADS_STO_PO_SCH');
      print_table('LADS_STO_PO_ITP');
      print_table('LADS_STO_PO_PAD');
      print_table('LADS_STO_PO_OID');
      print_table('LADS_STO_PO_SMY');
      print_interface('ATLLAD10','Reference Data');
      print_table('LADS_REF_HDR');
      print_table('LADS_REF_FLD');
      print_table('LADS_REF_DAT');
      print_interface('ATLLAD11','Customer');
      print_table('LADS_CUS_HDR');
      print_table('LADS_CUS_HTH');
      print_table('LADS_CUS_HTD');
      print_table('LADS_CUS_SAD');
      print_table('LADS_CUS_ZSD');
      print_table('LADS_CUS_ZSV');
      print_table('LADS_CUS_PFR');
      print_table('LADS_CUS_STX');
      print_table('LADS_CUS_LID');
      print_table('LADS_CUS_SAT');
      print_table('LADS_CUS_STD');
      print_table('LADS_CUS_CUD');
      print_table('LADS_CUS_CTX');
      print_table('LADS_CUS_CTE');
      print_table('LADS_CUS_CTD');
      print_table('LADS_CUS_BNK');
      print_table('LADS_CUS_UNL');
      print_table('LADS_CUS_PRP');
      print_table('LADS_CUS_PDP');
      print_table('LADS_CUS_CNT');
      print_table('LADS_CUS_VAT');
      print_table('LADS_CUS_PLM');
      print_table('LADS_CUS_MGV');
      print_table('LADS_CUS_MGE');
      print_interface('ATLLAD12','Invoice Summary');
      print_table('LADS_INV_SUM_HDR');
      print_table('LADS_INV_SUM_DET');
      print_interface('ATLLAD13','Sales Order');
      print_table('LADS_SAL_ORD_HDR');
      print_table('LADS_SAL_ORD_ORG');
      print_table('LADS_SAL_ORD_DAT');
      print_table('LADS_SAL_ORD_TAX');
      print_table('LADS_SAL_ORD_CON');
      print_table('LADS_SAL_ORD_PNR');
      print_table('LADS_SAL_ORD_PAD');
      print_table('LADS_SAL_ORD_REF');
      print_table('LADS_SAL_ORD_TOD');
      print_table('LADS_SAL_ORD_TOP');
      print_table('LADS_SAL_ORD_ADD');
      print_table('LADS_SAL_ORD_PCD');
      print_table('LADS_SAL_ORD_TXI');
      print_table('LADS_SAL_ORD_TXT');
      print_table('LADS_SAL_ORD_GEN');
      print_table('LADS_SAL_ORD_SOG');
      print_table('LADS_SAL_ORD_IRF');
      print_table('LADS_SAL_ORD_IAD');
      print_table('LADS_SAL_ORD_IDT');
      print_table('LADS_SAL_ORD_ITA');
      print_table('LADS_SAL_ORD_ICO');
      print_table('LADS_SAL_ORD_IPS');
      print_table('LADS_SAL_ORD_ISC');
      print_table('LADS_SAL_ORD_IPN');
      print_table('LADS_SAL_ORD_IPD');
      print_table('LADS_SAL_ORD_IID');
      print_table('LADS_SAL_ORD_IGT');
      print_table('LADS_SAL_ORD_ITD');
      print_table('LADS_SAL_ORD_ITP');
      print_table('LADS_SAL_ORD_IDD');
      print_table('LADS_SAL_ORD_ITX');
      print_table('LADS_SAL_ORD_ITT');
      print_table('LADS_SAL_ORD_ISS');
      print_table('LADS_SAL_ORD_ISR');
      print_table('LADS_SAL_ORD_ISD');
      print_table('LADS_SAL_ORD_IST');
      print_table('LADS_SAL_ORD_ISN');
      print_table('LADS_SAL_ORD_ISP');
      print_table('LADS_SAL_ORD_ISO');
      print_table('LADS_SAL_ORD_ISI');
      print_table('LADS_SAL_ORD_ISJ');
      print_table('LADS_SAL_ORD_ISX');
      print_table('LADS_SAL_ORD_ISY');
      print_table('LADS_SAL_ORD_SMY');
      print_interface('ATLLAD14','Shipment');
      print_table('LADS_SHP_HDR');
      print_table('LADS_SHP_HCT');
      print_table('LADS_SHP_HAR');
      print_table('LADS_SHP_HAD');
      print_table('LADS_SHP_HDA');
      print_table('LADS_SHP_HTX');
      print_table('LADS_SHP_HTG');
      print_table('LADS_SHP_HST');
      print_table('LADS_SHP_HSP');
      print_table('LADS_SHP_HSD');
      print_table('LADS_SHP_HSI');
      print_table('LADS_SHP_DLV');
      print_table('LADS_SHP_DAD');
      print_table('LADS_SHP_DAS');
      print_table('LADS_SHP_DED');
      print_table('LADS_SHP_DRS');
      print_table('LADS_SHP_DIT');
      print_table('LADS_SHP_DIB');
      print_table('LADS_SHP_DNG');
      print_table('LADS_SHP_DBT');
      print_table('LADS_SHP_DRF');
      print_table('LADS_SHP_DHU');
      print_table('LADS_SHP_DHI');
      print_interface('ATLLAD15','Address');
      print_table('LADS_ADR_HDR');
      print_table('LADS_ADR_DET');
      print_table('LADS_ADR_TEL');
      print_table('LADS_ADR_FAX');
      print_table('LADS_ADR_EMA');
      print_table('LADS_ADR_URL');
      print_table('LADS_ADR_COM');
      print_interface('ATLLAD16','Delivery');
      print_table('LADS_DEL_HDR');
      print_table('LADS_DEL_ADD');
      print_table('LADS_DEL_ADL');
      print_table('LADS_DEL_TIM');
      print_table('LADS_DEL_HTX');
      print_table('LADS_DEL_HTP');
      print_table('LADS_DEL_RTE');
      print_table('LADS_DEL_STG');
      print_table('LADS_DEL_NOD');
      print_table('LADS_DEL_DET');
      print_table('LADS_DEL_POD');
      print_table('LADS_DEL_INT');
      print_table('LADS_DEL_IRF');
      print_table('LADS_DEL_ERF');
      print_table('LADS_DEL_DTX');
      print_table('LADS_DEL_DTP');
      print_table('LADS_DEL_HUH');
      print_table('LADS_DEL_HUC');
      print_interface('ATLLAD17','Bill Of Material');
      print_table('LADS_BOM_HDR');
      print_table('LADS_BOM_DET');
      print_interface('ATLLAD18','Invoice');
      print_table('LADS_INV_HDR');
      print_table('LADS_INV_CUS');
      print_table('LADS_INV_CON');
      print_table('LADS_INV_PNR');
      print_table('LADS_INV_ADJ');
      print_table('LADS_INV_REF');
      print_table('LADS_INV_DAT');
      print_table('LADS_INV_DCN');
      print_table('LADS_INV_TAX');
      print_table('LADS_INV_TOD');
      print_table('LADS_INV_TOP');
      print_table('LADS_INV_CUR');
      print_table('LADS_INV_BNK');
      print_table('LADS_INV_FTD');
      print_table('LADS_INV_TXT');
      print_table('LADS_INV_TXI');
      print_table('LADS_INV_ORG');
      print_table('LADS_INV_SAL');
      print_table('LADS_INV_GEN');
      print_table('LADS_INV_MAT');
      print_table('LADS_INV_GRD');
      print_table('LADS_INV_IRF');
      print_table('LADS_INV_IDT');
      print_table('LADS_INV_IOB');
      print_table('LADS_INV_IAS');
      print_table('LADS_INV_IPN');
      print_table('LADS_INV_IAJ');
      print_table('LADS_INV_ICN');
      print_table('LADS_INV_ICP');
      print_table('LADS_INV_ITA');
      print_table('LADS_INV_IFT');
      print_table('LADS_INV_ICB');
      print_table('LADS_INV_ITX');
      print_table('LADS_INV_ITI');
      print_table('LADS_INV_SMY');
      print_interface('ATLLAD19','Vendor');
      print_table('LADS_VEN_HDR');
      print_table('LADS_VEN_TXH');
      print_table('LADS_VEN_TXL');
      print_table('LADS_VEN_CCD');
      print_table('LADS_VEN_ZCC');
      print_table('LADS_VEN_WTX');
      print_table('LADS_VEN_CTX');
      print_table('LADS_VEN_CTD');
      print_table('LADS_VEN_POH');
      print_table('LADS_VEN_POM');
      print_table('LADS_VEN_PTX');
      print_table('LADS_VEN_PTD');
      print_table('LADS_VEN_BNK');
      print_interface('ATLLAD20','Customer Hierarchy');
      print_table('LADS_HIE_CUS_HDR');
      print_table('LADS_HIE_CUS_DET');
      print_interface('ATLLAD21','Characteric Master');
      print_table('LADS_CHR_MAS_HDR');
      print_table('LADS_CHR_MAS_DET');
      print_table('LADS_CHR_MAS_VAL');
      print_table('LADS_CHR_MAS_DSC');
      print_interface('ATLLAD22','Exchange Rates');
      print_table('LADS_XCH_RAT_DET');
      print_interface('ATLLAD23','Stock Intransit');
      print_table('LADS_INT_STK_HDR');
      print_table('LADS_INT_STK_DET');
      print_interface('ATLLAD25','Generic ICB Export Documentation');
      print_table('LADS_EXP_HDR');
      print_table('LADS_EXP_ORD');
      print_table('LADS_EXP_HOR');
      print_table('LADS_EXP_ORG');
      print_table('LADS_EXP_DAT');
      print_table('LADS_EXP_PNR');
      print_table('LADS_EXP_GEN');
      print_table('LADS_EXP_ICO');
      print_table('LADS_EXP_SOR');
      print_table('LADS_EXP_DEL');
      print_table('LADS_EXP_HDE');
      print_table('LADS_EXP_ADD');
      print_table('LADS_EXP_TIM');
      print_table('LADS_EXP_DET');
      print_table('LADS_EXP_INT');
      print_table('LADS_EXP_IRF');
      print_table('LADS_EXP_ERF');
      print_table('LADS_EXP_HUH');
      print_table('LADS_EXP_HUC');
      print_table('LADS_EXP_SHP');
      print_table('LADS_EXP_HSH');
      print_table('LADS_EXP_HDA');
      print_table('LADS_EXP_HAR');
      print_table('LADS_EXP_HST');
      print_table('LADS_EXP_HSP');
      print_table('LADS_EXP_HSD');
      print_table('LADS_EXP_HSI');
      print_table('LADS_EXP_HAG');
      print_table('LADS_EXP_INV');
      print_table('LADS_EXP_HIN');
      print_table('LADS_EXP_IGN');
      print_table('LADS_EXP_IRE');
      print_table('LADS_EXP_ICN');
      print_table('LADS_EXP_SIN');
      print_table('LADS_EXP_IDT');
      print_interface('ATLLAD28','Open Purchase Order/Requisition');
      print_table('LADS_OPR_HDR');
      print_interface('ATLLAD29','Open Planned Process Orders');
      print_table('LADS_PPO_HDR');

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
         raise_application_error(-20000, 'FATAL ERROR - LADS - TABLE REPORT - GENERATE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end generate;

   /*******************************************************/
   /* This procedure performs the print interface routine */
   /*******************************************************/
   procedure print_interface(par_interface in varchar2, par_text in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Add the table sheet
      /*-*/
      lics_spreadsheet.addSheet(par_interface,false);

      /*-*/
      /* Set the sheet heading
      /*-*/
      lics_spreadsheet.setRange('A1:A1','A1:D1',lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Local Atlas Data Store Interfaces - '||par_interface||' - '||par_text);
      lics_spreadsheet.setRange('A2:A2',null,lics_spreadsheet.getHeadingType(2),lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Table/Column');
      lics_spreadsheet.setRange('B2:B2',null,lics_spreadsheet.getHeadingType(2),lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Description');
      lics_spreadsheet.setRange('C2:C2',null,lics_spreadsheet.getHeadingType(2),lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Attribute');
      lics_spreadsheet.setRange('D2:D2',null,lics_spreadsheet.getHeadingType(2),lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Primary Keys');
      lics_spreadsheet.setHeadingBorder('A1:D2',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);

      /*-*/
      /* Set the cell freeze
      /*-*/
      lics_spreadsheet.setFreezeCell('A3');

      /*-*/
      /* Reset the row count
      /*-*/
      var_row_count := 2;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end print_interface;

   /***************************************************/
   /* This procedure performs the print table routine */
   /***************************************************/
   procedure print_table(par_table in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_data varchar2(4000);
      var_sav_count number;
      var_count number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_table_01 is 
         select upper(t01.table_name) as table_name,
                t02.comments as comments
           from all_tables t01, all_tab_comments t02
          where t01.table_name = t02.table_name(+)
            and t01.table_name = par_table;
      rcd_lads_table_01 csr_lads_table_01%rowtype;

      cursor csr_lads_constraint_01 is 
         select lower(t01.column_name) as column_name
           from all_cons_columns t01
          where t01.table_name = par_table
            and t01.constraint_name = par_table || '_PK'
       order by t01.position asc;
      rcd_lads_constraint_01 csr_lads_constraint_01%rowtype;

      cursor csr_lads_column_01 is
         select lower(t01.column_name) as column_name,
                t02.comments as comments,
                case when lower(t01.data_type) = 'varchar2' then lower(t01.data_type) || '(' || to_char(t01.char_length) || ' char)' else lower(t01.data_type) end as data_type
           from all_tab_columns t01, all_col_comments t02
          where t01.table_name = t02.table_name(+)
            and t01.column_name = t02.column_name(+)
            and t01.table_name = par_table
       order by t01.column_id asc;
      rcd_lads_column_01 csr_lads_column_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the table
      /*-*/
      open csr_lads_table_01;
      fetch csr_lads_table_01 into rcd_lads_table_01;
      if csr_lads_table_01%found then

         /*-*/
         /* Initialise the data variable
         /*-*/
         var_data := rcd_lads_table_01.table_name || chr(9) || rcd_lads_table_01.comments || chr(9) || chr(9);

         /*-*/
         /* Retrieve the constraints related to the table
         /*-*/
         var_count := 0;
         open csr_lads_constraint_01;
         loop
            fetch csr_lads_constraint_01 into rcd_lads_constraint_01;
            if csr_lads_constraint_01%notfound then
               exit;
            end if;
            if var_count > 0 then
               var_data := var_data || ', ';
            end if;
            var_data := var_data || rcd_lads_constraint_01.column_name;
            var_count := var_count + 1;
         end loop;
         close csr_lads_constraint_01;

         /*-*/
         /* Output the sheet table row
         /*-*/
         var_row_count := var_row_count + 1;
         lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                        'A'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),
                                        lics_spreadsheet.getSummaryType(6),lics_spreadsheet.FORMAT_CHAR_LEFT,false,var_data);
         var_sav_count := var_row_count + 1;

         /*-*/
         /* Retrieve the columns related to the table
         /*-*/
         open csr_lads_column_01;
         loop
            fetch csr_lads_column_01 into rcd_lads_column_01;
            if csr_lads_column_01%notfound then
               exit;
            end if;

            /*-*/
            /* Output the sheet column row
            /*-*/
            var_row_count := var_row_count + 1;
            lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,1,false,rcd_lads_column_01.column_name);
            lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,rcd_lads_column_01.comments);
            lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,rcd_lads_column_01.data_type);

         end loop;
         close csr_lads_column_01;

         /*-*/
         /* Group the table
         /*-*/
         lics_spreadsheet.setRowGroup(to_char(var_sav_count,'FM999999990')||':'||to_char(var_row_count,'FM999999990'));

         /*-*/
         /* Border the table
         /*-*/
         lics_spreadsheet.setRangeBorder('A3:A'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('B3:B'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('C3:C'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('D3:D'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);

      end if;
      close csr_lads_table_01;

      /*-*/
      /* Set the print settings
      /*-*/
      lics_spreadsheet.setPrintData('$1:$2','$A:$A',2,1,0);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end print_table;

end lads_table_report;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_table_report for lads_app.lads_table_report;
grant execute on lads_table_report to public;

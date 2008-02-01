/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_doco
 Owner   : lads_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Atlas Data Store - Documentation

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_doco as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end lads_doco;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_doco as

   /*-*/
   /* Private definitions
   /*-*/
   var_fil_handle utl_file.file_type;

   /*-*/
   /* Private declarations
   /*-*/
   procedure print_data(par_table in varchar2);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /**/
      /* Open the print file 
      /**/
      var_fil_handle := utl_file.fopen('/tmp', 'lads_doco.txt', 'w', 32767);

      /**/
      /* Print the data 
      /**/
      utl_file.put_line(var_fil_handle, 'ATLLAD01' || chr(9) || 'Control Recipe Tables');
      print_data('LADS_CTL_REC_HPI');
      print_data('LADS_CTL_REC_TPI');
      print_data('LADS_CTL_REC_VPI');
      print_data('LADS_CTL_REC_TXT');
      utl_file.put_line(var_fil_handle, 'ATLLAD02' || chr(9) || 'Stock Balance Tables');
      print_data('LADS_STK_BAL_HDR');
      print_data('LADS_STK_BAL_DET');
      utl_file.put_line(var_fil_handle, 'ATLLAD03' || chr(9) || 'ICB LLT Intransit');
      print_data('LADS_ICB_LLT_HDR');
      print_data('LADS_ICB_LLT_DET');
      utl_file.put_line(var_fil_handle, 'ATLLAD04' || chr(9) || 'Material');
      print_data('LADS_MAT_HDR');
      print_data('LADS_MAT_PCH');
      print_data('LADS_MAT_PCR');
      print_data('LADS_MAT_PIH');
      print_data('LADS_MAT_PIE');
      print_data('LADS_MAT_PIR');
      print_data('LADS_MAT_PIT');
      print_data('LADS_MAT_PIM');
      print_data('LADS_MAT_PID');
      print_data('LADS_MAT_MOE');
      print_data('LADS_MAT_GME');
      print_data('LADS_MAT_LCD');
      print_data('LADS_MAT_MKT');
      print_data('LADS_MAT_MRC');
      print_data('LADS_MAT_ZMC');
      print_data('LADS_MAT_MRD');
      print_data('LADS_MAT_MPM');
      print_data('LADS_MAT_MVM');
      print_data('LADS_MAT_MUM');
      print_data('LADS_MAT_MPV');
      print_data('LADS_MAT_UOM');
      print_data('LADS_MAT_UOE');
      print_data('LADS_MAT_MBE');
      print_data('LADS_MAT_MGN');
      print_data('LADS_MAT_MLG');
      print_data('LADS_MAT_SAD');
      print_data('LADS_MAT_ZSD');
      print_data('LADS_MAT_TAX');
      print_data('LADS_MAT_TXH');
      print_data('LADS_MAT_TXL');
      utl_file.put_line(var_fil_handle, 'ATLLAD05' || chr(9) || 'Price List');
      print_data('LADS_PRC_LST_HDR');
      print_data('LADS_PRC_LST_DET');
      print_data('LADS_PRC_LST_QUA');
      print_data('LADS_PRC_LST_VAL');
      utl_file.put_line(var_fil_handle, 'ATLLAD06' || chr(9) || 'Classification');
      print_data('LADS_CLA_HDR');
      print_data('LADS_CLA_CLS');
      print_data('LADS_CLA_CHR');
      utl_file.put_line(var_fil_handle, 'ATLLAD07' || chr(9) || 'Classification Master');
      print_data('LADS_CLA_MAS_HDR');
      print_data('LADS_CLA_MAS_DET');
      utl_file.put_line(var_fil_handle, 'ATLLAD08' || chr(9) || 'Master Bill Of Material');
      print_data('LADS_MAT_BOM_HDR');
      print_data('LADS_MAT_BOM_DET');
      utl_file.put_line(var_fil_handle, 'ATLLAD09' || chr(9) || 'Stock Transfer and Purchase Order');
      print_data('LADS_STO_PO_HDR');
      print_data('LADS_STO_PO_ORG');
      print_data('LADS_STO_PO_DAT');
      print_data('LADS_STO_PO_CON');
      print_data('LADS_STO_PO_PNR');
      print_data('LADS_STO_PO_REF');
      print_data('LADS_STO_PO_DEL');
      print_data('LADS_STO_PO_PAY');
      print_data('LADS_STO_PO_HTI');
      print_data('LADS_STO_PO_HTX');
      print_data('LADS_STO_PO_GEN');
      print_data('LADS_STO_PO_SCH');
      print_data('LADS_STO_PO_ITP');
      print_data('LADS_STO_PO_PAD');
      print_data('LADS_STO_PO_OID');
      print_data('LADS_STO_PO_SMY');
      utl_file.put_line(var_fil_handle, 'ATLLAD10' || chr(9) || 'Reference Data');
      print_data('LADS_REF_HDR');
      print_data('LADS_REF_FLD');
      print_data('LADS_REF_DAT');
      utl_file.put_line(var_fil_handle, 'ATLLAD11' || chr(9) || 'Customer');
      print_data('LADS_CUS_HDR');
      print_data('LADS_CUS_HTH');
      print_data('LADS_CUS_HTD');
      print_data('LADS_CUS_SAD');
      print_data('LADS_CUS_ZSD');
      print_data('LADS_CUS_ZSV');
      print_data('LADS_CUS_PFR');
      print_data('LADS_CUS_STX');
      print_data('LADS_CUS_LID');
      print_data('LADS_CUS_SAT');
      print_data('LADS_CUS_STD');
      print_data('LADS_CUS_CUD');
      print_data('LADS_CUS_CTX');
      print_data('LADS_CUS_CTE');
      print_data('LADS_CUS_CTD');
      print_data('LADS_CUS_BNK');
      print_data('LADS_CUS_UNL');
      print_data('LADS_CUS_PRP');
      print_data('LADS_CUS_PDP');
      print_data('LADS_CUS_CNT');
      print_data('LADS_CUS_VAT');
      print_data('LADS_CUS_PLM');
      print_data('LADS_CUS_MGV');
      print_data('LADS_CUS_MGE');
      utl_file.put_line(var_fil_handle, 'ATLLAD12' || chr(9) || 'Invoice Summary');
      print_data('LADS_INV_SUM_HDR');
      print_data('LADS_INV_SUM_DET');
      utl_file.put_line(var_fil_handle, 'ATLLAD13' || chr(9) || 'Sales Order');
      print_data('LADS_SAL_ORD_HDR');
      print_data('LADS_SAL_ORD_ORG');
      print_data('LADS_SAL_ORD_DAT');
      print_data('LADS_SAL_ORD_TAX');
      print_data('LADS_SAL_ORD_CON');
      print_data('LADS_SAL_ORD_PNR');
      print_data('LADS_SAL_ORD_PAD');
      print_data('LADS_SAL_ORD_REF');
      print_data('LADS_SAL_ORD_TOD');
      print_data('LADS_SAL_ORD_TOP');
      print_data('LADS_SAL_ORD_ADD');
      print_data('LADS_SAL_ORD_PCD');
      print_data('LADS_SAL_ORD_TXI');
      print_data('LADS_SAL_ORD_TXT');
      print_data('LADS_SAL_ORD_GEN');
      print_data('LADS_SAL_ORD_SOG');
      print_data('LADS_SAL_ORD_IRF');
      print_data('LADS_SAL_ORD_IAD');
      print_data('LADS_SAL_ORD_IDT');
      print_data('LADS_SAL_ORD_ITA');
      print_data('LADS_SAL_ORD_ICO');
      print_data('LADS_SAL_ORD_IPS');
      print_data('LADS_SAL_ORD_ISC');
      print_data('LADS_SAL_ORD_IPN');
      print_data('LADS_SAL_ORD_IPD');
      print_data('LADS_SAL_ORD_IID');
      print_data('LADS_SAL_ORD_IGT');
      print_data('LADS_SAL_ORD_ITD');
      print_data('LADS_SAL_ORD_ITP');
      print_data('LADS_SAL_ORD_IDD');
      print_data('LADS_SAL_ORD_ITX');
      print_data('LADS_SAL_ORD_ITT');
      print_data('LADS_SAL_ORD_ISS');
      print_data('LADS_SAL_ORD_ISR');
      print_data('LADS_SAL_ORD_ISD');
      print_data('LADS_SAL_ORD_IST');
      print_data('LADS_SAL_ORD_ISN');
      print_data('LADS_SAL_ORD_ISP');
      print_data('LADS_SAL_ORD_ISO');
      print_data('LADS_SAL_ORD_ISI');
      print_data('LADS_SAL_ORD_ISJ');
      print_data('LADS_SAL_ORD_ISX');
      print_data('LADS_SAL_ORD_ISY');
      print_data('LADS_SAL_ORD_SMY');
      utl_file.put_line(var_fil_handle, 'ATLLAD14' || chr(9) || 'Shipment');
      print_data('LADS_SHP_HDR');
      print_data('LADS_SHP_HCT');
      print_data('LADS_SHP_HAR');
      print_data('LADS_SHP_HAD');
      print_data('LADS_SHP_HDA');
      print_data('LADS_SHP_HTX');
      print_data('LADS_SHP_HTG');
      print_data('LADS_SHP_HST');
      print_data('LADS_SHP_HSP');
      print_data('LADS_SHP_HSD');
      print_data('LADS_SHP_HSI');
      print_data('LADS_SHP_DLV');
      print_data('LADS_SHP_DAD');
      print_data('LADS_SHP_DAS');
      print_data('LADS_SHP_DED');
      print_data('LADS_SHP_DRS');
      print_data('LADS_SHP_DIT');
      print_data('LADS_SHP_DIB');
      print_data('LADS_SHP_DNG');
      print_data('LADS_SHP_DBT');
      print_data('LADS_SHP_DRF');
      print_data('LADS_SHP_DHU');
      print_data('LADS_SHP_DHI');
      utl_file.put_line(var_fil_handle, 'ATLLAD15' || chr(9) || 'Address');
      print_data('LADS_ADR_HDR');
      print_data('LADS_ADR_DET');
      print_data('LADS_ADR_TEL');
      print_data('LADS_ADR_FAX');
      print_data('LADS_ADR_EMA');
      print_data('LADS_ADR_URL');
      print_data('LADS_ADR_COM');
      utl_file.put_line(var_fil_handle, 'ATLLAD16' || chr(9) || 'Delivery');
      print_data('LADS_DEL_HDR');
      print_data('LADS_DEL_ADD');
      print_data('LADS_DEL_ADL');
      print_data('LADS_DEL_TIM');
      print_data('LADS_DEL_HTX');
      print_data('LADS_DEL_HTP');
      print_data('LADS_DEL_RTE');
      print_data('LADS_DEL_STG');
      print_data('LADS_DEL_NOD');
      print_data('LADS_DEL_DET');
      print_data('LADS_DEL_POD');
      print_data('LADS_DEL_INT');
      print_data('LADS_DEL_IRF');
      print_data('LADS_DEL_ERF');
      print_data('LADS_DEL_DTX');
      print_data('LADS_DEL_DTP');
      print_data('LADS_DEL_HUH');
      print_data('LADS_DEL_HUC');
      utl_file.put_line(var_fil_handle, 'ATLLAD17' || chr(9) || 'Bill Of Material');
      print_data('LADS_BOM_HDR');
      print_data('LADS_BOM_DET');
      utl_file.put_line(var_fil_handle, 'ATLLAD18' || chr(9) || 'Invoice');
      print_data('LADS_INV_HDR');
      print_data('LADS_INV_CUS');
      print_data('LADS_INV_CON');
      print_data('LADS_INV_PNR');
      print_data('LADS_INV_ADJ');
      print_data('LADS_INV_REF');
      print_data('LADS_INV_DAT');
      print_data('LADS_INV_DCN');
      print_data('LADS_INV_TAX');
      print_data('LADS_INV_TOD');
      print_data('LADS_INV_TOP');
      print_data('LADS_INV_CUR');
      print_data('LADS_INV_BNK');
      print_data('LADS_INV_FTD');
      print_data('LADS_INV_TXT');
      print_data('LADS_INV_TXI');
      print_data('LADS_INV_ORG');
      print_data('LADS_INV_SAL');
      print_data('LADS_INV_GEN');
      print_data('LADS_INV_MAT');
      print_data('LADS_INV_GRD');
      print_data('LADS_INV_IRF');
      print_data('LADS_INV_IDT');
      print_data('LADS_INV_IOB');
      print_data('LADS_INV_IAS');
      print_data('LADS_INV_IPN');
      print_data('LADS_INV_IAJ');
      print_data('LADS_INV_ICN');
      print_data('LADS_INV_ICP');
      print_data('LADS_INV_ITA');
      print_data('LADS_INV_IFT');
      print_data('LADS_INV_ICB');
      print_data('LADS_INV_ITX');
      print_data('LADS_INV_ITI');
      print_data('LADS_INV_SMY');
      utl_file.put_line(var_fil_handle, 'ATLLAD19' || chr(9) || 'Vendor');
      print_data('LADS_VEN_HDR');
      print_data('LADS_VEN_TXH');
      print_data('LADS_VEN_TXL');
      print_data('LADS_VEN_CCD');
      print_data('LADS_VEN_ZCC');
      print_data('LADS_VEN_WTX');
      print_data('LADS_VEN_CTX');
      print_data('LADS_VEN_CTD');
      print_data('LADS_VEN_POH');
      print_data('LADS_VEN_POM');
      print_data('LADS_VEN_PTX');
      print_data('LADS_VEN_PTD');
      print_data('LADS_VEN_BNK');
      utl_file.put_line(var_fil_handle, 'ATLLAD20' || chr(9) || 'Customer Hierarchy');
      print_data('LADS_HIE_CUS_HDR');
      print_data('LADS_HIE_CUS_DET');
      utl_file.put_line(var_fil_handle, 'ATLLAD21' || chr(9) || 'Characteric Master');
      print_data('LADS_CHR_MAS_HDR');
      print_data('LADS_CHR_MAS_DET');
      print_data('LADS_CHR_MAS_VAL');
      print_data('LADS_CHR_MAS_DSC');
      utl_file.put_line(var_fil_handle, 'ATLLAD22' || chr(9) || 'Exchange Rates');
      print_data('LADS_XCH_RAT_DET');
      utl_file.put_line(var_fil_handle, 'ATLLAD23' || chr(9) || 'Stock Intransit');
      print_data('LADS_INT_STK_HDR');
      print_data('LADS_INT_STK_DET');
      utl_file.put_line(var_fil_handle, 'ATLLAD25' || chr(9) || 'Generic ICB Export Documentation');
      print_data('LADS_EXP_HDR');
      print_data('LADS_EXP_ORD');
      print_data('LADS_EXP_HOR');
      print_data('LADS_EXP_ORG');
      print_data('LADS_EXP_DAT');
      print_data('LADS_EXP_PNR');
      print_data('LADS_EXP_GEN');
      print_data('LADS_EXP_ICO');
      print_data('LADS_EXP_SOR');
      print_data('LADS_EXP_DEL');
      print_data('LADS_EXP_HDE');
      print_data('LADS_EXP_ADD');
      print_data('LADS_EXP_TIM');
      print_data('LADS_EXP_DET');
      print_data('LADS_EXP_INT');
      print_data('LADS_EXP_IRF');
      print_data('LADS_EXP_ERF');
      print_data('LADS_EXP_HUH');
      print_data('LADS_EXP_HUC');
      print_data('LADS_EXP_SHP');
      print_data('LADS_EXP_HSH');
      print_data('LADS_EXP_HDA');
      print_data('LADS_EXP_HAR');
      print_data('LADS_EXP_HST');
      print_data('LADS_EXP_HSP');
      print_data('LADS_EXP_HSD');
      print_data('LADS_EXP_HSI');
      print_data('LADS_EXP_HAG');
      print_data('LADS_EXP_INV');
      print_data('LADS_EXP_HIN');
      print_data('LADS_EXP_IGN');
      print_data('LADS_EXP_IRE');
      print_data('LADS_EXP_ICN');
      print_data('LADS_EXP_SIN');
      print_data('LADS_EXP_IDT');
      utl_file.put_line(var_fil_handle, 'ATLLAD28' || chr(9) || 'Open Purchase Order/Requisition');
      print_data('LADS_OPR_HDR');
      utl_file.put_line(var_fil_handle, 'ATLLAD29' || chr(9) || 'Open Planned Process Orders');
      print_data('LADS_PPO_HDR');

      /**/
      /* Close the print file 
      /**/
      utl_file.fclose(var_fil_handle);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /**************************************************/
   /* This procedure performs the print data routine */
   /**************************************************/
   procedure print_data(par_table in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_data varchar2(4000);
      var_work varchar2(1000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_table_01 is 
         select chr(9) || upper(t01.table_name) || chr(9) || t02.comments || chr(9)
           from all_tables t01, all_tab_comments t02
          where t01.table_name = t02.table_name(+)
            and t01.table_name = par_table;

      cursor csr_lads_constraint_01 is 
         select lower(t01.column_name)
           from all_cons_columns t01
          where t01.table_name = par_table
            and t01.constraint_name = par_table || '_PK'
       order by t01.position asc;

      cursor csr_lads_column_01 is 
         select case when lower(t01.data_type) = 'varchar2' then chr(9) || lower(t01.column_name) || chr(9) || t02.comments || chr(9) || lower(t01.data_type) || '(' || to_char(t01.data_length) || ')' else chr(9) || lower(t01.column_name) || chr(9) || t02.comments || chr(9) || lower(t01.data_type) end
           from all_tab_columns t01, all_col_comments t02
          where t01.table_name = t02.table_name(+)
            and t01.column_name = t02.column_name(+)
            and t01.table_name = par_table
       order by t01.column_id asc;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the tables
      /*-*/
      open csr_lads_table_01;
      loop
         fetch csr_lads_table_01 into var_data;
         if csr_lads_table_01%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve the constraints related to the table
         /*-*/
         open csr_lads_constraint_01;
         loop
            fetch csr_lads_constraint_01 into var_work;
            if csr_lads_constraint_01%notfound then
               exit;
            end if;
            var_data := var_data || chr(9) || var_work; 
         end loop;
         close csr_lads_constraint_01;

         /*-*/
         /* Write the print data
         /*-*/
         utl_file.put_line(var_fil_handle, var_data);

         /*-*/
         /* Retrieve the columns related to the table
         /*-*/
         open csr_lads_column_01;
         loop
            fetch csr_lads_column_01 into var_data;
            if csr_lads_column_01%notfound then
               exit;
            end if;

            /*-*/
            /* Write the print data
            /*-*/
            utl_file.put_line(var_fil_handle, var_data); 

         end loop;
         close csr_lads_column_01;

      end loop;
      close csr_lads_table_01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end print_data;

end lads_doco;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_doco for lads_app.lads_doco;
grant execute on lads_doco to public;
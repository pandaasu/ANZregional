-- This following script should be run on BDS or SITE_APP to perform the 
-- select data granting required by promax to view data.

select 'grant select on ' || table_name || ' to PXI_APP;' from all_tables where owner in ('LADS') 
union
select 'grant select on ' || view_name || ' to PXI_APP;' from all_views where owner in ('LADS')

-- These are the actual grants.
grant select on ACCNT_ASSGNMNT_GROUP to PXI_APP;
grant select on ANML_PARTS to PXI_APP;
grant select on BANNER to PXI_APP;
grant select on BRAND_ESSNC to PXI_APP;
grant select on BRAND_FLAG to PXI_APP;
grant select on BRAND_SUB_FLAG to PXI_APP;
grant select on BUS_SGMNT to PXI_APP;
grant select on CNSMR_PACK_FRMT to PXI_APP;
grant select on CUST_BUYING_GROUP to PXI_APP;
grant select on DSPLY_STRG_CNDTN to PXI_APP;
grant select on DSTRBTN_ROUTE to PXI_APP;
grant select on EXCH_RATE_FCTR to PXI_APP;
grant select on FIGHTING_UNIT to PXI_APP;
grant select on FNCTNL_VRTY to PXI_APP;
grant select on INGRDNT_VRTY to PXI_APP;
grant select on LADS_ADR_COM to PXI_APP;
grant select on LADS_ADR_DET to PXI_APP;
grant select on LADS_ADR_EMA to PXI_APP;
grant select on LADS_ADR_FAX to PXI_APP;
grant select on LADS_ADR_HDR to PXI_APP;
grant select on LADS_ADR_TEL to PXI_APP;
grant select on LADS_ADR_URL to PXI_APP;
grant select on LADS_BOM_DET to PXI_APP;
grant select on LADS_BOM_HDR to PXI_APP;
grant select on LADS_CHR_MAS_DET to PXI_APP;
grant select on LADS_CHR_MAS_DSC to PXI_APP;
grant select on LADS_CHR_MAS_HDR to PXI_APP;
grant select on LADS_CHR_MAS_VAL to PXI_APP;
grant select on LADS_CLA_CHR to PXI_APP;
grant select on LADS_CLA_CLS to PXI_APP;
grant select on LADS_CLA_HDR to PXI_APP;
grant select on LADS_CLA_MAS_DET to PXI_APP;
grant select on LADS_CLA_MAS_HDR to PXI_APP;
grant select on LADS_CTL_REC_HPI to PXI_APP;
grant select on LADS_CTL_REC_TPI to PXI_APP;
grant select on LADS_CTL_REC_TXT to PXI_APP;
grant select on LADS_CTL_REC_VPI to PXI_APP;
grant select on LADS_CUS_BNK to PXI_APP;
grant select on LADS_CUS_CNT to PXI_APP;
grant select on LADS_CUS_CTD to PXI_APP;
grant select on LADS_CUS_CTE to PXI_APP;
grant select on LADS_CUS_CTX to PXI_APP;
grant select on LADS_CUS_CUD to PXI_APP;
grant select on LADS_CUS_HDR to PXI_APP;
grant select on LADS_CUS_HTD to PXI_APP;
grant select on LADS_CUS_HTH to PXI_APP;
grant select on LADS_CUS_LID to PXI_APP;
grant select on LADS_CUS_MGE to PXI_APP;
grant select on LADS_CUS_MGV to PXI_APP;
grant select on LADS_CUS_PDP to PXI_APP;
grant select on LADS_CUS_PFR to PXI_APP;
grant select on LADS_CUS_PLM to PXI_APP;
grant select on LADS_CUS_PRP to PXI_APP;
grant select on LADS_CUS_SAD to PXI_APP;
grant select on LADS_CUS_SAT to PXI_APP;
grant select on LADS_CUS_STD to PXI_APP;
grant select on LADS_CUS_STX to PXI_APP;
grant select on LADS_CUS_UNL to PXI_APP;
grant select on LADS_CUS_VAT to PXI_APP;
grant select on LADS_CUS_ZSD to PXI_APP;
grant select on LADS_CUS_ZSV to PXI_APP;
grant select on LADS_DEL_ADD to PXI_APP;
grant select on LADS_DEL_ADL to PXI_APP;
grant select on LADS_DEL_DET to PXI_APP;
grant select on LADS_DEL_DTP to PXI_APP;
grant select on LADS_DEL_DTX to PXI_APP;
grant select on LADS_DEL_ERF to PXI_APP;
grant select on LADS_DEL_HDR to PXI_APP;
grant select on LADS_DEL_HTP to PXI_APP;
grant select on LADS_DEL_HTX to PXI_APP;
grant select on LADS_DEL_HUC to PXI_APP;
grant select on LADS_DEL_HUH to PXI_APP;
grant select on LADS_DEL_INT to PXI_APP;
grant select on LADS_DEL_IRF to PXI_APP;
grant select on LADS_DEL_NOD to PXI_APP;
grant select on LADS_DEL_POD to PXI_APP;
grant select on LADS_DEL_RTE to PXI_APP;
grant select on LADS_DEL_STG to PXI_APP;
grant select on LADS_DEL_TIM to PXI_APP;
grant select on LADS_EXP_ADD to PXI_APP;
grant select on LADS_EXP_DAT to PXI_APP;
grant select on LADS_EXP_DEL to PXI_APP;
grant select on LADS_EXP_DET to PXI_APP;
grant select on LADS_EXP_ERF to PXI_APP;
grant select on LADS_EXP_GEN to PXI_APP;
grant select on LADS_EXP_HAG to PXI_APP;
grant select on LADS_EXP_HAR to PXI_APP;
grant select on LADS_EXP_HDA to PXI_APP;
grant select on LADS_EXP_HDE to PXI_APP;
grant select on LADS_EXP_HDR to PXI_APP;
grant select on LADS_EXP_HIN to PXI_APP;
grant select on LADS_EXP_HOR to PXI_APP;
grant select on LADS_EXP_HSD to PXI_APP;
grant select on LADS_EXP_HSH to PXI_APP;
grant select on LADS_EXP_HSI to PXI_APP;
grant select on LADS_EXP_HSP to PXI_APP;
grant select on LADS_EXP_HST to PXI_APP;
grant select on LADS_EXP_HUC to PXI_APP;
grant select on LADS_EXP_HUH to PXI_APP;
grant select on LADS_EXP_ICN to PXI_APP;
grant select on LADS_EXP_ICO to PXI_APP;
grant select on LADS_EXP_IDT to PXI_APP;
grant select on LADS_EXP_IGN to PXI_APP;
grant select on LADS_EXP_INT to PXI_APP;
grant select on LADS_EXP_INV to PXI_APP;
grant select on LADS_EXP_IRE to PXI_APP;
grant select on LADS_EXP_IRF to PXI_APP;
grant select on LADS_EXP_ORD to PXI_APP;
grant select on LADS_EXP_ORG to PXI_APP;
grant select on LADS_EXP_PNR to PXI_APP;
grant select on LADS_EXP_SHP to PXI_APP;
grant select on LADS_EXP_SIN to PXI_APP;
grant select on LADS_EXP_SOR to PXI_APP;
grant select on LADS_EXP_TIM to PXI_APP;
grant select on LADS_FAR_DET to PXI_APP;
grant select on LADS_FAR_HDR to PXI_APP;
grant select on LADS_FAR_LED to PXI_APP;
grant select on LADS_FAR_TAX to PXI_APP;
grant select on LADS_HIE_CUS_DET to PXI_APP;
grant select on LADS_HIE_CUS_HDR to PXI_APP;
grant select on LADS_ICB_LLT_DET to PXI_APP;
grant select on LADS_ICB_LLT_HDR to PXI_APP;
grant select on LADS_INT_STK_DET to PXI_APP;
grant select on LADS_INT_STK_HDR to PXI_APP;
grant select on LADS_INV_ADJ to PXI_APP;
grant select on LADS_INV_BNK to PXI_APP;
grant select on LADS_INV_CON to PXI_APP;
grant select on LADS_INV_CUR to PXI_APP;
grant select on LADS_INV_CUS to PXI_APP;
grant select on LADS_INV_DAT to PXI_APP;
grant select on LADS_INV_DCN to PXI_APP;
grant select on LADS_INV_FTD to PXI_APP;
grant select on LADS_INV_GEN to PXI_APP;
grant select on LADS_INV_GRD to PXI_APP;
grant select on LADS_INV_HDR to PXI_APP;
grant select on LADS_INV_IAJ to PXI_APP;
grant select on LADS_INV_IAS to PXI_APP;
grant select on LADS_INV_ICB to PXI_APP;
grant select on LADS_INV_ICN to PXI_APP;
grant select on LADS_INV_ICP to PXI_APP;
grant select on LADS_INV_IDT to PXI_APP;
grant select on LADS_INV_IFT to PXI_APP;
grant select on LADS_INV_IOB to PXI_APP;
grant select on LADS_INV_IPN to PXI_APP;
grant select on LADS_INV_IRF to PXI_APP;
grant select on LADS_INV_ITA to PXI_APP;
grant select on LADS_INV_ITI to PXI_APP;
grant select on LADS_INV_ITX to PXI_APP;
grant select on LADS_INV_MAT to PXI_APP;
grant select on LADS_INV_ORG to PXI_APP;
grant select on LADS_INV_PNR to PXI_APP;
grant select on LADS_INV_REF to PXI_APP;
grant select on LADS_INV_SAL to PXI_APP;
grant select on LADS_INV_SMY to PXI_APP;
grant select on LADS_INV_SUM_DET to PXI_APP;
grant select on LADS_INV_SUM_HDR to PXI_APP;
grant select on LADS_INV_TAX to PXI_APP;
grant select on LADS_INV_TOD to PXI_APP;
grant select on LADS_INV_TOP to PXI_APP;
grant select on LADS_INV_TXI to PXI_APP;
grant select on LADS_INV_TXT to PXI_APP;
grant select on LADS_MAT_BOM_DET to PXI_APP;
grant select on LADS_MAT_BOM_HDR to PXI_APP;
grant select on LADS_MAT_GME to PXI_APP;
grant select on LADS_MAT_HDR to PXI_APP;
grant select on LADS_MAT_LCD to PXI_APP;
grant select on LADS_MAT_MBE to PXI_APP;
grant select on LADS_MAT_MGN to PXI_APP;
grant select on LADS_MAT_MKT to PXI_APP;
grant select on LADS_MAT_MLG to PXI_APP;
grant select on LADS_MAT_MOE to PXI_APP;
grant select on LADS_MAT_MPM to PXI_APP;
grant select on LADS_MAT_MPV to PXI_APP;
grant select on LADS_MAT_MRC to PXI_APP;
grant select on LADS_MAT_MRD to PXI_APP;
grant select on LADS_MAT_MUM to PXI_APP;
grant select on LADS_MAT_MVM to PXI_APP;
grant select on LADS_MAT_PCH to PXI_APP;
grant select on LADS_MAT_PCR to PXI_APP;
grant select on LADS_MAT_PID to PXI_APP;
grant select on LADS_MAT_PIE to PXI_APP;
grant select on LADS_MAT_PIH to PXI_APP;
grant select on LADS_MAT_PIM to PXI_APP;
grant select on LADS_MAT_PIR to PXI_APP;
grant select on LADS_MAT_PIT to PXI_APP;
grant select on LADS_MAT_SAD to PXI_APP;
grant select on LADS_MAT_TAX to PXI_APP;
grant select on LADS_MAT_TXH to PXI_APP;
grant select on LADS_MAT_TXL to PXI_APP;
grant select on LADS_MAT_UOE to PXI_APP;
grant select on LADS_MAT_UOM to PXI_APP;
grant select on LADS_MAT_ZMC to PXI_APP;
grant select on LADS_MAT_ZSD to PXI_APP;
grant select on LADS_OPR_HDR to PXI_APP;
grant select on LADS_PPO_HDR to PXI_APP;
grant select on LADS_PRC_LST_DET to PXI_APP;
grant select on LADS_PRC_LST_HDR to PXI_APP;
grant select on LADS_PRC_LST_QUA to PXI_APP;
grant select on LADS_PRC_LST_VAL to PXI_APP;
grant select on LADS_REF_DAT to PXI_APP;
grant select on LADS_REF_EORD to PXI_APP;
grant select on LADS_REF_FLD to PXI_APP;
grant select on LADS_REF_HDR to PXI_APP;
grant select on LADS_REF_T415A to PXI_APP;
grant select on LADS_SAL_ORD_ADD to PXI_APP;
grant select on LADS_SAL_ORD_CON to PXI_APP;
grant select on LADS_SAL_ORD_DAT to PXI_APP;
grant select on LADS_SAL_ORD_GEN to PXI_APP;
grant select on LADS_SAL_ORD_HDR to PXI_APP;
grant select on LADS_SAL_ORD_IAD to PXI_APP;
grant select on LADS_SAL_ORD_ICO to PXI_APP;
grant select on LADS_SAL_ORD_IDD to PXI_APP;
grant select on LADS_SAL_ORD_IDT to PXI_APP;
grant select on LADS_SAL_ORD_IGT to PXI_APP;
grant select on LADS_SAL_ORD_IID to PXI_APP;
grant select on LADS_SAL_ORD_IPD to PXI_APP;
grant select on LADS_SAL_ORD_IPN to PXI_APP;
grant select on LADS_SAL_ORD_IPS to PXI_APP;
grant select on LADS_SAL_ORD_IRF to PXI_APP;
grant select on LADS_SAL_ORD_ISC to PXI_APP;
grant select on LADS_SAL_ORD_ISD to PXI_APP;
grant select on LADS_SAL_ORD_ISI to PXI_APP;
grant select on LADS_SAL_ORD_ISJ to PXI_APP;
grant select on LADS_SAL_ORD_ISN to PXI_APP;
grant select on LADS_SAL_ORD_ISO to PXI_APP;
grant select on LADS_SAL_ORD_ISP to PXI_APP;
grant select on LADS_SAL_ORD_ISR to PXI_APP;
grant select on LADS_SAL_ORD_ISS to PXI_APP;
grant select on LADS_SAL_ORD_IST to PXI_APP;
grant select on LADS_SAL_ORD_ISX to PXI_APP;
grant select on LADS_SAL_ORD_ISY to PXI_APP;
grant select on LADS_SAL_ORD_ITA to PXI_APP;
grant select on LADS_SAL_ORD_ITD to PXI_APP;
grant select on LADS_SAL_ORD_ITP to PXI_APP;
grant select on LADS_SAL_ORD_ITT to PXI_APP;
grant select on LADS_SAL_ORD_ITX to PXI_APP;
grant select on LADS_SAL_ORD_ORG to PXI_APP;
grant select on LADS_SAL_ORD_PAD to PXI_APP;
grant select on LADS_SAL_ORD_PCD to PXI_APP;
grant select on LADS_SAL_ORD_PNR to PXI_APP;
grant select on LADS_SAL_ORD_REF to PXI_APP;
grant select on LADS_SAL_ORD_SMY to PXI_APP;
grant select on LADS_SAL_ORD_SOG to PXI_APP;
grant select on LADS_SAL_ORD_TAX to PXI_APP;
grant select on LADS_SAL_ORD_TOD to PXI_APP;
grant select on LADS_SAL_ORD_TOP to PXI_APP;
grant select on LADS_SAL_ORD_TXI to PXI_APP;
grant select on LADS_SAL_ORD_TXT to PXI_APP;
grant select on LADS_SHP_DAD to PXI_APP;
grant select on LADS_SHP_DAS to PXI_APP;
grant select on LADS_SHP_DBT to PXI_APP;
grant select on LADS_SHP_DED to PXI_APP;
grant select on LADS_SHP_DHI to PXI_APP;
grant select on LADS_SHP_DHU to PXI_APP;
grant select on LADS_SHP_DIB to PXI_APP;
grant select on LADS_SHP_DIT to PXI_APP;
grant select on LADS_SHP_DLV to PXI_APP;
grant select on LADS_SHP_DNG to PXI_APP;
grant select on LADS_SHP_DRF to PXI_APP;
grant select on LADS_SHP_DRS to PXI_APP;
grant select on LADS_SHP_HAD to PXI_APP;
grant select on LADS_SHP_HAR to PXI_APP;
grant select on LADS_SHP_HCT to PXI_APP;
grant select on LADS_SHP_HDA to PXI_APP;
grant select on LADS_SHP_HDR to PXI_APP;
grant select on LADS_SHP_HSD to PXI_APP;
grant select on LADS_SHP_HSI to PXI_APP;
grant select on LADS_SHP_HSP to PXI_APP;
grant select on LADS_SHP_HST to PXI_APP;
grant select on LADS_SHP_HTG to PXI_APP;
grant select on LADS_SHP_HTX to PXI_APP;
grant select on LADS_STK_BAL_DET to PXI_APP;
grant select on LADS_STK_BAL_HDR to PXI_APP;
grant select on LADS_STO_PO_CON to PXI_APP;
grant select on LADS_STO_PO_DAT to PXI_APP;
grant select on LADS_STO_PO_DEL to PXI_APP;
grant select on LADS_STO_PO_GEN to PXI_APP;
grant select on LADS_STO_PO_HDR to PXI_APP;
grant select on LADS_STO_PO_HTI to PXI_APP;
grant select on LADS_STO_PO_HTX to PXI_APP;
grant select on LADS_STO_PO_ITP to PXI_APP;
grant select on LADS_STO_PO_OID to PXI_APP;
grant select on LADS_STO_PO_ORG to PXI_APP;
grant select on LADS_STO_PO_PAD to PXI_APP;
grant select on LADS_STO_PO_PAY to PXI_APP;
grant select on LADS_STO_PO_PNR to PXI_APP;
grant select on LADS_STO_PO_REF to PXI_APP;
grant select on LADS_STO_PO_SCH to PXI_APP;
grant select on LADS_STO_PO_SMY to PXI_APP;
grant select on LADS_VEN_BNK to PXI_APP;
grant select on LADS_VEN_CCD to PXI_APP;
grant select on LADS_VEN_CTD to PXI_APP;
grant select on LADS_VEN_CTX to PXI_APP;
grant select on LADS_VEN_HDR to PXI_APP;
grant select on LADS_VEN_POH to PXI_APP;
grant select on LADS_VEN_POM to PXI_APP;
grant select on LADS_VEN_PTD to PXI_APP;
grant select on LADS_VEN_PTX to PXI_APP;
grant select on LADS_VEN_TXH to PXI_APP;
grant select on LADS_VEN_TXL to PXI_APP;
grant select on LADS_VEN_WTX to PXI_APP;
grant select on LADS_VEN_ZCC to PXI_APP;
grant select on LADS_XCH_RAT_DET to PXI_APP;
grant select on LADS_XRF_DET to PXI_APP;
grant select on LADS_XRF_HDR to PXI_APP;
grant select on MFANZ_CUST to PXI_APP;
grant select on MFANZ_CUST_BY_SALES_AREA to PXI_APP;
grant select on MFANZ_CUST_PRTNR_ROLES to PXI_APP;
grant select on MFANZ_DEL_DET to PXI_APP;
grant select on MFANZ_DEL_DET_ASN to PXI_APP;
grant select on MFANZ_FG_MATL_CLSSFCTN to PXI_APP;
grant select on MFANZ_FG_MATL_CLSSFCTN_ZREP to PXI_APP;
grant select on MFANZ_INVC_DTL to PXI_APP;
grant select on MFANZ_INVC_HDR to PXI_APP;
grant select on MFANZ_MATL to PXI_APP;
grant select on MFANZ_MATL_ALTRNTV_UOM to PXI_APP;
grant select on MFANZ_MATL_ANZ_VLTN to PXI_APP;
grant select on MFANZ_MATL_BY_ANZ_PLANT to PXI_APP;
grant select on MFANZ_MATL_BY_PLANT to PXI_APP;
grant select on MFANZ_MATL_BY_PLANT_PROMAX_VW to PXI_APP;
grant select on MFANZ_MATL_BY_SALES_AREA to PXI_APP;
grant select on MFANZ_MATL_DTRMNTN to PXI_APP;
grant select on MFANZ_MATL_DTRMNTN_GS1 to PXI_APP;
grant select on MFANZ_MATL_DTRMNTN_PROMAX_VW to PXI_APP;
grant select on MFANZ_MATL_DTRMNTN_ZREP to PXI_APP;
grant select on MFANZ_MATL_DTRMNTN_ZREP_GS1 to PXI_APP;
grant select on MFANZ_MATL_LCD to PXI_APP;
grant select on MFANZ_MATL_MOE to PXI_APP;
grant select on MFANZ_MATL_PROMAX_VW to PXI_APP;
grant select on MFANZ_MATL_SALES_BOM to PXI_APP;
grant select on MFANZ_MATL_SALES_TEXT to PXI_APP;
grant select on MFANZ_MATL_VLTN to PXI_APP;
grant select on MFANZ_MCUS_PER_TDU to PXI_APP;
grant select on MFANZ_MCUS_PER_TDU_ZREP to PXI_APP;
grant select on MFANZ_PACK_MATL_CLSSFCTN to PXI_APP;
grant select on MFANZ_PCKGNG_INSTRCTN to PXI_APP;
grant select on MFANZ_PRICE_LIST_DTL to PXI_APP;
grant select on MFANZ_PRICE_LIST_DTL_ALL to PXI_APP;
grant select on MFANZ_PRICE_LIST_HDR to PXI_APP;
grant select on MFANZ_RAW_MATL_CLSSFCTN to PXI_APP;
grant select on MFANZ_RSUS_PER_INT to PXI_APP;
grant select on MFANZ_RSUS_PER_MCU to PXI_APP;
grant select on MFANZ_RSUS_PER_MCU_ZREP to PXI_APP;
grant select on MFANZ_RSUS_PER_TDU to PXI_APP;
grant select on MFANZ_RSUS_PER_TDU_ALL to PXI_APP;
grant select on MFANZ_RSUS_PER_TDU_ZREP to PXI_APP;
grant select on MFANZ_SALES_ORDER_DTL to PXI_APP;
grant select on MFANZ_SALES_ORDER_HDR to PXI_APP;
grant select on MFANZ_STOCK_BLNC to PXI_APP;
grant select on MFANZ_STOCK_BLNC_HIST_VW to PXI_APP;
grant select on MFANZ_STO_PO_DTL to PXI_APP;
grant select on MFANZ_STO_PO_HDR to PXI_APP;
grant select on MFANZ_VNDR to PXI_APP;
grant select on MFANZ_VNDR_BY_PRCHSNG_ORG to PXI_APP;
grant select on MKT_CAT to PXI_APP;
grant select on MKT_SGMNT to PXI_APP;
grant select on MKT_SUB_CAT to PXI_APP;
grant select on MKT_SUB_CAT_GRP to PXI_APP;
grant select on MLTPCK_QTY to PXI_APP;
grant select on MOE_CODE_REF to PXI_APP;
grant select on MRKTNG_CNCPT to PXI_APP;
grant select on MULTI_MRKT_ACCNT to PXI_APP;
grant select on OCCSN to PXI_APP;
grant select on ON_PACK_CNSMR_OFFER to PXI_APP;
grant select on ON_PACK_CNSMR_VALUE to PXI_APP;
grant select on ON_PACK_TRADE_OFFER to PXI_APP;
grant select on OP_BUS_MODEL to PXI_APP;
grant select on PACK_FMLY to PXI_APP;
grant select on PACK_SUB_FMLY to PXI_APP;
grant select on PACK_TYPE to PXI_APP;
grant select on PHYSCL_CNDTN to PXI_APP;
grant select on PLANT_VW to PXI_APP;
grant select on PLNG_SRCE to PXI_APP;
grant select on POS_FRMT to PXI_APP;
grant select on POS_FRMT_GRPNG to PXI_APP;
grant select on POS_PLACE to PXI_APP;
grant select on PRDCT_CTGRY to PXI_APP;
grant select on PRDCT_TYPE to PXI_APP;
grant select on PRMRY_ROUTE to PXI_APP;
grant select on PRNT_ACCNT to PXI_APP;
grant select on PRODN_LINE to PXI_APP;
grant select on PROMAX_CUST_HIER_VIEW to PXI_APP;
grant select on PROMAX_MATL_AUS_SNACK to PXI_APP;
grant select on PROMAX_MATL_CUST_DSTRBTN_CHNLS to PXI_APP;
grant select on PROMAX_PRICE_EXT_VIEW to PXI_APP;
grant select on PROMAX_PROM_INVOICES to PXI_APP;
grant select on PROMAX_PROM_INV_EXT_VIEW to PXI_APP;
grant select on PROMAX_PROM_PRICE_CNDTNS to PXI_APP;
grant select on PROMAX_VENDOR_VIEW to PXI_APP;
grant select on RAW_FMLY to PXI_APP;
grant select on RAW_GROUP to PXI_APP;
grant select on RAW_SUB_FMLY to PXI_APP;
grant select on SIEBEL_CUST_VW to PXI_APP;
grant select on SIEBEL_MATL_VW to PXI_APP;
grant select on SIZE_DSCRPTV to PXI_APP;
grant select on SIZE_GROUP to PXI_APP;
grant select on SOP_BUS_CODE to PXI_APP;
grant select on SPPLY_SGMNT to PXI_APP;
grant select on TDU_CNFGRTN to PXI_APP;
grant select on TDU_FRMT to PXI_APP;
grant select on TRADE_SCTR to PXI_APP;
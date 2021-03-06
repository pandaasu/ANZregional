-- This following script should be run on BDS or SITE_APP to perform the 
-- select data granting required by promax to view data.

select 'grant select on ' || table_name || ' to PUBLIC;' from all_tables where owner in ('BDS') 
union
select 'grant select on ' || view_name || ' to PUBLIC;' from all_views where owner in ('BDS')

-- These are the actual grants.
grant select on BDS_ACCT_ASSGNMNT_GRP_EN to PUBLIC;
grant select on BDS_ADDR_COMMENT to PUBLIC;
grant select on BDS_ADDR_CUSTOMER to PUBLIC;
grant select on BDS_ADDR_CUSTOMER_EN to PUBLIC;
grant select on BDS_ADDR_DETAIL to PUBLIC;
grant select on BDS_ADDR_EMAIL to PUBLIC;
grant select on BDS_ADDR_FAX to PUBLIC;
grant select on BDS_ADDR_HEADER to PUBLIC;
grant select on BDS_ADDR_PHONE to PUBLIC;
grant select on BDS_ADDR_URL to PUBLIC;
grant select on BDS_ADDR_VENDOR to PUBLIC;
grant select on BDS_ADDR_VENDOR_EN to PUBLIC;
grant select on BDS_BOM_ALL to PUBLIC;
grant select on BDS_BOM_DET to PUBLIC;
grant select on BDS_BOM_HDR to PUBLIC;
grant select on BDS_CHARISTIC_DESC to PUBLIC;
grant select on BDS_CHARISTIC_HDR to PUBLIC;
grant select on BDS_CHARISTIC_VALUE to PUBLIC;
grant select on BDS_CHARISTIC_VALUE_EN to PUBLIC;
grant select on BDS_CUSTOMER_CLASSFCTN to PUBLIC;
grant select on BDS_CUSTOMER_CLASSFCTN_EN to PUBLIC;
grant select on BDS_CUST_BANK to PUBLIC;
grant select on BDS_CUST_COMP to PUBLIC;
grant select on BDS_CUST_COMP_TEXT to PUBLIC;
grant select on BDS_CUST_COMP_WHTAX to PUBLIC;
grant select on BDS_CUST_CONTACT to PUBLIC;
grant select on BDS_CUST_HEADER to PUBLIC;
grant select on BDS_CUST_PLANT to PUBLIC;
grant select on BDS_CUST_PLANT_DEPT to PUBLIC;
grant select on BDS_CUST_PLANT_RCVPNT to PUBLIC;
grant select on BDS_CUST_PLANT_VOMD to PUBLIC;
grant select on BDS_CUST_PLANT_VOMD_EXCEPT to PUBLIC;
grant select on BDS_CUST_SALES_AREA to PUBLIC;
grant select on BDS_CUST_SALES_AREA_LICSE to PUBLIC;
grant select on BDS_CUST_SALES_AREA_PNRFUN to PUBLIC;
grant select on BDS_CUST_SALES_AREA_TAXIND to PUBLIC;
grant select on BDS_CUST_SALES_AREA_TEXT to PUBLIC;
grant select on BDS_CUST_SALES_AREA_VMIFCT to PUBLIC;
grant select on BDS_CUST_SALES_AREA_VMITYP to PUBLIC;
grant select on BDS_CUST_TEXT to PUBLIC;
grant select on BDS_CUST_UNLPNT to PUBLIC;
grant select on BDS_CUST_VAT to PUBLIC;
grant select on BDS_INTRANSIT_DETAIL to PUBLIC;
grant select on BDS_INTRANSIT_HEADER to PUBLIC;
grant select on BDS_MATERIAL_BOM_ALL to PUBLIC;
grant select on BDS_MATERIAL_BOM_ALL_ZREP to PUBLIC;
grant select on BDS_MATERIAL_BOM_DET to PUBLIC;
grant select on BDS_MATERIAL_BOM_HDR to PUBLIC;
grant select on BDS_MATERIAL_BOM_SYSDATE to PUBLIC;
grant select on BDS_MATERIAL_CLASSFCTN to PUBLIC;
grant select on BDS_MATERIAL_CLASSFCTN_EN to PUBLIC;
grant select on BDS_MATERIAL_DESC to PUBLIC;
grant select on BDS_MATERIAL_DSTRBTN_CHAIN to PUBLIC;
grant select on BDS_MATERIAL_DTRMNTN_ALL to PUBLIC;
grant select on BDS_MATERIAL_DTRMNTN_SYSDATE to PUBLIC;
grant select on BDS_MATERIAL_HDR to PUBLIC;
grant select on BDS_MATERIAL_MOE to PUBLIC;
grant select on BDS_MATERIAL_MOE_GRP to PUBLIC;
grant select on BDS_MATERIAL_PKG_INSTR_ALL to PUBLIC;
grant select on BDS_MATERIAL_PKG_INSTR_DET to PUBLIC;
grant select on BDS_MATERIAL_PKG_INSTR_EAN to PUBLIC;
grant select on BDS_MATERIAL_PKG_INSTR_HDR to PUBLIC;
grant select on BDS_MATERIAL_PKG_INSTR_MOE to PUBLIC;
grant select on BDS_MATERIAL_PKG_INSTR_REG to PUBLIC;
grant select on BDS_MATERIAL_PKG_INSTR_SYSDATE to PUBLIC;
grant select on BDS_MATERIAL_PKG_INSTR_TEXT to PUBLIC;
grant select on BDS_MATERIAL_PLANT_BATCH to PUBLIC;
grant select on BDS_MATERIAL_PLANT_FORECAST to PUBLIC;
grant select on BDS_MATERIAL_PLANT_HDR to PUBLIC;
grant select on BDS_MATERIAL_PLANT_MFANZ to PUBLIC;
grant select on BDS_MATERIAL_PLANT_TTL_CNSMPTN to PUBLIC;
grant select on BDS_MATERIAL_PLANT_UNP_CNSMPTN to PUBLIC;
grant select on BDS_MATERIAL_PLANT_VRSN to PUBLIC;
grant select on BDS_MATERIAL_REGIONAL to PUBLIC;
grant select on BDS_MATERIAL_TAX to PUBLIC;
grant select on BDS_MATERIAL_TEXT to PUBLIC;
grant select on BDS_MATERIAL_TEXT_EN to PUBLIC;
grant select on BDS_MATERIAL_UOM to PUBLIC;
grant select on BDS_MATERIAL_UOM_EAN to PUBLIC;
grant select on BDS_MATERIAL_VLTN to PUBLIC;
grant select on BDS_PRODCTN_RESRC_EN to PUBLIC;
grant select on BDS_PURCHASING_SRC_SYSDATE to PUBLIC;
grant select on BDS_RECIPE_BOM to PUBLIC;
grant select on BDS_RECIPE_HEADER to PUBLIC;
grant select on BDS_RECIPE_RESOURCE to PUBLIC;
grant select on BDS_RECIPE_SRC_TEXT to PUBLIC;
grant select on BDS_RECIPE_SRC_VALUE to PUBLIC;
grant select on BDS_REFRNC_ACCT_ASSGNMNT_GRP to PUBLIC;
grant select on BDS_REFRNC_BOM_ALTRNT_T415A to PUBLIC;
grant select on BDS_REFRNC_CHARISTIC to PUBLIC;
grant select on BDS_REFRNC_MATERIAL_TDU to PUBLIC;
grant select on BDS_REFRNC_MATERIAL_ZREP to PUBLIC;
grant select on BDS_REFRNC_MOE to PUBLIC;
grant select on BDS_REFRNC_PLANT to PUBLIC;
grant select on BDS_REFRNC_PRODCTN_RESRC_HDR to PUBLIC;
grant select on BDS_REFRNC_PRODCTN_RESRC_TEXT to PUBLIC;
grant select on BDS_REFRNC_PURCHASING_SRC to PUBLIC;
grant select on BDS_REFRNC_PURCHASING_SRC_CML to PUBLIC;
grant select on BDS_STOCK_BALANCE to PUBLIC;
grant select on BDS_STOCK_DETAIL to PUBLIC;
grant select on BDS_STOCK_HEADER to PUBLIC;
grant select on BDS_VEND_BANK to PUBLIC;
grant select on BDS_VEND_COMP to PUBLIC;
grant select on BDS_VEND_COMP_MARS to PUBLIC;
grant select on BDS_VEND_COMP_TEXT to PUBLIC;
grant select on BDS_VEND_COMP_WHTAX to PUBLIC;
grant select on BDS_VEND_HEADER to PUBLIC;
grant select on BDS_VEND_PURCH to PUBLIC;
grant select on BDS_VEND_PURCH_PLANT to PUBLIC;
grant select on bds_vend_purch_text to PUBLIC;
grant select on BDS_VEND_TEXT to PUBLIC;


logon as dds

/**/
/* Indexes
/**/
create index fcst_fact_ix01 on fcst_fact
   (company_code, fcst_yyyypp, fcst_type_code);

create index sales_fact_ix01 on sales_fact
   (company_code, billing_eff_yyyypp);

create index sales_period_01_fact_ix01 on sales_period_01_fact
   (company_code, billing_eff_yyyypp);


grant select, insert, update, delete on mars_date_dim to dw_app;
grant select, insert, update, delete on demand_plng_grp_sales_area_dim to dw_app;
grant select, insert, update, delete on cust_sales_area_dim to dw_app;
grant select, insert, update, delete on sales_fact to dw_app;
grant select, insert, update, delete on fcst_fact to dw_app;
grant select, insert, update, delete on sales_period_01_fact to dw_app;
grant select, insert, update, delete on sales_month_01_fact to dw_app;


grant select on ACCRLS_FACT to dw_app;
grant select on ACCT_ASSGNMNT_GRP_DIM to dw_app;
grant select on ACCT_MGR_DIM to dw_app;
grant select on BANNER_DIM to dw_app;
grant select on BOM_DIM to dw_app;
grant select on CLAIM_ALLOCN_FACT to dw_app;
grant select on CLAIM_FACT to dw_app;
grant select on CLAIM_TYPE_DIM to dw_app;
grant select on CNTRY_DIM to dw_app;
grant select on COMPANY_DIM to dw_app;
grant select on CSL_ORDER_DLVRY_FACT to dw_app;
grant select on CURRCY_DIM to dw_app;
grant select on CUST_BUYING_GRP_DIM to dw_app;
grant select on CUST_DIM to dw_app;
grant select on CUST_SALES_AREA_DIM to dw_app;
grant select on DATA_MART_01_DET to dw_app;
grant select on DATA_MART_01_HDR to dw_app;
grant select on DCS_SALES_ORDER_FACT to dw_app;
grant select on DEMAND_PLNG_FCST_FACT to dw_app;
grant select on DEMAND_PLNG_GRP_DIM to dw_app;
grant select on DEMAND_PLNG_GRP_MATL_DIV_DIM to dw_app;
grant select on DEMAND_PLNG_GRP_SALES_AREA_DIM to dw_app;
grant select on DISTBN_CHNL_DIM to dw_app;
grant select on DISTBN_ROUTE_DIM to dw_app;
grant select on DIVISION_DIM to dw_app;
grant select on DLVRY_FACT to dw_app;
grant select on DLVRY_TYPE_DIM to dw_app;
grant select on DOC_XACTN_TYPE_DIM to dw_app;
grant select on EXCH_RATE_DIM to dw_app;
grant select on FCST_FACT to dw_app;
grant select on FCST_LOCAL_REGION_FACT to dw_app;
grant select on FCST_TYPE_DIM to dw_app;
grant select on GRD_MATL_DIM to dw_app;
grant select on INTRANSIT_FACT to dw_app;
grant select on INVC_TYPE_DIM to dw_app;
grant select on INV_BALN_FACT to dw_app;
grant select on INV_TYPE_DIM to dw_app;
grant select on LOCAL_MATL_CLASSN_DIM to dw_app;
grant select on LOCAL_REGION_DIM to dw_app;
grant select on MARS_DATE_DIM to dw_app;
grant select on MARS_DATE_MONTH_DIM to dw_app;
grant select on MARS_DATE_PERIOD_DIM to dw_app;
grant select on MARS_DATE_WEEK_DIM to dw_app;
grant select on MATL_DIM to dw_app;
grant select on MATL_PLANT_DIM to dw_app;
grant select on MULTI_MKT_ACCT_DIM to dw_app;
grant select on ORDER_FACT to dw_app;
grant select on ORDER_REASN_DIM to dw_app;
grant select on ORDER_TYPE_DIM to dw_app;
grant select on ORDER_USAGE_DIM to dw_app;
grant select on PLANT_DIM to dw_app;
grant select on PMX_CUST_DIM to dw_app;
grant select on POS_FORMAT_GRPG_DIM to dw_app;
grant select on PROC_PLAN_ORDER_FACT to dw_app;
grant select on PRODN_PLAN_FACT to dw_app;
grant select on PROM_ATTRB_DIM to dw_app;
grant select on PROM_FACT to dw_app;
grant select on PROM_FUND_TYPE_DIM to dw_app;
grant select on PROM_STATUS_DIM to dw_app;
grant select on PROM_TYPE_CLASS_DIM to dw_app;
grant select on PROM_TYPE_DIM to dw_app;
grant select on PURCH_ORDER_BIFG_FACT to dw_app;
grant select on PURCH_ORDER_FACT to dw_app;
grant select on PURCH_ORDER_TYPE_DIM to dw_app;
grant select on REGION_DIM to dw_app;
grant select on REGL_FCST_FACT to dw_app;
grant select on REGL_SALES_FACT to dw_app;
grant select on SALES_FACT to dw_app;
grant select on SALES_FORCE_GEO_HIER to dw_app;
grant select on SALES_MONTH_01_FACT to dw_app;
grant select on SALES_OFFICE_HIER to dw_app;
grant select on SALES_ORG_DIM to dw_app;
grant select on SALES_PERIOD_01_FACT to dw_app;
grant select on SHIP_TO_HIER to dw_app;
grant select on STD_HIER to dw_app;
grant select on STORAGE_LOCN_DIM to dw_app;
grant select on SUB_DAILY_DLVRY_FACT to dw_app;
grant select on SUB_DAILY_ORDER_FACT to dw_app;
grant select on SUB_DAILY_PURCH_ORDER_FACT to dw_app;
grant select on SUB_DAILY_SALES_FACT to dw_app;
grant select on TEMP_HIER to dw_app;
grant select on TMP_SUB_DAILY_DLVRY_FACT to dw_app;
grant select on TMP_SUB_DAILY_ORDER_FACT to dw_app;
grant select on TMP_SUB_DAILY_PURCH_ORDER_FACT to dw_app;
grant select on TMP_SUB_DAILY_SALES_FACT to dw_app;
grant select on TRANSPORT_MODEL_DIM to dw_app;
grant select on TRUNCATE_CNTL to dw_app;
grant select on UOM_DIM to dw_app;



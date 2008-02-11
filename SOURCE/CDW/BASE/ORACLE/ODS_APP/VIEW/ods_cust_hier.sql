/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/** 
 Object : ods_cust_hier 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Customer Heirarchy View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.ods_cust_hier as
select max(t02.hityp) as sap_cust_hier_type_code,
  t01.hdrseq as cust_hier_hdr_cntr,
  max(case when t01.hielv = '01' then ltrim(t01.kunnr,' 0') end) as sap_cust_code_level_1,
  max(case when t01.hielv = '01' then t01.vkorg end) as sap_sales_org_code_level_1,
  max(case when t01.hielv = '01' then t01.vtweg end) as sap_distbn_chnl_code_level_1,
  max(case when t01.hielv = '01' then t01.spart end) as sap_division_code_level_1,
  max(case when t01.hielv = '01' then t01.hzuor end) as assgmnt_to_hier_level_1,
  max(case when t01.hielv = '01' then to_date(t01.datab,'yyyymmdd') end) as node_vldty_start_date_level_1,
  max(case when t01.hielv = '01' then to_date(t01.datbi,'yyyymmdd') end) as node_vldty_end_date_level_1,
  max(case when t01.hielv = '01' then t01.ktokd end) as sap_cust_acc_grp_code_level_1,
  max(case when t01.hielv = '01' then t01.sortl end) as cust_hier_sort_level_1,
  max(case when t01.hielv = '02' then ltrim(t01.kunnr,' 0') end) as sap_cust_code_level_2,
  max(case when t01.hielv = '02' then t01.vkorg end) as sap_sales_org_code_level_2,
  max(case when t01.hielv = '02' then t01.vtweg end) as sap_distbn_chnl_code_level_2,
  max(case when t01.hielv = '02' then t01.spart end) as sap_division_code_level_2,
  max(case when t01.hielv = '02' then t01.hzuor end) as assgmnt_to_hier_level_2,
  max(case when t01.hielv = '02' then to_date(t01.datab,'yyyymmdd') end) as node_vldty_start_date_level_2,
  max(case when t01.hielv = '02' then to_date(t01.datbi,'yyyymmdd') end) as node_vldty_end_date_level_2,
  max(case when t01.hielv = '02' then t01.ktokd end) as sap_cust_acc_grp_code_level_2,
  max(case when t01.hielv = '02' then t01.sortl end) as cust_hier_sort_level_2,
  max(case when t01.hielv = '03' then ltrim(t01.kunnr,' 0') end) as sap_cust_code_level_3,
  max(case when t01.hielv = '03' then t01.vkorg end) as sap_sales_org_code_level_3,
  max(case when t01.hielv = '03' then t01.vtweg end) as sap_distbn_chnl_code_level_3,
  max(case when t01.hielv = '03' then t01.spart end) as sap_division_code_level_3,
  max(case when t01.hielv = '03' then t01.hzuor end) as assgmnt_to_hier_level_3,
  max(case when t01.hielv = '03' then to_date(t01.datab,'yyyymmdd') end) as node_vldty_start_date_level_3,
  max(case when t01.hielv = '03' then to_date(t01.datbi,'yyyymmdd') end) as node_vldty_end_date_level_3,
  max(case when t01.hielv = '03' then t01.ktokd end) as sap_cust_acc_grp_code_level_3,
  max(case when t01.hielv = '03' then t01.sortl end) as cust_hier_sort_level_3,
  max(case when t01.hielv = '04' then ltrim(t01.kunnr,' 0') end) as sap_cust_code_level_4,
  max(case when t01.hielv = '04' then t01.vkorg end) as sap_sales_org_code_level_4,
  max(case when t01.hielv = '04' then t01.vtweg end) as sap_distbn_chnl_code_level_4,
  max(case when t01.hielv = '04' then t01.spart end) as sap_division_code_level_4,
  max(case when t01.hielv = '04' then t01.hzuor end) as assgmnt_to_hier_level_4,
  max(case when t01.hielv = '04' then to_date(t01.datab,'yyyymmdd') end) as node_vldty_start_date_level_4,
  max(case when t01.hielv = '04' then to_date(t01.datbi,'yyyymmdd') end) as node_vldty_end_date_level_4,
  max(case when t01.hielv = '04' then t01.ktokd end) as sap_cust_acc_grp_code_level_4,
  max(case when t01.hielv = '04' then t01.sortl end) as cust_hier_sort_level_4,
  max(case when t01.hielv = '05' then ltrim(t01.kunnr,' 0') end) as sap_cust_code_level_5,
  max(case when t01.hielv = '05' then t01.vkorg end) as sap_sales_org_code_level_5,
  max(case when t01.hielv = '05' then t01.vtweg end) as sap_distbn_chnl_code_level_5,
  max(case when t01.hielv = '05' then t01.spart end) as sap_division_code_level_5,
  max(case when t01.hielv = '05' then t01.hzuor end) as assgmnt_to_hier_level_5,
  max(case when t01.hielv = '05' then to_date(t01.datab,'yyyymmdd') end) as node_vldty_start_date_level_5,
  max(case when t01.hielv = '05' then to_date(t01.datbi,'yyyymmdd') end) as node_vldty_end_date_level_5,
  max(case when t01.hielv = '05' then t01.ktokd end) as sap_cust_acc_grp_code_level_5,
  max(case when t01.hielv = '05' then t01.sortl end) as cust_hier_sort_level_5,
  max(case when t01.hielv = '06' then ltrim(t01.kunnr,' 0') end) as sap_cust_code_level_6,
  max(case when t01.hielv = '06' then t01.vkorg end) as sap_sales_org_code_level_6,
  max(case when t01.hielv = '06' then t01.vtweg end) as sap_distbn_chnl_code_level_6,
  max(case when t01.hielv = '06' then t01.spart end) as sap_division_code_level_6,
  max(case when t01.hielv = '06' then t01.hzuor end) as assgmnt_to_hier_level_6,
  max(case when t01.hielv = '06' then to_date(t01.datab,'yyyymmdd') end) as node_vldty_start_date_level_6,
  max(case when t01.hielv = '06' then to_date(t01.datbi,'yyyymmdd') end) as node_vldty_end_date_level_6,
  max(case when t01.hielv = '06' then t01.ktokd end) as sap_cust_acc_grp_code_level_6,
  max(case when t01.hielv = '06' then t01.sortl end) as cust_hier_sort_level_6,
  max(case when t01.hielv = '07' then ltrim(t01.kunnr,' 0') end) as sap_cust_code_level_7,
  max(case when t01.hielv = '07' then t01.vkorg end) as sap_sales_org_code_level_7,
  max(case when t01.hielv = '07' then t01.vtweg end) as sap_distbn_chnl_code_level_7,
  max(case when t01.hielv = '07' then t01.spart end) as sap_division_code_level_7,
  max(case when t01.hielv = '07' then t01.hzuor end) as assgmnt_to_hier_level_7,
  max(case when t01.hielv = '07' then to_date(t01.datab,'yyyymmdd') end) as node_vldty_start_date_level_7,
  max(case when t01.hielv = '07' then to_date(t01.datbi,'yyyymmdd') end) as node_vldty_end_date_level_7,
  max(case when t01.hielv = '07' then t01.ktokd end) as sap_cust_acc_grp_code_level_7,
  max(case when t01.hielv = '07' then t01.sortl end) as cust_hier_sort_level_7,
  max(case when t01.hielv = '08' then ltrim(t01.kunnr,' 0') end) as sap_cust_code_level_8,
  max(case when t01.hielv = '08' then t01.vkorg end) as sap_sales_org_code_level_8,
  max(case when t01.hielv = '08' then t01.vtweg end) as sap_distbn_chnl_code_level_8,
  max(case when t01.hielv = '08' then t01.spart end) as sap_division_code_level_8,
  max(case when t01.hielv = '08' then t01.hzuor end) as assgmnt_to_hier_level_8,
  max(case when t01.hielv = '08' then to_date(t01.datab,'yyyymmdd') end) as node_vldty_start_date_level_8,
  max(case when t01.hielv = '08' then to_date(t01.datbi,'yyyymmdd') end) as node_vldty_end_date_level_8,
  max(case when t01.hielv = '08' then t01.ktokd end) as sap_cust_acc_grp_code_level_8,
  max(case when t01.hielv = '08' then t01.sortl end) as cust_hier_sort_level_8,
  max(case when t01.hielv = '09' then ltrim(t01.kunnr,' 0') end) as sap_cust_code_level_9,
  max(case when t01.hielv = '09' then t01.vkorg end) as sap_sales_org_code_level_9,
  max(case when t01.hielv = '09' then t01.vtweg end) as sap_distbn_chnl_code_level_9,
  max(case when t01.hielv = '09' then t01.spart end) as sap_division_code_level_9,
  max(case when t01.hielv = '09' then t01.hzuor end) as assgmnt_to_hier_level_9,
  max(case when t01.hielv = '09' then to_date(t01.datab,'yyyymmdd') end) as node_vldty_start_date_level_9,
  max(case when t01.hielv = '09' then to_date(t01.datbi,'yyyymmdd') end) as node_vldty_end_date_level_9,
  max(case when t01.hielv = '09' then t01.ktokd end) as sap_cust_acc_grp_code_level_9,
  max(case when t01.hielv = '09' then t01.sortl end) as cust_hier_sort_level_9,
  max(case when t01.hielv = '10' then ltrim(t01.kunnr,' 0') end) as sap_cust_code_level_10,
  max(case when t01.hielv = '10' then t01.vkorg end) as sap_sales_org_code_level_10,
  max(case when t01.hielv = '10' then t01.vtweg end) as sap_distbn_chnl_code_level_10,
  max(case when t01.hielv = '10' then t01.spart end) as sap_division_code_level_10,
  max(case when t01.hielv = '10' then t01.hzuor end) as assgmnt_to_hier_level_10,
  max(case when t01.hielv = '10' then to_date(t01.datab,'yyyymmdd') end) as node_vldty_start_date_level_10,
  max(case when t01.hielv = '10' then to_date(t01.datbi,'yyyymmdd') end) as node_vldty_end_date_level_10,
  max(case when t01.hielv = '10' then t01.ktokd end) as sap_cust_acc_grp_code_level_10,
  max(case when t01.hielv = '10' then t01.sortl end) as cust_hier_sort_level_10
from sap_hie_cus_det t01,
  sap_hie_cus_hdr t02
where t01.hdrdat = t02.hdrdat
  and t01.hdrseq = t02.hdrseq
  and t01.hdrdat in (select max(hdrdat) as hdrdat from sap_hie_cus_hdr where valdtn_status = 'VALID')
group by t01.hdrdat,
  t01.hdrseq;
  
/*-*/
/* Authority 
/*-*/
grant select on ods_app.ods_cust_hier to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym ods_cust_hier for ods_app.ods_cust_hier;
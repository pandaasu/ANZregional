/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : pmx_cust_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Promax Customer Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.pmx_cust_dim_view as
select company_code,
  division_code,
  cust_name as pmx_cust_name,
  cust_code,
  prom_flag as prmtbl_flag,
  acct_mgr_key
from pmx_cust;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.pmx_cust_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym pmx_cust_dim_view for ods_app.pmx_cust_dim_view;
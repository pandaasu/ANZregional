/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : pmx_acct_mgr_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Promax Account Manager Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.pmx_acct_mgr_dim_view as
select company_code,
  division_code,
  acct_mgr_code,
  acct_mgr_key,
  acct_mgr_name,
  active_flag
from pmx_acct_mgr;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.pmx_acct_mgr_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym pmx_acct_mgr_dim_view for ods_app.pmx_acct_mgr_dim_view;
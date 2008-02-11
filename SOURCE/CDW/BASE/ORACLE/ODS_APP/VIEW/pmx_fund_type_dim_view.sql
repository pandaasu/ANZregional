/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : pmx_fund_type_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Promax Fund Type Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.pmx_fund_type_dim_view as
select company_code,
  division_code,
  prom_fund_type_code,
  prom_fund_type_key,
  prom_fund_type_desc,
  prom_fund_type_ext_desc,
  mars_fund_type_code,
  off_invoice_flag
from pmx_fund_type;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.pmx_fund_type_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym pmx_fund_type_dim_view for ods_app.pmx_fund_type_dim_view;

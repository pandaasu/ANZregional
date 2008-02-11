/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : pmx_prom_attrb_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Promax Promotion Attribute Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.pmx_prom_attrb_dim_view as
select company_code,
  division_code,
  prom_attrb_key,
  prom_attrb_code,
  prom_attrb_desc
from pmx_prom_attrb;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.pmx_prom_attrb_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym pmx_prom_attrb_dim_view for ods_app.pmx_prom_attrb_dim_view;
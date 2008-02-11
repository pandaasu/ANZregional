/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : pmx_prom_type_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Promax Promotion Type Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.pmx_prom_type_dim_view as
select company_code,
  division_code,
  prom_type_key,
  prom_type_code,
  prom_type_desc
from pmx_prom_type;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.pmx_prom_type_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym pmx_prom_type_dim_view for ods_app.pmx_prom_type_dim_view;
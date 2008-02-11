/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : pmx_prom_status_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Promax Promotion Status Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.pmx_prom_status_dim_view as
select prom_status_code,
  prom_status_desc
from pmx_prom_status;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.pmx_prom_status_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym pmx_prom_status_dim_view for ods_app.pmx_prom_status_dim_view;
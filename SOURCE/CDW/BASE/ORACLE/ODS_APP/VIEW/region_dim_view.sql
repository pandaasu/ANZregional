/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : region_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Region Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.region_dim_view as
select region_code, -- SAP Region Code 
  cntry_code,       -- SAP Country Code 
  region_desc       -- Region Description 
from region;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.region_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym region_dim_view for ods_app.region_dim_view;
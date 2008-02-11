/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : country_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Country Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.country_dim_view as
select cntry_code,
  cntry_desc
from cntry;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.country_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym country_dim_view for ods_app.country_dim_view;
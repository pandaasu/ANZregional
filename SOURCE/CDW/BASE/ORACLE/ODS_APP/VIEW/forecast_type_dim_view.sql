/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : forecast_type_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Forecast Type Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.forecast_type_dim_view as
select fcst_type_code,
  fcst_type_desc
from fcst_type;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.forecast_type_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym forecast_type_dim_view for ods_app.forecast_type_dim_view;
/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : delivery_type_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Delivery Type Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.delivery_type_dim_view as
select dlvry_type_code,
  dlvry_type_desc
from dlvry_type;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.delivery_type_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym delivery_type_dim_view for ods_app.delivery_type_dim_view;
/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : order_type_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Order Type Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.order_type_dim_view as
select order_type_code,
  order_type_desc,
  order_type_sign
from order_type;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.order_type_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym order_type_dim_view for ods_app.order_type_dim_view;
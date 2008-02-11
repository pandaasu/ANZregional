/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : order_reason_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Order Reason Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.order_reason_dim_view as
select order_reasn_code,
  order_reasn_desc
from order_reasn;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.order_reason_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym order_reason_dim_view for ods_app.order_reason_dim_view;
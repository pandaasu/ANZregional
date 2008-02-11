/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : order_usage_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Order Usage Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.order_usage_dim_view as
select order_usage_code,  -- SAP Order Usage Code 
  order_usage_desc        -- Order Usage Description 
from order_usage;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.order_usage_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym order_usage_dim_view for ods_app.order_usage_dim_view;
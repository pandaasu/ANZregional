/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : purch_order_type_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Purchase Order Type Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.purch_order_type_dim_view as
select purch_order_type_code, -- SAP Purchase Order Type Code 
  purch_order_type_desc,      -- Purchase Order Description 
  purch_order_type_sign       -- Purchasr Order Sign
from purch_order_type;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.purch_order_type_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym purch_order_type_dim_view for ods_app.purch_order_type_dim_view;
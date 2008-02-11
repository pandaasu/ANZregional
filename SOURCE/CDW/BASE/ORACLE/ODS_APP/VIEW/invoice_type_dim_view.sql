/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : invoice_type_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Invoice Type Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.invoice_type_dim_view as
select invc_type_code,  -- SAP Invoice Type Code 
  invc_type_desc,       -- Invoice Type Description 
  invc_type_sign        -- Invoice Type Sign 
from invc_type;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.invoice_type_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym invoice_type_dim_view for ods_app.invoice_type_dim_view;
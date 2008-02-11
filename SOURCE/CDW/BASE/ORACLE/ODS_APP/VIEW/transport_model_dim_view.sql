/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : transport_model_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Transport Model Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.transport_model_dim_view as
select transport_model_code,
  transport_model_desc
from transport_model;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.transport_model_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym transport_model_dim_view for ods_app.transport_model_dim_view;
/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : currency_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Currency Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.currency_dim_view as
select currcy_code,
  currcy_desc
from currcy;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.currency_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym currency_dim_view for ods_app.currency_dim_view;
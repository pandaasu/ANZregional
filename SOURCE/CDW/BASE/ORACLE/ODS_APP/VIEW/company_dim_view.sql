/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : company_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Company Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.company_dim_view as
select company_code,
  company_desc
from company;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.company_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym company_dim_view for ods_app.company_dim_view;
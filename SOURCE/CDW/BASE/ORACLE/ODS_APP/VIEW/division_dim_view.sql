/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : division_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Division Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.division_dim_view as
select division_code,
  division_desc
from division_v2
where division_lang = 'E'
  and valdtn_status = 'VALID';
  
/*-*/
/* Authority 
/*-*/
grant select on ods_app.division_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym division_dim_view for ods_app.division_dim_view;
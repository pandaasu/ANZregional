/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/** 
 Object : local_matl_classn_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Local Material Classification Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.local_matl_classn_dim_view as
select ltrim(t01.matl_code, '0') as matl_code,  -- Material Number 
  t01.local_classn_type_code,                   -- Local Material Classification Type Description 
  t02.local_classn_type_desc,                   -- Local Material Classification Type Description 
  t01.local_classn_code,                        -- Local Material Classification Code 
  t03.local_classn_desc                         -- Local Material Classification Description 
from local_matl_classn t01,
  local_classn_type t02,
  local_classn t03
where t01.local_matl_classn_status = 'ACTIVE'
  and t02.local_classn_type_code = t03.local_classn_type_code
  and t03.local_classn_type_code = t01.local_classn_type_code
  and t03.local_classn_code = t01.local_classn_code;      

/*-*/
/* Authority 
/*-*/
grant select on ods_app.local_matl_classn_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym local_matl_classn_dim_view for ods_app.local_matl_classn_dim_view;
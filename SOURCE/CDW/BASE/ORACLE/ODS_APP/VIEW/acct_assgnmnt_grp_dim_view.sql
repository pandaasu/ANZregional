/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : acct_assgnmnt_grp_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Account Assignment Group Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.acct_assgnmnt_grp_dim_view as
select t01.acct_assgnmnt_grp_code,  -- SAP Account Assignment Group Code 
  t01.acct_assgnmnt_grp_desc        -- Account Assignment Group Desc 
from acct_assgnmnt_grp t01
where t01.acct_assgnmnt_grp_lang = 'E'
  and t01.valdtn_status = 'VALID';
  
/*-*/
/* Authority 
/*-*/
grant select on ods_app.acct_assgnmnt_grp_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym acct_assgnmnt_grp_dim_view for ods_app.acct_assgnmnt_grp_dim_view;
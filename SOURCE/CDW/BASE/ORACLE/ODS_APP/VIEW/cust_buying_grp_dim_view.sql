/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : cust_buying_grp_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Customer Buying Group Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.cust_buying_grp_dim_view as
select cust_buying_grp_code,
  cust_buying_grp_desc
from cust_buying_grp
where cust_buying_grp_lang = 'E'
  and valdtn_status = 'VALID';
  
/*-*/
/* Authority 
/*-*/
grant select on ods_app.cust_buying_grp_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym cust_buying_grp_dim_view for ods_app.cust_buying_grp_dim_view;
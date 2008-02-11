/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : distribution_chnl_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Distribution Channel Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.distribution_chnl_dim_view as
select distbn_chnl_code,
  distbn_chnl_desc
from distbn_chnl_v2
where distbn_chnl_lang = 'E'
  and valdtn_status = 'VALID';
  
/*-*/
/* Authority 
/*-*/
grant select on ods_app.distribution_chnl_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym distribution_chnl_dim_view for ods_app.distribution_chnl_dim_view;
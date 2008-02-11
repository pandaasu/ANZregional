/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : pmx_claim_type_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Promax Claim Type Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.pmx_claim_type_dim_view as
select claim_type_code,
  claim_type_desc
from pmx_claim_type;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.pmx_claim_type_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym pmx_claim_type_dim_view for ods_app.pmx_claim_type_dim_view;
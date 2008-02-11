/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : sales_org_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Sales Org Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.sales_org_dim_view as
select sales_org_code,  -- SAP Sales Org Code 
  sales_org_desc        -- Sales Org Description 
from sales_org_v2
where sales_org_lang = 'E'
  and valdtn_status = 'VALID';
  
/*-*/
/* Authority 
/*-*/
grant select on ods_app.sales_org_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym sales_org_dim_view for ods_app.sales_org_dim_view;
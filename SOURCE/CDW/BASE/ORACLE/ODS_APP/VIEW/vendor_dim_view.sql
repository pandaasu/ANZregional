/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : vendor_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Vendor Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.vendor_dim_view as
select vendor_code,
  vendor_name_en,
  addr_sort_en,
  addr_city_en,
  addr_postl_code_en,
  addr_regn_code_en,
  cntry_code_en
from vendor
where valdtn_status = 'VALID';

/*-*/
/* Authority 
/*-*/
grant select on ods_app.vendor_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym vendor_dim_view for ods_app.vendor_dim_view;
/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : customer_sales_area_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Customer Sales Area Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.customer_sales_area_dim_view as
select t01.kunnr as cust_code,        -- SAP Customer Code
  t02.vkorg as sales_org_code,        -- Sale Org Code
  t02.vtweg as distbn_chnl_code,      -- Distribution Channel Code
  t02.spart as division_code,         -- Division Code
  t02.ktgrd as acct_assgnmnt_grp_code -- Account Assignment Group Code
from sap_cus_hdr t01,
  sap_cus_sad t02
where t01.kunnr = t02.kunnr
  and t01.valdtn_status = 'VALID'
  and t02.ktgrd is not null;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.customer_sales_area_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym customer_sales_area_dim_view for ods_app.customer_sales_area_dim_view;
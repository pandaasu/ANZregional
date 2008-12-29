/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : cust  
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Customer View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.cust as
  select t01.name as name,
    t01.house_number || ' ' || t01.street as addr1,
    ' ' as addr2,
    t01.city as city,
    t01.region_code as region,
    t01.city_post_code as postcode,
    ltrim(t01.customer_code, '0') as cust_code
  from bds_addr_customer_det t01
  where t01.address_version = '*NONE'
    and exists
    (
      select 1
      from bds_cust_sales_area t02
      where t01.customer_code = t02.customer_code
        and t02.sales_org_code = '147'
        and t02.deletion_flag is null         
    );
  
/**/
/* Authority 
/**/
grant select on manu.cust to bds_app with grant option;
grant select on manu.cust to pt_app with grant option;
grant select on manu.cust to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym cust for manu.cust;    
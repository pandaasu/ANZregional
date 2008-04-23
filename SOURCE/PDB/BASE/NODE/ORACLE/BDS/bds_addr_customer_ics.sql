/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 View   : bds_prodctn_resrc_en_ics  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_prodctn_resrc_en_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view bds.bds_addr_customer_ics as
  select t01.customer_code, 
    t01.address_version, 
    t01.valid_from_date,
    t01.valid_to_date, 
    t01.title, t01.name, 
    t01.name_02, 
    t01.name_03,
    t01.name_04, 
    t01.city, 
    t01.district, 
    t01.city_post_code,
    t01.po_box_post_code, 
    t01.company_post_code, 
    t01.po_box,
    t01.po_box_minus_number, 
    t01.po_box_city,
    t01.po_box_region,
    t01.po_box_country, 
    t01.po_box_country_iso, 
    t01.transportation_zone,
    t01.street, 
    t01.house_number, 
    t01.location, 
    t01.building, 
    t01.floor,
    t01.room_number, 
    t01.country, 
    t01.country_iso, 
    t01.language,
    t01.language_iso, 
    t01.region_code, 
    t01.search_term_01,
    t01.search_term_02, 
    t01.phone_number, 
    t01.phone_extension,
    t01.phone_full_number, 
    t01.fax_number, 
    t01.fax_extension,
    t01.fax_full_number
  from bds_addr_customer_det t01
  where exists 
  (
    select 1
    from bds_cust_sales_area_ics t02
    where t02.sales_org_code in ('147', '149')
      and t02.customer_code = t01.customer_code
  );

/**/
/* Authority 
/**/
grant select on bds.bds_addr_customer_ics to appsupport;
grant select on bds.bds_addr_customer_ics to bds_app with grant option;
grant select on bds.bds_addr_customer_ics to fcs_user;

/**/
/* Synonym 
/**/
create or replace public synonym bds_addr_customer_ics for bds.bds_addr_customer_ics;
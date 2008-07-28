/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_ADDR_CUSTOMER_EN
 Owner   : BDS
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Address View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/05   Steve Gregan   Created
 2008/07   Trevor Keon    Added street supplement fields

*******************************************************************************/


/**/
/* Table creation
/**/

create or replace view bds_addr_customer_en as  
  select t01.customer_code, 
    t01.address_version, 
    t01.valid_from_date,
    t01.valid_to_date, 
    t01.title, 
    t01.name, 
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
    t01.fax_full_number, 
    t02.street_supplement_01,
    t02.street_supplement_02, 
    t02.street_supplement_03
  from bds_addr_customer t01, 
    bds_addr_detail t02
  where t01.customer_code = t02.address_code
    and t01.address_version = t02.address_version
    and t01.address_version = '*NONE'
    and t02.address_type = 'KNA1';

/**/
/* Synonym
/**/
create or replace public synonym bds_addr_customer_en for bds.bds_addr_customer_en;

/**/
/* Authority
/**/
grant select on bds.bds_addr_customer_en to lads with grant option;
grant select on bds.bds_addr_customer_en to manu with grant option;
grant select on bds.bds_addr_customer_en to bds_app with grant option;
grant select on bds.bds_addr_customer_en to site_app;
grant select on bds.bds_addr_customer_en to ics_app;
grant select on bds.bds_addr_customer_en to ics_reader;

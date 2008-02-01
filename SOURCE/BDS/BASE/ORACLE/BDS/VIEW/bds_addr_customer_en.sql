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

*******************************************************************************/


/**/
/* Table creation
/**/

create or replace view bds_addr_customer_en as  
   select t01.*
   from bds_addr_customer t01
   where t01.address_version = '*NONE';
/

/**/
/* Synonym
/**/
create or replace public synonym bds_addr_customer_en for bds.bds_addr_customer_en;

/**/
/* Authority
/**/
grant select on bds.bds_addr_customer_en to lads with grant option;
grant select on bds.bds_addr_customer_en to manu with grant option;
grant select on bds.bds_addr_customer_en to site_app;
grant select on bds.bds_addr_customer_en to ics_reader;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_ADDR_CUSTOMER_ZH
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Customer Address View - Chinese

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/03   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/

create or replace view bds_addr_customer_zh as  
   select t01.*
   from bds_addr_customer t01
   where t01.address_version = 'I';
/

/**/
/* Synonym
/**/
create or replace public synonym bds_addr_customer_zh for bds.bds_addr_customer_zh;

/**/
/* Authority
/**/
grant select on bds.bds_addr_customer_zh to public;

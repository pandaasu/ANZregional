/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : cust_partner_funcn
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Customer Partner Function View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.cust_partner_funcn as
   select * from ods_cust_partner_funcn;

/*-*/
/* Authority
/*-*/
grant select on od.cust_partner_funcn to od_app with grant option;
grant select on od.cust_partner_funcn to od_user;
grant select on od.cust_partner_funcn to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym cust_partner_funcn for od.cust_partner_funcn;


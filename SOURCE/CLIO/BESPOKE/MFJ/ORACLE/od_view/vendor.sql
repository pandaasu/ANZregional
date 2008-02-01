/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : vendor
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Vendor View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.vendor as
   select * from ods_vendor;

/*-*/
/* Authority
/*-*/
grant select on od.vendor to od_app with grant option;
grant select on od.vendor to od_user;
grant select on od.vendor to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym vendor for od.vendor;


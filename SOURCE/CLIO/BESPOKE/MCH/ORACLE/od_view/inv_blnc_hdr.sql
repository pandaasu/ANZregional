/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : inv_blnc_hdr
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Inventory Balance Header View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.inv_blnc_hdr as
   select * from ods_inv_blnc_hdr;

/*-*/
/* Authority
/*-*/
grant select on od.inv_blnc_hdr to od_app with grant option;
grant select on od.inv_blnc_hdr to od_user;
grant select on od.inv_blnc_hdr to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym inv_blnc_hdr for od.inv_blnc_hdr;


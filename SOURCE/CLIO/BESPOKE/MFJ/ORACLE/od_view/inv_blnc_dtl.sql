/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : inv_blnc_dtl
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Inventory Balance Detail View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.inv_blnc_dtl as
   select * from ods_inv_blnc_dtl;

/*-*/
/* Authority
/*-*/
grant select on od.inv_blnc_dtl to od_app with grant option;
grant select on od.inv_blnc_dtl to od_user;
grant select on od.inv_blnc_dtl to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym inv_blnc_dtl for od.inv_blnc_dtl;


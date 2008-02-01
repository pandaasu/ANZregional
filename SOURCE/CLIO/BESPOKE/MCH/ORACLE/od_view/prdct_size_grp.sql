/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : prdct_size_grp
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Product Size Group View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.prdct_size_grp as
   select * from ods_prdct_size_grp;

/*-*/
/* Authority
/*-*/
grant select on od.prdct_size_grp to od_app with grant option;
grant select on od.prdct_size_grp to od_user;
grant select on od.prdct_size_grp to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym prdct_size_grp for od.prdct_size_grp;


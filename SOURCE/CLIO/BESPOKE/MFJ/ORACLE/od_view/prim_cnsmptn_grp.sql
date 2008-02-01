/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : prim_cnsmptn_grp
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Primary Consumption Group View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.prim_cnsmptn_grp as
   select * from ods_prim_cnsmptn_grp;

/*-*/
/* Authority
/*-*/
grant select on od.prim_cnsmptn_grp to od_app with grant option;
grant select on od.prim_cnsmptn_grp to od_user;
grant select on od.prim_cnsmptn_grp to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym prim_cnsmptn_grp for od.prim_cnsmptn_grp;


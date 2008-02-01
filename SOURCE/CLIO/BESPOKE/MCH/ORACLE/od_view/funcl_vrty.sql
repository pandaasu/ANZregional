/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : funcl_vrty
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Functional Variety View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.funcl_vrty as
   select * from ods_funcl_vrty;

/*-*/
/* Authority
/*-*/
grant select on od.funcl_vrty to od_app with grant option;
grant select on od.funcl_vrty to od_user;
grant select on od.funcl_vrty to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym funcl_vrty for od.funcl_vrty;


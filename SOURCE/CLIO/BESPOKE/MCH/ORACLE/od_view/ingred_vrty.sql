/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : ingred_vrty
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Ingredient Variety View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.ingred_vrty as
   select * from ods_ingred_vrty;

/*-*/
/* Authority
/*-*/
grant select on od.ingred_vrty to od_app with grant option;
grant select on od.ingred_vrty to od_user;
grant select on od.ingred_vrty to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym ingred_vrty for od.ingred_vrty;


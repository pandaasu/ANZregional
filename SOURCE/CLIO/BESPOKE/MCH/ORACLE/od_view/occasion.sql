/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : occasion
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Occasion View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.occasion as
   select * from ods_occasion;

/*-*/
/* Authority
/*-*/
grant select on od.occasion to od_app with grant option;
grant select on od.occasion to od_user;
grant select on od.occasion to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym occasion for od.occasion;

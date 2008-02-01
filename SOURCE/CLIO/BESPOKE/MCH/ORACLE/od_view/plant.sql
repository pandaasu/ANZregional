/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : plant
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Plant View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.plant as
   select * from ods_plant;

/*-*/
/* Authority
/*-*/
grant select on od.plant to od_app with grant option;
grant select on od.plant to od_user;
grant select on od.plant to pld_rep_app;
grant select on od.plant to dw_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym plant for od.plant;


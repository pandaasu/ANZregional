/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : trad_unit_frmt
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Trade Unit Format View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.trad_unit_frmt as
   select * from ods_trad_unit_frmt;

/*-*/
/* Authority
/*-*/
grant select on od.trad_unit_frmt to od_app with grant option;
grant select on od.trad_unit_frmt to od_user;
grant select on od.trad_unit_frmt to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym trad_unit_frmt for od.trad_unit_frmt;


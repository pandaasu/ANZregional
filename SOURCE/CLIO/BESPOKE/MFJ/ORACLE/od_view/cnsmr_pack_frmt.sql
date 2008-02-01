/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : cnsmr_pack_frmt
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Consumer Pack Format View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.cnsmr_pack_frmt as
   select * from ods_cnsmr_pack_frmt;

/*-*/
/* Authority
/*-*/
grant select on od.cnsmr_pack_frmt to od_app with grant option;
grant select on od.cnsmr_pack_frmt to od_user;
grant select on od.cnsmr_pack_frmt to pld_rep_app;


/*-*/
/* Synonym
/*-*/
create public synonym cnsmr_pack_frmt for od.cnsmr_pack_frmt;


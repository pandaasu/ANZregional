/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_bdt
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS BDT View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/05   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_bdt
   (sap_bdt_code,
    bdt_abbrd_desc,
    bdt_desc) as
   select substr(t01.z_data,36,2),
          substr(t01.z_data,44,12),
          substr(t01.z_data,44,30)
     from lads_ref_dat t01
    where t01.z_tabname = 'CAWNT'
      and substr(t01.z_data,4,10) = '0000000185';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_bdt to od with grant option;
grant select on lads.ods_bdt to dw_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_bdt for lads.ods_bdt;


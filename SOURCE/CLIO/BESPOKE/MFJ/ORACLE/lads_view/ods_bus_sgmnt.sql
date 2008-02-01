/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_bus_sgmnt
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Business Segment View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_bus_sgmnt
   (sap_bus_sgmnt_code,
    bus_sgmnt_abbrd_desc,
    bus_sgmnt_desc) as
   select substr(t01.z_data,4,2),
          substr(t01.z_data,6,12),
          substr(t01.z_data,18,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC001';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_bus_sgmnt to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_bus_sgmnt for lads.ods_bus_sgmnt;
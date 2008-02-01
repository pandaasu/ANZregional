/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_trad_unit_frmt
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Trade Unit Format View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_trad_unit_frmt
   (sap_trad_unit_frmt_code,
    trad_unit_frmt_abbrd_desc,
    trad_unit_frmt_desc) as
   select substr(t01.z_data,4,2),
          substr(t01.z_data,6,12),
          substr(t01.z_data,18,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC020';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_trad_unit_frmt to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_trad_unit_frmt for lads.ods_trad_unit_frmt;


/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_cnsmr_pack_frmt
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Consumer Pack Format View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_cnsmr_pack_frmt
   (sap_cnsmr_pack_frmt_code,
    cnsmr_pack_frmt_abbrd_desc,
    cnsmr_pack_frmt_desc) as
   select substr(t01.z_data,4,2),
          substr(t01.z_data,6,12),
          substr(t01.z_data,18,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC025';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_cnsmr_pack_frmt to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_cnsmr_pack_frmt for lads.ods_cnsmr_pack_frmt;


/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_mkt_sgmnt
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Market Segment View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_mkt_sgmnt
   (sap_mkt_sgmnt_code,
    mkt_sgmnt_abbrd_desc,
    mkt_sgmnt_desc) as
   select substr(t01.z_data,4,2),
          substr(t01.z_data,6,12),
          substr(t01.z_data,18,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC002';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_mkt_sgmnt to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_mkt_sgmnt for lads.ods_mkt_sgmnt;


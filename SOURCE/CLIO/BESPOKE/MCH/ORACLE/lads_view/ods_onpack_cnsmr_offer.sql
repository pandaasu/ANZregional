/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_onpack_cnsmr_offer
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Onpack Consumer Offer View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_onpack_cnsmr_offer
   (sap_onpack_cnsmr_offer_code,
    onpack_cnsmr_offer_abbrd_desc,
    onpack_cnsmr_offer_desc) as
   select substr(t01.z_data,4,2),
          substr(t01.z_data,6,12),
          substr(t01.z_data,18,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC023';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_onpack_cnsmr_offer to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_onpack_cnsmr_offer for lads.ods_onpack_cnsmr_offer;


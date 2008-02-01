/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_prdct_size_grp
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Product Size Group View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_prdct_size_grp
   (sap_prdct_size_grp_code,
    prdct_size_grp_abbrd_desc,
    prdct_size_grp_desc) as 
   select substr(t01.z_data,4,2),
          substr(t01.z_data,6,12),
          substr(t01.z_data,18,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC018';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_prdct_size_grp to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_prdct_size_grp for lads.ods_prdct_size_grp;


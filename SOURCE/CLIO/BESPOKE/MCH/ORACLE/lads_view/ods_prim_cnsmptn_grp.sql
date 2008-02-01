/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_prim_cnsmptn_grp
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Primary Consumption Group View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_prim_cnsmptn_grp
   (sap_prim_cnsmptn_grp_code,
    prim_cnsmptn_grp_abbrd_desc,
    prim_cnsmptn_grp_desc) as
   select substr(t01.z_data,4,2),
          substr(t01.z_data,6,12),
          substr(t01.z_data,18,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC019';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_prim_cnsmptn_grp to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_prim_cnsmptn_grp for lads.ods_prim_cnsmptn_grp;


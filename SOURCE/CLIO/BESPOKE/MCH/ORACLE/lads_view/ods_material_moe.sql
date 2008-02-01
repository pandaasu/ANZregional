/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_material_moe
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Material Mars Organisational Entity View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_material_moe
   (sap_material_code,
    sap_moe_code) as 
   select lads_trim_code(t01.matnr),
          t01.moe
     from lads_mat_moe t01
    where t01.usagecode = 'MKE';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_material_moe to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_material_moe for lads.ods_material_moe;


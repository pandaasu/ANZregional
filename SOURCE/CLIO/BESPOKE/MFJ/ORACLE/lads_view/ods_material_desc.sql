/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_material_desc
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Material Description View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_material_desc
   (sap_material_code,
    sap_lang_code,
    material_desc) as 
   select lads_trim_code(t01.matnr),
          t01.spras_iso,
          t01.maktx
     from lads_mat_mkt t01;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_material_desc to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_material_desc for lads.ods_material_desc;


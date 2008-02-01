/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_material_cross_ref
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Material Cross Reference View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_material_cross_ref
   (sap_material_code,
    sap_matl_cross_ref_type_code,
    material_cross_ref) as 
   select lads_trim_code(t01.z_matnr),
          t01.z_lcdid,
          lads_trim_code(t01.z_lcdnr)
     from lads_mat_lcd t01;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_material_cross_ref to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_material_cross_ref for lads.ods_material_cross_ref;


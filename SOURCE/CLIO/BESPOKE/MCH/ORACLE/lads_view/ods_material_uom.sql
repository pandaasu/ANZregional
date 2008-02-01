/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_material_uom
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Material Unit Of Measure View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_material_uom
   (sap_material_code,
    denominator_x_conv,
    numerator_y_conv,
    alt_uom_code,
    alt_uom_ean_upc,
    alt_uom_ean_upc_ctgry_code,
    alt_uom_lngth,
    alt_uom_wdth,
    alt_uom_ht,
    alt_uom_dim_code,
    alt_uom_vol,
    alt_uom_vol_unit_code,
    alt_uom_gross_wght,
    alt_uom_wght_unit_code) as 
   select lads_trim_code(t01.matnr),
          t01.umren,
          t01.umrez,
          t01.meinh,
          t01.ean11,
          t01.numtp,
          t01.laeng,
          t01.breit,
          t01.hoehe,
          t01.meabm,
          t01.volum,
          t01.voleh,
          t01.brgew,
          t01.gewei
     from lads_mat_uom t01;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_material_uom to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_material_uom for lads.ods_material_uom;


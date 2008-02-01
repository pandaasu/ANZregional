/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_material_std_price
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Material Standard Price View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_material_std_price
   (sap_material_code,
    sap_plant_code,
    price_unit,
    std_price) as 
   select lads_trim_code(t01.matnr),
          t01.bwkey,
          t01.peinh,
          t01.stprs
     from lads_mat_mbe t01;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_material_std_price to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_material_std_price for lads.ods_material_std_price;


/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_intransit_contnr_dtl
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Intransit Container Detail View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_intransit_contnr_dtl
   (handling_unit_id,
    sap_material_code,
    shipd_qty,
    material_batch_desc,
    sap_plant_code,
    sap_storage_locn_code) as 
   select t01.exidv,
          lads_trim_code(t01.matnr),
          t01.vemng,
          t01.charg,
          t01.werks,
          t01.lgort
     from lads_icb_mfj_det t01;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_intransit_contnr_dtl to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_intransit_contnr_dtl for lads.ods_intransit_contnr_dtl;


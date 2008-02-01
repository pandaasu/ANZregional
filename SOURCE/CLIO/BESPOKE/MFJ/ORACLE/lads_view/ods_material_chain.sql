/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_material_chain
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Material Chain View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created
 2005/11   Steve Gregan	  Added cmpnt_usage and cmpnt_status

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_material_chain
   (sap_material_code,
    material_chain_valid_from_date,
    cmpnt_usage,
    cmpnt_status,
    cmpnt_material_code,
    cmpnt_qty,
    cmpnt_uom_code,
    material_chain_lupdt) as 
   select lads_trim_code(t01.matnr),
          lads_to_date(t01.datuv,'yyyymmdd'),
          t01.stlan,
          t01.stlst,
          lads_trim_code(t02.idnrk),
          t02.menge_c,
          t02.meins,
          t01.lads_date
     from lads_mat_bom_hdr t01,
          lads_mat_bom_det t02
    where t01.stlnr = t02.stlnr
      and t01.stlal = t02.stlal;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_material_chain to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_material_chain for lads.ods_material_chain;


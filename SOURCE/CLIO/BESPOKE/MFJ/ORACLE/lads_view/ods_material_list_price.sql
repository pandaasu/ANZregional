/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_material_list_price
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Material List Price View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_material_list_price
   (sap_material_code,
    sap_cndtn_type_code,
    sap_sales_org_code,
    sap_distbn_chnl_code,
    material_list_price_valid_from,
    material_list_price_valid_to,
    material_list_price,
    material_list_price_crrcy_code,
    material_list_price_per_units,
    material_list_price_uom_code) as 
   select lads_trim_code(t01.matnr),
          t01.kschl,
          t01.vkorg,
          t01.vtweg,
          lads_to_date(t01.datab,'yyyymmdd'),
          lads_to_date(t01.datbi,'yyyymmdd'),
          t02.kbetr,
          t02.konwa,
          t02.kpein,
          t02.kmein
     from lads_prc_lst_hdr t01,
          lads_prc_lst_det t02
    where t01.vakey = t02.vakey
      and t01.kschl = t02.kschl
      and t01.datab = t02.datab
      and t01.knumh = t02.knumh;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_material_list_price to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_material_list_price for lads.ods_material_list_price;


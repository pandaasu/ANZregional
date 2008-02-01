/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_address
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Address View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_address
   (sap_addr_type_code,
    sap_cust_vendor_code,
    sap_addr_context_code,
    addr_vrsn,
    addr_valid_from_date,
    addr_valid_to_date,
    addr_name,
    addr_city,
    addr_postl_code,
    addr_street,
    sap_addr_cntry_code,
    sap_addr_lang_code,
    sap_addr_regn_code,
    addr_sort,
    addr_time_zone,
    addr_tel,
    addr_fax,
    addr_lupdt) as 
   select t01.obj_type,
          lads_trim_code(t01.obj_id),
          t01.context,
          t02.addr_vers,
          t02.from_date,
          t02.to_date,
          trim(t02.name)||' '||trim(t02.name_2),
          t02.city,
          t02.postl_cod1,
          t02.street,
          t02.country,
          t02.langu_iso,
          t02.region,
          t02.sort1,
          t02.time_zone,
          t03.telephone,
          t04.fax,
          t01.lads_date
     from lads_adr_hdr t01,
          lads_adr_det t02,
          lads_adr_tel t03,
          lads_adr_fax t04
    where t01.obj_type = t02.obj_type(+)
      and t01.obj_id = t02.obj_id(+)
      and t01.context = t02.context(+)
      and t01.obj_type = t03.obj_type(+)
      and t01.obj_id = t03.obj_id(+)
      and t01.context = t03.context(+)
      and t01.obj_type = t04.obj_type(+)
      and t01.obj_id = t04.obj_id(+)
      and t01.context = t04.context(+)
      and t03.std_no(+) = 'X'
      and t04.std_no(+) = 'X';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_address to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_address for lads.ods_address;


/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : matl_vndr_xref
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Material Vender Cross-reference View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.matl_vndr_xref as
  select t01.plant_code as plant,
    ltrim(t01.sap_material_code,'0') as matl_code,
    t01.vendor_code as vndr_code,
    nvl(t02.vendor_name_01,'Missing in Atlas') as vndr_name,
    to_char(t01.src_list_valid_from, 'yyyymmdd') as eff_start_date,
    to_char(t01.src_list_valid_to, 'yyyymmdd') as eff_end_date,  
    t01.plant_procured_from as plant_from,
    t01.purchasing_organisation as prchsng_org,
    t02.company_code as sales_org,
    t01.order_unit as uom
  from bds_refrnc_purchasing_src t01,
    bds_vend_comp t02
  where t01.vendor_code = t02.vendor_code(+)
    and t01.plant_code like 'AU%'
    and (t02.company_code is null or t02.company_code in ('147','149'));
  
/**/
/* Authority 
/**/
grant select on manu.matl_vndr_xref to bds_app with grant option;
grant select on manu.matl_vndr_xref to pt_app with grant option;
grant select on manu.matl_vndr_xref to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym matl_vndr_xref for manu.matl_vndr_xref;   
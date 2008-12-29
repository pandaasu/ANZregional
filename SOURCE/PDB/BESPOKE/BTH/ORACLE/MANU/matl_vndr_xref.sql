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
 Manufacturing - Material Vendor Reference View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/10   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.matl_vndr_xref as
  select distinct t13.plant_code as plant,
    ltrim(t13.sap_material_code,'0') as matl_code,
    t13.vendor_code as vndr_code,
    decode(t14.vendor_name_01, null, 'Missing in Atlas', t14.vendor_name_01) as vndr_name,
    to_char(t13.src_list_valid_from,'yyyymmdd') as eff_start_date,
    to_char(t13.src_list_valid_to,'yyyymmdd') as eff_end_date,
    t13.plant_procured_from as plant_from,
    t13.purchasing_organisation as prchsng_org,
    t14.company_code as sales_org,
    t13.order_unit as uom
  from bds_refrnc_purchasing_src t13,
    bds_vend_comp t14        
  where t13.vendor_code = t14.vendor_code (+)
    and t13.plant_code in ('AU30')
    and t14.deletion_flag is null;

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
/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : matl_rprsnttv_xref
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Material Representative Reference View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view bds_app.matl_rprsnttv_xref_ics as
  select ltrim(t01.sap_material_code,'0') as matl_code,
    ltrim(t01.mars_rprsnttv_item_code,'0') as rprsnttv_item_code,
    case when t01.plant_code like 'AU%' then t01.sales_text_147 else t01.sales_text_149 end as matl_sales_text,
    t01.plant_code as plant_code
  from bds_material_plant_mfanz_test t01
  where t01.plant_code IN ('AU20', 'AU21', 'AU22', 'AU25')
    and t01.mars_rprsnttv_item_code is not null
    and 
    (
      (t01.plant_code like 'AU%' and t01.sales_text_147 is not null)
      or (t01.plant_code like 'NZ%' and t01.sales_text_149 is not null)
    );
    
/**/
/* Authority 
/**/
--grant select on bds_app.matl_rprsnttv_xref_ics to bds_app with grant option;
grant select on bds_app.matl_rprsnttv_xref_ics to pt_app with grant option;
grant select on bds_app.matl_rprsnttv_xref_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym matl_rprsnttv_xref_ics for bds_app.matl_rprsnttv_xref_ics;    
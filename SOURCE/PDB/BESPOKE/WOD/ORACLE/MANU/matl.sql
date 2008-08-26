/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : matl 
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Materials View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view bds_app.matl_ics as
  select ltrim(t01.sap_material_code,'0') as matl_code,
    t01.bds_material_desc_en as matl_desc,
    t01.plant_code as plant,
    t01.material_type as matl_type,
    t01.material_grp as matl_group,
    ltrim(t01.regional_code_17,'0') as rgnl_code_nmbr,
    t01.base_uom as base_uom,
    t01.order_unit as order_uom,
    t01.gross_weight as gross_wght,
    t01.net_weight as net_wght,
    t01.gross_weight_unit as dclrd_uom,
    t01.length as lngth,
    t01.width as width,
    t01.height as hght,
    t01.dimension_uom as uom_for_lwh,
    t01.interntl_article_no as ean_code,
    t01.total_shelf_life as shelf_life,
    t01.mars_intrmdt_prdct_compnt_flag as intrmdt_prdct_cmpnnt,
    t01.mars_merchandising_unit_flag as mrchndsng_unit,
    t01.mars_prmotional_material_flag as prmtnl_matl,
    t01.mars_retail_sales_unit_flag as rtl_sales_unit,
    t01.mars_semi_finished_prdct_flag as semi_fnshd_prdct,
    t01.mars_rprsnttv_item_flag as rprsnttv_item,
    t01.mars_traded_unit_flag as trdd_unit,
    t01.mars_plant_material_type as plant_orntd_matl_type,
    t01.bds_unit_cost as unit_cost,
    t01.batch_mngmnt_reqrmnt_indctr as batch_mngmnt_rqrmnt_indctr,
    t01.procurement_type as prcrmnt_type,
    t01.special_procurement_type as spcl_prcrmnt_type,
    t01.issue_storage_location as issue_strg_locn,
    t01.mrp_controller as mrp_cntrllr,
    t01.plant_specific_status_valid as plant_sts_start,
    t01.xplant_status as x_plant_matl_sts,
    t01.xplant_status_valid as x_plant_matl_sts_start,
    t01.deletion_indctr as dltn_indctr,
    t01.plant_specific_status as plant_sts,
    t01.assembly_scrap_percntg as assy_scrap,
    t01.component_scrap_percntg as comp_scrap,
    t01.future_planned_price_1 as plnd_price,
    t01.vltn_class as vltn_class,
    t01.backflush_indctr as back_flush_ind
  from bds_material_plant_mfanz_test t01
  where plant_code IN ('AU20', 'AU21', 'AU22', 'AU23', 'AU24', 'AU25');

/**/
/* Authority 
/**/
--grant select on bds_app.matl_ics to bds_app with grant option;
grant select on bds_app.matl_ics to pt_app with grant option;
grant select on bds_app.matl_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym matl_ics for bds_app.matl_ics; 
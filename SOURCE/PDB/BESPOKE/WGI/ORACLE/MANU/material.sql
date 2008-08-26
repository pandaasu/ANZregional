/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : material 
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
create or replace force view bds_app.material_ics as
  select ltrim(t01.sap_material_code,'0') as material_code,
    t01.material_type as material_type,
    t01.material_grp as material_grp,
    ltrim(t01.regional_code_10,'0') as old_material_code,
    t01.base_uom as uom,
    t01.order_unit as order_uom,
    t01.gross_weight as gross_wght,
    t01.net_weight as dclrd_wght,
    t01.gross_weight_unit as dclrd_uom,
    t01.interntl_article_no as ean_code,
    t01.length as length,
    t01.width as width,
    t01.height as height,
    t01.dimension_uom as uod,
    t01.total_shelf_life as shelf_life,
    t01.mars_intrmdt_prdct_compnt_flag as int_code,
    t01.mars_merchandising_unit_flag as mcu_code,
    t01.mars_prmotional_material_flag as pro_code,
    t01.mars_retail_sales_unit_flag as rsu_code,
    t01.mars_semi_finished_prdct_flag as sfp_code,
    t01.mars_rprsnttv_item_flag as rep_code,
    t01.mars_traded_unit_flag as tdu_code,
    t01.bds_material_desc_en as material_desc,
    t01.mars_plant_material_type as plant_orntd_matl_type,
    t01.plant_specific_status_valid as eff_start_date,
    t01.bds_unit_cost as unit_cost,
    t01.batch_mngmnt_reqrmnt_indctr as batch_mngmnt_rqrmnt_indctr,
    t01.procurement_type as prcrmnt_type,
    t01.xplant_status as x_plant_matl_sts,
    t01.xplant_status_valid as x_plant_matl_sts_start,
    t01.deletion_indctr as dltn_indctr,
    t01.plant_specific_status as plant_sts
  from bds_material_plant_mfanz t01
  where plant_code = 'NZ01';

/**/
/* Authority 
/**/
--grant select on bds_app.material_ics to bds_app with grant option;
grant select on bds_app.material_ics to pt_app with grant option;
grant select on bds_app.material_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym material_ics for bds_app.material_ics; 
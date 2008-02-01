/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : fcst_material_list_price
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - Forecast Material List Price

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dw_app.fcst_material_list_price
   (sap_material_code,
    sap_sales_org_code,
    sap_distbn_chnl_code,
    sap_cndtn_type_code, 
    cndtn_type_desc,
    material_list_price_buom,
    material_list_price_valid_from,
    material_list_price_valid_to) as
   select t2.sap_material_code, 
          t1.sap_sales_org_code, 
          t1.sap_distbn_chnl_code, 
          t1.sap_cndtn_type_code, 
          t1.cndtn_type_desc,  
          t1.material_list_price_buom, 
          t1.material_list_price_valid_from, 
          t1.material_list_price_valid_to 
     from (select t11.sap_material_code, 
                  t12.sap_sales_org_code, 
                  t12.sap_distbn_chnl_code,  
                  t12.sap_cndtn_type_code,
                  t14.cndtn_type_desc,
                  t12.material_list_price / material_list_price_per_units / t13.numerator_y_conv * t13.denominator_x_conv as material_list_price_buom, 
                  t12.material_list_price_valid_from, 
                  t12.material_list_price_valid_to 
             from material_dim t11,
                  material_list_price t12, 
                  material_uom t13,
                  condition_type t14
            where t11.sap_material_code = t12.sap_material_code
              and t12.sap_material_code = t13.sap_material_code(+)
              and t12.material_list_price_uom_code = t13.alt_uom_code(+)
              and t12.sap_cndtn_type_code = t14.sap_cndtn_type_code
              and t12.sap_cndtn_type_code in ('PR00','ZK30')) t1,
          material_dim t2
    where t1.sap_material_code = decode(t2.sap_rep_item_code,null,t2.sap_material_code,t2.sap_rep_item_code);

/*-*/
/* Authority
/*-*/
grant select on dw_app.fcst_material_list_price to mfj_plan;
grant select on dw_app.fcst_material_list_price to pp_app;

/*-*/
/* Synonym
/*-*/
create public synonym fcst_material_list_price for dw_app.fcst_material_list_price;
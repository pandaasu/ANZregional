DROP VIEW MANU.MATL_VW;

/* Formatted on 2008/12/22 10:59 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.matl_vw (matl_code,
                                           matl_desc,
                                           plant,
                                           matl_type,
                                           matl_group,
                                           rgnl_code_nmbr,
                                           base_uom,
                                           order_uom,
                                           gross_wght,
                                           net_wght,
                                           dclrd_uom,
                                           lngth,
                                           width,
                                           hght,
                                           uom_for_lwh,
                                           ean_code,
                                           shelf_life,
                                           intrmdt_prdct_cmpnnt,
                                           mrchndsng_unit,
                                           prmtnl_matl,
                                           rtl_sales_unit,
                                           semi_fnshd_prdct,
                                           rprsnttv_item,
                                           trdd_unit,
                                           plant_orntd_matl_type,
                                           unit_cost,
                                           batch_mngmnt_rqrmnt_indctr,
                                           prcrmnt_type,
                                           spcl_prcrmnt_type,
                                           issue_strg_locn,
                                           mrp_cntrllr,
                                           plant_sts_start,
                                           x_plant_matl_sts,
                                           x_plant_matl_sts_start,
                                           dltn_indctr,
                                           plant_sts,
                                           assy_scrap,
                                           comp_scrap,
                                           plnd_price,
                                           vltn_class,
                                           back_flush_ind,
                                           brand_flag_code,
                                           brand_flag_short_desc,
                                           brand_flag_long_desc,
                                           rprsnttv_item_code,
                                           matl_sales_text,
                                           followup_material,
                                           material_division,
                                           mrp_type,
                                           max_storage_prd,
                                           max_storage_prd_unit
                                          )
AS
  SELECT       /*************************************************************/
              /*  Created:  09 Feb 2007                                     */
              /*    By:   Jeff Phillipson                                   */
              /*                                                            */
              /*    Ver   Date       Author       Description               */
              /*  ----- ---------- ------------------------------------     */
              /*   1.0  09/02/2007 J Phillipson Converted for snack food    */
              /*  PURPOSE                                                   */
              /* Provide a generic view of Material data                    */
              /*  Note:                                                     */
              /*   This contains all requirements for all plants to date    */
              /**************************************************************/
         LTRIM (t01.sap_material_code, '0') matl_code,
         t01.bds_material_desc_en matl_desc, t01.plant_code plant,
         t01.material_type matl_type,
                             -- ROH Raw, FERT FG, VERP Packaging, PIPE non MRP
                                     t01.material_grp matl_group,
         
         /* the next line is based on site: 10 Wyong, 17 Petcare, 19 Snack, 18 NZ */
         LTRIM (t01.regional_code_19, '0') rgnl_code_nmbr,
         t01.base_uom base_uom, t01.order_unit order_uom,
         t01.gross_weight gross_wght, t01.net_weight net_wght,
         t01.gross_weight_unit dclrd_uom, t01.LENGTH lngth, t01.width width,
         t01.height hght, t01.dimension_uom uom_for_lwh,
         t01.interntl_article_no ean_code, t01.total_shelf_life shelf_life,
         t01.mars_intrmdt_prdct_compnt_flag intrmdt_prdct_cmpnnt,       -- int
         t01.mars_merchandising_unit_flag mrchndsng_unit,               -- msu
         t01.mars_prmotional_material_flag prmtnl_matl,
         t01.mars_retail_sales_unit_flag rtl_sales_unit,                -- rsu
         t01.mars_semi_finished_prdct_flag semi_fnshd_prdct,            -- sfp
         t01.mars_rprsnttv_item_flag rprsnttv_item,                     -- rep
         t01.mars_traded_unit_flag trdd_unit,                           -- tdu
         t01.mars_plant_material_type plant_orntd_matl_type,
         TO_CHAR (t01.bds_unit_cost) unit_cost,
         t01.batch_mngmnt_reqrmnt_indctr batch_mngmnt_rqrmnt_indctr,
         t01.procurement_type prcrmnt_type,
         t01.special_procurement_type spcl_prcrmnt_type,
         t01.issue_storage_location issue_strg_locn,
         t01.mrp_controller mrp_cntrllr,
         DECODE (t01.plant_specific_status_valid,
                 NULL, TO_DATE ('01/01/1900', 'dd/mm/yyyy'),
                 t01.plant_specific_status_valid
                ) plant_sts_start,
         t01.xplant_status x_plant_matl_sts,
         DECODE (t01.xplant_status_valid,
                 NULL, TO_DATE ('01/01/1900', 'dd/mm/yyyy'),
                 t01.xplant_status_valid
                ) x_plant_matl_sts_start,
         t01.deletion_indctr dltn_indctr, t01.plant_specific_status plant_sts,
         t01.assembly_scrap_percntg assy_scrap,
         t01.component_scrap_percntg comp_scrap,
         t01.future_planned_price_1 plnd_price, t01.vltn_class,
         t01.backflush_indctr back_flush_ind,
         DECODE (t01.material_type,
                 'FERT', t02.sap_brand_flag_code,
                 NULL
                ) brand_flag_code,
         DECODE (t01.material_type,
                 'FERT', t03.sap_charistic_value_shrt_desc,
                 NULL
                ) brand_flag_short_desc,
         DECODE (t01.material_type,
                 'FERT', t03.sap_charistic_value_long_desc,
                 NULL
                ) brand_flag_long_desc,
         LTRIM (t01.mars_rprsnttv_item_code, '0') rprsnttv_item_code,
         
         /* select 147 for Australia - 149 for NZ */
         DECODE (t04.plant_sales_organisation,
                 '147', t01.sales_text_147,
                 t01.sales_text_149
                ) matl_sales_text,
         LTRIM (followup_material, '0') followup_material, material_division,
         mrp_type, max_storage_prd, max_storage_prd_unit
    FROM bds_material_plant_mfanz t01,
         bds_material_classfctn t02,
         bds_refrnc_charistic t03,
         bds_refrnc_plant t04
   WHERE (   t01.material_type IN ('ROH', 'VERP', 'NLAG', 'PIPE')
          OR (    t01.material_type = 'FERT'
              AND (   t01.mars_traded_unit_flag = 'X'
                   OR t01.mars_merchandising_unit_flag = 'X'
                   OR t01.mars_retail_sales_unit_flag = 'X'
                   OR t01.mars_intrmdt_prdct_compnt_flag = 'X'
                  )
             )
         )
     AND t01.sap_material_code = t02.sap_material_code(+)
     AND t02.sap_brand_flag_code = t03.sap_charistic_value_code(+)
     AND t01.plant_code = t04.plant_code
     AND t03.sap_charistic_code(+) = '/MARS/MD_CHC003'
     AND t01.plant_code = 'AU40';


DROP PUBLIC SYNONYM MATL_VW;

CREATE PUBLIC SYNONYM MATL_VW FOR MANU.MATL_VW;


GRANT SELECT ON MANU.MATL_VW TO APPSUPPORT;

GRANT SELECT ON MANU.MATL_VW TO MANU_APP WITH GRANT OPTION;

GRANT SELECT ON MANU.MATL_VW TO PUBLIC;


DROP VIEW MANU.MATERIAL;

/* Formatted on 2010/09/30 11:07 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.material (material_code,
                                            material_type,
                                            material_grp,
                                            old_material_code,
                                            uom,
                                            order_uom,
                                            gross_wght,
                                            dclrd_wght,
                                            dclrd_uom,
                                            ean_code,
                                            LENGTH,
                                            width,
                                            height,
                                            uod,
                                            shelf_life,
                                            int_code,
                                            mcu_code,
                                            pro_code,
                                            rsu_code,
                                            sfp_code,
                                            rep_code,
                                            tdu_code,
                                            material_desc,
                                            plant_orntd_matl_type,
                                            eff_start_date,
                                            unit_cost,
                                            batch_mngmnt_rqrmnt_indctr,
                                            prcrmnt_type,
                                            x_plant_matl_sts,
                                            x_plant_matl_sts_start,
                                            dltn_indctr,
                                            plant_sts,
                                            store_locn
                                           )
AS
   SELECT LTRIM (t01.sap_material_code, '0') AS material_code,
          t01.material_type AS material_type,
          t01.material_grp AS material_grp,
          LTRIM (t01.regional_code_18, '0') AS old_material_code,
          t01.base_uom AS uom, t01.order_unit AS order_uom,
          t01.gross_weight AS gross_wght, t01.net_weight AS dclrd_wght,
          t01.gross_weight_unit AS dclrd_uom,
          t01.interntl_article_no AS ean_code, t01.LENGTH AS LENGTH,
          t01.width AS width, t01.height AS height, t01.dimension_uom AS uod,
          t01.total_shelf_life AS shelf_life,
          t01.mars_intrmdt_prdct_compnt_flag AS int_code,
          t01.mars_merchandising_unit_flag AS mcu_code,
          t01.mars_prmotional_material_flag AS pro_code,
          t01.mars_retail_sales_unit_flag AS rsu_code,
          t01.mars_semi_finished_prdct_flag AS sfp_code,
          t01.mars_rprsnttv_item_flag AS rep_code,
          t01.mars_traded_unit_flag AS tdu_code,
          t01.bds_material_desc_en AS material_desc,
          t01.mars_plant_material_type AS plant_orntd_matl_type,
          NVL (t01.plant_specific_status_valid,
               TO_DATE ('19000101', 'yyyymmdd')
              ) AS eff_start_date,
          TO_CHAR (t01.bds_unit_cost) AS unit_cost,
          t01.batch_mngmnt_reqrmnt_indctr AS batch_mngmnt_rqrmnt_indctr,
          t01.procurement_type AS prcrmnt_type,
          t01.xplant_status AS x_plant_matl_sts,
          NVL (t01.xplant_status_valid,
               TO_DATE ('19000101', 'yyyymmdd')
              ) AS x_plant_matl_sts_start,
          t01.deletion_indctr AS dltn_indctr,
          t01.plant_specific_status AS plant_sts,
          t01.issue_storage_location AS store_locn
     FROM bds_material_plant_mfanz t01
    WHERE plant_code = 'AU10'
      AND (   t01.material_type IN
                              ('ROH', 'VERP', 'NLAG', 'PIPE', 'ERSA', 'ZROH')
           OR (    t01.material_type = 'FERT'
               AND (   t01.mars_traded_unit_flag = 'X'
                    OR t01.mars_retail_sales_unit_flag = 'X'
                   )
              )
          );


DROP PUBLIC SYNONYM MATERIAL;

CREATE PUBLIC SYNONYM MATERIAL FOR MANU.MATERIAL;


GRANT SELECT ON MANU.MATERIAL TO BDS_APP WITH GRANT OPTION;

GRANT SELECT ON MANU.MATERIAL TO MANU_APP WITH GRANT OPTION;

GRANT SELECT ON MANU.MATERIAL TO PT_APP WITH GRANT OPTION;

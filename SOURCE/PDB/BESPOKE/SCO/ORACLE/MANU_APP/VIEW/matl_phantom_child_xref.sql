DROP VIEW MANU_APP.MATL_PHANTOM_CHILD_XREF;

/* Formatted on 2008/06/30 14:45 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.matl_phantom_child_xref (parent_matl_code,
                                                               parent_matl_type,
                                                               child_matl_code,
                                                               child_matl_type,
                                                               child_phantom
                                                              )
AS
  SELECT t02.bom_material_code parent_matl_code,
            t01.material_type
         || CASE
              WHEN t01.mars_intrmdt_prdct_compnt_flag = 'X'
                THEN '_INT'
              WHEN t01.mars_merchandising_unit_flag = 'X'
                THEN '_MCU'
              WHEN t01.mars_prmotional_material_flag = 'X'
                THEN '_PRM'
              WHEN t01.mars_retail_sales_unit_flag = 'X'
                THEN '_RSU'
              WHEN t01.mars_semi_finished_prdct_flag = 'X'
                THEN '_SFR'
              WHEN t01.mars_rprsnttv_item_flag = 'X'
                THEN '_REP'
              WHEN t01.mars_traded_unit_flag = 'X'
                THEN '_TDU'
              ELSE ''
            END parent_matl_type,
         t02.item_material_code child_matl_code,
            t03.material_type
         || CASE
              WHEN t03.mars_intrmdt_prdct_compnt_flag = 'X'
                THEN '_INT'
              WHEN t03.mars_merchandising_unit_flag = 'X'
                THEN '_MCU'
              WHEN t03.mars_prmotional_material_flag = 'X'
                THEN '_PRM'
              WHEN t03.mars_retail_sales_unit_flag = 'X'
                THEN '_RSU'
              WHEN t03.mars_semi_finished_prdct_flag = 'X'
                THEN '_SFR'
              WHEN t03.mars_rprsnttv_item_flag = 'X'
                THEN '_REP'
              WHEN t03.mars_traded_unit_flag = 'X'
                THEN '_TDU'
              ELSE ''
            END child_matl_type,
         CASE
           WHEN t03.procurement_type = 'E'
           AND t03.special_procurement_type = '50'
             THEN 'Y'
           ELSE 'N'
         END child_phantom
    FROM bds_material_plant_mfanz t01,
         TABLE (bds_bom.get_dataset (SYSDATE,
                                     LTRIM (t01.sap_material_code, '0'),
                                     t01.plant_code
                                    )
               ) t02,
         bds_material_plant_mfanz t03
   WHERE t02.item_material_code = LTRIM (t03.sap_material_code, '0')
     AND t01.plant_code = t03.plant_code
     AND t01.plant_code = 'AU40'
     AND t01.procurement_type = 'E'
     AND t01.special_procurement_type = '50';


DROP PUBLIC SYNONYM MATL_PHANTOM_CHILD_XREF;

CREATE PUBLIC SYNONYM MATL_PHANTOM_CHILD_XREF FOR MANU_APP.MATL_PHANTOM_CHILD_XREF;


GRANT SELECT ON MANU_APP.MATL_PHANTOM_CHILD_XREF TO APPSUPPORT;

GRANT SELECT ON MANU_APP.MATL_PHANTOM_CHILD_XREF TO FCS_USER WITH GRANT OPTION;


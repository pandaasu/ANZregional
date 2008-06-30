DROP VIEW MANU_APP.ICS_MATL_BRAND_XREF;

/* Formatted on 2008/06/30 14:33 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.ics_matl_brand_xref (matl_code,
                                                           brand_flag_code,
                                                           brand_flag_short_desc,
                                                           brand_flag_long_desc
                                                          )
AS
  SELECT t01.sap_material_code matl_code,
         t01.sap_brand_flag_code brand_flag_code,
         t02.sap_charistic_value_shrt_desc brand_flag_short_desc,
         t02.sap_charistic_value_long_desc brand_flag_long_desc
    FROM bds_material_classfctn_ics t01, bds_refrnc_charistic_ics t02
   WHERE t01.sap_brand_flag_code = t02.sap_charistic_value_code
     AND t02.sap_charistic_code = '/MARS/MD_CHC003';



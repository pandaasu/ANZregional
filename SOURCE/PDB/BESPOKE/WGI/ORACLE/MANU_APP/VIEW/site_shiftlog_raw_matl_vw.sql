DROP VIEW MANU_APP.SITE_SHIFTLOG_RAW_MATL_VW;

/* Formatted on 2008/11/05 13:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.site_shiftlog_raw_matl_vw (matl_code,
                                                                 matl_type,
                                                                 matl_desc,
                                                                 plant_orntd_matl_type
                                                                )
AS
  SELECT material_code, material_type, material_desc, plant_orntd_matl_type
    FROM (SELECT   material_code, material_type, material_desc,
                   plant_orntd_matl_type, MAX (x_plant_matl_sts_start)
              FROM material_plan
             WHERE material_type IN ('ROH', 'VERP')
               AND plant = 'NZ01'
               AND plant_sts = 20
               AND x_plant_matl_sts_start <= SYSDATE
          GROUP BY material_code,
                   material_type,
                   material_desc,
                   plant_orntd_matl_type);


DROP PUBLIC SYNONYM SITE_SHIFTLOG_RAW_MATL_VW;

CREATE PUBLIC SYNONYM SITE_SHIFTLOG_RAW_MATL_VW FOR MANU_APP.SITE_SHIFTLOG_RAW_MATL_VW;


GRANT SELECT ON MANU_APP.SITE_SHIFTLOG_RAW_MATL_VW TO MANU_USER;

GRANT SELECT ON MANU_APP.SITE_SHIFTLOG_RAW_MATL_VW TO SHIFTLOG WITH GRANT OPTION;

GRANT SELECT ON MANU_APP.SITE_SHIFTLOG_RAW_MATL_VW TO SHIFTLOG_APP WITH GRANT OPTION;


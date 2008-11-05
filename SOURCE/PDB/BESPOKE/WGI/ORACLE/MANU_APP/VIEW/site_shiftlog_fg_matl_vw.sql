DROP VIEW MANU_APP.SITE_SHIFTLOG_FG_MATL_VW;

/* Formatted on 2008/11/05 13:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.site_shiftlog_fg_matl_vw (matl_code,
                                                                matl_desc,
                                                                units_per_case,
                                                                gross_wght,
                                                                gross_wght_uom
                                                               )
AS
  SELECT DISTINCT a.material_code matl_code, a.material_desc matl_desc,
                  b.units_per_case AS units_per_case, a.gross_wght,
                  a.dclrd_uom AS gross_wght_uom
             FROM material a,
                  (SELECT matl_code, units_per_case, units_per_case_date
                     FROM material_pllt
                   UNION
                   SELECT matl_code, units_per_case, units_per_case_date
                     FROM material_pllt_nc) b
            WHERE a.material_code = LTRIM (b.matl_code(+), '0')
              AND material_type = 'FERT'
              AND a.rsu_code IS NULL
              AND b.units_per_case IS NOT NULL
              AND a.material_code NOT IN (SELECT matl_code
                                            FROM site_mvms_pllt)
              AND (   b.units_per_case_date =
                        (SELECT MAX (units_per_case_date)
                           FROM (SELECT matl_code, units_per_case_date
                                   FROM material_pllt
                                 UNION
                                 SELECT matl_code, units_per_case_date
                                   FROM material_pllt_nc) p
                          WHERE p.matl_code = b.matl_code)
                   OR b.units_per_case_date IS NULL
                  )
              AND (   b.units_per_case_date <= SYSDATE
                   OR b.units_per_case_date IS NULL
                  )
  UNION ALL
  SELECT   matl_code, matl_desc, units_per_case, gross_wght, gross_wght_uom
      FROM site_mvms_pllt
  ORDER BY 1;


DROP PUBLIC SYNONYM SITE_SHIFTLOG_FG_MATL_VW;

CREATE PUBLIC SYNONYM SITE_SHIFTLOG_FG_MATL_VW FOR MANU_APP.SITE_SHIFTLOG_FG_MATL_VW;


GRANT SELECT ON MANU_APP.SITE_SHIFTLOG_FG_MATL_VW TO MANU_USER;

GRANT SELECT ON MANU_APP.SITE_SHIFTLOG_FG_MATL_VW TO SHIFTLOG WITH GRANT OPTION;

GRANT SELECT ON MANU_APP.SITE_SHIFTLOG_FG_MATL_VW TO SHIFTLOG_APP WITH GRANT OPTION;


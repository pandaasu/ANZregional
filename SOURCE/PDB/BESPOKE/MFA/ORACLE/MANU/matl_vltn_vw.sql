DROP VIEW MANU.MATL_VLTN_VW;

/* Formatted on 2008/12/22 11:05 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.matl_vltn_vw (matl_code,
                                                vltn_area,
                                                stndrd_price,
                                                price_unit,
                                                vltn_area_dltn_indctr
                                               )
AS
  SELECT "MATL_CODE", "VLTN_AREA", "STNDRD_PRICE", "PRICE_UNIT",
         "VLTN_AREA_DLTN_INDCTR"
    FROM lads.mfanz_matl_vltn@ap0064p.world
   WHERE vltn_area IN ('AU10', 'AU11');


DROP PUBLIC SYNONYM MATL_VLTN_VW;

CREATE PUBLIC SYNONYM MATL_VLTN_VW FOR MANU.MATL_VLTN_VW;


GRANT SELECT ON MANU.MATL_VLTN_VW TO MANU_APP;

GRANT SELECT ON MANU.MATL_VLTN_VW TO MANU_MAINT;

GRANT SELECT ON MANU.MATL_VLTN_VW TO MANU_USER;


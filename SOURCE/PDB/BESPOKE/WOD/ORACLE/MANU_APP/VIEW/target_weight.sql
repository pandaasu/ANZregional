DROP VIEW MANU_APP.TARGET_WEIGHT;

/* Formatted on 2008/10/01 09:01 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.target_weight (plant,
                                                     matl_code,
                                                     target_weight
                                                    )
AS
  SELECT
   /*********************************************/
   /* This view presents targets weight for all mataerials that contain a NAKE
   /* identified by the BOM record
   /* created by Jeff Phillipson
   /* Date 19 Mar 2007
   /*********************************************/
         t01.plant, t01.matl_code, ROUND (qty / batch_qty, 3) target_weight
    FROM bom t01, matl t02, matl t03
   WHERE t01.sub_matl_code = t02.matl_code
     AND t01.matl_code = t03.matl_code
     AND t01.plant = t02.plant
     AND t02.plant_orntd_matl_type = 7                            -- nake = 7;



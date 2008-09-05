DROP VIEW MANU_APP.MATERAIL_MRP_VW;

/* Formatted on 2008/09/05 10:49 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.materail_mrp_vw (material,
                                                       plant,
                                                       mrp_cntrllr
                                                      )
AS
  SELECT "MATERIAL", "PLANT", "MRP_CNTRLLR"
    FROM material_mrp;


DROP PUBLIC SYNONYM MATERAIL_MRP_VW;

CREATE PUBLIC SYNONYM MATERAIL_MRP_VW FOR MANU_APP.MATERAIL_MRP_VW;


GRANT SELECT ON MANU_APP.MATERAIL_MRP_VW TO PUBLIC WITH GRANT OPTION;


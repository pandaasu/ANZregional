DROP VIEW MANU_APP.PARENT_CHILD_QTY;

/* Formatted on 2008/10/01 09:01 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.parent_child_qty (alt,
                                                        matl_code,
                                                        matl_type,
                                                        sub_matl_code,
                                                        sub_matl_type,
                                                        sub_matl_qty,
                                                        uom,
                                                        plant
                                                       )
AS
  SELECT   MAX (alt) alt, t01.matl_code, t03.matl_type, t01.sub_matl_code,
           t02.matl_type AS sub_matl_type,
           t01.qty / t01.batch_qty sub_matl_qty, t01.uom, t01.plant
      FROM bom t01, matl t02, matl t03
     WHERE t01.sub_matl_code = t02.matl_code
       AND t01.matl_code = t03.matl_code
       AND t01.plant = t03.plant
       AND t01.plant = t02.plant
       AND t01.eff_start_date <= TRUNC (SYSDATE)
       AND (t02.rtl_sales_unit = 'X' OR t02.mrchndsng_unit = 'X')
       AND t03.matl_type = 'FERT'
  GROUP BY t01.matl_code,
           t03.matl_type,
           t01.sub_matl_code,
           t02.matl_type,
           t01.qty,
           t01.batch_qty,
           t01.uom,
           t01.plant;


DROP PUBLIC SYNONYM PARENT_CHILD_QTY;

CREATE PUBLIC SYNONYM PARENT_CHILD_QTY FOR MANU_APP.PARENT_CHILD_QTY;


GRANT SELECT ON MANU_APP.PARENT_CHILD_QTY TO APPSUPPORT;

GRANT SELECT ON MANU_APP.PARENT_CHILD_QTY TO CITSRV1;


DROP VIEW MANU_APP.PROC_ORDER_BOM_VW;

/* Formatted on 2008/11/05 13:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.proc_order_bom_vw (lvl,
                                                         ID,
                                                         s,
                                                         material,
                                                         material_desc,
                                                         batch,
                                                         batch_uom,
                                                         sub_matl,
                                                         sub_matl_desc,
                                                         qty,
                                                         uom
                                                        )
AS
  SELECT   r.lvl, r.ID, r.s, r.material, m1.material_desc, r.batch,
           r.batch_uom, r.sub_matl, m.material_desc sub_matl_desc, r.qty,
           r.uom
      FROM material m,
           material m1,
           (SELECT     LPAD (' ', 2 * (LEVEL - 1)) || TO_CHAR (material) s,
                       material, TO_CHAR (batch_qty, '9999.999') batch,
                       batch_uom, sub_matl, TO_CHAR (qty, '9999.999') qty,
                       uom, ROWNUM ID, LEVEL lvl
                  FROM bom_vw
            START WITH material IN (SELECT LTRIM (material, '0')
                                      FROM cntl_rec
                                     WHERE proc_order LIKE '%1003766')
            CONNECT BY PRIOR sub_matl = material
                   AND alternate = get_alternate (material)
                   AND eff_start_date = get_alternate_date (material)) r
     WHERE m.material_code = r.sub_matl AND m1.material_code = r.material
  ORDER BY ID;



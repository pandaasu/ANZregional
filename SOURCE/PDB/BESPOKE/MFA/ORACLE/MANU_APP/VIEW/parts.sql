DROP VIEW MANU_APP.PARTS;

/* Formatted on 2008/09/05 10:50 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.parts (frmprod,
                                             frmprod_desc,
                                             ingred,
                                             prtdesc,
                                             seq
                                            )
AS
  SELECT   v.material AS frmprod, m.material_desc AS frmprod_desc,
           v.sub_matl AS ingred, UPPER (m1.material_desc) AS prtdesc,
              --this eliminates errors with matching case in cleaning schedule
                                                                     v.seq
      FROM bom_now_vw v, material m, material m1
     WHERE v.material =
              m.material_code
                             --Used by the cleaning model schedule spreadsheet
       AND v.sub_matl = m1.material_code
       AND m1.plant_orntd_matl_type IN
             ('4', '3')
                      -- lower mixes defined by Semi Finished goods type 3 & 4
       AND m.plant_orntd_matl_type IN ('7')   -- top level defined by NAKE = 7
  ORDER BY 1, seq;


DROP PUBLIC SYNONYM PARTS;

CREATE PUBLIC SYNONYM PARTS FOR MANU_APP.PARTS;


GRANT SELECT ON MANU_APP.PARTS TO MANU_USER;


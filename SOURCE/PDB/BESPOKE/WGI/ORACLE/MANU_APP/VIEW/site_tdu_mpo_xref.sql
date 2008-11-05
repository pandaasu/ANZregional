DROP VIEW MANU_APP.SITE_TDU_MPO_XREF;

/* Formatted on 2008/11/05 13:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.site_tdu_mpo_xref (matl_code,
                                                         matl_desc,
                                                         mpo,
                                                         mpo_desc,
                                                         qty
                                                        )
AS
  SELECT s.matl_code, m.material_desc matl_desc, s.sub_matl mpo,
         m1.material_desc mpo_desc, qty
    FROM site_mpo s, material m, material m1
   WHERE s.matl_code = m.material_code(+) AND s.sub_matl = m1.material_code(+);


DROP PUBLIC SYNONYM SITE_TDU_MPO_XREF;

CREATE PUBLIC SYNONYM SITE_TDU_MPO_XREF FOR MANU_APP.SITE_TDU_MPO_XREF;


GRANT SELECT ON MANU_APP.SITE_TDU_MPO_XREF TO PUBLIC WITH GRANT OPTION;


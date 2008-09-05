DROP VIEW MANU_APP.DMR_MATL_SUPPLIER;

/* Formatted on 2008/09/05 10:49 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.dmr_matl_supplier (vndr_num,
                                                         vndr_name,
                                                         purchng_org,
                                                         purchng_group,
                                                         matl_code,
                                                         matl_desc,
                                                         uom,
                                                         plant,
                                                         mrp_cntlr
                                                        )
AS
  SELECT DISTINCT vndr_code, vndr_name, prchsng_org, sales_org prchsng_group,
                  matl_code, ma.material_desc, s.uom base_uom, s.plant,
                  mrp_cntrllr
             FROM matl_vndr_xref s, material_mrp p, material_plan ma
            WHERE s.matl_code = p.material(+)
              AND ma.material_code(+) = s.matl_code
              AND LENGTH (vndr_code) > 7
  UNION ALL
  SELECT m.plant,
         DECODE (m.plant,
                 'AU10', 'Wyong Plant',
                 'AU11', 'Linfox Wyong',
                 'AU53', 'CocoSub',
                 'AU55', 'Fairhaven',
                 'AU56', 'Moraitis',
                 'AU13', 'Generic Returns - Carrier Depots',
                 'AU57', 'Packcentre',
                 m.plant
                ) vndr_name,
         '', '', material_code, material_desc, uom, m.plant, mrp_cntrllr
    FROM material_plan m, material_mrp p
   WHERE (tdu_code = 'X' OR sfp_code = 'X')
     AND m.material_code = p.material(+)
     AND m.plant NOT IN ('AU10')
--AND m.MATERIAL_CODE NOT IN ( SELECT matl_code FROM site_matl_supplier_xref);;;;;


DROP PUBLIC SYNONYM DMR_MATL_SUPPLIER;

CREATE PUBLIC SYNONYM DMR_MATL_SUPPLIER FOR MANU_APP.DMR_MATL_SUPPLIER;


GRANT SELECT ON MANU_APP.DMR_MATL_SUPPLIER TO DR_APP;

GRANT SELECT ON MANU_APP.DMR_MATL_SUPPLIER TO MANU_USER;


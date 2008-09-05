DROP VIEW MANU_APP.PLT_ITEM_REF_VW;

/* Formatted on 2008/09/05 10:49 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.plt_item_ref_vw (material_code,
                                                       material_desc,
                                                       material_type,
                                                       old_item_code,
                                                       uom,
                                                       gross_wght,
                                                       dclrd_wght,
                                                       dclrd_uom,
                                                       ean_code,
                                                       shelf_life,
                                                       eff_start_date,
                                                       units_per_case_date,
                                                       apn_code,
                                                       units_per_case,
                                                       inners_per_case_date,
                                                       inners_per_case,
                                                       pi_start_date,
                                                       pi_end_date,
                                                       pllt_gross_wght,
                                                       crtns_per_pllt,
                                                       crtns_per_layer,
                                                       uom_qty,
                                                       carton_label_format,
                                                       trade_partner_prod_code,
                                                       batch_mngmnt_rqrmnt_indctr,
                                                       store_locn
                                                      )
AS
  SELECT LTRIM (m.material_code, '0') material_code,
         m.material_desc material_desc, m.material_type,
         m.old_material_code old_item_code, m.uom, m.gross_wght, m.dclrd_wght,
         m.dclrd_uom, m.ean_code, m.shelf_life, m.eff_start_date,
         p.units_per_case_date, p.apn_code, p.units_per_case,
         p.inners_per_case_date, p.inners_per_case, p.pi_start_date,
         p.pi_end_date, p.pllt_gross_wght, p.crtns_per_pllt,
         p.crtns_per_layer, p.uom_qty, carton_label_format,
         '' trade_partner_prod_code, m.batch_mngmnt_rqrmnt_indctr,
         m.store_locn
    FROM material m, material_pllt p, site_matl_cluster_xref x
   WHERE m.material_code = p.matl_code(+) AND m.material_code = x.material_code(+);


DROP PUBLIC SYNONYM PLT_ITEM_REF_VW;

CREATE PUBLIC SYNONYM PLT_ITEM_REF_VW FOR MANU_APP.PLT_ITEM_REF_VW;


GRANT SELECT ON MANU_APP.PLT_ITEM_REF_VW TO MANU_USER;

GRANT SELECT ON MANU_APP.PLT_ITEM_REF_VW TO NEGUSIAN WITH GRANT OPTION;

GRANT SELECT ON MANU_APP.PLT_ITEM_REF_VW TO PT_APP WITH GRANT OPTION;


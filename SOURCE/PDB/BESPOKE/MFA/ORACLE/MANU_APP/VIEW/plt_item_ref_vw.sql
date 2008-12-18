create or replace view plt_item_ref_vw as 
  select ltrim(m.material_code,'0') as material_code, 
    m.material_desc as material_desc, 
    m.material_type, 
    m.old_material_code as old_item_code, 
    m.uom, 
    m.gross_wght, 
    m.dclrd_wght, 
    m.dclrd_uom, 
    m.ean_code, 
    m.shelf_life, 
    m.eff_start_date, 
    p.units_per_case_date, 
    p.apn_code, 
    p.units_per_case, 
    p.inners_per_case_date, 
    p.inners_per_case, 
    p.pi_start_date, 
    p.pi_end_date, 
    p.pllt_gross_wght, 
    p.crtns_per_pllt, 
    p.crtns_per_layer, 
    p.uom_qty, 
    x.carton_label_format, 
    '' as trade_partner_prod_code, 
    m.batch_mngmnt_rqrmnt_indctr, 
    m.store_locn,
    s.mcu_material_code,
    s.mcu_description,
    s.mcu_ean,
    s.mcu_gross_weight
  from material m, 
    material_pllt p, 
    site_matl_cluster_xref x, 
    (
      select b.material as material_code, 
        b.sub_matl as mcu_material_code, 
        m.bds_material_desc_en as mcu_description, 
        m.interntl_article_no as mcu_ean, 
        m.gross_weight as mcu_gross_weight 
      from bom b, 
        bds_material_plant_mfanz m 
      where b.sub_matl = ltrim(m.sap_material_code,'0') 
        and b.plant = m.plant_code 
        and m.mars_merchandising_unit_flag = 'X'
    ) s 
  where m.material_code = p.matl_code(+) 
    and m.material_code = x.material_code(+) 
    and m.material_code = s.material_code(+);
/

grant select on manu_app.plt_item_ref_vw to manu_user;
grant select on manu_app.plt_item_ref_vw to negusian with grant option;
grant select on manu_app.plt_item_ref_vw to pt_app with grant option;

create or replace public synonym plt_item_ref_vw for manu_app.plt_item_ref_vw;
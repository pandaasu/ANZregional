/******************************************************************************/
/*  NAME: BDS_MATERIAL_BOM_SYSDATE                                            */
/*                                                                            */
/*  REVISIONS:                                                                */
/*  Ver    Date        Author           Description                           */
/*  -----  ----------  ---------------  ------------------------------------  */
/*  1.0    03-01-2007  Steve Gregan     Created view                          */
/******************************************************************************/

create or replace force view bds.bds_material_bom_sysdate
   (sap_bom,
    bom_alternative,
    bom_plant,
    bom_usage,
    bom_status,
    bom_eff_date,
    parent_material_code,
    parent_base_qty,
    parent_base_uom,
    parent_material_type,
    parent_ian,
    parent_plan_flag,
    parent_intr_flag,
    parent_mcu_flag,
    parent_prom_flag,
    parent_rsu_flag,
    parent_ship_cont,
    parent_semi_finished,
    parent_tdu_flag,
    parent_rep_flag,
    child_material_code,
    child_base_qty,
    child_base_uom,
    child_per_parent,
    child_material_type,
    child_ian,
    child_plan_flag,
    child_intr_flag,
    child_mcu_flag,
    child_prom_flag,
    child_rsu_flag,
    child_ship_cont,
    child_semi_finished,
    child_tdu_flag,
    child_rep_flag) as
   select t02.*
     from (select t01.*
             from (select t01.sap_bom,
                          t01.sap_bom_alternative,
                          rank() over (partition by t01.parent_material_code,
                                                    t01.bom_plant,
                                                    t01.bom_usage,
                                                    t01.sap_bom_alternative
                                           order by t01.bom_eff_date desc) as rnkseq
                     from bds_material_bom_hdr t01
                    where t01.bds_lads_status = '1'
                      and trunc(t01.bom_eff_date) <= trunc(sysdate)) t01
            where rnkseq = 1) t01,
          (select t01.sap_bom,
                  t01.sap_bom_alternative,
                  t01.bom_plant,
                  t01.bom_usage,
                  t01.bom_status,
                  t01.bom_eff_date,
                  t01.parent_material_code,
                  t01.parent_base_qty,
                  t01.parent_base_uom,
                  t03.material_type,
                  t03.interntl_article_no,
                  t03.mars_plan_item_flag,
                  t03.mars_intrmdt_prdct_compnt_flag,
                  t03.mars_merchandising_unit_flag,
                  t03.mars_prmotional_material_flag,
                  t03.mars_retail_sales_unit_flag,
                  t03.mars_shpping_contnr_flag,
                  t03.mars_semi_finished_prdct_flag,
                  t03.mars_traded_unit_flag,
                  t03.mars_rprsnttv_item_flag,
                  t02.child_material_code,
                  t02.child_base_qty as child_base_qty,
                  t02.child_base_uom as child_base_uom,
                  decode(t01.parent_base_qty,0,0,((t02.child_base_qty/t01.parent_base_qty)*nvl(t05.bds_factor_to_base_uom,1))) as child_per_parent,
                  t04.material_type as child_type,
                  t04.interntl_article_no as child_ian,
                  t04.mars_plan_item_flag as child_plan_item_flag,
                  t04.mars_intrmdt_prdct_compnt_flag as child_intrmdt_prdct_flag,
                  t04.mars_merchandising_unit_flag as child_merchandising_flag,
                  t04.mars_prmotional_material_flag as child_prmotional_flag,
                  t04.mars_retail_sales_unit_flag as child_rsu_flag,
                  t04.mars_shpping_contnr_flag as child_shpping_contnr_flag,
                  t04.mars_semi_finished_prdct_flag as child_semi_finished_prdct_flag,
                  t04.mars_traded_unit_flag as child_tdu_flag,
                  t04.mars_rprsnttv_item_flag as child_rep_flag
             from bds_material_bom_hdr t01,
                  bds_material_bom_det t02,
                  bds_material_hdr t03,
                  bds_material_hdr t04,
                  bds_material_uom t05
            where t01.sap_bom = t02.sap_bom
              and t01.sap_bom_alternative = t02.sap_bom_alternative
              and t01.parent_material_code = t03.sap_material_code
              and t02.child_material_code = t04.sap_material_code
              and t02.child_material_code = t05.sap_material_code
              and t02.child_base_uom = t05.uom_code
              and t01.bds_lads_status = '1'
              and t03.bds_lads_status = '1'
              and t04.bds_lads_status = '1') t02
    where t01.sap_bom = t02.sap_bom
      and t01.sap_bom_alternative = t02.sap_bom_alternative
    union all
   select '*NONE' as sap_bom,
          '01' as sap_bom_alternative,
          '*NONE' as bom_plant,
          '5' as bom_usage,
          1 as bom_status,
          to_date('19000101','yyyymmdd') as bom_eff_date,
          t01.sap_material_code as parent_material_code,
          1 as parent_base_qty,
          'EA' as parent_base_uom,
          t01.material_type,
          t01.interntl_article_no,
          t01.mars_plan_item_flag,
          t01.mars_intrmdt_prdct_compnt_flag,
          t01.mars_merchandising_unit_flag,
          t01.mars_prmotional_material_flag,
          t01.mars_retail_sales_unit_flag,
          t01.mars_shpping_contnr_flag,
          t01.mars_semi_finished_prdct_flag,
          t01.mars_traded_unit_flag,
          t01.mars_rprsnttv_item_flag,
          t01.sap_material_code as child_material_code,
          1 as child_base_qty,
          'EA' as child_base_uom,
          1 as child_per_parent,
          t01.material_type as child_type,
          t01.interntl_article_no as child_ian,
          t01.mars_plan_item_flag as child_plan_item_flag,
          t01.mars_intrmdt_prdct_compnt_flag as child_intrmdt_prdct_flag,
          t01.mars_merchandising_unit_flag as child_merchandising_flag,
          t01.mars_prmotional_material_flag as child_prmotional_flag,
          t01.mars_retail_sales_unit_flag as child_rsu_flag,
          t01.mars_shpping_contnr_flag as child_shpping_contnr_flag,
          t01.mars_semi_finished_prdct_flag as child_semi_finished_prdct_flag,
          t01.mars_traded_unit_flag as child_tdu_flag,
          t01.mars_rprsnttv_item_flag as child_rep_flag
     from bds_material_hdr t01,
          (select parent_material_code
             from bds_material_bom_hdr
            where bds_lads_status = '1'
              and bom_plant = '*NONE'
              and bom_status in (1,7)
              and bom_usage = '5'
              and sap_bom_alternative = '01') t02
    where t01.bds_lads_status = '1'
      and t01.material_type = 'FERT'
      and (t01.mars_traded_unit_flag = 'X' or t01.mars_intrmdt_prdct_compnt_flag = 'X')
      and t01.mars_retail_sales_unit_flag = 'X'
      and t01.sap_material_code = t02.parent_material_code(+)
      and t02.parent_material_code(+) is null;

/*-*/
/* Authority
/*-*/

/*-*/
/* Synonym
/*-*/
create or replace public synonym bds_material_bom_sysdate for bds.bds_material_bom_sysdate;
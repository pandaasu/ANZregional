/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : drp_intransit_contnr_view
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - DRP Intransit Container View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dw_app.drp_intransit_contnr_view
   (sap_material_code,
    sap_bus_sgmnt_code,
    sap_plant_code,
    sap_storage_locn_code,
    shipd_qty, 
    sap_handling_unit_sts_code,
    whse_estd_arrival_date,
    purch_order_num,
    vessel_desc,
    contnr_num, 
    port_estd_arrival_date) as
   select t3.sap_material_code, 
          t3.sap_bus_sgmnt_code, 
          t4.sap_plant_code, 
          t5.sap_storage_locn_code, 
          round(sum(t2.shipd_qty / decode(t7.conv_factor,null,1,conv_factor)),0) as shipd_qty, 
          t6.sap_handling_unit_sts_code, 
          t1.whse_estd_arrival_date, 
          t1.purch_order_num, 
          t1.vessel_desc, 
          t1.contnr_num, 
          t1.port_estd_arrival_date 
     from intransit_contnr_hdr t1, 
          intransit_contnr_dtl t2, 
          material_dim t3, 
          plant t4, 
          storage_locn t5, 
          handling_unit_status t6, 
          (select a.material_code, b.numerator_y_conv / b.denominator_x_conv as conv_factor 
             from material_dim a, material_uom b 
            where a.sap_base_uom_code = 'KGM' and b.material_code = a.material_code and b.alt_uom_code = 37) t7 
    where t1.intransit_contnr_hdr_code = t2.intransit_contnr_hdr_code and 
          t2.material_code = t3.material_code and 
          t2.plant_code = t4.plant_code and 
          t2.storage_locn_code = t5.storage_locn_code and 
          t1.handling_unit_sts_code = t6.handling_unit_sts_code and 
          t6.handling_unit_sts_code in ('1','2','3') and 
          t3.sap_bus_sgmnt_code in ('01','02','05') and 
          (t3.material_type_flag_tdu = 'Y' or t3.material_type_flag_sfp = 'Y') and 
          to_char(t1.idoc_creatn_date,'yyyymmdd') = (select to_char(max(idoc_creatn_date),'yyyymmdd') from intransit_contnr_hdr) and 
          t7.material_code(+) = t2.material_code 
    group by t3.sap_material_code, 
             t3.sap_bus_sgmnt_code, 
             t4.sap_plant_code, 
             t5.sap_storage_locn_code, 
             t6.sap_handling_unit_sts_code, 
             t1.whse_estd_arrival_date, 
             t1.purch_order_num, 
             t1.vessel_desc, 
             t1.contnr_num, 
             t1.port_estd_arrival_date;

/*-*/
/* Authority
/*-*/
grant select on dw_app.drp_intransit_contnr_view to ml_app;
grant select on dw_app.drp_intransit_contnr_view to pb_app;
grant select on dw_app.drp_intransit_contnr_view to pp_app;
grant select on dw_app.drp_intransit_contnr_view to drp_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym drp_intransit_contnr_view for dw_app.drp_intransit_contnr_view;

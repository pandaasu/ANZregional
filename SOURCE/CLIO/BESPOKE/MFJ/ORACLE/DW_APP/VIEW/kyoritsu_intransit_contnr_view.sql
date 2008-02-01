/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : kyoritsu_intransit_contnr_view
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - Kyoritsu Intransit Container View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dw_app.kyoritsu_intransit_contnr_view
   (record_id,
    material_batch_desc,
    port_estd_arrival_date,
    whse_estd_arrival_date,
    sailing_desc, 
    vessel_desc,
    voyage_num,
    sap_vendor_code,
    vendor_name,
    contnr_num, 
    sap_material_code,
    material_desc_ja,
    shipd_qty,
    idoc_creatn_date,
    idoc_creatn_time) as
   select '003' as record_id, 
          t2.material_batch_desc, 
          t1.port_estd_arrival_date, 
          t1.whse_estd_arrival_date, 
          t1.voyage_num || ' ' || t1.vessel_desc as sailing_desc, 
          t1.vessel_desc, 
          t1.voyage_num, 
          t1.sap_vendor_code, 
          nvl(t3.vendor_name,'UNKNOWN'), 
          t1.contnr_num, 
          t4.sap_material_code, 
          t4.material_desc_ja, 
          sum(t2.shipd_qty) as shipd_qty, 
          t1.idoc_creatn_date, 
          t1.idoc_creatn_time 
     from intransit_contnr_hdr t1, 
          intransit_contnr_dtl t2, 
          vendor t3, 
          material_dim t4, 
          handling_unit_status t5, 
          plant t6, 
          storage_locn t7 
    where t1.handling_unit_id = t2.handling_unit_id and 
          t1.sap_vendor_code = t3.sap_vendor_code(+) and 
          t2.sap_material_code = t4.sap_material_code and 
          t1.sap_handling_unit_sts_code = t5.sap_handling_unit_sts_code and 
          t2.sap_plant_code = t6.sap_plant_code and 
          t2.sap_storage_locn_code = t7.sap_storage_locn_code and 
          t4.material_type_flag_tdu = 'Y' and 
          t5.sap_handling_unit_sts_code in ('1','2') and 
          t6.sap_plant_code = 'JP01' and 
          t7.sap_storage_locn_code in ('0015','0024','0037') 
    group by '003', 
             t2.material_batch_desc, 
             t1.port_estd_arrival_date, 
             t1.whse_estd_arrival_date, 
             t1.voyage_num || ' ' || t1.vessel_desc, 
             t1.vessel_desc, 
             t1.voyage_num, 
             t1.sap_vendor_code, 
             t3.vendor_name,
             t1.contnr_num, 
             t4.sap_material_code, 
             t4.material_desc_ja, 
             t1.idoc_creatn_date, 
             T1.idoc_creatn_time;

/*-*/
/* Authority
/*-*/
grant select on dw_app.kyoritsu_intransit_contnr_view to ml_app;
grant select on dw_app.kyoritsu_intransit_contnr_view to pb_app;
grant select on dw_app.kyoritsu_intransit_contnr_view to pp_app;

/*-*/
/* Synonym
/*-*/
create public synonym kyoritsu_intransit_contnr_view for dw_app.kyoritsu_intransit_contnr_view;


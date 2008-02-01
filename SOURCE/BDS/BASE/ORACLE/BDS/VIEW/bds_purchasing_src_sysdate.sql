 /******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_PURCHASING_SRC_SYSDATE
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Reference - Purchasing Source (Vendor/Material) by SYSDATE

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/

create or replace view bds_purchasing_src_sysdate as
   select  a.sap_material_code as sap_material_code, 
           a.plant_code as plant_code, 
           a.record_no as record_no, 
           a.creatn_date as creatn_date, 
           a.creatn_user as creatn_user, 
           a.vendor_code as vendor_code, 
           a.fixed_vendor_indctr as fixed_vendor_indctr, 
           a.agreement_no as agreement_no, 
           a.agreement_item as agreement_item, 
           a.fixed_purchase_agreement_item as fixed_purchase_agreement_item, 
           a.plant_procured_from as plant_procured_from, 
           a.sto_fixed_issuing_plant as sto_fixed_issuing_plant, 
           a.manufctr_part_refrnc_material as manufctr_part_refrnc_material, 
           a.blocked_supply_src_flag as blocked_supply_src_flag, 
           a.purchasing_organisation as purchasing_organisation, 
           a.purchasing_document_ctgry as purchasing_document_ctgry, 
           a.src_list_ctgry as src_list_ctgry, 
           a.src_list_planning_usage as src_list_planning_usage, 
           a.order_unit as order_unit, 
           a.logical_system as logical_system, 
           a.special_stock_indctr as special_stock_indctr
   from bds_refrnc_purchasing_src a
   where a.src_list_valid_from <= trunc(sysdate)
     and a.src_list_valid_to  >= trunc(sysdate);
/


/**/
/* Synonym
/**/
create or replace public synonym bds_purchasing_src_sysdate for bds.bds_purchasing_src_sysdate;


/**/
/* Authority
/**/
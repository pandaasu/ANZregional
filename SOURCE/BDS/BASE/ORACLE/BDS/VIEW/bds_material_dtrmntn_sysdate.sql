 /******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_DTRMNTN_SYSDATE
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Reference - Material Determination for SYSDATE

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/

create or replace view bds_material_dtrmntn_sysdate as  
   select a.refrnc_code,
          a.zrep_material_code as zrep_material_code,
          a.material_dtrmntn_type as material_dtrmntn_type,
          b.tdu_material_code as tdu_material_code,
          a.sales_organisation as sales_organisation,
          a.dstrbtn_channel as dstrbtn_channel,
          a.sold_to_code as sold_to_code,
          b.substitution_reason as substitution_reason,
          b.mrp_indctr as mrp_indctr,
          b.cross_sell_dlvry_cntrl as cross_sell_dlvry_cntrl
   from bds_refrnc_material_zrep a,
        bds_refrnc_material_tdu b
   where a.client_id = b.client_id
     and a.condition_record_no = b.condition_record_no
     and a.client_id = '002'
     and a.application_id = 'V'
     and trunc(a.start_date) <= trunc(sysdate)
     and trunc(a.end_date) >= trunc(sysdate);
/


/**/
/* Synonym
/**/
create or replace public synonym bds_material_dtrmntn_sysdate for bds.bds_material_dtrmntn_sysdate;


/**/
/* Authority
/**/
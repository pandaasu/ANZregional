 /******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_PKG_INSTR_ALL
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Packaging Instruction View for ALL dates

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/

create or replace view bds_material_pkg_instr_all as  
   select t01.sap_material_code as sap_material_code, 
          t01.sales_organisation, 
          t01.component as component, 
          t01.pkg_instr_start_date as pkg_instr_start_date,
          t01.pkg_instr_end_date as pkg_instr_end_date,
          t01.variable_key as variable_key, 
          t01.height as height, 
          t01.width as width, 
          t01.length as length, 
          t01.hu_total_weight as hu_total_weight, 
          t01.hu_total_volume as hu_total_volume, 
          t01.dimension_uom as dimension_uom, 
          t01.weight_unit as weight_unit, 
          t01.volume_unit as volume_unit, 
          t01.target_qty as target_qty, 
          t01.rounding_qty as rounding_qty, 
          t01.uom as uom
   from bds_material_pkg_instr_det t01 
   where t01.pkg_instr_table_usage = 'P' 
     and t01.pkg_instr_application = 'PO' 
     and t01.pkg_instr_type = 'Z001' 
     and t01.pkg_instr_table = '505'
     and t01.sales_organisation in ('147','149') 
     and t01.item_ctgry in ('I');
/

/**/
/* Synonym
/**/
create or replace public synonym bds_material_pkg_instr_all for bds.bds_material_pkg_instr_all;


/**/
/* Authority
/**/
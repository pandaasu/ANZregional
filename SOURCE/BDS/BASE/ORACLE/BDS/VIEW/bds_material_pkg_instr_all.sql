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
   SELECT sap_material_code, pkg_instr_table_usage, pkg_instr_table,
          pkg_instr_type, pkg_instr_application, item_ctgry,
          sales_organisation, component, pkg_instr_start_date,
          pkg_instr_end_date, variable_key, height, width, LENGTH,
          hu_total_weight, hu_total_volume, dimension_uom, weight_unit,
          volume_unit, target_qty, rounding_qty, uom
     FROM bds_material_pkg_instr_det;
/

/**/
/* Synonym
/**/
create or replace public synonym bds_material_pkg_instr_all for bds.bds_material_pkg_instr_all;


/**/
/* Authority
/**/
GRANT SELECT ON BDS.BDS_MATERIAL_PKG_INSTR_ALL TO BDS_APP WITH GRANT OPTION;
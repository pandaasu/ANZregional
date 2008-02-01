/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_PKG_INSTR_REG
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Packing Instruction Regional Code Conversion (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_pkg_instr_reg
   (sap_material_code             varchar2(18 char)      not null, 
    pkg_instr_table_usage         varchar2(1 char)       not null, 
    pkg_instr_table               varchar2(64 char)      not null, 
    pkg_instr_type                varchar2(4 char)       not null, 
    pkg_instr_application         varchar2(2 char)       not null, 
    pkg_instr_start_date          date                   not null, 
    pkg_instr_end_date            date                   not null,
    sales_organisation            varchar2(4 char)       not null, 
    regional_code_id              varchar2(5 char)       not null, 
    regional_code                 varchar2(18 char)      not null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_pkg_instr_reg
   add constraint bds_material_pkg_instr_reg_pk primary key (sap_material_code, 
                                                             pkg_instr_table_usage, 
                                                             pkg_instr_table, 
                                                             pkg_instr_type, 
                                                             pkg_instr_application, 
                                                             pkg_instr_start_date, 
                                                             pkg_instr_end_date,
                                                             sales_organisation,
                                                             regional_code_id,
                                                             regional_code);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_pkg_instr_reg is 'Business Data Store - Material Packing Instruction Regional Code Conversion  (MATMAS)';
comment on column bds_material_pkg_instr_reg.sap_material_code is 'Material Number - lads_mat_pch.matnr';
comment on column bds_material_pkg_instr_reg.pkg_instr_table_usage is 'Usage of the condition table - lads_mat_pch.kvewe';
comment on column bds_material_pkg_instr_reg.pkg_instr_table is 'Condition table - lads_mat_pch.kotabnr';
comment on column bds_material_pkg_instr_reg.pkg_instr_type is 'Condition type for packing object regermination - lads_mat_pch.kschl';
comment on column bds_material_pkg_instr_reg.pkg_instr_application is 'Application - lads_mat_pch.kappl';
comment on column bds_material_pkg_instr_reg.pkg_instr_start_date is 'Validity start date of the condition record - lads_mat_pch.vkorg';
comment on column bds_material_pkg_instr_reg.pkg_instr_end_date is 'Validity end date of the condition record - lads_mat_pcr.datab';
comment on column bds_material_pkg_instr_reg.sales_organisation is 'Sales Organization - lads_mat_pcr.datbi';
comment on column bds_material_pkg_instr_reg.regional_code_id is 'Regional code Id - lads_mat_pir.z_lcdid';
comment on column bds_material_pkg_instr_reg.regional_code is 'Regional code number - lads_mat_pir.z_lcdnr';



/**/
/* Synonym
/**/
create or replace public synonym bds_material_pkg_instr_reg for bds.bds_material_pkg_instr_reg;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_pkg_instr_reg to lics_app;
grant select,update,delete,insert on bds_material_pkg_instr_reg to bds_app;
grant select,update,delete,insert on bds_material_pkg_instr_reg to lads_app;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_PKG_INSTR_MOE
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Packing Instruction MOE (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_pkg_instr_moe
   (sap_material_code             varchar2(18 char)      not null, 
    pkg_instr_table_usage         varchar2(1 char)       not null, 
    pkg_instr_table               varchar2(64 char)      not null, 
    pkg_instr_type                varchar2(4 char)       not null, 
    pkg_instr_application         varchar2(2 char)       not null, 
    pkg_instr_start_date          date                   not null, 
    pkg_instr_end_date            date                   not null,
    sales_organisation            varchar2(4 char)       not null, 
    moe_code                      varchar2(4 char)       not null, 
    usage_code                    varchar2(3 char)       not null, 
    start_date                    date                   not null, 
    end_date                      date                   not null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_pkg_instr_moe
   add constraint bds_material_pkg_instr_moe_pk primary key (sap_material_code, 
                                                             pkg_instr_table_usage, 
                                                             pkg_instr_table, 
                                                             pkg_instr_type, 
                                                             pkg_instr_application, 
                                                             pkg_instr_start_date, 
                                                             pkg_instr_end_date,
                                                             sales_organisation,
                                                             moe_code,
                                                             usage_code,
                                                             start_date,
                                                             end_date);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_pkg_instr_moe is 'Business Data Store - Material Packing Instruction MOE  (MATMAS)';
comment on column bds_material_pkg_instr_moe.sap_material_code is 'Material Number - lads_mat_pch.matnr';
comment on column bds_material_pkg_instr_moe.pkg_instr_table_usage is 'Usage of the condition table - lads_mat_pch.kvewe';
comment on column bds_material_pkg_instr_moe.pkg_instr_table is 'Condition table - lads_mat_pch.kotabnr';
comment on column bds_material_pkg_instr_moe.pkg_instr_type is 'Condition type for packing object moeermination - lads_mat_pch.kschl';
comment on column bds_material_pkg_instr_moe.pkg_instr_application is 'Application - lads_mat_pch.kappl';
comment on column bds_material_pkg_instr_moe.pkg_instr_start_date is 'Validity start date of the condition record - lads_mat_pch.vkorg';
comment on column bds_material_pkg_instr_moe.pkg_instr_end_date is 'Validity end date of the condition record - lads_mat_pcr.datab';
comment on column bds_material_pkg_instr_moe.sales_organisation is 'Sales Organization - lads_mat_pcr.datbi';
comment on column bds_material_pkg_instr_moe.moe_code is 'MOE code - lads_mat_pim.moe';
comment on column bds_material_pkg_instr_moe.usage_code is 'Item Usage Code - lads_mat_pim.usagecode';
comment on column bds_material_pkg_instr_moe.start_date is 'MOE  Start date - lads_mat_pim.datab';
comment on column bds_material_pkg_instr_moe.end_date is 'MOE End Date - lads_mat_pim.dated';



/**/
/* Synonym
/**/
create or replace public synonym bds_material_pkg_instr_moe for bds.bds_material_pkg_instr_moe;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_pkg_instr_moe to lics_app;
grant select,update,delete,insert on bds_material_pkg_instr_moe to bds_app;
grant select,update,delete,insert on bds_material_pkg_instr_moe to lads_app;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_PKG_INSTR_TEXT
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Packing Instruction Text (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_pkg_instr_text
   (sap_material_code             varchar2(18 char)      not null, 
    pkg_instr_table_usage         varchar2(1 char)       not null, 
    pkg_instr_table               varchar2(64 char)      not null, 
    pkg_instr_type                varchar2(4 char)       not null, 
    pkg_instr_application         varchar2(2 char)       not null, 
    pkg_instr_start_date          date                   not null, 
    pkg_instr_end_date            date                   not null,
    sales_organisation            varchar2(4 char)       not null, 
    text_language                 varchar2(1 char)       not null, 
    short_text                    varchar2(40 char)      null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_pkg_instr_text
   add constraint bds_material_pkg_instr_text_pk primary key (sap_material_code, 
                                                             pkg_instr_table_usage, 
                                                             pkg_instr_table, 
                                                             pkg_instr_type, 
                                                             pkg_instr_application, 
                                                             pkg_instr_start_date, 
                                                             pkg_instr_end_date,
                                                             sales_organisation,
                                                             text_language);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_pkg_instr_text is 'Business Data Store - Material Packing Instruction Text  (MATMAS)';
comment on column bds_material_pkg_instr_text.sap_material_code is 'Material Number - lads_mat_pch.matnr';
comment on column bds_material_pkg_instr_text.pkg_instr_table_usage is 'Usage of the condition table - lads_mat_pch.kvewe';
comment on column bds_material_pkg_instr_text.pkg_instr_table is 'Condition table - lads_mat_pch.kotabnr';
comment on column bds_material_pkg_instr_text.pkg_instr_type is 'Condition type for packing object textermination - lads_mat_pch.kschl';
comment on column bds_material_pkg_instr_text.pkg_instr_application is 'Application - lads_mat_pch.kappl';
comment on column bds_material_pkg_instr_text.pkg_instr_start_date is 'Validity start date of the condition record - lads_mat_pch.vkorg';
comment on column bds_material_pkg_instr_text.pkg_instr_end_date is 'Validity end date of the condition record - lads_mat_pcr.datab';
comment on column bds_material_pkg_instr_text.sales_organisation is 'Sales Organization - lads_mat_pcr.datbi';
comment on column bds_material_pkg_instr_text.text_language is 'Language Key - lads_mat_pit.spras';
comment on column bds_material_pkg_instr_text.short_text is 'Short text of packing object - lads_mat_pit.content';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_pkg_instr_text for bds.bds_material_pkg_instr_text;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_pkg_instr_text to lics_app;
grant select,update,delete,insert on bds_material_pkg_instr_text to bds_app;
grant select,update,delete,insert on bds_material_pkg_instr_text to lads_app;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_PKG_INSTR_EAN
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Packing Instruction EAN (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_pkg_instr_ean
   (sap_material_code             varchar2(18 char)      not null, 
    pkg_instr_table_usage         varchar2(1 char)       not null, 
    pkg_instr_table               varchar2(64 char)      not null, 
    pkg_instr_type                varchar2(4 char)       not null, 
    pkg_instr_application         varchar2(2 char)       not null, 
    pkg_instr_start_date          date                   not null, 
    pkg_instr_end_date            date                   not null,
    sales_organisation            varchar2(4 char)       not null, 
    interntl_article_no           varchar2(18 char)      not null, 
    interntl_article_no_ctgry     varchar2(2 char)       null, 
    main_ean_indctr               varchar2(1 char)       null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_pkg_instr_ean
   add constraint bds_material_pkg_instr_ean_pk primary key (sap_material_code, 
                                                             pkg_instr_table_usage, 
                                                             pkg_instr_table, 
                                                             pkg_instr_type, 
                                                             pkg_instr_application, 
                                                             pkg_instr_start_date, 
                                                             pkg_instr_end_date,
                                                             sales_organisation,
                                                             interntl_article_no);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_pkg_instr_ean is 'Business Data Store - Material Packing Instruction EAN  (MATMAS)';
comment on column bds_material_pkg_instr_ean.sap_material_code is 'Material Number - lads_mat_pch.matnr';
comment on column bds_material_pkg_instr_ean.pkg_instr_table_usage is 'Usage of the condition table - lads_mat_pch.kvewe';
comment on column bds_material_pkg_instr_ean.pkg_instr_table is 'Condition table - lads_mat_pch.kotabnr';
comment on column bds_material_pkg_instr_ean.pkg_instr_type is 'Condition type for packing object eanermination - lads_mat_pch.kschl';
comment on column bds_material_pkg_instr_ean.pkg_instr_application is 'Application - lads_mat_pch.kappl';
comment on column bds_material_pkg_instr_ean.pkg_instr_start_date is 'Validity start date of the condition record - lads_mat_pch.vkorg';
comment on column bds_material_pkg_instr_ean.pkg_instr_end_date is 'Validity end date of the condition record - lads_mat_pcr.datab';
comment on column bds_material_pkg_instr_ean.sales_organisation is 'Sales Organization - lads_mat_pcr.datbi';
comment on column bds_material_pkg_instr_ean.interntl_article_no is 'International Article Number (EAN/UPC) - lads_mat_pie.ean11';
comment on column bds_material_pkg_instr_ean.interntl_article_no_ctgry is 'Category of International Article Number (EAN) - lads_mat_pie.eantp';
comment on column bds_material_pkg_instr_ean.main_ean_indctr is 'Indicator: Main EAN - lads_mat_pie.hpean';




/**/
/* Synonym
/**/
create or replace public synonym bds_material_pkg_instr_ean for bds.bds_material_pkg_instr_ean;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_pkg_instr_ean to lics_app;
grant select,update,delete,insert on bds_material_pkg_instr_ean to bds_app;
grant select,update,delete,insert on bds_material_pkg_instr_ean to lads_app;

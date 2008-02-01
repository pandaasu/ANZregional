/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_PKG_INSTR_HDR
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Packing Instruction Header (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_pkg_instr_hdr
   (sap_material_code             varchar2(18 char)      not null, 
    pkg_instr_table_usage         varchar2(1 char)       not null, 
    pkg_instr_table               varchar2(64 char)      not null, 
    pkg_instr_type                varchar2(4 char)       not null, 
    pkg_instr_application         varchar2(2 char)       not null, 
    pkg_instr_start_date          date                   not null, 
    pkg_instr_end_date            date                   not null,
    sales_organisation            varchar2(4 char)       not null, 
    pkg_instr_no                  varchar2(22 char)      null, 
    variable_key                  varchar2(100 char)     null,
    alternative_pkg_instr_1       varchar2(22 char)      null, 
    alternative_pkg_instr_2       varchar2(22 char)      null, 
    alternative_pkg_instr_3       varchar2(22 char)      null, 
    alternative_pkg_instr_4       varchar2(22 char)      null, 
    height                        number                 null, 
    width                         number                 null, 
    length                        number                 null, 
    pkg_material_tare_weight      number                 null, 
    goods_load_weight             number                 null, 
    hu_total_weight               number                 null, 
    pkg_material_tare_volume      number                 null, 
    goods_load_volume             number                 null, 
    hu_total_volume               number                 null, 
    pkg_instr_id_no               varchar2(20 char)      null, 
    stack_factor                  number                 null, 
    change_date                   date                   null, 
    dimension_uom                 varchar2(3 char)       null, 
    weight_unit                   varchar2(3 char)       null, 
    max_weight_unit               varchar2(3 char)       null, 
    volume_unit                   varchar2(3 char)       null, 
    max_volume_unit               varchar2(3 char)       null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_pkg_instr_hdr
   add constraint bds_material_pkg_instr_hdr_pk primary key (sap_material_code, 
                                                             pkg_instr_table_usage, 
                                                             pkg_instr_table, 
                                                             pkg_instr_type, 
                                                             pkg_instr_application, 
                                                             pkg_instr_start_date, 
                                                             pkg_instr_end_date,
                                                             sales_organisation);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_pkg_instr_hdr is 'Business Data Store - Material Packing Instruction Header  (MATMAS)';
comment on column bds_material_pkg_instr_hdr.sap_material_code is 'Material Number - lads_mat_pch.matnr';
comment on column bds_material_pkg_instr_hdr.pkg_instr_table_usage is 'Usage of the condition table - lads_mat_pch.kvewe';
comment on column bds_material_pkg_instr_hdr.pkg_instr_table is 'Condition table - lads_mat_pch.kotabnr';
comment on column bds_material_pkg_instr_hdr.pkg_instr_type is 'Condition type for packing object determination - lads_mat_pch.kschl';
comment on column bds_material_pkg_instr_hdr.pkg_instr_application is 'Application - lads_mat_pch.kappl';
comment on column bds_material_pkg_instr_hdr.pkg_instr_start_date is 'Validity start date of the condition record - lads_mat_pch.vkorg';
comment on column bds_material_pkg_instr_hdr.pkg_instr_end_date is 'Validity end date of the condition record - lads_mat_pcr.datab';
comment on column bds_material_pkg_instr_hdr.sales_organisation is 'Sales Organization - lads_mat_pcr.datbi';
comment on column bds_material_pkg_instr_hdr.pkg_instr_no is 'Packing instruction - lads_mat_pcr.packnr';
comment on column bds_material_pkg_instr_hdr.variable_key is 'Variable key 100 bytes - lads_mat_pch.vakey';
comment on column bds_material_pkg_instr_hdr.alternative_pkg_instr_1 is 'Alternative packing instruction - lads_mat_pcr.packnr1';
comment on column bds_material_pkg_instr_hdr.alternative_pkg_instr_2 is 'Alternative packing instruction - lads_mat_pcr.packnr2';
comment on column bds_material_pkg_instr_hdr.alternative_pkg_instr_3 is 'Alternative packing instruction - lads_mat_pcr.packnr3';
comment on column bds_material_pkg_instr_hdr.alternative_pkg_instr_4 is 'Alternative packing instruction - lads_mat_pcr.packnr4';
comment on column bds_material_pkg_instr_hdr.height is 'Height - lads_mat_pih.height';
comment on column bds_material_pkg_instr_hdr.width is 'Width - lads_mat_pih.width';
comment on column bds_material_pkg_instr_hdr.length is 'Length - lads_mat_pih.length';
comment on column bds_material_pkg_instr_hdr.pkg_material_tare_weight is 'Tare weight of packaging materials - lads_mat_pih.tarewei';
comment on column bds_material_pkg_instr_hdr.goods_load_weight is 'Loading weight of goods to be packed - lads_mat_pih.loadwei';
comment on column bds_material_pkg_instr_hdr.hu_total_weight is 'Total weight of handling unit - lads_mat_pih.totlwei';
comment on column bds_material_pkg_instr_hdr.pkg_material_tare_volume is 'Tare volume of packaging materials - lads_mat_pih.tarevol';
comment on column bds_material_pkg_instr_hdr.goods_load_volume is 'Loading volume of goods to be packed - lads_mat_pih.loadvol';
comment on column bds_material_pkg_instr_hdr.hu_total_volume is 'Total volume of handling unit - lads_mat_pih.totlvol';
comment on column bds_material_pkg_instr_hdr.pkg_instr_id_no is 'Identification number of packing instruction - lads_mat_pih.pobjid';
comment on column bds_material_pkg_instr_hdr.stack_factor is 'Stacking factor - lads_mat_pih.stfac';
comment on column bds_material_pkg_instr_hdr.change_date is 'Date of last change - lads_mat_pih.chdat';
comment on column bds_material_pkg_instr_hdr.dimension_uom is 'Unit of dimension for length/width/height - lads_mat_pih.unitdim';
comment on column bds_material_pkg_instr_hdr.weight_unit is 'Unit of weight - lads_mat_pih.unitwei';
comment on column bds_material_pkg_instr_hdr.max_weight_unit is 'Unit of weight - lads_mat_pih.unitwei_max';
comment on column bds_material_pkg_instr_hdr.volume_unit is 'Volume unit - lads_mat_pih.unitvol';
comment on column bds_material_pkg_instr_hdr.max_volume_unit is 'Volume unit - lads_mat_pih.unitvol_max';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_pkg_instr_hdr for bds.bds_material_pkg_instr_hdr;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_pkg_instr_hdr to lics_app;
grant select,update,delete,insert on bds_material_pkg_instr_hdr to bds_app;
grant select,update,delete,insert on bds_material_pkg_instr_hdr to lads_app;

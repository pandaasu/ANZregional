/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_PKG_INSTR_DET
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Packing Instruction Detail (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created
 2007/04   Steve Gregan   Added redundant header fields

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_pkg_instr_det
   (sap_material_code             varchar2(18 char)      not null, 
    pkg_instr_table_usage         varchar2(1 char)       not null, 
    pkg_instr_table               varchar2(64 char)      not null, 
    pkg_instr_type                varchar2(4 char)       not null, 
    pkg_instr_application         varchar2(2 char)       not null, 
    pkg_instr_start_date          date                   not null, 
    pkg_instr_end_date            date                   not null,
    sales_organisation            varchar2(4 char)       not null, 
    item_ctgry                    varchar2(2 char)       not null, 
    component                     varchar2(20 char)      not null, 
    target_qty                    number                 null, 
    min_qty                       number                 null, 
    rounding_qty                  number                 null, 
    uom                           varchar2(3 char)       null, 
    load_carrier_indctr           varchar2(1 char)       null,
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
alter table bds_material_pkg_instr_det
   add constraint bds_material_pkg_instr_det_pk primary key (sap_material_code, 
                                                             pkg_instr_table_usage, 
                                                             pkg_instr_table, 
                                                             pkg_instr_type, 
                                                             pkg_instr_application, 
                                                             pkg_instr_start_date, 
                                                             pkg_instr_end_date,
                                                             sales_organisation,
                                                             item_ctgry, 
                                                             component);

/**/
/* Comments
/**/
comment on table bds_material_pkg_instr_det is 'Business Data Store - Material Packing Instruction Detail  (MATMAS)';
comment on column bds_material_pkg_instr_det.sap_material_code is 'Material Number - lads_mat_pch.matnr';
comment on column bds_material_pkg_instr_det.pkg_instr_table_usage is 'Usage of the condition table - lads_mat_pch.kvewe';
comment on column bds_material_pkg_instr_det.pkg_instr_table is 'Condition table - lads_mat_pch.kotabnr';
comment on column bds_material_pkg_instr_det.pkg_instr_type is 'Condition type for packing object determination - lads_mat_pch.kschl';
comment on column bds_material_pkg_instr_det.pkg_instr_application is 'Application - lads_mat_pch.kappl';
comment on column bds_material_pkg_instr_det.pkg_instr_start_date is 'Validity start date of the condition record - lads_mat_pch.vkorg';
comment on column bds_material_pkg_instr_det.pkg_instr_end_date is 'Validity end date of the condition record - lads_mat_pcr.datab';
comment on column bds_material_pkg_instr_det.sales_organisation is 'Sales Organization - lads_mat_pcr.datbi';
comment on column bds_material_pkg_instr_det.item_ctgry is 'Detailed item category - lads_mat_pid.detail_itemtype';
comment on column bds_material_pkg_instr_det.component is 'Component (gen.field for matl, packaging matl or pkg instr.) - lads_mat_pid.component';
comment on column bds_material_pkg_instr_det.target_qty is 'Target quantity - lads_mat_pid.trgqty';
comment on column bds_material_pkg_instr_det.min_qty is 'Minimum quantity - lads_mat_pid.minqty';
comment on column bds_material_pkg_instr_det.rounding_qty is 'Rounding qty - lads_mat_pid.rndqty';
comment on column bds_material_pkg_instr_det.uom is 'Unit of measure - lads_mat_pid.unitqty';
comment on column bds_material_pkg_instr_det.load_carrier_indctr is 'Load carrier indicator - lads_mat_pid.indmapaco';
comment on column bds_material_pkg_instr_det.pkg_instr_no is 'Packing instruction - lads_mat_pcr.packnr';
comment on column bds_material_pkg_instr_det.variable_key is 'Variable key 100 bytes - lads_mat_pch.vakey';
comment on column bds_material_pkg_instr_det.alternative_pkg_instr_1 is 'Alternative packing instruction - lads_mat_pcr.packnr1';
comment on column bds_material_pkg_instr_det.alternative_pkg_instr_2 is 'Alternative packing instruction - lads_mat_pcr.packnr2';
comment on column bds_material_pkg_instr_det.alternative_pkg_instr_3 is 'Alternative packing instruction - lads_mat_pcr.packnr3';
comment on column bds_material_pkg_instr_det.alternative_pkg_instr_4 is 'Alternative packing instruction - lads_mat_pcr.packnr4';
comment on column bds_material_pkg_instr_det.height is 'Height - lads_mat_pih.height';
comment on column bds_material_pkg_instr_det.width is 'Width - lads_mat_pih.width';
comment on column bds_material_pkg_instr_det.length is 'Length - lads_mat_pih.length';
comment on column bds_material_pkg_instr_det.pkg_material_tare_weight is 'Tare weight of packaging materials - lads_mat_pih.tarewei';
comment on column bds_material_pkg_instr_det.goods_load_weight is 'Loading weight of goods to be packed - lads_mat_pih.loadwei';
comment on column bds_material_pkg_instr_det.hu_total_weight is 'Total weight of handling unit - lads_mat_pih.totlwei';
comment on column bds_material_pkg_instr_det.pkg_material_tare_volume is 'Tare volume of packaging materials - lads_mat_pih.tarevol';
comment on column bds_material_pkg_instr_det.goods_load_volume is 'Loading volume of goods to be packed - lads_mat_pih.loadvol';
comment on column bds_material_pkg_instr_det.hu_total_volume is 'Total volume of handling unit - lads_mat_pih.totlvol';
comment on column bds_material_pkg_instr_det.pkg_instr_id_no is 'Identification number of packing instruction - lads_mat_pih.pobjid';
comment on column bds_material_pkg_instr_det.stack_factor is 'Stacking factor - lads_mat_pih.stfac';
comment on column bds_material_pkg_instr_det.change_date is 'Date of last change - lads_mat_pih.chdat';
comment on column bds_material_pkg_instr_det.dimension_uom is 'Unit of dimension for length/width/height - lads_mat_pih.unitdim';
comment on column bds_material_pkg_instr_det.weight_unit is 'Unit of weight - lads_mat_pih.unitwei';
comment on column bds_material_pkg_instr_det.max_weight_unit is 'Unit of weight - lads_mat_pih.unitwei_max';
comment on column bds_material_pkg_instr_det.volume_unit is 'Volume unit - lads_mat_pih.unitvol';
comment on column bds_material_pkg_instr_det.max_volume_unit is 'Volume unit - lads_mat_pih.unitvol_max';

/**/
/* Synonym
/**/
create or replace public synonym bds_material_pkg_instr_det for bds.bds_material_pkg_instr_det;

/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_pkg_instr_det to lics_app;
grant select,update,delete,insert on bds_material_pkg_instr_det to bds_app;
grant select,update,delete,insert on bds_material_pkg_instr_det to lads_app;

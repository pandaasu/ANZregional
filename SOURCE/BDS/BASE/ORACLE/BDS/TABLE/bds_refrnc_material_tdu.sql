/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_REFRNC_MATERIAL_TDU
 Owner   : BDS
 Author  : Linden Glen

 taxription
 -----------
 Business Data Store - Reference Data - Material TDU (ZDISTR)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_refrnc_material_tdu
   (client_id                        varchar2(3 char)        not null,
    condition_record_no              varchar2(10 char)       not null,
    tdu_material_code                varchar2(18 char)       null,
    tdu_uom                          varchar2(13 char)       null,
    substitution_reason              varchar2(4 char)        null,
    mrp_indctr                       varchar2(1 char)        null,
    cross_sell_dlvry_cntrl           varchar2(1 char)        null,
    change_flag                      varchar2(1 char)        null,    
    sap_idoc_number                  number                  null, 
    sap_idoc_timestamp               varchar2(14 char)       null);

    
/**/
/* Primary Key Constraint
/**/
alter table bds_refrnc_material_tdu
   add constraint bds_refrnc_material_tdu_pk primary key (client_id, condition_record_no);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_refrnc_material_tdu is 'Business Data Store - Reference Data - Material TDU (ZDISTR - KONDD)';
comment on column bds_refrnc_material_tdu.client_id is 'Client ID - LADS_REF_DAT - KONDD';
comment on column bds_refrnc_material_tdu.condition_record_no is 'Condition record number - LADS_REF_DAT - KONDD';
comment on column bds_refrnc_material_tdu.tdu_material_code is 'Substitute material - LADS_REF_DAT - KONDD';
comment on column bds_refrnc_material_tdu.tdu_uom is 'Substitute unit of measure - LADS_REF_DAT - KONDD';
comment on column bds_refrnc_material_tdu.substitution_reason is 'Reason for material substitution - LADS_REF_DAT - KONDD';
comment on column bds_refrnc_material_tdu.mrp_indctr is 'MRP indicator for alternative material in product selection - LADS_REF_DAT - KONDD';
comment on column bds_refrnc_material_tdu.cross_sell_dlvry_cntrl is 'Cross-selling delivery control - LADS_REF_DAT - KONDD';
comment on column bds_refrnc_material_tdu.sap_idoc_number is 'SAP IDOC Number - LADS_REF_DAT';
comment on column bds_refrnc_material_tdu.sap_idoc_timestamp is 'SAP IDOC Timestamp - LADS_REF_DAT';
comment on column bds_refrnc_material_tdu.change_flag is 'Record based on change IDOC from SAP - LADS_REF_DAT';


/**/
/* Synonym
/**/
create or replace public synonym bds_refrnc_material_tdu for bds.bds_refrnc_material_tdu;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_refrnc_material_tdu to lics_app;
grant select,update,delete,insert on bds_refrnc_material_tdu to bds_app;
grant select,update,delete,insert on bds_refrnc_material_tdu to lads_app;

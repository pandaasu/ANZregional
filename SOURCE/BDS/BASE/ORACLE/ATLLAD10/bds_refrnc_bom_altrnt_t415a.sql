/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_REFRNC_BOM_ALTRNT_T415A
 Owner   : BDS
 Author  : Linden Glen

 taxription
 -----------
 Business Data Store - Reference Data - bom_altrnt_t415a (ZDISTR)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_refrnc_bom_altrnt_t415a
   (sap_material_code                 varchar2(18 char)       not null,
    plant_code                        varchar2(4 char)        not null,
    bom_usage                         varchar2(1 char)        not null,
    valid_from_date                   date                    not null,
    technical_status_from_date        date                    null,
    altrntv_bom                       varchar2(2 char)        null,
    change_flag                       varchar2(1 char)        null,
    sap_idoc_number                   number                  null, 
    sap_idoc_timestamp                varchar2(14 char)       null);

    
/**/
/* Primary Key Constraint
/**/
alter table bds_refrnc_bom_altrnt_t415a
   add constraint bds_refrnc_bom_altrnt_t415a_pk primary key (sap_material_code, plant_code, bom_usage, valid_from_date);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_refrnc_bom_altrnt_t415a is 'Business Data Store - Reference Data - BOM Alternative (ZDISTR - T415A)';
comment on column bds_refrnc_bom_altrnt_t415a.sap_material_code is 'SAP Material Code - LADS_REF_DAT - T415A';
comment on column bds_refrnc_bom_altrnt_t415a.plant_code is 'Plant - LADS_REF_DAT - T415A';
comment on column bds_refrnc_bom_altrnt_t415a.bom_usage is 'BOM Usage - LADS_REF_DAT - T415A';
comment on column bds_refrnc_bom_altrnt_t415a.valid_from_date is 'Start date of entry - LADS_REF_DAT - T415A';
comment on column bds_refrnc_bom_altrnt_t415a.technical_status_from_date is 'Technical Status Valid Date - LADS_REF_DAT - T415A';
comment on column bds_refrnc_bom_altrnt_t415a.sap_idoc_number is 'SAP IDOC Number - LADS_REF_DAT - T415A';
comment on column bds_refrnc_bom_altrnt_t415a.sap_idoc_timestamp is 'SAP IDOC Timestamp - LADS_REF_DAT - T415A';
comment on column bds_refrnc_bom_altrnt_t415a.change_flag is 'Record based on change IDOC from SAP - LADS_REF_DAT - T415A';


/**/
/* Synonym
/**/
create or replace public synonym bds_refrnc_bom_altrnt_t415a for bds.bds_refrnc_bom_altrnt_t415a;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_refrnc_bom_altrnt_t415a to lics_app;
grant select,update,delete,insert on bds_refrnc_bom_altrnt_t415a to bds_app;
grant select,update,delete,insert on bds_refrnc_bom_altrnt_t415a to lads_app;

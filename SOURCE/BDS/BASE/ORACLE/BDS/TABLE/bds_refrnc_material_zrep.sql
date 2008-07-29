/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_REFRNC_MATERIAL_ZREP
 Owner   : BDS
 Author  : Linden Glen

 taxription
 -----------
 Business Data Store - Reference Data - Material ZREP (ZDISTR)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_refrnc_material_zrep
   (refrnc_code                      varchar2(30 char)            not null,
    client_id                        varchar2(5 char)             not null,
    application_id                   varchar2(5 char)             not null,
    material_dtrmntn_type            varchar2(5 char)             not null,
    sales_organisation               varchar2(5 char)             not null,
    dstrbtn_channel                  varchar2(5 char)             not null,
    sold_to_code                     varchar2(10 char)            not null,
    zrep_material_code               varchar2(18 char)            not null,
    start_date                       date                         not null,
    end_date                         date                         not null,
    condition_record_no              varchar2(10 char)            null,
    change_flag                      varchar2(1 char)             null,    
    sap_idoc_number                  number                       null, 
    sap_idoc_timestamp               varchar2(14 char)            null);
    
/**/
/* Primary Key Constraint
/**/
alter table bds_refrnc_material_zrep
   add constraint bds_refrnc_material_zrep_pk primary key (refrnc_code,
                                                           client_id,
                                                           application_id,
                                                           material_dtrmntn_type,
                                                           sales_organisation,
                                                           dstrbtn_channel,
                                                           sold_to_code,
                                                           zrep_material_code,
                                                           end_date,
                                                           start_date);

/**/
/* Indexes
/**/
create index bds_refrnc_material_zrep_idx01 on bds_refrnc_material_zrep (client_id, application_id);



/**/
/* Comments
/**/
comment on table bds_refrnc_material_zrep is 'Business Data Store - Reference Data - Material ZREP (ZDISTR - KOTD907, KOTD501, KOTD880, KOTD002)';
comment on column bds_refrnc_material_zrep.client_id is 'Client ID - LADS_REF_DAT';
comment on column bds_refrnc_material_zrep.client_id is 'Client - LADS_REF_DAT';
comment on column bds_refrnc_material_zrep.application_id is 'Application - LADS_REF_DAT';
comment on column bds_refrnc_material_zrep.material_dtrmntn_type is 'Material determination type - LADS_REF_DAT';
comment on column bds_refrnc_material_zrep.sales_organisation is 'Sales Organization - LADS_REF_DAT';
comment on column bds_refrnc_material_zrep.dstrbtn_channel is 'Distribution Channel - LADS_REF_DAT';
comment on column bds_refrnc_material_zrep.sold_to_code is 'Sold-to party - LADS_REF_DAT';
comment on column bds_refrnc_material_zrep.zrep_material_code is 'Material entered - LADS_REF_DAT';
comment on column bds_refrnc_material_zrep.end_date is 'Validity end date of the condition record - LADS_REF_DAT';
comment on column bds_refrnc_material_zrep.start_date is 'Validity start date of the condition record - LADS_REF_DAT';
comment on column bds_refrnc_material_zrep.condition_record_no is 'Condition record number - LADS_REF_DAT';
comment on column bds_refrnc_material_zrep.sap_idoc_number is 'SAP IDOC Number - LADS_REF_DAT';
comment on column bds_refrnc_material_zrep.sap_idoc_timestamp is 'SAP IDOC Timestamp - LADS_REF_DAT';
comment on column bds_refrnc_material_zrep.change_flag is 'Record based on change IDOC from SAP - LADS_REF_DAT';


/**/
/* Synonym
/**/
create or replace public synonym bds_refrnc_material_zrep for bds.bds_refrnc_material_zrep;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_refrnc_material_zrep to lics_app;
grant select,update,delete,insert on bds_refrnc_material_zrep to bds_app;
grant select,update,delete,insert on bds_refrnc_material_zrep to lads_app;

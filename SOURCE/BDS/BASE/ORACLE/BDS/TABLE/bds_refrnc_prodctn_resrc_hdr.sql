/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_REFRNC_PRODCTN_RESRC_HDR
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Reference Data - Production Resource Header (ZDISTR)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_refrnc_prodctn_resrc_hdr
   (client_id                       varchar2(5 char)      not null, 
    resrc_type                      varchar2(5 char)      not null,
    resrc_id                        varchar2(8 char)      not null,
    resrc_code                      varchar2(8 char)      null,
    resrc_plant_code                varchar2(4 char)      null,
    resrc_ctgry                     varchar2(4 char)      null,
    resrc_deletion_flag             varchar2(1 char)      null,
    sap_idoc_number                 number                null, 
    sap_idoc_timestamp              varchar2(14 char)     null, 
    change_flag                     varchar2(1 char)      null);

    
/**/
/* Primary Key Constraint
/**/
alter table bds_refrnc_prodctn_resrc_hdr
   add constraint bds_prodctn_resrc_hdr_pk primary key (client_id, resrc_type, resrc_id);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_refrnc_prodctn_resrc_hdr is 'Business Data Store - Reference Data - Production Resource Header (ZDISTR - CRHD)';
comment on column bds_refrnc_prodctn_resrc_hdr.client_id is 'SAP Client ID - LADS_REF_DAT - CRHD';
comment on column bds_refrnc_prodctn_resrc_hdr.resrc_type is 'Object types of the CIM Resource - LADS_REF_DAT - CRHD';
comment on column bds_refrnc_prodctn_resrc_hdr.resrc_id is 'Object ID of the resource - LADS_REF_DAT - CRHD';
comment on column bds_refrnc_prodctn_resrc_hdr.resrc_code is 'Resource/Work Center Code - LADS_REF_DAT - CRHD';
comment on column bds_refrnc_prodctn_resrc_hdr.resrc_plant_code is 'Resource Plant Code - LADS_REF_DAT - CRHD';
comment on column bds_refrnc_prodctn_resrc_hdr.resrc_ctgry is 'Resource Category - LADS_REF_DAT - CRHD';
comment on column bds_refrnc_prodctn_resrc_hdr.resrc_deletion_flag is 'Resource Deletion Flag - LADS_REF_DAT - CRHD';
comment on column bds_refrnc_prodctn_resrc_hdr.sap_idoc_number is 'SAP IDOC Number - LADS_REF_DAT - CRHD';
comment on column bds_refrnc_prodctn_resrc_hdr.sap_idoc_timestamp is 'SAP IDOC Timestamp - LADS_REF_DAT - CRHD';
comment on column bds_refrnc_prodctn_resrc_hdr.change_flag is 'Record based on change IDOC from SAP - LADS_REF_DAT - CRHD';


/**/
/* Synonym
/**/
create or replace public synonym bds_refrnc_prodctn_resrc_hdr for bds.bds_refrnc_prodctn_resrc_hdr;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_refrnc_prodctn_resrc_hdr to lics_app;
grant select,update,delete,insert on bds_refrnc_prodctn_resrc_hdr to bds_app;
grant select,update,delete,insert on bds_refrnc_prodctn_resrc_hdr to lads_app;

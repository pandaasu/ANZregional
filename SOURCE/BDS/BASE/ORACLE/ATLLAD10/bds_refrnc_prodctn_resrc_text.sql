/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_REFRNC_PRODCTN_RESRC_TEXT
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Reference Data - Production Resource Text (ZDISTR)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_refrnc_prodctn_resrc_text
   (client_id                       varchar2(5 char)      not null, 
    resrc_type                      varchar2(5 char)      not null,
    resrc_id                        varchar2(8 char)      not null,
    resrc_lang                      varchar2(5 char)      not null,
    resrc_text                      varchar2(40 char)     null,
    resrc_text_upper                varchar2(40 char)     null,
    change_date                     date                  null,
    change_user                     varchar2(12 char)     null,
    sap_idoc_number                 number                null, 
    sap_idoc_timestamp              varchar2(14 char)     null, 
    change_flag                     varchar2(1 char)      null);

    
/**/
/* Primary Key Constraint
/**/
alter table bds_refrnc_prodctn_resrc_text
   add constraint bds_prodctn_resrc_text_pk primary key (client_id, resrc_type, resrc_id, resrc_lang);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_refrnc_prodctn_resrc_text is 'Business Data Store - Reference Data - Production Resource Text (ZDISTR - CRTX)';
comment on column bds_refrnc_prodctn_resrc_text.client_id is 'SAP Client ID - LADS_REF_DAT - CRTX';
comment on column bds_refrnc_prodctn_resrc_text.resrc_type is 'Object types of the CIM Resource - LADS_REF_DAT - CRTX';
comment on column bds_refrnc_prodctn_resrc_text.resrc_id is 'Object ID of the resource - LADS_REF_DAT - CRTX';
comment on column bds_refrnc_prodctn_resrc_text.resrc_lang is 'Language Key - LADS_REF_DAT - CRTX';
comment on column bds_refrnc_prodctn_resrc_text.resrc_text is 'Short Description - LADS_REF_DAT - CRTX';
comment on column bds_refrnc_prodctn_resrc_text.resrc_text is 'Short Description in Capitals - LADS_REF_DAT - CRTX';
comment on column bds_refrnc_prodctn_resrc_text.change_date is 'Date of last change to record - LADS_REF_DAT - CRTX';
comment on column bds_refrnc_prodctn_resrc_text.resrc_text is 'Last change user - LADS_REF_DAT - CRTX';
comment on column bds_refrnc_prodctn_resrc_text.sap_idoc_number is 'SAP IDOC Number - LADS_REF_DAT - CRTX';
comment on column bds_refrnc_prodctn_resrc_text.sap_idoc_timestamp is 'SAP IDOC Timestamp - LADS_REF_DAT - CRTX';
comment on column bds_refrnc_prodctn_resrc_text.change_flag is 'Record based on change IDOC from SAP - LADS_REF_DAT - CRTX';


/**/
/* Synonym
/**/
create or replace public synonym bds_refrnc_prodctn_resrc_text for bds.bds_refrnc_prodctn_resrc_text;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_refrnc_prodctn_resrc_text to lics_app;
grant select,update,delete,insert on bds_refrnc_prodctn_resrc_text to bds_app;
grant select,update,delete,insert on bds_refrnc_prodctn_resrc_text to lads_app;

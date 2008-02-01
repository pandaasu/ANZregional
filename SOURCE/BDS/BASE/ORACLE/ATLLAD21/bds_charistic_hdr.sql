/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_CHARISTIC_HDR
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Characteristic Data - ATLLAD21 (CHRMAS03)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_charistic_hdr
   (sap_charistic_code                varchar2(30 char)     not null,
    bds_charistic_desc_en             varchar2(30 char)     null,   
    bds_lads_date                     date                  null,
    bds_lads_status                   varchar2(2 char)      null,
    sap_idoc_name                     varchar2(30 char)     null,
    sap_idoc_number                   number                null,
    sap_idoc_timestamp                varchar2(14 char)     null,
    sap_creatn_date                   varchar2(8 char)      null,
    sap_creatn_user                   varchar2(12 char)     null, 
    sap_change_date                   varchar2(8 char)      null, 
    sap_change_user                   varchar2(12 char)     null,
    sap_case_snstive                  varchar2(1 char)      null, 
    sap_entry_reqd                    varchar2(1 char)      null, 
    sap_sngl_value                    varchar2(1 char)      null, 
    sap_function                      varchar2(3 char)      null,
    sap_charistic_grp                 varchar2(10 char)     null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_charistic_hdr
   add constraint bds_charistic_hdr_pk primary key (sap_charistic_code);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_charistic_hdr is 'Business Data Store - Characteristic Master Header (CHRMAS03)';
comment on column bds_charistic_hdr.sap_charistic_code is 'SAP Characteristic code - LADS_CHR_MAS_HDR.ATNAM';
comment on column bds_charistic_hdr.bds_charistic_desc_en is 'Characteristic English Description - LADS_CHR_MAS_DET.ATBEZ';
comment on column bds_charistic_hdr.bds_lads_date is 'LADS Date - LADS_CHR_MAS_HDR.LADS_DATE';
comment on column bds_charistic_hdr.bds_lads_status is 'LADS Status - LADS_CHR_MAS_HDR.LADS_STATUS';
comment on column bds_charistic_hdr.sap_idoc_name is 'IDOC Name - LADS_CHR_MAS_HDR.IDOC_NAME';
comment on column bds_charistic_hdr.sap_idoc_number is 'IDOC Number - LADS_CHR_MAS_HDR.IDOC_NUMBER';
comment on column bds_charistic_hdr.sap_idoc_timestamp is 'IDOC Timestamp - LADS_CHR_MAS_HDR.IDOC_TIMESTAMP';
comment on column bds_charistic_hdr.sap_creatn_date is 'SAP Record creation date - LADS_CHR_MAS_HDR.ADATU';
comment on column bds_charistic_hdr.sap_creatn_user is 'SAP Record creation user - LADS_CHR_MAS_HDR.ANAME';
comment on column bds_charistic_hdr.sap_change_date is 'SAP Last change date - LADS_CHR_MAS_HDR.VDATU';
comment on column bds_charistic_hdr.sap_change_user is 'SAP Last change user - LADS_CHR_MAS_HDR.VNAME';
comment on column bds_charistic_hdr.sap_case_snstive is 'SAP Case sensitive flag - LADS_CHR_MAS_HDR.ATKLE';
comment on column bds_charistic_hdr.sap_entry_reqd is 'SAP Entry Required flag - LADS_CHR_MAS_HDR.ATERF';
comment on column bds_charistic_hdr.sap_sngl_value is 'SAP Single Value flag - LADS_CHR_MAS_HDR.ATEIN';
comment on column bds_charistic_hdr.sap_function is 'SAP Function - LADS_CHR_MAS_HDR.MSGFN';
comment on column bds_charistic_hdr.sap_charistic_grp is 'SAP Characteristic Group code - LADS_CHR_MAS_HDR.ATKLA';


/**/
/* Synonym
/**/
create or replace public synonym bds_charistic_hdr for bds.bds_charistic_hdr;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_charistic_hdr to lics_app;
grant select,update,delete,insert on bds_charistic_hdr to bds_app;
grant select,update,delete,insert on bds_charistic_hdr to lads_app;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_REFRNC_CHARISTIC
 Owner   : BDS
 Author  : Linden Glen

 taxription
 -----------
 Business Data Store - Reference Data - Characteristic Value Codes (ZDISTR)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_refrnc_charistic
   (sap_charistic_code                varchar2(30 char)     not null,
    sap_charistic_value_code          varchar2(30 char)     not null,
    sap_charistic_value_shrt_desc     varchar2(256 char)    null, 
    sap_charistic_value_long_desc     varchar2(256 char)    null, 
    sap_idoc_number                   number                null, 
    sap_idoc_timestamp                varchar2(14 char)     null, 
    change_flag                       varchar2(1 char)      null);

    
/**/
/* Primary Key Constraint
/**/
alter table bds_refrnc_charistic
   add constraint bds_refrnc_charistic_pk primary key (sap_charistic_code, sap_charistic_value_code);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_refrnc_charistic is 'Business Data Store - Reference Data - Characteristics (ZDISTR - T001W)';
comment on column bds_refrnc_charistic.sap_charistic_code is 'SAP Characteristic code - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_charistic.sap_charistic_value_code is 'SAP Characteristic Value code - LADS_REF_DAT';
comment on column bds_refrnc_charistic.sap_charistic_value_shrt_desc is 'Characteristic Short Description - LADS_REF_DAT';
comment on column bds_refrnc_charistic.sap_charistic_value_long_desc is 'Characteristic Long Description - LADS_REF_DAT';
comment on column bds_refrnc_charistic.sap_idoc_number is 'SAP IDOC Number - LADS_REF_DAT';
comment on column bds_refrnc_charistic.sap_idoc_timestamp is 'SAP IDOC Timestamp - LADS_REF_DAT';
comment on column bds_refrnc_charistic.change_flag is 'Record based on change IDOC from SAP - LADS_REF_DAT';



/**/
/* Synonym
/**/
create or replace public synonym bds_refrnc_charistic for bds.bds_refrnc_charistic;

s
/**/
/* Authority
/**/
grant select,update,delete,insert on bds_refrnc_charistic to lics_app;
grant select,update,delete,insert on bds_refrnc_charistic to bds_app;
grant select,update,delete,insert on bds_refrnc_charistic to lads_app;

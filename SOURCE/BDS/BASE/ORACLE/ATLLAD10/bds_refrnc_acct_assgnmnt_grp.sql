/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_REFRNC_ACCT_ASSGNMNT_GRP
 Owner   : BDS
 Author  : Linden Glen

 taxription
 -----------
 Business Data Store - Reference Data - Account Assignment Group (ZDISTR)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_refrnc_acct_assgnmnt_grp
   (acct_assgnmnt_grp_code            varchar2(4 char)         not null, 
    desc_language                     varchar2(2 char)         not null,
    acct_assgnmnt_grp_desc            varchar2(20 char)        null,
    sap_idoc_number                   number                   null, 
    sap_idoc_timestamp                varchar2(14 char)        null, 
    change_flag                       varchar2(1 char)         null);

    
/**/
/* Primary Key Constraint
/**/
alter table bds_refrnc_acct_assgnmnt_grp
   add constraint bds_acct_assgnmnt_grp_pk primary key (acct_assgnmnt_grp_code, desc_language);

    
/**/
/* Indexes
/**/
create index bds_refrnc_aag_idx1 on bds_refrnc_acct_assgnmnt_grp (desc_language);

/**/
/* Comments
/**/
comment on table bds_refrnc_acct_assgnmnt_grp is 'Business Data Store - Reference Data - Account Assignment Group (ZDISTR - TVKTT)';
comment on column bds_refrnc_acct_assgnmnt_grp.acct_assgnmnt_grp_code is 'Account Assignment Group Code - LADS_REF_DAT - TVKTT';
comment on column bds_refrnc_acct_assgnmnt_grp.desc_language is 'Account Assignment Group Description Language - LADS_REF_DAT - TVKTT';
comment on column bds_refrnc_acct_assgnmnt_grp.acct_assgnmnt_grp_desc is 'Account Assignment Group Description - LADS_REF_DAT - TVKTT';
comment on column bds_refrnc_acct_assgnmnt_grp.sap_idoc_number is 'SAP IDOC Number - LADS_REF_DAT - TVKTT';
comment on column bds_refrnc_acct_assgnmnt_grp.sap_idoc_timestamp is 'SAP IDOC Timestamp - LADS_REF_DAT - TVKTT';
comment on column bds_refrnc_acct_assgnmnt_grp.change_flag is 'Record based on change IDOC from SAP - LADS_REF_DAT - TVKTT';

/**/
/* Synonym
/**/
create or replace public synonym bds_refrnc_acct_assgnmnt_grp for bds.bds_refrnc_acct_assgnmnt_grp;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_refrnc_acct_assgnmnt_grp to lics_app;
grant select,update,delete,insert on bds_refrnc_acct_assgnmnt_grp to bds_app;
grant select,update,delete,insert on bds_refrnc_acct_assgnmnt_grp to lads_app;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_REFRNC_MOE
 Owner   : BDS
 Author  : Linden Glen

 taxription
 -----------
 Business Data Store - Reference Data - Mars Organisational Entity (ZDISTR)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_refrnc_moe
   (moe_code                        varchar2(4 char)      not null, 
    moe_shrt_desc                   varchar2(12 char)     null,
    moe_long_desc                   varchar2(40 char)     null,
    moe_type                        varchar2(2 char)      null,
    moe_reporting_grp               varchar2(4 char)      null,
    moe_dp_grp                      varchar2(4 char)      null,
    moe_grp_3                       varchar2(4 char)      null,
    moe_grp_4                       varchar2(4 char)      null,
    moe_grp_5                       varchar2(4 char)      null,
    sap_idoc_number                 number                null, 
    sap_idoc_timestamp              varchar2(14 char)     null, 
    change_flag                     varchar2(1 char)      null);

    
/**/
/* Primary Key Constraint
/**/
alter table bds_refrnc_moe
   add constraint bds_refrnc_moe_pk primary key (moe_code);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_refrnc_moe is 'Business Data Store - Reference Data - Mars Organisational Entity (ZDISTR - T001)';
comment on column bds_refrnc_moe.moe_code is 'Mars Organisational Entity Code - LADS_REF_DAT - T001';
comment on column bds_refrnc_moe.moe_shrt_desc is 'MOE Short Description - LADS_REF_DAT - T001';
comment on column bds_refrnc_moe.moe_long_desc is 'MOE Long Description - LADS_REF_DAT - T001';
comment on column bds_refrnc_moe.moe_type is 'MOE Type - LADS_REF_DAT - T001';
comment on column bds_refrnc_moe.moe_reporting_grp is 'MOE Reporting Group - LADS_REF_DAT - T001';
comment on column bds_refrnc_moe.moe_dp_grp is 'MOE DP Group - LADS_REF_DAT - T001';
comment on column bds_refrnc_moe.moe_grp_3 is 'MOE Group 3 - LADS_REF_DAT - T001';
comment on column bds_refrnc_moe.moe_grp_4 is 'MOE Group 4 - LADS_REF_DAT - T001';
comment on column bds_refrnc_moe.moe_grp_5 is 'MOE Group 5 - LADS_REF_DAT - T001';
comment on column bds_refrnc_moe.sap_idoc_number is 'SAP IDOC Number - LADS_REF_DAT - T001';
comment on column bds_refrnc_moe.sap_idoc_timestamp is 'SAP IDOC Timestamp - LADS_REF_DAT - T001';
comment on column bds_refrnc_moe.change_flag is 'Record based on change IDOC from SAP - LADS_REF_DAT - T001';


/**/
/* Synonym
/**/
create or replace public synonym bds_refrnc_moe for bds.bds_refrnc_moe;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_refrnc_moe to lics_app;
grant select,update,delete,insert on bds_refrnc_moe to bds_app;
grant select,update,delete,insert on bds_refrnc_moe to lads_app;

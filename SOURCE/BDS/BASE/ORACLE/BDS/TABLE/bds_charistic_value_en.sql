/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_CHARISTIC_VALUE_EN
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Characteristic Data, English Values - ATLLAD21 (CHRMAS03)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created
 2006/11   Linden Glen    Changed sap_classfctn_code to sap_charistic_value_code

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_charistic_value_en
   (sap_charistic_code                varchar2(30 char)     not null,
    sap_charistic_value_code          varchar2(30 char)     not null, 
    sap_charistic_value_desc          varchar2(30 char)     null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_charistic_value_en
   add constraint bds_charistic_value_en_pk primary key (sap_charistic_code, sap_charistic_value_code);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_charistic_value_en is 'Business Data Store - English Only Characteristic Master Values (CHRMAS03)';
comment on column bds_charistic_value_en.sap_charistic_code is 'SAP Characteristic code - LADS_CHR_MAS_HDR.ATNAM';
comment on column bds_charistic_value_en.sap_charistic_value_code is 'SAP Classification Value code - LADS_CHR_MAS_VAL.ATWRT';
comment on column bds_charistic_value_en.sap_charistic_value_desc is 'SAP Classification Value Description - LADS_CHR_MAS_DSC.ATWTB';


/**/
/* Synonym
/**/
create or replace public synonym bds_charistic_value_en for bds.bds_charistic_value_en;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_charistic_value_en to lics_app;
grant select,update,delete,insert on bds_charistic_value_en to bds_app;
grant select,update,delete,insert on bds_charistic_value_en to lads_app;

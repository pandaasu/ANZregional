/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_CHARISTIC_VALUE
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Characteristic Data Values - ATLLAD21 (CHRMAS03)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created
 2006/11   Linden Glen    Changed sap_classfctn_code to sap_charistic_value_code

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_charistic_value
   (sap_charistic_code                varchar2(30 char)     not null,
    sap_charistic_value_code          varchar2(30 char)     not null, 
    sap_charistic_value_lang          varchar2(2 char)      not null,
    sap_charistic_value_desc          varchar2(30 char)     null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_charistic_value
   add constraint bds_charistic_value_pk primary key (sap_charistic_code, sap_charistic_value_code, sap_charistic_value_lang);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_charistic_value is 'Business Data Store - Characteristic Master Values (CHRMAS03)';
comment on column bds_charistic_value.sap_charistic_code is 'SAP Characteristic code - LADS_CHR_MAS_HDR.ATNAM';
comment on column bds_charistic_value.sap_charistic_value_code is 'SAP Characteristic Value code - LADS_CHR_MAS_VAL.ATWRT';
comment on column bds_charistic_value.sap_charistic_value_lang is 'SAP Characteristic Value Description Language - LADS_CHR_MAS_DSC.SPRAS_ISO';
comment on column bds_charistic_value.sap_charistic_value_desc is 'SAP Characteristic Value Description - LADS_CHR_MAS_DSC.ATWTB';


/**/
/* Synonym
/**/
create or replace public synonym bds_charistic_value for bds.bds_charistic_value;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_charistic_value to lics_app;
grant select,update,delete,insert on bds_charistic_value to bds_app;
grant select,update,delete,insert on bds_charistic_value to lads_app;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_CHARISTIC_DESC
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Characteristic Descriptions - ATLLAD21 (CHRMAS03)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_charistic_desc
   (sap_charistic_code                varchar2(30 char)     not null,
    sap_charistic_desc_lang           varchar2(2 char)      not null,
    sap_charistic_desc                varchar2(30 char)     null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_charistic_desc
   add constraint bds_charistic_desc_pk primary key (sap_charistic_code, sap_charistic_desc_lang);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_charistic_desc is 'Business Data Store - Characteristic Master Descriptions (CHRMAS03)';
comment on column bds_charistic_desc.sap_charistic_code is 'SAP Characteristic code - LADS_CHR_MAS_HDR.ATNAM';
comment on column bds_charistic_desc.sap_charistic_desc_lang is 'SAP Classification code - LADS_CHR_MAS_DET.SPRAS_ISO';
comment on column bds_charistic_desc.sap_charistic_desc is 'SAP Characteristic Description - LADS_CHR_MAS_DET.ATBEZ';


/**/
/* Synonym
/**/
create or replace public synonym bds_charistic_desc for bds.bds_charistic_desc;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_charistic_desc to lics_app;
grant select,update,delete,insert on bds_charistic_desc to bds_app;
grant select,update,delete,insert on bds_charistic_desc to lads_app;

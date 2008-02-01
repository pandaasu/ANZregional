/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_DESC
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Description (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_desc
   (sap_material_code         varchar2(18 char)    not null, 
    desc_language             varchar2(2 char)     not null,
    material_desc             varchar2(40 char)    null,  
    sap_function              varchar2(3 char)     null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_desc
   add constraint bds_material_desc_pk primary key (sap_material_code, desc_language);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_desc is 'Business Data Store - Material Description (MATMAS)';
comment on column bds_material_desc.sap_material_code is 'Material Number - lads_mat_mkt.matnr';
comment on column bds_material_desc.material_desc is 'Material Description - lads_mat_mkt.maktx';
comment on column bds_material_desc.desc_language is 'Language according to ISO 639 - lads_mat_mkt.spras_iso';
comment on column bds_material_desc.sap_function is 'Function - lads_mat_mkt.msgfn';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_desc for bds.bds_material_desc;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_desc to lics_app;
grant select,update,delete,insert on bds_material_desc to bds_app;
grant select,update,delete,insert on bds_material_desc to lads_app;

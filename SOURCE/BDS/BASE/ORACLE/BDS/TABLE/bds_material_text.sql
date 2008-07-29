/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_TEXT
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Text (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_text
   (sap_material_code             varchar2(18 char)     not null, 
    text_object                   varchar2(10 char)     not null, 
    text_name                     varchar2(70 char)     not null, 
    text_id                       varchar2(4 char)      not null, 
    text_type                     varchar2(6 char)      not null, 
    text_language                 varchar2(2 char)      not null, 
    text                          varchar2(2000 char)   null, 
    sap_function                  varchar2(3 char)      null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_text
   add constraint bds_material_text_pk primary key (sap_material_code, text_object, text_name, text_id, text_type, text_language);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_text is 'Business Data Store - Material Text (MATMAS)';
comment on column bds_material_text.sap_material_code is 'Material Number - lads_mat_txh.matnr';
comment on column bds_material_text.text_object is 'Texts: application object - lads_mat_txh.tdobject';
comment on column bds_material_text.text_name is 'Name - lads_mat_txh.tdname';
comment on column bds_material_text.text_id is 'Text ID - lads_mat_txh.tdid';
comment on column bds_material_text.text_type is 'SAPscript: Format of Text - lads_mat_txh.tdtexttype';
comment on column bds_material_text.text_language is 'Language according to ISO 639 - lads_mat_txh.spras_iso';
comment on column bds_material_text.text is 'Material Text - lads_mat_txl.tdline';
comment on column bds_material_text.sap_function is 'Function - lads_mat_txh.msgfn';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_text for bds.bds_material_text;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_text to lics_app;
grant select,update,delete,insert on bds_material_text to bds_app;
grant select,update,delete,insert on bds_material_text to lads_app;

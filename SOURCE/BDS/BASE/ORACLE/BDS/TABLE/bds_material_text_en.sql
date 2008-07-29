/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_TEXT_EN
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Text (English for MVKE) (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_text_en
   (sap_material_code             varchar2(18 char)     not null, 
    sales_organisation            varchar2(4 char)      not null,
    dstrbtn_channel               varchar2(2 char)      not null,
    text                          varchar2(2000 char)   null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_text_en
   add constraint bds_material_text_en_pk primary key (sap_material_code, sales_organisation, dstrbtn_channel);

    
/**/
/* Indexes
/**/
create index bds_material_text_en_idx1 on bds_material_text_en (sales_organisation, dstrbtn_channel);


/**/
/* Comments
/**/
comment on table bds_material_text_en is 'Business Data Store - Material Text (English by MVKE) (MATMAS)';
comment on column bds_material_text_en.sap_material_code is 'Material Number - lads_mat_txh.matnr';
comment on column bds_material_text_en.sales_organisation is 'Sales Organisation - lads_mat_txh.tdname';
comment on column bds_material_text_en.dstrbtn_channel is 'Distribution Channel - lads_mat_txh.tdname';
comment on column bds_material_text_en.text is 'Material Text - lads_mat_txl.tdline';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_text_en for bds.bds_material_text_en;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_text_en to lics_app;
grant select,update,delete,insert on bds_material_text_en to bds_app;
grant select,update,delete,insert on bds_material_text_en to lads_app;

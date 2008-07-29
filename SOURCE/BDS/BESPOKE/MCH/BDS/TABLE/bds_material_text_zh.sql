/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_TEXT_ZH
 Owner   : BDS
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Material Text (Chinese for MVKE) (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/05   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_text_zh
   (sap_material_code             varchar2(18 char)     not null, 
    sales_organisation            varchar2(4 char)      not null,
    dstrbtn_channel               varchar2(2 char)      not null,
    text                          varchar2(2000 char)   null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_text_zh
   add constraint bds_material_text_zh_pk primary key (sap_material_code, sales_organisation, dstrbtn_channel);

    
/**/
/* Indexes
/**/
create index bds_material_text_zh_idx1 on bds_material_text_zh (sales_organisation, dstrbtn_channel);


/**/
/* Comments
/**/
comment on table bds_material_text_zh is 'Business Data Store - Material Text (Chinese by MVKE) (MATMAS)';
comment on column bds_material_text_zh.sap_material_code is 'Material Number - lads_mat_txh.matnr';
comment on column bds_material_text_zh.sales_organisation is 'Sales Organisation - lads_mat_txh.tdname';
comment on column bds_material_text_zh.dstrbtn_channel is 'Distribution Channel - lads_mat_txh.tdname';
comment on column bds_material_text_zh.text is 'Material Text - lads_mat_txl.tdline';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_text_zh for bds.bds_material_text_zh;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_text_zh to lics_app;
grant select,update,delete,insert on bds_material_text_zh to bds_app;
grant select,update,delete,insert on bds_material_text_zh to lads_app;

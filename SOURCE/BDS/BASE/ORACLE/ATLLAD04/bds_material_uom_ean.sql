/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_uom_ean_EAN
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Unit Of Measure Conversions for EAN (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_uom_ean
   (sap_material_code             varchar2(18 char)     not null, 
    uom_code                      varchar2(3 char)      not null,
    consecutive_no                varchar2(5 char)      not null, 
    sap_function                  varchar2(3 char)      null, 
    interntl_article_no           varchar2(18 char)     null, 
    interntl_article_no_ctgry     varchar2(2 char)      null, 
    main_ean_indctr               varchar2(1 char)      null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_uom_ean
   add constraint bds_material_uom_ean_pk primary key (sap_material_code, uom_code, consecutive_no);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_uom_ean is 'Business Data Store - Material Unit Of Measure Conversions for EAN (MATMAS)';
comment on column bds_material_uom_ean.sap_material_code is 'Material Number - lads_mat_uoe.matnr';
comment on column bds_material_uom_ean.uom_code is 'Unit of Measure - lads_mat_uoe.meinh';
comment on column bds_material_uom_ean.consecutive_no is 'Consecutive Number - lads_mat_uoe.lfnum';
comment on column bds_material_uom_ean.sap_function is 'Function - lads_mat_uoe.msgfn';
comment on column bds_material_uom_ean.interntl_article_no is 'International Article Number (EAN/UPC) - lads_mat_uoe.ean11';
comment on column bds_material_uom_ean.interntl_article_no_ctgry is 'Category of International Article Number (EAN) - lads_mat_uoe.eantp';
comment on column bds_material_uom_ean.main_ean_indctr is 'Indicator: Main EAN - lads_mat_uoe.hpean';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_uom_ean for bds.bds_material_uom_ean;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_uom_ean to lics_app;
grant select,update,delete,insert on bds_material_uom_ean to bds_app;
grant select,update,delete,insert on bds_material_uom_ean to lads_app;

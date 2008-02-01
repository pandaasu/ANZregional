/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : material_bf_bsf_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Material Brand Flag Brand Sub Flag Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.material_bf_bsf_dim
   (sap_brand_flag_code        varchar2(4 char)               not null,
    brand_flag_abbrd_desc      varchar2(12 char)              not null,
    brand_flag_desc            varchar2(30 char)              not null,
    sap_brand_sub_flag_code    varchar2(4 char)               not null,
    brand_sub_flag_abbrd_desc  varchar2(12 char)              not null,
    brand_sub_flag_desc        varchar2(30 char)              not null);

/**/
/* Comments
/**/
comment on table dd.material_bf_bsf_dim is 'Material Brand Flag Brand Sub Flag Table';
comment on column dd.material_bf_bsf_dim.sap_brand_flag_code is 'SAP Brand Flag Code';
comment on column dd.material_bf_bsf_dim.brand_flag_abbrd_desc is 'Brand Flag Abbreviated Description';
comment on column dd.material_bf_bsf_dim.brand_flag_desc is 'Brand Flag Description';
comment on column dd.material_bf_bsf_dim.sap_brand_sub_flag_code is 'SAP Brand Sub-Flag Code';
comment on column dd.material_bf_bsf_dim.brand_sub_flag_abbrd_desc is 'Brand Sub-Flag Abbreviated Description';
comment on column dd.material_bf_bsf_dim.brand_sub_flag_desc is 'Brand Sub-Flag Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.material_bf_bsf_dim
   add constraint material_bf_bsf_dim_pk primary key (sap_brand_flag_code, sap_brand_sub_flag_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.material_bf_bsf_dim to dw_app;
grant select on dd.material_bf_bsf_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym material_bf_bsf_dim for dd.material_bf_bsf_dim;
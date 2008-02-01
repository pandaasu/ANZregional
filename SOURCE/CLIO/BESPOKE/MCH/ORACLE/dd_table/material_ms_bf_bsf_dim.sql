/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : material_ms_bf_bsf_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Material Market Segment Brand Flag Brand Sub Flag Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.material_ms_bf_bsf_dim
   (sap_mkt_sgmnt_code         varchar2(4 char)               not null,
    mkt_sgmnt_abbrd_desc       varchar2(12 char)              not null,
    mkt_sgmnt_desc             varchar2(30 char)              not null,
    sap_brand_flag_code        varchar2(4 char)               not null,
    brand_flag_abbrd_desc      varchar2(12 char)              not null,
    brand_flag_desc            varchar2(30 char)              not null,
    sap_brand_sub_flag_code    varchar2(4 char)               not null,
    brand_sub_flag_abbrd_desc  varchar2(12 char)              not null,
    brand_sub_flag_desc        varchar2(30 char)              not null);

/**/
/* Comments
/**/
comment on table dd.material_ms_bf_bsf_dim is 'Material Market Segment Brand Flag Brand Sub Flag Table';
comment on column dd.material_ms_bf_bsf_dim.sap_mkt_sgmnt_code is 'SAP Market Segment Code';
comment on column dd.material_ms_bf_bsf_dim.mkt_sgmnt_abbrd_desc is 'Market Segment Abbreviated Description';
comment on column dd.material_ms_bf_bsf_dim.mkt_sgmnt_desc is 'Market Segment Description';
comment on column dd.material_ms_bf_bsf_dim.sap_brand_flag_code is 'SAP Brand Flag Code';
comment on column dd.material_ms_bf_bsf_dim.brand_flag_abbrd_desc is 'Brand Flag Abbreviated Description';
comment on column dd.material_ms_bf_bsf_dim.brand_flag_desc is 'Brand Flag Description';
comment on column dd.material_ms_bf_bsf_dim.sap_brand_sub_flag_code is 'SAP Brand Sub-Flag Code';
comment on column dd.material_ms_bf_bsf_dim.brand_sub_flag_abbrd_desc is 'Brand Sub-Flag Abbreviated Description';
comment on column dd.material_ms_bf_bsf_dim.brand_sub_flag_desc is 'Brand Sub-Flag Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.material_ms_bf_bsf_dim
   add constraint material_ms_bf_bsf_dim_pk primary key (sap_mkt_sgmnt_code, sap_brand_flag_code, sap_brand_sub_flag_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.material_ms_bf_bsf_dim to dw_app;
grant select on dd.material_ms_bf_bsf_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym material_ms_bf_bsf_dim for dd.material_ms_bf_bsf_dim;
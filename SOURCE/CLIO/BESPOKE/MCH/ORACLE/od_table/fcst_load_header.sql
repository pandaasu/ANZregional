/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_load_header
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Load Header Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_load_header
   (load_identifier                 varchar2(64 char)      not null,
    load_description                varchar2(128 char)     not null,
    load_status                     varchar2(32 char)      not null,
    load_type                       varchar2(32 char)      not null,
    load_data                       varchar2(32 char)      not null,
    cast_yyyymmdd                   varchar2(8 char)       not null,
    cast_yyyyppw                    number(7,0)            not null,
    cast_yyyypp                     number(6,0)            not null,
    fcst_str_yyyyppw                number(7,0)            not null,
    fcst_str_yyyypp                 number(6,0)            not null,
    fcst_end_yyyyppw                number(7,0)            not null,
    fcst_end_yyyypp                 number(6,0)            not null,
    sales_org_code                  varchar2(4 char)       not null,
    distbn_chnl_code                varchar2(2 char)       not null,
    division_code                   varchar2(2 char)       not null,
    crt_user                        varchar2(30 char)      not null,
    crt_date                        date                   not null,
    upd_user                        varchar2(30 char)      not null,
    upd_date                        date                   not null);

/**/
/* Comments
/**/
comment on table od.fcst_load_header is 'Forecast Load Header Table';
comment on column od.fcst_load_header.load_identifier is 'Load identifier';
comment on column od.fcst_load_header.load_description is 'Load description';
comment on column od.fcst_load_header.load_status is 'Load status *CREATING,*VALID,*ERROR,*LOADED';
comment on column od.fcst_load_header.load_type is 'Load type *BR,*OP,*ROB';
comment on column od.fcst_load_header.load_data is 'Load data *DOMESTIC,*AFFILIATE';
comment on column od.fcst_load_header.cast_yyyymmdd is 'Casting date';
comment on column od.fcst_load_header.cast_yyyyppw is 'Casting period week';
comment on column od.fcst_load_header.cast_yyyypp is 'Casting period';
comment on column od.fcst_load_header.fcst_str_yyyyppw is 'Forecast start period week';
comment on column od.fcst_load_header.fcst_str_yyyypp is 'Forecast start period';
comment on column od.fcst_load_header.fcst_end_yyyyppw is 'Forecast end period week';
comment on column od.fcst_load_header.fcst_end_yyyypp is 'Forecast end period';
comment on column od.fcst_load_header.sales_org_code is 'Sales organisation code';
comment on column od.fcst_load_header.distbn_chnl_code is 'Distribution channel code';
comment on column od.fcst_load_header.division_code is 'Division code';
comment on column od.fcst_load_header.crt_user is 'Creation user identifier';
comment on column od.fcst_load_header.crt_date is 'Creation timestamp';
comment on column od.fcst_load_header.upd_user is 'Update user identifier';
comment on column od.fcst_load_header.upd_date is 'Update timestamp';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_load_header
   add constraint fcst_load_header_pk primary key (load_identifier);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_load_header to od_app;
grant select, insert, update, delete on od.fcst_load_header to dw_app;
grant select on od.fcst_load_header to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_load_header for od.fcst_load_header;
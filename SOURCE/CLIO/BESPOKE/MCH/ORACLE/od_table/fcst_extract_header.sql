/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_extract_header
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
create table od.fcst_extract_header
   (extract_identifier              varchar2(64 char)      not null,
    extract_description             varchar2(128 char)     not null,
    extract_type                    varchar2(32 char)      not null,
    plan_group                      varchar2(32 char)      not null,
    export_count                    number                 not null,
    crt_user                        varchar2(30 char)      not null,
    crt_date                        date                   not null);

/**/
/* Comments
/**/
comment on table od.fcst_extract_header is 'Forecast Extract Header Table';
comment on column od.fcst_extract_header.extract_identifier is 'Extract identifier';
comment on column od.fcst_extract_header.extract_description is 'Extract description';
comment on column od.fcst_extract_header.extract_type is 'Extract type';
comment on column od.fcst_extract_header.plan group is 'Planning group';
comment on column od.fcst_extract_header.export_count is 'Export count';
comment on column od.fcst_extract_header.crt_user is 'Creation user identifier';
comment on column od.fcst_extract_header.crt_date is 'Creation timestamp';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_extract_header
   add constraint fcst_extract_header_pk primary key (extract_identifier);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_extract_header to od_app;
grant select, insert, update, delete on od.fcst_extract_header to dw_app;
grant select on od.fcst_extract_header to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_extract_header for od.fcst_extract_header;
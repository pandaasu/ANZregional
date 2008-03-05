/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_extract_detail
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Extract Detail Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_extract_detail
   (extract_identifier              varchar2(64 char)      not null,
    extract_sequence                number                 not null,
    extract_data                    varchar2(4000 char)    not null);

/**/
/* Comments
/**/
comment on table od.fcst_extract_detail is 'Forecast Extract Detail Table';
comment on column od.fcst_extract_detail.extract_identifier is 'Extract identifier';
comment on column od.fcst_extract_detail.extract_sequence is 'Extract sequence';
comment on column od.fcst_extract_detail.extract_data is 'Extract data';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_extract_detail
   add constraint fcst_extract_detail_pk primary key (extract_identifier, extract_sequence);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_extract_detail to od_app;
grant select, insert, update, delete on od.fcst_extract_detail to dw_app;
grant select on od.fcst_extract_detail to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_extract_detail for od.fcst_extract_detail;



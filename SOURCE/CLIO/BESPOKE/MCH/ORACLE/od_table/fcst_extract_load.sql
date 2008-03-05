/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_extract_load
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Extract Load Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_extract_load
   (extract_identifier              varchar2(64 char)      not null,
    load_identifier                 varchar2(64 char)      not null);

/**/
/* Comments
/**/
comment on table od.fcst_extract_load is 'Forecast Extract Load Table';
comment on column od.fcst_extract_load.extract_identifier is 'Extract identifier';
comment on column od.fcst_extract_load.load_identifier is 'Load identifier';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_extract_load
   add constraint fcst_extract_load_pk primary key (extract_identifier, load_identifier);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_extract_load to od_app;
grant select, insert, update, delete on od.fcst_extract_load to dw_app;
grant select on od.fcst_extract_load to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_extract_load for od.fcst_extract_load;
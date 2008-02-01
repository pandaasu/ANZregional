/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_data
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - Validation Data

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds_data
   (vda_query                                    varchar2(30 char)                   not null,
    vda_row                                      number                              not null,
    vda_table                                    varchar2(30 char)                   not null,
    vda_data                                     varchar2(4000 char)                 not null);

/**/
/* Comments
/**/
comment on table vds_data is 'Validation Data';
comment on column vds_data.vda_query is 'Query code';
comment on column vds_data.vda_row is 'Row number';
comment on column vds_data.vda_table is 'Table code';
comment on column vds_data.vda_data is 'Row data';

/**/
/* Primary Key Constraint
/**/
alter table vds_data
   add constraint vds_data_pk primary key (vda_query, vda_row);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds_data to vds_app with grant option;
grant select on vds_data to public;

/**/
/* Synonym
/**/
create or replace public synonym vds_data for vds.vds_data;
/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_val_fil
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Validation Filter

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds_val_fil
   (vaf_filter                                   varchar2(30 char)                   not null,
    vaf_description                              varchar2(128 char)                  not null,
    vaf_group                                    varchar2(30 char)                   not null,
    vaf_type                                     varchar2(30 char)                   not null);

/**/
/* Comments
/**/
comment on table vds_val_fil is 'VDS Validation Filter';
comment on column vds_val_fil.vaf_filter is 'Validation filter identifier';
comment on column vds_val_fil.vaf_description is 'Validation filter description';
comment on column vds_val_fil.vaf_group is 'Validation group identifier';
comment on column vds_val_fil.vaf_type is 'Validation type identifier';

/**/
/* Primary Key Constraint
/**/
alter table vds_val_fil
   add constraint vds_val_fil_pk primary key (vaf_filter);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds_val_fil to vds_app;
grant select on vds_val_fil to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym vds_val_fil for vds.vds_val_fil;

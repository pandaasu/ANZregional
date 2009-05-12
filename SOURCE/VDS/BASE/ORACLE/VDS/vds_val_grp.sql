/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_val_grp
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Validation Group

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds_val_grp
   (vag_group                                    varchar2(30 char)                   not null,
    vag_description                              varchar2(128 char)                  not null,
    vag_cod_length                               number                              not null,
    vag_cod_query                                clob                                not null);

/**/
/* Comments
/**/
comment on table vds_val_grp is 'VDS Validation Group';
comment on column vds_val_grp.vag_group is 'Validation group identifier';
comment on column vds_val_grp.vag_description is 'Validation group description';
comment on column vds_val_grp.vag_cod_length is 'Validation group code length';
comment on column vds_val_grp.vag_cod_query is 'Validation group code query';

/**/
/* Primary Key Constraint
/**/
alter table vds_val_grp
   add constraint vds_val_grp_pk primary key (vag_group);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds_val_grp to vds_app;
grant select on vds_val_grp to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym vds_val_grp for vds.vds_val_grp;

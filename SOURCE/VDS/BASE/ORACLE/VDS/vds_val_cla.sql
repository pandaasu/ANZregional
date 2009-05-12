/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_val_cla
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Validation Classification

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds_val_cla
   (vac_class                                    varchar2(30 char)                   not null,
    vac_description                              varchar2(128 char)                  not null,
    vac_group                                    varchar2(30 char)                   not null,
    vac_lst_query                                clob                                not null,
    vac_one_query                                clob                                not null,
    vac_exe_batch                                varchar2(1 char)                    not null);

/**/
/* Comments
/**/
comment on table vds_val_cla is 'VDS Validation Classification';
comment on column vds_val_cla.vac_class is 'Validation classification identifier';
comment on column vds_val_cla.vac_description is 'Validation classification description';
comment on column vds_val_cla.vac_group is 'Validation group identifier';
comment on column vds_val_cla.vac_lst_query is 'Validation classification list query';
comment on column vds_val_cla.vac_one_query is 'Validation classification one query';
comment on column vds_val_cla.vac_exe_batch is 'Validation classification execute batch';

/**/
/* Primary Key Constraint
/**/
alter table vds_val_cla
   add constraint vds_val_cla_pk primary key (vac_class);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds_val_cla to vds_app;
grant select on vds_val_cla to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym vds_val_cla for vds.vds_val_cla;

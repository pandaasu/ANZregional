/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_val_typ_rul
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Validation Type Rule

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds_val_typ_rul
   (vtr_type                                     varchar2(30 char)                   not null,
    vtr_rule                                     varchar2(30 char)                   not null,
    vtr_sequence                                 number                              not null);

/**/
/* Comments
/**/
comment on table vds_val_typ_rul is 'VDS Validation Type Rule';
comment on column vds_val_typ_rul.vtr_type is 'Validation type identifier';
comment on column vds_val_typ_rul.vtr_rule is 'Validation type rule';
comment on column vds_val_typ_rul.vtr_sequence is 'Validation type rule sequence';

/**/
/* Primary Key Constraint
/**/
alter table vds_val_typ_rul
   add constraint vds_val_typ_rul_pk primary key (vtr_type, vtr_rule);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds_val_typ_rul to vds_app;
grant select on vds_val_typ_rul to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym vds_val_typ_rul for vds.vds_val_typ_rul;

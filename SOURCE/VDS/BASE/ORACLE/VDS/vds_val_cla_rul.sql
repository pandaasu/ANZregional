/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_val_cla_rul
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Validation Classification Rule

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds_val_cla_rul
   (vcr_class                                    varchar2(30 char)                   not null,
    vcr_rule                                     varchar2(30 char)                   not null,
    vcr_sequence                                 number                              not null);

/**/
/* Comments
/**/
comment on table vds_val_cla_rul is 'VDS Validation Classification Rule';
comment on column vds_val_cla_rul.vcr_class is 'Validation classification identifier';
comment on column vds_val_cla_rul.vcr_rule is 'Validation classification rule';
comment on column vds_val_cla_rul.vcr_sequence is 'Validation classification rule sequence';

/**/
/* Primary Key Constraint
/**/
alter table vds_val_cla_rul
   add constraint vds_val_cla_rul_pk primary key (vcr_class, vcr_rule);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds_val_cla_rul to vds_app;
grant select on vds_val_cla_rul to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym vds_val_cla_rul for vds.vds_val_cla_rul;

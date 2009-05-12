/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_val_mes_ema
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Validation Message Email

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds_val_mes_ema
   (vme_execution                                varchar2(50 char)                   not null,
    vme_code                                     varchar2(30 char)                   not null,
    vme_class                                    varchar2(30 char)                   not null,
    vme_sequence                                 number                              not null,
    vme_email                                    varchar2(30 char)                   not null);

/**/
/* Comments
/**/
comment on table vds_val_mes_ema is 'VDS Validation Message Email';
comment on column vds_val_mes_ema.vme_execution is 'Validation execution identifier';
comment on column vds_val_mes_ema.vme_code is 'Validation code';
comment on column vds_val_mes_ema.vme_class is 'Validation classification identifier';
comment on column vds_val_mes_ema.vme_sequence is 'Validation message sequence';
comment on column vds_val_mes_ema.vme_email is 'Validation email identifier';

/**/
/* Primary Key Constraint
/**/
alter table vds_val_mes_ema
   add constraint vds_val_mes_ema_pk primary key (vme_execution, vme_code, vme_class, vme_sequence, vme_email);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds_val_mes_ema to vds_app;
grant select on vds_val_mes_ema to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym vds_val_mes_ema for vds.vds_val_mes_ema;

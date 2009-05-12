/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_val_ema
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Validation Email

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds_val_ema
   (vae_email                                    varchar2(30 char)                   not null,
    vae_description                              varchar2(128 char)                  not null,
    vae_address                                  varchar2(64 char)                   not null,
    vae_status                                   varchar2(1 char)                    not null);

/**/
/* Comments
/**/
comment on table vds_val_ema is 'VDS Validation Email';
comment on column vds_val_ema.vae_email is 'Validation email identifier (*ADMINISTRATOR)';
comment on column vds_val_ema.vae_description is 'Validation email description';
comment on column vds_val_ema.vae_address is 'Validation email address';
comment on column vds_val_ema.vae_status is 'Validation email status - 0(inactive), 1(active)';

/**/
/* Primary Key Constraint
/**/
alter table vds_val_ema
   add constraint vds_val_ema_pk primary key (vae_email);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds_val_ema to vds_app;
grant select on vds_val_ema to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym vds_val_ema for vds.vds_val_ema;

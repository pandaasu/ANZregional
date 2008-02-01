/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_val_ema
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Validation Email

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_val_ema
   (vae_email                                    varchar2(30 char)                   not null,
    vae_description                              varchar2(128 char)                  not null,
    vae_address                                  varchar2(64 char)                   not null,
    vae_status                                   varchar2(1 char)                    not null);

/**/
/* Comments
/**/
comment on table sap_val_ema is 'SAP Validation Email';
comment on column sap_val_ema.vae_email is 'Validation email identifier (*ADMINISTRATOR)';
comment on column sap_val_ema.vae_description is 'Validation email description';
comment on column sap_val_ema.vae_address is 'Validation email address';
comment on column sap_val_ema.vae_status is 'Validation email status - 0(inactive), 1(active)';

/**/
/* Primary Key Constraint
/**/
alter table sap_val_ema
   add constraint sap_val_ema_pk primary key (vae_email);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_val_ema to lads_app;
grant select on sap_val_ema to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_val_ema for lads.sap_val_ema;

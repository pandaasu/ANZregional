/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_val_mes_ema
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Validation Message Email

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_val_mes_ema
   (vme_execution                                varchar2(50 char)                   not null,
    vme_code                                     varchar2(30 char)                   not null,
    vme_class                                    varchar2(30 char)                   not null,
    vme_sequence                                 number                              not null,
    vme_email                                    varchar2(30 char)                   not null);

/**/
/* Comments
/**/
comment on table sap_val_mes_ema is 'SAP Validation Message Email';
comment on column sap_val_mes_ema.vme_execution is 'Validation execution identifier';
comment on column sap_val_mes_ema.vme_code is 'Validation code';
comment on column sap_val_mes_ema.vme_class is 'Validation classification identifier';
comment on column sap_val_mes_ema.vme_sequence is 'Validation message sequence';
comment on column sap_val_mes_ema.vme_email is 'Validation email identifier';

/**/
/* Primary Key Constraint
/**/
alter table sap_val_mes_ema
   add constraint sap_val_mes_ema_pk primary key (vme_execution, vme_code, vme_class, vme_sequence, vme_email);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_val_mes_ema to lads_app;
grant select on sap_val_mes_ema to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_val_mes_ema for lads.sap_val_mes_ema;

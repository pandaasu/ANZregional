/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_val_ema_det
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Validation Email Detail

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_val_ema_det
   (ved_email                                    varchar2(30 char)                   not null,
    ved_group                                    varchar2(30 char)                   not null,
    ved_class                                    varchar2(30 char)                   not null,
    ved_type                                     varchar2(30 char)                   not null,
    ved_filter                                   varchar2(30 char)                   not null,
    ved_rule                                     varchar2(30 char)                   not null,
    ved_search01                                 varchar2(256 char)                  null,
    ved_search02                                 varchar2(256 char)                  null,
    ved_search03                                 varchar2(256 char)                  null,
    ved_search04                                 varchar2(256 char)                  null,
    ved_search05                                 varchar2(256 char)                  null,
    ved_search06                                 varchar2(256 char)                  null,
    ved_search07                                 varchar2(256 char)                  null,
    ved_search08                                 varchar2(256 char)                  null,
    ved_search09                                 varchar2(256 char)                  null);

/**/
/* Comments
/**/
comment on table sap_val_ema_det is 'SAP Validation Email Detail';
comment on column sap_val_ema_det.ved_email is 'Validation email identifier';
comment on column sap_val_ema_det.ved_group is 'Validation email detail group';
comment on column sap_val_ema_det.ved_class is 'Validation email detail classification';
comment on column sap_val_ema_det.ved_type is 'Validation email detail type';
comment on column sap_val_ema_det.ved_filter is 'Validation email detail filter';
comment on column sap_val_ema_det.ved_rule is 'Validation email detail rule';
comment on column sap_val_ema_det.ved_search01 is 'Validation email detail search 01';
comment on column sap_val_ema_det.ved_search02 is 'Validation email detail search 02';
comment on column sap_val_ema_det.ved_search03 is 'Validation email detail search 03';
comment on column sap_val_ema_det.ved_search04 is 'Validation email detail search 04';
comment on column sap_val_ema_det.ved_search05 is 'Validation email detail search 05';
comment on column sap_val_ema_det.ved_search06 is 'Validation email detail search 06';
comment on column sap_val_ema_det.ved_search07 is 'Validation email detail search 07';
comment on column sap_val_ema_det.ved_search08 is 'Validation email detail search 08';
comment on column sap_val_ema_det.ved_search09 is 'Validation email detail search 09';

/**/
/* Primary Key Constraint
/**/
alter table sap_val_ema_det
   add constraint sap_val_ema_det_pk primary key (ved_email, ved_group, ved_class, ved_type, ved_filter, ved_rule);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_val_ema_det to lads_app;
grant select on sap_val_ema_det to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_val_ema_det for lads.sap_val_ema_det;

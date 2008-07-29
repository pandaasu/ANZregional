/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_val_mes
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Validation Message

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created
 2006/12   Steve Gregan   Included execution identifier
                          Included version flag
                          Included emailed count
                          Included search list

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_val_mes
   (vam_execution                                varchar2(50 char)                   not null,
    vam_code                                     varchar2(30 char)                   not null,
    vam_class                                    varchar2(30 char)                   not null,
    vam_sequence                                 number                              not null,
    vam_group                                    varchar2(30 char)                   not null,
    vam_type                                     varchar2(30 char)                   not null,
    vam_filter                                   varchar2(30 char)                   not null,
    vam_rule                                     varchar2(30 char)                   not null,
    vam_text                                     varchar2(4000 char)                 not null,
    vam_version                                  number                              not null,
    vam_emailed                                  number                              not null,
    vam_search01                                 varchar2(256 char)                  null,
    vam_search02                                 varchar2(256 char)                  null,
    vam_search03                                 varchar2(256 char)                  null,
    vam_search04                                 varchar2(256 char)                  null,
    vam_search05                                 varchar2(256 char)                  null,
    vam_search06                                 varchar2(256 char)                  null,
    vam_search07                                 varchar2(256 char)                  null,
    vam_search08                                 varchar2(256 char)                  null,
    vam_search09                                 varchar2(256 char)                  null);

/**/
/* Comments
/**/
comment on table sap_val_mes is 'SAP Validation Message';
comment on column sap_val_mes.vam_execution is 'Validation execution identifier (*SINGLE or GROUP_BATCH_YYYYMMDDHHMISS)';
comment on column sap_val_mes.vam_code is 'Validation code (eg. material code, customer code, etc.)';
comment on column sap_val_mes.vam_class is 'Validation classification identifier';
comment on column sap_val_mes.vam_sequence is 'Validation message sequence';
comment on column sap_val_mes.vam_group is 'Validation message group identifier';
comment on column sap_val_mes.vam_type is 'Validation message type identifier';
comment on column sap_val_mes.vam_filter is 'Validation message filter identifier';
comment on column sap_val_mes.vam_rule is 'Validation message rule identifier';
comment on column sap_val_mes.vam_text is 'Validation message text';
comment on column sap_val_mes.vam_version is 'Validation message version - 0(current), 1 to 99(historical)';
comment on column sap_val_mes.vam_emailed is 'Validation message emailed count';
comment on column sap_val_mes.vam_search01 is 'Validation message search 01';
comment on column sap_val_mes.vam_search02 is 'Validation message search 02';
comment on column sap_val_mes.vam_search03 is 'Validation message search 03';
comment on column sap_val_mes.vam_search04 is 'Validation message search 04';
comment on column sap_val_mes.vam_search05 is 'Validation message search 05';
comment on column sap_val_mes.vam_search06 is 'Validation message search 06';
comment on column sap_val_mes.vam_search07 is 'Validation message search 07';
comment on column sap_val_mes.vam_search08 is 'Validation message search 08';
comment on column sap_val_mes.vam_search09 is 'Validation message search 09';

/**/
/* Primary Key Constraint
/**/
alter table sap_val_mes
   add constraint sap_val_mes_pk primary key (vam_execution, vam_code, vam_class, vam_sequence);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_val_mes to lads_app;
grant select on sap_val_mes to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_val_mes for lads.sap_val_mes;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_interface
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2006/08   Steve Gregan   Added int_search column
 2008/11   Steve Gregan   Added user invocation columns (CHINA INTERFACE LOADER)
 2011/02   Steve Gregan   End point architecture version

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_interface
   (int_interface                varchar2(32 char)               not null,
    int_description              varchar2(128 char)              not null,
    int_type                     varchar2(10 char)               not null,
    int_group                    varchar2(10 char)               not null,
    int_priority                 number(2,0)                     not null,
    int_hdr_history              number(5,0)                     not null,
    int_dta_history              number(5,0)                     not null,
    int_fil_path                 varchar2(128 char)              not null,
    int_fil_prefix               varchar2(10 char)               null,
    int_fil_sequence             number(2,0)                     null,
    int_fil_extension            varchar2(10 char)               null,
    int_opr_alert                varchar2(256 char)              null,
    int_ema_group                varchar2(64 char)               null,
    int_search                   varchar2(256 char)              null,
    int_procedure                varchar2(256 char)              not null,
    int_status                   varchar2(1 char)                not null,
    int_usr_invocation           varchar2(1 char)                null,
    int_usr_validation           varchar2(256 char)              null,
    int_usr_message              varchar2(64 char)               null,
    int_lod_type                 varchar2(10 char)               not null,
    int_lod_group                varchar2(10 char)               not null);

/**/
/* Comments
/**/
comment on table lics_interface is 'LICS Interface Table';
comment on column lics_interface.int_interface is 'Interface - interface identifier';
comment on column lics_interface.int_description is 'Interface - interface description';
comment on column lics_interface.int_type is 'Interface - interface type';
comment on column lics_interface.int_group is 'Interface - interface group';
comment on column lics_interface.int_priority is 'Interface - processing priority';
comment on column lics_interface.int_hdr_history is 'Interface - header history to retain (days)';
comment on column lics_interface.int_dta_history is 'Interface - data history to retain (days)';
comment on column lics_interface.int_fil_path is 'Interface - file path';
comment on column lics_interface.int_fil_prefix is 'Interface - file prefix';
comment on column lics_interface.int_fil_sequence is 'Interface - file sequence length';
comment on column lics_interface.int_fil_extension is 'Interface - file extension';
comment on column lics_interface.int_opr_alert is 'Interface - operator alert message';
comment on column lics_interface.int_ema_group is 'Interface - email group';
comment on column lics_interface.int_search is 'Interface - search procedure';
comment on column lics_interface.int_procedure is 'Interface - processing procedure';
comment on column lics_interface.int_status is 'Interface - interface status';
comment on column lics_interface.int_usr_invocation is 'Interface - user invocation indicator (0=No or 1=Yes)';
comment on column lics_interface.int_usr_validation is 'Interface - user invocation validation procedure';
comment on column lics_interface.int_usr_message is 'Interface - user invocation message name (*OUTBOUND only)';
comment on column lics_interface.int_lod_type is 'Interface - interface load type (*NONE=outbound interfaces, *PUSH=load pushing, *POLL=load polling)';
comment on column lics_interface.int_lod_group is 'Interface - interface load group (*NONE=load type *PUSH or *NONE, group=load type *POLL)';

/**/
/* Primary Key Constraint
/**/
alter table lics_interface
   add constraint lics_interface_pk primary key (int_interface);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_interface to lics_app;
grant select on lics_interface to lics_exec;

/**/
/* Synonym
/**/
create or replace public synonym lics_interface for lics.lics_interface;
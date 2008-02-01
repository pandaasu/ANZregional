/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_triggered
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_triggered

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/06   Steve Gregan   Added group

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_triggered
   (tri_sequence                 number(15,0)                    not null,
    tri_group                    varchar2(10 char)               not null,
    tri_function                 varchar2(128 char)              not null,
    tri_procedure                varchar2(512 char)              not null,
    tri_timestamp                date                            not null,
    tri_opr_alert                varchar2(256 char)              null,
    tri_ema_group                varchar2(64 char)               null);

/**/
/* Comments
/**/
comment on table lics_triggered is 'LICS Triggered Table';
comment on column lics_triggered.tri_sequence is 'Triggered - trigger sequence number (sequence generated)';
comment on column lics_triggered.tri_group is 'Triggered - trigger group';
comment on column lics_triggered.tri_function is 'Triggered - trigger function';
comment on column lics_triggered.tri_procedure is 'Triggered - execution procedure';
comment on column lics_triggered.tri_timestamp is 'Triggered - creation time';
comment on column lics_triggered.tri_opr_alert is 'Triggered - operator alert message';
comment on column lics_triggered.tri_ema_group is 'Triggered - email group';

/**/
/* Primary Key Constraint
/**/
alter table lics_triggered
   add constraint lics_triggered_pk primary key (tri_sequence);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_triggered to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_triggered for lics.lics_triggered;

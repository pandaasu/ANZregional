/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_event
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_event

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_event
   (eve_sequence                 number(15,0)                    not null,
    eve_time                     date                            not null,
    eve_result                   varchar2(10 char)               not null,
    eve_job                      varchar2(32 char)               not null,
    eve_execution                number(15,0)                    null,
    eve_type                     varchar2(10 char)               null,
    eve_group                    varchar2(10 char)               null,
    eve_procedure                varchar2(256 char)              null,
    eve_interface                varchar2(32 char)               null,
    eve_header                   number(15,0)                    null,
    eve_hdr_trace                number(5,0)                     null,
    eve_message                  varchar2(4000 char)             null,
    eve_opr_alert                varchar2(256 char)              null,
    eve_ema_group                varchar2(64 char)               null);

/**/
/* Comments
/**/
comment on table lics_event is 'LICS Event Table';
comment on column lics_event.eve_sequence is 'Event - event sequence number (sequence generated)';
comment on column lics_event.eve_time is 'Event - event time';
comment on column lics_event.eve_result is 'Event - event result';
comment on column lics_event.eve_job is 'Event - job identifier';
comment on column lics_event.eve_execution is 'Event - job execution number';
comment on column lics_event.eve_type is 'Event - job type';
comment on column lics_event.eve_group is 'Event - interface group';
comment on column lics_event.eve_procedure is 'Event - job procedure';
comment on column lics_event.eve_interface is 'Event - interface identifier';
comment on column lics_event.eve_header is 'Event - header sequence number';
comment on column lics_event.eve_hdr_trace is 'Event - header trace sequence number';
comment on column lics_event.eve_message is 'Event - message text';
comment on column lics_event.eve_opr_alert is 'Event - operator alert message';
comment on column lics_event.eve_ema_group is 'Event - email group';

/**/
/* Primary Key Constraint
/**/
alter table lics_event
   add constraint lics_event_pk primary key (eve_sequence);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_event to lics_app;

/**/
/* Synonym
/**/
create public synonym lics_event for lics.lics_event;

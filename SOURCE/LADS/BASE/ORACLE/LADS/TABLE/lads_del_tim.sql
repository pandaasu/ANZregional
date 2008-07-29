/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_tim
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_tim

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_tim
   (vbeln                                        varchar2(10 char)                   not null,
    timseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    vstzw                                        varchar2(4 char)                    null,
    vstzw_bez                                    varchar2(20 char)                   null,
    ntanf                                        varchar2(8 char)                    null,
    ntanz                                        varchar2(6 char)                    null,
    ntend                                        varchar2(8 char)                    null,
    ntenz                                        varchar2(6 char)                    null,
    tzone_beg                                    varchar2(6 char)                    null,
    isdd                                         varchar2(8 char)                    null,
    isdz                                         varchar2(6 char)                    null,
    iedd                                         varchar2(8 char)                    null,
    iedz                                         varchar2(6 char)                    null,
    tzone_end                                    varchar2(6 char)                    null,
    vornr                                        varchar2(4 char)                    null,
    vstga                                        varchar2(4 char)                    null,
    vstga_bez                                    varchar2(20 char)                   null,
    event                                        varchar2(10 char)                   null,
    event_ali                                    varchar2(20 char)                   null,
    qualf1                                       varchar2(3 char)                    null,
    vdatu                                        varchar2(8 char)                    null);

/**/
/* Comments
/**/
comment on table lads_del_tim is 'LADS Delivery Time';
comment on column lads_del_tim.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_tim.timseq is 'TIM - generated sequence number';
comment on column lads_del_tim.qualf is 'IDOC Qualifier: Date (Delivery)';
comment on column lads_del_tim.vstzw is 'Deadline function';
comment on column lads_del_tim.vstzw_bez is 'Description';
comment on column lads_del_tim.ntanf is 'Constraint for Start of Activity (Basic)';
comment on column lads_del_tim.ntanz is 'Constraint for activity start time (Basic)';
comment on column lads_del_tim.ntend is 'Constraint for finish of activity (Basic)';
comment on column lads_del_tim.ntenz is 'Basic finish time of the activity';
comment on column lads_del_tim.tzone_beg is 'Time zone';
comment on column lads_del_tim.isdd is 'Actual start: Execution (date)';
comment on column lads_del_tim.isdz is 'Actual start: Execution/setup (time)';
comment on column lads_del_tim.iedd is 'Actual finish: Execution (date)';
comment on column lads_del_tim.iedz is 'Actual finish: Execution (time)';
comment on column lads_del_tim.tzone_end is 'Time zone';
comment on column lads_del_tim.vornr is 'Operation Number';
comment on column lads_del_tim.vstga is 'Deadline deviation reason';
comment on column lads_del_tim.vstga_bez is 'Description';
comment on column lads_del_tim.event is 'Event type';
comment on column lads_del_tim.event_ali is 'Alias for the transaction (language-independent)';
comment on column lads_del_tim.qualf1 is 'IDOC Qualifier: Date (Delivery)';
comment on column lads_del_tim.vdatu is 'Requested delivery date';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_tim
   add constraint lads_del_tim_pk primary key (vbeln, timseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_tim to lads_app;
grant select, insert, update, delete on lads_del_tim to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_tim for lads.lads_del_tim;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_tim
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_tim

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_tim
   (zzgrpnr                                      varchar2(40 char)                   not null,
    delseq                                       number                              not null,
    hdeseq                                       number                              not null,
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
    event_ali                                    varchar2(20 char)                   null);


/**/
/* Comments
/**/
comment on table lads_exp_tim is 'Generic ICB Document - Delivery data';
comment on column lads_exp_tim.qualf is 'IDOC Qualifier: Date (Delivery)';
comment on column lads_exp_tim.vstzw is 'Deadline function';
comment on column lads_exp_tim.vstzw_bez is 'Description';
comment on column lads_exp_tim.ntanf is 'Constraint for Start of Activity (Basic)';
comment on column lads_exp_tim.ntanz is 'Constraint for activity start time (Basic)';
comment on column lads_exp_tim.ntend is 'Constraint for finish of activity (Basic)';
comment on column lads_exp_tim.ntenz is 'Basic finish time of the activity';
comment on column lads_exp_tim.tzone_beg is 'Time zone';
comment on column lads_exp_tim.isdd is 'Actual start: Execution (date)';
comment on column lads_exp_tim.isdz is 'Actual start: Execution/setup (time)';
comment on column lads_exp_tim.iedd is 'Actual finish: Execution (date)';
comment on column lads_exp_tim.iedz is 'Actual finish: Execution (time)';
comment on column lads_exp_tim.tzone_end is 'Time zone';
comment on column lads_exp_tim.vornr is 'Operation Number';
comment on column lads_exp_tim.vstga is 'Deadline deviation reason';
comment on column lads_exp_tim.vstga_bez is 'Description';
comment on column lads_exp_tim.event is 'Event type';
comment on column lads_exp_tim.event_ali is 'Alias for the transaction (language-independent)';



/**/
/* Primary Key Constraint
/**/
alter table lads_exp_tim
   add constraint lads_exp_tim_pk primary key (zzgrpnr, delseq, hdeseq, timseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_tim to lads_app;
grant select, insert, update, delete on lads_exp_tim to ics_app;
grant select on lads_exp_tim to ics_reader with grant option;
grant select on lads_exp_tim to ics_executor;
grant select on lads_exp_tim to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_tim for lads.lads_exp_tim;

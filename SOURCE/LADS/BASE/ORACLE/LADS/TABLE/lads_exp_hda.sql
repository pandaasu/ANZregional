/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_hda
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_hda

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_hda
   (zzgrpnr                                      varchar2(40 char)                   not null,
    shpseq                                       number                              not null,
    hshseq                                       number                              not null,
    hdaseq                                       number                              not null,
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
comment on table lads_exp_hda is 'Generic ICB Document - Shipment data';
comment on column lads_exp_hda.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_hda.shpseq is 'SHP - generated sequence number';
comment on column lads_exp_hda.hshseq is 'HSH - generated sequence number';
comment on column lads_exp_hda.hdaseq is 'HDA - generated sequence number';
comment on column lads_exp_hda.qualf is 'IDOC Qualifier: Date (Shipment)';
comment on column lads_exp_hda.vstzw is 'Deadline function';
comment on column lads_exp_hda.vstzw_bez is 'Description';
comment on column lads_exp_hda.ntanf is 'Constraint for Start of Activity (Basic)';
comment on column lads_exp_hda.ntanz is 'Constraint for activity start time (Basic)';
comment on column lads_exp_hda.ntend is 'Constraint for finish of activity (Basic)';
comment on column lads_exp_hda.ntenz is 'Basic finish time of the activity';
comment on column lads_exp_hda.tzone_beg is 'Time zone';
comment on column lads_exp_hda.isdd is 'Actual start: Execution (date)';
comment on column lads_exp_hda.isdz is 'Actual start: Execution/setup (time)';
comment on column lads_exp_hda.iedd is 'Actual finish: Execution (date)';
comment on column lads_exp_hda.iedz is 'Actual finish: Execution (time)';
comment on column lads_exp_hda.tzone_end is 'Time zone';
comment on column lads_exp_hda.vornr is 'Operation Number';
comment on column lads_exp_hda.vstga is 'Deadline deviation reason';
comment on column lads_exp_hda.vstga_bez is 'Description';
comment on column lads_exp_hda.event is 'Event type';
comment on column lads_exp_hda.event_ali is 'Alias for the transaction (language-independent)';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_hda
   add constraint lads_exp_hda_pk primary key (zzgrpnr, shpseq, hshseq, hdaseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_hda to lads_app;
grant select, insert, update, delete on lads_exp_hda to ics_app;
grant select on lads_exp_hda to ics_reader with grant option;
grant select on lads_exp_hda to ics_executor;
grant select on lads_exp_hda to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_hda for lads.lads_exp_hda;

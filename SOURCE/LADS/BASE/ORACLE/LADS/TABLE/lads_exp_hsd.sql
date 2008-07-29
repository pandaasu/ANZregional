/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_hsd
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_hsd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_hsd
   (zzgrpnr                                      varchar2(40 char)                   not null,
    shpseq                                       number                              not null,
    hshseq                                       number                              not null,
    hstseq                                       number                              not null,
    hsdseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    ntanf                                        varchar2(8 char)                    null,
    ntanz                                        varchar2(6 char)                    null,
    ntend                                        varchar2(8 char)                    null,
    ntenz                                        varchar2(6 char)                    null,
    isdd                                         varchar2(8 char)                    null,
    isdz                                         varchar2(6 char)                    null,
    iedd                                         varchar2(8 char)                    null,
    iedz                                         varchar2(6 char)                    null,
    vornr                                        varchar2(4 char)                    null,
    vstga                                        varchar2(4 char)                    null);

/**/
/* Comments
/**/
comment on table lads_exp_hsd is 'Generic ICB Document - Shipment data';
comment on column lads_exp_hsd.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_hsd.shpseq is 'SHP - generated sequence number';
comment on column lads_exp_hsd.hshseq is 'HSH - generated sequence number';
comment on column lads_exp_hsd.hstseq is 'HST - generated sequence number';
comment on column lads_exp_hsd.hsdseq is 'HSD - generated sequence number';
comment on column lads_exp_hsd.qualf is 'IDOC Qualifier: Date (Shipment Stage)';
comment on column lads_exp_hsd.ntanf is 'Constraint for Start of Activity (Basic)';
comment on column lads_exp_hsd.ntanz is 'Constraint for activity start time (Basic)';
comment on column lads_exp_hsd.ntend is 'Constraint for finish of activity (Basic)';
comment on column lads_exp_hsd.ntenz is 'Basic finish time of the activity';
comment on column lads_exp_hsd.isdd is 'Actual start: Execution (date)';
comment on column lads_exp_hsd.isdz is 'Actual start: Execution/setup (time)';
comment on column lads_exp_hsd.iedd is 'Actual finish: Execution (date)';
comment on column lads_exp_hsd.iedz is 'Actual finish: Execution (time)';
comment on column lads_exp_hsd.vornr is 'Operation Number';
comment on column lads_exp_hsd.vstga is 'Deadline deviation reason';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_hsd
   add constraint lads_exp_hsd_pk primary key (zzgrpnr, shpseq, hshseq, hstseq, hsdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_hsd to lads_app;
grant select, insert, update, delete on lads_exp_hsd to ics_app;
grant select on lads_exp_hsd to ics_reader with grant option;
grant select on lads_exp_hsd to ics_executor;
grant select on lads_exp_hsd to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_hsd for lads.lads_exp_hsd;

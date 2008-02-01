/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_ded
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_ded

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_ded
   (tknum                                        varchar2(10 char)                   not null,
    dlvseq                                       number                              not null,
    dedseq                                       number                              not null,
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
    knote                                        varchar2(10 char)                   null,
    knote_bez                                    varchar2(30 char)                   null);

/**/
/* Comments
/**/
comment on table lads_shp_ded is 'LADS Shipment Deadline';
comment on column lads_shp_ded.tknum is 'Shipment Number';
comment on column lads_shp_ded.dlvseq is 'DLV - generated sequence number';
comment on column lads_shp_ded.dedseq is 'DED - generated sequence number';
comment on column lads_shp_ded.qualf is 'IDOC Qualifier: Date (Delivery)';
comment on column lads_shp_ded.vstzw is 'Deadline function';
comment on column lads_shp_ded.vstzw_bez is 'Description';
comment on column lads_shp_ded.ntanf is 'Constraint for Start of Activity (Basic)';
comment on column lads_shp_ded.ntanz is 'Constraint for activity start time (Basic)';
comment on column lads_shp_ded.ntend is 'Constraint for finish of activity (Basic)';
comment on column lads_shp_ded.ntenz is 'Basic finish time of the activity';
comment on column lads_shp_ded.tzone_beg is 'Time zone';
comment on column lads_shp_ded.isdd is 'Actual start: Execution (date)';
comment on column lads_shp_ded.isdz is 'Actual start: Execution/setup (time)';
comment on column lads_shp_ded.iedd is 'Actual finish: Execution (date)';
comment on column lads_shp_ded.iedz is 'Actual finish: Execution (time)';
comment on column lads_shp_ded.tzone_end is 'Time zone';
comment on column lads_shp_ded.vornr is 'Operation Number';
comment on column lads_shp_ded.vstga is 'Deadline deviation reason';
comment on column lads_shp_ded.vstga_bez is 'Description';
comment on column lads_shp_ded.event is 'Event type';
comment on column lads_shp_ded.event_ali is 'Alias for the transaction (language-independent)';
comment on column lads_shp_ded.knote is 'Transportation Connection Points';
comment on column lads_shp_ded.knote_bez is 'Node name';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_ded
   add constraint lads_shp_ded_pk primary key (tknum, dlvseq, dedseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_ded to lads_app;
grant select, insert, update, delete on lads_shp_ded to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_ded for lads.lads_shp_ded;

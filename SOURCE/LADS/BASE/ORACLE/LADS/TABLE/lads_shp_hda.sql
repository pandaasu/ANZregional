/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_hda
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_hda

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_hda
   (tknum                                        varchar2(10 char)                   not null,
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
    event_ali                                    varchar2(20 char)                   null,
    knote                                        varchar2(10 char)                   null,
    knote_bez                                    varchar2(30 char)                   null);

/**/
/* Comments
/**/
comment on table lads_shp_hda is 'LADS Shipment Date';
comment on column lads_shp_hda.tknum is 'Shipment Number';
comment on column lads_shp_hda.hdaseq is 'HDA - generated sequence number';
comment on column lads_shp_hda.qualf is 'IDOC Qualifier: Date (Shipment)';
comment on column lads_shp_hda.vstzw is 'Deadline function';
comment on column lads_shp_hda.vstzw_bez is 'Description';
comment on column lads_shp_hda.ntanf is 'Constraint for Start of Activity (Basic)';
comment on column lads_shp_hda.ntanz is 'Constraint for activity start time (Basic)';
comment on column lads_shp_hda.ntend is 'Constraint for finish of activity (Basic)';
comment on column lads_shp_hda.ntenz is 'Basic finish time of the activity';
comment on column lads_shp_hda.tzone_beg is 'Time zone';
comment on column lads_shp_hda.isdd is 'Actual start: Execution (date)';
comment on column lads_shp_hda.isdz is 'Actual start: Execution/setup (time)';
comment on column lads_shp_hda.iedd is 'Actual finish: Execution (date)';
comment on column lads_shp_hda.iedz is 'Actual finish: Execution (time)';
comment on column lads_shp_hda.tzone_end is 'Time zone';
comment on column lads_shp_hda.vornr is 'Operation Number';
comment on column lads_shp_hda.vstga is 'Deadline deviation reason';
comment on column lads_shp_hda.vstga_bez is 'Description';
comment on column lads_shp_hda.event is 'Event type';
comment on column lads_shp_hda.event_ali is 'Alias for the transaction (language-independent)';
comment on column lads_shp_hda.knote is 'Transportation Connection Points';
comment on column lads_shp_hda.knote_bez is 'Node name';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_hda
   add constraint lads_shp_hda_pk primary key (tknum, hdaseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_hda to lads_app;
grant select, insert, update, delete on lads_shp_hda to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_hda for lads.lads_shp_hda;

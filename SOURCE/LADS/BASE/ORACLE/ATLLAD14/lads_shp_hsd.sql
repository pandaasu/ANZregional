/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_hsd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_hsd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_hsd
   (tknum                                        varchar2(10 char)                   not null,
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
comment on table lads_shp_hsd is 'LADS Shipment Stage Date';
comment on column lads_shp_hsd.tknum is 'Shipment Number';
comment on column lads_shp_hsd.hstseq is 'HST - generated sequence number';
comment on column lads_shp_hsd.hsdseq is 'HSD - generated sequence number';
comment on column lads_shp_hsd.qualf is 'IDOC Qualifier: Date (Shipment Stage)';
comment on column lads_shp_hsd.ntanf is 'Constraint for Start of Activity (Basic)';
comment on column lads_shp_hsd.ntanz is 'Constraint for activity start time (Basic)';
comment on column lads_shp_hsd.ntend is 'Constraint for finish of activity (Basic)';
comment on column lads_shp_hsd.ntenz is 'Basic finish time of the activity';
comment on column lads_shp_hsd.isdd is 'Actual start: Execution (date)';
comment on column lads_shp_hsd.isdz is 'Actual start: Execution/setup (time)';
comment on column lads_shp_hsd.iedd is 'Actual finish: Execution (date)';
comment on column lads_shp_hsd.iedz is 'Actual finish: Execution (time)';
comment on column lads_shp_hsd.vornr is 'Operation Number';
comment on column lads_shp_hsd.vstga is 'Deadline deviation reason';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_hsd
   add constraint lads_shp_hsd_pk primary key (tknum, hstseq, hsdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_hsd to lads_app;
grant select, insert, update, delete on lads_shp_hsd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_hsd for lads.lads_shp_hsd;

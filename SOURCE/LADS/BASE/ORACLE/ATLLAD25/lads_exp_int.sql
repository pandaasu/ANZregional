/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_int
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_int

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_int
   (zzgrpnr                                      varchar2(40 char)                   not null,
    delseq                                       number                              not null,
    hdeseq                                       number                              not null,
    detseq                                       number                              not null,
    intseq                                       number                              not null,
    atinn                                        number                              null,
    atnam                                        varchar2(30 char)                   null,
    atbez                                        varchar2(30 char)                   null,
    atwrt                                        varchar2(30 char)                   null,
    atwtb                                        varchar2(30 char)                   null,
    ewahr                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_exp_int is 'Generic ICB Document - Delivery data';
comment on column lads_exp_int.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_int.delseq is 'DEL - generated sequence number';
comment on column lads_exp_int.hdeseq is 'HDE - generated sequence number';
comment on column lads_exp_int.detseq is 'DET - generated sequence number';
comment on column lads_exp_int.intseq is 'INT - generated sequence number';
comment on column lads_exp_int.atinn is 'Internal characteristic';
comment on column lads_exp_int.atnam is 'Characteristic Name';
comment on column lads_exp_int.atbez is 'Characteristic description';
comment on column lads_exp_int.atwrt is 'Characteristic Value';
comment on column lads_exp_int.atwtb is 'Characteristic value description';
comment on column lads_exp_int.ewahr is 'Tolerance from';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_int
   add constraint lads_exp_int_pk primary key (zzgrpnr, delseq, hdeseq, detseq, intseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_int to lads_app;
grant select, insert, update, delete on lads_exp_int to ics_app;
grant select on lads_exp_int to ics_reader with grant option;
grant select on lads_exp_int to ics_executor;
grant select on lads_exp_int to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_int for lads.lads_exp_int;

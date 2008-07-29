/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_sin
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_sin

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_sin
   (zzgrpnr                                      varchar2(40 char)                   not null,
    invseq                                       number                              not null,
    hinseq                                       number                              not null,
    sinseq                                       number                              not null,
    sumid                                        varchar2(3 char)                    null,
    summe                                        varchar2(18 char)                   null,
    sunit                                        varchar2(3 char)                    null,
    waerq                                        varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table lads_exp_sin is 'Generic ICB Document - Invoice data';
comment on column lads_exp_sin.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_sin.invseq is 'INV - generated sequence number';
comment on column lads_exp_sin.hinseq is 'HIN - generated sequence number';
comment on column lads_exp_sin.sinseq is 'SIN - generated sequence number';
comment on column lads_exp_sin.sumid is 'Qualifier for totals segment for shipping notification';
comment on column lads_exp_sin.summe is 'Total value of sum segment';
comment on column lads_exp_sin.sunit is 'Total value unit for totals segment in the shipping notif.';
comment on column lads_exp_sin.waerq is 'Currency';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_sin
   add constraint lads_exp_sin_pk primary key (zzgrpnr, invseq, hinseq, sinseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_sin to lads_app;
grant select, insert, update, delete on lads_exp_sin to ics_app;
grant select on lads_exp_sin to ics_reader with grant option;
grant select on lads_exp_sin to ics_executor;
grant select on lads_exp_sin to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_sin for lads.lads_exp_sin;

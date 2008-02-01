/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_dat
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_dat

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_dat
   (zzgrpnr                                      varchar2(40 char)                   not null,
    ordseq                                       number                              not null,
    horseq                                       number                              not null,
    datseq                                       number                              not null,
    iddat                                        varchar2(3 char)                    null,
    datum                                        varchar2(8 char)                    null,
    uzeit                                        varchar2(6 char)                    null);

/**/
/* Comments
/**/
comment on table lads_exp_dat is 'Generic ICB Document - Order data';
comment on column lads_exp_dat.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_dat.ordseq is 'ORD - generated sequence number';
comment on column lads_exp_dat.horseq is 'HOR - generated sequence number';
comment on column lads_exp_dat.datseq is 'DAT - generated sequence number';
comment on column lads_exp_dat.iddat is 'Qualifier for IDOC date segment';
comment on column lads_exp_dat.datum is 'IDOC: Date';
comment on column lads_exp_dat.uzeit is 'IDOC: Time';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_dat
   add constraint lads_exp_dat_pk primary key (zzgrpnr, ordseq, horseq, datseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_dat to lads_app;
grant select, insert, update, delete on lads_exp_dat to ics_app;
grant select on lads_exp_dat to ics_reader with grant option;
grant select on lads_exp_dat to ics_executor;
grant select on lads_exp_dat to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_dat for lads.lads_exp_dat;

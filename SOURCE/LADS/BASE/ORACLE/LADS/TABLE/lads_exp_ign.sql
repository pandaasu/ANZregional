/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_ign
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_ign

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_ign
   (zzgrpnr                                      varchar2(40 char)                   not null,
    invseq                                       number                              not null,
    hinseq                                       number                              not null,
    ignseq                                       number                              not null,
    posex                                        varchar2(6 char)                    null,
    menge                                        varchar2(15 char)                   null,
    menee                                        varchar2(3 char)                    null,
    ntgew                                        varchar2(18 char)                   null,
    gewei                                        varchar2(3 char)                    null,
    brgew                                        varchar2(18 char)                   null,
    pstyv                                        varchar2(4 char)                    null,
    werks                                        varchar2(4 char)                    null);

/**/
/* Comments
/**/
comment on table lads_exp_ign is 'Generic ICB Document - Invoice data';
comment on column lads_exp_ign.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_ign.invseq is 'INV - generated sequence number';
comment on column lads_exp_ign.hinseq is 'HIN - generated sequence number';
comment on column lads_exp_ign.ignseq is 'IGN - generated sequence number';
comment on column lads_exp_ign.posex is 'Item number';
comment on column lads_exp_ign.menge is 'Quantity';
comment on column lads_exp_ign.menee is 'Unit of measure';
comment on column lads_exp_ign.ntgew is 'Net weight';
comment on column lads_exp_ign.gewei is 'Weight unit';
comment on column lads_exp_ign.brgew is 'Total weight';
comment on column lads_exp_ign.pstyv is 'Sales document item category';
comment on column lads_exp_ign.werks is 'Plant';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_ign
   add constraint lads_exp_ign_pk primary key (zzgrpnr, invseq, hinseq, ignseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_ign to lads_app;
grant select, insert, update, delete on lads_exp_ign to ics_app;
grant select on lads_exp_ign to ics_reader with grant option;
grant select on lads_exp_ign to ics_executor;
grant select on lads_exp_ign to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_ign for lads.lads_exp_ign;

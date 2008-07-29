/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_sor
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_sor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_sor
   (zzgrpnr                                      varchar2(40 char)                   not null,
    ordseq                                       number                              not null,
    horseq                                       number                              not null,
    sorseq                                       number                              not null,
    sumid                                        varchar2(3 char)                    null,
    summe                                        varchar2(18 char)                   null,
    sunit                                        varchar2(3 char)                    null,
    waerq                                        varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table lads_exp_sor is 'Generic ICB Document - Order data';
comment on column lads_exp_sor.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_sor.ordseq is 'ORD - generated sequence number';
comment on column lads_exp_sor.horseq is 'HOR - generated sequence number';
comment on column lads_exp_sor.sorseq is 'SOR - generated sequence number';
comment on column lads_exp_sor.sumid is 'Qualifier for totals segment for shipping notification';
comment on column lads_exp_sor.summe is 'Total value of sum segment';
comment on column lads_exp_sor.sunit is 'Total value unit for totals segment in the shipping notif.';
comment on column lads_exp_sor.waerq is 'Currency';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_sor
   add constraint lads_exp_sor_pk primary key (zzgrpnr, ordseq, horseq, sorseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_sor to lads_app;
grant select, insert, update, delete on lads_exp_sor to ics_app;
grant select on lads_exp_sor to ics_reader with grant option;
grant select on lads_exp_sor to ics_executor;
grant select on lads_exp_sor to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_sor for lads.lads_exp_sor;

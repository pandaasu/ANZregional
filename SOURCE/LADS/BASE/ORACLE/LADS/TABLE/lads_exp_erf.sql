/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_erf
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_erf

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_erf
   (zzgrpnr                                      varchar2(40 char)                   not null,
    delseq                                       number                              not null,
    hdeseq                                       number                              not null,
    detseq                                       number                              not null,
    erfseq                                       number                              not null,
    quali                                        varchar2(3 char)                    null,
    bstnr                                        varchar2(35 char)                   null,
    bstdt                                        varchar2(8 char)                    null,
    bsark                                        varchar2(4 char)                    null,
    ihrez                                        varchar2(12 char)                   null,
    posex                                        varchar2(6 char)                    null);

/**/
/* Comments
/**/
comment on table lads_exp_erf is 'Generic ICB Document - Delivery data';
comment on column lads_exp_erf.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_erf.delseq is 'DEL - generated sequence number';
comment on column lads_exp_erf.hdeseq is 'HDE - generated sequence number';
comment on column lads_exp_erf.detseq is 'DET - generated sequence number';
comment on column lads_exp_erf.erfseq is 'ERF - generated sequence number';
comment on column lads_exp_erf.quali is 'Qualifier for Reference Data of Ordering Party';
comment on column lads_exp_erf.bstnr is 'Customer purchase order number';
comment on column lads_exp_erf.bstdt is 'Customer purchase order date';
comment on column lads_exp_erf.bsark is 'Customer purchase order type';
comment on column lads_exp_erf.ihrez is 'Customer's or vendor's internal reference';
comment on column lads_exp_erf.posex is 'Item Number of the Underlying Purchase Order';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_erf
   add constraint lads_exp_erf_pk primary key (zzgrpnr, delseq, hdeseq, detseq, erfseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_erf to lads_app;
grant select, insert, update, delete on lads_exp_erf to ics_app;
grant select on lads_exp_erf to ics_reader with grant option;
grant select on lads_exp_erf to ics_executor;
grant select on lads_exp_erf to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_erf for lads.lads_exp_erf;

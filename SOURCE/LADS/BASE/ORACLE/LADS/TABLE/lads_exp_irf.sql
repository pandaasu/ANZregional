/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_irf
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_irf

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_irf
   (zzgrpnr                                      varchar2(40 char)                   not null,
    delseq                                       number                              not null,
    hdeseq                                       number                              not null,
    detseq                                       number                              not null,
    irfseq                                       number                              not null,
    qualf                                        varchar2(1 char)                    null,
    belnr                                        varchar2(35 char)                   null,
    posnr                                        varchar2(6 char)                    null,
    datum                                        varchar2(8 char)                    null,
    doctype                                      varchar2(4 char)                    null,
    reason                                       varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table lads_exp_irf is 'Generic ICB Document - Delivery data';
comment on column lads_exp_irf.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_irf.delseq is 'DEL - generated sequence number';
comment on column lads_exp_irf.hdeseq is 'HDE - generated sequence number';
comment on column lads_exp_irf.detseq is 'DET - generated sequence number';
comment on column lads_exp_irf.irfseq is 'IRF - generated sequence number';
comment on column lads_exp_irf.qualf is 'SD document category';
comment on column lads_exp_irf.belnr is 'IDOC document number';
comment on column lads_exp_irf.posnr is 'Item number';
comment on column lads_exp_irf.datum is 'IDOC: Date';
comment on column lads_exp_irf.doctype is 'Order type (Purchasing)';
comment on column lads_exp_irf.reason is 'Order reason (reason for the business transaction)';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_irf
   add constraint lads_exp_irf_pk primary key (zzgrpnr, delseq, hdeseq, detseq, irfseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_irf to lads_app;
grant select, insert, update, delete on lads_exp_irf to ics_app;
grant select on lads_exp_irf to ics_reader with grant option;
grant select on lads_exp_irf to ics_executor;
grant select on lads_exp_irf to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_irf for lads.lads_exp_irf;

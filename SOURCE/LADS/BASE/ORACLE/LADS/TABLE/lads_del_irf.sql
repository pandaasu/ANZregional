/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_irf
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_irf

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2008/08   Trevor Keon    Added lads_del_irf_ix01

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_irf
   (vbeln                                        varchar2(10 char)                   not null,
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
comment on table lads_del_irf is 'LADS Delivery Detail Internal Reference';
comment on column lads_del_irf.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_irf.detseq is 'DET - generated sequence number';
comment on column lads_del_irf.irfseq is 'IRF - generated sequence number';
comment on column lads_del_irf.qualf is 'SD document category';
comment on column lads_del_irf.belnr is 'IDOC document number';
comment on column lads_del_irf.posnr is 'Item number';
comment on column lads_del_irf.datum is 'IDOC: Date';
comment on column lads_del_irf.doctype is 'Order type (Purchasing)';
comment on column lads_del_irf.reason is 'Order reason (reason for the business transaction)';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_irf
   add constraint lads_del_irf_pk primary key (vbeln, detseq, irfseq);

/**/
/* Indexes
/**/
create index lads.lads_del_irf_ix01 on lads.lads_del_irf (belnr, posnr);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_irf to lads_app;
grant select, insert, update, delete on lads_del_irf to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_irf for lads.lads_del_irf;

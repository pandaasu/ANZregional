/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_hsi
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_hsi

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_hsi
   (zzgrpnr                                      varchar2(40 char)                   not null,
    shpseq                                       number                              not null,
    hshseq                                       number                              not null,
    hstseq                                       number                              not null,
    hsiseq                                       number                              not null,
    vbeln                                        varchar2(10 char)                   null,
    parid                                        varchar2(35 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_hsi is 'Generic ICB Document - Shipment data';
comment on column lads_exp_hsi.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_hsi.shpseq is 'SHP - generated sequence number';
comment on column lads_exp_hsi.hshseq is 'HSH - generated sequence number';
comment on column lads_exp_hsi.hstseq is 'HST - generated sequence number';
comment on column lads_exp_hsi.hsiseq is 'HSI - generated sequence number';
comment on column lads_exp_hsi.vbeln is 'Delivery';
comment on column lads_exp_hsi.parid is 'External partner number';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_hsi
   add constraint lads_exp_hsi_pk primary key (zzgrpnr, shpseq, hshseq, hstseq, hsiseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_hsi to lads_app;
grant select, insert, update, delete on lads_exp_hsi to ics_app;
grant select on lads_exp_hsi to ics_reader with grant option;
grant select on lads_exp_hsi to ics_executor;
grant select on lads_exp_hsi to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_hsi for lads.lads_exp_hsi;

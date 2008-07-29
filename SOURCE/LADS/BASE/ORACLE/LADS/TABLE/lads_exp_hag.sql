/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_hag
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_hag

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_hag
   (zzgrpnr                                      varchar2(40 char)                   not null,
    shpseq                                       number                              not null,
    hshseq                                       number                              not null,
    hstseq                                       number                              not null,
    hagseq                                       number                              not null,
    partner_q                                    varchar2(3 char)                    null,
    address_t                                    varchar2(1 char)                    null,
    partner_id                                   varchar2(17 char)                   null,
    jurisdic                                     varchar2(17 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_hag is 'Generic ICB Document - Shipment data';
comment on column lads_exp_hag.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_hag.shpseq is 'SHP - generated sequence number';
comment on column lads_exp_hag.hshseq is 'HSH - generated sequence number';
comment on column lads_exp_hag.hstseq is 'HST - generated sequence number';
comment on column lads_exp_hag.hagseq is 'HAG - generated sequence number';
comment on column lads_exp_hag.partner_q is 'Qualifier for partner function';
comment on column lads_exp_hag.address_t is 'Addr. type';
comment on column lads_exp_hag.partner_id is 'Partner no. (SAP)';
comment on column lads_exp_hag.jurisdic is 'Location for tax calculation - Tax Jurisdiction Code';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_hag
   add constraint lads_exp_hag_pk primary key (zzgrpnr, shpseq, hshseq, hstseq, hagseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_hag to lads_app;
grant select, insert, update, delete on lads_exp_hag to ics_app;
grant select on lads_exp_hag to ics_reader with grant option;
grant select on lads_exp_hag to ics_executor;
grant select on lads_exp_hag to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_hag for lads.lads_exp_hag;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_hsp
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_hsp

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_hsp
   (zzgrpnr                                      varchar2(40 char)                   not null,
    shpseq                                       number                              not null,
    hshseq                                       number                              not null,
    hstseq                                       number                              not null,
    hspseq                                       number                              not null,
    quali                                        varchar2(3 char)                    null,
    knote                                        varchar2(10 char)                   null,
    adrnr                                        varchar2(10 char)                   null,
    vstel                                        varchar2(4 char)                    null,
    lstel                                        varchar2(2 char)                    null,
    werks                                        varchar2(4 char)                    null,
    lgort                                        varchar2(4 char)                    null,
    kunnr                                        varchar2(10 char)                   null,
    lifnr                                        varchar2(10 char)                   null,
    ablad                                        varchar2(25 char)                   null,
    lgnum                                        varchar2(3 char)                    null,
    lgtor                                        varchar2(3 char)                    null,
    bahnra                                       varchar2(10 char)                   null,
    partner_q                                    varchar2(3 char)                    null,
    address_t                                    varchar2(1 char)                    null,
    partner_id                                   varchar2(17 char)                   null,
    jurisdic                                     varchar2(17 char)                   null,
    knote_bez                                    varchar2(30 char)                   null,
    vstel_bez                                    varchar2(30 char)                   null,
    lstel_bez                                    varchar2(20 char)                   null,
    werks_bez                                    varchar2(30 char)                   null,
    lgort_bez                                    varchar2(16 char)                   null,
    lgnum_bez                                    varchar2(25 char)                   null,
    lgtor_bez                                    varchar2(25 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_hsp is 'Generic ICB Document - Shipment data';
comment on column lads_exp_hsp.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_hsp.shpseq is 'SHP - generated sequence number';
comment on column lads_exp_hsp.hshseq is 'HSH - generated sequence number';
comment on column lads_exp_hsp.hstseq is 'HST - generated sequence number';
comment on column lads_exp_hsp.hspseq is 'HSP - generated sequence number';
comment on column lads_exp_hsp.quali is 'Qualifier for stage point';
comment on column lads_exp_hsp.knote is 'Transportation Connection Points';
comment on column lads_exp_hsp.adrnr is 'Address';
comment on column lads_exp_hsp.vstel is 'Shipping Point/Receiving Point';
comment on column lads_exp_hsp.lstel is 'Loading Point';
comment on column lads_exp_hsp.werks is 'EDI plant number for shipping unit';
comment on column lads_exp_hsp.lgort is 'Storage Location';
comment on column lads_exp_hsp.kunnr is 'Customer Number 1';
comment on column lads_exp_hsp.lifnr is 'Vendor number of destination point';
comment on column lads_exp_hsp.ablad is 'Unloading Point';
comment on column lads_exp_hsp.lgnum is 'Warehouse Number / Warehouse Complex';
comment on column lads_exp_hsp.lgtor is 'Door For Warehouse Number';
comment on column lads_exp_hsp.bahnra is 'TrainStnNumber';
comment on column lads_exp_hsp.partner_q is 'Qualifier for partner function';
comment on column lads_exp_hsp.address_t is 'Addr. type';
comment on column lads_exp_hsp.partner_id is 'Partner no. (SAP)';
comment on column lads_exp_hsp.jurisdic is 'Location for tax calculation - Tax Jurisdiction Code';
comment on column lads_exp_hsp.knote_bez is 'Node name';
comment on column lads_exp_hsp.vstel_bez is 'Description of shipping point';
comment on column lads_exp_hsp.lstel_bez is 'Loading point description';
comment on column lads_exp_hsp.werks_bez is 'Plant Descript.';
comment on column lads_exp_hsp.lgort_bez is 'Description of storage location';
comment on column lads_exp_hsp.lgnum_bez is 'Warehouse number description';
comment on column lads_exp_hsp.lgtor_bez is 'Door description';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_hsp
   add constraint lads_exp_hsp_pk primary key (zzgrpnr, shpseq, hshseq, hstseq, hspseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_hsp to lads_app;
grant select, insert, update, delete on lads_exp_hsp to ics_app;
grant select on lads_exp_hsp to ics_reader with grant option;
grant select on lads_exp_hsp to ics_executor;
grant select on lads_exp_hsp to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_hsp for lads.lads_exp_hsp;

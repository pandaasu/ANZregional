/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_huc
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_huc

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_huc
   (zzgrpnr                                      varchar2(40 char)                   not null,
    delseq                                       number                              not null,
    hdeseq                                       number                              not null,
    huhseq                                       number                              not null,
    hucseq                                       number                              not null,
    velin                                        varchar2(1 char)                    null,
    vbeln                                        varchar2(10 char)                   null,
    posnr                                        varchar2(6 char)                    null,
    exidv                                        varchar2(20 char)                   null,
    vemng                                        number                              null,
    vemeh                                        varchar2(3 char)                    null,
    matnr                                        varchar2(18 char)                   null,
    kdmat                                        varchar2(35 char)                   null,
    charg                                        varchar2(10 char)                   null,
    werks                                        varchar2(4 char)                    null,
    lgort                                        varchar2(4 char)                    null,
    cuobj                                        varchar2(18 char)                   null,
    bestq                                        varchar2(1 char)                    null,
    sobkz                                        varchar2(1 char)                    null,
    sonum                                        varchar2(16 char)                   null,
    anzsn                                        number                              null,
    wdatu                                        varchar2(8 char)                    null,
    parid                                        varchar2(35 char)                   null,
    matnr_external                               varchar2(40 char)                   null,
    matnr_version                                varchar2(10 char)                   null,
    matnr_guid                                   varchar2(32 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_huc is 'Generic ICB Document - Delivery data';
comment on column lads_exp_huc.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_huc.delseq is 'DEL - generated sequence number';
comment on column lads_exp_huc.hdeseq is 'HDE - generated sequence number';
comment on column lads_exp_huc.huhseq is 'HUH - generated sequence number';
comment on column lads_exp_huc.hucseq is 'HUC - generated sequence number';
comment on column lads_exp_huc.velin is 'Type of Handling-unit Item Content';
comment on column lads_exp_huc.vbeln is 'Sales and Distribution Document Number';
comment on column lads_exp_huc.posnr is 'Item number of the SD document';
comment on column lads_exp_huc.exidv is 'External Handling Unit Identification';
comment on column lads_exp_huc.vemng is 'Base Quantity Packed in the Handling Unit Item';
comment on column lads_exp_huc.vemeh is 'Base Unit of Measure of the Quantity to be Packed (VEMNG)';
comment on column lads_exp_huc.matnr is 'Material Number';
comment on column lads_exp_huc.kdmat is 'Material belonging to the customer';
comment on column lads_exp_huc.charg is 'Batch Number';
comment on column lads_exp_huc.werks is 'Plant';
comment on column lads_exp_huc.lgort is 'Storage Location';
comment on column lads_exp_huc.cuobj is 'Configuration (internal object number)';
comment on column lads_exp_huc.bestq is 'Stock Category in the Warehouse Management System';
comment on column lads_exp_huc.sobkz is 'Special Stock Indicator';
comment on column lads_exp_huc.sonum is 'Special Stock Number';
comment on column lads_exp_huc.anzsn is 'Number of serial numbers';
comment on column lads_exp_huc.wdatu is 'Date of Goods Receipt';
comment on column lads_exp_huc.parid is 'External partner number';
comment on column lads_exp_huc.matnr_external is 'Long material number (future development) for MATNR field';
comment on column lads_exp_huc.matnr_version is 'Version number (future development) for MATNR field';
comment on column lads_exp_huc.matnr_guid is 'External GUID (future development) for MATNR field';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_huc
   add constraint lads_exp_huc_pk primary key (zzgrpnr, delseq, hdeseq, huhseq, hucseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_huc to lads_app;
grant select, insert, update, delete on lads_exp_huc to ics_app;
grant select on lads_exp_huc to ics_reader with grant option;
grant select on lads_exp_huc to ics_executor;
grant select on lads_exp_huc to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_huc for lads.lads_exp_huc;

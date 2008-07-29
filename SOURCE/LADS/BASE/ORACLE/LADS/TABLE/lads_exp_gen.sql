/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_gen
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_gen

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_gen
   (zzgrpnr                                      varchar2(40 char)                   not null,
    ordseq                                       number                              not null,
    horseq                                       number                              not null,
    genseq                                       number                              not null,
    posex                                        varchar2(6 char)                    null,
    action                                       varchar2(3 char)                    null,
    pstyp                                        varchar2(1 char)                    null,
    kzabs                                        varchar2(1 char)                    null,
    menge                                        varchar2(15 char)                   null,
    menee                                        varchar2(3 char)                    null,
    bmng2                                        varchar2(15 char)                   null,
    pmene                                        varchar2(3 char)                    null,
    abftz                                        varchar2(7 char)                    null,
    vprei                                        varchar2(15 char)                   null,
    peinh                                        varchar2(9 char)                    null,
    netwr                                        varchar2(18 char)                   null,
    anetw                                        varchar2(18 char)                   null,
    skfbp                                        varchar2(18 char)                   null,
    ntgew                                        varchar2(18 char)                   null,
    gewei                                        varchar2(3 char)                    null,
    einkz                                        varchar2(1 char)                    null,
    curcy                                        varchar2(3 char)                    null,
    preis                                        varchar2(18 char)                   null,
    matkl                                        varchar2(9 char)                    null,
    uepos                                        varchar2(6 char)                    null,
    grkor                                        varchar2(3 char)                    null,
    evers                                        varchar2(7 char)                    null,
    bpumn                                        number                              null,
    bpumz                                        number                              null,
    abgru                                        varchar2(2 char)                    null,
    abgrt                                        varchar2(40 char)                   null,
    antlf                                        varchar2(1 char)                    null,
    fixmg                                        varchar2(1 char)                    null,
    kzazu                                        varchar2(1 char)                    null,
    brgew                                        varchar2(18 char)                   null,
    pstyv                                        varchar2(4 char)                    null,
    empst                                        varchar2(25 char)                   null,
    abtnr                                        varchar2(4 char)                    null,
    abrvw                                        varchar2(3 char)                    null,
    werks                                        varchar2(4 char)                    null,
    lprio                                        number                              null,
    lprio_bez                                    varchar2(20 char)                   null,
    route                                        varchar2(6 char)                    null,
    route_bez                                    varchar2(40 char)                   null,
    lgort                                        varchar2(4 char)                    null,
    vstel                                        varchar2(4 char)                    null,
    delco                                        varchar2(3 char)                    null,
    matnr                                        varchar2(35 char)                   null,
    valtg                                        number                              null,
    hipos                                        number                              null,
    hievw                                        varchar2(1 char)                    null,
    posguid                                      varchar2(22 char)                   null,
    zzact_qty                                    number                              null,
    zzdeluom                                     varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table lads_exp_gen is 'Generic ICB Document - Order data';
comment on column lads_exp_gen.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_gen.ordseq is 'ORD - generated sequence number';
comment on column lads_exp_gen.horseq is 'HOR - generated sequence number';
comment on column lads_exp_gen.genseq is 'GEN - generated sequence number';
comment on column lads_exp_gen.posex is 'Item number';
comment on column lads_exp_gen.action is 'Action code for the item';
comment on column lads_exp_gen.pstyp is 'Item Category';
comment on column lads_exp_gen.kzabs is 'Flag: order acknowledgment required';
comment on column lads_exp_gen.menge is 'Quantity';
comment on column lads_exp_gen.menee is 'Unit of measure';
comment on column lads_exp_gen.bmng2 is 'Quantity in price unit';
comment on column lads_exp_gen.pmene is 'Price unit of measure';
comment on column lads_exp_gen.abftz is 'Agreed cumulative quantity';
comment on column lads_exp_gen.vprei is 'Price (net)';
comment on column lads_exp_gen.peinh is 'Price unit';
comment on column lads_exp_gen.netwr is 'Item value (net)';
comment on column lads_exp_gen.anetw is 'Absolute net value of item';
comment on column lads_exp_gen.skfbp is 'Amount qualifying for cash discount';
comment on column lads_exp_gen.ntgew is 'Net weight';
comment on column lads_exp_gen.gewei is 'Weight unit';
comment on column lads_exp_gen.einkz is 'Flag: More than one schedule line for the item';
comment on column lads_exp_gen.curcy is 'Currency';
comment on column lads_exp_gen.preis is 'Gross price';
comment on column lads_exp_gen.matkl is 'IDOC material class';
comment on column lads_exp_gen.uepos is 'Higher-Level Item in BOM Structures';
comment on column lads_exp_gen.grkor is 'Delivery group (items delivered together)';
comment on column lads_exp_gen.evers is 'Shipping instructions';
comment on column lads_exp_gen.bpumn is 'Denominator for conv. of order price unit into order unit';
comment on column lads_exp_gen.bpumz is 'Numerator for conversion of order price unit into order unit';
comment on column lads_exp_gen.abgru is 'Reason for rejection of quotations and sales orders';
comment on column lads_exp_gen.abgrt is 'Description';
comment on column lads_exp_gen.antlf is 'Maximum number of partial deliveries allowed per item';
comment on column lads_exp_gen.fixmg is 'Delivery date and quantity fixed';
comment on column lads_exp_gen.kzazu is 'Order combination indicator';
comment on column lads_exp_gen.brgew is 'Total weight';
comment on column lads_exp_gen.pstyv is 'Sales document item category';
comment on column lads_exp_gen.empst is 'Receiving point';
comment on column lads_exp_gen.abtnr is 'Department number';
comment on column lads_exp_gen.abrvw is 'Usage indicator';
comment on column lads_exp_gen.werks is 'Plant';
comment on column lads_exp_gen.lprio is 'Delivery Priority';
comment on column lads_exp_gen.lprio_bez is 'Description';
comment on column lads_exp_gen.route is 'Route';
comment on column lads_exp_gen.route_bez is 'Description';
comment on column lads_exp_gen.lgort is 'Storage Location';
comment on column lads_exp_gen.vstel is 'Shipping Point/Receiving Point';
comment on column lads_exp_gen.delco is 'Agreed delivery time';
comment on column lads_exp_gen.matnr is 'IDOC material ID';
comment on column lads_exp_gen.valtg is 'Additional value days';
comment on column lads_exp_gen.hipos is 'Superior item in an item hierarchy';
comment on column lads_exp_gen.hievw is 'Use of Hierarchy Item';
comment on column lads_exp_gen.posguid is 'ATP: Encryption of DELNR and DELPS';
comment on column lads_exp_gen.zzact_qty is 'Actual quantity delivered (13.3)';
comment on column lads_exp_gen.zzdeluom is 'Unit of measure (3.0)';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_gen
   add constraint lads_exp_gen_pk primary key (zzgrpnr, ordseq, horseq, genseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_gen to lads_app;
grant select, insert, update, delete on lads_exp_gen to ics_app;
grant select on lads_exp_gen to ics_reader with grant option;
grant select on lads_exp_gen to ics_executor;
grant select on lads_exp_gen to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_gen for lads.lads_exp_gen;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sto_po_gen
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sto_po_gen

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sto_po_gen
   (belnr                                        varchar2(35 char)                   not null,
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
    posguid                                      varchar2(22 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sto_po_gen is 'LADS Stock Transfer and Purchase Order General';
comment on column lads_sto_po_gen.belnr is 'IDOC document number';
comment on column lads_sto_po_gen.genseq is 'GEN - generated sequence number';
comment on column lads_sto_po_gen.posex is 'Item number';
comment on column lads_sto_po_gen.action is 'Action code for the item';
comment on column lads_sto_po_gen.pstyp is 'Item Category';
comment on column lads_sto_po_gen.kzabs is 'Flag: order acknowledgment required';
comment on column lads_sto_po_gen.menge is 'Quantity';
comment on column lads_sto_po_gen.menee is 'Unit of measure';
comment on column lads_sto_po_gen.bmng2 is 'Quantity in price unit';
comment on column lads_sto_po_gen.pmene is 'Price unit of measure';
comment on column lads_sto_po_gen.abftz is 'Agreed cumulative quantity';
comment on column lads_sto_po_gen.vprei is 'Price (net)';
comment on column lads_sto_po_gen.peinh is 'Price unit';
comment on column lads_sto_po_gen.netwr is 'Item value (net)';
comment on column lads_sto_po_gen.anetw is 'Absolute net value of item';
comment on column lads_sto_po_gen.skfbp is 'Amount qualifying for cash discount';
comment on column lads_sto_po_gen.ntgew is 'Net weight';
comment on column lads_sto_po_gen.gewei is 'Weight unit';
comment on column lads_sto_po_gen.einkz is 'Flag: More than one schedule line for the item';
comment on column lads_sto_po_gen.curcy is 'Currency';
comment on column lads_sto_po_gen.preis is 'Gross price';
comment on column lads_sto_po_gen.matkl is 'IDOC material class';
comment on column lads_sto_po_gen.uepos is 'Higher-Level Item in BOM Structures';
comment on column lads_sto_po_gen.grkor is 'Delivery group (items delivered together)';
comment on column lads_sto_po_gen.evers is 'Shipping instructions';
comment on column lads_sto_po_gen.bpumn is 'Denominator for conv. of order price unit into order unit';
comment on column lads_sto_po_gen.bpumz is 'Numerator for conversion of order price unit into order unit';
comment on column lads_sto_po_gen.abgru is 'Reason for rejection of quotations and sales orders';
comment on column lads_sto_po_gen.abgrt is 'Description';
comment on column lads_sto_po_gen.antlf is 'Maximum number of partial deliveries allowed per item';
comment on column lads_sto_po_gen.fixmg is 'Delivery date and quantity fixed';
comment on column lads_sto_po_gen.kzazu is 'Order combination indicator';
comment on column lads_sto_po_gen.brgew is 'Total weight';
comment on column lads_sto_po_gen.pstyv is 'Sales document item category';
comment on column lads_sto_po_gen.empst is 'Receiving point';
comment on column lads_sto_po_gen.abtnr is 'Department number';
comment on column lads_sto_po_gen.abrvw is 'Usage indicator';
comment on column lads_sto_po_gen.werks is 'Plant';
comment on column lads_sto_po_gen.lprio is 'Delivery Priority';
comment on column lads_sto_po_gen.lprio_bez is 'Description';
comment on column lads_sto_po_gen.route is 'Route';
comment on column lads_sto_po_gen.route_bez is 'Route Description';
comment on column lads_sto_po_gen.lgort is 'Storage Location';
comment on column lads_sto_po_gen.vstel is 'Shipping Point/Receiving Point';
comment on column lads_sto_po_gen.delco is 'Agreed delivery time';
comment on column lads_sto_po_gen.matnr is 'IDOC material ID';
comment on column lads_sto_po_gen.valtg is 'Additional value days';
comment on column lads_sto_po_gen.hipos is 'Superior item in an item hierarchy';
comment on column lads_sto_po_gen.hievw is 'Use of Hierarchy Item';
comment on column lads_sto_po_gen.posguid is 'ATP: Encryption of DELNR and DELPS';

/**/
/* Primary Key Constraint
/**/
alter table lads_sto_po_gen
   add constraint lads_sto_po_gen_pk primary key (belnr, genseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sto_po_gen to lads_app;
grant select, insert, update, delete on lads_sto_po_gen to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sto_po_gen for lads.lads_sto_po_gen;

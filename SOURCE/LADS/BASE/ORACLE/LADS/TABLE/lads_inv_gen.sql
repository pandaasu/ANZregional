/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_gen
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_gen

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_gen
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
    posguid                                      varchar2(22 char)                   null,
    vkorg                                        varchar2(4 char)                    null,
    vtweg                                        varchar2(2 char)                    null,
    spart                                        varchar2(2 char)                    null,
    volum                                        number                              null,
    voleh                                        varchar2(3 char)                    null,
    pcb                                          number                              null,
    spcb                                         number                              null,
    zztarif                                      varchar2(3 char)                    null,
    fklmg                                        varchar2(15 char)                   null,
    meins                                        varchar2(3 char)                    null,
    zzistdu                                      varchar2(1 char)                    null,
    zzisrsu                                      varchar2(1 char)                    null,
    prod_spart                                   varchar2(2 char)                    null,
    pmatn_ean                                    varchar2(18 char)                   null,
    tdumatn_ean                                  varchar2(18 char)                   null,
    mtpos                                        varchar2(4 char)                    null,
    org_dlvnr                                    varchar2(10 char)                   null,
    org_dlvdt                                    varchar2(8 char)                    null,
    mat_legacy                                   varchar2(5 char)                    null,
    rsu_per_mcu                                  varchar2(5 char)                    null,
    mcu_per_tdu                                  varchar2(5 char)                    null,
    rsu_per_tdu                                  varchar2(5 char)                    null,
    number_of_rsu                                varchar2(5 char)                    null,
    vsart                                        varchar2(2 char)                    null,
    knref                                        varchar2(30 char)                   null,
    zzaggno                                      varchar2(4 char)                    null,
    zzagtcd                                      varchar2(2 char)                    null,
    kwmeng                                       number                              null);

/**/
/* Comments
/**/
comment on table lads_inv_gen is 'LADS Invoice Item General';
comment on column lads_inv_gen.belnr is 'IDOC document number';
comment on column lads_inv_gen.genseq is 'GEN - generated sequence number';
comment on column lads_inv_gen.posex is 'Item number';
comment on column lads_inv_gen.action is 'Action code for the item';
comment on column lads_inv_gen.pstyp is 'Item Category';
comment on column lads_inv_gen.kzabs is 'Flag: order acknowledgment required';
comment on column lads_inv_gen.menge is 'Quantity';
comment on column lads_inv_gen.menee is 'Unit of measure';
comment on column lads_inv_gen.bmng2 is 'Quantity in price unit';
comment on column lads_inv_gen.pmene is 'Price unit of measure';
comment on column lads_inv_gen.abftz is 'Agreed cumulative quantity';
comment on column lads_inv_gen.vprei is 'Price (net)';
comment on column lads_inv_gen.peinh is 'Price unit';
comment on column lads_inv_gen.netwr is 'Item value (net)';
comment on column lads_inv_gen.anetw is 'Absolute net value of item';
comment on column lads_inv_gen.skfbp is 'Amount qualifying for cash discount';
comment on column lads_inv_gen.ntgew is 'Net weight';
comment on column lads_inv_gen.gewei is 'Weight unit';
comment on column lads_inv_gen.einkz is 'Flag: More than one schedule line for the item';
comment on column lads_inv_gen.curcy is 'Currency';
comment on column lads_inv_gen.preis is 'Gross price';
comment on column lads_inv_gen.matkl is 'IDOC material class';
comment on column lads_inv_gen.uepos is 'Higher-Level Item in BOM Structures';
comment on column lads_inv_gen.grkor is 'Delivery group (items delivered together)';
comment on column lads_inv_gen.evers is 'Shipping instructions';
comment on column lads_inv_gen.bpumn is 'Denominator for conv. of order price unit into order unit';
comment on column lads_inv_gen.bpumz is 'Numerator for conversion of order price unit into order unit';
comment on column lads_inv_gen.abgru is 'Reason for rejection of quotations and sales orders';
comment on column lads_inv_gen.abgrt is 'Description of Reason for rejection of quotations and sales orders';
comment on column lads_inv_gen.antlf is 'Maximum number of partial deliveries allowed per item';
comment on column lads_inv_gen.fixmg is 'Delivery date and quantity fixed';
comment on column lads_inv_gen.kzazu is 'Order combination indicator';
comment on column lads_inv_gen.brgew is 'Total weight';
comment on column lads_inv_gen.pstyv is 'Sales document item category';
comment on column lads_inv_gen.empst is 'Receiving point';
comment on column lads_inv_gen.abtnr is 'Department number';
comment on column lads_inv_gen.abrvw is 'Usage indicator';
comment on column lads_inv_gen.werks is 'Plant';
comment on column lads_inv_gen.lprio is 'Delivery Priority';
comment on column lads_inv_gen.lprio_bez is 'Description';
comment on column lads_inv_gen.route is 'Route';
comment on column lads_inv_gen.route_bez is 'Description';
comment on column lads_inv_gen.lgort is 'Storage Location';
comment on column lads_inv_gen.vstel is 'Shipping Point/Receiving Point';
comment on column lads_inv_gen.delco is 'Agreed delivery time';
comment on column lads_inv_gen.matnr is 'IDOC material ID';
comment on column lads_inv_gen.valtg is 'Additional value days';
comment on column lads_inv_gen.hipos is 'Superior item in an item hierarchy';
comment on column lads_inv_gen.hievw is 'Use of Hierarchy Item';
comment on column lads_inv_gen.posguid is 'ATP: Encryption of DELNR and DELPS';
comment on column lads_inv_gen.vkorg is 'Sales Organization';
comment on column lads_inv_gen.vtweg is 'Distribution Channel';
comment on column lads_inv_gen.spart is 'Division';
comment on column lads_inv_gen.volum is 'Volume';
comment on column lads_inv_gen.voleh is 'Volume unit';
comment on column lads_inv_gen.pcb is 'PCB';
comment on column lads_inv_gen.spcb is 'SPCB';
comment on column lads_inv_gen.zztarif is 'Document Band Price';
comment on column lads_inv_gen.fklmg is 'Quantity';
comment on column lads_inv_gen.meins is 'Base Unit of Measure';
comment on column lads_inv_gen.zzistdu is 'TDU (Traded Unit)';
comment on column lads_inv_gen.zzisrsu is 'RSU (Retail Sales Unit)';
comment on column lads_inv_gen.prod_spart is 'Division';
comment on column lads_inv_gen.pmatn_ean is 'International Article Number (EAN/UPC)';
comment on column lads_inv_gen.tdumatn_ean is 'International Article Number (EAN/UPC)';
comment on column lads_inv_gen.mtpos is 'Item category group from material master';
comment on column lads_inv_gen.org_dlvnr is 'Sales and Distribution Document Number';
comment on column lads_inv_gen.org_dlvdt is 'Date';
comment on column lads_inv_gen.mat_legacy is 'Legacy material code';
comment on column lads_inv_gen.rsu_per_mcu is 'RSU / MCU proportion';
comment on column lads_inv_gen.mcu_per_tdu is 'MCU / TDU proportion';
comment on column lads_inv_gen.rsu_per_tdu is 'RSU / TDU proportion';
comment on column lads_inv_gen.number_of_rsu is 'Number of RSUs';
comment on column lads_inv_gen.vsart is 'Shipping type';
comment on column lads_inv_gen.knref is '"Customer description of partner (plant, storage location)"';
comment on column lads_inv_gen.zzaggno is 'Inv. list agreement nb';
comment on column lads_inv_gen.zzagtcd is 'Agreement Text Code';
comment on column lads_inv_gen.kwmeng is 'Cumulative order quantity in sales units';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_gen
   add constraint lads_inv_gen_pk primary key (belnr, genseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_gen to lads_app;
grant select, insert, update, delete on lads_inv_gen to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_gen for lads.lads_inv_gen;

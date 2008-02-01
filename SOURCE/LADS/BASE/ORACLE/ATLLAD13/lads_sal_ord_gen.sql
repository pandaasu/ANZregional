/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_gen
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_gen

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_gen
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
    zzlogpoint                                   varchar2(15 char)                   null,
    zzhomopal                                    varchar2(13 char)                   null,
    zzhomolay                                    varchar2(13 char)                   null,
    zzloosecas                                   varchar2(13 char)                   null,
    zzcond05                                     varchar2(13 char)                   null,
    zzcond06                                     varchar2(13 char)                   null,
    zzcond07                                     varchar2(13 char)                   null,
    zzcond08                                     varchar2(13 char)                   null,
    zzcond09                                     varchar2(13 char)                   null,
    zzcond10                                     varchar2(13 char)                   null,
    zzpalspace                                   varchar2(15 char)                   null,
    zzpalbas01                                   varchar2(13 char)                   null,
    zzpalbas02                                   varchar2(13 char)                   null,
    zzpalbas03                                   varchar2(13 char)                   null,
    zzpalbas04                                   varchar2(13 char)                   null,
    zzpalbas05                                   varchar2(13 char)                   null,
    zzbrgew                                      varchar2(13 char)                   null,
    zzweightpal                                  varchar2(13 char)                   null,
    zzlogpoint_f                                 varchar2(15 char)                   null,
    zzhomopal_f                                  varchar2(13 char)                   null,
    zzhomolay_f                                  varchar2(13 char)                   null,
    zzloosecas_f                                 varchar2(13 char)                   null,
    zzcond05_f                                   varchar2(13 char)                   null,
    zzcond06f                                    varchar2(13 char)                   null,
    zzcond07_f                                   varchar2(13 char)                   null,
    zzcond08_f                                   varchar2(13 char)                   null,
    zzcond09_f                                   varchar2(13 char)                   null,
    zzcond10_f                                   varchar2(13 char)                   null,
    zzpalspace_f                                 varchar2(15 char)                   null,
    zzpalbas01_f                                 varchar2(13 char)                   null,
    zzpalbas02_f                                 varchar2(13 char)                   null,
    zzpalbas03_f                                 varchar2(13 char)                   null,
    zzpalbas04_f                                 varchar2(13 char)                   null,
    zzpalbas05_f                                 varchar2(13 char)                   null,
    zzbrgew_f                                    varchar2(13 char)                   null,
    zzweightpal_f                                varchar2(13 char)                   null,
    zzmeins01                                    varchar2(3 char)                    null,
    zzmeins02                                    varchar2(3 char)                    null,
    zzmeins03                                    varchar2(3 char)                    null,
    zzmeins04                                    varchar2(3 char)                    null,
    zzmeins05                                    varchar2(3 char)                    null,
    zzweightuom                                  varchar2(3 char)                    null,
    zzmvgr1                                      varchar2(3 char)                    null,
    zzqtypaluom                                  varchar2(13 char)                   null,
    zzpcbqty                                     varchar2(4 char)                    null,
    zzmatwa                                      varchar2(18 char)                   null,
    zzordrspstatus_l                             varchar2(2 char)                    null,
    zzean_cu                                     varchar2(18 char)                   null,
    zzmenge_in_pc                                varchar2(13 char)                   null,
    posex_id                                     varchar2(6 char)                    null,
    config_id                                    varchar2(6 char)                    null,
    inst_id                                      varchar2(8 char)                    null,
    qualf                                        number                              null,
    icc                                          number                              null,
    moi                                          varchar2(4 char)                    null,
    pri                                          varchar2(3 char)                    null,
    acn                                          varchar2(5 char)                    null,
    function                                     varchar2(3 char)                    null,
    tdobject                                     varchar2(10 char)                   null,
    tdobname                                     varchar2(70 char)                   null,
    tdid                                         varchar2(4 char)                    null,
    tdspras                                      varchar2(1 char)                    null,
    tdtexttype                                   varchar2(6 char)                    null,
    langua_iso                                   varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_gen is 'LADS Sales Order General';
comment on column lads_sal_ord_gen.belnr is 'Document number';
comment on column lads_sal_ord_gen.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_gen.posex is 'Item number';
comment on column lads_sal_ord_gen.action is 'Action code for the item';
comment on column lads_sal_ord_gen.pstyp is 'Item Category';
comment on column lads_sal_ord_gen.kzabs is 'Flag: order acknowledgment required';
comment on column lads_sal_ord_gen.menge is 'Quantity';
comment on column lads_sal_ord_gen.menee is 'Unit of measure';
comment on column lads_sal_ord_gen.bmng2 is 'Quantity in price unit';
comment on column lads_sal_ord_gen.pmene is 'Price unit of measure';
comment on column lads_sal_ord_gen.abftz is 'Agreed cumulative quantity';
comment on column lads_sal_ord_gen.vprei is 'Price (net)';
comment on column lads_sal_ord_gen.peinh is 'Price unit';
comment on column lads_sal_ord_gen.netwr is 'Item value (net)';
comment on column lads_sal_ord_gen.anetw is 'Absolute net value of item';
comment on column lads_sal_ord_gen.skfbp is 'Amount qualifying for cash discount';
comment on column lads_sal_ord_gen.ntgew is 'Net weight';
comment on column lads_sal_ord_gen.gewei is 'Weight unit';
comment on column lads_sal_ord_gen.einkz is 'Flag: More than one schedule line for the item';
comment on column lads_sal_ord_gen.curcy is 'Currency';
comment on column lads_sal_ord_gen.preis is 'Gross price';
comment on column lads_sal_ord_gen.matkl is 'IDOC material class';
comment on column lads_sal_ord_gen.uepos is 'Higher-Level Item in BOM Structures';
comment on column lads_sal_ord_gen.grkor is 'Delivery group (items delivered together)';
comment on column lads_sal_ord_gen.evers is 'Shipping instructions';
comment on column lads_sal_ord_gen.bpumn is 'Denominator for conv. of order price unit into order unit';
comment on column lads_sal_ord_gen.bpumz is 'Numerator for conversion of order price unit into order unit';
comment on column lads_sal_ord_gen.abgru is 'Reason for rejection of quotations and sales orders';
comment on column lads_sal_ord_gen.abgrt is 'Description';
comment on column lads_sal_ord_gen.antlf is 'Maximum number of partial deliveries allowed per item';
comment on column lads_sal_ord_gen.fixmg is 'Delivery date and quantity fixed';
comment on column lads_sal_ord_gen.kzazu is 'Order combination indicator';
comment on column lads_sal_ord_gen.brgew is 'Total weight';
comment on column lads_sal_ord_gen.pstyv is 'Sales document item category';
comment on column lads_sal_ord_gen.empst is 'Receiving point';
comment on column lads_sal_ord_gen.abtnr is 'Department number';
comment on column lads_sal_ord_gen.abrvw is 'Usage indicator';
comment on column lads_sal_ord_gen.werks is 'Plant';
comment on column lads_sal_ord_gen.lprio is 'Delivery Priority';
comment on column lads_sal_ord_gen.lprio_bez is 'Description';
comment on column lads_sal_ord_gen.route is 'Route';
comment on column lads_sal_ord_gen.route_bez is 'Description';
comment on column lads_sal_ord_gen.lgort is 'Storage Location';
comment on column lads_sal_ord_gen.vstel is 'Shipping Point/Receiving Point';
comment on column lads_sal_ord_gen.delco is 'Agreed delivery time';
comment on column lads_sal_ord_gen.matnr is 'IDOC material ID';
comment on column lads_sal_ord_gen.valtg is 'Additional value days';
comment on column lads_sal_ord_gen.hipos is 'Superior item in an item hierarchy';
comment on column lads_sal_ord_gen.hievw is 'Use of Hierarchy Item';
comment on column lads_sal_ord_gen.posguid is 'ATP: Encryption of DELNR and DELPS';
comment on column lads_sal_ord_gen.zzlogpoint is 'Display form of  Pricing condition 1 - (Logistic Points)';
comment on column lads_sal_ord_gen.zzhomopal is 'Pricing Condition 2 (Generaly Homo. Pallet)';
comment on column lads_sal_ord_gen.zzhomolay is 'Pricing Condition 2 (Generaly Homo. Pallet)';
comment on column lads_sal_ord_gen.zzloosecas is 'Pricing Condition4 (Generaly loose cs)';
comment on column lads_sal_ord_gen.zzcond05 is 'Pricing Condition 5 value';
comment on column lads_sal_ord_gen.zzcond06 is 'Pricing Condition 5 value';
comment on column lads_sal_ord_gen.zzcond07 is 'Pricing Condition 5 value';
comment on column lads_sal_ord_gen.zzcond08 is 'Pricing Condition 5 value';
comment on column lads_sal_ord_gen.zzcond09 is 'Pricing Condition 5 value';
comment on column lads_sal_ord_gen.zzcond10 is 'Pricing Condition 5 value';
comment on column lads_sal_ord_gen.zzpalspace is 'Number of pallet spaces';
comment on column lads_sal_ord_gen.zzpalbas01 is 'Number of pallet Base';
comment on column lads_sal_ord_gen.zzpalbas02 is 'Number of pallet Base';
comment on column lads_sal_ord_gen.zzpalbas03 is 'Number of pallet Base';
comment on column lads_sal_ord_gen.zzpalbas04 is 'Number of pallet Base';
comment on column lads_sal_ord_gen.zzpalbas05 is 'Number of pallet Base';
comment on column lads_sal_ord_gen.zzbrgew is 'Total weight (without pallet bases)';
comment on column lads_sal_ord_gen.zzweightpal is '"Total Weight, including pallet bases"';
comment on column lads_sal_ord_gen.zzlogpoint_f is 'Display form of  Pricing condition 1 - (Logistic Points)';
comment on column lads_sal_ord_gen.zzhomopal_f is 'Pricing Condition 2 (Generaly Homo. Pallet)';
comment on column lads_sal_ord_gen.zzhomolay_f is 'Pricing Condition 2 (Generaly Homo. Pallet)';
comment on column lads_sal_ord_gen.zzloosecas_f is 'Pricing Condition 4 (Generaly loose cs)';
comment on column lads_sal_ord_gen.zzcond05_f is 'Pricing Condition 5 value';
comment on column lads_sal_ord_gen.zzcond06f is 'Pricing Condition 5 value';
comment on column lads_sal_ord_gen.zzcond07_f is 'Pricing Condition 5 value';
comment on column lads_sal_ord_gen.zzcond08_f is 'Pricing Condition 5 value';
comment on column lads_sal_ord_gen.zzcond09_f is 'Pricing Condition 5 value';
comment on column lads_sal_ord_gen.zzcond10_f is 'Pricing Condition 5 value';
comment on column lads_sal_ord_gen.zzpalspace_f is 'Number of pallet spaces';
comment on column lads_sal_ord_gen.zzpalbas01_f is 'Number of pallet Base';
comment on column lads_sal_ord_gen.zzpalbas02_f is 'Number of pallet Base';
comment on column lads_sal_ord_gen.zzpalbas03_f is 'Number of pallet Base';
comment on column lads_sal_ord_gen.zzpalbas04_f is 'Number of pallet Base';
comment on column lads_sal_ord_gen.zzpalbas05_f is 'Number of pallet Base';
comment on column lads_sal_ord_gen.zzbrgew_f is 'Total weight (without pallet bases)';
comment on column lads_sal_ord_gen.zzweightpal_f is '"Total Weight, including pallet bases"';
comment on column lads_sal_ord_gen.zzmeins01 is 'Target quantity unit of measure in ISO code';
comment on column lads_sal_ord_gen.zzmeins02 is 'Target quantity unit of measure in ISO code';
comment on column lads_sal_ord_gen.zzmeins03 is 'Target quantity unit of measure in ISO code';
comment on column lads_sal_ord_gen.zzmeins04 is 'Target quantity unit of measure in ISO code';
comment on column lads_sal_ord_gen.zzmeins05 is 'Target quantity unit of measure in ISO code';
comment on column lads_sal_ord_gen.zzweightuom is 'Target quantity unit of measure in ISO code';
comment on column lads_sal_ord_gen.zzmvgr1 is 'CRPC Material Category';
comment on column lads_sal_ord_gen.zzqtypaluom is 'quantity in pallet uom. (10.2)';
comment on column lads_sal_ord_gen.zzpcbqty is 'Consumer Unit in Traded Unit / PCB Quantity';
comment on column lads_sal_ord_gen.zzmatwa is 'IDOC material entered';
comment on column lads_sal_ord_gen.zzordrspstatus_l is 'Order response status';
comment on column lads_sal_ord_gen.zzean_cu is 'EAN of UoM PC (International Article Number)';
comment on column lads_sal_ord_gen.zzmenge_in_pc is 'quantity in PC uom. (10.3)';
comment on column lads_sal_ord_gen.posex_id is 'Character field of length 6';
comment on column lads_sal_ord_gen.config_id is 'Character field of length 6';
comment on column lads_sal_ord_gen.inst_id is '"Character field, 8 characters long"';
comment on column lads_sal_ord_gen.qualf is 'IDoc object identification(A/D)';
comment on column lads_sal_ord_gen.icc is 'Interchangeability Code';
comment on column lads_sal_ord_gen.moi is 'Type Identification';
comment on column lads_sal_ord_gen.pri is 'Order Priority';
comment on column lads_sal_ord_gen.acn is 'Aircraft registration number';
comment on column lads_sal_ord_gen.function is 'Function (for transferred text)';
comment on column lads_sal_ord_gen.tdobject is 'Texts: application object';
comment on column lads_sal_ord_gen.tdobname is 'Name';
comment on column lads_sal_ord_gen.tdid is 'Text ID';
comment on column lads_sal_ord_gen.tdspras is 'Language';
comment on column lads_sal_ord_gen.tdtexttype is 'SAPscript: Format of Text';
comment on column lads_sal_ord_gen.langua_iso is 'Language key';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_gen
   add constraint lads_sal_ord_gen_pk primary key (belnr, genseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_gen to lads_app;
grant select, insert, update, delete on lads_sal_ord_gen to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_gen for lads.lads_sal_ord_gen;

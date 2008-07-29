/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_hdr
   (action                                       varchar2(3 char)                    null,
    kzabs                                        varchar2(1 char)                    null,
    curcy                                        varchar2(3 char)                    null,
    hwaer                                        varchar2(3 char)                    null,
    wkurs                                        varchar2(12 char)                   null,
    zterm                                        varchar2(17 char)                   null,
    kundeuinr                                    varchar2(20 char)                   null,
    eigenuinr                                    varchar2(20 char)                   null,
    bsart                                        varchar2(4 char)                    null,
    belnr                                        varchar2(35 char)                   not null,
    ntgew                                        varchar2(18 char)                   null,
    brgew                                        varchar2(18 char)                   null,
    gewei                                        varchar2(3 char)                    null,
    fkart_rl                                     varchar2(4 char)                    null,
    ablad                                        varchar2(25 char)                   null,
    bstzd                                        varchar2(4 char)                    null,
    vsart                                        varchar2(2 char)                    null,
    vsart_bez                                    varchar2(20 char)                   null,
    recipnt_no                                   varchar2(10 char)                   null,
    kzazu                                        varchar2(1 char)                    null,
    autlf                                        varchar2(1 char)                    null,
    augru                                        varchar2(3 char)                    null,
    augru_bez                                    varchar2(40 char)                   null,
    abrvw                                        varchar2(3 char)                    null,
    abrvw_bez                                    varchar2(20 char)                   null,
    fktyp                                        varchar2(1 char)                    null,
    lifsk                                        varchar2(2 char)                    null,
    lifsk_bez                                    varchar2(20 char)                   null,
    empst                                        varchar2(25 char)                   null,
    abtnr                                        varchar2(4 char)                    null,
    delco                                        varchar2(3 char)                    null,
    wkurs_m                                      varchar2(12 char)                   null,
    zzexpectpb                                   varchar2(3 char)                    null,
    zzorbdpr                                     varchar2(3 char)                    null,
    zzmanbpr                                     varchar2(3 char)                    null,
    zztarif                                      varchar2(3 char)                    null,
    zznocombi                                    varchar2(1 char)                    null,
    zzpbuom01                                    varchar2(4 char)                    null,
    zzpbuom02                                    varchar2(4 char)                    null,
    zzpbuom03                                    varchar2(4 char)                    null,
    zzpbuom04                                    varchar2(4 char)                    null,
    zzpbuom05                                    varchar2(4 char)                    null,
    zzpbuom06                                    varchar2(4 char)                    null,
    zzpbuom07                                    varchar2(4 char)                    null,
    zzpbuom08                                    varchar2(4 char)                    null,
    zzpbuom09                                    varchar2(4 char)                    null,
    zzpbuom10                                    varchar2(4 char)                    null,
    zzgrouping                                   varchar2(1 char)                    null,
    zzincompleted                                varchar2(1 char)                    null,
    zzstatus                                     varchar2(2 char)                    null,
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
    zzerror                                      varchar2(1 char)                    null,
    zzvsart                                      varchar2(2 char)                    null,
    zzsdabw                                      varchar2(4 char)                    null,
    zzordrspstatus_h                             varchar2(2 char)                    null,
    cmgst                                        varchar2(1 char)                    null,
    cmgst_bez                                    varchar2(20 char)                   null,
    spstg                                        varchar2(1 char)                    null,
    spstg_bez                                    varchar2(20 char)                   null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_hdr is 'LADS Sales Order Header';
comment on column lads_sal_ord_hdr.action is 'Action code for the whole EDI message';
comment on column lads_sal_ord_hdr.kzabs is 'Flag: order acknowledgment required';
comment on column lads_sal_ord_hdr.curcy is 'Currency';
comment on column lads_sal_ord_hdr.hwaer is 'EDI local currency';
comment on column lads_sal_ord_hdr.wkurs is 'Exchange rate';
comment on column lads_sal_ord_hdr.zterm is 'Terms of payment key';
comment on column lads_sal_ord_hdr.kundeuinr is 'VAT registration number';
comment on column lads_sal_ord_hdr.eigenuinr is 'VAT registration number (Own)';
comment on column lads_sal_ord_hdr.bsart is 'Document type';
comment on column lads_sal_ord_hdr.belnr is 'Document number';
comment on column lads_sal_ord_hdr.ntgew is 'Net weight';
comment on column lads_sal_ord_hdr.brgew is 'Total weight';
comment on column lads_sal_ord_hdr.gewei is 'Weight unit';
comment on column lads_sal_ord_hdr.fkart_rl is 'Invoice list type';
comment on column lads_sal_ord_hdr.ablad is 'Unloading Point';
comment on column lads_sal_ord_hdr.bstzd is 'Purchase order number supplement';
comment on column lads_sal_ord_hdr.vsart is 'Shipping conditions';
comment on column lads_sal_ord_hdr.vsart_bez is 'Description of the Shipping Type';
comment on column lads_sal_ord_hdr.recipnt_no is 'Number of recipient (for control via the ALE model)';
comment on column lads_sal_ord_hdr.kzazu is 'Order combination indicator';
comment on column lads_sal_ord_hdr.autlf is 'Complete delivery defined for each sales order?';
comment on column lads_sal_ord_hdr.augru is 'Order reason (reason for the business transaction)';
comment on column lads_sal_ord_hdr.augru_bez is 'Order Reason Description';
comment on column lads_sal_ord_hdr.abrvw is 'Usage indicator';
comment on column lads_sal_ord_hdr.abrvw_bez is 'Usage indicator Description';
comment on column lads_sal_ord_hdr.fktyp is 'Billing category';
comment on column lads_sal_ord_hdr.lifsk is 'Delivery block (document header)';
comment on column lads_sal_ord_hdr.lifsk_bez is 'Delivery Block Description';
comment on column lads_sal_ord_hdr.empst is 'Receiving point';
comment on column lads_sal_ord_hdr.abtnr is 'Department number';
comment on column lads_sal_ord_hdr.delco is 'Agreed delivery time';
comment on column lads_sal_ord_hdr.wkurs_m is 'Indirectly quoted exchange rate in an IDoc segment';
comment on column lads_sal_ord_hdr.zzexpectpb is 'Customer expected  Band Price';
comment on column lads_sal_ord_hdr.zzorbdpr is 'Calculated Order Band Price';
comment on column lads_sal_ord_hdr.zzmanbpr is 'Manual overrided Band Price';
comment on column lads_sal_ord_hdr.zztarif is 'Document Band Price';
comment on column lads_sal_ord_hdr.zznocombi is 'Sales Order must not be eligible for Order Combination';
comment on column lads_sal_ord_hdr.zzpbuom01 is ' Price band condition code';
comment on column lads_sal_ord_hdr.zzpbuom02 is ' Price band condition code';
comment on column lads_sal_ord_hdr.zzpbuom03 is ' Price band condition code';
comment on column lads_sal_ord_hdr.zzpbuom04 is ' Price band condition code';
comment on column lads_sal_ord_hdr.zzpbuom05 is ' Price band condition code';
comment on column lads_sal_ord_hdr.zzpbuom06 is ' Price band condition code';
comment on column lads_sal_ord_hdr.zzpbuom07 is ' Price band condition code';
comment on column lads_sal_ord_hdr.zzpbuom08 is ' Price band condition code';
comment on column lads_sal_ord_hdr.zzpbuom09 is ' Price band condition code';
comment on column lads_sal_ord_hdr.zzpbuom10 is ' Price band condition code';
comment on column lads_sal_ord_hdr.zzgrouping is 'User Manual Grouping criteria for Sales Orders Combination';
comment on column lads_sal_ord_hdr.zzincompleted is 'Additional field for contry specific usage';
comment on column lads_sal_ord_hdr.zzstatus is 'Country specific Document status';
comment on column lads_sal_ord_hdr.zzlogpoint is 'Display form of  Pricing condition 1 - (Logistic Points)';
comment on column lads_sal_ord_hdr.zzhomopal is 'Pricing Condition 2 (Generaly Homo. Pallet)';
comment on column lads_sal_ord_hdr.zzhomolay is 'Pricing Condition 2 (Generaly Homo. Pallet)';
comment on column lads_sal_ord_hdr.zzloosecas is 'Pricing Condition4 (Generaly loose cs)';
comment on column lads_sal_ord_hdr.zzcond05 is 'Pricing Condition 5 value';
comment on column lads_sal_ord_hdr.zzcond06 is 'Pricing Condition 5 value';
comment on column lads_sal_ord_hdr.zzcond07 is 'Pricing Condition 5 value';
comment on column lads_sal_ord_hdr.zzcond08 is 'Pricing Condition 5 value';
comment on column lads_sal_ord_hdr.zzcond09 is 'Pricing Condition 5 value';
comment on column lads_sal_ord_hdr.zzcond10 is 'Pricing Condition 5 value';
comment on column lads_sal_ord_hdr.zzpalspace is 'Number of pallet spaces';
comment on column lads_sal_ord_hdr.zzpalbas01 is 'Number of pallet Base';
comment on column lads_sal_ord_hdr.zzpalbas02 is 'Number of pallet Base';
comment on column lads_sal_ord_hdr.zzpalbas03 is 'Number of pallet Base';
comment on column lads_sal_ord_hdr.zzpalbas04 is 'Number of pallet Base';
comment on column lads_sal_ord_hdr.zzpalbas05 is 'Number of pallet Base';
comment on column lads_sal_ord_hdr.zzbrgew is 'Total weight (without pallet bases)';
comment on column lads_sal_ord_hdr.zzweightpal is '"Total Weight, including pallet bases"';
comment on column lads_sal_ord_hdr.zzlogpoint_f is 'Display form of  Pricing condition 1 - (Logistic Points)';
comment on column lads_sal_ord_hdr.zzhomopal_f is 'Pricing Condition 2 (Generaly Homo. Pallet)';
comment on column lads_sal_ord_hdr.zzhomolay_f is 'Pricing Condition 2 (Generaly Homo. Pallet)';
comment on column lads_sal_ord_hdr.zzloosecas_f is 'Pricing Condition4 (Generaly loose cs)';
comment on column lads_sal_ord_hdr.zzcond05_f is 'Pricing Condition 5 value';
comment on column lads_sal_ord_hdr.zzcond06f is 'Pricing Condition 5 value';
comment on column lads_sal_ord_hdr.zzcond07_f is 'Pricing Condition 5 value';
comment on column lads_sal_ord_hdr.zzcond08_f is 'Pricing Condition 5 value';
comment on column lads_sal_ord_hdr.zzcond09_f is 'Pricing Condition 5 value';
comment on column lads_sal_ord_hdr.zzcond10_f is 'Pricing Condition 5 value';
comment on column lads_sal_ord_hdr.zzpalspace_f is 'Number of pallet spaces';
comment on column lads_sal_ord_hdr.zzpalbas01_f is 'Number of pallet Base';
comment on column lads_sal_ord_hdr.zzpalbas02_f is 'Number of pallet Base';
comment on column lads_sal_ord_hdr.zzpalbas03_f is 'Number of pallet Base';
comment on column lads_sal_ord_hdr.zzpalbas04_f is 'Number of pallet Base';
comment on column lads_sal_ord_hdr.zzpalbas05_f is 'Number of pallet Base';
comment on column lads_sal_ord_hdr.zzbrgew_f is 'Total weight (without pallet bases)';
comment on column lads_sal_ord_hdr.zzweightpal_f is '"Total Weight, including pallet bases"';
comment on column lads_sal_ord_hdr.zzmeins01 is 'Target quantity unit of measure in ISO code';
comment on column lads_sal_ord_hdr.zzmeins02 is 'Target quantity unit of measure in ISO code';
comment on column lads_sal_ord_hdr.zzmeins03 is 'Target quantity unit of measure in ISO code';
comment on column lads_sal_ord_hdr.zzmeins04 is 'Target quantity unit of measure in ISO code';
comment on column lads_sal_ord_hdr.zzmeins05 is 'Target quantity unit of measure in ISO code';
comment on column lads_sal_ord_hdr.zzweightuom is 'Target quantity unit of measure in ISO code';
comment on column lads_sal_ord_hdr.zzerror is '"Individual, User-Defined Character"';
comment on column lads_sal_ord_hdr.zzvsart is 'Shipping type';
comment on column lads_sal_ord_hdr.zzsdabw is 'Special processing indicator';
comment on column lads_sal_ord_hdr.zzordrspstatus_h is 'Order response status';
comment on column lads_sal_ord_hdr.cmgst is 'Overall status of credit checks';
comment on column lads_sal_ord_hdr.cmgst_bez is 'Overall status of credit checks - description';
comment on column lads_sal_ord_hdr.spstg is 'Overall blocked status';
comment on column lads_sal_ord_hdr.spstg_bez is 'Description of Overall blocked status';
comment on column lads_sal_ord_hdr.idoc_name is 'IDOC name';
comment on column lads_sal_ord_hdr.idoc_number is 'IDOC number';
comment on column lads_sal_ord_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_sal_ord_hdr.lads_date is 'LADS date loaded';
comment on column lads_sal_ord_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan, 4=deleted)';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_hdr
   add constraint lads_sal_ord_hdr_pk primary key (belnr);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_hdr to lads_app;
grant select, insert, update, delete on lads_sal_ord_hdr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_hdr for lads.lads_sal_ord_hdr;

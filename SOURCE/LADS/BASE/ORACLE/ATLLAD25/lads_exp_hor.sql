/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_hor
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_hor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_hor
   (zzgrpnr                                      varchar2(40 char)                   not null,
    ordseq                                       number                              not null,
    horseq                                       number                              not null,
    action                                       varchar2(3 char)                    null,
    kzabs                                        varchar2(1 char)                    null,
    curcy                                        varchar2(3 char)                    null,
    hwaer                                        varchar2(3 char)                    null,
    wkurs                                        varchar2(12 char)                   null,
    zterm                                        varchar2(17 char)                   null,
    kundeuinr                                    varchar2(20 char)                   null,
    eigenuinr                                    varchar2(20 char)                   null,
    bsart                                        varchar2(4 char)                    null,
    belnr                                        varchar2(35 char)                   null,
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
    zzshipto                                     varchar2(10 char)                   null,
    zzsoldto                                     varchar2(10 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_hor is 'Generic ICB Document - Order data';
comment on column lads_exp_hor.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_hor.ordseq is 'ORD - generated sequence number';
comment on column lads_exp_hor.horseq is 'HOR - generated sequence number';
comment on column lads_exp_hor.action is 'Action code for the whole EDI message';
comment on column lads_exp_hor.kzabs is 'Flag: order acknowledgment required';
comment on column lads_exp_hor.curcy is 'Currency';
comment on column lads_exp_hor.hwaer is 'EDI local currency';
comment on column lads_exp_hor.wkurs is 'Exchange rate';
comment on column lads_exp_hor.zterm is 'Terms of payment key';
comment on column lads_exp_hor.kundeuinr is 'VAT registration number';
comment on column lads_exp_hor.eigenuinr is 'VAT registration number (Own)';
comment on column lads_exp_hor.bsart is 'Document type';
comment on column lads_exp_hor.belnr is 'Document number';
comment on column lads_exp_hor.ntgew is 'Net weight';
comment on column lads_exp_hor.brgew is 'Total weight';
comment on column lads_exp_hor.gewei is 'Weight unit';
comment on column lads_exp_hor.fkart_rl is 'Invoice list type';
comment on column lads_exp_hor.ablad is 'Unloading Point';
comment on column lads_exp_hor.bstzd is 'Purchase order number supplement';
comment on column lads_exp_hor.vsart is 'Shipping conditions';
comment on column lads_exp_hor.vsart_bez is 'Description of the Shipping Type';
comment on column lads_exp_hor.recipnt_no is 'Number of recipient (for control via the ALE model)';
comment on column lads_exp_hor.kzazu is 'Order combination indicator';
comment on column lads_exp_hor.autlf is 'Complete delivery defined for each sales order?';
comment on column lads_exp_hor.augru is 'Order reason (reason for the business transaction)';
comment on column lads_exp_hor.augru_bez is 'Order Reason Description';
comment on column lads_exp_hor.abrvw is 'Usage indicator';
comment on column lads_exp_hor.abrvw_bez is 'Usage indicator Description';
comment on column lads_exp_hor.fktyp is 'Billing category';
comment on column lads_exp_hor.lifsk is 'Delivery block (document header)';
comment on column lads_exp_hor.lifsk_bez is 'Delivery Block Description';
comment on column lads_exp_hor.empst is 'Receiving point';
comment on column lads_exp_hor.abtnr is 'Department number';
comment on column lads_exp_hor.delco is 'Agreed delivery time';
comment on column lads_exp_hor.wkurs_m is 'Indirectly quoted exchange rate in an IDoc segment';
comment on column lads_exp_hor.zzshipto is 'Final Ship_to party';
comment on column lads_exp_hor.zzsoldto is 'Final Sold_to party';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_hor
   add constraint lads_exp_hor_pk primary key (zzgrpnr, ordseq, horseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_hor to lads_app;
grant select, insert, update, delete on lads_exp_hor to ics_app;
grant select on lads_exp_hor to ics_reader with grant option;
grant select on lads_exp_hor to ics_executor;
grant select on lads_exp_hor to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_hor for lads.lads_exp_hor;

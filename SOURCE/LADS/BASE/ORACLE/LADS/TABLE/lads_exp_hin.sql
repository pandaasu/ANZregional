/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_hin
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_hin

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_hin
   (zzgrpnr                                      varchar2(40 char)                   not null,
    invseq                                       number                              not null,
    hinseq                                       number                              not null,
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
    del_belnr                                    varchar2(35 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_hin is 'Generic ICB Document - Invoice data';
comment on column lads_exp_hin.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_hin.invseq is 'INV - generated sequence number';
comment on column lads_exp_hin.hinseq is 'HIN - generated sequence number';
comment on column lads_exp_hin.action is 'Action code for the whole EDI message';
comment on column lads_exp_hin.kzabs is 'Flag: order acknowledgment required';
comment on column lads_exp_hin.curcy is 'Currency';
comment on column lads_exp_hin.hwaer is 'EDI local currency';
comment on column lads_exp_hin.wkurs is 'Exchange rate';
comment on column lads_exp_hin.zterm is 'Terms of payment key';
comment on column lads_exp_hin.kundeuinr is 'VAT registration number';
comment on column lads_exp_hin.eigenuinr is 'VAT registration number';
comment on column lads_exp_hin.bsart is 'Document type';
comment on column lads_exp_hin.belnr is 'IDOC document number';
comment on column lads_exp_hin.ntgew is 'Net weight';
comment on column lads_exp_hin.brgew is 'Total Weight';
comment on column lads_exp_hin.gewei is 'Weight unit';
comment on column lads_exp_hin.fkart_rl is 'Invoice list type';
comment on column lads_exp_hin.ablad is 'Unloading Point';
comment on column lads_exp_hin.bstzd is 'Purchase order number supplement';
comment on column lads_exp_hin.vsart is 'Shipping conditions';
comment on column lads_exp_hin.vsart_bez is 'Description of the Shipping Type';
comment on column lads_exp_hin.recipnt_no is 'Number of recipient (for control via the ALE model)';
comment on column lads_exp_hin.kzazu is 'Order combination indicator';
comment on column lads_exp_hin.autlf is 'Complete delivery defined for each sales order?';
comment on column lads_exp_hin.augru is 'Order reason (reason for the business transaction)';
comment on column lads_exp_hin.augru_bez is 'Description';
comment on column lads_exp_hin.abrvw is 'Usage indicator';
comment on column lads_exp_hin.abrvw_bez is 'Description';
comment on column lads_exp_hin.fktyp is 'Billing category';
comment on column lads_exp_hin.lifsk is 'Delivery block (document header)';
comment on column lads_exp_hin.lifsk_bez is 'Description';
comment on column lads_exp_hin.empst is 'Receiving point';
comment on column lads_exp_hin.abtnr is 'Department number';
comment on column lads_exp_hin.delco is 'Agreed delivery time';
comment on column lads_exp_hin.wkurs_m is 'Indirectly quoted exchange rate in an IDoc segment';
comment on column lads_exp_hin.del_belnr is 'Delivery Number';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_hin
   add constraint lads_exp_hin_pk primary key (zzgrpnr, invseq, hinseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_hin to lads_app;
grant select, insert, update, delete on lads_exp_hin to ics_app;
grant select on lads_exp_hin to ics_reader with grant option;
grant select on lads_exp_hin to ics_executor;
grant select on lads_exp_hin to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_hin for lads.lads_exp_hin;

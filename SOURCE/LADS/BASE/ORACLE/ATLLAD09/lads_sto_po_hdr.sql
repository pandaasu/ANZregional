/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sto_po_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sto_po_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sto_po_hdr
   (belnr                                        varchar2(35 char)                   not null,
    bsart                                        varchar2(4 char)                    null,
    curcy                                        varchar2(3 char)                    null,
    wkurs                                        varchar2(12 char)                   null,
    zterm                                        varchar2(17 char)                   null,
    recipnt_no                                   varchar2(10 char)                   null,
    action                                       varchar2(3 char)                    null,
    kzabs                                        varchar2(1 char)                    null,
    hwaer                                        varchar2(3 char)                    null,
    kundeuinr                                    varchar2(20 char)                   null,
    eigenuinr                                    varchar2(20 char)                   null,
    ntgew                                        varchar2(18 char)                   null,
    brgew                                        varchar2(18 char)                   null,
    gewei                                        varchar2(3 char)                    null,
    fkart_rl                                     varchar2(4 char)                    null,
    ablad                                        varchar2(25 char)                   null,
    bstzd                                        varchar2(4 char)                    null,
    vsart                                        varchar2(2 char)                    null,
    vsart_bez                                    varchar2(20 char)                   null,
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
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_sto_po_hdr is 'LADS Stock Transfer and Purchase Order Header';
comment on column lads_sto_po_hdr.belnr is 'IDOC document number';
comment on column lads_sto_po_hdr.bsart is 'Document type';
comment on column lads_sto_po_hdr.curcy is 'Currency';
comment on column lads_sto_po_hdr.wkurs is 'Exchange rate';
comment on column lads_sto_po_hdr.zterm is 'Terms of payment key';
comment on column lads_sto_po_hdr.recipnt_no is 'Number of recipient (for control via the ALE model)';
comment on column lads_sto_po_hdr.action is 'Action code for the whole EDI message';
comment on column lads_sto_po_hdr.kzabs is 'Flag: order acknowledgment required';
comment on column lads_sto_po_hdr.hwaer is 'EDI local currency';
comment on column lads_sto_po_hdr.kundeuinr is 'VAT registration number (Customer)';
comment on column lads_sto_po_hdr.eigenuinr is 'VAT registration number (Own)';
comment on column lads_sto_po_hdr.ntgew is 'Net weight';
comment on column lads_sto_po_hdr.brgew is 'Total Weight';
comment on column lads_sto_po_hdr.gewei is 'Weight unit';
comment on column lads_sto_po_hdr.fkart_rl is 'Invoice list type';
comment on column lads_sto_po_hdr.ablad is 'Unloading Point';
comment on column lads_sto_po_hdr.bstzd is 'Purchase order number supplement';
comment on column lads_sto_po_hdr.vsart is 'Shipping conditions';
comment on column lads_sto_po_hdr.vsart_bez is 'Description of the Shipping Type';
comment on column lads_sto_po_hdr.kzazu is 'Order combination indicator';
comment on column lads_sto_po_hdr.autlf is 'Complete delivery defined for each sales order?';
comment on column lads_sto_po_hdr.augru is 'Order reason (reason for the business transaction)';
comment on column lads_sto_po_hdr.augru_bez is 'Description';
comment on column lads_sto_po_hdr.abrvw is 'Usage indicator';
comment on column lads_sto_po_hdr.abrvw_bez is 'Description';
comment on column lads_sto_po_hdr.fktyp is 'Billing category';
comment on column lads_sto_po_hdr.lifsk is 'Delivery block (document header)';
comment on column lads_sto_po_hdr.lifsk_bez is 'Description';
comment on column lads_sto_po_hdr.empst is 'Receiving point';
comment on column lads_sto_po_hdr.abtnr is 'Department number';
comment on column lads_sto_po_hdr.delco is 'Agreed delivery time';
comment on column lads_sto_po_hdr.wkurs_m is 'Indirectly quoted exchange rate in an IDoc segment';
comment on column lads_sto_po_hdr.idoc_name is 'IDOC name';
comment on column lads_sto_po_hdr.idoc_number is 'IDOC number';
comment on column lads_sto_po_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_sto_po_hdr.lads_date is 'LADS date loaded';
comment on column lads_sto_po_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';

/**/
/* Primary Key Constraint
/**/
alter table lads_sto_po_hdr
   add constraint lads_sto_po_hdr_pk primary key (belnr);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sto_po_hdr to lads_app;
grant select, insert, update, delete on lads_sto_po_hdr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sto_po_hdr for lads.lads_sto_po_hdr;

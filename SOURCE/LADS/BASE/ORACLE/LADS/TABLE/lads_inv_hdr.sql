/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_hdr
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
    z_edi_relevant                               varchar2(3 char)                    null,
    zlsch                                        varchar2(1 char)                    null,
    text1                                        varchar2(30 char)                   null,
    vbtyp                                        varchar2(1 char)                    null,
    expnr                                        varchar2(20 char)                   null,
    reprint                                      varchar2(1 char)                    null,
    crpc_version                                 varchar2(2 char)                    null,
    zzsplitinvlines                              varchar2(1 char)                    null,
    bbbnr                                        number                              null,
    bbsnr                                        number                              null,
    abrvw2                                       varchar2(3 char)                    null,
    auart                                        varchar2(4 char)                    null,
    zzinternal_doc                               varchar2(1 char)                    null,
    mescod                                       varchar2(3 char)                    null,
    mesfct                                       varchar2(3 char)                    null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_inv_hdr is 'LADS Invoice Header';
comment on column lads_inv_hdr.action is 'Action code for the whole EDI message';
comment on column lads_inv_hdr.kzabs is 'Flag: order acknowledgment required';
comment on column lads_inv_hdr.curcy is 'Currency';
comment on column lads_inv_hdr.hwaer is 'EDI local currency';
comment on column lads_inv_hdr.wkurs is 'Exchange rate';
comment on column lads_inv_hdr.zterm is 'Terms of payment key';
comment on column lads_inv_hdr.kundeuinr is 'VAT registration number';
comment on column lads_inv_hdr.eigenuinr is 'VAT registration number';
comment on column lads_inv_hdr.bsart is 'Document type';
comment on column lads_inv_hdr.belnr is 'IDOC document number';
comment on column lads_inv_hdr.ntgew is 'Net weight';
comment on column lads_inv_hdr.brgew is 'Total Weight';
comment on column lads_inv_hdr.gewei is 'Weight unit';
comment on column lads_inv_hdr.fkart_rl is 'Invoice list type';
comment on column lads_inv_hdr.ablad is 'Unloading Point';
comment on column lads_inv_hdr.bstzd is 'Purchase order number supplement';
comment on column lads_inv_hdr.vsart is 'Shipping conditions';
comment on column lads_inv_hdr.vsart_bez is 'Description of the Shipping Type';
comment on column lads_inv_hdr.recipnt_no is 'Number of recipient (for control via the ALE model)';
comment on column lads_inv_hdr.kzazu is 'Order combination indicator';
comment on column lads_inv_hdr.autlf is 'Complete delivery defined for each sales order?';
comment on column lads_inv_hdr.augru is 'Order reason (reason for the business transaction)';
comment on column lads_inv_hdr.augru_bez is 'Description';
comment on column lads_inv_hdr.abrvw is 'Usage indicator';
comment on column lads_inv_hdr.abrvw_bez is 'Description';
comment on column lads_inv_hdr.fktyp is 'Billing category';
comment on column lads_inv_hdr.lifsk is 'Delivery block (document header)';
comment on column lads_inv_hdr.lifsk_bez is 'Description';
comment on column lads_inv_hdr.empst is 'Receiving point';
comment on column lads_inv_hdr.abtnr is 'Department number';
comment on column lads_inv_hdr.delco is 'Agreed delivery time';
comment on column lads_inv_hdr.wkurs_m is 'Indirectly quoted exchange rate in an IDoc segment';
comment on column lads_inv_hdr.z_edi_relevant is 'Action code for the whole EDI message';
comment on column lads_inv_hdr.zlsch is 'Payment Method';
comment on column lads_inv_hdr.text1 is 'Name of the Payment Method in the Language of the Country';
comment on column lads_inv_hdr.vbtyp is 'SD document category';
comment on column lads_inv_hdr.expnr is 'External partner number (in customer system)';
comment on column lads_inv_hdr.reprint is 'Reprint Flag';
comment on column lads_inv_hdr.crpc_version is 'CRPC Version number';
comment on column lads_inv_hdr.zzsplitinvlines is 'Flag  : Delivery split into several invoices';
comment on column lads_inv_hdr.bbbnr is 'International location number (part 1)';
comment on column lads_inv_hdr.bbsnr is 'International location number (Part 2)';
comment on column lads_inv_hdr.abrvw2 is 'Usage indicator';
comment on column lads_inv_hdr.auart is 'Sales Document Type';
comment on column lads_inv_hdr.zzinternal_doc is 'Internal document flag';
comment on column lads_inv_hdr.mescod is 'IDOC message code';
comment on column lads_inv_hdr.mesfct is 'IDOC message function';
comment on column lads_inv_hdr.idoc_name is 'IDOC name';
comment on column lads_inv_hdr.idoc_number is 'IDOC number';
comment on column lads_inv_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_inv_hdr.lads_date is 'LADS date loaded';
comment on column lads_inv_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan, 4=cancelled)';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_hdr
   add constraint lads_inv_hdr_pk primary key (belnr);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_hdr to lads_app;
grant select, insert, update, delete on lads_inv_hdr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_hdr for lads.lads_inv_hdr;

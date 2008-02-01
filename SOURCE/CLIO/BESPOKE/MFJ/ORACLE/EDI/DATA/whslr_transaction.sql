/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : whslr_transaction
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Wholesaler Transaction Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.whslr_transaction
   (sap_order_type                      varchar2(10 char)             not null,
    sap_invoice_type                    varchar2(10 char)             not null,
    edi_ship_to_type                    varchar2(10 char)             not null,
    edi_tran_code                       varchar2(10 char)             not null);

/**/
/* Comments
/**/
comment on table edi.whslr_transaction is 'Collection Agency Transaction Table';
comment on column edi.whslr_transaction.sap_order_type is 'SAP order type - code or *';
comment on column edi.whslr_transaction.sap_invoice_type is 'SAP invoice type - code or *';
comment on column edi.whslr_transaction.edi_ship_to_type is 'EDI ship to type - code or *';
comment on column edi.whslr_transaction.edi_tran_code is 'EDI transaction code';

/**/
/* Primary Key Constraint
/**/
alter table edi.whslr_transaction
   add constraint whslr_transaction_pk primary key (sap_order_type, sap_invoice_type, edi_ship_to_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.whslr_transaction to dw_app;
grant select on edi.whslr_transaction to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym whslr_transaction for edi.whslr_transaction;
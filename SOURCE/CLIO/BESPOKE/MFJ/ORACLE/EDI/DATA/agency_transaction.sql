/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : agency_transaction
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Collection Agency Transaction Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.agency_transaction
   (sap_invoice_type                    varchar2(10 char)             not null,
    sap_order_type                      varchar2(10 char)             not null,
    edi_tran_code                       varchar2(10 char)             not null);

/**/
/* Comments
/**/
comment on table edi.agency_transaction is 'Collection Agency Transaction Table';
comment on column edi.agency_transaction.sap_invoice_type is 'SAP invoice type - code or *';
comment on column edi.agency_transaction.sap_order_type is 'SAP order type - code or *';
comment on column edi.agency_transaction.edi_tran_code is 'EDI transaction code';

/**/
/* Primary Key Constraint
/**/
alter table edi.agency_transaction
   add constraint agency_transaction_pk primary key (sap_invoice_type, sap_order_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.agency_transaction to dw_app;
grant select on edi.agency_transaction to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym agency_transaction for edi.agency_transaction;
/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : whslr_dly_inv_hdr
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Wholesaler Daily Invoice Header Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.whslr_dly_inv_hdr
   (sap_company_code                varchar2(10 char)             not null,
    sap_creatn_date                 varchar2(10 char)             not null,
    sap_invoice_number              varchar2(35 char)             not null,
    sap_order_type                  varchar2(35 char)             null,
    sap_invoice_type                varchar2(35 char)             null,
    sap_payer_code                  varchar2(17 char)             null,
    sap_prmry_code                  varchar2(17 char)             null,
    sap_scdry_code                  varchar2(17 char)             null,
    sap_shpto_code                  varchar2(17 char)             null,
    sap_refnr_number                varchar2(35 char)             null,
    edi_partn_code                  varchar2(20 char)             null,
    edi_partn_name                  varchar2(128 char)            null,
    edi_sndto_code                  varchar2(20 char)             null,
    edi_whslr_code                  varchar2(20 char)             null,
    edi_brnch_code                  varchar2(20 char)             null,
    edi_brnch_name                  varchar2(128 char)            null,
    edi_sldto_code                  varchar2(20 char)             null,
    edi_sldto_name                  varchar2(128 char)            null,
    edi_shpto_code                  varchar2(20 char)             null,
    edi_shpto_pcde                  varchar2(10 char)             null,
    edi_shpto_name                  varchar2(128 char)            null,
    edi_shpto_addr                  varchar2(128 char)            null,
    edi_ordby_code                  varchar2(20 char)             null,
    edi_invoice_number              varchar2(35 char)             null,
    edi_invoice_date                varchar2(8 char)              null,
    edi_order_number                varchar2(35 char)             null,
    edi_order_date                  varchar2(8 char)              null,
    edi_disc_code                   varchar2(1 char)              null,
    edi_tran_code                   varchar2(10 char)             null,
    edi_ship_to_type                varchar2(30 char)             null,
    edi_case_qty                    number                        null,
    edi_amount                      number                        null,
    edi_discount                    number                        null,
    edi_balance                     number                        null,
    edi_tax                         number                        null,
    edi_value                       number                        null,
    edi_disc_volume_cnt             number                        null,
    edi_disc_volume_pct             number                        null,
    edi_disc_volume                 number                        null,
    edi_disc_noreturn               number                        null,
    edi_disc_earlypay               number                        null);

/**/
/* Comments
/**/
comment on table edi.whslr_dly_inv_hdr is 'Wholesaler Daily Invoice Header Table';

/**/
/* Primary Key Constraint
/**/
alter table edi.whslr_dly_inv_hdr
   add constraint whslr_dly_inv_hdr_pk primary key (sap_invoice_number);

/**/
/* Indexes
/**/
create index whslr_dly_inv_hdr_ix01 on whslr_dly_inv_hdr (sap_creatn_date);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.whslr_dly_inv_hdr to dw_app;
grant select on edi.whslr_dly_inv_hdr to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym whslr_dly_inv_hdr for edi.whslr_dly_inv_hdr;
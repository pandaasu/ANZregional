/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : whslr_mly_inv_det
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Wholesaler Monthly Invoice Detail Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.whslr_mly_inv_det
   (sap_company_code                varchar2(10 char)             not null,
    edi_sndto_code                  varchar2(20 char)             not null,
    edi_bilto_date                  varchar2(8 char)              not null,
    edi_brnch_code                  varchar2(20 char)             not null,
    edi_invoice_number              varchar2(35 char)             not null,
    edi_invoice_date                varchar2(8 char)              null,
    edi_sldto_code                  varchar2(20 char)             null,
    edi_tran_code                   varchar2(10 char)             null,
    edi_ship_to_type                varchar2(30 char)             null,
    edi_order_number                varchar2(35 char)             null,
    edi_order_date                  varchar2(8 char)              null,
    edi_amount                      number                        null,
    edi_discount                    number                        null,
    edi_balance                     number                        null,
    edi_tax                         number                        null,
    edi_value                       number                        null,
    edi_disc_volume                 number                        null,
    edi_disc_noreturn               number                        null,
    edi_disc_earlypay               number                        null);

/**/
/* Comments
/**/
comment on table edi.whslr_mly_inv_det is 'Wholesaler Monthly Invoice Detail Table';

/**/
/* Primary Key Constraint
/**/
alter table edi.whslr_mly_inv_det
   add constraint whslr_mly_inv_det_pk primary key (sap_company_code, edi_sndto_code, edi_bilto_date, edi_brnch_code, edi_invoice_number);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.whslr_mly_inv_det to dw_app;
grant select on edi.whslr_mly_inv_det to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym whslr_mly_inv_det for edi.whslr_mly_inv_det;
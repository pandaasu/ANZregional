/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : whslr_dly_inv_det
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Wholesaler Daily Invoice Detail Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.whslr_dly_inv_det
   (sap_company_code                varchar2(10 char)             not null,
    sap_creatn_date                 varchar2(10 char)             not null,
    sap_invoice_number              varchar2(35 char)             not null,
    sap_invoice_line                number                        not null,
    sap_unit_price                  number                        null,
    sap_amount                      number                        null,
    sap_disc_volume_pct             number                        null,
    sap_disc_volume                 number                        null,
    sap_disc_noreturn               number                        null,
    sap_disc_earlypay               number                        null,
    edi_material_code               varchar2(35 char)             null,
    edi_material_name               varchar2(40 char)             null,
    edi_rsu_per_tdu                 number                        null,
    edi_case_qty                    number                        null,
    edi_delivered_qty               number                        null,
    edi_unit_price                  number                        null,
    edi_amount                      number                        null);

/**/
/* Comments
/**/
comment on table edi.whslr_dly_inv_det is 'Wholesaler Daily Invoice Detail Table';

/**/
/* Primary Key Constraint
/**/
alter table edi.whslr_dly_inv_det
   add constraint whslr_dly_inv_det_pk primary key (sap_invoice_number, sap_invoice_line);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.whslr_dly_inv_det to dw_app;
grant select on edi.whslr_dly_inv_det to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym whslr_dly_inv_det for edi.whslr_dly_inv_det;
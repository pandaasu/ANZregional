/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : whslr_mly_inv_bch
 Owner  : od

 Description
 -----------
 Electronic Data Interchange - Wholesaler Monthly Invoice Branch Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.whslr_mly_inv_bch
   (sap_company_code                varchar2(10 char)             not null,
    edi_sndto_code                  varchar2(20 char)             not null,
    edi_bilto_date                  varchar2(8 char)              not null,
    edi_brnch_code                  varchar2(20 char)             not null,
    edi_brnch_name                  varchar2(128 char)            null,
    edi_count                       number                        null,
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
comment on table edi.whslr_mly_inv_bch is 'Wholesaler Monthly Invoice Branch Table';

/**/
/* Primary Key Constraint
/**/
alter table edi.whslr_mly_inv_bch
   add constraint whslr_mly_inv_bch_pk primary key (sap_company_code, edi_sndto_code, edi_bilto_date, edi_brnch_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.whslr_mly_inv_bch to dw_app;
grant select on edi.whslr_mly_inv_bch to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym whslr_mly_inv_bch for edi.whslr_mly_inv_bch;
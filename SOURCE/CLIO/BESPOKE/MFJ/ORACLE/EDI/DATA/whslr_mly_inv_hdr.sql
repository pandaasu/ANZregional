/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : whslr_mly_inv_hdr
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Wholesaler Monthly Invoice Header Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.whslr_mly_inv_hdr
   (edi_sndto_code                  varchar2(20 char)             not null,
    edi_bilto_date                  varchar2(8 char)              not null,
    edi_bilto_str_date              varchar2(8 char)              not null,
    edi_bilto_end_date              varchar2(8 char)              not null,
    edi_sndon_date                  varchar2(8 char)              not null,
    edi_snton_date                  varchar2(8 char)              not null,
    edi_partn_code                  varchar2(20 char)             null,
    edi_partn_name                  varchar2(128 char)            null,
    edi_whslr_code                  varchar2(20 char)             null,
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
comment on table edi.whslr_mly_inv_hdr is 'Wholesaler Monthly Invoice Header Table';

/**/
/* Primary Key Constraint
/**/
alter table edi.whslr_mly_inv_hdr
   add constraint whslr_mly_inv_hdr_pk primary key (edi_sndto_code, edi_bilto_date);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.whslr_mly_inv_hdr to dw_app;
grant select on edi.whslr_mly_inv_hdr to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym whslr_mly_inv_hdr for edi.whslr_mly_inv_hdr;
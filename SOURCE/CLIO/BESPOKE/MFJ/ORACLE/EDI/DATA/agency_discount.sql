/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : agency_discount
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Collection Agency Discount Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.agency_discount
   (edi_disc_code                       varchar2(10 char)             not null,
    edi_disc_name                       varchar2(128 char)            not null);

/**/
/* Comments
/**/
comment on table edi.agency_discount is 'Collection Agency Discount Table';
comment on column edi.agency_discount.edi_disc_code is 'EDI discount code';
comment on column edi.agency_discount.edi_disc_name is 'EDI discount description';

/**/
/* Primary Key Constraint
/**/
alter table edi.agency_discount
   add constraint agency_discount_pk primary key (edi_disc_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.agency_discount to dw_app;
grant select on edi.agency_discount to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym agency_discount for edi.agency_discount;
/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : payer_link
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Payer Link Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.payer_link
   (sap_payer_code                      varchar2(10 char)             not null,
    edi_link_type                       varchar2(10 char)             not null,
    edi_link_code                       varchar2(20 char)             not null);

/**/
/* Comments
/**/
comment on table edi.payer_link is 'Collection Agency Link Table';
comment on column edi.payer_link.sap_payer_code is 'SAP payer customer code';
comment on column edi.payer_link.edi_link_type is 'EDI collection link type (*AGENCY,*WHSLR)';
comment on column edi.payer_link.edi_link_code is 'EDI collection link code';

/**/
/* Primary Key Constraint
/**/
alter table edi.payer_link
   add constraint payer_link_pk primary key (sap_payer_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.payer_link to dw_app;
grant select on edi.payer_link to public with grant option;

/**/
/* Synonym
/**/
create public synonym payer_link for edi.payer_link;
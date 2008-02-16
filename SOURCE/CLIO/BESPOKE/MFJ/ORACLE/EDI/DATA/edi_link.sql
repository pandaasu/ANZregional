/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : edi_link
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - EDI Link Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.edi_link
   (sap_cust_type                       varchar2(10 char)             not null,
    sap_cust_code                       varchar2(10 char)             not null,
    edi_link_type                       varchar2(10 char)             not null,
    edi_link_code                       varchar2(20 char)             not null);

/**/
/* Comments
/**/
comment on table edi.edi_link is 'EDI Link Table';
comment on column edi.edi_link.sap_cust_type is 'SAP customer type (*PAYER,*SOLDTO)';
comment on column edi.edi_link.sap_cust_code is 'SAP customer code';
comment on column edi.edi_link.edi_link_type is 'EDI link type (*AGENCY,*WHSLR)';
comment on column edi.edi_link.edi_link_code is 'EDI link code';

/**/
/* Primary Key Constraint
/**/
alter table edi.edi_link
   add constraint edi_link_pk primary key (sap_cust_type, sap_cust_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.edi_link to dw_app;
grant select on edi.edi_link to public with grant option;

/**/
/* Synonym
/**/
create public synonym edi_link for edi.edi_link;
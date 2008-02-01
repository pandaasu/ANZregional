/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : agency_interface
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Collection Agency Interface Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.agency_interface
   (edi_agency_code                     varchar2(20 char)             not null,
    sap_sales_org_code                  varchar2(10 char)             not null,
    sap_distbn_chnl_code                varchar2(10 char)             not null,
    sap_division_code                   varchar2(10 char)             not null,
    edi_interface                       varchar2(32 char)             not null);

/**/
/* Comments
/**/
comment on table edi.agency_interface is 'Collection Agency Interface Table';
comment on column edi.agency_interface.edi_agency_code is 'EDI collection agency code';
comment on column edi.agency_interface.sap_sales_org_code is 'SAP sales organisation code';
comment on column edi.agency_interface.sap_distbn_chnl_code is 'SAP distribution channel code';
comment on column edi.agency_interface.sap_division_code is 'SAP division code';
comment on column edi.agency_interface.edi_interface is 'EDI Interface code';

/**/
/* Primary Key Constraint
/**/
alter table edi.agency_interface
   add constraint agency_interface_pk primary key (edi_agency_code, sap_sales_org_code, sap_distbn_chnl_code, sap_division_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.agency_interface to dw_app;
grant select on edi.agency_interface to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym agency_interface for edi.agency_interface;
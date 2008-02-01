/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : company
 Owner  : od

 Description
 -----------
 Operational Data Store - Company Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.company
   (sap_company_code  varchar2(6 char)            not null,
    company_desc      varchar2(60 char)           not null,
    sap_currcy_code   varchar2(5 char)            not null,
    reg_company_code  varchar2(6 char)            not null,
    company_lupdp     varchar2(8 char)            not null,
    company_lupdt     date                        not null);

/**/
/* Comments
/**/
comment on table od.company is 'Company Table';
comment on column od.company.sap_company_code is 'SAP Company Code';
comment on column od.company.company_desc is 'Company Description';
comment on column od.company.sap_currcy_code is 'SAP Currency Code';
comment on column od.company.reg_company_code is 'Regional Company Code';
comment on column od.company.company_lupdp is 'last updated person';
comment on column od.company.company_lupdt is 'last updated time';

/**/
/* Primary Key Constraint
/**/
alter table od.company
   add constraint company_pk primary key (sap_company_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.company to dw_app;
grant select on od.company to od_app with grant option;
grant select on od.company to od_user;
grant select on od.company to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym company for od.company;
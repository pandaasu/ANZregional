/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : currency
 Owner  : od

 Description
 -----------
 Operational Data Store - Currency Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.currency
   (sap_currcy_code  varchar2(5 char)                  not null,
    currcy_desc      varchar2(40 char)                 not null,
    currcy_lupdp     varchar2(8 char)                  not null,
    currcy_lupdt     date                              not null);

/**/
/* Comments
/**/
comment on table od.currency is 'Currency Table';
comment on column od.currency.sap_currcy_code is 'SAP Currency Code';
comment on column od.currency.currcy_desc IS 'Currency Description';
comment on column od.currency.currcy_lupdp is 'Last Updated Person';
comment on column od.currency.currcy_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.currency
   add constraint currency_pk primary key (sap_currcy_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.currency to dw_app;
grant select on od.currency to od_app with grant option;
grant select on od.currency to od_user;
grant select on od.currency to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym currency for od.currency;
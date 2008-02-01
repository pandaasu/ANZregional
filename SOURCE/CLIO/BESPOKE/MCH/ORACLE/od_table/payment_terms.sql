/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : payment_terms
 Owner  : od

 Description
 -----------
 Operational Data Store - Payment Terms Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.payment_terms
   (sap_payment_terms_code  varchar2(17 char)          not null,
    payment_terms_desc      varchar2(40 char)          not null,
    payment_terms_lupdp     varchar2(8 char)           not null,
    payment_terms_lupdt     date                       not null);

/**/
/* Comments
/**/
comment on table od.payment_terms is 'Payment Terms Table';
comment on column od.payment_terms.sap_payment_terms_code is 'SAP Payment Terms Code';
comment on column od.payment_terms.payment_terms_desc is 'Payment Terms Description';
comment on column od.payment_terms.payment_terms_lupdp is 'Last Updated Person';
comment on column od.payment_terms.payment_terms_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.payment_terms
   add constraint payment_terms_pk primary key (sap_payment_terms_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.payment_terms to dw_app;
grant select on od.payment_terms to od_app with grant option;
grant select on od.payment_terms to od_user;
grant select on od.payment_terms to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym payment_terms for od.payment_terms;
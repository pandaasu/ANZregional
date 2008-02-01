/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : multi_lang_literal
 Owner  : od

 Description
 -----------
 Operational Data Store - Multiple Language Literal Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.multi_lang_literal
   (literal_code              number(8)                not null,
    sap_lang_code             varchar2(2 char)         not null,
    literal_desc              varchar2(60 char)        not null,
    multi_lang_literal_lupdp  varchar2(8 char)         not null,
    multi_lang_literal_lupdt  date                     not null);

/**/
/* Comments
/**/
comment on table od.multi_lang_literal is 'Multiple Language Literal Table';
comment on column od.multi_lang_literal.literal_code is 'Literal Code';
comment on column od.multi_lang_literal.sap_lang_code is 'SAP Language Code';
comment on column od.multi_lang_literal.literal_desc is 'Literal Description';
comment on column od.multi_lang_literal.multi_lang_literal_lupdp is 'Last Updated Person';
comment on column od.multi_lang_literal.multi_lang_literal_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.multi_lang_literal
   add constraint multi_lang_literal_pk primary key (literal_code);

/**/
/* Foreign Key Constraints
/**/
alter table od.multi_lang_literal
   add constraint multi_lang_literal_fk01 foreign key (sap_lang_code) 
      references od.language (sap_lang_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.multi_lang_literal to dw_app;
grant select on od.multi_lang_literal to od_app with grant option;
grant select on od.multi_lang_literal to od_user;
grant select on od.multi_lang_literal to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym multi_lang_literal for od.multi_lang_literal;
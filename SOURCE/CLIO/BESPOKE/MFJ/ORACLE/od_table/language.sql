/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : language
 Owner  : od

 Description
 -----------
 Operational Data Store - Language Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.language
   (sap_lang_code  varchar2(2 char)                    not null,
    lang_desc      varchar2(40 char)                   not null,
    lang_lupdp     varchar2(8 char)                    not null,
    lang_lupdt     date                                not null);

/**/
/* Comments
/**/
comment on table od.language is 'Language Table';
comment on column od.language.sap_lang_code is 'SAP Language Code';
comment on column od.language.lang_desc is 'Language Description';
comment on column od.language.lang_lupdp is 'Last Updated Person';
comment on column od.language.lang_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.language
   add constraint language_pk primary key (sap_lang_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.language to dw_app;
grant select on od.language to od_app with grant option;
grant select on od.language to od_user;
grant select on od.language to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym language for od.language;
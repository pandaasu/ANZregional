/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_text
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Text

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_text
   (customer_code                      varchar2(10 char)        not null,
    text_object                        varchar2(10 char)        not null,
    text_name                          varchar2(70 char)        not null,
    text_id                            varchar2(5 char)         not null,
    text_language                      varchar2(5 char)         not null,
    text_type                          varchar2(6 char)         not null,
    text_language_iso                  varchar2(2 char)         null,
    text_line                          varchar2(2000 char)      null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_text is 'Business Data Store - Customer Text Header';
comment on column bds_cust_text.customer_code is 'Customer Number - lads_cus_hth.kunnr';
comment on column bds_cust_text.text_object is 'Texts: application object - lads_cus_hth.tdobject';
comment on column bds_cust_text.text_name is 'Name - lads_cus_hth.tdname';
comment on column bds_cust_text.text_id is 'Text ID - lads_cus_hth.tdid';
comment on column bds_cust_text.text_language is 'Language Key - lads_cus_hth.tdspras';
comment on column bds_cust_text.text_type is 'SAPscript: Format of Text - lads_cus_hth.tdtexttype';
comment on column bds_cust_text.text_language_iso is 'Language according to ISO 639 - lads_cus_hth.tdsprasiso';
comment on column bds_cust_text.text_line is 'Text line - lads_cus_htd.tdline';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_text
   add constraint bds_cust_text_pk primary key (customer_code, text_object, text_name, text_id, text_language, text_type);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_text to lics_app;
grant select, insert, update, delete on bds_cust_text to lads_app;
grant select, insert, update, delete on bds_cust_text to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_text for bds.bds_cust_text;
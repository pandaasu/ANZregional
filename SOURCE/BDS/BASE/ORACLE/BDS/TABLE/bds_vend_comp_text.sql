/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_vend_comp_text
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Vendor Company Text

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_vend_comp_text
   (vendor_code                        varchar2(10 char)        not null,
    company_code                       varchar2(6 char)         not null,
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
comment on table bds_vend_comp_text is 'Business Data Store - Vendor Company Text';
comment on column bds_vend_comp_text.vendor_code is 'Account Number of Vendor or Creditor - lads_ven_ctx.lifnr';
comment on column bds_vend_comp_text.company_code is 'Company Code - lads_ven_ccd.bukrs';
comment on column bds_vend_comp_text.text_object is 'Texts: application object - lads_ven_ctx.tdobject';
comment on column bds_vend_comp_text.text_name is 'Name - lads_ven_ctx.tdname';
comment on column bds_vend_comp_text.text_id is 'Text ID - lads_ven_ctx.tdid';
comment on column bds_vend_comp_text.text_language is 'Language Key - lads_ven_ctx.tdspras';
comment on column bds_vend_comp_text.text_type is 'SAPscript: Format of Text - lads_ven_ctx.tdtexttype';
comment on column bds_vend_comp_text.text_language_iso is 'Language according to ISO 639 - lads_ven_ctx.tdsprasiso';
comment on column bds_vend_comp_text.text_line is 'Text line - lads_ven_ctd.tdline';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_vend_comp_text
   add constraint bds_vend_comp_text_pk primary key (vendor_code, company_code, text_object, text_name, text_id, text_language, text_type);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_vend_comp_text to lics_app;
grant select, insert, update, delete on bds_vend_comp_text to lads_app;
grant select, insert, update, delete on bds_vend_comp_text to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_vend_comp_text for bds.bds_vend_comp_text;
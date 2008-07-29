/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_sales_area_text
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Sales Area Text

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_sales_area_text
   (customer_code                      varchar2(10 char)        not null,
    sales_org_code                     varchar2(5 char)         not null,
    distbn_chnl_code                   varchar2(5 char)         not null,
    division_code                      varchar2(5 char)         not null,
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
comment on table bds_cust_sales_area_text is 'Business Data Store - Customer Sales Area Text Header';
comment on column bds_cust_sales_area_text.customer_code is 'Customer Number - lads_cus_sat.kunnr';
comment on column bds_cust_sales_area_text.sales_org_code is 'Sales Organization - lads_cus_sad.vkorg';
comment on column bds_cust_sales_area_text.distbn_chnl_code is 'Distribution Channel - lads_cus_sad.vtweg';
comment on column bds_cust_sales_area_text.division_code is 'Division - lads_cus_sad.spart';
comment on column bds_cust_sales_area_text.text_object is 'Texts: application object - lads_cus_sat.tdobject';
comment on column bds_cust_sales_area_text.text_name is 'Name - lads_cus_sat.tdname';
comment on column bds_cust_sales_area_text.text_id is 'Text ID - lads_cus_sat.tdid';
comment on column bds_cust_sales_area_text.text_language is 'Language Key - lads_cus_sat.tdspras';
comment on column bds_cust_sales_area_text.text_type is 'SAPscript: Format of Text - lads_cus_sat.tdtexttype';
comment on column bds_cust_sales_area_text.text_language_iso is 'Language according to ISO 639 - lads_cus_sat.tdsprasiso';
comment on column bds_cust_sales_area_text.text_line is 'Text line - lads_cus_std.tdline';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_sales_area_text
   add constraint bds_cust_sales_area_text_pk primary key (customer_code, sales_org_code, distbn_chnl_code, division_code, text_object, text_name, text_id, text_language, text_type);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_sales_area_text to lics_app;
grant select, insert, update, delete on bds_cust_sales_area_text to lads_app;
grant select, insert, update, delete on bds_cust_sales_area_text to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_sales_area_text for bds.bds_cust_sales_area_text;
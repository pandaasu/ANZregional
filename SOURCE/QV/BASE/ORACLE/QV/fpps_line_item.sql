/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : fpps_line_item
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - fpps_line_item 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2011/05   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table fpps_line_item
(
  fli_version                           number not null,
  fli_line_item                         number not null,
  fli_line_item_owner                   varchar2(50 char) not null,
  fli_line_item_usage_owner             varchar2(50 char) not null,
  fli_line_item_classification          varchar2(500 char) not null,
  fli_line_item_short_desc              varchar2(20 char) not null,
  fli_line_item_long_desc               varchar2(100 char) not null,
  fli_sign_conversion                   varchar2(1 char) null,
  fli_financial_unit                    varchar2(20 char) not null,
  fli_std_ref_indicator                 varchar2(1 char) not null,
  fli_aggregate_data                    varchar2(1 char) not null,
  fli_ignore                            varchar2(1 char) not null,
  fli_usage                             varchar2(20 char) not null,
  fli_force_calc                        varchar2(5 char) null,
  fli_disable_allocation                varchar2(5 char) null
);

/**/
/* Comments 
/**/
comment on table fpps_line_item is 'FPPS - Line Item Master Data';
comment on column fpps_line_item.fli_version is 'FPPS Line Item - load version';
comment on column fpps_line_item.fli_line_item is 'FPPS Line Item - line item';
comment on column fpps_line_item.fli_line_item_owner is 'FPPS Line Item - line item owner';
comment on column fpps_line_item.fli_line_item_usage_owner is 'FPPS Line Item - line item usage owner';
comment on column fpps_line_item.fli_line_item_classification is 'FPPS Line Item - line item classification';
comment on column fpps_line_item.fli_line_item_short_desc is 'FPPS Line Item - line item short description';
comment on column fpps_line_item.fli_line_item_long_desc is 'FPPS Line Item - line item long description';
comment on column fpps_line_item.fli_sign_conversion is 'FPPS Line Item - sign conversion';
comment on column fpps_line_item.fli_financial_unit is 'FPPS Line Item - financial unit';
comment on column fpps_line_item.fli_std_ref_indicator is 'FPPS Line Item - standard reference indicator';
comment on column fpps_line_item.fli_aggregate_data is 'FPPS Line Item - aggregate data indicator';
comment on column fpps_line_item.fli_ignore is 'FPPS Line Item - ignore MAA/MAT/Y TD/YEE/YT G indicator';
comment on column fpps_line_item.fli_usage is 'FPPS Line Item - usage';
comment on column fpps_line_item.fli_force_calc is 'FPPS Line Item - force calculation flag';
comment on column fpps_line_item.fli_disable_allocation is 'FPPS Line Item - disable allocation flag';

/**/
/* Primary Key Constraint 
/**/
alter table fpps_line_item
   add constraint fpps_line_item_pk primary key (fli_version, fli_line_item);

/**/
/* Authority 
/**/
grant select, insert, update, delete on fpps_line_item to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym fpps_line_item for qv.fpps_line_item;

/**/
/* Sequence 
/**/
create sequence fpps_line_item_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;
   
/**/
/* Authority
/**/
grant select on fpps_line_item_seq to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym fpps_line_item_seq for qv.fpps_line_item_seq;
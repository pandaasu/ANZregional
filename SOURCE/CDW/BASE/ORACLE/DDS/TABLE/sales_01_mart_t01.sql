/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Table   : sales_01_mart_t01
 Owner   : dds
 Author  : Steve Gregan

 Description
 -----------
 Dimensional Data Store - Sales Mart 01 Header

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/09   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sales_01_mart_t01
   (company_code varchar2(6 char) not null,
    extract_date date not null,
    extract_str_time date not null,
    extract_end_time date not null,
    sale_extract_date date not null,
    fcst_extract_date date not null,
    current_yyyy number(4,0) not null,
    current_yyyypp number(6,0) not null,
    current_yyyyppw number(7,0) not null,
    current_pp number(2,0) not null,
    current_yw number(2,0) not null,
    current_pw number(2,0) not null,
    p01_heading varchar2(50 char) not null,
    p02_heading varchar2(50 char) not null,
    p03_heading varchar2(50 char) not null,
    p04_heading varchar2(50 char) not null,
    p05_heading varchar2(50 char) not null,
    p06_heading varchar2(50 char) not null,
    p07_heading varchar2(50 char) not null,
    p08_heading varchar2(50 char) not null,
    p09_heading varchar2(50 char) not null,
    p10_heading varchar2(50 char) not null,
    p11_heading varchar2(50 char) not null,
    p12_heading varchar2(50 char) not null,
    p13_heading varchar2(50 char) not null,
    p14_heading varchar2(50 char) not null,
    p15_heading varchar2(50 char) not null,
    p16_heading varchar2(50 char) not null,
    p17_heading varchar2(50 char) not null,
    p18_heading varchar2(50 char) not null,
    p19_heading varchar2(50 char) not null,
    p20_heading varchar2(50 char) not null,
    p21_heading varchar2(50 char) not null,
    p22_heading varchar2(50 char) not null,
    p23_heading varchar2(50 char) not null,
    p24_heading varchar2(50 char) not null,
    p25_heading varchar2(50 char) not null,
    p26_heading varchar2(50 char) not null,
    p27_heading varchar2(50 char) not null);

/**/
/* Comments
/**/
comment on table sales_01_mart_t01 is 'Sales Mart 01 Header Table';
comment on column sales_01_mart_t01.company_code is 'Company code';
comment on column sales_01_mart_t01.extract_date is 'Extract date';
comment on column sales_01_mart_t01.extract_str_time is 'Extract start time';
comment on column sales_01_mart_t01.extract_end_time is 'Extract end time';
comment on column sales_01_mart_t01.sale_extract_date is 'Sale extract date';
comment on column sales_01_mart_t01.fcst_extract_date is 'Forecast extract date';
comment on column sales_01_mart_t01.current_yyyy is 'Current year';
comment on column sales_01_mart_t01.current_yyyypp is 'Current period';
comment on column sales_01_mart_t01.current_yyyyppw is 'Current week';
comment on column sales_01_mart_t01.current_pp is 'Current period number';
comment on column sales_01_mart_t01.current_yw is 'Current year week number';
comment on column sales_01_mart_t01.current_pw is 'Current period week number';
comment on column sales_01_mart_t01.p01_heading is 'P01 heading';
comment on column sales_01_mart_t01.p02_heading is 'P02 heading';
comment on column sales_01_mart_t01.p03_heading is 'P03 heading';
comment on column sales_01_mart_t01.p04_heading is 'P04 heading';
comment on column sales_01_mart_t01.p05_heading is 'P05 heading';
comment on column sales_01_mart_t01.p06_heading is 'P06 heading';
comment on column sales_01_mart_t01.p07_heading is 'P07 heading';
comment on column sales_01_mart_t01.p08_heading is 'P08 heading';
comment on column sales_01_mart_t01.p09_heading is 'P09 heading';
comment on column sales_01_mart_t01.p10_heading is 'P10 heading';
comment on column sales_01_mart_t01.p11_heading is 'P11 heading';
comment on column sales_01_mart_t01.p12_heading is 'P12 heading';
comment on column sales_01_mart_t01.p13_heading is 'P13 heading';
comment on column sales_01_mart_t01.p14_heading is 'P14 heading';
comment on column sales_01_mart_t01.p15_heading is 'P15 heading';
comment on column sales_01_mart_t01.p16_heading is 'P16 heading';
comment on column sales_01_mart_t01.p17_heading is 'P17 heading';
comment on column sales_01_mart_t01.p18_heading is 'P18 heading';
comment on column sales_01_mart_t01.p19_heading is 'P19 heading';
comment on column sales_01_mart_t01.p20_heading is 'P20 heading';
comment on column sales_01_mart_t01.p21_heading is 'P21 heading';
comment on column sales_01_mart_t01.p22_heading is 'P22 heading';
comment on column sales_01_mart_t01.p23_heading is 'P23 heading';
comment on column sales_01_mart_t01.p24_heading is 'P24 heading';
comment on column sales_01_mart_t01.p25_heading is 'P25 heading';
comment on column sales_01_mart_t01.p26_heading is 'P26 heading';
comment on column sales_01_mart_t01.p27_heading is 'P27 heading';

/**/
/* Primary Key Constraint
/**/
alter table sales_01_mart_t01
   add constraint sales_01_mart_t01_pk primary key (company_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on sales_01_mart_t01 to dw_app;
grant select on sales_01_mart_t01 to public;

/**/
/* Synonym
/**/
create or replace public synonym sales_01_mart_t01 for dds.sales_01_mart_t01;
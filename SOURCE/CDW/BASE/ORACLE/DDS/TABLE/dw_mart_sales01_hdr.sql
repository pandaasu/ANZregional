/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Table   : dw_mart_sales01_hdr
 Owner   : dds
 Author  : Steve Gregan

 Description
 -----------
 Dimensional Data Store - Mart Sales 01 Header

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dw_mart_sales01_hdr
   (company_code varchar2(6 char) not null,
    extract_date date not null,
    extract_str_time date not null,
    extract_end_time date not null,
    extract_yyyypp number(6,0) not null,
    current_yyyy number(4,0) not null,
    current_yyyypp number(6,0) not null,
    current_yyyyppw number(7,0) not null,
    current_yyyyppdd number(8,0) not null,
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
    p26_heading varchar2(50 char) not null);

/**/
/* Comments
/**/
comment on table dw_mart_sales01_hdr is 'Mart Sales 01 Header Table';
comment on column dw_mart_sales01_hdr.company_code is 'Company code';
comment on column dw_mart_sales01_hdr.extract_date is 'Extract date';
comment on column dw_mart_sales01_hdr.extract_str_time is 'Extract start time';
comment on column dw_mart_sales01_hdr.extract_end_time is 'Extract end time';
comment on column dw_mart_sales01_hdr.extract_yyyypp is 'Extract period';
comment on column dw_mart_sales01_hdr.current_yyyy is 'Current year';
comment on column dw_mart_sales01_hdr.current_yyyypp is 'Current period';
comment on column dw_mart_sales01_hdr.current_yyyyppw is 'Current week';
comment on column dw_mart_sales01_hdr.current_pp is 'Current period number';
comment on column dw_mart_sales01_hdr.current_yw is 'Current year week number';
comment on column dw_mart_sales01_hdr.current_pw is 'Current period week number';
comment on column dw_mart_sales01_hdr.p01_heading is 'P01 heading';
comment on column dw_mart_sales01_hdr.p02_heading is 'P02 heading';
comment on column dw_mart_sales01_hdr.p03_heading is 'P03 heading';
comment on column dw_mart_sales01_hdr.p04_heading is 'P04 heading';
comment on column dw_mart_sales01_hdr.p05_heading is 'P05 heading';
comment on column dw_mart_sales01_hdr.p06_heading is 'P06 heading';
comment on column dw_mart_sales01_hdr.p07_heading is 'P07 heading';
comment on column dw_mart_sales01_hdr.p08_heading is 'P08 heading';
comment on column dw_mart_sales01_hdr.p09_heading is 'P09 heading';
comment on column dw_mart_sales01_hdr.p10_heading is 'P10 heading';
comment on column dw_mart_sales01_hdr.p11_heading is 'P11 heading';
comment on column dw_mart_sales01_hdr.p12_heading is 'P12 heading';
comment on column dw_mart_sales01_hdr.p13_heading is 'P13 heading';
comment on column dw_mart_sales01_hdr.p14_heading is 'P14 heading';
comment on column dw_mart_sales01_hdr.p15_heading is 'P15 heading';
comment on column dw_mart_sales01_hdr.p16_heading is 'P16 heading';
comment on column dw_mart_sales01_hdr.p17_heading is 'P17 heading';
comment on column dw_mart_sales01_hdr.p18_heading is 'P18 heading';
comment on column dw_mart_sales01_hdr.p19_heading is 'P19 heading';
comment on column dw_mart_sales01_hdr.p20_heading is 'P20 heading';
comment on column dw_mart_sales01_hdr.p21_heading is 'P21 heading';
comment on column dw_mart_sales01_hdr.p22_heading is 'P22 heading';
comment on column dw_mart_sales01_hdr.p23_heading is 'P23 heading';
comment on column dw_mart_sales01_hdr.p24_heading is 'P24 heading';
comment on column dw_mart_sales01_hdr.p25_heading is 'P25 heading';
comment on column dw_mart_sales01_hdr.p26_heading is 'P26 heading';

/**/
/* Primary Key Constraint
/**/
alter table dw_mart_sales01_hdr
   add constraint dw_mart_sales01_hdr_pk primary key (company_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dw_mart_sales01_hdr to dw_app;
grant select on dw_mart_sales01_hdr to public;

/**/
/* Synonym
/**/
create or replace public synonym dw_mart_sales01_hdr for dds.dw_mart_sales01_hdr;
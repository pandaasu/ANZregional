/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : cdw 
 Table   : efex_cntl_hdr
 Owner   : ods 
 Author  : Steve Gregan 

 Description 
 ----------- 
 Operational Data Store - efex_cntl_hdr

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2010/06   Steve Gregan   Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table ods.efex_cntl_hdr
   (market_id           number                not null,
    extract_time        varchar2(14)          not null,
    extract_status      varchar2(32)          not null);

/**/
/* Primary Key Constraint 
/**/
alter table ods.efex_cntl_hdr
   add constraint efex_cntl_hdr_pk primary key (market_id , extract_time);

/**/
/* Column comments 
/**/
comment on table ods.efex_cntl_hdr is 'Operational Data Store - Efex Control Header';
comment on column ods.efex_cntl_hdr.market_id is 'Efex Market Unique Code';
comment on column ods.efex_cntl_hdr.extract_time is 'Efex Extract Time (YYYYMMDDHH24MISS)';
comment on column ods.efex_cntl_hdr.extract_status is 'Efex Extract Status (*CONTROL or *INTERFACE or *COMPLETED or *CANCELLED)';

/**/
/* Authority 
/**/
grant select, update, delete, insert on ods.efex_cntl_hdr to ods_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym efex_cntl_hdr for ods.efex_cntl_hdr;

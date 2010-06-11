/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : cdw 
 Table   : efex_cntl_det
 Owner   : ods 
 Author  : Steve Gregan 

 Description 
 ----------- 
 Operational Data Store - efex_cntl_det

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2010/06   Steve Gregan   Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table ods.efex_cntl_det
   (market_id           number                not null,
    extract_time        varchar2(14)          not null,
    iface_code          varchar2(32)          not null,
    iface_count         number                not null,
    iface_recvd         number                not null);

/**/
/* Primary Key Constraint 
/**/
alter table ods.efex_cntl_det
   add constraint efex_cntl_det_pk primary key (market_id , extract_time, iface_code);

/**/
/* Column comments 
/**/
comment on table ods.efex_cntl_det is 'Operational Data Store - Efex Control Detail';
comment on column ods.efex_cntl_det.market_id is 'Efex Market Unique Code';
comment on column ods.efex_cntl_det.extract_time is 'Efex Extract Time (YYYYMMDDHH24MISS)';
comment on column ods.efex_cntl_det.iface_code is 'Efex Interface Code';
comment on column ods.efex_cntl_det.iface_count is 'Efex Interface Count';
comment on column ods.efex_cntl_det.iface_recvd is 'Efex Interface Received';

/**/
/* Authority 
/**/
grant select, update, delete, insert on ods.efex_cntl_det to ods_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym efex_cntl_det for ods.efex_cntl_det;
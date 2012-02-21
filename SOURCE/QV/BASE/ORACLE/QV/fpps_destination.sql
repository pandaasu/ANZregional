/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : fpps_destination
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - fpps_destination 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2011/05   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table fpps_destination
(
  fde_version          number not null,
  fde_total            number not null,
  fde_total_desc       varchar2(50 char) not null,
  fde_mkt_group        number not null,
  fde_mkt_group_desc   varchar2(50 char) not null,
  fde_market           varchar2(10 char) not null,
  fde_market_desc      varchar2(50 char) not null
);

/**/
/* Comments 
/**/
comment on table fpps_destination is 'FPPS - Destination Master Data';
comment on column fpps_destination.fde_version is 'FPPS Destination - load version';
comment on column fpps_destination.fde_total is 'FPPS Destination - total';
comment on column fpps_destination.fde_total_desc is 'FPPS Destination - total description';
comment on column fpps_destination.fde_mkt_group is 'FPPS Destination - market group';
comment on column fpps_destination.fde_mkt_group_desc is 'FPPS Destination - market group description';
comment on column fpps_destination.fde_market is 'FPPS Destination - market';
comment on column fpps_destination.fde_market_desc is 'FPPS Destination - market description';

/**/
/* Authority 
/**/
grant select, insert, update, delete on fpps_destination to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym fpps_destination for qv.fpps_destination;

/**/
/* Sequence 
/**/
create sequence fpps_destination_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;
   
/**/
/* Authority
/**/
grant select on fpps_destination_seq to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym fpps_destination_seq for qv.fpps_destination_seq;
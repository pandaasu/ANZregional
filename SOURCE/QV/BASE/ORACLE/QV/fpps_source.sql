/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : fpps_source
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - fpps_source 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2011/05   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table fpps_source
(
  fsr_version      number not null,
  fsr_total        number not null,
  fsr_total_desc   varchar2(50 char) not null,
  fsr_group        number not null,
  fsr_group_desc   varchar2(50 char) not null,
  fsr_from         number not null,
  fsr_from_desc    varchar2(50 char) not null
);

/**/
/* Comments 
/**/
comment on table fpps_source is 'FPPS - Source Master Data';
comment on column fpps_source.fsr_version is 'FPPS Source - load version';
comment on column fpps_source.fsr_total is 'FPPS Source - total';
comment on column fpps_source.fsr_total_desc is 'FPPS Source - total description';
comment on column fpps_source.fsr_group is 'FPPS Source - group';
comment on column fpps_source.fsr_group_desc is 'FPPS Source - group description';
comment on column fpps_source.fsr_from is 'FPPS Source - from';
comment on column fpps_source.fsr_from_desc is 'FPPS Source - from description';

/**/
/* Indexes 
/**/
create index qv.fpps_source_idx01 on qv.fpps_source(fsr_from);

/**/
/* Authority 
/**/
grant select, insert, update, delete on fpps_source to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym fpps_source for qv.fpps_source;

/**/
/* Sequence 
/**/
create sequence fpps_source_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;
   
/**/
/* Authority
/**/
grant select on fpps_source_seq to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym fpps_source_seq for qv.fpps_source_seq;
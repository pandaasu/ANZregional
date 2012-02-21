/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : fpps_customer
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - fpps_customer 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2011/05   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table fpps_customer
(
  fcs_version        number not null,
  fcs_total          number not null,
  fcs_total_desc     varchar2(50 char) not null,
  fcs_int_acc        number not null,
  fcs_int_acc_desc   varchar2(50 char) not null
);

/**/
/* Comments 
/**/
comment on table fpps_customer is 'FPPS - Customer Master Data';
comment on column fpps_customer.fcs_version is 'FPPS Customer - load version';
comment on column fpps_customer.fcs_total is 'FPPS Customer - total';
comment on column fpps_customer.fcs_total_desc is 'FPPS Customer - total description';
comment on column fpps_customer.fcs_int_acc is 'FPPS Customer - internal account';
comment on column fpps_customer.fcs_int_acc_desc is 'FPPS Customer - internal account description';

/**/
/* Indexes 
/**/
create index qv.fpps_customer_idx01 on qv.fpps_customer(fcs_int_acc);

/**/
/* Authority 
/**/
grant select, insert, update, delete on fpps_customer to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym fpps_customer for qv.fpps_customer;

/**/
/* Sequence 
/**/
create sequence fpps_customer_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;
   
/**/
/* Authority
/**/
grant select on fpps_customer_seq to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym fpps_customer_seq for qv.fpps_customer_seq;
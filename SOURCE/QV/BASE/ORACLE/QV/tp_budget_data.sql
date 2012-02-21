/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : tp_budget_data
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - tp_budget_data 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2010/09   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table tp_budget_data
(
  tbd_version         number not null,
  tbd_date            date not null,
  tbd_demand_group    varchar2(128) not null,
  tbd_brand           varchar2(128) not null,
  tbd_mkt_sub_cat     varchar2(128) not null,
  tbd_mars_year       number not null,
  tbd_mars_period     number not null,
  tbd_mars_prd_wk     number not null,
  tbd_budget          number not null
);

/**/
/* Comments 
/**/
comment on table tp_budget_data is 'Trade Promotions - Budget Data';
comment on column tp_budget_data.tbd_version is 'Budget Data - load version';
comment on column tp_budget_data.tbd_date is 'Budget Data - as at date';
comment on column tp_budget_data.tbd_demand_group is 'Budget Data - demand group';
comment on column tp_budget_data.tbd_brand is 'Budget Data - brand';
comment on column tp_budget_data.tbd_mkt_sub_cat is 'Budget Data - market sub category';
comment on column tp_budget_data.tbd_mars_year is 'Budget Data - mars year (YYYY)';
comment on column tp_budget_data.tbd_mars_period is 'Budget Data - mars period (YYYYPP)';
comment on column tp_budget_data.tbd_mars_prd_wk is 'Budget Data - mars period week (YYYYPPW)';
comment on column tp_budget_data.tbd_budget is 'Budget Data - budget';

/**/
/* Indexes 
/**/
create index tp_budget_data_ix01 on tp_budget_data (tbd_date);

/**/
/* Authority 
/**/
grant select, insert, update, delete on tp_budget_data to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym tp_budget_data for qv.tp_budget_data;

/**/
/* Sequence 
/**/
create sequence tp_budget_data_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;
   
/**/
/* Authority
/**/
grant select on tp_budget_data_seq to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym tp_budget_data_seq for qv.tp_budget_data_seq;
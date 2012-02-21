/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : qv_trigger_data
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - qv_trigger_data 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2011/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table qv_trigger_data
(
   interface_num        varchar2(10 char),          
   date_updated         date,
   filter_01            varchar2(1000 char),
   filter_02            varchar2(1000 char),
   filter_03            varchar2(1000 char),
   filter_04            varchar2(1000 char),
   filter_05            varchar2(1000 char),
   filter_06            varchar2(1000 char),
   filter_07            varchar2(1000 char),
   filter_08            varchar2(1000 char),
   filter_09            varchar2(1000 char)
);

/**/
/* Comments 
/**/
comment on table qv_trigger_data is 'QV Trigger Data Table';
comment on column qv_trigger_data.interface_num is 'Trigger Table - interface';
comment on column qv_trigger_data.date_updated is 'Trigger Table - date updated';
comment on column qv_trigger_data.filter_01 is 'Trigger Table - filter 01';
comment on column qv_trigger_data.filter_02 is 'Trigger Table - filter 02';
comment on column qv_trigger_data.filter_03 is 'Trigger Table - filter 03';
comment on column qv_trigger_data.filter_04 is 'Trigger Table - filter 04';
comment on column qv_trigger_data.filter_05 is 'Trigger Table - filter 05';
comment on column qv_trigger_data.filter_06 is 'Trigger Table - filter 06';
comment on column qv_trigger_data.filter_07 is 'Trigger Table - filter 07';
comment on column qv_trigger_data.filter_08 is 'Trigger Table - filter 08';
comment on column qv_trigger_data.filter_09 is 'Trigger Table - filter 09';

/**/
/* Primary Key Constraint 
/**/
alter table qv_trigger_data
   add constraint qv_trigger_data_pk primary key (interface_num);

/**/
/* Authority 
/**/
grant select, insert, update, delete on qv_trigger_data to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_trigger_data for qv.qv_trigger_data;

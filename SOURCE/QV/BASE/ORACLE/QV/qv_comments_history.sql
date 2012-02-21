/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : qv_comments_history
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - Comments history table

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2010/10   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table qv_comments_history
(
  qch_dashboard       varchar2(128 char) not null,
  qch_tab             varchar2(128 char) not null,
  qch_object          varchar2(128 char),
  qch_date_added      date not null,
  qch_adding_user     varchar2(10 char) not null,  
  qch_date_removed    date not null,
  qch_removing_user   varchar2(10 char) not null,
  qch_comment         varchar2(4000 char) not null
);

/**/
/* Comments 
/**/
comment on table qv_comments_history is 'Qlikview - Comments history';
comment on column qv_comments_history.qch_dashboard is 'Comments history - dashboard the comment applies to';
comment on column qv_comments_history.qch_tab is 'Comments history - tab the comment applies to';
comment on column qv_comments_history.qch_object is 'Comments history - object the comment applies to';
comment on column qv_comments_history.qch_date_added is 'Comments history - date added';
comment on column qv_comments_history.qch_adding_user is 'Comments history - user adding data';
comment on column qv_comments_history.qch_date_removed is 'Comments history - date removed';
comment on column qv_comments_history.qch_removing_user is 'Comments history - user removing data';
comment on column qv_comments_history.qch_comment is 'Comments history - the comment';

/**/
/* Authority 
/**/
grant select, insert, update, delete on qv_comments_history to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_comments_history for qv.qv_comments_history;
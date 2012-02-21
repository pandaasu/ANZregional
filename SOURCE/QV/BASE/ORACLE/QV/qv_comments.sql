/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : qv_comments
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - Comments table

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2010/10   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table qv_comments
(
  qvc_id              number not null,
  qvc_date            date not null,
  qvc_user            varchar2(10 char) not null,
  qvc_remove_date     date not null,
  qvc_valid_period    varchar2(32 char) not null,
  qvc_dashboard       varchar2(128 char) not null,
  qvc_tab             varchar2(128 char) not null,
  qvc_object          varchar2(128 char),
  qvc_comment         varchar2(4000 char) not null
);

/**/
/* Comments 
/**/
comment on table qv_comments is 'Qlikview - Comments';
comment on column qv_comments.qvc_id is 'Comments - id number';
comment on column qv_comments.qvc_date is 'Comments - date added';
comment on column qv_comments.qvc_user is 'Comments - user adding data';
comment on column qv_comments.qvc_remove_date is 'Comments - date to remove comment';
comment on column qv_comments.qvc_valid_period is 'Comments - period of time comment is valid for';
comment on column qv_comments.qvc_dashboard is 'Comments - dashboard the comment applies to';
comment on column qv_comments.qvc_tab is 'Comments - tab the comment applies to';
comment on column qv_comments.qvc_object is 'Comments - object the comment applies to';
comment on column qv_comments.qvc_comment is 'Comments - the comment';

/**/
/* Primary Key Constraint 
/**/
alter table qv_comments
   add constraint qv_comments_pk primary key (qvc_id, qvc_dashboard, qvc_tab);

/**/
/* Authority 
/**/
grant select, insert, update, delete on qv_comments to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_comments for qv.qv_comments;
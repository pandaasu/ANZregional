/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_map_question
 Owner  : pts

 Description
 -----------
 Product Testing System - Map Question Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_map_question
   (mqu_map_code                    varchar2(32 char)             not null,
    mqu_que_code                    number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_map_question is 'Map Question Table';
comment on column pts.pts_map_question.mqu_map_code is 'Map code';
comment on column pts.pts_map_question.mqu_que_code is 'Question code';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_map_question
   add constraint pts_map_question_pk primary key (mqu_map_code, mqu_que_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_map_question to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_map_question for pts.pts_map_question;    
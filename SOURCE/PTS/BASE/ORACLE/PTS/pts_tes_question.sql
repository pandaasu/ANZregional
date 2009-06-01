/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_question
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Question Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_question
   (tqu_tes_code                    number                        not null,
    tqu_day_code                    number                        not null,
    tqu_que_code                    number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_question is 'Test Question Table';
comment on column pts.pts_tes_question.tqu_tes_code is 'Test code';
comment on column pts.pts_tes_question.tqu_day_code is 'Test Day code';
comment on column pts.pts_tes_question.tqu_que_code is 'Test question code';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_question
   add constraint pts_tes_question_pk primary key (tqu_tes_code, tqu_day_code, tqu_que_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_question to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_question for pts.pts_tes_question;            
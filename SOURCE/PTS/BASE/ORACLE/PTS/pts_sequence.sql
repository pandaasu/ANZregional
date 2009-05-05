/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_sequence
 Owner  : pts

 Description
 -----------
 Product Testing System - pts_sys_sequence

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Sequence creation
/**/
create sequence pts_hou_sequence
   increment by 1
   start with 100001
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence pts_pet_sequence
   increment by 1
   start with 100001
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence pts_sam_sequence
   increment by 1
   start with 100001
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence pts_question_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence pts_ptest_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

/**/
/* Authority
/**/
grant select on pts_hou_sequence to pts_app;
grant select on pts_pet_sequence to pts_app;
grant select on pts_sam_sequence to pts_app;

grant select on pts_question_sequence to pts_app;
grant select on pts_ptest_sequence to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_hou_sequence for pts.pts_hou_sequence;
create or replace public synonym pts_pet_sequence for pts.pts_pet_sequence;
create or replace public synonym pts_sam_sequence for pts.pts_sam_sequence;

create or replace public synonym pts_ptest_sequence for pts.pts_ptest_sequence;

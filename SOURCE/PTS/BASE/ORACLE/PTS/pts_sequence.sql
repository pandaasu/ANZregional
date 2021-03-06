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
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence pts_pet_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence pts_sam_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence pts_que_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence pts_stm_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence pts_pty_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence pts_int_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence pts_tes_sequence
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
grant select on pts_que_sequence to pts_app;
grant select on pts_stm_sequence to pts_app;
grant select on pts_pty_sequence to pts_app;
grant select on pts_int_sequence to pts_app;
grant select on pts_tes_sequence to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_hou_sequence for pts.pts_hou_sequence;
create or replace public synonym pts_pet_sequence for pts.pts_pet_sequence;
create or replace public synonym pts_sam_sequence for pts.pts_sam_sequence;
create or replace public synonym pts_que_sequence for pts.pts_que_sequence;
create or replace public synonym pts_stm_sequence for pts.pts_stm_sequence;
create or replace public synonym pts_pty_sequence for pts.pts_pty_sequence;
create or replace public synonym pts_int_sequence for pts.pts_int_sequence;
create or replace public synonym pts_tes_sequence for pts.pts_tes_sequence;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_que_response
 Owner  : pts

 Description
 -----------
 Product Testing System - Question Response Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_que_response
   (qre_que_code                    number                        not null,
    qre_res_code                    number                        not null,
    qre_res_text                    varchar2(2000 char)           not null);

/**/
/* Comments
/**/
comment on table pts.pts_que_response is 'Question Response Table';
comment on column pts.pts_que_response.qre_que_code is 'Question response question sequence';
comment on column pts.pts_que_response.qre_res_code is 'Question response code';
comment on column pts.pts_que_response.qre_res_text is 'Question response text';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_que_response
   add constraint pts_que_response_pk primary key (qre_que_code, qre_res_seqn);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_que_response to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_que_response for pts.pts_que_response;
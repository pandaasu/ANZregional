/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_que_definition
 Owner  : pts

 Description
 -----------
 Product Testing System - Question Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_que_definition
   (qde_que_code                    number                        not null,
    qde_que_text                    varchar2(4000 char)           not null,
    qde_que_status                  number                        not null,
    qde_upd_user                    varchar2(30 char)             not null,
    qde_upd_date                    date                          not null,
    qde_que_type                    number                        not null,
    qde_rsp_type                    number                        not null,
    qde_rsp_str_range               number                        null,
    qde_rsp_end_range               number                        null);

/**/
/* Comments
/**/
comment on table pts.pts_que_definition is 'Question Definition Table';
comment on column pts.pts_que_definition.qde_que_code is 'Question code';
comment on column pts.pts_que_definition.qde_que_text is 'Question definition text';
comment on column pts.pts_que_definition.qde_que_status is 'Question status';
comment on column pts.pts_que_definition.qde_upd_user is 'Question update user';
comment on column pts.pts_que_definition.qde_upd_date is 'Question update date';
comment on column pts.pts_que_definition.qde_que_type is 'Question type code';
comment on column pts.pts_que_definition.qde_rsp_type is 'Question response type';
comment on column pts.pts_que_definition.qde_rsp_str_range is 'Question response range start';
comment on column pts.pts_que_definition.qde_rsp_end_range is 'Question response range end';              

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_que_definition
   add constraint pts_que_definition_pk primary key (qde_que_code);

/**/
/* Indexes
/**/
create index pts_que_definition_ix01 on pts.pts_que_definition
   (qde_que_group, qde_que_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_que_definition to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_que_definition for pts.pts_que_definition;
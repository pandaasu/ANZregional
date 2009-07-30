/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_stm_definition
 Owner  : pts

 Description
 -----------
 Product Testing System - Selection Template Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_stm_definition
   (std_stm_code                    number                        not null,
    std_stm_text                    varchar2(120 char)            not null,
    std_stm_status                  number                        not null,
    std_upd_user                    varchar2(30 char)             not null,
    std_upd_date                    date                          not null,
    std_stm_target                  number                        not null,
    std_sel_type                    varchar2(32 char)             not null,
    std_req_mem_count               number                        null,
    std_req_res_count               number                        null);

/**/
/* Comments
/**/
comment on table pts.pts_stm_definition is 'Selection Template Definition Table';
comment on column pts.pts_stm_definition.std_stm_code is 'Selection template code';
comment on column pts.pts_stm_definition.std_stm_text is 'Selection template text';
comment on column pts.pts_stm_definition.std_stm_status is 'Selection template status';
comment on column pts.pts_stm_definition.std_upd_user is 'Selection template update user';
comment on column pts.pts_stm_definition.std_upd_date is 'Selection template update date';
comment on column pts.pts_stm_definition.std_stm_target is 'Selection template target';
comment on column pts.pts_stm_definition.std_sel_type is 'Selection type (*PERCENT or *TOTAL)';
comment on column pts.pts_stm_definition.std_req_mem_count is 'Selection template panel requested member count';
comment on column pts.pts_stm_definition.std_req_res_count is 'Selection template panel requested reserve count';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_stm_definition
   add constraint pts_stm_definition_pk primary key (std_stm_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_stm_definition to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_stm_definition for pts.pts_stm_definition;    
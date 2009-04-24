/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_sel_tem_definition
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
create table pts.pts_sel_tem_definition
   (std_tem_code                    number                        not null,
    std_tem_text                    varchar2(120 char)            not null,
    std_tem_status                  varchar2(1 char)              not null,
    std_upd_user                    varchar2(30 char)             not null,
    std_upd_date                    date                          not null,
    std_tar_code                    number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_sel_tem_definition is 'Selection Template Table';
comment on column pts.pts_sel_tem_definition.std_tem_code is 'Selection template code';
comment on column pts.pts_sel_tem_definition.std_tem_text is 'Selection template text';
comment on column pts.pts_sel_tem_definition.std_tem_status is 'Selection template status (0=Inactive or 1=Active)';
comment on column pts.pts_sel_tem_definition.std_upd_user is 'Selection template update user';
comment on column pts.pts_sel_tem_definition.std_upd_date is 'Selection template update date';
comment on column pts.pts_sel_tem_definition.std_tar_code is 'Selection template test target code';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_sel_tem_definition
   add constraint pts_sel_tem_definition_pk primary key (std_tem_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_sel_tem_definition to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_sel_tem_definition for pts.pts_sel_tem_definition;    
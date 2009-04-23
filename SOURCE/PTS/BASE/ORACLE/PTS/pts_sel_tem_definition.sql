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
   (std_sel_template                number                        not null,
    std_tem_text                    varchar2(120 char)            not null,
    std_tem_status                  varchar2(1 char)              not null,
    std_upd_user                    varchar2(30 char)             not null,
    std_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table pts.pts_sel_tem_definition is 'Selection Template Table';
comment on column pts.pts_sel_tem_definition.std_tem_code is 'Template code';
comment on column pts.pts_sel_tem_definition.std_tem_text is 'Template text';
comment on column pts.pts_sel_tem_definition.std_tem_status is 'Template status';
comment on column pts.pts_sel_tem_definition.std_upd_user is 'Template update user';
comment on column pts.pts_sel_tem_definition.std_upd_date is 'Template update date';

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
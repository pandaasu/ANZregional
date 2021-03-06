/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_definition
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_definition
   (tde_tes_code                    number                        not null,
    tde_tes_title                   varchar2(120 char)            not null,
    tde_com_code                    number                        not null,
    tde_tes_status                  number                        not null,
    tde_glo_status                  number                        not null,
    tde_tes_type                    number                        not null,
    tde_upd_user                    varchar2(30 char)             not null,
    tde_upd_date                    date                          not null,
    tde_tes_req_name                varchar2(60 char)             null,
    tde_tes_req_miden               varchar2(30 char)             null,
    tde_tes_aim                     varchar2(2000 char)           null,
    tde_tes_reason                  varchar2(2000 char)           null,
    tde_tes_prediction              varchar2(2000 char)           null,
    tde_tes_comment                 varchar2(2000 char)           null,
    tde_tes_str_date                date                          null,
    tde_tes_fld_week                number                        null,
    tde_tes_len_meal                number                        null,
    tde_tes_max_temp                number                        null,
    tde_tes_day_count               number                        null,
    tde_tes_sam_count               number                        null,
    tde_pan_sel_type                varchar2(32 char)             null,
    tde_req_mem_count               number                        null,
    tde_req_res_count               number                        null,
    tde_hou_pet_multi               varchar2(1 char)              null,
    tde_wgt_que_calc                varchar2(1 char)              null,
    tde_wgt_que_bowl                number                        null,
    tde_wgt_que_offer               number                        null,
    tde_wgt_que_remain              number                        null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_definition is 'Test Table';

comment on column pts.pts_tes_definition.tde_tes_code is 'Test code';
comment on column pts.pts_tes_definition.tde_tes_title is 'Test title';
comment on column pts.pts_tes_definition.tde_com_code is 'Company code';
comment on column pts.pts_tes_definition.tde_tes_status is 'Test status';
comment on column pts.pts_tes_definition.tde_glo_status is 'GloPal status';
comment on column pts.pts_tes_definition.tde_tes_type is 'Test type';
comment on column pts.pts_tes_definition.tde_upd_user is 'Test update user';
comment on column pts.pts_tes_definition.tde_upd_date is 'Test update date';
comment on column pts.pts_tes_definition.tde_tes_req_name is 'Test requestor name';
comment on column pts.pts_tes_definition.tde_tes_req_miden is 'Test requestor mars identifier';
comment on column pts.pts_tes_definition.tde_tes_aim is 'Test aim';
comment on column pts.pts_tes_definition.tde_tes_reason is 'Test reason';
comment on column pts.pts_tes_definition.tde_tes_prediction is 'Test prediction';
comment on column pts.pts_tes_definition.tde_tes_comment is 'Test comment';
comment on column pts.pts_tes_definition.tde_tes_str_date is 'Test start date';
comment on column pts.pts_tes_definition.tde_tes_fld_week is 'Test field week';
comment on column pts.pts_tes_definition.tde_tes_len_meal is 'Test meal length minutes';
comment on column pts.pts_tes_definition.tde_tes_max_temp is 'Test maximum temperature';
comment on column pts.pts_tes_definition.tde_tes_day_count is 'Test day count';
comment on column pts.pts_tes_definition.tde_tes_sam_count is 'Test sample per day count';
comment on column pts.pts_tes_definition.tde_pan_sel_type is 'Test panel selection type (*PERCENT or *TOTAL)';
comment on column pts.pts_tes_definition.tde_req_mem_count is 'Test panel requested member count';
comment on column pts.pts_tes_definition.tde_req_res_count is 'Test panel requested reserve count';
comment on column pts.pts_tes_definition.tde_hou_pet_multi is 'Test multiple pets per household';
comment on column pts.pts_tes_definition.tde_wgt_que_calc is 'Test weight question calculation required';
comment on column pts.pts_tes_definition.tde_wgt_que_bowl is 'Test weight question bowl';
comment on column pts.pts_tes_definition.tde_wgt_que_offer is 'Test weight question offered';
comment on column pts.pts_tes_definition.tde_wgt_que_remain is 'Test weight question remaining';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_definition
   add constraint pts_tes_definition_pk primary key (tde_tes_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_definition to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_definition for pts.pts_tes_definition;    
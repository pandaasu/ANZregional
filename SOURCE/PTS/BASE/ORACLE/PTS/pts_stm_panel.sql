/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_stm_panel
 Owner  : pts

 Description
 -----------
 Product Testing System - Selection Template Panel Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_stm_panel
   (stp_stm_code                    number                        not null,
    stp_pan_code                    number                        not null,
    stp_pan_status                  varchar2(32 char)             not null,
    stp_hou_code                    number                        not null,
    stp_sel_group                   varchar2(32 char)             not null);

/**/
/* Comments
/**/
comment on table pts.pts_stm_panel is 'Selection Template Panel Table';
comment on column pts.pts_stm_panel.stp_stm_code is 'Selection template code';
comment on column pts.pts_stm_panel.stp_pan_code is 'Panel code (household or pet)';
comment on column pts.pts_stm_panel.stp_pan_status is 'Panel status (*MEMBER, *RESERVE, *RECRUITED)';
comment on column pts.pts_stm_panel.stp_hou_code is 'Household code';
comment on column pts.pts_stm_panel.stp_sel_group is 'Selection group code (*GROUP01 - *GROUP99)';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_stm_panel
   add constraint pts_stm_panel_pk primary key (stp_stm_code, stp_pan_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_stm_panel to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_stm_panel for pts.pts_stm_panel;           
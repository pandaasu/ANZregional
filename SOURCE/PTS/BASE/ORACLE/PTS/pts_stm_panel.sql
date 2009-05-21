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
create global temporary table pts.pts_stm_panel
   (stp_sel_group                   varchar2(32 char)             not null,
    stp_hou_code                    number                        not null,
    stp_pet_code                    number                        not null,
    stp_pan_status                  number                        not null)
on commit preserve rows;

/**/
/* Comments
/**/
comment on table pts.pts_stm_panel is 'Selection Template Panel Table';
comment on column pts.pts_stm_panel.stp_sel_group is 'Selection group code (*GROUP01 - *GROUP99)';
comment on column pts.pts_stm_panel.stp_hou_code is 'Household code';
comment on column pts.pts_stm_panel.stp_pet_code is 'Pet code (test target *HOUSEHOLD = zero)';
comment on column pts.pts_stm_panel.stp_pan_status is 'Panel status';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_stm_panel
   add constraint pts_stm_panel_pk primary key (stp_sel_group, stp_hou_code, stp_pet_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_stm_panel to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_stm_panel for pts.pts_stm_panel;           
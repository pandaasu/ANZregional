/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_panel
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Panel Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_panel
   (tpa_tes_code                    number                        not null,
    tpa_sel_group                   varchar2(32 char)             not null,
    tpa_hou_code                    number                        not null,
    tpa_pet_code                    number                        not null,
    tpa_pan_status                  varchar2(32 char)             not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_panel is 'Test Panel Table';
comment on column pts.pts_tes_panel.tpa_tes_code is 'Test code';
comment on column pts.pts_tes_panel.tpa_sel_group is 'Selection group code (*GROUP01 - *GROUP99)';
comment on column pts.pts_tes_panel.tpa_hou_code is 'Household code';
comment on column pts.pts_tes_panel.tpa_pet_code is 'Pet code (product test type *HHOLD = zero)';
comment on column pts.pts_tes_panel.tpa_pan_status is 'Panel status (*MEMBER, *RESERVE, *RECRUITED)';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_panel
   add constraint pts_tes_panel_pk primary key (tpa_tes_code, tpa_sel_group, tpa_hou_code, tpa_pet_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_panel to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_panel for pts.pts_tes_panel;           
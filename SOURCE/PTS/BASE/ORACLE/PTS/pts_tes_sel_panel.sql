/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_sel_panel
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Selection Panel Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_sel_panel
   (tsp_tes_code                    number                        not null,
    tsp_sel_group                   varchar2(32 char)             not null,
    tsp_hou_code                    number                        not null,
    tsp_pet_code                    number                        null,
    tsp_status                      varchar2(20 char)             not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_sel_panel is 'Test Selection Panel Table';
comment on column pts.pts_tes_sel_panel.tsp_tes_code is 'Test code';
comment on column pts.pts_tes_sel_panel.tsp_sel_group is 'Selection group code (*GROUP01 - *GROUP99)';
comment on column pts.pts_tes_sel_panel.tsp_hou_code is 'Household code';
comment on column pts.pts_tes_sel_panel.tsp_pet_code is 'Pet code (product test type *HHOLD = zero)';
comment on column pts.pts_tes_sel_panel.tsp_status is 'Panel status (*ACTIVE, *RESERVE, *RECRUITED)';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_sel_panel
   add constraint pts_tes_sel_panel_pk primary key (tsp_tes_code, tsp_sel_group, tsp_hou_code, tsp_pet_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_sel_panel to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_sel_panel for pts.pts_tes_sel_panel;           
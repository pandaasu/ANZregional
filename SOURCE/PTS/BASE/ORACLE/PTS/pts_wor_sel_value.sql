/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_wor_sel_value
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Selection Value Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create global temporary table pts.pts_wor_sel_value
   (wsv_sel_group                   varchar2(32 char)             not null,
    wsv_tab_code                    varchar2(32 char)             not null,
    wsv_fld_code                    number                        not null,
    wsv_val_code                    number                        not null,
    wsv_val_text                    varchar2(256 char)            null)
on commit preserve rows;

/**/
/* Comments
/**/
comment on table pts.pts_wor_sel_value is 'Test Selection Value Table';
comment on column pts.pts_wor_sel_value.wsv_sel_group is 'Selection group';
comment on column pts.pts_wor_sel_value.wsv_tab_code is 'System table code';
comment on column pts.pts_wor_sel_value.wsv_fld_code is 'System field code';
comment on column pts.pts_wor_sel_value.wsv_val_code is 'System value code';
comment on column pts.pts_wor_sel_value.wsv_val_text is 'Value text';

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_wor_sel_value to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_wor_sel_value for pts.pts_wor_sel_value;           
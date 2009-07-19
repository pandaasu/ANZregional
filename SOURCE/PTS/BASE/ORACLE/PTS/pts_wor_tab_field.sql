/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_wor_tab_field
 Owner  : pts

 Description
 -----------
 Product Testing System - Table Field Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create global temporary table pts.pts_wor_tab_field
   (wtf_tab_code                    varchar2(32 char)             not null,
    wtf_fld_code                    number                        not null)
on commit preserve rows;

/**/
/* Comments
/**/
comment on table pts.pts_wor_tab_field is 'Table Field Table';
comment on column pts.pts_wor_tab_field.wtf_tab_code is 'System table code';
comment on column pts.pts_wor_tab_field.wtf_fld_code is 'System field code';
/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_wor_tab_field to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_wor_tab_field for pts.pts_wor_tab_field;           
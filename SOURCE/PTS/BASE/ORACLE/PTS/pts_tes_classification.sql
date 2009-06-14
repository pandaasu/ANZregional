/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_classification
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Classification Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_classification
   (tcl_tes_code                    number                        not null,
    tcl_pan_code                    number                        not null,
    tcl_tab_code                    varchar2(32 char)             not null,
    tcl_fld_code                    number                        not null,
    tcl_val_code                    number                        not null,
    tcl_val_text                    varchar2(256 char)            null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_classification is 'Test Classification Table';
comment on column pts.pts_tes_classification.tcl_tes_code is 'Test code';
comment on column pts.pts_tes_classification.tcl_pan_code is 'Panel code (household or pet)';
comment on column pts.pts_tes_classification.tcl_tab_code is 'System table code';
comment on column pts.pts_tes_classification.tcl_fld_code is 'System field code';
comment on column pts.pts_tes_classification.tcl_val_code is 'System value code';
comment on column pts.pts_tes_classification.tcl_val_text is 'System value text';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_classification
   add constraint pts_tes_classification_pk primary key (tcl_tes_code, tcl_pan_code, tcl_tab_code, tcl_fld_code, tcl_val_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_classification to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_classification for pts.pts_tes_classification;
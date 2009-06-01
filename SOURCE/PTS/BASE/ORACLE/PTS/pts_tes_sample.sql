/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_sample
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Sample Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_sample
   (tsa_res_code                    number                        not null,
    tsa_sam_code                    varchar2(32 char)             not null,
    tsa_mkt_res_code                varchar2(1 char)              not null,
    tsa_rpt_code                    varchar2(3 char)              not null,
    tsa_sam_identifier              varchar2(20 char)             not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_sample is 'Test Sample Table';
comment on column pts.pts_tes_sample.tsa_site is 'Site code';
comment on column pts.pts_tes_sample.tsa_test is 'Test code';
comment on column pts.pts_tes_sample.tsa_sel_group is 'Selection group code (*GROUP01 - *GROUP99)';
comment on column pts.pts_tes_sample.tsa_sel_text is 'Selection group text';
comment on column pts.pts_tes_sample.tsa_req_pan_count is 'Selection group requested panel count';
comment on column pts.pts_tes_sample.tsa_req_res_count is 'Selection group requested reserve count';
comment on column pts.pts_tes_sample.tsa_sel_pan_count is 'Selection group selected panel count';
comment on column pts.pts_tes_sample.tsa_sel_res_count is 'Selection group selected reserve count';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_sample
   add constraint pts_tes_sample_pk primary key (tsa_site, tsa_test, tsa_sel_group);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_sample to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_sample for pts.pts_tes_sample;            
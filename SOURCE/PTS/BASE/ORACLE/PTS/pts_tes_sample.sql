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
   (tsa_tes_code                    number                        not null,
    tsa_sam_code                    number                        not null,
    tsa_mkt_code                    varchar2(1 char)              not null,
    tsa_mkt_edoc                    varchar2(1 char)              not null,
    tsa_rpt_code                    varchar2(3 char)              not null,
    tsa_sam_iden                    varchar2(20 char)             not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_sample is 'Test Sample Table';
comment on column pts.pts_tes_sample.tsa_tes_code is 'Test code';
comment on column pts.pts_tes_sample.tsa_sam_code is 'Sample code';
comment on column pts.pts_tes_sample.tsa_mkt_code is 'Market research code';
comment on column pts.pts_tes_sample.tsa_mkt_edoc is 'Market research alias';
comment on column pts.pts_tes_sample.tsa_rpt_code is 'Report code';
comment on column pts.pts_tes_sample.tsa_sam_iden is 'Sample identifier';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_sample
   add constraint pts_tes_sample_pk primary key (tsa_tes_code, tsa_sam_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_sample to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_sample for pts.pts_tes_sample;            
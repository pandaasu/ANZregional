/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_feeding
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Feeding Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_feeding
   (tfe_tes_code                    number                        not null,
    tfe_sam_code                    number                        not null,
    tfe_pet_size                    number                        not null,
    tfe_fed_qnty                    number                        not null,
    tfe_fed_text                    varchar2(120 char)            null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_feeding is 'Test Feeding Table';
comment on column pts.pts_tes_feeding.tfe_tes_code is 'Test code';
comment on column pts.pts_tes_feeding.tfe_sam_code is 'Sample code';
comment on column pts.pts_tes_feeding.tfe_pet_size is 'Pet size';
comment on column pts.pts_tes_feeding.tfe_fed_qnty is 'Feeding quantity';
comment on column pts.pts_tes_feeding.tfe_fed_text is 'Feeding text';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_feeding
   add constraint pts_tes_feeding_pk primary key (tfe_tes_code, tfe_sam_code, tfe_pet_size);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_feeding to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_feeding for pts.pts_tes_feeding;            
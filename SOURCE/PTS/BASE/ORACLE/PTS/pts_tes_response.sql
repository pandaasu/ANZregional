/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_response
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Response Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_response
   (tre_tes_code                    number                        not null,
    tre_hou_code                    number                        not null,
    tre_pet_code                    number                        not null,
    tre_day_code                    number                        not null,
    tre_que_code                    number                        not null,
    tre_res_code                    number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_response is 'Test Response Table';
comment on column pts.pts_tes_response.tre_tes_code is 'Test code';
comment on column pts.pts_tes_response.tre_hou_code is 'Household code';
comment on column pts.pts_tes_response.tre_pet_code is 'Pet code (test target *HOUSEHOLD = zero)';
comment on column pts.pts_tes_response.tre_day_code is 'Test day code';
comment on column pts.pts_tes_response.tre_que_code is 'Test question code';
comment on column pts.pts_tes_response.tre_res_code is 'Test response code';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_response
   add constraint pts_tes_response_pk primary key (tre_tes_code, tre_hou_code, tre_pet_code, tre_day_code, tre_que_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_response to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_response for pts.pts_tes_response;            
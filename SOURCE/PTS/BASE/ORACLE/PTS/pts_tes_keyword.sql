/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_keyword
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Keywprd Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_keyword
   (tke_tes_code                    number                        not null,
    tke_key_word                    varchar2(32 char)             not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_keyword is 'Test Keyword Table';
comment on column pts.pts_tes_keyword.tke_tes_code is 'Test code';
comment on column pts.pts_tes_keyword.tke_key_word is 'Test key word';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_keyword
   add constraint pts_tes_keyword_pk primary key (tke_tes_code, tke_key_word);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_keyword to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_keyword for pts.pts_tes_keyword;            
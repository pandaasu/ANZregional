/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_stk_header
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Stocktake Header Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_stk_header
   (sth_stk_code                    varchar2(32)                  not null,
    sth_stk_name                    varchar2(120 char)            not null,
    sth_stk_time                    varchar2(16)                  not null,
    sth_stk_status                  varchar2(10)                  not null,
    sth_upd_user                    varchar2(30)                  not null,
    sth_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_stk_header is 'Stocktake Header Table';
comment on column psa.psa_stk_header.sth_stk_code is 'Stocktake code - STOCKTAKE_YYYYMMDDHHMISS';
comment on column psa.psa_stk_header.sth_stk_name is 'Stocktake name';
comment on column psa.psa_stk_header.sth_stk_time is 'Stocktake time - as at YYYY/MM/DD HH:MI';
comment on column psa.psa_stk_header.sth_stk_status is 'Stocktake status - *LOADING or *ACTIVE';
comment on column psa.psa_stk_header.sth_upd_user is 'Last updated user';
comment on column psa.psa_stk_header.sth_upd_date is 'Last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_stk_header
   add constraint psa_stk_header_pk primary key (sth_stk_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_stk_header to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_stk_header for psa.psa_stk_header;
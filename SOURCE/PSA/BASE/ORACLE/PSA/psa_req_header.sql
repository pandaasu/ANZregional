/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_req_header
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Requirement Header Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_req_header
   (rhe_req_code                    varchar2(32)                  not null,
    rhe_req_name                    varchar2(120 char)            not null,
    rhe_req_status                  varchar2(1)                   not null,
    rhe_str_week                    varchar2(7)                   not null,
    rhe_end_week                    varchar2(7)                   not null,
    rhe_upd_user                    varchar2(30)                  not null,
    rhe_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_req_header is 'Production Requirement Header Table';
comment on column psa.psa_req_header.rhe_req_code is 'Requirement code - YYYYPPW_YYYYMMDDHHMISS';
comment on column psa.psa_req_header.rhe_req_name is 'Requirement name';
comment on column psa.psa_req_header.rhe_req_status is 'Requirement status (0=inactive or 1=active)';
comment on column psa.psa_req_header.rhe_str_week is 'Requirement start MARS week';
comment on column psa.psa_req_header.rhe_end_week is 'Requirement end MARS week';
comment on column psa.psa_req_header.rhe_upd_user is 'Last updated user';
comment on column psa.psa_req_header.rhe_upd_date is 'Last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_req_header
   add constraint psa_req_header_pk primary key (rhe_req_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_req_header to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_req_header for psa.psa_req_header;
/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_str_header
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_str_header

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/09   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_str_header
   (sth_str_code          varchar2(32 char)            not null,
    sth_str_text          varchar2(128 char)           not null,
    sth_status            varchar2(1 char)             not null,
    sth_upd_user          varchar2(30 char)            not null,
    sth_upd_time          date                         not null);

/**/
/* Comments
/**/
comment on table lics_str_header is 'LICS Stream Header Table';
comment on column lics_str_header.sth_str_code is 'Stream header - stream code';
comment on column lics_str_header.sth_str_text is 'Stream header - stream text';
comment on column lics_str_header.sth_status is 'Stream header - stream status';
comment on column lics_str_header.sth_upd_user is 'Stream header - update user';
comment on column lics_str_header.sth_upd_time is 'Stream header - update time';

/**/
/* Primary Key Constraint
/**/
alter table lics_str_header
   add constraint lics_str_header_pk primary key (sth_str_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_str_header to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_str_header for lics.lics_str_header;
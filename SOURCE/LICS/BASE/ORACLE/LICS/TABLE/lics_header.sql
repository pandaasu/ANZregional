/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_header
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_header

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2006/08   Steve Gregan   Added hea_msg_name column

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_header
   (hea_header                   number(15,0)                    not null,
    hea_interface                varchar2(32 char)               not null,
    hea_trc_count                number(5,0)                     not null,
    hea_crt_user                 varchar2(30 char)               not null,
    hea_crt_time                 date                            not null,
    hea_fil_name                 varchar2(64 char)               not null,
    hea_msg_name                 varchar2(64 char)               not null,
    hea_status                   varchar2(1 char)                not null);

/**/
/* Comments
/**/
comment on table lics_header is 'LICS Header Table';
comment on column lics_header.hea_header is 'Header - header sequence number (sequence generated)';
comment on column lics_header.hea_interface is 'Header - interface identifier';
comment on column lics_header.hea_trc_count is 'Header - trace count';
comment on column lics_header.hea_crt_user is 'Header - creation user';
comment on column lics_header.hea_crt_time is 'Header - creation time';
comment on column lics_header.hea_fil_name is 'Header - file name';
comment on column lics_header.hea_msg_name is 'Header - message name';
comment on column lics_header.hea_status is 'Header - header status';

/**/
/* Primary Key Constraint
/**/
alter table lics_header
   add constraint lics_header_pk primary key (hea_header);

/**/
/* Foreign Key Constraints
/**/
--alter table lics_header
--   add constraint lics_header_fk01 foreign key (hea_interface)
--      references lics_interface (int_interface);

/**/
/* Indexes
/**/
--create index lics_header_ix01 on lics_header
--   (hea_interface, hea_status);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_header to lics_app;
grant select on lics_header to lics_exec;

/**/
/* Synonym
/**/
create or replace public synonym lics_header for lics.lics_header;

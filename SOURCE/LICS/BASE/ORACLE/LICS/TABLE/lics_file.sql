/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_file
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_file

 YYYY/MM   Author         Description
 -------   ------         -----------
 2011/02   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_file
   (fil_file                     number(15,0)                    not null,
    fil_path                     varchar2(64 char)               not null,
    fil_name                     varchar2(256 char)              not null,
    fil_status                   varchar2(1 char)                not null,
    fil_crt_user                 varchar2(30 char)               not null,
    fil_crt_time                 date                            not null,
    fil_message                  varchar2(2000 char)             null);

/**/
/* Comments
/**/
comment on table lics_file is 'LICS File Table';
comment on column lics_file.fil_file is 'File - file sequence number (sequence generated)';
comment on column lics_file.fil_path is 'File - file path';
comment on column lics_file.fil_name is 'File - file name';
comment on column lics_file.fil_status is 'File - file status';
comment on column lics_file.fil_crt_user is 'File - creation user';
comment on column lics_file.fil_crt_time is 'File - creation time';
comment on column lics_file.fil_message is 'File - file message';

/**/
/* Primary Key Constraint
/**/
alter table lics_file
   add constraint lics_file_pk primary key (fil_file);

/**/
/* Indexes
/**/
create unique index lics_file_ix01 on lics_file
   (fil_path, fil_name);
create index lics_file_ix02 on lics_file
   (fil_path, fil_status, fil_file);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_file to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_file for lics.lics_file;

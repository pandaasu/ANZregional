/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_data
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_data

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_data
   (dat_header                   number(15,0)                    not null,
    dat_dta_seq                  number(9,0)                     not null,
    dat_record                   varchar2(4000 char)             not null,
    dat_status                   varchar2(1 char)                not null);

/**/
/* Comments
/**/
comment on table lics_data is 'LICS Data Table';
comment on column lics_data.dat_header is 'Data - header sequence number';
comment on column lics_data.dat_dta_seq is 'Data - data sequence number';
comment on column lics_data.dat_record is 'Data - record string';
comment on column lics_data.dat_status is 'Data - data status';

/**/
/* Primary Key Constraint
/**/
alter table lics_data
   add constraint lics_data_pk primary key (dat_header, dat_dta_seq);

/**/
/* Foreign Key Constraints
/**/
--alter table lics_data
--   add constraint lics_data_fk01 foreign key (dat_header)
--      references lics_header (hea_header);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_data to lics_app;
grant select on lics_data to lics_exec;

/**/
/* Synonym
/**/
create public synonym lics_data for lics.lics_data;

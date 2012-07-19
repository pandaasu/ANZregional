/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_hdr_search
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_hdr_search

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/08   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_hdr_search
   (hes_header                   number(15,0)                    not null,
    hes_sea_tag                  varchar2(64 char)               not null,
    hes_sea_value                varchar2(128 char)              not null);

/**/
/* Comments
/**/
comment on table lics_hdr_search is 'LICS Header Search Table';
comment on column lics_hdr_search.hes_header is 'Header search - header sequence number';
comment on column lics_hdr_search.hes_sea_tag is 'Header search - search tag';
comment on column lics_hdr_search.hes_sea_value is 'Header search - search value';

/**/
/* Primary Key Constraint
/**/
alter table lics_hdr_search
   add constraint lics_hdr_search_pk primary key (hes_header, hes_sea_tag, hes_sea_value);

/**/
/* Foreign Key Constraints
/**/
--alter table lics_hdr_search
--   add constraint lics_hdr_search_fk01 foreign key (hes_header)
--      references lics_header (hea_header);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_hdr_search to lics_app;
grant select on lics_hdr_search to lics_exec;

/**/
/* Synonym
/**/
create or replace public synonym lics_hdr_search for lics.lics_hdr_search;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_xrf_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_xrf_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_xrf_hdr
   (xrf_code                                     varchar2(32 char)                   not null,
    xrf_desc                                     varchar2(128 char)                  not null);

/**/
/* Comments
/**/
comment on table lads_xrf_hdr is 'LADS Cross Reference Header';
comment on column lads_xrf_hdr.xrf_code is 'Cross reference code';
comment on column lads_xrf_hdr.xrf_desc is 'Cross reference description';

/**/
/* Primary Key Constraint
/**/
alter table lads_xrf_hdr
   add constraint lads_xrf_hdr_pk primary key (xrf_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_xrf_hdr to lads_app;
grant select, insert, update, delete on lads_xrf_hdr to ics_app;
grant select, insert, update, delete on lads_xrf_hdr to lics_app;

/**/
/* Synonym
/**/
create public synonym lads_xrf_hdr for lads.lads_xrf_hdr;

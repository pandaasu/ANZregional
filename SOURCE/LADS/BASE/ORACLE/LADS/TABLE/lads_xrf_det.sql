/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_xrf_det
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_xrf_det

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_xrf_det
   (xrf_code                                     varchar2(32 char)                   not null,
    xrf_source                                   varchar2(64 char)                   not null,
    xrf_target                                   varchar2(64 char)                   not null);

/**/
/* Comments
/**/
comment on table lads_xrf_det is 'LADS Cross Reference Detail';
comment on column lads_xrf_det.xrf_code is 'Cross reference code';
comment on column lads_xrf_det.xrf_source is 'Cross reference source code';
comment on column lads_xrf_det.xrf_target is 'Cross reference target code';

/**/
/* Primary Key Constraint
/**/
alter table lads_xrf_det
   add constraint lads_xrf_det_pk primary key (xrf_code, xrf_source);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_xrf_det to lads_app;
grant select, insert, update, delete on lads_xrf_det to ics_app;
grant select, insert, update, delete on lads_xrf_det to lics_app;

/**/
/* Synonym
/**/
create public synonym lads_xrf_det for lads.lads_xrf_det;

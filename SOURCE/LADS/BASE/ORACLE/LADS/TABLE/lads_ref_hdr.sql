/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ref_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ref_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ref_hdr
   (z_tabgrp                                     varchar2(4 char)                    null,
    z_tabname                                    varchar2(30 char)                   not null,
    z_tabhie                                     number                              null,
    z_chngonly                                   varchar2(1 char)                    null,
    z_keylen                                     number                              null,
    z_walen                                      number                              null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_ref_hdr is 'LADS Reference Header';
comment on column lads_ref_hdr.z_tabgrp is 'Table group for reference data distribution';
comment on column lads_ref_hdr.z_tabname is 'Table Name';
comment on column lads_ref_hdr.z_tabhie is 'Hierarchy value for table listing';
comment on column lads_ref_hdr.z_chngonly is 'Flag indicating distribution of changes only';
comment on column lads_ref_hdr.z_keylen is 'Table key length for reference table distribution';
comment on column lads_ref_hdr.z_walen is 'Work area length for reference table distribution';
comment on column lads_ref_hdr.idoc_name is 'IDOC name';
comment on column lads_ref_hdr.idoc_number is 'IDOC number';
comment on column lads_ref_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_ref_hdr.lads_date is 'LADS date loaded';
comment on column lads_ref_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';

/**/
/* Primary Key Constraint
/**/
alter table lads_ref_hdr
   add constraint lads_ref_hdr_pk primary key (z_tabname);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ref_hdr to lads_app;
grant select, insert, update, delete on lads_ref_hdr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ref_hdr for lads.lads_ref_hdr;

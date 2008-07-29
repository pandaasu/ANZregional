/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cla_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cla_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cla_hdr
   (obtab                                        varchar2(10 char)                   not null,
    objek                                        varchar2(50 char)                   not null,
    klart                                        varchar2(3 char)                    not null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_cla_hdr is 'LADS Classification Header';
comment on column lads_cla_hdr.obtab is 'Name of database table for object';
comment on column lads_cla_hdr.objek is 'Key of object to be classified';
comment on column lads_cla_hdr.klart is 'Class type';
comment on column lads_cla_hdr.idoc_name is 'IDOC name';
comment on column lads_cla_hdr.idoc_number is 'IDOC number';
comment on column lads_cla_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_cla_hdr.lads_date is 'LADS date loaded';
comment on column lads_cla_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';

/**/
/* Primary Key Constraint
/**/
alter table lads_cla_hdr
   add constraint lads_cla_hdr_pk primary key (obtab, objek, klart);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cla_hdr to lads_app;
grant select, insert, update, delete on lads_cla_hdr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cla_hdr for lads.lads_cla_hdr;

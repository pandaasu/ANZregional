/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cla_mas_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cla_mas_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cla_mas_hdr
   (klart                                        varchar2(3 char)                    not null,
    class                                        varchar2(18 char)                   not null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_cla_mas_hdr is 'LADS Classification Master Header';
comment on column lads_cla_mas_hdr.klart is 'Class Type';
comment on column lads_cla_mas_hdr.class is 'Class Name';
comment on column lads_cla_mas_hdr.idoc_name is 'IDOC name';
comment on column lads_cla_mas_hdr.idoc_number is 'IDOC number';
comment on column lads_cla_mas_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_cla_mas_hdr.lads_date is 'LADS date loaded';
comment on column lads_cla_mas_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';

/**/
/* Primary Key Constraint
/**/
alter table lads_cla_mas_hdr
   add constraint lads_cla_mas_hdr_pk primary key (klart, class);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cla_mas_hdr to lads_app;
grant select, insert, update, delete on lads_cla_mas_hdr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cla_mas_hdr for lads.lads_cla_mas_hdr;

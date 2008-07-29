/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_adr_com
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_adr_com

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_adr_com
   (obj_type                                     varchar2(10 char)                   not null,
    obj_id                                       varchar2(70 char)                   not null,
    context                                      number                              not null,
    comseq                                       number                              not null,
    addr_vers                                    varchar2(1 char)                    null,
    langu                                        varchar2(1 char)                    null,
    langu_iso                                    varchar2(2 char)                    null,
    adr_notes                                    varchar2(50 char)                   null,
    errorflag                                    varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_adr_com is 'LADS Address Comment';
comment on column lads_adr_com.obj_type is 'Address owner object type';
comment on column lads_adr_com.obj_id is 'Address owner object ID';
comment on column lads_adr_com.context is 'Semantic description of an object address';
comment on column lads_adr_com.comseq is 'COM - generated sequence number';
comment on column lads_adr_com.addr_vers is 'International address version ID';
comment on column lads_adr_com.langu is 'Language Key';
comment on column lads_adr_com.langu_iso is 'Language according to ISO 639';
comment on column lads_adr_com.adr_notes is 'Address notes';
comment on column lads_adr_com.errorflag is 'Flag: Record not processed';

/**/
/* Primary Key Constraint
/**/
alter table lads_adr_com
   add constraint lads_adr_com_pk primary key (obj_type, obj_id, context, comseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_adr_com to lads_app;
grant select, insert, update, delete on lads_adr_com to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_adr_com for lads.lads_adr_com;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_adr_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_adr_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2007/03   Steve Gregan   Added LADS_FLATTENED

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_adr_hdr
   (obj_type                                     varchar2(10 char)                   not null,
    obj_id                                       varchar2(70 char)                   not null,
    obj_id_ext                                   varchar2(70 char)                   null,
    context                                      number                              not null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null,
    lads_flattened                               varchar2(1 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_adr_hdr is 'LADS Address Header';
comment on column lads_adr_hdr.obj_type is 'Address owner object type';
comment on column lads_adr_hdr.obj_id is 'Address owner object ID';
comment on column lads_adr_hdr.obj_id_ext is 'Object Key';
comment on column lads_adr_hdr.context is 'Semantic description of an object address';
comment on column lads_adr_hdr.idoc_name is 'IDOC name';
comment on column lads_adr_hdr.idoc_number is 'IDOC number';
comment on column lads_adr_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_adr_hdr.lads_date is 'LADS date loaded';
comment on column lads_adr_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';
comment on column lads_adr_hdr.lads_flattened is 'LADS Flattened Status - 0 Unflattened, 1 Flattened to BDS, 2 Excluded/Skipped';

/**/
/* Primary Key Constraint
/**/
alter table lads_adr_hdr
   add constraint lads_adr_hdr_pk primary key (obj_type, obj_id, context);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_adr_hdr to lads_app;
grant select, insert, update, delete on lads_adr_hdr to ics_app;
grant select, update on lads_adr_hdr to bds_app;

/**/
/* Synonym
/**/
create public synonym lads_adr_hdr for lads.lads_adr_hdr;

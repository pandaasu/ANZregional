/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_chr_mas_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_chr_mas_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_chr_mas_hdr
   (msgfn                                        varchar2(3 char)                    null,
    atnam                                        varchar2(30 char)                   not null,
    atkle                                        varchar2(1 char)                    null,
    atkla                                        varchar2(10 char)                   null,
    aterf                                        varchar2(1 char)                    null,
    atein                                        varchar2(1 char)                    null,
    aname                                        varchar2(12 char)                   null,
    adatu                                        varchar2(8 char)                    null,
    vname                                        varchar2(12 char)                   null,
    vdatu                                        varchar2(8 char)                    null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_chr_mas_hdr is 'LADS Characteristic Master Header';
comment on column lads_chr_mas_hdr.msgfn is 'Function';
comment on column lads_chr_mas_hdr.atnam is 'Characteristic Name';
comment on column lads_chr_mas_hdr.atkle is 'Case sensitive';
comment on column lads_chr_mas_hdr.atkla is 'Chars Group';
comment on column lads_chr_mas_hdr.aterf is 'Entry Required';
comment on column lads_chr_mas_hdr.atein is 'Single value';
comment on column lads_chr_mas_hdr.aname is 'Name of Person who Created the Object';
comment on column lads_chr_mas_hdr.adatu is 'Date on which the record was created';
comment on column lads_chr_mas_hdr.vname is 'Name of person who changed object';
comment on column lads_chr_mas_hdr.vdatu is 'Date of Last Change';
comment on column lads_chr_mas_hdr.idoc_name is 'IDOC name';
comment on column lads_chr_mas_hdr.idoc_number is 'IDOC number';
comment on column lads_chr_mas_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_chr_mas_hdr.lads_date is 'LADS date loaded';
comment on column lads_chr_mas_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';

/**/
/* Primary Key Constraint
/**/
alter table lads_chr_mas_hdr
   add constraint lads_chr_mas_hdr_pk primary key (atnam);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_chr_mas_hdr to lads_app;
grant select, insert, update, delete on lads_chr_mas_hdr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_chr_mas_hdr for lads.lads_chr_mas_hdr;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cla_chr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cla_chr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cla_chr
   (obtab                                        varchar2(10 char)                   not null,
    objek                                        varchar2(50 char)                   not null,
    klart                                        varchar2(3 char)                    not null,
    chrseq                                       number                              not null,
    atnam                                        varchar2(30 char)                   null,
    atwrt                                        varchar2(30 char)                   null);

/**/
/* Comments
/**/
comment on table lads_cla_chr is 'LADS Classification Characteristic';
comment on column lads_cla_chr.obtab is 'Name of database table for object';
comment on column lads_cla_chr.objek is 'Key of object to be classified';
comment on column lads_cla_chr.klart is 'Class type';
comment on column lads_cla_chr.chrseq is 'CHR - generated sequence number';
comment on column lads_cla_chr.atnam is 'Characteristic Name';
comment on column lads_cla_chr.atwrt is 'Characteristic value';

/**/
/* Primary Key Constraint
/**/
alter table lads_cla_chr
   add constraint lads_cla_chr_pk primary key (obtab, objek, klart, chrseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cla_chr to lads_app;
grant select, insert, update, delete on lads_cla_chr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cla_chr for lads.lads_cla_chr;

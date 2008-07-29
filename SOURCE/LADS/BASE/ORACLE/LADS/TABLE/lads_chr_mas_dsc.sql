/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_chr_mas_dsc
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_chr_mas_dsc

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_chr_mas_dsc
   (atnam                                        varchar2(30 char)                   not null,
    valseq                                       number                              not null,
    dscseq                                       number                              not null,
    atzhl                                        varchar2(4 char)                    null,
    spras                                        varchar2(1 char)                    null,
    atwtb                                        varchar2(30 char)                   null,
    spras_iso                                    varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_chr_mas_dsc is 'LADS Characteristic Master Description';
comment on column lads_chr_mas_dsc.atnam is 'Characteristic Name';
comment on column lads_chr_mas_dsc.valseq is 'VAL - generated sequence number';
comment on column lads_chr_mas_dsc.dscseq is 'DSC - generated sequence number';
comment on column lads_chr_mas_dsc.atzhl is 'Int counter';
comment on column lads_chr_mas_dsc.spras is 'Language Key';
comment on column lads_chr_mas_dsc.atwtb is 'Characteristic value description';
comment on column lads_chr_mas_dsc.spras_iso is 'Language according to ISO 639';

/**/
/* Primary Key Constraint
/**/
alter table lads_chr_mas_dsc
   add constraint lads_chr_mas_dsc_pk primary key (atnam, valseq, dscseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_chr_mas_dsc to lads_app;
grant select, insert, update, delete on lads_chr_mas_dsc to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_chr_mas_dsc for lads.lads_chr_mas_dsc;

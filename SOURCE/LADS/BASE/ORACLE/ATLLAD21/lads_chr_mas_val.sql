/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_chr_mas_val
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_chr_mas_val

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_chr_mas_val
   (atnam                                        varchar2(30 char)                   not null,
    valseq                                       number                              not null,
    atzhl                                        varchar2(4 char)                    null,
    atwrt                                        varchar2(30 char)                   null);

/**/
/* Comments
/**/
comment on table lads_chr_mas_val is 'LADS Characteristic Master Value';
comment on column lads_chr_mas_val.atnam is 'Characteristic Name';
comment on column lads_chr_mas_val.valseq is 'VAL - generated sequence number';
comment on column lads_chr_mas_val.atzhl is 'Int counter';
comment on column lads_chr_mas_val.atwrt is 'Characteristic Value';

/**/
/* Primary Key Constraint
/**/
alter table lads_chr_mas_val
   add constraint lads_chr_mas_val_pk primary key (atnam, valseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_chr_mas_val to lads_app;
grant select, insert, update, delete on lads_chr_mas_val to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_chr_mas_val for lads.lads_chr_mas_val;

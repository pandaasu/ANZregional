/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_chr_mas_det
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_chr_mas_det

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_chr_mas_det
   (atnam                                        varchar2(30 char)                   not null,
    detseq                                       number                              not null,
    spras                                        varchar2(1 char)                    null,
    atbez                                        varchar2(30 char)                   null,
    spras_iso                                    varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_chr_mas_det is 'LADS Characteristic Master Detail';
comment on column lads_chr_mas_det.atnam is 'Characteristic Name';
comment on column lads_chr_mas_det.detseq is 'DET - generated sequence number';
comment on column lads_chr_mas_det.spras is 'Language Key';
comment on column lads_chr_mas_det.atbez is 'Characteristic description';
comment on column lads_chr_mas_det.spras_iso is 'Language according to ISO 639';

/**/
/* Primary Key Constraint
/**/
alter table lads_chr_mas_det
   add constraint lads_chr_mas_det_pk primary key (atnam, detseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_chr_mas_det to lads_app;
grant select, insert, update, delete on lads_chr_mas_det to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_chr_mas_det for lads.lads_chr_mas_det;

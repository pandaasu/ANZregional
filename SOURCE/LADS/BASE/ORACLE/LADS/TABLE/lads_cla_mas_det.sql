/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cla_mas_det
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cla_mas_det

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cla_mas_det
   (klart                                        varchar2(3 char)                    not null,
    class                                        varchar2(18 char)                   not null,
    detseq                                       number                              not null,
    atnam                                        varchar2(30 char)                   null,
    posnr                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_cla_mas_det is 'LADS Classification Master Header';
comment on column lads_cla_mas_det.klart is 'Class Type';
comment on column lads_cla_mas_det.class is 'Class Name';
comment on column lads_cla_mas_det.detseq  is 'DET - generated sequence number';
comment on column lads_cla_mas_det.atnam  is 'Characteristic Name';
comment on column lads_cla_mas_det.posnr is 'Position Number';

/**/
/* Primary Key Constraint
/**/
alter table lads_cla_mas_det
   add constraint lads_cla_mas_det_pk primary key (klart, class, detseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cla_mas_det to lads_app;
grant select, insert, update, delete on lads_cla_mas_det to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cla_mas_det for lads.lads_cla_mas_det;

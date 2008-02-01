/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_mat
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_mat

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_mat
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    matseq                                       number                              not null,
    langu                                        varchar2(2 char)                    null,
    maktx                                        varchar2(40 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_mat is 'LADS Invoice Item Material Description';
comment on column lads_inv_mat.belnr is 'IDOC document number';
comment on column lads_inv_mat.genseq is 'GEN - generated sequence number';
comment on column lads_inv_mat.matseq is 'MAT - generated sequence number';
comment on column lads_inv_mat.langu is 'Language according to ISO 639';
comment on column lads_inv_mat.maktx is 'Material Description';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_mat
   add constraint lads_inv_mat_pk primary key (belnr, genseq, matseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_mat to lads_app;
grant select, insert, update, delete on lads_inv_mat to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_mat for lads.lads_inv_mat;

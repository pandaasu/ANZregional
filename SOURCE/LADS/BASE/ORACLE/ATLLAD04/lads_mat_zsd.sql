/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_zsd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_zsd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_zsd
   (matnr                                        varchar2(18 char)                   not null,
    sadseq                                       number                              not null,
    zsdseq                                       number                              not null,
    zzlogist_point                               number                              null);

/**/
/* Comments
/**/
comment on table lads_mat_zsd is 'LADS Material Mars Sales Area Data';
comment on column lads_mat_zsd.matnr is 'Material Number';
comment on column lads_mat_zsd.sadseq is 'SAD - generated sequence number';
comment on column lads_mat_zsd.zsdseq is 'ZSD - generated sequence number';
comment on column lads_mat_zsd.zzlogist_point is 'Logistic Point';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_zsd
   add constraint lads_mat_zsd_pk primary key (matnr, sadseq, zsdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_zsd to lads_app;
grant select, insert, update, delete on lads_mat_zsd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_zsd for lads.lads_mat_zsd;

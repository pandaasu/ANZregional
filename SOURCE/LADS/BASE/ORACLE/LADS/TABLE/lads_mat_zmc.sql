/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_zmc
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_zmc

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_zmc
   (matnr                                        varchar2(18 char)                   not null,
    mrcseq                                       number                              not null,
    zmcseq                                       number                              not null,
    zzmtart                                      number                              null,
    zzmattim_pl                                  number                              null,
    zzfppsmoe                                    varchar2(15 char)                   null);

/**/
/* Comments
/**/
comment on table lads_mat_zmc is 'LADS Material Mars Plant Data';
comment on column lads_mat_zmc.matnr is 'Material Number';
comment on column lads_mat_zmc.mrcseq is 'MRC - generated sequence number';
comment on column lads_mat_zmc.zmcseq is 'ZMC - generated sequence number';
comment on column lads_mat_zmc.zzmtart is 'ATLAS MD plant oriented material type';
comment on column lads_mat_zmc.zzmattim_pl is 'Maturation lead time in days';
comment on column lads_mat_zmc.zzfppsmoe is 'FPPS source';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_zmc
   add constraint lads_mat_zmc_pk primary key (matnr, mrcseq, zmcseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_zmc to lads_app;
grant select, insert, update, delete on lads_mat_zmc to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_zmc for lads.lads_mat_zmc;

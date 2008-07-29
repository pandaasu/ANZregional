/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_mlg
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_mlg

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_mlg
   (matnr                                        varchar2(18 char)                   not null,
    mgnseq                                       number                              not null,
    mlgseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    lgtyp                                        varchar2(3 char)                    null,
    lvorm                                        varchar2(1 char)                    null,
    lgpla                                        varchar2(10 char)                   null,
    lpmax                                        number                              null,
    lpmin                                        number                              null,
    mamng                                        number                              null,
    nsmng                                        number                              null,
    kober                                        varchar2(3 char)                    null,
    rdmng                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_mat_mlg is 'LADS Material Storage Type Data';
comment on column lads_mat_mlg.matnr is 'Material Number';
comment on column lads_mat_mlg.mgnseq is 'MGN - generated sequence number';
comment on column lads_mat_mlg.mlgseq is 'MLG - generated sequence number';
comment on column lads_mat_mlg.msgfn is 'Function';
comment on column lads_mat_mlg.lgtyp is 'Storage Type';
comment on column lads_mat_mlg.lvorm is 'Deletion flag for all material data of a storage type';
comment on column lads_mat_mlg.lgpla is 'Storage Bin';
comment on column lads_mat_mlg.lpmax is 'Maximum storage bin quantity';
comment on column lads_mat_mlg.lpmin is 'Minimum storage bin quantity';
comment on column lads_mat_mlg.mamng is 'Control quantity';
comment on column lads_mat_mlg.nsmng is 'Replenishment quantity';
comment on column lads_mat_mlg.kober is 'Picking Area';
comment on column lads_mat_mlg.rdmng is 'Rounding qty';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_mlg
   add constraint lads_mat_mlg_pk primary key (matnr, mgnseq, mlgseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_mlg to lads_app;
grant select, insert, update, delete on lads_mat_mlg to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_mlg for lads.lads_mat_mlg;

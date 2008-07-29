/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_mrd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_mrd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_mrd
   (matnr                                        varchar2(18 char)                   not null,
    mrcseq                                       number                              not null,
    mrdseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    lgort                                        varchar2(4 char)                    null,
    pstat                                        varchar2(15 char)                   null,
    lvorm                                        varchar2(1 char)                    null,
    diskz                                        varchar2(1 char)                    null,
    lsobs                                        varchar2(2 char)                    null,
    lminb                                        number                              null,
    lbstf                                        number                              null,
    herkl                                        varchar2(3 char)                    null,
    exppg                                        varchar2(1 char)                    null,
    exver                                        varchar2(2 char)                    null,
    lgpbe                                        varchar2(10 char)                   null,
    prctl                                        varchar2(10 char)                   null,
    lwmkb                                        varchar2(3 char)                    null,
    bskrf                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_mat_mrd is 'LADS Material Warehouse and Batch';
comment on column lads_mat_mrd.matnr is 'Material Number';
comment on column lads_mat_mrd.mrcseq is 'MRC - generated sequence number';
comment on column lads_mat_mrd.mrdseq is 'MRD - generated sequence number';
comment on column lads_mat_mrd.msgfn is 'Function';
comment on column lads_mat_mrd.lgort is 'Storage Location';
comment on column lads_mat_mrd.pstat is 'Maintenance status';
comment on column lads_mat_mrd.lvorm is 'Flag Material for Deletion at Storage Location Level';
comment on column lads_mat_mrd.diskz is 'Storage location MRP indicator';
comment on column lads_mat_mrd.lsobs is 'Special procurement type';
comment on column lads_mat_mrd.lminb is 'Reorder point for storage location MRP';
comment on column lads_mat_mrd.lbstf is 'Replenishment quantity for storage location MRP';
comment on column lads_mat_mrd.herkl is 'Country of origin of the material';
comment on column lads_mat_mrd.exppg is 'Preference indicator (deactivated)';
comment on column lads_mat_mrd.exver is 'Export indicator (deactivated)';
comment on column lads_mat_mrd.lgpbe is 'Storage bin';
comment on column lads_mat_mrd.prctl is 'Profit Center';
comment on column lads_mat_mrd.lwmkb is 'Picking area for lean WM';
comment on column lads_mat_mrd.bskrf is 'Inventory correction factor';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_mrd
   add constraint lads_mat_mrd_pk primary key (matnr, mrcseq, mrdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_mrd to lads_app;
grant select, insert, update, delete on lads_mat_mrd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_mrd for lads.lads_mat_mrd;

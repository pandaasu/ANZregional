/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_mgn
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_mgn

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_mgn
   (matnr                                        varchar2(18 char)                   not null,
    mgnseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    lgnum                                        varchar2(3 char)                    null,
    lvorm                                        varchar2(1 char)                    null,
    lgbkz                                        varchar2(3 char)                    null,
    ltkze                                        varchar2(3 char)                    null,
    ltkza                                        varchar2(3 char)                    null,
    lhmg1                                        number                              null,
    lhmg2                                        number                              null,
    lhmg3                                        number                              null,
    lhme1                                        varchar2(3 char)                    null,
    lhme2                                        varchar2(3 char)                    null,
    lhme3                                        varchar2(3 char)                    null,
    lety1                                        varchar2(3 char)                    null,
    lety2                                        varchar2(3 char)                    null,
    lety3                                        varchar2(3 char)                    null,
    lvsme                                        varchar2(3 char)                    null,
    kzzul                                        varchar2(1 char)                    null,
    block                                        varchar2(2 char)                    null,
    kzmbf                                        varchar2(1 char)                    null,
    bsskz                                        varchar2(1 char)                    null,
    mkapv                                        number                              null,
    bezme                                        varchar2(3 char)                    null,
    plkpt                                        varchar2(3 char)                    null,
    vomem                                        varchar2(1 char)                    null,
    l2skr                                        varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_mat_mgn is 'LADS Material Warehouse Number Data';
comment on column lads_mat_mgn.matnr is 'Material Number';
comment on column lads_mat_mgn.mgnseq is 'MGN - generated sequence number';
comment on column lads_mat_mgn.msgfn is 'Function';
comment on column lads_mat_mgn.lgnum is 'Warehouse Number / Warehouse Complex';
comment on column lads_mat_mgn.lvorm is 'Deletion flag for all material data of a warehouse number';
comment on column lads_mat_mgn.lgbkz is 'Storage section indicator';
comment on column lads_mat_mgn.ltkze is 'Storage type indicator for stock placement';
comment on column lads_mat_mgn.ltkza is 'Storage type indicator for stock removal';
comment on column lads_mat_mgn.lhmg1 is 'Loading equipment quantity';
comment on column lads_mat_mgn.lhmg2 is 'Loading equipment quantity';
comment on column lads_mat_mgn.lhmg3 is 'Loading equipment quantity';
comment on column lads_mat_mgn.lhme1 is 'Unit of measure for loading equipment quantity';
comment on column lads_mat_mgn.lhme2 is 'Unit of measure for loading equipment quantity';
comment on column lads_mat_mgn.lhme3 is 'Unit of measure for loading equipment quantity';
comment on column lads_mat_mgn.lety1 is 'Storage Unit Type';
comment on column lads_mat_mgn.lety2 is 'Storage Unit Type';
comment on column lads_mat_mgn.lety3 is 'Storage Unit Type';
comment on column lads_mat_mgn.lvsme is 'Warehouse Management Unit of Measure';
comment on column lads_mat_mgn.kzzul is 'Indicator: Allow addition to existing stock';
comment on column lads_mat_mgn.block is 'Bulk storage indicator';
comment on column lads_mat_mgn.kzmbf is 'Indicator: Message to inventory management';
comment on column lads_mat_mgn.bsskz is 'Special movement indicator for warehouse management';
comment on column lads_mat_mgn.mkapv is 'Capacity usage';
comment on column lads_mat_mgn.bezme is 'Unit of measure for capacity consumption';
comment on column lads_mat_mgn.plkpt is 'Picking storage type for rough-cut and detailed planning';
comment on column lads_mat_mgn.vomem is 'Default for unit of measure from material master record';
comment on column lads_mat_mgn.l2skr is 'Material relevance for 2-step picking';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_mgn
   add constraint lads_mat_mgn_pk primary key (matnr, mgnseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_mgn to lads_app;
grant select, insert, update, delete on lads_mat_mgn to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_mgn for lads.lads_mat_mgn;

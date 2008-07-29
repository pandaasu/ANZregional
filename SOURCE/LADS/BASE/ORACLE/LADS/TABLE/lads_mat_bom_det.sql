/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_bom_det
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_bom_det

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_bom_det
   (stlnr                                        varchar2(8 char)                    not null,
    stlal                                        varchar2(2 char)                    not null,
    detseq                                       number                              not null,
    posnr                                        varchar2(4 char)                    null,
    postp                                        varchar2(1 char)                    null,
    idnrk                                        varchar2(18 char)                   null,
    menge_c                                      number                              null,
    meins                                        varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table lads_mat_bom_det is 'LADS Material BOM Detail';
comment on column lads_mat_bom_det.stlnr is 'Bill of Material';
comment on column lads_mat_bom_det.stlal is 'Alternative BOM';
comment on column lads_mat_bom_det.detseq is 'DET - generated sequence number';
comment on column lads_mat_bom_det.posnr is 'Item No';
comment on column lads_mat_bom_det.postp is 'Item Category';
comment on column lads_mat_bom_det.idnrk is 'Component ';
comment on column lads_mat_bom_det.menge_c is 'Component Quantity';
comment on column lads_mat_bom_det.meins is 'Component UOM';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_bom_det
   add constraint lads_mat_bom_det_pk primary key (stlnr, stlal, detseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_bom_det to lads_app;
grant select, insert, update, delete on lads_mat_bom_det to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_bom_det for lads.lads_mat_bom_det;

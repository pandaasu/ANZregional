/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : temp_bom_det
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - temp_bom_det (TEMPORARY)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/02   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table temp_bom_det
   (msgfn                                        varchar2(3 char)                    null,
    matnr                                        varchar2(18 char)                   not null,
    stlal                                        varchar2(2 char)                    not null,
    werks                                        varchar2(4 char)                    not null,
    detseq                                       number                              not null,
    posnr                                        varchar2(4 char)                    null,
    postp                                        varchar2(1 char)                    null,
    idnrk                                        varchar2(18 char)                   null,
    menge                                        number                              null,
    meins                                        varchar2(3 char)                    null,
    datuv                                        varchar2(8 char)                    null,
    datub                                        varchar2(8 char)                    null);

/**/
/* Comments
/**/
comment on table temp_bom_det is 'LADS Bill Of Material Detail';
comment on column temp_bom_det.msgfn is 'Item Message Function';
comment on column temp_bom_det.matnr is 'Material Number';
comment on column temp_bom_det.stlal is 'Alternative BOM';
comment on column temp_bom_det.werks is 'Plant';
comment on column temp_bom_det.detseq is 'DET - generated sequence number';
comment on column temp_bom_det.posnr is 'Item Number';
comment on column temp_bom_det.postp is 'Item Category';
comment on column temp_bom_det.idnrk is 'Component';
comment on column temp_bom_det.menge is 'Component Quantity';
comment on column temp_bom_det.meins is 'Component UOM';
comment on column temp_bom_det.datuv is 'Component Valid From Date';
comment on column temp_bom_det.datub is 'Component Valid To Date';

/**/
/* Primary Key Constraint
/**/
alter table temp_bom_det
   add constraint temp_bom_det_pk primary key (stlal, matnr, werks, detseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on temp_bom_det to lads_app;
grant select on temp_bom_det to ics_reader with grant option;

/**/
/* Synonym
/**/
create public synonym temp_bom_det for lads.temp_bom_det;

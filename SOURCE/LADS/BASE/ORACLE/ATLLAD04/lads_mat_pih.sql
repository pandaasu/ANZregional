/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_pih
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_pih

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_pih
   (matnr                                        varchar2(18 char)                   not null,
    pchseq                                       number                              not null,
    pcrseq                                       number                              not null,
    pihseq                                       number                              not null,
    packnr                                       varchar2(22 char)                   null,
    height                                       number                              null,
    width                                        number                              null,
    length                                       number                              null,
    tarewei                                      number                              null,
    loadwei                                      number                              null,
    totlwei                                      number                              null,
    tarevol                                      number                              null,
    loadvol                                      number                              null,
    totlvol                                      number                              null,
    pobjid                                       varchar2(20 char)                   null,
    stfac                                        number                              null,
    chdat                                        varchar2(8 char)                    null,
    unitdim                                      varchar2(3 char)                    null,
    unitwei                                      varchar2(3 char)                    null,
    unitwei_max                                  varchar2(3 char)                    null,
    unitvol                                      varchar2(3 char)                    null,
    unitvol_max                                  varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table lads_mat_pih is 'LADS Material Packaging Instruction Header';
comment on column lads_mat_pih.matnr is 'Material Number';
comment on column lads_mat_pih.pchseq is 'PCH - generated sequence number';
comment on column lads_mat_pih.pcrseq is 'PCR - generated sequence number';
comment on column lads_mat_pih.pihseq is 'PIH - generated sequence number';
comment on column lads_mat_pih.packnr is 'Unique internal packing object number';
comment on column lads_mat_pih.height is 'Height';
comment on column lads_mat_pih.width is 'Width';
comment on column lads_mat_pih.length is 'Length';
comment on column lads_mat_pih.tarewei is 'Tare weight of packaging materials';
comment on column lads_mat_pih.loadwei is 'Loading weight of goods to be packed';
comment on column lads_mat_pih.totlwei is 'Total weight of handling unit';
comment on column lads_mat_pih.tarevol is 'Tare volume of packaging materials';
comment on column lads_mat_pih.loadvol is 'Loading volume of goods to be packed';
comment on column lads_mat_pih.totlvol is 'Total volume of handling unit';
comment on column lads_mat_pih.pobjid is 'Identification number of packing instruction';
comment on column lads_mat_pih.stfac is 'Stacking factor';
comment on column lads_mat_pih.chdat is 'Date of last change';
comment on column lads_mat_pih.unitdim is 'Unit of dimension for length/width/height';
comment on column lads_mat_pih.unitwei is 'Unit of weight';
comment on column lads_mat_pih.unitwei_max is 'Unit of weight';
comment on column lads_mat_pih.unitvol is 'Volume unit';
comment on column lads_mat_pih.unitvol_max is 'Volume unit';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_pih
   add constraint lads_mat_pih_pk primary key (matnr, pchseq, pcrseq, pihseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_pih to lads_app;
grant select, insert, update, delete on lads_mat_pih to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_pih for lads.lads_mat_pih;

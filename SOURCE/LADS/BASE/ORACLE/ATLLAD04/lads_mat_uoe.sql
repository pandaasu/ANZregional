/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_uoe
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_uoe

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_uoe
   (matnr                                        varchar2(18 char)                   not null,
    uomseq                                       number                              not null,
    uoeseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    meinh                                        varchar2(3 char)                    null,
    lfnum                                        varchar2(5 char)                    null,
    ean11                                        varchar2(18 char)                   null,
    eantp                                        varchar2(2 char)                    null,
    hpean                                        varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_mat_uoe is 'LADS Material Additional EAN';
comment on column lads_mat_uoe.matnr is 'Material Number';
comment on column lads_mat_uoe.uomseq is 'UOM - generated sequence number';
comment on column lads_mat_uoe.uoeseq is 'UOE - generated sequence number';
comment on column lads_mat_uoe.msgfn is 'Function';
comment on column lads_mat_uoe.meinh is 'Unit of Measure for Display';
comment on column lads_mat_uoe.lfnum is 'Consecutive Number';
comment on column lads_mat_uoe.ean11 is 'International Article Number (EAN/UPC)';
comment on column lads_mat_uoe.eantp is 'Category of International Article Number (EAN)';
comment on column lads_mat_uoe.hpean is 'Indicator: Main EAN';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_uoe
   add constraint lads_mat_uoe_pk primary key (matnr, uomseq, uoeseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_uoe to lads_app;
grant select, insert, update, delete on lads_mat_uoe to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_uoe for lads.lads_mat_uoe;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_mge
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_mge

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_mge
   (kunnr                                        varchar2(10 char)                   not null,
    mgeseq                                       number                              not null,
    locnr                                        varchar2(10 char)                   null,
    matnr                                        varchar2(18 char)                   null,
    wmatn                                        varchar2(18 char)                   null,
    matkl                                        varchar2(9 char)                    null);

/**/
/* Comments
/**/
comment on table lads_cus_mge is 'LADS Customer Value Only Material Determination Exception';
comment on column lads_cus_mge.kunnr is 'Customer Number';
comment on column lads_cus_mge.mgeseq is 'MGE - generated sequence number';
comment on column lads_cus_mge.locnr is 'Customer number for plant';
comment on column lads_cus_mge.matnr is 'Material Number';
comment on column lads_cus_mge.wmatn is 'Posting material number of value-only or individual material';
comment on column lads_cus_mge.matkl is 'Material Group';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_mge
   add constraint lads_cus_mge_pk primary key (kunnr, mgeseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_mge to lads_app;
grant select, insert, update, delete on lads_cus_mge to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_mge for lads.lads_cus_mge;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_mkt
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_mkt

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_mkt
   (matnr                                        varchar2(18 char)                   not null,
    mktseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    spras                                        varchar2(1 char)                    null,
    maktx                                        varchar2(40 char)                   null,
    spras_iso                                    varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_mat_mkt is 'LADS Material Description';
comment on column lads_mat_mkt.matnr is 'Material Number';
comment on column lads_mat_mkt.mktseq is 'MKT - generated sequence number';
comment on column lads_mat_mkt.msgfn is 'Function';
comment on column lads_mat_mkt.spras is 'Language Key';
comment on column lads_mat_mkt.maktx is 'Material Description';
comment on column lads_mat_mkt.spras_iso is 'Language according to ISO 639';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_mkt
   add constraint lads_mat_mkt_pk primary key (matnr, mktseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_mkt to lads_app;
grant select, insert, update, delete on lads_mat_mkt to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_mkt for lads.lads_mat_mkt;

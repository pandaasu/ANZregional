/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_itx
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_itx

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_itx
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    itxseq                                       number                              not null,
    tdid                                         varchar2(4 char)                    null,
    tsspras                                      varchar2(3 char)                    null,
    tsspras_iso                                  varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_inv_itx is 'LADS Invoice Item Text Header';
comment on column lads_inv_itx.belnr is 'IDOC document number';
comment on column lads_inv_itx.genseq is 'GEN - generated sequence number';
comment on column lads_inv_itx.itxseq is 'ITX - generated sequence number';
comment on column lads_inv_itx.tdid is 'Text ID';
comment on column lads_inv_itx.tsspras is 'Language Key';
comment on column lads_inv_itx.tsspras_iso is 'Language according to ISO 639';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_itx
   add constraint lads_inv_itx_pk primary key (belnr, genseq, itxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_itx to lads_app;
grant select, insert, update, delete on lads_inv_itx to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_itx for lads.lads_inv_itx;

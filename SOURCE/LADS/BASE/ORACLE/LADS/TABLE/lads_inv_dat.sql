/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_dat
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_dat

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_dat
   (belnr                                        varchar2(35 char)                   not null,
    datseq                                       number                              not null,
    iddat                                        varchar2(3 char)                    null,
    datum                                        varchar2(8 char)                    null,
    uzeit                                        varchar2(6 char)                    null);

/**/
/* Comments
/**/
comment on table lads_inv_dat is 'LADS Invoice Date';
comment on column lads_inv_dat.belnr is 'IDOC document number';
comment on column lads_inv_dat.datseq is 'DAT - generated sequence number';
comment on column lads_inv_dat.iddat is 'Qualifier for IDOC date segment';
comment on column lads_inv_dat.datum is 'IDOC: Date';
comment on column lads_inv_dat.uzeit is 'IDOC: Time';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_dat
   add constraint lads_inv_dat_pk primary key (belnr, datseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_dat to lads_app;
grant select, insert, update, delete on lads_inv_dat to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_dat for lads.lads_inv_dat;

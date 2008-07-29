/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_dat
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_dat

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_dat
   (belnr                                        varchar2(35 char)                   not null,
    datseq                                       number                              not null,
    iddat                                        varchar2(3 char)                    null,
    datum                                        varchar2(8 char)                    null,
    uzeit                                        varchar2(6 char)                    null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_dat is 'LADS Sales Order Date';
comment on column lads_sal_ord_dat.belnr is 'Document number';
comment on column lads_sal_ord_dat.datseq is 'DAT - generated sequence number';
comment on column lads_sal_ord_dat.iddat is 'Qualifier for IDOC date segment';
comment on column lads_sal_ord_dat.datum is 'IDOC: Date';
comment on column lads_sal_ord_dat.uzeit is 'IDOC: Time';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_dat
   add constraint lads_sal_ord_dat_pk primary key (belnr, datseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_dat to lads_app;
grant select, insert, update, delete on lads_sal_ord_dat to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_dat for lads.lads_sal_ord_dat;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_ias
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_ias

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_ias
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    iasseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    betrg                                        varchar2(18 char)                   null,
    krate                                        varchar2(15 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_ias is 'LADS Invoice Item Amount';
comment on column lads_inv_ias.belnr is 'IDOC document number';
comment on column lads_inv_ias.genseq is 'GEN - generated sequence number';
comment on column lads_inv_ias.iasseq is 'IAS - generated sequence number';
comment on column lads_inv_ias.qualf is 'Qualifier amount';
comment on column lads_inv_ias.betrg is 'Total value of sum segment';
comment on column lads_inv_ias.krate is 'Condition record per unit';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_ias
   add constraint lads_inv_ias_pk primary key (belnr, genseq, iasseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_ias to lads_app;
grant select, insert, update, delete on lads_inv_ias to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_ias for lads.lads_inv_ias;

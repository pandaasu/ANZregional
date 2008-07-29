/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_cus
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_cus

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_cus
   (belnr                                        varchar2(35 char)                   not null,
    cusseq                                       number                              not null,
    customer                                     varchar2(10 char)                   null,
    atnam                                        varchar2(30 char)                   null,
    atwrt                                        varchar2(30 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_cus is 'LADS Invoice Japan Customer';
comment on column lads_inv_cus.belnr is 'IDOC document number';
comment on column lads_inv_cus.cusseq is 'CUS - generated sequence number';
comment on column lads_inv_cus.customer is 'Customer Number';
comment on column lads_inv_cus.atnam is 'Characteristic Name';
comment on column lads_inv_cus.atwrt is 'Characteristic Value';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_cus
   add constraint lads_inv_cus_pk primary key (belnr, cusseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_cus to lads_app;
grant select, insert, update, delete on lads_inv_cus to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_cus for lads.lads_inv_cus;

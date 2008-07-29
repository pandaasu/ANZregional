/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_tod
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_tod

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_tod
   (belnr                                        varchar2(35 char)                   not null,
    todseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    lkond                                        varchar2(3 char)                    null,
    lktext                                       varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_tod is 'LADS Invoice Terms Of Delivery';
comment on column lads_inv_tod.belnr is 'IDOC document number';
comment on column lads_inv_tod.todseq is 'TOD - generated sequence number';
comment on column lads_inv_tod.qualf is 'IDOC qualifier: Terms of delivery';
comment on column lads_inv_tod.lkond is 'IDOC delivery condition code';
comment on column lads_inv_tod.lktext is 'IDOC delivery condition text';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_tod
   add constraint lads_inv_tod_pk primary key (belnr, todseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_tod to lads_app;
grant select, insert, update, delete on lads_inv_tod to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_tod for lads.lads_inv_tod;

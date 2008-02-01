/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_smy
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_smy

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_smy
   (belnr                                        varchar2(35 char)                   not null,
    smyseq                                       number                              not null,
    sumid                                        varchar2(3 char)                    null,
    summe                                        varchar2(18 char)                   null,
    sunit                                        varchar2(3 char)                    null,
    waerq                                        varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table lads_inv_smy is 'LADS Invoice Summary';
comment on column lads_inv_smy.belnr is 'IDOC document number';
comment on column lads_inv_smy.smyseq is 'SMY - generated sequence number';
comment on column lads_inv_smy.sumid is 'Qualifier for totals segment for shipping notification';
comment on column lads_inv_smy.summe is 'Total value of sum segment';
comment on column lads_inv_smy.sunit is 'Total value unit for totals segment in the shipping notif.';
comment on column lads_inv_smy.waerq is 'Currency';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_smy
   add constraint lads_inv_smy_pk primary key (belnr, smyseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_smy to lads_app;
grant select, insert, update, delete on lads_inv_smy to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_smy for lads.lads_inv_smy;

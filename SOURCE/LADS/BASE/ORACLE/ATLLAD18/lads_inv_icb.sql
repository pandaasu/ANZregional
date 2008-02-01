/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_icb
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_icb

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_icb
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    icbseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    ivkon                                        varchar2(30 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_icb is 'LADS Invoice Item Intercompany Billing';
comment on column lads_inv_icb.belnr is 'IDOC document number';
comment on column lads_inv_icb.genseq is 'GEN - generated sequence number';
comment on column lads_inv_icb.icbseq is 'ICB - generated sequence number';
comment on column lads_inv_icb.qualf is 'IDOC qualifier reference document';
comment on column lads_inv_icb.ivkon is '30 Characters';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_icb
   add constraint lads_inv_icb_pk primary key (belnr, genseq, icbseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_icb to lads_app;
grant select, insert, update, delete on lads_inv_icb to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_icb for lads.lads_inv_icb;

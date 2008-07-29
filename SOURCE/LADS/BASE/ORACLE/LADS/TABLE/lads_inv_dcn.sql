/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_dcn
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_dcn

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_dcn
   (belnr                                        varchar2(35 char)                   not null,
    dcnseq                                       number                              not null,
    alckz                                        varchar2(3 char)                    null,
    kschl                                        varchar2(4 char)                    null,
    kotxt                                        varchar2(80 char)                   null,
    betrg                                        varchar2(18 char)                   null,
    kperc                                        varchar2(8 char)                    null,
    krate                                        varchar2(15 char)                   null,
    uprbs                                        varchar2(9 char)                    null,
    meaun                                        varchar2(3 char)                    null,
    kobtr                                        varchar2(18 char)                   null,
    mwskz                                        varchar2(7 char)                    null,
    msatz                                        varchar2(17 char)                   null,
    koein                                        varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table lads_inv_dcn is 'LADS Invoice Discount';
comment on column lads_inv_dcn.belnr is 'IDOC document number';
comment on column lads_inv_dcn.dcnseq is 'DCN - generated sequence number';
comment on column lads_inv_dcn.alckz is 'Surcharge or discount indicator';
comment on column lads_inv_dcn.kschl is 'Condition type (coded)';
comment on column lads_inv_dcn.kotxt is 'Condition text';
comment on column lads_inv_dcn.betrg is 'Fixed surcharge/discount on total gross';
comment on column lads_inv_dcn.kperc is 'Condition percentage rate';
comment on column lads_inv_dcn.krate is 'Condition record per unit';
comment on column lads_inv_dcn.uprbs is 'Price unit';
comment on column lads_inv_dcn.meaun is 'Unit of measurement';
comment on column lads_inv_dcn.kobtr is 'IDoc condition end amount';
comment on column lads_inv_dcn.mwskz is 'VAT indicator';
comment on column lads_inv_dcn.msatz is 'VAT rate';
comment on column lads_inv_dcn.koein is 'Currency';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_dcn
   add constraint lads_inv_dcn_pk primary key (belnr, dcnseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_dcn to lads_app;
grant select, insert, update, delete on lads_inv_dcn to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_dcn for lads.lads_inv_dcn;

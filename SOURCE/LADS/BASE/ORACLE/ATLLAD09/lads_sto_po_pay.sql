/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sto_po_pay
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sto_po_pay

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sto_po_pay
   (belnr                                        varchar2(35 char)                   not null,
    payseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    tage                                         varchar2(8 char)                    null,
    prznt                                        varchar2(8 char)                    null,
    zterm_txt                                    varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sto_po_pay is 'LADS Stock Transfer and Purchase Order Payment';
comment on column lads_sto_po_pay.belnr is 'IDOC document number';
comment on column lads_sto_po_pay.payseq is 'PAY - generated sequence number';
comment on column lads_sto_po_pay.qualf is 'IDOC qualifier reference document';
comment on column lads_sto_po_pay.tage is 'IDOC Number of days';
comment on column lads_sto_po_pay.prznt is 'IDOC percentage for terms of payment';
comment on column lads_sto_po_pay.zterm_txt is 'Terms Of Payment Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_sto_po_pay
   add constraint lads_sto_po_pay_pk primary key (belnr, payseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sto_po_pay to lads_app;
grant select, insert, update, delete on lads_sto_po_pay to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sto_po_pay for lads.lads_sto_po_pay;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_itp
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_itp

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_itp
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    itpseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    tage                                         varchar2(8 char)                    null,
    prznt                                        varchar2(8 char)                    null,
    zterm_txt                                    varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_itp is 'LADS Sales Order Item Terms Of Payment';
comment on column lads_sal_ord_itp.belnr is 'Document number';
comment on column lads_sal_ord_itp.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_itp.itpseq is 'ITP - generated sequence number';
comment on column lads_sal_ord_itp.qualf is 'IDOC qualifier: Terms of payment';
comment on column lads_sal_ord_itp.tage is 'IDOC Number of days';
comment on column lads_sal_ord_itp.prznt is 'IDOC percentage for terms of payment';
comment on column lads_sal_ord_itp.zterm_txt is 'Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_itp
   add constraint lads_sal_ord_itp_pk primary key (belnr, genseq, itpseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_itp to lads_app;
grant select, insert, update, delete on lads_sal_ord_itp to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_itp for lads.lads_sal_ord_itp;

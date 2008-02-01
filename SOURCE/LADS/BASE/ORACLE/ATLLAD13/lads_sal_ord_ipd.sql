/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_ipd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_ipd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_ipd
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    ipnseq                                       number                              not null,
    ipdseq                                       number                              not null,
    qualp                                        varchar2(3 char)                    null,
    stdpn                                        varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_ipd is 'LADS Sales Order Item Partner Additional';
comment on column lads_sal_ord_ipd.belnr is 'Document number';
comment on column lads_sal_ord_ipd.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_ipd.ipnseq is 'IPN - generated sequence number';
comment on column lads_sal_ord_ipd.ipdseq is 'IPD - generated sequence number';
comment on column lads_sal_ord_ipd.qualp is 'IDOC Partner identification (e.g.Dun and Bradstreet number)';
comment on column lads_sal_ord_ipd.stdpn is '"Character field, length 70"';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_ipd
   add constraint lads_sal_ord_ipd_pk primary key (belnr, genseq, ipnseq, ipdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_ipd to lads_app;
grant select, insert, update, delete on lads_sal_ord_ipd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_ipd for lads.lads_sal_ord_ipd;

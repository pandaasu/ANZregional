/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_ips
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_ips

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_ips
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    icoseq                                       number                              not null,
    ipsseq                                       number                              not null,
    kstbm                                        number                              null,
    kbetr                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_ips is 'LADS Sales Order Item Condition Price Scale';
comment on column lads_sal_ord_ips.belnr is 'Document number';
comment on column lads_sal_ord_ips.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_ips.icoseq is 'ICO - generated sequence number';
comment on column lads_sal_ord_ips.ipsseq is 'IPS - generated sequence number';
comment on column lads_sal_ord_ips.kstbm is 'Condition scale quantity';
comment on column lads_sal_ord_ips.kbetr is 'Rate (condition amount or percentage)';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_ips
   add constraint lads_sal_ord_ips_pk primary key (belnr, genseq, icoseq, ipsseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_ips to lads_app;
grant select, insert, update, delete on lads_sal_ord_ips to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_ips for lads.lads_sal_ord_ips;

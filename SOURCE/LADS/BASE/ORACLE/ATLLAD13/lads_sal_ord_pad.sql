/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_pad
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_pad

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_pad
   (belnr                                        varchar2(35 char)                   not null,
    pnrseq                                       number                              not null,
    padseq                                       number                              not null,
    qualp                                        varchar2(3 char)                    null,
    stdpn                                        varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_pad is 'LADS Sales Order Partner Additional';
comment on column lads_sal_ord_pad.belnr is 'Document number';
comment on column lads_sal_ord_pad.pnrseq is 'PNR - generated sequence number';
comment on column lads_sal_ord_pad.padseq is 'PAD - generated sequence number';
comment on column lads_sal_ord_pad.qualp is 'IDOC Partner identification (e.g.Dun and Bradstreet number)';
comment on column lads_sal_ord_pad.stdpn is '"Character field, length 70"';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_pad
   add constraint lads_sal_ord_pad_pk primary key (belnr, pnrseq, padseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_pad to lads_app;
grant select, insert, update, delete on lads_sal_ord_pad to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_pad for lads.lads_sal_ord_pad;

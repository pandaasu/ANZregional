/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_txt
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_txt

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_txt
   (belnr                                        varchar2(35 char)                   not null,
    txiseq                                       number                              not null,
    txtseq                                       number                              not null,
    tdline                                       varchar2(70 char)                   null,
    tdformat                                     varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_txt is 'LADS Sales Order Text Detail';
comment on column lads_sal_ord_txt.belnr is 'Document number';
comment on column lads_sal_ord_txt.txiseq is 'TXI - generated sequence number';
comment on column lads_sal_ord_txt.txtseq is 'TXT - generated sequence number';
comment on column lads_sal_ord_txt.tdline is 'Text line';
comment on column lads_sal_ord_txt.tdformat is 'Tag column';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_txt
   add constraint lads_sal_ord_txt_pk primary key (belnr, txiseq, txtseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_txt to lads_app;
grant select, insert, update, delete on lads_sal_ord_txt to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_txt for lads.lads_sal_ord_txt;

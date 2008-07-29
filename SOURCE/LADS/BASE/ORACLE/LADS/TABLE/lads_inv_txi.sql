/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_txi
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_txi

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_txi
   (belnr                                        varchar2(35 char)                   not null,
    txtseq                                       number                              not null,
    txiseq                                       number                              not null,
    tdline                                       varchar2(70 char)                   null,
    tdformat                                     varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_inv_txi is 'LADS Invoice Text Detail';
comment on column lads_inv_txi.belnr is 'IDOC document number';
comment on column lads_inv_txi.txtseq is 'TXT - generated sequence number';
comment on column lads_inv_txi.txiseq is 'TXI - generated sequence number';
comment on column lads_inv_txi.tdline is 'Text line';
comment on column lads_inv_txi.tdformat is 'Tag column';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_txi
   add constraint lads_inv_txi_pk primary key (belnr, txtseq, txiseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_txi to lads_app;
grant select, insert, update, delete on lads_inv_txi to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_txi for lads.lads_inv_txi;

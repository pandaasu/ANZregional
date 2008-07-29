/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sto_po_htx
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sto_po_htx

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sto_po_htx
   (belnr                                        varchar2(35 char)                   not null,
    htiseq                                       number                              not null,
    htxseq                                       number                              not null,
    tdformat                                     varchar2(2 char)                    null,
    tdline                                       varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sto_po_htx is 'LADS Stock Transfer and Purchase Order Text Detail';
comment on column lads_sto_po_htx.belnr is 'IDOC document number';
comment on column lads_sto_po_htx.htiseq is 'HTI - generated sequence number';
comment on column lads_sto_po_htx.htxseq is 'HTX - generated sequence number';
comment on column lads_sto_po_htx.tdformat is 'Tag column';
comment on column lads_sto_po_htx.tdline is 'Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_sto_po_htx
   add constraint lads_sto_po_htx_pk primary key (belnr, htiseq, htxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sto_po_htx to lads_app;
grant select, insert, update, delete on lads_sto_po_htx to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sto_po_htx for lads.lads_sto_po_htx;

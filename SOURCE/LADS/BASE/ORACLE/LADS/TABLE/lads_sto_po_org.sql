/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sto_po_org
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sto_po_org

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sto_po_org
   (belnr                                        varchar2(35 char)                   not null,
    orgseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    orgid                                        varchar2(35 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sto_po_org is 'LADS Stock Transfer and Purchase Order Organizational';
comment on column lads_sto_po_org.belnr is 'IDOC document number';
comment on column lads_sto_po_org.orgseq is 'ORG - generated sequence number';
comment on column lads_sto_po_org.qualf is 'IDOC qualifier reference document';
comment on column lads_sto_po_org.orgid is 'IDOC organization data';

/**/
/* Primary Key Constraint
/**/
alter table lads_sto_po_org
   add constraint lads_sto_po_org_pk primary key (belnr, orgseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sto_po_org to lads_app;
grant select, insert, update, delete on lads_sto_po_org to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sto_po_org for lads.lads_sto_po_org;

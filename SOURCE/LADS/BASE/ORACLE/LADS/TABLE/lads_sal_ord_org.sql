/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_org
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_org

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_org
   (belnr                                        varchar2(35 char)                   not null,
    orgseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    orgid                                        varchar2(35 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_org is 'LADS Sales Order Organisational';
comment on column lads_sal_ord_org.belnr is 'Document number';
comment on column lads_sal_ord_org.orgseq is 'ORG - generated sequence number';
comment on column lads_sal_ord_org.qualf is 'IDOC qualifer organization';
comment on column lads_sal_ord_org.orgid is 'IDOC organization';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_org
   add constraint lads_sal_ord_org_pk primary key (belnr, orgseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_org to lads_app;
grant select, insert, update, delete on lads_sal_ord_org to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_org for lads.lads_sal_ord_org;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_org
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_org

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_org
   (belnr                                        varchar2(35 char)                   not null,
    orgseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    orgid                                        varchar2(35 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_org is 'LADS Invoice Organisational';
comment on column lads_inv_org.belnr is 'IDOC document number';
comment on column lads_inv_org.orgseq is 'ORG - generated sequence number';
comment on column lads_inv_org.qualf is 'IDOC qualifer organization';
comment on column lads_inv_org.orgid is 'IDOC organization';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_org
   add constraint lads_inv_org_pk primary key (belnr, orgseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_org to lads_app;
grant select, insert, update, delete on lads_inv_org to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_org for lads.lads_inv_org;

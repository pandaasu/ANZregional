/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_org
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_org

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_org
   (zzgrpnr                                      varchar2(40 char)                   not null,
    ordseq                                       number                              not null,
    horseq                                       number                              not null,
    orgseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    orgid                                        varchar2(35 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_org is 'Generic ICB Document - Order data';
comment on column lads_exp_org.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_org.ordseq is 'ORD - generated sequence number';
comment on column lads_exp_org.horseq is 'HOR - generated sequence number';
comment on column lads_exp_org.orgseq is 'ORG - generated sequence number';
comment on column lads_exp_org.qualf is 'IDOC qualifer organization';
comment on column lads_exp_org.orgid is 'IDOC organization';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_org
   add constraint lads_exp_org_pk primary key (zzgrpnr, ordseq, horseq, orgseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_org to lads_app;
grant select, insert, update, delete on lads_exp_org to ics_app;
grant select on lads_exp_org to ics_reader with grant option;
grant select on lads_exp_org to ics_executor;
grant select on lads_exp_org to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_org for lads.lads_exp_org;

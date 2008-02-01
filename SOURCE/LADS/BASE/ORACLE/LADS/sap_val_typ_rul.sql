/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_val_typ_rul
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Validation Type Rule

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_val_typ_rul
   (vtr_type                                     varchar2(30 char)                   not null,
    vtr_rule                                     varchar2(30 char)                   not null,
    vtr_sequence                                 number                              not null);

/**/
/* Comments
/**/
comment on table sap_val_typ_rul is 'SAP Validation Type Rule';
comment on column sap_val_typ_rul.vtr_type is 'Validation type identifier';
comment on column sap_val_typ_rul.vtr_rule is 'Validation type rule';
comment on column sap_val_typ_rul.vtr_sequence is 'Validation type rule sequence';

/**/
/* Primary Key Constraint
/**/
alter table sap_val_typ_rul
   add constraint sap_val_typ_rul_pk primary key (vtr_type, vtr_rule);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_val_typ_rul to lads_app;
grant select on sap_val_typ_rul to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_val_typ_rul for lads.sap_val_typ_rul;

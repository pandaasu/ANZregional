/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_val_cla_rul
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Validation Classification Rule

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_val_cla_rul
   (vcr_class                                    varchar2(30 char)                   not null,
    vcr_rule                                     varchar2(30 char)                   not null,
    vcr_sequence                                 number                              not null);

/**/
/* Comments
/**/
comment on table sap_val_cla_rul is 'SAP Validation Classification Rule';
comment on column sap_val_cla_rul.vcr_class is 'Validation classification identifier';
comment on column sap_val_cla_rul.vcr_rule is 'Validation classification rule';
comment on column sap_val_cla_rul.vcr_sequence is 'Validation classification rule sequence';

/**/
/* Primary Key Constraint
/**/
alter table sap_val_cla_rul
   add constraint sap_val_cla_rul_pk primary key (vcr_class, vcr_rule);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_val_cla_rul to lads_app;
grant select on sap_val_cla_rul to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_val_cla_rul for lads.sap_val_cla_rul;

/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_val_rul
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Validation Rule

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_val_rul
   (var_rule                                     varchar2(30 char)                   not null,
    var_description                              varchar2(128 char)                  not null,
    var_group                                    varchar2(30 char)                   not null,
    var_query                                    clob                                not null,
    var_test                                     varchar2(15 char)                   not null,
    var_message                                  varchar2(4000 char)                 null);

/**/
/* Comments
/**/
comment on table sap_val_rul is 'SAP Validation Rule';
comment on column sap_val_rul.var_rule is 'Validation rule';
comment on column sap_val_rul.var_description is 'Validation rule description';
comment on column sap_val_rul.var_group is 'Validation group identifier';
comment on column sap_val_rul.var_query is 'Validation rule query';
comment on column sap_val_rul.var_test is 'Validation rule test (*FIRST_ROW, *EACH_ROW, *LAST_ROW, *ANY_ROWS, *NO_ROWS)';
comment on column sap_val_rul.var_message is 'Validation rule static message';

/**/
/* Primary Key Constraint
/**/
alter table sap_val_rul
   add constraint sap_val_rul_pk primary key (var_rule);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_val_rul to lads_app;
grant select on sap_val_rul to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_val_rul for lads.sap_val_rul;

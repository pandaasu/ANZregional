/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_val_cla
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Validation Classification

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_val_cla
   (vac_class                                    varchar2(30 char)                   not null,
    vac_description                              varchar2(128 char)                  not null,
    vac_group                                    varchar2(30 char)                   not null,
    vac_lst_query                                clob                                not null,
    vac_one_query                                clob                                not null,
    vac_exe_batch                                varchar2(1 char)                    not null);

/**/
/* Comments
/**/
comment on table sap_val_cla is 'SAP Validation Classification';
comment on column sap_val_cla.vac_class is 'Validation classification identifier';
comment on column sap_val_cla.vac_description is 'Validation classification description';
comment on column sap_val_cla.vac_group is 'Validation group identifier';
comment on column sap_val_cla.vac_lst_query is 'Validation classification list query';
comment on column sap_val_cla.vac_one_query is 'Validation classification one query';
comment on column sap_val_cla.vac_exe_batch is 'Validation classification execute batch';

/**/
/* Primary Key Constraint
/**/
alter table sap_val_cla
   add constraint sap_val_cla_pk primary key (vac_class);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_val_cla to lads_app;
grant select on sap_val_cla to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_val_cla for lads.sap_val_cla;

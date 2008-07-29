/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_val_grp
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Validation Group

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_val_grp
   (vag_group                                    varchar2(30 char)                   not null,
    vag_description                              varchar2(128 char)                  not null,
    vag_cod_length                               number                              not null,
    vag_cod_query                                clob                                not null);

/**/
/* Comments
/**/
comment on table sap_val_grp is 'SAP Validation Group';
comment on column sap_val_grp.vag_group is 'Validation group identifier';
comment on column sap_val_grp.vag_description is 'Validation group description';
comment on column sap_val_grp.vag_cod_length is 'Validation group code length';
comment on column sap_val_grp.vag_cod_query is 'Validation group code query';

/**/
/* Primary Key Constraint
/**/
alter table sap_val_grp
   add constraint sap_val_grp_pk primary key (vag_group);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_val_grp to lads_app;
grant select on sap_val_grp to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_val_grp for lads.sap_val_grp;

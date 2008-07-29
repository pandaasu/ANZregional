/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_val_fil
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Validation Filter

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_val_fil
   (vaf_filter                                   varchar2(30 char)                   not null,
    vaf_description                              varchar2(128 char)                  not null,
    vaf_group                                    varchar2(30 char)                   not null,
    vaf_type                                     varchar2(30 char)                   not null);

/**/
/* Comments
/**/
comment on table sap_val_fil is 'SAP Validation Filter';
comment on column sap_val_fil.vaf_filter is 'Validation filter identifier';
comment on column sap_val_fil.vaf_description is 'Validation filter description';
comment on column sap_val_fil.vaf_group is 'Validation group identifier';
comment on column sap_val_fil.vaf_type is 'Validation type identifier';

/**/
/* Primary Key Constraint
/**/
alter table sap_val_fil
   add constraint sap_val_fil_pk primary key (vaf_filter);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_val_fil to lads_app;
grant select on sap_val_fil to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_val_fil for lads.sap_val_fil;

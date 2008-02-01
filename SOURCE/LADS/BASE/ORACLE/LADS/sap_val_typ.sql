/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_val_typ_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Validation Type

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_val_typ
   (vat_type                                     varchar2(30 char)                   not null,
    vat_description                              varchar2(128 char)                  not null,
    vat_group                                    varchar2(30 char)                   not null);

/**/
/* Comments
/**/
comment on table sap_val_typ is 'SAP Validation Type';
comment on column sap_val_typ.vat_type is 'Validation type identifier';
comment on column sap_val_typ.vat_description is 'Validation type description';
comment on column sap_val_typ.vat_group is 'Validation group identifier';

/**/
/* Primary Key Constraint
/**/
alter table sap_val_typ
   add constraint sap_val_typ_pk primary key (vat_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_val_typ to lads_app;
grant select on sap_val_typ to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_val_typ for lads.sap_val_typ;

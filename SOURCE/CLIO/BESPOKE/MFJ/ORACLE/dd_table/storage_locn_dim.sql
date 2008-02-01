/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : storage_locn_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Storage Location Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.storage_locn_dim
   (sap_storage_locn_code    varchar2(4 char)                 not null,
    storage_locn_desc        varchar2(40 char)                not null);

/**/
/* Comments
/**/
comment on table dd.storage_locn_dim is 'Storage Location Dimension Table';
comment on column dd.storage_locn_dim.sap_storage_locn_code is 'SAP Storage Location Code';
comment on column dd.storage_locn_dim.storage_locn_desc is 'Storage Location Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.storage_locn_dim
   add constraint storage_locn_dim_pk primary key (sap_storage_locn_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.storage_locn_dim to dw_app;
grant select on dd.storage_locn_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym storage_locn_dim for dd.storage_locn_dim;

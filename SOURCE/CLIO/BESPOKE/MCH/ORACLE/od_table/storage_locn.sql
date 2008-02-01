/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : storage_locn
 Owner  : od

 Description
 -----------
 Operational Data Store - Storage Location Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.storage_locn
   (sap_storage_locn_code  varchar2(4 char)            not null,
    storage_locn_desc      varchar2(40 char)           not null,
    storage_locn_lupdp     varchar2(8 char)            not null,
    storage_locn_lupdt     date                        not null);

/**/
/* Comments
/**/
comment on table od.storage_locn is 'Storage Location Table';
comment on column od.storage_locn.sap_storage_locn_code is 'SAP Storage Location Code';
comment on column od.storage_locn.storage_locn_desc is 'Storage Location Description';
comment on column od.storage_locn.storage_locn_lupdp is 'Last Updated Person';
comment on column od.storage_locn.storage_locn_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.storage_locn
   add constraint storage_locn_pk primary key (sap_storage_locn_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.storage_locn to dw_app;
grant select on od.storage_locn to od_app with grant option;
grant select on od.storage_locn to od_user;
grant select on od.storage_locn to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym storage_locn for od.storage_locn;
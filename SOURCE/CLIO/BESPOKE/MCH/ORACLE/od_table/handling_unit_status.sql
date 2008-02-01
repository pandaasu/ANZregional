/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : handling_unit_status
 Owner  : od

 Description
 -----------
 Operational Data Store - Handling Unit Status Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.handling_unit_status
   (sap_handling_unit_sts_code  varchar2(1 char)       not null,
    handling_unit_sts_desc      varchar2(40 char)      not null,
    handling_unit_sts_lupdp     varchar2(8 char)       not null,
    handling_unit_sts_lupdt     date                   not null);

/**/
/* Comments
/**/
comment on table od.handling_unit_status is 'Handling Unit Status Table';
comment on column od.handling_unit_status.sap_handling_unit_sts_code is 'SAP Handling Unit Status Code';
comment on column od.handling_unit_status.handling_unit_sts_desc is 'Handling Unit Status Description';
comment on column od.handling_unit_status.handling_unit_sts_lupdp is 'Last Updated Person';
comment on column od.handling_unit_status.handling_unit_sts_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.handling_unit_status
   add constraint handling_unit_status_pk primary key (sap_handling_unit_sts_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.handling_unit_status to dw_app;
grant select on od.handling_unit_status to od_app with grant option;
grant select on od.handling_unit_status to od_user;
grant select on od.handling_unit_status to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym handling_unit_status for od.handling_unit_status;
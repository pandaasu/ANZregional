/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : invc_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Invoice Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.invc_type
   (sap_invc_type_code  varchar2(4 char)               not null,
    invc_type_desc      varchar2(40 char)              not null,
    invc_type_sign      varchar2(1 char),
    invc_type_lupdp     varchar2(8 char)               not null,
    invc_type_lupdt     date                           not null);

/**/
/* Comments
/**/
comment on table od.invc_type is 'Invoice Type Table';
comment on column od.invc_type.sap_invc_type_code is 'SAP Invoice Type Code';
comment on column od.invc_type.invc_type_desc is 'Invoice Type Description';
comment on column od.invc_type.invc_type_sign is 'Invoice Type Sign - used for Calculated Condition Types';
comment on column od.invc_type.invc_type_lupdp is 'Last Updated Person';
comment on column od.invc_type.invc_type_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.invc_type
   add constraint invc_type_pk primary key (sap_invc_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.invc_type to dw_app;
grant select on od.invc_type to od_app with grant option;
grant select on od.invc_type to od_user;
grant select on od.invc_type to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym invc_type for od.invc_type;

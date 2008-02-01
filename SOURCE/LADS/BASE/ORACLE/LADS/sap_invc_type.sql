/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sap_invc_type
 Owner  : lads

 Description
 -----------
 Local Atlas Data Store - Invoice Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/05   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads.sap_invc_type
   (sap_invc_type_code  varchar2(4 char)               not null,
    invc_type_desc      varchar2(40 char)              not null,
    invc_type_sign      varchar2(1 char)               null);

/**/
/* Comments
/**/
comment on table lads.sap_invc_type is 'Invoice Type Table';
comment on column lads.sap_invc_type.sap_invc_type_code is 'SAP Invoice Type Code';
comment on column lads.sap_invc_type.invc_type_desc is 'Invoice Type Description';
comment on column lads.sap_invc_type.invc_type_sign is 'Invoice Type Sign - used for Calculated Condition Types';

/**/
/* Primary Key Constraint
/**/
alter table lads.sap_invc_type
   add constraint sap_invc_type_pk primary key (sap_invc_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads.sap_invc_type to lads_app;
grant select on lads.sap_invc_type to ics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_invc_type for lads.sap_invc_type;

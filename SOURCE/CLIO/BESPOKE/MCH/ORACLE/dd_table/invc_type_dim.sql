/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : invc_type_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Invoice Type Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.invc_type_dim
   (sap_invc_type_code       varchar2(4 char)                 not null,
    invc_type_desc           varchar2(40 char)                not null,
    invc_type_sign           varchar2(1 char)                 null);

/**/
/* Comments
/**/
comment on table dd.invc_type_dim is 'Invoice Type Dimension Table';
comment on column dd.invc_type_dim.sap_invc_type_code is 'SAP Invoice Type Code';
comment on column dd.invc_type_dim.invc_type_desc is 'Invoice Type Description';
comment on column dd.invc_type_dim.invc_type_sign is 'Invoice Type Sign - used for Calculated Condition Types';

/**/
/* Primary Key Constraint
/**/
alter table dd.invc_type_dim
   add constraint invc_type_dim_pk primary key (sap_invc_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.invc_type_dim to dw_app;
grant select on dd.invc_type_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym invc_type_dim for dd.invc_type_dim;

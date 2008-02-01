/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : calcd_condition_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Calculated Condition Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.calcd_condition_type
   (sap_calcd_cndtn_type_code  varchar2(4 char)   not null,
    calcd_cndtn_type_desc      varchar2(80 char)  not null,
    calcd_cndtn_type_lupdp     varchar2(8 char)   not null,
    calcd_cndtn_type_lupdt     date               not null);

/**/
/* Comments
/**/
comment on table od.calcd_condition_type is 'Billing Type Table';
comment on column od.calcd_condition_type.sap_calcd_cndtn_type_code is 'SAP Calculated Condition Type Code';
comment on column od.calcd_condition_type.calcd_cndtn_type_desc is 'Calculated Condition Type Description';
comment on column od.calcd_condition_type.calcd_cndtn_type_lupdp is 'Last Updated Person';
comment on column od.calcd_condition_type.calcd_cndtn_type_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.calcd_condition_type
   add constraint calcd_condition_type_pk primary key (sap_calcd_cndtn_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.calcd_condition_type to dw_app;
grant select on od.calcd_condition_type to od_app with grant option;
grant select on od.calcd_condition_type to od_user;
grant select on od.calcd_condition_type to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym calcd_condition_type for od.calcd_condition_type;


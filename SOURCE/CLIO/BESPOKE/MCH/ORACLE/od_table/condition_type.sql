/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : condition_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Condition Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.condition_type
   (sap_cndtn_type_code  varchar2(4 char)         not null,
    cndtn_type_desc      varchar2(80 char)        not null,
    cndtn_type_lupdp     varchar2(8 char)         not null,
    cndtn_type_lupdt     date                     not null);

/**/
/* Comments
/**/
comment on table od.condition_type is 'Condition Type Table';
comment on column od.condition_type.sap_cndtn_type_code is 'SAP Condition Type Code';
comment on column od.condition_type.cndtn_type_desc is 'Condition Type Description';
comment on column od.condition_type.cndtn_type_lupdp is 'Last Updated Person';
comment on column od.condition_type.cndtn_type_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.condition_type
   add constraint condition_type_pk primary key (sap_cndtn_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.condition_type to dw_app;
grant select on od.condition_type to od_app with grant option;
grant select on od.condition_type to od_user;
grant select on od.condition_type to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym condition_type for od.condition_type;

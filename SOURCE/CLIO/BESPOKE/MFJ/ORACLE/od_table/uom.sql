/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : uom
 Owner  : od

 Description
 -----------
 Operational Data Store - Unit Of Measure Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.uom
   (sap_uom_code    varchar2(3 char)                   not null,
    uom_abbrd_desc  varchar2(15 char)                  not null,
    uom_desc        varchar2(40 char)                  not null,
    uom_dim         varchar2(40 char)                  not null,
    uom_lupdp       varchar2(8 char)                   not null,
    uom_lupdt       date                               not null);

/**/
/* Comments
/**/
comment on table od.uom is 'Unit Of Measure Table';
comment on column od.uom.sap_uom_code is 'SAP Unit of Measure Code';
comment on column od.uom.uom_abbrd_desc is 'Unit of Measure Abbreviated Description';
comment on column od.uom.uom_desc is 'Unit of Measure Description';
comment on column od.uom.uom_dim is 'Unit of Measure Dimension';
comment on column od.uom.uom_lupdp is 'Last Updated Person';
comment on column od.uom.uom_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.uom
   add constraint uom_pk primary key (sap_uom_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.uom to dw_app with grant option;
grant select on od.uom to od_app with grant option;
grant select on od.uom to od_user;
grant select on od.uom to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym uom for od.uom;
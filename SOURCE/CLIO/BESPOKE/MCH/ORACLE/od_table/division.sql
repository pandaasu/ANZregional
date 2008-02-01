/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : division
 Owner  : od

 Description
 -----------
 Operational Data Store - Division Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.division
   (sap_division_code  varchar2(2 char)                not null,
    division_desc      varchar2(60 char)               not null,
    division_lupdp     varchar2(8 char)                not null,
    division_lupdt     date                            not null);

/**/
/* Comments
/**/
comment on table od.division is 'Division Table';
comment on column od.division.sap_division_code is 'SAP Division Code';
comment on column od.division.division_desc is 'Division Description';
comment on column od.division.division_lupdp is 'Last Updated Person';
comment on column od.division.division_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.division
   add constraint division_pk primary key (sap_division_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.division to dw_app;
grant select on od.division to od_app with grant option;
grant select on od.division to od_user;
grant select on od.division to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym division for od.division;
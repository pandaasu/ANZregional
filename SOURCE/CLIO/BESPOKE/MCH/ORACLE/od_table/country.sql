/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : country
 Owner  : od

 Description
 -----------
 Operational Data Store - Country Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.country
   (sap_cntry_code  varchar2(3 char)              not null,
    cntry_desc      varchar2(60 char)             not null,
    cntry_lupdp     varchar2(8 char)              not null,
    cntry_lupdt     date                          not null);

/**/
/* Comments
/**/
comment on table od.country is 'Country Table';
comment on column od.country.sap_cntry_code is 'SAP Country Code';
comment on column od.country.cntry_desc is 'Country Description';
comment on column od.country.cntry_lupdp is 'Last Updated Person';
comment on column od.country.cntry_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.country
   add constraint country_pk primary key (sap_cntry_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.country to dw_app;
grant select on od.country to od_app with grant option;
grant select on od.country to od_user;
grant select on od.country to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym country for od.country;
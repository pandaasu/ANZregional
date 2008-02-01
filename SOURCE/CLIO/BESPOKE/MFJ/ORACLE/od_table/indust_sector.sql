/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : indust_sector
 Owner  : od

 Description
 -----------
 Operational Data Store - Industry Sector Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.indust_sector
   (sap_indust_sector_code  varchar2(1 char)           not null,
    indust_sector_desc      varchar2(40 char)          not null,
    indust_sector_lupdp     varchar2(8 char)           not null,
    indust_sector_lupdt     date                       not null);

/**/
/* Comments
/**/
comment on table od.indust_sector is 'Industry Sector Table';
comment on column od.indust_sector.sap_indust_sector_code is 'SAP Industry Sector Code';
comment on column od.indust_sector.indust_sector_desc is 'Industry Sector Description';
comment on column od.indust_sector.indust_sector_lupdp is 'Last Updated Person';
comment on column od.indust_sector.indust_sector_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.indust_sector
   add constraint indust_sector_pk primary key (sap_indust_sector_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.indust_sector to dw_app;
grant select on od.indust_sector to od_app with grant option;
grant select on od.indust_sector to od_user;
grant select on od.indust_sector to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym indust_sector for od.indust_sector;
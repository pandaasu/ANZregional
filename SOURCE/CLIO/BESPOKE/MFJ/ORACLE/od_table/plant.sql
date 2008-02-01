/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : plant
 Owner  : od

 Description
 -----------
 Operational Data Store - Plant Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.plant
   (sap_plant_code  varchar2(4 char)                   not null,
    plant_desc      varchar2(40 char)                  not null,
    plant_lupdp     varchar2(8 char)                   not null,
    plant_lupdt     date                               not null);

/**/
/* Comments
/**/
comment on table od.plant is 'Plant Table';
comment on column od.plant.sap_plant_code is 'SAP Plant Code';
comment on column od.plant.plant_desc is 'Plant Description';
comment on column od.plant.plant_lupdp is 'Last Updated Person';
comment on column od.plant.plant_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.plant
   add constraint plant_pk primary key (sap_plant_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.plant to dw_app;
grant select on od.plant to od_app with grant option;
grant select on od.plant to od_user;
grant select on od.plant to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym plant for od.plant;
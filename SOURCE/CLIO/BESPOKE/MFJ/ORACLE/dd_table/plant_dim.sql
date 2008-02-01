/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : plant_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Plant Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.plant_dim
   (sap_plant_code           varchar2(4 char)                 not null,
    plant_desc               varchar2(40 char)                not null);

/**/
/* Comments
/**/
comment on table dd.plant_dim is 'Plant Dimension Table';
comment on column dd.plant_dim.sap_plant_code is 'SAP Plant Code';
comment on column dd.plant_dim.plant_desc is 'Plant Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.plant_dim
   add constraint plant_dim_pk primary key (sap_plant_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.plant_dim to dw_app;
grant select on dd.plant_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym plant_dim for dd.plant_dim;

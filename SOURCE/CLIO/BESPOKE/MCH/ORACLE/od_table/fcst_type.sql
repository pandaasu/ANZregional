/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_type
   (fcst_type_code        number(8)                    not null,
    fcst_type_abbrd_desc  varchar2(10 char)            not null,
    fcst_type_desc        varchar2(40 char)            not null,
    fcst_type_lupdp       varchar2(8 char)             not null,
    fcst_type_lupdt       date                         not null);

/**/
/* Comments
/**/
comment on table od.fcst_type is 'Forecast Type Table';
comment on column od.fcst_type.fcst_type_code is 'Internal Data Warehouse surrogate key';
comment on column od.fcst_type.fcst_type_abbrd_desc is 'Forecast Type Abbreviated Description';
comment on column od.fcst_type.fcst_type_desc is 'Forecast Type Description';
comment on column od.fcst_type.fcst_type_lupdp is 'Last Updated Person';
comment on column od.fcst_type.fcst_type_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_type
   add constraint fcst_type_pk primary key (fcst_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_type to dw_app;
grant select on od.fcst_type to od_app with grant option;
grant select on od.fcst_type to od_user;
grant select on od.fcst_type to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym fcst_type for od.fcst_type;
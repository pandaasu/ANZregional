/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : fpps_values
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - fpps_values 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2011/05   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table fpps_values
(
  fvl_mars_yyyypp                       varchar2(6 char) not null,
  fvl_bus_segment                       varchar2(2 char) not null,
  fvl_value_type                        varchar2(15 char) not null,
  fvl_line_item                         number not null,
  fvl_source                            number not null,
  fvl_customer                          number not null,
  fvl_material                          varchar2(16 char) not null,
  fvl_unit                              number not null,
  fvl_destination                       number not null,
  fvl_value                             number null                              
);

/**/
/* Comments 
/**/
comment on table fpps_values is 'FPPS - Values (Actuals and Forecast) for Line Items';
comment on column fpps_values.fvl_mars_yyyypp is 'FPPS Values - mars YYYYPP';
comment on column fpps_values.fvl_bus_segment is 'FPPS Values - business segment';
comment on column fpps_values.fvl_value_type is 'FPPS Values - value type (actual or forecast)';
comment on column fpps_values.fvl_line_item is 'FPPS Values - line item';
comment on column fpps_values.fvl_source is 'FPPS Values - source';
comment on column fpps_values.fvl_customer is 'FPPS Values - customer';
comment on column fpps_values.fvl_material is 'FPPS Values - material';
comment on column fpps_values.fvl_unit is 'FPPS Values - unit';
comment on column fpps_values.fvl_destination is 'FPPS Values - destination';
comment on column fpps_values.fvl_value is 'FPPS Values - value';

--/**/
--/* Primary Key Constraint 
--/**/
--alter table fpps_values
--   add constraint fpps_values_pk primary key (fvl_mars_yyyypp, fvl_line_item, fvl_source, fvl_customer, fvl_material, fvl_unit, fvl_destination);

/**/
/* Indexes 
/**/
create index qv.fpps_values_idx01 on qv.fpps_values(fvl_mars_yyyypp, fvl_bus_segment);
create index qv.fpps_values_idx02 on qv.fpps_values(fvl_mars_yyyypp, fvl_bus_segment, fvl_value_type);

/**/
/* Authority 
/**/
grant select, insert, update, delete on fpps_values to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym fpps_values for qv.fpps_values;

/**/
/* Sequence 
/**/
create sequence fpps_values_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;
   
/**/
/* Authority
/**/
grant select on fpps_values_seq to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym fpps_values_seq for qv.fpps_values_seq;
/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_extract_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Extract Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_extract_type
   (extract_type                    varchar2(32 char)      not null,
    extract_type_description        varchar2(128 char)     not null,
    extract_type_version            varchar2(32 char)      not null,
    extract_plan_group              varchar2(32 char)      not null,
    extract_format                  varchar2(32 char)      not null,
    extract_planner                 varchar2(32 char)      not null,
    extract_procedure               varchar2(128 char)     not null);

/**/
/* Comments
/**/
comment on table od.fcst_extract_type is 'Forecast Extract Type Table';
comment on column od.fcst_extract_type.extract_type  is 'Extract type';
comment on column od.fcst_extract_type.extract_type_description is 'Extract type description';
comment on column od.fcst_extract_type.extract_type_version is 'Extract type version - *PERIOD or *YEAR';
comment on column od.fcst_extract_type.extract_plan_group  is 'Extract plan group - *SNACK, *PET or *ALL';
comment on column od.fcst_extract_type.extract_format  is 'Extract format - *FILE or *INTERFACE';
comment on column od.fcst_extract_type.extract_planner  is 'Extract planner - CNPLAN_SNK, CNPLAN_PET or *NONE';
comment on column od.fcst_extract_type.extract_procedure is 'Extract procedure';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_extract_type
   add constraint fcst_extract_type_pk primary key (extract_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_extract_type to od_app;
grant select, insert, update, delete on od.fcst_extract_type to dw_app;
grant select on od.fcst_extract_type to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_extract_type for od.fcst_extract_type;
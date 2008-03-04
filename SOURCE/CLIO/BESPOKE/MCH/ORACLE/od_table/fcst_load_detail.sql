/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_load_detail
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Load Detail Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_load_detail
   (load_identifier                 varchar2(64 char)      not null,
    load_sequence                   number                 not null,
    material_code                   varchar2(18 char)      not null,
    dmnd_group                      varchar2(10 char)      not null,
    plant_code                      varchar2(10 char)      not null,
    cover_yyyymmdd                  varchar2(8 char)       not null,
    cover_day                       number                 not null,
    cover_qty                       number                 not null,
    fcst_yyyyppw                    number(7,0)            not null,
    fcst_yyyypp                     number(6,0)            not null,
    fcst_qty                        number                 not null,
    fcst_prc                        number                 not null,
    fcst_gsv                        number                 not null,
    plan_group                      varchar2(32)           not null,
    mesg_text                       varchar2(4000 char)    null);

/**/
/* Comments
/**/
comment on table od.fcst_load_detail is 'Forecast Load Detail Table';
comment on column od.fcst_load_detail.load_identifier is 'Load identifier';
comment on column od.fcst_load_detail.load_sequence is 'Load sequence';
comment on column od.fcst_load_detail.material_code is 'Material code';
comment on column od.fcst_load_detail.dmnd_group is 'Demand group';
comment on column od.fcst_load_detail.plant_code is 'Plant code';
comment on column od.fcst_load_detail.cover_yyyymmdd is 'Forecast cover date';
comment on column od.fcst_load_detail.cover_day is 'Forecast cover days';
comment on column od.fcst_load_detail.cover_qty is 'Forecast cover quantity';
comment on column od.fcst_load_detail.fcst_yyyyppw is 'Forecast period week';
comment on column od.fcst_load_detail.fcst_yyyypp is 'Forecast period';
comment on column od.fcst_load_detail.fcst_qty is 'Forecast quantity';
comment on column od.fcst_load_detail.fcst_prc is 'Forecast price';
comment on column od.fcst_load_detail.fcst_gsv is 'Forecast gross sales value';
comment on column od.fcst_load_detail.plan_group is 'Planning group';
comment on column od.fcst_load_detail.mesg_text is 'Message text';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_load_detail
   add constraint fcst_load_detail_pk primary key (load_identifier, load_sequence);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_load_detail to od_app;
grant select, insert, update, delete on od.fcst_load_detail to dw_app;
grant select on od.fcst_load_detail to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_load_detail for od.fcst_load_detail;



/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_recipe_resource
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Control Recipe Resource

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_recipe_resource
   (recipe_resource_id                 number                   not null,
    proc_order                         varchar2(18)             not null,
    operation                          varchar2(4)              null,
    resource_code                      varchar2(9)              not null,
    batch_qty                          number                   null,
    batch_uom                          varchar2(4)              null,
    phantom                            varchar2(8)              null,
    phantom_desc                       varchar2(40)             null,
    phantom_qty                        varchar2(20)             null,
    phantom_uom                        varchar2(10)             null,
    plant                              varchar2(4)              null);

/*-*/
/* Comments
/*-*/
comment on table bds_recipe_resource is 'Business Data Store - Control Recipe Resource';
comment on column bds_recipe_resource.recipe_resource_id is '*no comment* - cntl_rec_resource.cntl_rec_resource_id';
comment on column bds_recipe_resource.proc_order is '*no comment* - cntl_rec_resource.proc_order';
comment on column bds_recipe_resource.operation is '*no comment* - cntl_rec_resource.operation';
comment on column bds_recipe_resource.resource_code is '*no comment* - cntl_rec_resource.resource_code';
comment on column bds_recipe_resource.batch_qty is '*no comment* - cntl_rec_resource.batch_qty';
comment on column bds_recipe_resource.batch_uom is '*no comment* - cntl_rec_resource.batch_uom';
comment on column bds_recipe_resource.phantom is '*no comment* - cntl_rec_resource.phantom';
comment on column bds_recipe_resource.phantom_desc is '*no comment* - cntl_rec_resource.phantom_desc';
comment on column bds_recipe_resource.phantom_qty is '*no comment* - cntl_rec_resource.phantom_qty';
comment on column bds_recipe_resource.phantom_uom is '*no comment* - cntl_rec_resource.phantom_uom';
comment on column bds_recipe_resource.plant is '*no comment* - cntl_rec_resource.plant';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_recipe_resource
   add constraint bds_recipe_resource_pk primary key (recipe_resource_id);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_recipe_resource to lics_app;
grant select, insert, update, delete on bds_recipe_resource to lads_app;
grant select, insert, update, delete on bds_recipe_resource to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_recipe_resource for bds.bds_recipe_resource;
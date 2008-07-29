/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_recipe_bom
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Control Recipe BOM

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_recipe_bom
   (recipe_bom_id                       number                  not null,
    proc_order                         varchar2(18)             not null,
    operation                          varchar2(4)              null,
    phase                              varchar2(4)              null,
    seq                                varchar2(4)              null,
    material_code                      varchar2(18)             null,
    material_desc                      varchar2(40)             null,
    material_qty                       number                   null,
    material_uom                       varchar2(4)              null,
    material_prnt                      varchar2(18)             null,
    bf_item                            varchar2(1)              null,
    reservation                        varchar2(40)             null,
    plant                              varchar2(4)              null,
    pan_size                           number                   null,
    last_pan_size                      number                   null,
    pan_size_flag                      varchar2(1)              null,
    pan_qty                            number                   null,
    phantom                            varchar2(1)              null,
    operation_from                     varchar2(4)              null);

/*-*/
/* Comments
/*-*/
comment on table bds_recipe_bom is 'Business Data Store - Control Recipe BOM';
comment on column bds_recipe_bom.recipe_bom_id is '*no comment* - cntl_rec_bom.cntl_rec_bom_id';
comment on column bds_recipe_bom.proc_order is '*no comment* - cntl_rec_bom.proc_order';
comment on column bds_recipe_bom.operation is '*no comment* - cntl_rec_bom.operation';
comment on column bds_recipe_bom.phase is '*no comment* - cntl_rec_bom.phase';
comment on column bds_recipe_bom.seq is '*no comment* - cntl_rec_bom.seq';
comment on column bds_recipe_bom.material_code is '*no comment* - cntl_rec_bom.material_code';
comment on column bds_recipe_bom.material_desc is '*no comment* - cntl_rec_bom.material_desc';
comment on column bds_recipe_bom.material_qty is '*no comment* - cntl_rec_bom.material_qty';
comment on column bds_recipe_bom.material_uom is '*no comment* - cntl_rec_bom.material_uom';
comment on column bds_recipe_bom.material_prnt is '*no comment* - cntl_rec_bom.material_prnt';
comment on column bds_recipe_bom.bf_item is '*no comment* - cntl_rec_bom.bf_item';
comment on column bds_recipe_bom.reservation is '*no comment* - cntl_rec_bom.reservation';
comment on column bds_recipe_bom.plant is '*no comment* - cntl_rec_bom.plant';
comment on column bds_recipe_bom.pan_size is '*no comment* - cntl_rec_bom.pan_size';
comment on column bds_recipe_bom.last_pan_size is '*no comment* - cntl_rec_bom.last_pan_size';
comment on column bds_recipe_bom.pan_size_flag is '*no comment* - cntl_rec_bom.pan_size_flag';
comment on column bds_recipe_bom.pan_qty is '*no comment* - cntl_rec_bom.pan_qty';
comment on column bds_recipe_bom.phantom is '*no comment* - cntl_rec_bom.phantom';
comment on column bds_recipe_bom.operation_from is '*no comment* - cntl_rec_bom.operation_from';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_recipe_bom
   add constraint bds_recipe_bom_pk primary key (recipe_bom_id);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_recipe_bom to lics_app;
grant select, insert, update, delete on bds_recipe_bom to lads_app;
grant select, insert, update, delete on bds_recipe_bom to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_recipe_bom for bds.bds_recipe_bom;
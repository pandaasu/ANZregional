/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_recipe_src_value
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Control Recipe SRC Value

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_recipe_src_value
   (recipe_src_value_id                number                   not null,
    proc_order                         varchar2(18)             not null,
    operation                          varchar2(4)              null,
    phase                              varchar2(4)              null,
    seq                                varchar2(4)              null,
    src_tag                            varchar2(40)             null,
    src_desc                           varchar2(2000)           null,
    src_val                            varchar2(30)             null,
    src_uom                            varchar2(20)             null,
    machine_code                       varchar2(4)              null,
    detail_desc                        varchar2(4000)           null,
    plant                              varchar2(4)              null);

/*-*/
/* Comments
/*-*/
comment on table bds_recipe_src_value is 'Business Data Store - Control Recipe MPI Value';
comment on column bds_recipe_src_value.recipe_src_value_id is '*no comment* - cntl_rec_mpi_val.cntl_rec_mpi_val_id';
comment on column bds_recipe_src_value.proc_order is '*no comment* - cntl_rec_mpi_val.proc_order';
comment on column bds_recipe_src_value.operation is '*no comment* - cntl_rec_mpi_val.operation';
comment on column bds_recipe_src_value.phase is '*no comment* - cntl_rec_mpi_val.phase';
comment on column bds_recipe_src_value.seq is '*no comment* - cntl_rec_mpi_val.seq';
comment on column bds_recipe_src_value.src_tag is '*no comment* - cntl_rec_mpi_val.mpi_tag';
comment on column bds_recipe_src_value.src_desc is '*no comment* - cntl_rec_mpi_val.mpi_desc';
comment on column bds_recipe_src_value.src_val is '*no comment* - cntl_rec_mpi_val.mpi_val';
comment on column bds_recipe_src_value.src_uom is '*no comment* - cntl_rec_mpi_val.mpi_uom';
comment on column bds_recipe_src_value.machine_code is '*no comment* - cntl_rec_mpi_val.machine_code';
comment on column bds_recipe_src_value.detail_desc is '*no comment* - cntl_rec_mpi_val.detail_desc';
comment on column bds_recipe_src_value.plant is '*no comment* - cntl_rec_mpi_val.plant';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_recipe_src_value
   add constraint bds_recipe_src_value_pk primary key (recipe_src_value_id);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_recipe_src_value to lics_app;
grant select, insert, update, delete on bds_recipe_src_value to lads_app;
grant select, insert, update, delete on bds_recipe_src_value to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_recipe_src_value for bds.bds_recipe_src_value;
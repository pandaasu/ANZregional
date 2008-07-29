/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_recipe_header
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Control Recipe Header

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created
 2007/07   Steve Gregan   Included material to the primary key

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_recipe_header
   (proc_order                         varchar2(12)             not null,
    cntl_rec_id                        number(18,0)             not null,
    plant                              varchar2(4)              not null,
    cntl_rec_status                    varchar2(5)              null,
    test_flag                          varchar2(1)              null,
    recipe_text                        varchar2(40)             null,
    material                           varchar2(18)             not null,
    material_text                      varchar2(40)             null,
    quantity                           number                   null,
    insplot                            varchar2(12)             null,
    uom                                varchar2(4)              null,
    batch                              varchar2(10)             null,
    sched_start_datime                 date                     null,
    run_start_datime                   date                     not null,
    run_end_datime                     date                     not null,
    version                            number                   null,
    upd_datime                         date                     null,
    cntl_rec_xfer                      varchar2(1)              not null,
    teco_status                        varchar2(4)              null,
    storage_locn                       varchar2(4)              null,
    idoc_timestamp                     varchar2(16)             not null);

/*-*/
/* Comments
/*-*/
comment on table bds_recipe_header is 'Business Data Store - Control Recipe Header';
comment on column bds_recipe_header.proc_order is '*no comment* - cntl_rec.proc_order';
comment on column bds_recipe_header.cntl_rec_id is '*no comment* - cntl_rec.cntl_rec_id';
comment on column bds_recipe_header.plant is '*no comment* - cntl_rec.plant';
comment on column bds_recipe_header.cntl_rec_status is '*no comment* - cntl_rec.cntl_rec_status';
comment on column bds_recipe_header.test_flag is '*no comment* - cntl_rec.test_flag';
comment on column bds_recipe_header.recipe_text is '*no comment* - cntl_rec.recipe_text';
comment on column bds_recipe_header.material is '*no comment* - cntl_rec.material';
comment on column bds_recipe_header.material_text is '*no comment* - cntl_rec.material_text';
comment on column bds_recipe_header.quantity is '*no comment* - cntl_rec.quantity';
comment on column bds_recipe_header.insplot is '*no comment* - cntl_rec.insplot';
comment on column bds_recipe_header.uom is '*no comment* - cntl_rec.uom';
comment on column bds_recipe_header.batch is '*no comment* - cntl_rec.batch';
comment on column bds_recipe_header.sched_start_datime is '*no comment* - cntl_rec.sched_start_datime';
comment on column bds_recipe_header.run_start_datime is '*no comment* - cntl_rec.run_start_datime';
comment on column bds_recipe_header.run_end_datime is '*no comment* - cntl_rec.run_end_datime';
comment on column bds_recipe_header.version is '*no comment* - cntl_rec.version';
comment on column bds_recipe_header.upd_datime is '*no comment* - cntl_rec.upd_datime';
comment on column bds_recipe_header.cntl_rec_xfer is '*no comment* - cntl_rec.cntl_rec_xfer';
comment on column bds_recipe_header.teco_status is '*no comment* - cntl_rec.teco_status';
comment on column bds_recipe_header.storage_locn is '*no comment* - cntl_rec.storage_locn';
comment on column bds_recipe_header.idoc_timestamp is '*no comment* - cntl_rec.idoc_timestamp';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_recipe_header
   add constraint bds_recipe_header_pk primary key (proc_order, material);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_recipe_header to lics_app;
grant select, insert, update, delete on bds_recipe_header to lads_app;
grant select, insert, update, delete on bds_recipe_header to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_recipe_header for bds.bds_recipe_header;
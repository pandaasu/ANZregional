/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_recipe_src_text
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Control Recipe SRC Text

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created
 2011/09   Ben Halicki    Converted several field datatypes to CHAR to handle unicode

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_recipe_src_text
   (recipe_src_text_id                 number                   not null,
    proc_order                         varchar2(18)             not null,
    operation                          varchar2(4)              null,
    phase                              varchar2(4)              null,
    seq                                varchar2(4)              null,
    src_text                           varchar2(4000 char)      null,
    src_type                           varchar2(1 char)         null,
    machine_code                       varchar2(4 char)         null,
    detail_desc                        varchar2(4000 char)      null,
    plant                              varchar2(4)              null);

/*-*/
/* Comments
/*-*/
comment on table bds_recipe_src_text is 'Business Data Store - Control Recipe Source Text';
comment on column bds_recipe_src_text.recipe_src_text_id is '*no comment* - cntl_rec_mpi_txt.cntl_rec_mpi_txt_id';
comment on column bds_recipe_src_text.proc_order is '*no comment* - cntl_rec_mpi_txt.proc_order';
comment on column bds_recipe_src_text.operation is '*no comment* - cntl_rec_mpi_txt.operation';
comment on column bds_recipe_src_text.phase is '*no comment* - cntl_rec_mpi_txt.phase';
comment on column bds_recipe_src_text.seq is '*no comment* - cntl_rec_mpi_txt.seq';
comment on column bds_recipe_src_text.src_text is '*no comment* - cntl_rec_mpi_txt.mpi_text';
comment on column bds_recipe_src_text.src_type is '*no comment* - cntl_rec_mpi_txt.mpi_type';
comment on column bds_recipe_src_text.machine_code is '*no comment* - cntl_rec_mpi_txt.machine_code';
comment on column bds_recipe_src_text.detail_desc is '*no comment* - cntl_rec_mpi_txt.detail_desc';
comment on column bds_recipe_src_text.plant is '*no comment* - cntl_rec_mpi_txt.plant';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_recipe_src_text
   add constraint bds_recipe_src_text_pk primary key (recipe_src_text_id);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_recipe_src_text to lics_app;
grant select, insert, update, delete on bds_recipe_src_text to lads_app;
grant select, insert, update, delete on bds_recipe_src_text to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_recipe_src_text for bds.bds_recipe_src_text;
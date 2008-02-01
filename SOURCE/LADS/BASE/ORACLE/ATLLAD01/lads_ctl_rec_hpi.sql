/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ctl_rec_hpi
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ctl_rec_hpi

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ctl_rec_hpi
   (cntl_rec_id                                  number(18,0)                        not null,
    plant                                        varchar2(4 char)                    null,
    proc_order                                   varchar2(12 char)                   null,
    dest                                         varchar2(2 char)                    null,
    dest_address                                 varchar2(32 char)                   null,
    dest_type                                    varchar2(1 char)                    null,
    cntl_rec_status                              varchar2(5 char)                    null,
    test_flag                                    varchar2(1 char)                    null,
    recipe_text                                  varchar2(40 char)                   null,
    material                                     varchar2(18 char)                   null,
    material_text                                varchar2(40 char)                   null,
    insplot                                      number(12,0)                        null,
    material_external                            varchar2(40 char)                   null,
    material_guid                                varchar2(32 char)                   null,
    material_version                             varchar2(10 char)                   null,
    batch                                        varchar2(10 char)                   null,
    scheduled_start_date                         varchar2(8 char)                    null,
    scheduled_start_time                         varchar2(6 char)                    null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_ctl_rec_hpi is 'LADS Control Recipe Process Instruction Header';
comment on column lads_ctl_rec_hpi.cntl_rec_id is 'Control recipe number';
comment on column lads_ctl_rec_hpi.plant is 'Plant';
comment on column lads_ctl_rec_hpi.proc_order is 'Process order number';
comment on column lads_ctl_rec_hpi.dest is 'Control recipe destination';
comment on column lads_ctl_rec_hpi.dest_address is 'Address of the control recipe destination';
comment on column lads_ctl_rec_hpi.dest_type is 'Type of control recipe destination';
comment on column lads_ctl_rec_hpi.cntl_rec_status is 'Control recipe status';
comment on column lads_ctl_rec_hpi.test_flag is 'Indicator: message or control recipe for test purposes';
comment on column lads_ctl_rec_hpi.recipe_text is 'Short text';
comment on column lads_ctl_rec_hpi.material is 'Material Number for Order';
comment on column lads_ctl_rec_hpi.material_text is 'Material Description';
comment on column lads_ctl_rec_hpi.insplot is 'Inspection Lot Number';
comment on column lads_ctl_rec_hpi.material_external is 'Long material number (future development) for MATERIAL field';
comment on column lads_ctl_rec_hpi.material_guid is 'External GUID (future development) for MATERIAL field';
comment on column lads_ctl_rec_hpi.material_version is 'Version number (future development) for MATERIAL field';
comment on column lads_ctl_rec_hpi.batch is 'Batch number';
comment on column lads_ctl_rec_hpi.scheduled_start_date is 'Earliest Scheduled Start: Execution (Date)';
comment on column lads_ctl_rec_hpi.scheduled_start_time is 'Earliest Scheduled Start: Execution (Time)';
comment on column lads_ctl_rec_hpi.idoc_name is 'IDOC name';
comment on column lads_ctl_rec_hpi.idoc_number is 'IDOC number';
comment on column lads_ctl_rec_hpi.idoc_timestamp is 'IDOC timestamp';
comment on column lads_ctl_rec_hpi.lads_date is 'LADS date loaded';
comment on column lads_ctl_rec_hpi.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';

/**/
/* Primary Key Constraint
/**/
alter table lads_ctl_rec_hpi
   add constraint lads_ctl_rec_hpi_pk primary key (cntl_rec_id);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ctl_rec_hpi to lads_app;
grant select, insert, update, delete on lads_ctl_rec_hpi to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ctl_rec_hpi for lads.lads_ctl_rec_hpi;

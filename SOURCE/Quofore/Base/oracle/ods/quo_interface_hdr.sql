/*******************************************************************************
** Table Definition
********************************************************************************

 System : quo
 Table  : quo_interface_hdr
 Owner  : quo
 Author : Mal Chambeyron

 Description
 -------------------------------------------------------------------------------
 Quofore Interface Control : Interface Loader Header 

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2013-02-19   Mal Chambeyron         Created

*******************************************************************************/

-- Table DDL
drop table ods.quo_interface_hdr cascade constraints;

create table ods.quo_interface_hdr (
  q4x_load_seq                    number(15)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_status                      varchar2(16 char)               not null,
  q4x_interface_name              varchar2(32 char)               not null,
  q4x_source_id                   number(4)                       not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_entity_name                 varchar2(32 char)               not null,
  q4x_file_name                   varchar2(512 char)              not null,
  q4x_timestamp                   date                            not null,
  q4x_row_count                   number(10)                      not null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Constraints and Checks
alter table ods.quo_interface_hdr add constraint quo_interface_hdr_pk primary key (q4x_load_seq) 
  using index (create unique index quo_interface_hdr_pk on ods.quo_interface_hdr(q4x_load_seq));

alter table ods.quo_interface_hdr add constraint quo_interface_hdr_uk unique (q4x_source_id,q4x_batch_id,q4x_entity_name) 
  using index (create unique index quo_interface_hdr_uk on ods.quo_interface_hdr(q4x_source_id,q4x_batch_id,q4x_entity_name));

alter table ods.quo_interface_hdr add constraint quo_interface_hdr_status_ck check (q4x_status in ('*STARTED','*LOADED','*PROCESSED','*ERROR'));  

alter table ods.quo_interface_hdr add constraint quo_interface_hdr_interface_ck check (q4x_interface_name = upper(q4x_interface_name));  

alter table ods.quo_interface_hdr add constraint quo_interface_hdr_entity_ck check (q4x_entity_name = upper(q4x_entity_name));  

-- Comments
comment on table ods.quo_interface_hdr is 'Quofore Interface Control : Interface Loader Header';
comment on column ods.quo_interface_hdr.q4x_load_seq is 'Primary Key - Unique Load Id';
comment on column ods.quo_interface_hdr.q4x_create_user is 'Create User - Set on Creation';
comment on column ods.quo_interface_hdr.q4x_create_time is 'Create Date/Time - Set on Creation';
comment on column ods.quo_interface_hdr.q4x_modify_user is 'Modify User - Updated on Each Modification';
comment on column ods.quo_interface_hdr.q4x_modify_time is 'Modify Date/Time - Updated on Each Modification';
comment on column ods.quo_interface_hdr.q4x_status is 'One of .. *STARTED,*LOADED,*PROCESSED,*ERROR';
comment on column ods.quo_interface_hdr.q4x_interface_name is 'Interface Name, Format .. QUOCDW##.{Source Id} - MUST BE UPPERCASE';
comment on column ods.quo_interface_hdr.q4x_source_id is 'Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column ods.quo_interface_hdr.q4x_batch_id is 'Quofore Batch Id';
comment on column ods.quo_interface_hdr.q4x_entity_name is 'Quofore Entity Name .. {Entity} - MUST BE UPPERCASE';
comment on column ods.quo_interface_hdr.q4x_file_name is 'Quofore File Name, Format .. {Interface Name}_{Entity}_{YYYYMMDDHH24MISS}_{Quofore Export File Id}.csv - LICS Limit Currently VARCHAR2(64 CHAR)!!!';
comment on column ods.quo_interface_hdr.q4x_timestamp is 'Quofore File Timestamp {YYYYMMDDHH24MISS}';
comment on column ods.quo_interface_hdr.q4x_row_count is 'Quofore File Row Count';

-- Synonyms
create or replace public synonym quo_interface_hdr for ods.quo_interface_hdr;

-- Grants
grant select,update,delete,insert on ods.quo_interface_hdr to ods_app;
grant select on ods.quo_interface_hdr to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

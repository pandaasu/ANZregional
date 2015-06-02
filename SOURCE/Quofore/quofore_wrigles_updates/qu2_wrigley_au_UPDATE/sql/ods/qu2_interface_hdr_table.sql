
set define off;

  /*****************************************************************************
  ** Table Definition
  ******************************************************************************

    System   : qu2
    Owner    : ods
    Table    : qu2_interface_hdr
    Author   : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
    Interface Loader Header

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2013-07-10  Mal Chambeyron        Increase Entity Name from 32 > 64 char
    2014-05-15  Mal Chambeyron        Cleanup Source Id
    2014-05-15  Mal Chambeyron        Make into a Template
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-05-26  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- Table DDL
drop table ods.qu2_interface_hdr cascade constraints;

create table ods.qu2_interface_hdr (
  q4x_load_seq                    number(15)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_status                      varchar2(16 char)               not null,
  q4x_interface_name              varchar2(32 char)               not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_entity_name                 varchar2(64 char)               not null,
  q4x_file_name                   varchar2(512 char)              not null,
  q4x_timestamp                   date                            not null,
  q4x_row_count                   number(10)                      not null
)
compress;

-- Constraints and Checks
alter table ods.qu2_interface_hdr add constraint qu2_interface_hdr_pk primary key (q4x_load_seq)
  using index (create unique index qu2_interface_hdr_pk on ods.qu2_interface_hdr(q4x_load_seq));

alter table ods.qu2_interface_hdr add constraint qu2_interface_hdr_uk unique (q4x_batch_id,q4x_entity_name)
  using index (create unique index qu2_interface_hdr_uk on ods.qu2_interface_hdr(q4x_batch_id,q4x_entity_name));

alter table ods.qu2_interface_hdr add constraint qu2_interface_hdr_status_ck check (q4x_status in ('*STARTED','*LOADED','*PROCESSED','*ERROR'));

alter table ods.qu2_interface_hdr add constraint qu2_interface_hdr_interface_ck check (q4x_interface_name = upper(q4x_interface_name));

alter table ods.qu2_interface_hdr add constraint qu2_interface_hdr_entity_ck check (q4x_entity_name = upper(q4x_entity_name));

-- Comments
comment on table ods.qu2_interface_hdr is 'Quofore Interface Control : Interface Loader Header';
comment on column ods.qu2_interface_hdr.q4x_load_seq is 'Primary Key - Unique Load Id';
comment on column ods.qu2_interface_hdr.q4x_create_user is 'Create User - Set on Creation';
comment on column ods.qu2_interface_hdr.q4x_create_time is 'Create Date/Time - Set on Creation';
comment on column ods.qu2_interface_hdr.q4x_modify_user is 'Modify User - Updated on Each Modification';
comment on column ods.qu2_interface_hdr.q4x_modify_time is 'Modify Date/Time - Updated on Each Modification';
comment on column ods.qu2_interface_hdr.q4x_status is 'One of .. *STARTED,*LOADED,*PROCESSED,*ERROR';
comment on column ods.qu2_interface_hdr.q4x_interface_name is 'Interface Name, Format .. QUOCDW##.{Source Id} - MUST BE UPPERCASE';
comment on column ods.qu2_interface_hdr.q4x_batch_id is 'Quofore Batch Id';
comment on column ods.qu2_interface_hdr.q4x_entity_name is 'Quofore Entity Name .. {Entity} - MUST BE UPPERCASE';
comment on column ods.qu2_interface_hdr.q4x_file_name is 'Quofore File Name, Format .. {Interface Name}_{Entity}_{YYYYMMDDHH24MISS}_{Quofore Export File Id}.csv - LICS Limit Currently VARCHAR2(64 CHAR)!!!';
comment on column ods.qu2_interface_hdr.q4x_timestamp is 'Quofore File Timestamp {YYYYMMDDHH24MISS}';
comment on column ods.qu2_interface_hdr.q4x_row_count is 'Quofore File Row Count';

-- Synonyms
create or replace public synonym qu2_interface_hdr for ods.qu2_interface_hdr;

-- Grants
grant select,insert,update,delete on ods.qu2_interface_hdr to ods_app;
grant select on ods.qu2_interface_hdr to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

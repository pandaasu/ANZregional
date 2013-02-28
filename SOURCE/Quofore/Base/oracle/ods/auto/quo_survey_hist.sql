
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_survey_hist
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_survey_hist] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_survey_hist cascade constraints;

create table ods.quo_survey_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_source_id                   number(4)                       not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  id_lookup                       varchar2(50 char)               null,
  is_active                       number(1, 0)                    null,
  created_date                    date                            null,
  survey_type_id                  number(10, 0)                   null,
  survey_type_id_lookup           varchar2(50 char)               null,
  survey_type_id_desc             varchar2(50 char)               null,
  name                            varchar2(50 char)               null,
  note                            varchar2(200 char)              null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_survey_hist add constraint quo_survey_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_survey_hist_pk on ods.quo_survey_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_survey_hist add constraint quo_survey_hist_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_survey_hist_uk on ods.quo_survey_hist (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_survey_hist_ts on ods.quo_survey_hist (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_survey_hist is '[Survey] Main survey master information';
comment on column quo_survey_hist.q4x_load_seq is '* Unique Load Id';
comment on column quo_survey_hist.q4x_load_data_seq is '* Data Record Id';
comment on column quo_survey_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_survey_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_survey_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_survey_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_survey_hist.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_survey_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_survey_hist.q4x_timestamp is '* Timestamp';
comment on column quo_survey_hist.id is '[ID] Unique Internal ID for the row';
comment on column quo_survey_hist.id_lookup is '[ID_Lookup] ';
comment on column quo_survey_hist.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column quo_survey_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column quo_survey_hist.survey_type_id is '[SurveyTypeId] To find the LookupList and LookupListItem for SurveyType list.';
comment on column quo_survey_hist.survey_type_id_lookup is '[SurveyTypeId_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_survey_hist.survey_type_id_desc is '[SurveyTypeId_Description] Default language description of the node';
comment on column quo_survey_hist.name is '[Name] The name of the survey.';
comment on column quo_survey_hist.note is '[Notes] Notes about the survey';


-- Synonyms
create or replace public synonym quo_survey_hist for ods.quo_survey_hist;

-- Grants
grant select,update,delete,insert on ods.quo_survey_hist to ods_app;
grant select on ods.quo_survey_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

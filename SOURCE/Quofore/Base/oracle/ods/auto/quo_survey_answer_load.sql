
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_survey_answer_load
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_survey_answer_load] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_survey_answer_load cascade constraints;

create table ods.quo_survey_answer_load (
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
  survey_response_id              number(10, 0)                   null,
  survey_response_id_lookup       varchar2(50 char)               null,
  survey_id                       number(10, 0)                   null,
  survey_id_lookup                varchar2(50 char)               null,
  survey_question_id              number(10, 0)                   null,
  survey_question_id_lookup       varchar2(50 char)               null,
  response_opt_id                 number(10, 0)                   null,
  response_opt_id_lookup          varchar2(50 char)               null,
  freeform_response               varchar2(4000 char)             null,
  rep_id                          number(10, 0)                   null,
  rep_id_lookup                   varchar2(50 char)               null,
  callcard_id                     number(10, 0)                   null,
  callcard_id_lookup              varchar2(50 char)               null,
  task_id                         number(10, 0)                   null,
  survey_response_created_date    date                            null,
  task_created_date               date                            null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_survey_answer_load add constraint quo_survey_answer_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_survey_answer_load_pk on ods.quo_survey_answer_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_survey_answer_load add constraint quo_survey_answer_load_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_survey_answer_load_uk on ods.quo_survey_answer_load (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_survey_answer_load_ts on ods.quo_survey_answer_load (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_survey_answer_load is '[SurveyAnswer] Actual survey transactional data filled during a callcard.';
comment on column quo_survey_answer_load.q4x_load_seq is '* Unique Load Id';
comment on column quo_survey_answer_load.q4x_load_data_seq is '* Data Record Id';
comment on column quo_survey_answer_load.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_survey_answer_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_survey_answer_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_survey_answer_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_survey_answer_load.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_survey_answer_load.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_survey_answer_load.q4x_timestamp is '* Timestamp';
comment on column quo_survey_answer_load.id is '[ID] Unique Internal ID for the row';
comment on column quo_survey_answer_load.id_lookup is '[ID_Lookup] ';
comment on column quo_survey_answer_load.survey_response_id is '[SurveyResponse_ID] ';
comment on column quo_survey_answer_load.survey_response_id_lookup is '[SurveyResponse_ID_Lookup] ';
comment on column quo_survey_answer_load.survey_id is '[Survey_ID] Mandatory foreign key to [Survey].[Id].';
comment on column quo_survey_answer_load.survey_id_lookup is '[Survey_ID_Lookup] ';
comment on column quo_survey_answer_load.survey_question_id is '[SurveyQuestion_ID] Mandatory foreign key to [SurveyQuestion].[Id].';
comment on column quo_survey_answer_load.survey_question_id_lookup is '[SurveyQuestion_ID_Lookup] ';
comment on column quo_survey_answer_load.response_opt_id is '[ResponseOption_ID] Foreign key to [ResponseOption].[Id].';
comment on column quo_survey_answer_load.response_opt_id_lookup is '[ResponseOption_ID_Lookup] ';
comment on column quo_survey_answer_load.freeform_response is '[FreeFormResponse] Freeform response data for this question. This may be any data type';
comment on column quo_survey_answer_load.rep_id is '[Rep_ID] Mandatory foreign key to [Rep].[Id].';
comment on column quo_survey_answer_load.rep_id_lookup is '[Rep_ID_Lookup] ';
comment on column quo_survey_answer_load.callcard_id is '[Callcard_ID] Foreign key to [CallCard].[Id].';
comment on column quo_survey_answer_load.callcard_id_lookup is '[Callcard_ID_Lookup] ';
comment on column quo_survey_answer_load.task_id is '[Task_ID] not compulsory';
comment on column quo_survey_answer_load.survey_response_created_date is '[SurveyResponseCreatedDate] ';
comment on column quo_survey_answer_load.task_created_date is '[TaskCreatedDate] ';


-- Synonyms
create or replace public synonym quo_survey_answer_load for ods.quo_survey_answer_load;

-- Grants
grant select,update,delete,insert on ods.quo_survey_answer_load to ods_app;
grant select on ods.quo_survey_answer_load to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/


  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu3
    Owner    : ods
    Table    : qu3_survey_answer
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    [qu3_survey_answer] table creation script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup Source Id
    2014-05-15  Mal Chambeyron        Updated to Handle Special Case [digest]
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-05-26  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- _load -----------------------------------------------------------------------

-- Table
drop table ods.qu3_survey_answer_load cascade constraints;

create table ods.qu3_survey_answer_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  survey_response_id              number(10, 0)                   null,
  survey_id                       number(10, 0)                   null,
  survey_question_id              number(10, 0)                   null,
  response_opt_id                 number(10, 0)                   null,
  freeform_response               varchar2(4000 char)             null,
  rep_id                          number(10, 0)                   null,
  callcard_id                     number(10, 0)                   null,
  survey_response_created_date    date                            null,
  task_created_date               date                            null
)
compress;

-- Keys / Indexes
alter table ods.qu3_survey_answer_load add constraint qu3_survey_answer_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_survey_answer_load_pk on ods.qu3_survey_answer_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_survey_answer_load add constraint qu3_survey_answer_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_survey_answer_load_uk on ods.qu3_survey_answer_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu3_survey_answer_load is '[SurveyAnswer][LOAD] Actual survey transactional data filled during a callcard.';
comment on column qu3_survey_answer_load.q4x_load_seq is '* Unique Load Id';
comment on column qu3_survey_answer_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_survey_answer_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_survey_answer_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_survey_answer_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_survey_answer_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_survey_answer_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_survey_answer_load.q4x_timestamp is '* Timestamp';
comment on column qu3_survey_answer_load.id is '[ID] Unique Internal ID for the row';
comment on column qu3_survey_answer_load.survey_response_id is '[SurveyResponse_ID] ';
comment on column qu3_survey_answer_load.survey_id is '[Survey_ID] Mandatory foreign key from [Survey].[Id].';
comment on column qu3_survey_answer_load.survey_question_id is '[SurveyQuestion_ID] Mandatory foreign key from [SurveyQuestion].[Id].';
comment on column qu3_survey_answer_load.response_opt_id is '[ResponseOption_ID] Foreign key from [ResponseOption].[Id].';
comment on column qu3_survey_answer_load.freeform_response is '[FreeFormResponse] Freeform response data for this question. This may be any data type';
comment on column qu3_survey_answer_load.rep_id is '[Rep_ID] Mandatory foreign key from [Rep].[Id].';
comment on column qu3_survey_answer_load.callcard_id is '[Callcard_ID] Foreign key from [CallCard].[Id].';
comment on column qu3_survey_answer_load.survey_response_created_date is '[SurveyResponseCreatedDate] ';
comment on column qu3_survey_answer_load.task_created_date is '[TaskCreatedDate] ';

-- Synonyms
create or replace public synonym qu3_survey_answer_load for ods.qu3_survey_answer_load;

-- Grants
grant select,insert,update,delete on ods.qu3_survey_answer_load to ods_app;
grant select on ods.qu3_survey_answer_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu3_survey_answer_hist cascade constraints;

create table ods.qu3_survey_answer_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  survey_response_id              number(10, 0)                   null,
  survey_id                       number(10, 0)                   null,
  survey_question_id              number(10, 0)                   null,
  response_opt_id                 number(10, 0)                   null,
  freeform_response               varchar2(4000 char)             null,
  rep_id                          number(10, 0)                   null,
  callcard_id                     number(10, 0)                   null,
  survey_response_created_date    date                            null,
  task_created_date               date                            null
)
compress;

-- Keys / Indexes
alter table ods.qu3_survey_answer_hist add constraint qu3_survey_answer_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_survey_answer_hist_pk on ods.qu3_survey_answer_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_survey_answer_hist add constraint qu3_survey_answer_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_survey_answer_hist_uk on ods.qu3_survey_answer_hist (id,q4x_batch_id)) compress;

create index ods.qu3_survey_answer_hist_ts on ods.qu3_survey_answer_hist (q4x_timestamp) compress;

-- Comments
comment on table qu3_survey_answer_hist is '[SurveyAnswer][HIST] Actual survey transactional data filled during a callcard.';
comment on column qu3_survey_answer_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu3_survey_answer_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_survey_answer_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_survey_answer_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_survey_answer_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_survey_answer_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_survey_answer_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_survey_answer_hist.q4x_timestamp is '* Timestamp';
comment on column qu3_survey_answer_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu3_survey_answer_hist.survey_response_id is '[SurveyResponse_ID] ';
comment on column qu3_survey_answer_hist.survey_id is '[Survey_ID] Mandatory foreign key from [Survey].[Id].';
comment on column qu3_survey_answer_hist.survey_question_id is '[SurveyQuestion_ID] Mandatory foreign key from [SurveyQuestion].[Id].';
comment on column qu3_survey_answer_hist.response_opt_id is '[ResponseOption_ID] Foreign key from [ResponseOption].[Id].';
comment on column qu3_survey_answer_hist.freeform_response is '[FreeFormResponse] Freeform response data for this question. This may be any data type';
comment on column qu3_survey_answer_hist.rep_id is '[Rep_ID] Mandatory foreign key from [Rep].[Id].';
comment on column qu3_survey_answer_hist.callcard_id is '[Callcard_ID] Foreign key from [CallCard].[Id].';
comment on column qu3_survey_answer_hist.survey_response_created_date is '[SurveyResponseCreatedDate] ';
comment on column qu3_survey_answer_hist.task_created_date is '[TaskCreatedDate] ';

-- Synonyms
create or replace public synonym qu3_survey_answer_hist for ods.qu3_survey_answer_hist;

-- Grants
grant select,insert,update,delete on ods.qu3_survey_answer_hist to ods_app;
grant select on ods.qu3_survey_answer_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

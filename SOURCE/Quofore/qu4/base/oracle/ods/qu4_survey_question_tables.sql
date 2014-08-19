
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu4
    Owner    : ods
    Table    : qu4_survey_question
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    [qu4_survey_question] table creation script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup source_id
    2014-05-15  Mal Chambeyron        Updated to Handle Special Case [digest]
    2014-06-03  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- _load -----------------------------------------------------------------------

-- Table
drop table ods.qu4_survey_question_load cascade constraints;

create table ods.qu4_survey_question_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  survey_id                       number(10, 0)                   not null,
  question_id                     number(10, 0)                   null,
  question                        varchar2(200 char)              null,
  is_mandatory                    number(1, 0)                    null,
  sort_ord                        varchar2(50 char)               null,
  question_set                    number(3, 0)                    null,
  is_single_choice                number(1, 0)                    null,
  free_form_data_type             varchar2(50 char)               null,
  question_created_date           date                            null
)
compress;

-- Keys / Indexes
alter table ods.qu4_survey_question_load add constraint qu4_survey_question_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_survey_question_load_pk on ods.qu4_survey_question_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_survey_question_load add constraint qu4_survey_question_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_survey_question_load_uk on ods.qu4_survey_question_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu4_survey_question_load is '[SurveyQuestion][LOAD] Various questions attached to a survey.';
comment on column qu4_survey_question_load.q4x_load_seq is '* Unique Load Id';
comment on column qu4_survey_question_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_survey_question_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_survey_question_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_survey_question_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_survey_question_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_survey_question_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_survey_question_load.q4x_timestamp is '* Timestamp';
comment on column qu4_survey_question_load.id is '[ID] Unique Internal ID for the row';
comment on column qu4_survey_question_load.survey_id is '[Survey_ID] Mandatory foreign key from [Survey].[Id].';
comment on column qu4_survey_question_load.question_id is '[Question_ID] ID of the question.';
comment on column qu4_survey_question_load.question is '[Question] The text of the question.';
comment on column qu4_survey_question_load.is_mandatory is '[IsMandatory] Indicates whether the question must be answered to complete the survey. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column qu4_survey_question_load.sort_ord is '[SortOrder] The order in which the questions should be presented in a survey in a hierarchical way.';
comment on column qu4_survey_question_load.question_set is '[QuestionSet] Identifies the question set to which this question belongs. If populated, this question will not be presented unless a response is chosen which enables this question set.';
comment on column qu4_survey_question_load.is_single_choice is '[IsSingleChoice] Indicates whether the response is limited to a single selection. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column qu4_survey_question_load.free_form_data_type is '[FreeformDataType] What type of responses this Question contains e.g. Checkboxes, radio buttons, dropdown list, text etc. A question can have only one type of response.';
comment on column qu4_survey_question_load.question_created_date is '[QuestionCreatedDate] ';

-- Synonyms
create or replace public synonym qu4_survey_question_load for ods.qu4_survey_question_load;

-- Grants
grant select,insert,update,delete on ods.qu4_survey_question_load to ods_app;
grant select on ods.qu4_survey_question_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu4_survey_question_hist cascade constraints;

create table ods.qu4_survey_question_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  survey_id                       number(10, 0)                   not null,
  question_id                     number(10, 0)                   null,
  question                        varchar2(200 char)              null,
  is_mandatory                    number(1, 0)                    null,
  sort_ord                        varchar2(50 char)               null,
  question_set                    number(3, 0)                    null,
  is_single_choice                number(1, 0)                    null,
  free_form_data_type             varchar2(50 char)               null,
  question_created_date           date                            null
)
compress;

-- Keys / Indexes
alter table ods.qu4_survey_question_hist add constraint qu4_survey_question_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_survey_question_hist_pk on ods.qu4_survey_question_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_survey_question_hist add constraint qu4_survey_question_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_survey_question_hist_uk on ods.qu4_survey_question_hist (id,q4x_batch_id)) compress;

create index ods.qu4_survey_question_hist_ts on ods.qu4_survey_question_hist (q4x_timestamp) compress;

-- Comments
comment on table qu4_survey_question_hist is '[SurveyQuestion][HIST] Various questions attached to a survey.';
comment on column qu4_survey_question_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu4_survey_question_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_survey_question_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_survey_question_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_survey_question_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_survey_question_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_survey_question_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_survey_question_hist.q4x_timestamp is '* Timestamp';
comment on column qu4_survey_question_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu4_survey_question_hist.survey_id is '[Survey_ID] Mandatory foreign key from [Survey].[Id].';
comment on column qu4_survey_question_hist.question_id is '[Question_ID] ID of the question.';
comment on column qu4_survey_question_hist.question is '[Question] The text of the question.';
comment on column qu4_survey_question_hist.is_mandatory is '[IsMandatory] Indicates whether the question must be answered to complete the survey. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column qu4_survey_question_hist.sort_ord is '[SortOrder] The order in which the questions should be presented in a survey in a hierarchical way.';
comment on column qu4_survey_question_hist.question_set is '[QuestionSet] Identifies the question set to which this question belongs. If populated, this question will not be presented unless a response is chosen which enables this question set.';
comment on column qu4_survey_question_hist.is_single_choice is '[IsSingleChoice] Indicates whether the response is limited to a single selection. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column qu4_survey_question_hist.free_form_data_type is '[FreeformDataType] What type of responses this Question contains e.g. Checkboxes, radio buttons, dropdown list, text etc. A question can have only one type of response.';
comment on column qu4_survey_question_hist.question_created_date is '[QuestionCreatedDate] ';

-- Synonyms
create or replace public synonym qu4_survey_question_hist for ods.qu4_survey_question_hist;

-- Grants
grant select,insert,update,delete on ods.qu4_survey_question_hist to ods_app;
grant select on ods.qu4_survey_question_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

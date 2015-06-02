
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu2
    Owner    : ods
    Table    : qu2_response_opt
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
    [qu2_response_opt] table creation script _load and _hist

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
drop table ods.qu2_response_opt_load cascade constraints;

create table ods.qu2_response_opt_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  survey_question_id              number(10, 0)                   null,
  sort_ord                        number(3, 0)                    null,
  enable_set                      number(3, 0)                    null,
  response_label                  varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu2_response_opt_load add constraint qu2_response_opt_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_response_opt_load_pk on ods.qu2_response_opt_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_response_opt_load add constraint qu2_response_opt_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_response_opt_load_uk on ods.qu2_response_opt_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu2_response_opt_load is '[ResponseOption][LOAD] If a survey question consists of pre-defined responses (e.g. list box, set of checkboxes etc), this file contains responses available to a particular survey questions. Each response is a separate row in this file. e.g. if a question has 5 checkboxes as possible responses, this file shall have 5 rows for this particular question.<\n>If the survey question is a simple data entry fields (e.g. text, date) then it doesn''t contain any response options.';
comment on column qu2_response_opt_load.q4x_load_seq is '* Unique Load Id';
comment on column qu2_response_opt_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_response_opt_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_response_opt_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_response_opt_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_response_opt_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_response_opt_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_response_opt_load.q4x_timestamp is '* Timestamp';
comment on column qu2_response_opt_load.id is '[ID] Unique Internal ID for the row';
comment on column qu2_response_opt_load.survey_question_id is '[SurveyQuestion_ID] Mandatory foreign key from [SurveyQuestion].[Id].';
comment on column qu2_response_opt_load.sort_ord is '[SortOrder] The order in which the responses should be presented for a question.';
comment on column qu2_response_opt_load.enable_set is '[EnableSet] If this response option is chosen, which question set in survey question should be enabled. This is used with conditional questions where a question is shown only when a particular response is selected in previous question.<\n>Maps to SurveyQuestion.QuestionSet column.';
comment on column qu2_response_opt_load.response_label is '[ResponseLabel] The actual value of the response.';

-- Synonyms
create or replace public synonym qu2_response_opt_load for ods.qu2_response_opt_load;

-- Grants
grant select,insert,update,delete on ods.qu2_response_opt_load to ods_app;
grant select on ods.qu2_response_opt_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu2_response_opt_hist cascade constraints;

create table ods.qu2_response_opt_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  survey_question_id              number(10, 0)                   null,
  sort_ord                        number(3, 0)                    null,
  enable_set                      number(3, 0)                    null,
  response_label                  varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu2_response_opt_hist add constraint qu2_response_opt_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_response_opt_hist_pk on ods.qu2_response_opt_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_response_opt_hist add constraint qu2_response_opt_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_response_opt_hist_uk on ods.qu2_response_opt_hist (id,q4x_batch_id)) compress;

create index ods.qu2_response_opt_hist_ts on ods.qu2_response_opt_hist (q4x_timestamp) compress;

-- Comments
comment on table qu2_response_opt_hist is '[ResponseOption][HIST] If a survey question consists of pre-defined responses (e.g. list box, set of checkboxes etc), this file contains responses available to a particular survey questions. Each response is a separate row in this file. e.g. if a question has 5 checkboxes as possible responses, this file shall have 5 rows for this particular question.<\n>If the survey question is a simple data entry fields (e.g. text, date) then it doesn''t contain any response options.';
comment on column qu2_response_opt_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu2_response_opt_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_response_opt_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_response_opt_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_response_opt_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_response_opt_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_response_opt_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_response_opt_hist.q4x_timestamp is '* Timestamp';
comment on column qu2_response_opt_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu2_response_opt_hist.survey_question_id is '[SurveyQuestion_ID] Mandatory foreign key from [SurveyQuestion].[Id].';
comment on column qu2_response_opt_hist.sort_ord is '[SortOrder] The order in which the responses should be presented for a question.';
comment on column qu2_response_opt_hist.enable_set is '[EnableSet] If this response option is chosen, which question set in survey question should be enabled. This is used with conditional questions where a question is shown only when a particular response is selected in previous question.<\n>Maps to SurveyQuestion.QuestionSet column.';
comment on column qu2_response_opt_hist.response_label is '[ResponseLabel] The actual value of the response.';

-- Synonyms
create or replace public synonym qu2_response_opt_hist for ods.qu2_response_opt_hist;

-- Grants
grant select,insert,update,delete on ods.qu2_response_opt_hist to ods_app;
grant select on ods.qu2_response_opt_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/


/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_survey_question_hist
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_survey_question_hist] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_survey_question_hist cascade constraints;

create table ods.quo_survey_question_hist (
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
  survey_id                       number(10, 0)                   null,
  survey_id_lookup                varchar2(50 char)               null,
  question_id                     number(10, 0)                   null,
  question_id_lookup              varchar2(50 char)               null,
  question                        varchar2(200 char)              null,
  is_mandatory                    number(1, 0)                    null,
  sort_ord                        varchar2(50 char)               null,
  question_set                    number(3, 0)                    null,
  response_type_id                number(10, 0)                   null,
  response_type_id_lookup         varchar2(50 char)               null,
  is_single_choice                number(1, 0)                    null,
  freeform_data_type              varchar2(50 char)               null,
  question_created_date           date                            null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_survey_question_hist add constraint quo_survey_question_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_survey_question_hist_pk on ods.quo_survey_question_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_survey_question_hist add constraint quo_survey_question_hist_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_survey_question_hist_uk on ods.quo_survey_question_hist (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_survey_question_hist_ts on ods.quo_survey_question_hist (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_survey_question_hist is '[SurveyQuestion] Various questions attached to a survey.';
comment on column quo_survey_question_hist.q4x_load_seq is '* Unique Load Id';
comment on column quo_survey_question_hist.q4x_load_data_seq is '* Data Record Id';
comment on column quo_survey_question_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_survey_question_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_survey_question_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_survey_question_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_survey_question_hist.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_survey_question_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_survey_question_hist.q4x_timestamp is '* Timestamp';
comment on column quo_survey_question_hist.id is '[ID] Unique Internal ID for the row';
comment on column quo_survey_question_hist.id_lookup is '[ID_Lookup] ';
comment on column quo_survey_question_hist.survey_id is '[Survey_ID] Mandatory foreign key to [Survey].[Id].';
comment on column quo_survey_question_hist.survey_id_lookup is '[Survey_Id_Lookup] ';
comment on column quo_survey_question_hist.question_id is '[Question_ID] ID of the question.';
comment on column quo_survey_question_hist.question_id_lookup is '[Question_ID_Lookup] ';
comment on column quo_survey_question_hist.question is '[Question] The text of the question.';
comment on column quo_survey_question_hist.is_mandatory is '[IsMandatory] Indicates whether the question must be answered to conplete the survey. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column quo_survey_question_hist.sort_ord is '[SortOrder] The order in which the questions should be presented in a survey in a hierarchical way. Thic includes the ability to nest questions.';
comment on column quo_survey_question_hist.question_set is '[QuestionSet] Identifies the question set to which this question belongs. If populated, this question will not be presented unless a response is chosen which enables this question set.';
comment on column quo_survey_question_hist.response_type_id is '[ResponseType_ID] Mandatory foreign key to [ResponseType].[Id].';
comment on column quo_survey_question_hist.response_type_id_lookup is '[ResponseType_ID_Lookup] ';
comment on column quo_survey_question_hist.is_single_choice is '[IsSingleChoice] Indicates whether the response is limited to a single selection. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column quo_survey_question_hist.freeform_data_type is '[FreeformDataType] The data type of the freeform response. e.g. varchar(20), decimal(9, 4), integer.';
comment on column quo_survey_question_hist.question_created_date is '[QuestionCreatedDate] ';


-- Synonyms
create or replace public synonym quo_survey_question_hist for ods.quo_survey_question_hist;

-- Grants
grant select,update,delete,insert on ods.quo_survey_question_hist to ods_app;
grant select on ods.quo_survey_question_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

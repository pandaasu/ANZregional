
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_response_opt
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_response_opt] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_response_opt cascade constraints;

create table ods.quo_response_opt (
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
  survey_question_id              number(10, 0)                   null,
  survey_question_id_lookup       varchar2(50 char)               null,
  sort_ord                        number(3, 0)                    null,
  enable_set                      number(3, 0)                    null,
  response_label                  varchar2(50 char)               null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_response_opt add constraint quo_response_opt_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_response_opt_pk on ods.quo_response_opt (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_response_opt add constraint quo_response_opt_uk unique (q4x_source_id,id)
  using index (create unique index ods.quo_response_opt_uk on ods.quo_response_opt (q4x_source_id,id)) compress;

create index ods.quo_response_opt_ts on ods.quo_response_opt (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_response_opt is '[ResponseOption] Responses available to survey questions.';
comment on column quo_response_opt.q4x_load_seq is '* Unique Load Id';
comment on column quo_response_opt.q4x_load_data_seq is '* Data Record Id';
comment on column quo_response_opt.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_response_opt.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_response_opt.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_response_opt.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_response_opt.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_response_opt.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_response_opt.q4x_timestamp is '* Timestamp';
comment on column quo_response_opt.id is '[ID] Unique Internal ID for the row';
comment on column quo_response_opt.id_lookup is '[ID_Lookup] ';
comment on column quo_response_opt.survey_question_id is '[SurveyQuestion_ID] Mandatory foreign key to [SurveyQuestion].[Id].';
comment on column quo_response_opt.survey_question_id_lookup is '[SurveyQuestion_ID_Lookup] ';
comment on column quo_response_opt.sort_ord is '[SortOrder] The order in which the questions should be presented in a survey. Thic includes the ability to nest questions.';
comment on column quo_response_opt.enable_set is '[EnableSet] If this response option is chosen, which question set in survey question should be enabled.';
comment on column quo_response_opt.response_label is '[ResponseLabel] The name';


-- Synonyms
create or replace public synonym quo_response_opt for ods.quo_response_opt;

-- Grants
grant select,update,delete,insert on ods.quo_response_opt to ods_app;
grant select on ods.quo_response_opt to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

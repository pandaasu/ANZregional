
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu4
    Owner    : ods
    Table    : qu4_act_hdr
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    [qu4_act_hdr] table creation script _load and _hist

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
drop table ods.qu4_act_hdr_load cascade constraints;

create table ods.qu4_act_hdr_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  task_id                         number(10, 0)                   not null,
  rep_id                          number(10, 0)                   not null,
  start_date                      date                            null,
  is_complete                     number(1, 0)                    null,
  end_date                        date                            null,
  call_card_id                    number(10, 0)                   null,
  incomplete_reason_id            number(10, 0)                   null,
  incomplete_reason_id_desc       varchar2(50 char)               null,
  notes                           varchar2(200 char)              null,
  due_date                        date                            null,
  full_name                       varchar2(101 char)              null,
  task_id_desc                    varchar2(200 char)              null,
  comments                        varchar2(100 char)              null,
  key_site_plcmnt_is_activated    number(10, 0)                   null,
  mstm_reg_plcmnt_no_of_register  number(10, 0)                   null,
  mstm_reg_plcmnt_no_of_mstm      number(10, 0)                   null,
  fridge_plcmnt_is_activated      number(10, 0)                   null,
  fridge_plcmnt_no_of_doors       number(10, 0)                   null,
  fridge_plcmnt_no_of_frdg_units  number(10, 0)                   null,
  fridge_plcmnt_is_sleeved_up     number(10, 0)                   null,
  fridge_plcmnt_is_mars_and_coke  number(10, 0)                   null,
  front_back_fronts_in_store      number(10, 0)                   null,
  front_back_fronts_tied_to_prom  number(10, 0)                   null,
  front_back_front_end_type       number(10, 0)                   null,
  front_back_backs_in_store       number(10, 0)                   null,
  front_back_backs_tied_to_prom   number(10, 0)                   null,
  front_back_back_end_type        number(10, 0)                   null,
  lead_in_lead_out_is_any         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu4_act_hdr_load add constraint qu4_act_hdr_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_act_hdr_load_pk on ods.qu4_act_hdr_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_act_hdr_load add constraint qu4_act_hdr_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_act_hdr_load_uk on ods.qu4_act_hdr_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu4_act_hdr_load is '[ActivityHeader][LOAD] Header file for ALL the tasks transactional data. Each task instance has a separate detail file.';
comment on column qu4_act_hdr_load.q4x_load_seq is '* Unique Load Id';
comment on column qu4_act_hdr_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_act_hdr_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_act_hdr_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_act_hdr_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_act_hdr_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_act_hdr_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_act_hdr_load.q4x_timestamp is '* Timestamp';
comment on column qu4_act_hdr_load.id is '[ID] Unique Internal ID for the row';
comment on column qu4_act_hdr_load.task_id is '[Task_ID] Mandatory foreign key from [Task].[Id].';
comment on column qu4_act_hdr_load.rep_id is '[Rep_ID] Mandatory foreign key from [Rep].[Id].';
comment on column qu4_act_hdr_load.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column qu4_act_hdr_load.is_complete is '[IsComplete] Indicates whether the activity has been completed successfully. 0 indicates False, 1 indicates True. Null indicates that the activity has been started, but more will be done before it is complete.';
comment on column qu4_act_hdr_load.end_date is '[EndDate] The last date on which the task should be executed.';
comment on column qu4_act_hdr_load.call_card_id is '[Callcard_ID] Foreign key from [CallCard].[Id]. Populated if the rep completed the survey as part of a visit.';
comment on column qu4_act_hdr_load.incomplete_reason_id is '[IncompleteReasonID] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu4_act_hdr_load.incomplete_reason_id_desc is '[IncompleteReasonID_Description] Default language description of the node';
comment on column qu4_act_hdr_load.notes is '[Notes] ';
comment on column qu4_act_hdr_load.due_date is '[DueDate] ';
comment on column qu4_act_hdr_load.full_name is '[FullName] Full name of the rep';
comment on column qu4_act_hdr_load.task_id_desc is '[Task_ID_Description] ';
comment on column qu4_act_hdr_load.comments is '[Comments] Comments';
comment on column qu4_act_hdr_load.key_site_plcmnt_is_activated is '[KeysitePlacement_IsActivated] ';
comment on column qu4_act_hdr_load.mstm_reg_plcmnt_no_of_register is '[MSTMRegPlacement_NoOfRegisters] Total number of registers in store';
comment on column qu4_act_hdr_load.mstm_reg_plcmnt_no_of_mstm is '[MSTMRegPlacement_NoOfMSTM] Number of registers containing Mars, Snickers, Twix and M&M�s';
comment on column qu4_act_hdr_load.fridge_plcmnt_is_activated is '[FridgePlacement_IsActivated] Activated indicates 1/3 of doors contain a fridge unit';
comment on column qu4_act_hdr_load.fridge_plcmnt_no_of_doors is '[FridgePlacement_NoOfDoors] Number of fridge doors';
comment on column qu4_act_hdr_load.fridge_plcmnt_no_of_frdg_units is '[FridgePlacement_NoOfFridgeUnits] Number of fridge units (across all doors)';
comment on column qu4_act_hdr_load.fridge_plcmnt_is_sleeved_up is '[FridgePlacement_IsSleevedUp] Are Coca-Cola bottles sleeved up with Mars bars in any fridge(s)';
comment on column qu4_act_hdr_load.fridge_plcmnt_is_mars_and_coke is '[FridgePlacement_IsMarsAndCokeCombo] Is there a Mars and Coca-Cola promotion running in-store';
comment on column qu4_act_hdr_load.front_back_fronts_in_store is '[FrontEndsBackEnds_FrontsInStore] Number of Mars displays on front of aisles';
comment on column qu4_act_hdr_load.front_back_fronts_tied_to_prom is '[FrontEndsBackEnds_FrontsTiedToPromo] Number of Mars displays on front of aisles, tied to promotion';
comment on column qu4_act_hdr_load.front_back_front_end_type is '[FrontEndsBackEnds_FrontEndType] Bulk indicates cardboard or similar display case is used for products;Densed indicates products are used to create display / stand itself (e.g. cases of soft drinks are often displayed this way)';
comment on column qu4_act_hdr_load.front_back_backs_in_store is '[FrontEndsBackEnds_BacksInStore] Number of Mars displays on back of aisles';
comment on column qu4_act_hdr_load.front_back_backs_tied_to_prom is '[FrontEndsBackEnds_BacksTiedToPromo] Number of Mars displays on back of aisles, tied to promotion';
comment on column qu4_act_hdr_load.front_back_back_end_type is '[FrontEndsBackEnds_BackEndType] Bulk indicates cardboard or similar display case is used for products;Densed indicates products are used to create display / stand itself (e.g. cases of soft drinks are often displayed this way)';
comment on column qu4_act_hdr_load.lead_in_lead_out_is_any is '[LeadInLeadOut_IsAny] indicates there�s a lead-in / lead-out on a (any) promotion in store.';

-- Synonyms
create or replace public synonym qu4_act_hdr_load for ods.qu4_act_hdr_load;

-- Grants
grant select,insert,update,delete on ods.qu4_act_hdr_load to ods_app;
grant select on ods.qu4_act_hdr_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu4_act_hdr_hist cascade constraints;

create table ods.qu4_act_hdr_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  task_id                         number(10, 0)                   not null,
  rep_id                          number(10, 0)                   not null,
  start_date                      date                            null,
  is_complete                     number(1, 0)                    null,
  end_date                        date                            null,
  call_card_id                    number(10, 0)                   null,
  incomplete_reason_id            number(10, 0)                   null,
  incomplete_reason_id_desc       varchar2(50 char)               null,
  notes                           varchar2(200 char)              null,
  due_date                        date                            null,
  full_name                       varchar2(101 char)              null,
  task_id_desc                    varchar2(200 char)              null,
  comments                        varchar2(100 char)              null,
  key_site_plcmnt_is_activated    number(10, 0)                   null,
  mstm_reg_plcmnt_no_of_register  number(10, 0)                   null,
  mstm_reg_plcmnt_no_of_mstm      number(10, 0)                   null,
  fridge_plcmnt_is_activated      number(10, 0)                   null,
  fridge_plcmnt_no_of_doors       number(10, 0)                   null,
  fridge_plcmnt_no_of_frdg_units  number(10, 0)                   null,
  fridge_plcmnt_is_sleeved_up     number(10, 0)                   null,
  fridge_plcmnt_is_mars_and_coke  number(10, 0)                   null,
  front_back_fronts_in_store      number(10, 0)                   null,
  front_back_fronts_tied_to_prom  number(10, 0)                   null,
  front_back_front_end_type       number(10, 0)                   null,
  front_back_backs_in_store       number(10, 0)                   null,
  front_back_backs_tied_to_prom   number(10, 0)                   null,
  front_back_back_end_type        number(10, 0)                   null,
  lead_in_lead_out_is_any         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu4_act_hdr_hist add constraint qu4_act_hdr_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_act_hdr_hist_pk on ods.qu4_act_hdr_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_act_hdr_hist add constraint qu4_act_hdr_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_act_hdr_hist_uk on ods.qu4_act_hdr_hist (id,q4x_batch_id)) compress;

create index ods.qu4_act_hdr_hist_ts on ods.qu4_act_hdr_hist (q4x_timestamp) compress;

create index ods.qu4_act_hdr_hist_sd on ods.qu4_act_hdr_hist (start_date) compress;

-- Comments
comment on table qu4_act_hdr_hist is '[ActivityHeader][HIST] Header file for ALL the tasks transactional data. Each task instance has a separate detail file.';
comment on column qu4_act_hdr_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu4_act_hdr_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_act_hdr_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_act_hdr_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_act_hdr_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_act_hdr_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_act_hdr_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_act_hdr_hist.q4x_timestamp is '* Timestamp';
comment on column qu4_act_hdr_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu4_act_hdr_hist.task_id is '[Task_ID] Mandatory foreign key from [Task].[Id].';
comment on column qu4_act_hdr_hist.rep_id is '[Rep_ID] Mandatory foreign key from [Rep].[Id].';
comment on column qu4_act_hdr_hist.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column qu4_act_hdr_hist.is_complete is '[IsComplete] Indicates whether the activity has been completed successfully. 0 indicates False, 1 indicates True. Null indicates that the activity has been started, but more will be done before it is complete.';
comment on column qu4_act_hdr_hist.end_date is '[EndDate] The last date on which the task should be executed.';
comment on column qu4_act_hdr_hist.call_card_id is '[Callcard_ID] Foreign key from [CallCard].[Id]. Populated if the rep completed the survey as part of a visit.';
comment on column qu4_act_hdr_hist.incomplete_reason_id is '[IncompleteReasonID] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu4_act_hdr_hist.incomplete_reason_id_desc is '[IncompleteReasonID_Description] Default language description of the node';
comment on column qu4_act_hdr_hist.notes is '[Notes] ';
comment on column qu4_act_hdr_hist.due_date is '[DueDate] ';
comment on column qu4_act_hdr_hist.full_name is '[FullName] Full name of the rep';
comment on column qu4_act_hdr_hist.task_id_desc is '[Task_ID_Description] ';
comment on column qu4_act_hdr_hist.comments is '[Comments] Comments';
comment on column qu4_act_hdr_hist.key_site_plcmnt_is_activated is '[KeysitePlacement_IsActivated] ';
comment on column qu4_act_hdr_hist.mstm_reg_plcmnt_no_of_register is '[MSTMRegPlacement_NoOfRegisters] Total number of registers in store';
comment on column qu4_act_hdr_hist.mstm_reg_plcmnt_no_of_mstm is '[MSTMRegPlacement_NoOfMSTM] Number of registers containing Mars, Snickers, Twix and M&M�s';
comment on column qu4_act_hdr_hist.fridge_plcmnt_is_activated is '[FridgePlacement_IsActivated] Activated indicates 1/3 of doors contain a fridge unit';
comment on column qu4_act_hdr_hist.fridge_plcmnt_no_of_doors is '[FridgePlacement_NoOfDoors] Number of fridge doors';
comment on column qu4_act_hdr_hist.fridge_plcmnt_no_of_frdg_units is '[FridgePlacement_NoOfFridgeUnits] Number of fridge units (across all doors)';
comment on column qu4_act_hdr_hist.fridge_plcmnt_is_sleeved_up is '[FridgePlacement_IsSleevedUp] Are Coca-Cola bottles sleeved up with Mars bars in any fridge(s)';
comment on column qu4_act_hdr_hist.fridge_plcmnt_is_mars_and_coke is '[FridgePlacement_IsMarsAndCokeCombo] Is there a Mars and Coca-Cola promotion running in-store';
comment on column qu4_act_hdr_hist.front_back_fronts_in_store is '[FrontEndsBackEnds_FrontsInStore] Number of Mars displays on front of aisles';
comment on column qu4_act_hdr_hist.front_back_fronts_tied_to_prom is '[FrontEndsBackEnds_FrontsTiedToPromo] Number of Mars displays on front of aisles, tied to promotion';
comment on column qu4_act_hdr_hist.front_back_front_end_type is '[FrontEndsBackEnds_FrontEndType] Bulk indicates cardboard or similar display case is used for products;Densed indicates products are used to create display / stand itself (e.g. cases of soft drinks are often displayed this way)';
comment on column qu4_act_hdr_hist.front_back_backs_in_store is '[FrontEndsBackEnds_BacksInStore] Number of Mars displays on back of aisles';
comment on column qu4_act_hdr_hist.front_back_backs_tied_to_prom is '[FrontEndsBackEnds_BacksTiedToPromo] Number of Mars displays on back of aisles, tied to promotion';
comment on column qu4_act_hdr_hist.front_back_back_end_type is '[FrontEndsBackEnds_BackEndType] Bulk indicates cardboard or similar display case is used for products;Densed indicates products are used to create display / stand itself (e.g. cases of soft drinks are often displayed this way)';
comment on column qu4_act_hdr_hist.lead_in_lead_out_is_any is '[LeadInLeadOut_IsAny] indicates there�s a lead-in / lead-out on a (any) promotion in store.';

-- Synonyms
create or replace public synonym qu4_act_hdr_hist for ods.qu4_act_hdr_hist;

-- Grants
grant select,insert,update,delete on ods.qu4_act_hdr_hist to ods_app;
grant select on ods.qu4_act_hdr_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

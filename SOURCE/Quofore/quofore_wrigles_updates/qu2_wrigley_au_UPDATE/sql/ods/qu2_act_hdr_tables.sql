
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu2
    Owner    : ods
    Table    : qu2_act_hdr
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
    [qu2_act_hdr] table creation script _load and _hist

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
drop table ods.qu2_act_hdr_load cascade constraints;

create table ods.qu2_act_hdr_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  task_id                         number(10, 0)                   null,
  rep_id                          number(10, 0)                   null,
  start_date                      date                            null,
  is_complete                     number(1, 0)                    null,
  end_date                        date                            null,
  callcard_id                     number(10, 0)                   null,
  incomplete_reason_id            number(10, 0)                   null,
  incomplete_reason_id_desc       varchar2(50 char)               null,
  note                            varchar2(200 char)              null,
  due_date                        date                            null,
  full_name                       varchar2(101 char)              null,
  task_id_desc                    varchar2(200 char)              null,
  no_incr_display                 number(10, 0)                   null,
  incr_duration                   number(10, 0)                   null,
  sell_in_note                    varchar2(50 char)               null,
  min_coverage_express            number(10, 0)                   null,
  min_coverage_std                number(10, 0)                   null,
  planogram_ad_here_              number(10, 0)                   null,
  min_gm_sku_aisle                number(10, 0)                   null,
  min_confec_aisle                number(10, 0)                   null,
  gm_off_loc_old                  number(10, 0)                   null,
  confec_old                      number(10, 0)                   null,
  payment_status_compliant        number(10, 0)                   null,
  titanium_created_date           date                            null,
  contact_name                    varchar2(101 char)              null,
  admin_meeting                   number(10, 0)                   null,
  leave_public_holiday            number(10, 0)                   null,
  sick_leave                      number(10, 0)                   null,
  travel                          number(10, 0)                   null,
  it_down_time                    number(10, 0)                   null,
  time_in_shed                    number(10, 0)                   null,
  entry_nestle_stands_a_loc       number(10, 0)                   null,
  entry_nestle_standsin_store     number(10, 0)                   null,
  no_a_locs_reclaimed             number(10, 0)                   null,
  nonewalocations_wwy             number(10, 0)                   null,
  agree_reclaim_a_locs            number(10, 0)                   null,
  nestle_moved_wwy_stand          number(10, 0)                   null,
  no_nestle_stands_prev_wwy       number(10, 0)                   null,
  retailer_signed_premium_offer   number(10, 0)                   null,
  titanium_status                 number(10, 0)                   null,
  comments                        varchar2(100 char)              null,
  outcome_para_import_1           number(10, 0)                   null,
  letter_advising_1               number(10, 0)                   null,
  store_supply_1                  number(10, 0)                   null,
  store_stock_1                   number(10, 0)                   null,
  avg_inners_old_1                number(10, 0)                   null,
  ranged_prod                     number(10, 0)                   null,
  prod_ranging                    number(10, 0)                   null,
  admin                           number(10, 0)                   null,
  conference                      number(10, 0)                   null,
  cust_not_in_quofore             number(10, 0)                   null,
  development_time                number(10, 0)                   null,
  meeting_other                   number(10, 0)                   null,
  meeting_period                  number(10, 0)                   null,
  telesales                       number(10, 0)                   null,
  trade_show                      number(10, 0)                   null,
  training                        number(10, 0)                   null,
  different_terr                  number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu2_act_hdr_load add constraint qu2_act_hdr_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_act_hdr_load_pk on ods.qu2_act_hdr_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_act_hdr_load add constraint qu2_act_hdr_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_act_hdr_load_uk on ods.qu2_act_hdr_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu2_act_hdr_load is '[ActivityHeader][LOAD] Header file for ALL the tasks transactional data. Each task instance has a separate detail file.';
comment on column qu2_act_hdr_load.q4x_load_seq is '* Unique Load Id';
comment on column qu2_act_hdr_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_act_hdr_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_act_hdr_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_act_hdr_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_act_hdr_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_act_hdr_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_act_hdr_load.q4x_timestamp is '* Timestamp';
comment on column qu2_act_hdr_load.id is '[ID] Unique Internal ID for the row';
comment on column qu2_act_hdr_load.task_id is '[Task_ID] Mandatory foreign key from [Task].[Id].';
comment on column qu2_act_hdr_load.rep_id is '[Rep_ID] Mandatory foreign key from [Rep].[Id].';
comment on column qu2_act_hdr_load.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column qu2_act_hdr_load.is_complete is '[IsComplete] Indicates whether the activity has been completed successfully. 0 indicates False, 1 indicates True. Null indicates that the activity has been started, but more will be done before it is complete.';
comment on column qu2_act_hdr_load.end_date is '[EndDate] The last date on which the task should be executed.';
comment on column qu2_act_hdr_load.callcard_id is '[Callcard_ID] Foreign key from [CallCard].[Id]. Populated if the rep completed the survey as part of a visit.';
comment on column qu2_act_hdr_load.incomplete_reason_id is '[IncompleteReasonID] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu2_act_hdr_load.incomplete_reason_id_desc is '[IncompleteReasonID_Description] Default language description of the node';
comment on column qu2_act_hdr_load.note is '[Notes] ';
comment on column qu2_act_hdr_load.due_date is '[DueDate] ';
comment on column qu2_act_hdr_load.full_name is '[FullName] Full name of the rep';
comment on column qu2_act_hdr_load.task_id_desc is '[Task_ID_Description] ';
comment on column qu2_act_hdr_load.no_incr_display is '[NumIncrDisplay] Number of incremental displays greater than HO';
comment on column qu2_act_hdr_load.incr_duration is '[IncrDuration] Incremental duration of off location above HO (weeks)';
comment on column qu2_act_hdr_load.sell_in_note is '[SellInNote] Following items are only required in Grocery sector';
comment on column qu2_act_hdr_load.min_coverage_express is '[MinCoverageExpress] Min coverage Express & Self Scan - List (Yes, No, NA)';
comment on column qu2_act_hdr_load.min_coverage_std is '[MinCoverageStd] Min coverage Std checkouts - List (Yes, No, NA)';
comment on column qu2_act_hdr_load.planogram_ad_here_ is '[PlanogramAdhered] Planograms adhered to - List (Yes, No, NA)';
comment on column qu2_act_hdr_load.min_gm_sku_aisle is '[MinGMSKUAisle] Min G&M SKUs in Aisle - List (Yes, No, NA)';
comment on column qu2_act_hdr_load.min_confec_aisle is '[MinConfecAisle] Min Confectionary in Aisle - List (Yes, No, NA)';
comment on column qu2_act_hdr_load.gm_off_loc_old is '[GMOffLocationOLD] G&M Off Location Display (OLD) - List (Yes, No, NA)';
comment on column qu2_act_hdr_load.confec_old is '[ConfecOLD] Confectionary OLD - List (Yes, No, NA)';
comment on column qu2_act_hdr_load.payment_status_compliant is '[PmtStsCompliant] Payment status compliant and paid - List (Yes, No, NA)';
comment on column qu2_act_hdr_load.titanium_created_date is '[TitaniumCreatedDate] Date';
comment on column qu2_act_hdr_load.contact_name is '[ContactName] Customer contact name';
comment on column qu2_act_hdr_load.admin_meeting is '[AdminMeeting] Admin/Meetings';
comment on column qu2_act_hdr_load.leave_public_holiday is '[LeavePublicHoliday] Leave/Public Holiday';
comment on column qu2_act_hdr_load.sick_leave is '[SickLeave] Sick Leave';
comment on column qu2_act_hdr_load.travel is '[Travel] Travel';
comment on column qu2_act_hdr_load.it_down_time is '[ITDownTime] IT down time';
comment on column qu2_act_hdr_load.time_in_shed is '[TimeInShed] Time in Shed';
comment on column qu2_act_hdr_load.entry_nestle_stands_a_loc is '[EntryNestleStandsALocation] On entry, Nestle stands in A loc';
comment on column qu2_act_hdr_load.entry_nestle_standsin_store is '[EntryNestleStandsInStore] On entry, Nestle stands in  store';
comment on column qu2_act_hdr_load.no_a_locs_reclaimed is '[NoALocationsReclaimed] On exit, A-locations reclaimed';
comment on column qu2_act_hdr_load.nonewalocations_wwy is '[NoNewALocationsWrigley] On exit, A-locations wrigley gained';
comment on column qu2_act_hdr_load.agree_reclaim_a_locs is '[AgreeReclaimALocations] On Exit, did decision maker agree to reclaim A-loc from Nestle';
comment on column qu2_act_hdr_load.nestle_moved_wwy_stand is '[NestleMovedWrigleyStand] On entry, has Nestle moved wrigley stand';
comment on column qu2_act_hdr_load.no_nestle_stands_prev_wwy is '[NoNestleStandsPrevWrigley] On entry, Nestle stands where prev wrigley stand';
comment on column qu2_act_hdr_load.retailer_signed_premium_offer is '[RetailerSignedPremiumOffer] On exit, retailer signed up to Impulse platinum offer';
comment on column qu2_act_hdr_load.titanium_status is '[TitaniumStatus] Status';
comment on column qu2_act_hdr_load.comments is '[Comments] Comments';
comment on column qu2_act_hdr_load.outcome_para_import_1 is '[OutcomeParaImport1] Outcome';
comment on column qu2_act_hdr_load.letter_advising_1 is '[LetterAdvising1] Letter advising of parallel importing?';
comment on column qu2_act_hdr_load.store_supply_1 is '[StoreSupply1] Who is supplying the Wrigley parallel products to the store?';
comment on column qu2_act_hdr_load.store_stock_1 is '[StoreStock1] How often does this store stock Wrigley parallel products?';
comment on column qu2_act_hdr_load.avg_inners_old_1 is '[AvgInnersold1] Average # of inners sold per month in total';
comment on column qu2_act_hdr_load.ranged_prod is '[RangedProd] Where are the products ranged';
comment on column qu2_act_hdr_load.prod_ranging is '[ProdRanging] Reason for ranging these products';
comment on column qu2_act_hdr_load.admin is '[Administration] Administration';
comment on column qu2_act_hdr_load.conference is '[Conference] Conference';
comment on column qu2_act_hdr_load.cust_not_in_quofore is '[CustomerNotInQuofore] Customer Not In Quofore';
comment on column qu2_act_hdr_load.development_time is '[DevelopmentTime] Development Time';
comment on column qu2_act_hdr_load.meeting_other is '[MeetingOther] Meeting Other';
comment on column qu2_act_hdr_load.meeting_period is '[MeetingPeriod] Meeting Period';
comment on column qu2_act_hdr_load.telesales is '[Telesales] Telesales';
comment on column qu2_act_hdr_load.trade_show is '[TradeShow] Trade Show';
comment on column qu2_act_hdr_load.training is '[Training] Training';
comment on column qu2_act_hdr_load.different_terr is '[DifferentTerritory] Different Territory';

-- Synonyms
create or replace public synonym qu2_act_hdr_load for ods.qu2_act_hdr_load;

-- Grants
grant select,insert,update,delete on ods.qu2_act_hdr_load to ods_app;
grant select on ods.qu2_act_hdr_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu2_act_hdr_hist cascade constraints;

create table ods.qu2_act_hdr_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  task_id                         number(10, 0)                   null,
  rep_id                          number(10, 0)                   null,
  start_date                      date                            null,
  is_complete                     number(1, 0)                    null,
  end_date                        date                            null,
  callcard_id                     number(10, 0)                   null,
  incomplete_reason_id            number(10, 0)                   null,
  incomplete_reason_id_desc       varchar2(50 char)               null,
  note                            varchar2(200 char)              null,
  due_date                        date                            null,
  full_name                       varchar2(101 char)              null,
  task_id_desc                    varchar2(200 char)              null,
  no_incr_display                 number(10, 0)                   null,
  incr_duration                   number(10, 0)                   null,
  sell_in_note                    varchar2(50 char)               null,
  min_coverage_express            number(10, 0)                   null,
  min_coverage_std                number(10, 0)                   null,
  planogram_ad_here_              number(10, 0)                   null,
  min_gm_sku_aisle                number(10, 0)                   null,
  min_confec_aisle                number(10, 0)                   null,
  gm_off_loc_old                  number(10, 0)                   null,
  confec_old                      number(10, 0)                   null,
  payment_status_compliant        number(10, 0)                   null,
  titanium_created_date           date                            null,
  contact_name                    varchar2(101 char)              null,
  admin_meeting                   number(10, 0)                   null,
  leave_public_holiday            number(10, 0)                   null,
  sick_leave                      number(10, 0)                   null,
  travel                          number(10, 0)                   null,
  it_down_time                    number(10, 0)                   null,
  time_in_shed                    number(10, 0)                   null,
  entry_nestle_stands_a_loc       number(10, 0)                   null,
  entry_nestle_standsin_store     number(10, 0)                   null,
  no_a_locs_reclaimed             number(10, 0)                   null,
  nonewalocations_wwy             number(10, 0)                   null,
  agree_reclaim_a_locs            number(10, 0)                   null,
  nestle_moved_wwy_stand          number(10, 0)                   null,
  no_nestle_stands_prev_wwy       number(10, 0)                   null,
  retailer_signed_premium_offer   number(10, 0)                   null,
  titanium_status                 number(10, 0)                   null,
  comments                        varchar2(100 char)              null,
  outcome_para_import_1           number(10, 0)                   null,
  letter_advising_1               number(10, 0)                   null,
  store_supply_1                  number(10, 0)                   null,
  store_stock_1                   number(10, 0)                   null,
  avg_inners_old_1                number(10, 0)                   null,
  ranged_prod                     number(10, 0)                   null,
  prod_ranging                    number(10, 0)                   null,
  admin                           number(10, 0)                   null,
  conference                      number(10, 0)                   null,
  cust_not_in_quofore             number(10, 0)                   null,
  development_time                number(10, 0)                   null,
  meeting_other                   number(10, 0)                   null,
  meeting_period                  number(10, 0)                   null,
  telesales                       number(10, 0)                   null,
  trade_show                      number(10, 0)                   null,
  training                        number(10, 0)                   null,
  different_terr                  number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu2_act_hdr_hist add constraint qu2_act_hdr_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_act_hdr_hist_pk on ods.qu2_act_hdr_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_act_hdr_hist add constraint qu2_act_hdr_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_act_hdr_hist_uk on ods.qu2_act_hdr_hist (id,q4x_batch_id)) compress;

create index ods.qu2_act_hdr_hist_ts on ods.qu2_act_hdr_hist (q4x_timestamp) compress;

create index ods.qu2_act_hdr_hist_sd on ods.qu2_act_hdr_hist (start_date) compress;

-- Comments
comment on table qu2_act_hdr_hist is '[ActivityHeader][HIST] Header file for ALL the tasks transactional data. Each task instance has a separate detail file.';
comment on column qu2_act_hdr_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu2_act_hdr_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_act_hdr_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_act_hdr_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_act_hdr_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_act_hdr_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_act_hdr_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_act_hdr_hist.q4x_timestamp is '* Timestamp';
comment on column qu2_act_hdr_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu2_act_hdr_hist.task_id is '[Task_ID] Mandatory foreign key from [Task].[Id].';
comment on column qu2_act_hdr_hist.rep_id is '[Rep_ID] Mandatory foreign key from [Rep].[Id].';
comment on column qu2_act_hdr_hist.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column qu2_act_hdr_hist.is_complete is '[IsComplete] Indicates whether the activity has been completed successfully. 0 indicates False, 1 indicates True. Null indicates that the activity has been started, but more will be done before it is complete.';
comment on column qu2_act_hdr_hist.end_date is '[EndDate] The last date on which the task should be executed.';
comment on column qu2_act_hdr_hist.callcard_id is '[Callcard_ID] Foreign key from [CallCard].[Id]. Populated if the rep completed the survey as part of a visit.';
comment on column qu2_act_hdr_hist.incomplete_reason_id is '[IncompleteReasonID] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu2_act_hdr_hist.incomplete_reason_id_desc is '[IncompleteReasonID_Description] Default language description of the node';
comment on column qu2_act_hdr_hist.note is '[Notes] ';
comment on column qu2_act_hdr_hist.due_date is '[DueDate] ';
comment on column qu2_act_hdr_hist.full_name is '[FullName] Full name of the rep';
comment on column qu2_act_hdr_hist.task_id_desc is '[Task_ID_Description] ';
comment on column qu2_act_hdr_hist.no_incr_display is '[NumIncrDisplay] Number of incremental displays greater than HO';
comment on column qu2_act_hdr_hist.incr_duration is '[IncrDuration] Incremental duration of off location above HO (weeks)';
comment on column qu2_act_hdr_hist.sell_in_note is '[SellInNote] Following items are only required in Grocery sector';
comment on column qu2_act_hdr_hist.min_coverage_express is '[MinCoverageExpress] Min coverage Express & Self Scan - List (Yes, No, NA)';
comment on column qu2_act_hdr_hist.min_coverage_std is '[MinCoverageStd] Min coverage Std checkouts - List (Yes, No, NA)';
comment on column qu2_act_hdr_hist.planogram_ad_here_ is '[PlanogramAdhered] Planograms adhered to - List (Yes, No, NA)';
comment on column qu2_act_hdr_hist.min_gm_sku_aisle is '[MinGMSKUAisle] Min G&M SKUs in Aisle - List (Yes, No, NA)';
comment on column qu2_act_hdr_hist.min_confec_aisle is '[MinConfecAisle] Min Confectionary in Aisle - List (Yes, No, NA)';
comment on column qu2_act_hdr_hist.gm_off_loc_old is '[GMOffLocationOLD] G&M Off Location Display (OLD) - List (Yes, No, NA)';
comment on column qu2_act_hdr_hist.confec_old is '[ConfecOLD] Confectionary OLD - List (Yes, No, NA)';
comment on column qu2_act_hdr_hist.payment_status_compliant is '[PmtStsCompliant] Payment status compliant and paid - List (Yes, No, NA)';
comment on column qu2_act_hdr_hist.titanium_created_date is '[TitaniumCreatedDate] Date';
comment on column qu2_act_hdr_hist.contact_name is '[ContactName] Customer contact name';
comment on column qu2_act_hdr_hist.admin_meeting is '[AdminMeeting] Admin/Meetings';
comment on column qu2_act_hdr_hist.leave_public_holiday is '[LeavePublicHoliday] Leave/Public Holiday';
comment on column qu2_act_hdr_hist.sick_leave is '[SickLeave] Sick Leave';
comment on column qu2_act_hdr_hist.travel is '[Travel] Travel';
comment on column qu2_act_hdr_hist.it_down_time is '[ITDownTime] IT down time';
comment on column qu2_act_hdr_hist.time_in_shed is '[TimeInShed] Time in Shed';
comment on column qu2_act_hdr_hist.entry_nestle_stands_a_loc is '[EntryNestleStandsALocation] On entry, Nestle stands in A loc';
comment on column qu2_act_hdr_hist.entry_nestle_standsin_store is '[EntryNestleStandsInStore] On entry, Nestle stands in  store';
comment on column qu2_act_hdr_hist.no_a_locs_reclaimed is '[NoALocationsReclaimed] On exit, A-locations reclaimed';
comment on column qu2_act_hdr_hist.nonewalocations_wwy is '[NoNewALocationsWrigley] On exit, A-locations wrigley gained';
comment on column qu2_act_hdr_hist.agree_reclaim_a_locs is '[AgreeReclaimALocations] On Exit, did decision maker agree to reclaim A-loc from Nestle';
comment on column qu2_act_hdr_hist.nestle_moved_wwy_stand is '[NestleMovedWrigleyStand] On entry, has Nestle moved wrigley stand';
comment on column qu2_act_hdr_hist.no_nestle_stands_prev_wwy is '[NoNestleStandsPrevWrigley] On entry, Nestle stands where prev wrigley stand';
comment on column qu2_act_hdr_hist.retailer_signed_premium_offer is '[RetailerSignedPremiumOffer] On exit, retailer signed up to Impulse platinum offer';
comment on column qu2_act_hdr_hist.titanium_status is '[TitaniumStatus] Status';
comment on column qu2_act_hdr_hist.comments is '[Comments] Comments';
comment on column qu2_act_hdr_hist.outcome_para_import_1 is '[OutcomeParaImport1] Outcome';
comment on column qu2_act_hdr_hist.letter_advising_1 is '[LetterAdvising1] Letter advising of parallel importing?';
comment on column qu2_act_hdr_hist.store_supply_1 is '[StoreSupply1] Who is supplying the Wrigley parallel products to the store?';
comment on column qu2_act_hdr_hist.store_stock_1 is '[StoreStock1] How often does this store stock Wrigley parallel products?';
comment on column qu2_act_hdr_hist.avg_inners_old_1 is '[AvgInnersold1] Average # of inners sold per month in total';
comment on column qu2_act_hdr_hist.ranged_prod is '[RangedProd] Where are the products ranged';
comment on column qu2_act_hdr_hist.prod_ranging is '[ProdRanging] Reason for ranging these products';
comment on column qu2_act_hdr_hist.admin is '[Administration] Administration';
comment on column qu2_act_hdr_hist.conference is '[Conference] Conference';
comment on column qu2_act_hdr_hist.cust_not_in_quofore is '[CustomerNotInQuofore] Customer Not In Quofore';
comment on column qu2_act_hdr_hist.development_time is '[DevelopmentTime] Development Time';
comment on column qu2_act_hdr_hist.meeting_other is '[MeetingOther] Meeting Other';
comment on column qu2_act_hdr_hist.meeting_period is '[MeetingPeriod] Meeting Period';
comment on column qu2_act_hdr_hist.telesales is '[Telesales] Telesales';
comment on column qu2_act_hdr_hist.trade_show is '[TradeShow] Trade Show';
comment on column qu2_act_hdr_hist.training is '[Training] Training';
comment on column qu2_act_hdr_hist.different_terr is '[DifferentTerritory] Different Territory';

-- Synonyms
create or replace public synonym qu2_act_hdr_hist for ods.qu2_act_hdr_hist;

-- Grants
grant select,insert,update,delete on ods.qu2_act_hdr_hist to ods_app;
grant select on ods.qu2_act_hdr_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

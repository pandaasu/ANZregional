
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu2
    Owner    : ods
    Table    : qu2_act_dtl_exec_compl
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
    [qu2_act_dtl_exec_compl] table creation script _load and _hist

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
drop table ods.qu2_act_dtl_exec_compl_load cascade constraints;

create table ods.qu2_act_dtl_exec_compl_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  act_id                          number(10, 0)                   null,
  act_name                        number(10, 0)                   null,
  objective                       number(10, 0)                   null,
  hardware_on_entry               number(10, 0)                   null,
  pos_on_entry                    number(10, 0)                   null,
  planogram_on_entry              number(10, 0)                   null,
  allocation_on_entry             number(10, 0)                   null,
  promotion_compliance_on_entry   number(10, 0)                   null,
  over_all_compliance_on_entry    number(10, 0)                   null,
  commentary_on_entry             number(10, 0)                   null,
  hardware_on_exit                number(10, 0)                   null,
  pos_on_exit                     number(10, 0)                   null,
  planogram_on_exit               number(10, 0)                   null,
  allocation_on_exit              number(10, 0)                   null,
  promotion_compliance_exit       number(10, 0)                   null,
  over_all_compliance_exit        number(10, 0)                   null,
  commentary_on_exit              number(10, 0)                   null,
  action_plan                     number(10, 0)                   null,
  hier_node_id                    number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu2_act_dtl_exec_compl_load add constraint qu2_act_dtl_exec_compl_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_act_dtl_exec_compl_load_pk on ods.qu2_act_dtl_exec_compl_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_act_dtl_exec_compl_load add constraint qu2_act_dtl_exec_compl_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_act_dtl_exec_compl_load_uk on ods.qu2_act_dtl_exec_compl_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu2_act_dtl_exec_compl_load is '[ActivityDetail_ExecCompliance][LOAD] Detail file for Execution Compliance task';
comment on column qu2_act_dtl_exec_compl_load.q4x_load_seq is '* Unique Load Id';
comment on column qu2_act_dtl_exec_compl_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_act_dtl_exec_compl_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_act_dtl_exec_compl_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_act_dtl_exec_compl_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_act_dtl_exec_compl_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_act_dtl_exec_compl_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_act_dtl_exec_compl_load.q4x_timestamp is '* Timestamp';
comment on column qu2_act_dtl_exec_compl_load.id is '[ID] Unique Internal ID for the row';
comment on column qu2_act_dtl_exec_compl_load.act_id is '[Activity_ID] Mandatory foreign key from [ActivityHeader].[Id].';
comment on column qu2_act_dtl_exec_compl_load.act_name is '[ActivityName] Activity Name';
comment on column qu2_act_dtl_exec_compl_load.objective is '[Objective] Objective';
comment on column qu2_act_dtl_exec_compl_load.hardware_on_entry is '[HardwareOnEntry] Hardware On Entry';
comment on column qu2_act_dtl_exec_compl_load.pos_on_entry is '[PositionOnEntry] Position in Store on Entry';
comment on column qu2_act_dtl_exec_compl_load.planogram_on_entry is '[PlanogramOnEntry] Planogram On Entry';
comment on column qu2_act_dtl_exec_compl_load.allocation_on_entry is '[AllocationOnEntry] Allocation on Entry';
comment on column qu2_act_dtl_exec_compl_load.promotion_compliance_on_entry is '[PromotionComplianceOnEntry] Promotion Compliance on Entry';
comment on column qu2_act_dtl_exec_compl_load.over_all_compliance_on_entry is '[OverallComplianceOnEntry] Overall Compliance on Entry';
comment on column qu2_act_dtl_exec_compl_load.commentary_on_entry is '[CommentaryOnEntry] Commentary On Entry';
comment on column qu2_act_dtl_exec_compl_load.hardware_on_exit is '[HardwareOnExit] Hardware on Exit';
comment on column qu2_act_dtl_exec_compl_load.pos_on_exit is '[PositionOnExit] Position in Store On Exit';
comment on column qu2_act_dtl_exec_compl_load.planogram_on_exit is '[PlanogramOnExit] Planogram On Exit';
comment on column qu2_act_dtl_exec_compl_load.allocation_on_exit is '[AllocationOnExit] Allocation on Exit';
comment on column qu2_act_dtl_exec_compl_load.promotion_compliance_exit is '[PromotionComplianceExit] Promotion Compliance On Exit';
comment on column qu2_act_dtl_exec_compl_load.over_all_compliance_exit is '[OverallComplianceExit] Overall Compliance on Exit';
comment on column qu2_act_dtl_exec_compl_load.commentary_on_exit is '[CommentaryOnExit] Commentary on Exit';
comment on column qu2_act_dtl_exec_compl_load.action_plan is '[ActionPlan] Action Plan';
comment on column qu2_act_dtl_exec_compl_load.hier_node_id is '[HierarchyNode_Id] Foreign key from [Hierarchy].[Id].';

-- Synonyms
create or replace public synonym qu2_act_dtl_exec_compl_load for ods.qu2_act_dtl_exec_compl_load;

-- Grants
grant select,insert,update,delete on ods.qu2_act_dtl_exec_compl_load to ods_app;
grant select on ods.qu2_act_dtl_exec_compl_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu2_act_dtl_exec_compl_hist cascade constraints;

create table ods.qu2_act_dtl_exec_compl_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  act_id                          number(10, 0)                   null,
  act_name                        number(10, 0)                   null,
  objective                       number(10, 0)                   null,
  hardware_on_entry               number(10, 0)                   null,
  pos_on_entry                    number(10, 0)                   null,
  planogram_on_entry              number(10, 0)                   null,
  allocation_on_entry             number(10, 0)                   null,
  promotion_compliance_on_entry   number(10, 0)                   null,
  over_all_compliance_on_entry    number(10, 0)                   null,
  commentary_on_entry             number(10, 0)                   null,
  hardware_on_exit                number(10, 0)                   null,
  pos_on_exit                     number(10, 0)                   null,
  planogram_on_exit               number(10, 0)                   null,
  allocation_on_exit              number(10, 0)                   null,
  promotion_compliance_exit       number(10, 0)                   null,
  over_all_compliance_exit        number(10, 0)                   null,
  commentary_on_exit              number(10, 0)                   null,
  action_plan                     number(10, 0)                   null,
  hier_node_id                    number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu2_act_dtl_exec_compl_hist add constraint qu2_act_dtl_exec_compl_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_act_dtl_exec_compl_hist_pk on ods.qu2_act_dtl_exec_compl_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_act_dtl_exec_compl_hist add constraint qu2_act_dtl_exec_compl_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_act_dtl_exec_compl_hist_uk on ods.qu2_act_dtl_exec_compl_hist (id,q4x_batch_id)) compress;

create index ods.qu2_act_dtl_exec_compl_hist_ts on ods.qu2_act_dtl_exec_compl_hist (q4x_timestamp) compress;

-- Comments
comment on table qu2_act_dtl_exec_compl_hist is '[ActivityDetail_ExecCompliance][HIST] Detail file for Execution Compliance task';
comment on column qu2_act_dtl_exec_compl_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu2_act_dtl_exec_compl_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_act_dtl_exec_compl_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_act_dtl_exec_compl_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_act_dtl_exec_compl_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_act_dtl_exec_compl_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_act_dtl_exec_compl_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_act_dtl_exec_compl_hist.q4x_timestamp is '* Timestamp';
comment on column qu2_act_dtl_exec_compl_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu2_act_dtl_exec_compl_hist.act_id is '[Activity_ID] Mandatory foreign key from [ActivityHeader].[Id].';
comment on column qu2_act_dtl_exec_compl_hist.act_name is '[ActivityName] Activity Name';
comment on column qu2_act_dtl_exec_compl_hist.objective is '[Objective] Objective';
comment on column qu2_act_dtl_exec_compl_hist.hardware_on_entry is '[HardwareOnEntry] Hardware On Entry';
comment on column qu2_act_dtl_exec_compl_hist.pos_on_entry is '[PositionOnEntry] Position in Store on Entry';
comment on column qu2_act_dtl_exec_compl_hist.planogram_on_entry is '[PlanogramOnEntry] Planogram On Entry';
comment on column qu2_act_dtl_exec_compl_hist.allocation_on_entry is '[AllocationOnEntry] Allocation on Entry';
comment on column qu2_act_dtl_exec_compl_hist.promotion_compliance_on_entry is '[PromotionComplianceOnEntry] Promotion Compliance on Entry';
comment on column qu2_act_dtl_exec_compl_hist.over_all_compliance_on_entry is '[OverallComplianceOnEntry] Overall Compliance on Entry';
comment on column qu2_act_dtl_exec_compl_hist.commentary_on_entry is '[CommentaryOnEntry] Commentary On Entry';
comment on column qu2_act_dtl_exec_compl_hist.hardware_on_exit is '[HardwareOnExit] Hardware on Exit';
comment on column qu2_act_dtl_exec_compl_hist.pos_on_exit is '[PositionOnExit] Position in Store On Exit';
comment on column qu2_act_dtl_exec_compl_hist.planogram_on_exit is '[PlanogramOnExit] Planogram On Exit';
comment on column qu2_act_dtl_exec_compl_hist.allocation_on_exit is '[AllocationOnExit] Allocation on Exit';
comment on column qu2_act_dtl_exec_compl_hist.promotion_compliance_exit is '[PromotionComplianceExit] Promotion Compliance On Exit';
comment on column qu2_act_dtl_exec_compl_hist.over_all_compliance_exit is '[OverallComplianceExit] Overall Compliance on Exit';
comment on column qu2_act_dtl_exec_compl_hist.commentary_on_exit is '[CommentaryOnExit] Commentary on Exit';
comment on column qu2_act_dtl_exec_compl_hist.action_plan is '[ActionPlan] Action Plan';
comment on column qu2_act_dtl_exec_compl_hist.hier_node_id is '[HierarchyNode_Id] Foreign key from [Hierarchy].[Id].';

-- Synonyms
create or replace public synonym qu2_act_dtl_exec_compl_hist for ods.qu2_act_dtl_exec_compl_hist;

-- Grants
grant select,insert,update,delete on ods.qu2_act_dtl_exec_compl_hist to ods_app;
grant select on ods.qu2_act_dtl_exec_compl_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

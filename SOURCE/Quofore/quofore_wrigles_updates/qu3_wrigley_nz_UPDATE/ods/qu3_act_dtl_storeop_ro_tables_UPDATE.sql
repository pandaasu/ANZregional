
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu3
    Owner    : ods
    Table    : qu3_act_dtl_storeop_ro
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    [qu3_act_dtl_storeop_ro] table update script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2015-03-18  Mal Chambeyron        Add New Columns

  *****************************************************************************/

-- Table
alter table ods.qu3_act_dtl_storeop_ro_load add (
  no_parallel_store               number(10, 0)                   null,
  no_paralle_wwy_stand            number(10, 0)                   null,
  no_comp_wwy_stand               number(10, 0)                   null,
  no_oos_wwy_stand                number(10, 0)                   null,
  no_pack_date_issue              number(10, 0)                   null,
  pref_wholesaler                 number(10, 0)                   null
)
;

alter table ods.qu3_act_dtl_storeop_ro_hist add (
  no_parallel_store               number(10, 0)                   null,
  no_paralle_wwy_stand            number(10, 0)                   null,
  no_comp_wwy_stand               number(10, 0)                   null,
  no_oos_wwy_stand                number(10, 0)                   null,
  no_pack_date_issue              number(10, 0)                   null,
  pref_wholesaler                 number(10, 0)                   null
)
;

comment on column qu3_act_dtl_storeop_ro_load.no_parallel_store is '[NumParallelStore] Num Parallel Import SKUs in Store';
comment on column qu3_act_dtl_storeop_ro_load.no_paralle_wwy_stand is '[NumParallelWrigStand] Num Parallel Import SKUs on Wrigley Stands';
comment on column qu3_act_dtl_storeop_ro_load.no_comp_wwy_stand is '[NumCompWrigStand] Num Competitor Products on Wrigley Stands';
comment on column qu3_act_dtl_storeop_ro_load.no_oos_wwy_stand is '[NumOOSWrigStand] Num OOS facings on Wrigley Stands';
comment on column qu3_act_dtl_storeop_ro_load.no_pack_date_issue is '[NumPacksDateIssue] Num Wrigley packs w. date issues found in Store';
comment on column qu3_act_dtl_storeop_ro_load.pref_wholesaler is '[PreferredWholesaler] Preferred Wholesaler';

comment on column qu3_act_dtl_storeop_ro_hist.no_parallel_store is '[NumParallelStore] Num Parallel Import SKUs in Store';
comment on column qu3_act_dtl_storeop_ro_hist.no_paralle_wwy_stand is '[NumParallelWrigStand] Num Parallel Import SKUs on Wrigley Stands';
comment on column qu3_act_dtl_storeop_ro_hist.no_comp_wwy_stand is '[NumCompWrigStand] Num Competitor Products on Wrigley Stands';
comment on column qu3_act_dtl_storeop_ro_hist.no_oos_wwy_stand is '[NumOOSWrigStand] Num OOS facings on Wrigley Stands';
comment on column qu3_act_dtl_storeop_ro_hist.no_pack_date_issue is '[NumPacksDateIssue] Num Wrigley packs w. date issues found in Store';
comment on column qu3_act_dtl_storeop_ro_hist.pref_wholesaler is '[PreferredWholesaler] Preferred Wholesaler';

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

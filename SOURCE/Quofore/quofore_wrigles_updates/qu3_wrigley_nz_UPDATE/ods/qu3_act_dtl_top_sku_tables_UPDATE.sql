
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu3
    Owner    : ods
    Table    : qu3_act_dtl_top_sku
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    [qu3_act_dtl_top_sku] table update script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2015-03-18  Mal Chambeyron        Add New Columns

  *****************************************************************************/

-- Table
alter table ods.qu3_act_dtl_top_sku_load add (
  no_std_chk_non_belt             number(10, 0)                   null,
  no_aisle                        number(10, 0)                   null
)
;

alter table ods.qu3_act_dtl_top_sku_hist add (
  no_std_chk_non_belt             number(10, 0)                   null,
  no_aisle                        number(10, 0)                   null
)
;

-- Comments
comment on column qu3_act_dtl_top_sku_load.no_std_chk_non_belt is '[NumStdChkNonBelt] PODs at Std Chk Non-belt side';
comment on column qu3_act_dtl_top_sku_load.no_aisle is '[NumAisle] PODs at Aisle';

comment on column qu3_act_dtl_top_sku_hist.no_std_chk_non_belt is '[NumStdChkNonBelt] PODs at Std Chk Non-belt side';
comment on column qu3_act_dtl_top_sku_hist.no_aisle is '[NumAisle] PODs at Aisle';

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

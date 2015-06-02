
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu3
    Owner    : ods
    Table    : qu3_act_dtl_off_loc
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    [qu3_act_dtl_off_loc] table update script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2015-03-18  Mal Chambeyron        Add New Columns

  *****************************************************************************/

-- Table

alter table ods.qu3_act_dtl_off_loc_load add (
  -- coop_spend                      number(18, 4)                   null,
  sold_in_by                      number(10, 0)                   null,
  built_by                        number(10, 0)                   null
)
;

alter table ods.qu3_act_dtl_off_loc_hist add (
  -- coop_spend                      number(18, 4)                   null,
  sold_in_by                      number(10, 0)                   null,
  built_by                        number(10, 0)                   null
)
;

-- Comments
-- comment on column qu3_act_dtl_off_loc_load.coop_spend is '[Coopspend] The Co Op Spend Amount.';
comment on column qu3_act_dtl_off_loc_load.sold_in_by is '[SoldInBy] Sold In By';
comment on column qu3_act_dtl_off_loc_load.built_by is '[BuiltBy] Built By';

-- comment on column qu3_act_dtl_off_loc_hist.coop_spend is '[Coopspend] The Co Op Spend Amount.';
comment on column qu3_act_dtl_off_loc_hist.sold_in_by is '[SoldInBy] Sold In By';
comment on column qu3_act_dtl_off_loc_hist.built_by is '[BuiltBy] Built By';

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/


  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu3
    Owner    : ods
    Table    : qu3_act_dtl_gpa
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    [qu3_act_dtl_gpa] table update script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2015-03-18  Mal Chambeyron        Add New Columns

  *****************************************************************************/

-- Table
alter table ods.qu3_act_dtl_gpa_load add (
  no_choc_bar_facing              number(10, 0)                   null,
  no_comp_gum_facing              number(10, 0)                   null,
  no_comp_mint_facing             number(10, 0)                   null,
  no_comp_candy_facing            number(10, 0)                   null
)
;

alter table ods.qu3_act_dtl_gpa_hist add (
  no_choc_bar_facing              number(10, 0)                   null,
  no_comp_gum_facing              number(10, 0)                   null,
  no_comp_mint_facing             number(10, 0)                   null,
  no_comp_candy_facing            number(10, 0)                   null
)
;

-- Comments
comment on column qu3_act_dtl_gpa_load.no_choc_bar_facing is '[NumChocBarFacing] Num Choc Singles facings';
comment on column qu3_act_dtl_gpa_load.no_comp_gum_facing is '[NumCompGumFacing] Num Non-Wrigley Gum facings';
comment on column qu3_act_dtl_gpa_load.no_comp_mint_facing is '[NumCompMintFacing] Num Non-Wrigley Mint facings';
comment on column qu3_act_dtl_gpa_load.no_comp_candy_facing is '[NumCompCandyFacing] Num Non-Wrigley Candy facings';

comment on column qu3_act_dtl_gpa_hist.no_choc_bar_facing is '[NumChocBarFacing] Num Choc Singles facings';
comment on column qu3_act_dtl_gpa_hist.no_comp_gum_facing is '[NumCompGumFacing] Num Non-Wrigley Gum facings';
comment on column qu3_act_dtl_gpa_hist.no_comp_mint_facing is '[NumCompMintFacing] Num Non-Wrigley Mint facings';
comment on column qu3_act_dtl_gpa_hist.no_comp_candy_facing is '[NumCompCandyFacing] Num Non-Wrigley Candy facings';

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/


/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : qu2
  Owner  : ods
  Table  : qu2_act_dtl_off_loc_load|hist
  Author : Mal Chambeyron

  Description
  ------------------------------------------------------------------------------
  Quofore Loader [qu2_act_dtl_off_loc_load|hist] table creation script

  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2015-03-04  Mal Chambeyron        Add New Columns

*******************************************************************************/

-- Table
alter table ods.qu2_act_dtl_off_loc_load add (
  promotional_type                number(10, 0)                   null,
  brand                           number(10, 0)                   null,
  promotional_impact              number(10, 0)                   null,
  no_pre_pack_units               number(10, 0)                   null,
  tm_influence                    number(10, 0)                   null
)
;

alter table ods.qu2_act_dtl_off_loc_hist add (
  promotional_type                number(10, 0)                   null,
  brand                           number(10, 0)                   null,
  promotional_impact              number(10, 0)                   null,
  no_pre_pack_units               number(10, 0)                   null,
  tm_influence                    number(10, 0)                   null
)
;

-- Comments
comment on column qu2_act_dtl_off_loc_load.promotional_type is '[PromotionalType] Promotion Type';
comment on column qu2_act_dtl_off_loc_load.brand is '[Brand] Brand';
comment on column qu2_act_dtl_off_loc_load.promotional_impact is '[PromotionalImpact] Impact of promotion';
comment on column qu2_act_dtl_off_loc_load.no_pre_pack_units is '[NumPrepackUnits] Number of prepack units';
comment on column qu2_act_dtl_off_loc_load.tm_influence is '[TMInfluence] TMInfluence';
--
comment on column qu2_act_dtl_off_loc_hist.promotional_type is '[PromotionalType] Promotion Type';
comment on column qu2_act_dtl_off_loc_hist.brand is '[Brand] Brand';
comment on column qu2_act_dtl_off_loc_hist.promotional_impact is '[PromotionalImpact] Impact of promotion';
comment on column qu2_act_dtl_off_loc_hist.no_pre_pack_units is '[NumPrepackUnits] Number of prepack units';
comment on column qu2_act_dtl_off_loc_hist.tm_influence is '[TMInfluence] TMInfluence';

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

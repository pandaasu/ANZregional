
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : qu2
  Owner  : ods
  Table  : qu2_act_dtl_a_loc_load|hist
  Author : Mal Chambeyron

  Description
  ------------------------------------------------------------------------------
  Quofore Loader [qu2_act_dtl_a_loc_load|hist] table creation script

  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2015-03-04  Mal Chambeyron        Add New Columns

*******************************************************************************/

-- Table
alter table ods.qu2_act_dtl_a_loc_load add (
  secondary_loc                   number(10, 0)                   null,
  other_loc                       number(10, 0)                   null,
  no_ts                           number(10, 0)                   null
)
;

alter table ods.qu2_act_dtl_a_loc_hist add (
  secondary_loc                   number(10, 0)                   null,
  other_loc                       number(10, 0)                   null,
  no_ts                           number(10, 0)                   null
)
;

-- Comments
comment on column qu2_act_dtl_a_loc_load.secondary_loc is '[SecondaryLocation] Total number of hardware in secondary locations';
comment on column qu2_act_dtl_a_loc_load.other_loc is '[OtherLocation] Total number of hardware in other locations';
comment on column qu2_act_dtl_a_loc_load.no_ts is '[NumTS] Number of TS';
--
comment on column qu2_act_dtl_a_loc_hist.secondary_loc is '[SecondaryLocation] Total number of hardware in secondary locations';
comment on column qu2_act_dtl_a_loc_hist.other_loc is '[OtherLocation] Total number of hardware in other locations';
comment on column qu2_act_dtl_a_loc_hist.no_ts is '[NumTS] Number of TS';

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

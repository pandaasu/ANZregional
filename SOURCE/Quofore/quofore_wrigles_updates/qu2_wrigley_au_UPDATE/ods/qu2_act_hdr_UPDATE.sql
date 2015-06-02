
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : qu2
  Owner  : ods
  Table  : qu2_act_hdr_load|hist
  Author : Mal Chambeyron

  Description
  ------------------------------------------------------------------------------
  Quofore Loader [qu2_act_hdr_load|hist] table creation script

  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2015-03-04  Mal Chambeyron        Add New Columns

*******************************************************************************/

-- Table
alter table ods.qu2_act_hdr_load add (
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
;

alter table ods.qu2_act_hdr_hist add (
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
;

-- Comments
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
--
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

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

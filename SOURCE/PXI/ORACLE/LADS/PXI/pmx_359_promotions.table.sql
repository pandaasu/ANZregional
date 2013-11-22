--------------------------------------------------------------------------------
-- Table

drop table pxi.pmx_359_promotions cascade constraints;

create table pxi.pmx_359_promotions (
  -- Batch Control Fields
  xactn_seq number(15,0),
  batch_seq number(15,0),
  batch_rec_seq number(10,0),
  -- Promax 359 Promotions Record Fields  
  ic_record_type varchar2(6 char),
  px_company_code varchar2(3 char),
  px_division_code varchar2(3 char),
  customer_hierarchy varchar2(10 char),
  sales_deal varchar2(10 char),
  material varchar2(18 char),
  buy_start_date date,
  buy_stop_date date,
  transaction_code varchar2(4 char),
  description varchar2(40 char),
  sales_org varchar2(4 char),
  rate number(12,2),
  user_1 varchar2(10 char),
  user_2 varchar2(10 char),
  action_code varchar2(1 char),
  bonus_stock_description varchar2(100 char),
  bonus_stock_hurdle number(9,2),
  bonus_stock_receive number(9,2),
  bonus_stock_sku_code varchar2(18 char),
  rate_unit varchar2(5 char),
  condition_pricing_unit varchar2(5 char),
  condition_uom varchar2(3 char),
  sap_promo_number varchar2(10 char),
  currency varchar2(3 char),
  uom_str_unit varchar2(3 char),
  uom_str_saleable varchar2(3 char),
  promo_price_saleable varchar2(10 char),
  promo_price_unit varchar2(10 char),
  transaction_amount varchar2(10 char),
  payer_code varchar2(20 char),
  -- Enriched Fields
  condition_flag varchar2(1 char),
  business_segment varchar2(2 char),
  rate_multiplier number(4),
  condition_type_code varchar2(1 char),
  pricing_condition_code varchar2(4 char),
  condition_table_ref varchar2(5 char),
  cust_div_code varchar2(2 char),
  order_type_code varchar2(4 char),
  -- Calculated Fields
  vakey varchar2(50 char),
  px_xactn_id number(10,0),
  new_customer_hierarchy varchar2(10 char),
  new_material varchar2(18 char),
  new_rate number(12,2),
  new_rate_unit varchar2(5 char),
  new_rate_multiplier varchar2(5 char)
);

-- Batch Control Fields
comment on column pxi.pmx_359_promotions.xactn_seq is 'Unique Transaction Sequence';
comment on column pxi.pmx_359_promotions.batch_seq is 'Unique Batch Sequence per Inbound File';
comment on column pxi.pmx_359_promotions.batch_rec_seq is 'Record Sequence within Batch';
-- Promax 359 Promotions Record Fields  
comment on column pxi.pmx_359_promotions.ic_record_type is 'IC Record Type';
comment on column pxi.pmx_359_promotions.px_company_code is 'PX Company Code';
comment on column pxi.pmx_359_promotions.px_division_code is 'PX Division Code';
comment on column pxi.pmx_359_promotions.customer_hierarchy is 'Customer Hierarchy';
comment on column pxi.pmx_359_promotions.sales_deal is 'Sales Deal';
comment on column pxi.pmx_359_promotions.material is 'Material';
comment on column pxi.pmx_359_promotions.buy_start_date is 'Buy Start Date';
comment on column pxi.pmx_359_promotions.buy_stop_date is 'Buy Stop Date';
comment on column pxi.pmx_359_promotions.transaction_code is 'Transaction Code';
comment on column pxi.pmx_359_promotions.description is 'Description';
comment on column pxi.pmx_359_promotions.sales_org is 'Sales Org';
comment on column pxi.pmx_359_promotions.rate is 'Rate';
comment on column pxi.pmx_359_promotions.user_1 is 'User 1';
comment on column pxi.pmx_359_promotions.user_2 is 'User 2';
comment on column pxi.pmx_359_promotions.action_code is 'Action Code';
comment on column pxi.pmx_359_promotions.bonus_stock_description is 'Bonus Stock Description';
comment on column pxi.pmx_359_promotions.bonus_stock_hurdle is 'Bonus Stock Hurdle';
comment on column pxi.pmx_359_promotions.bonus_stock_receive is 'Bonus Stock Receive';
comment on column pxi.pmx_359_promotions.bonus_stock_sku_code is 'Bonus Stock SKU Code';
comment on column pxi.pmx_359_promotions.rate_unit is 'Rate Unit';
comment on column pxi.pmx_359_promotions.condition_pricing_unit is 'Condition Pricing Unit';
comment on column pxi.pmx_359_promotions.condition_uom is 'Condition UOM';
comment on column pxi.pmx_359_promotions.sap_promo_number is 'SAP Promo Number';
comment on column pxi.pmx_359_promotions.currency is 'Currency';
comment on column pxi.pmx_359_promotions.uom_str_unit is 'UOM Str Unit';
comment on column pxi.pmx_359_promotions.uom_str_saleable is 'UOM Str Saleable';
comment on column pxi.pmx_359_promotions.promo_price_saleable is 'Promo Price Saleable';
comment on column pxi.pmx_359_promotions.promo_price_unit is 'Promo Price Unit';
comment on column pxi.pmx_359_promotions.transaction_amount is 'Transaction Amount';
comment on column pxi.pmx_359_promotions.payer_code is 'Payer Code';
-- Enriched Fields
comment on column pxi.pmx_359_promotions.condition_flag is 'Condition Flag .. If Condition Pricing Unit = 1 Then Condition Flag = F (Dollar) Else Condition Flag = T (Percentage)';
comment on column pxi.pmx_359_promotions.business_segment is 'Business Segment .. Determined from Company Code / Material';
comment on column pxi.pmx_359_promotions.rate_multiplier is 'Rate Multiplier .. Lookup (pmx_prom_config)';
comment on column pxi.pmx_359_promotions.condition_type_code is 'Condition Type Code .. Lookup (pmx_prom_config)';
comment on column pxi.pmx_359_promotions.pricing_condition_code is 'Pricing Condition Code .. Lookup (pmx_prom_config)';
comment on column pxi.pmx_359_promotions.condition_table_ref is 'Condition Table Ref .. Lookup (pmx_prom_config)';
comment on column pxi.pmx_359_promotions.cust_div_code is 'Cust Div Code .. Lookup (pmx_prom_config)';
comment on column pxi.pmx_359_promotions.order_type_code is 'Order Type Code .. Lookup (pmx_prom_config)';
-- Calculated Fields
comment on column pxi.pmx_359_promotions.vakey is 'VAKEY';
comment on column pxi.pmx_359_promotions.px_xactn_id is 'PX Transaction Id .. Embedded in Description .. after [:]';
comment on column pxi.pmx_359_promotions.new_customer_hierarchy is 'FULL Customer Hierarchy';
comment on column pxi.pmx_359_promotions.new_material is 'FULL Material';
comment on column pxi.pmx_359_promotions.new_rate is 'Rate .. Calc';
comment on column pxi.pmx_359_promotions.new_rate_unit is 'Rate Unit .. If Percentage Then Null Else Currency';
comment on column pxi.pmx_359_promotions.new_rate_multiplier is 'Rate Multiplier .. Calc';

comment on table pxi.pmx_359_promotions is 'Promax PX Promotions / Pricing Conditions Transaction Table';

-- Primary Key
alter table pxi.pmx_359_promotions add constraint pmx_359_promotions_pk primary key (xactn_seq)
  using index (create unique index pxi.pmx_359_promotions_pk on pxi.pmx_359_promotions (xactn_seq));

create unique index pxi.pmx_359_promotions_uk on pxi.pmx_359_promotions (vakey, pricing_condition_code, xactn_seq, sales_deal);

create unique index pxi.pmx_359_promotions_batch_seq on pxi.pmx_359_promotions (batch_seq, batch_rec_seq);

create index pxi.pmx_359_promotions_px_xactn_id on pxi.pmx_359_promotions (px_xactn_id);

create index pmx_359_promotions_nuind02 on pxi.pmx_359_promotions (vakey, pricing_condition_code, batch_seq);


-- Synonym
create or replace public synonym pmx_359_promotions for pxi.pmx_359_promotions;

-- Grants
grant select, insert, update, delete on pxi.pmx_359_promotions to pxi_app;


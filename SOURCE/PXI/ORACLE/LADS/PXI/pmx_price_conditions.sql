  drop table pix.pmx_price_conditions;
  
  CREATE TABLE PXI.PMX_PRICE_CONDITIONS (
    CONDITION_TABLE VARCHAR2(5 CHAR), 
    VAKEY VARCHAR2(50 CHAR), 
    COMPANY_CODE VARCHAR2(3 CHAR), 
    CUST_DIV_CODE VARCHAR2(2 CHAR), 
    CUST_HIERARCHY_CODE VARCHAR2(10 CHAR), 
    MATL_CODE VARCHAR2(18 CHAR), 
    BUY_START_DATE DATE, 
    BUY_STOP_DATE DATE, 
    PRICING_CONDITION_CODE VARCHAR2(4 CHAR), 
    CONDITION_TYPE_CODE VARCHAR2(1 CHAR), 
    RATE NUMBER(12,2), 
    RATE_UNIT VARCHAR2(5 CHAR), 
    SALES_DEAL VARCHAR2(10 CHAR), 
    RATE_MULTIPLIER VARCHAR2(5 CHAR), 
    ORDER_TYPE_CODE VARCHAR2(4 CHAR)
   );
   
-- Indexes
create index pxi.PMX_PRICE_CONDITIONS_nu01 on pxi.PMX_PRICE_CONDITIONS (vakey, pricing_condition_code);

-- Grants
grant select, insert, update, delete on pxi.PMX_PRICE_CONDITIONS to pxi_app;

-- Table Comments
comment on column pxi.pmx_price_conditions.company_code is 'PX Company Code';
comment on column pxi.pmx_price_conditions.buy_start_date is 'Buy Start Date';
comment on column pxi.pmx_price_conditions.buy_stop_date is 'Buy Stop Date';
comment on column pxi.pmx_price_conditions.condition_type_code is 'Condition Type Code .. Lookup (pmx_prom_config)';
comment on column pxi.pmx_price_conditions.pricing_condition_code is 'Pricing Condition Code .. Lookup (pmx_prom_config)';
comment on column pxi.pmx_price_conditions.condition_table is 'Condition Table Ref .. Lookup (pmx_prom_config)';
comment on column pxi.pmx_price_conditions.cust_div_code is 'Cust Div Code .. Lookup (pmx_prom_config)';
comment on column pxi.pmx_price_conditions.order_type_code is 'Order Type Code .. Lookup (pmx_prom_config)';
comment on column pxi.pmx_price_conditions.vakey is 'VAKEY';
comment on column pxi.pmx_price_conditions.CUST_HIERARCHY_CODE is 'FULL Customer Hierarchy';
comment on column pxi.pmx_price_conditions.matl_code is 'FULL Material';
comment on column pxi.pmx_price_conditions.rate is 'Rate .. Calc';
comment on column pxi.pmx_price_conditions.rate_unit is 'Rate Unit .. If Percentage Then Null Else Currency';
comment on column pxi.pmx_price_conditions.rate_multiplier is 'Rate Multiplier .. Calc';

comment on table pxi.pmx_price_conditions is 'Promax PX Pricing Conditions Timeline Table';
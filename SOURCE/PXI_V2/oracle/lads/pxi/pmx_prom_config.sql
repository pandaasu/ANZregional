prompt :: Create Table [pmx_prom_config] ::::::::::::::::::::::::::::::::::::::::::::::

/*******************************************************************************
/* Table Definition
/*******************************************************************************

 System : pxi
 Table  : pmx_prom_config
 Owner  : pxi
 Author : Mal Chambeyron

 Description
 -------------------------------------------------------------------------------
 Repository of JDBC Connection Configuration

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-03-11   Mal Chambeyron         Created script from existing table .. 

*******************************************************************************/

-- Table

drop table pxi.pmx_prom_config cascade constraints;

create table pxi.pmx_prom_config (	
  cmpny_code varchar2(3 byte) not null enable, 
  div_code varchar2(2 byte) not null enable, 
  fd_cust_code varchar2(2 byte) not null enable, 
  cndtn_flag varchar2(1 byte) not null enable, 
  rate_unit varchar2(5 byte), 
  rate_multiplier number(4,0), 
  cndtn_type_code varchar2(1 byte) not null enable, 
  pricing_cndtn_code varchar2(4 byte) not null enable, 
  cndtn_table_ref varchar2(5 byte) not null enable, 
  cust_div_code varchar2(2 byte) not null enable, 
  order_type_code varchar2(4 byte), 
  valdtn_status varchar2(10 byte) not null enable, 
  prom_config_lupdp varchar2(8 byte) not null enable, 
  prom_config_lupdt date not null enable 
);

-- Keys

alter table pxi.pmx_prom_config add constraint pmx_prom_config_pk primary key (cmpny_code, div_code, fd_cust_code, pricing_cndtn_code)
  using index (create unique index pxi.pmx_prom_config_pk on pxi.pmx_prom_config(cmpny_code, div_code, fd_cust_code, pricing_cndtn_code));

-- Comments

COMMENT ON TABLE PXI.PMX_PROM_CONFIG  IS 'Promax PX Promotion Configuration table';
COMMENT ON COLUMN PXI.PMX_PROM_CONFIG.CMPNY_CODE IS 'Company Code';
COMMENT ON COLUMN PXI.PMX_PROM_CONFIG.DIV_CODE IS 'Division Code';
COMMENT ON COLUMN PXI.PMX_PROM_CONFIG.FD_CUST_CODE IS 'Fund Description Customer Code';
COMMENT ON COLUMN PXI.PMX_PROM_CONFIG.CNDTN_FLAG IS 'Condition Flag, e.g. ''T'' for Percentage, ''F'' for Dollar Amount';
COMMENT ON COLUMN PXI.PMX_PROM_CONFIG.RATE_UNIT IS 'Rate Unit';
COMMENT ON COLUMN PXI.PMX_PROM_CONFIG.RATE_MULTIPLIER IS 'Rate Multiplier';
COMMENT ON COLUMN PXI.PMX_PROM_CONFIG.CNDTN_TYPE_CODE IS 'Condition Type, e.g. ''A'' for Percentage, ''C'' for Dollar Amount';
COMMENT ON COLUMN PXI.PMX_PROM_CONFIG.PRICING_CNDTN_CODE IS 'Pricing Condition Code';
COMMENT ON COLUMN PXI.PMX_PROM_CONFIG.CNDTN_TABLE_REF IS 'Condition Table Reference';
COMMENT ON COLUMN PXI.PMX_PROM_CONFIG.CUST_DIV_CODE IS 'Customer Division Code';
COMMENT ON COLUMN PXI.PMX_PROM_CONFIG.ORDER_TYPE_CODE IS 'Order Type Code';
COMMENT ON COLUMN PXI.PMX_PROM_CONFIG.VALDTN_STATUS IS 'Validation Status';
COMMENT ON COLUMN PXI.PMX_PROM_CONFIG.PROM_CONFIG_LUPDP IS 'Last Updated Person';
COMMENT ON COLUMN PXI.PMX_PROM_CONFIG.PROM_CONFIG_LUPDT IS 'Last Updated Time';

-- Synonyms

create or replace public synonym pmx_prom_config for px.pmx_prom_config;

-- grants

grant select, insert, update, delete on pxi.pmx_prom_config to pxi_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

-- Initialise Table



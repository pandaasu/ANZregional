-- Promax Pricing Conditions Configuration Table.

  CREATE TABLE "PMX_PROM_CONFIG" 
   (	"CMPNY_CODE" VARCHAR2(3 BYTE) NOT NULL ENABLE, 
	"DIV_CODE" VARCHAR2(2 BYTE) NOT NULL ENABLE, 
	"FD_CUST_CODE" VARCHAR2(2 BYTE) NOT NULL ENABLE, 
	"CNDTN_FLAG" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
	"RATE_UNIT" VARCHAR2(5 BYTE), 
	"RATE_MULTIPLIER" NUMBER(4,0), 
	"CNDTN_TYPE_CODE" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
	"PRICING_CNDTN_CODE" VARCHAR2(4 BYTE) NOT NULL ENABLE, 
	"CNDTN_TABLE_REF" VARCHAR2(5 BYTE) NOT NULL ENABLE, 
	"CUST_DIV_CODE" VARCHAR2(2 BYTE) NOT NULL ENABLE, 
	"ORDER_TYPE_CODE" VARCHAR2(4 BYTE), 
	"VALDTN_STATUS" VARCHAR2(10 BYTE) NOT NULL ENABLE, 
	"PROM_CONFIG_LUPDP" VARCHAR2(8 BYTE) NOT NULL ENABLE, 
	"PROM_CONFIG_LUPDT" date not null enable, 
	 CONSTRAINT "PMX_PROM_CONFIG_PK" PRIMARY KEY ("CMPNY_CODE", "DIV_CODE", "FD_CUST_CODE", "PRICING_CNDTN_CODE"));

   COMMENT ON COLUMN "PMX_PROM_CONFIG"."CMPNY_CODE" IS 'Company Code';
   COMMENT ON COLUMN "PMX_PROM_CONFIG"."DIV_CODE" IS 'Division Code';
   COMMENT ON COLUMN "PMX_PROM_CONFIG"."FD_CUST_CODE" IS 'Fund Description Customer Code';
   COMMENT ON COLUMN "PMX_PROM_CONFIG"."CNDTN_FLAG" IS 'Condition Flag, e.g. ''T'' for Percentage, ''F'' for Dollar Amount';
   COMMENT ON COLUMN "PMX_PROM_CONFIG"."RATE_UNIT" IS 'Rate Unit';
   COMMENT ON COLUMN "PMX_PROM_CONFIG"."RATE_MULTIPLIER" IS 'Rate Multiplier';
   COMMENT ON COLUMN "PMX_PROM_CONFIG"."CNDTN_TYPE_CODE" IS 'Condition Type, e.g. ''A'' for Percentage, ''C'' for Dollar Amount';
   COMMENT ON COLUMN "PMX_PROM_CONFIG"."PRICING_CNDTN_CODE" IS 'Pricing Condition Code';
   COMMENT ON COLUMN "PMX_PROM_CONFIG"."CNDTN_TABLE_REF" IS 'Condition Table Reference';
   COMMENT ON COLUMN "PMX_PROM_CONFIG"."CUST_DIV_CODE" IS 'Customer Division Code';
   COMMENT ON COLUMN "PMX_PROM_CONFIG"."ORDER_TYPE_CODE" IS 'Order Type Code';
   COMMENT ON COLUMN "PMX_PROM_CONFIG"."VALDTN_STATUS" IS 'Validation Status';
   COMMENT ON COLUMN "PMX_PROM_CONFIG"."PROM_CONFIG_LUPDP" IS 'Last Updated Person';
   COMMENT ON COLUMN "PMX_PROM_CONFIG"."PROM_CONFIG_LUPDT" IS 'Last Updated Time';
   comment on table "PMX_PROM_CONFIG"  is 'Promax PX Promotion Configuration table';
   
   grant select, update, insert, delete on pmx_prom_config to pxi_app;
   
   create or replace public synonym pmx_prom_config for pxi.pmx_prom_config;
   
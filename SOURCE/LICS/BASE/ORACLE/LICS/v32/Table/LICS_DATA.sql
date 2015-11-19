--------------------------------------------------------
--  DDL for Table LICS_DATA
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_DATA" ("DAT_HEADER" NUMBER(15,0), "DAT_DTA_SEQ" NUMBER(9,0), "DAT_RECORD" VARCHAR2(4000 CHAR), "DAT_STATUS" VARCHAR2(1 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_DATA"."DAT_HEADER" IS 'Data - header sequence number';
   COMMENT ON COLUMN "LICS"."LICS_DATA"."DAT_DTA_SEQ" IS 'Data - data sequence number';
   COMMENT ON COLUMN "LICS"."LICS_DATA"."DAT_RECORD" IS 'Data - record string';
   COMMENT ON COLUMN "LICS"."LICS_DATA"."DAT_STATUS" IS 'Data - data status';
   COMMENT ON TABLE "LICS"."LICS_DATA"  IS 'LICS Data Table';

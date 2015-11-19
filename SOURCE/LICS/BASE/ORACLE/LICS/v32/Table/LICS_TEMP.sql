--------------------------------------------------------
--  DDL for Table LICS_TEMP
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "LICS"."LICS_TEMP" ("DAT_DTA_SEQ" NUMBER(9,0), "DAT_RECORD" VARCHAR2(4000 CHAR)) ON COMMIT PRESERVE ROWS ;

   COMMENT ON COLUMN "LICS"."LICS_TEMP"."DAT_DTA_SEQ" IS 'Data - data sequence number';
   COMMENT ON COLUMN "LICS"."LICS_TEMP"."DAT_RECORD" IS 'Data - record string';
   COMMENT ON TABLE "LICS"."LICS_TEMP"  IS 'LICS Temporary Table';

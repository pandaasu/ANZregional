--------------------------------------------------------
--  DDL for Table LICS_STR_EXE_PARAM
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_STR_EXE_PARAM" ("STP_EXE_SEQN" NUMBER, "STP_STR_CODE" VARCHAR2(32 CHAR), "STP_PAR_CODE" VARCHAR2(32 CHAR), "STP_PAR_TEXT" VARCHAR2(128 CHAR), "STP_PAR_VALUE" VARCHAR2(64 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_PARAM"."STP_EXE_SEQN" IS 'Stream parameter - execution sequence';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_PARAM"."STP_STR_CODE" IS 'Stream parameter - stream code';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_PARAM"."STP_PAR_CODE" IS 'Stream parameter - parameter code';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_PARAM"."STP_PAR_TEXT" IS 'Stream parameter - parameter text';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_PARAM"."STP_PAR_VALUE" IS 'Stream parameter - parameter value (fixed value or supplied)';
   COMMENT ON TABLE "LICS"."LICS_STR_EXE_PARAM"  IS 'LICS Stream Parameter Table';

--------------------------------------------------------
--  DDL for Table LICS_STR_EXE_HEADER
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_STR_EXE_HEADER" ("STH_EXE_SEQN" NUMBER, "STH_EXE_TEXT" VARCHAR2(128 CHAR), "STH_EXE_STATUS" VARCHAR2(10 CHAR), "STH_EXE_REQUEST" VARCHAR2(10 CHAR), "STH_EXE_LOAD" DATE, "STH_EXE_START" DATE, "STH_EXE_END" DATE, "STH_STR_CODE" VARCHAR2(32 CHAR), "STH_STR_TEXT" VARCHAR2(128 CHAR), "STH_STATUS" VARCHAR2(1 CHAR), "STH_UPD_USER" VARCHAR2(30 CHAR), "STH_UPD_TIME" DATE) ;

   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_HEADER"."STH_EXE_SEQN" IS 'Stream header - execution sequence';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_HEADER"."STH_EXE_TEXT" IS 'Stream header - execution text';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_HEADER"."STH_EXE_STATUS" IS 'Stream header - execution status';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_HEADER"."STH_EXE_REQUEST" IS 'Stream header - execution request';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_HEADER"."STH_EXE_LOAD" IS 'Stream header - execution load time';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_HEADER"."STH_EXE_START" IS 'Stream header - execution start time';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_HEADER"."STH_EXE_END" IS 'Stream header - execution end time';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_HEADER"."STH_STR_CODE" IS 'Stream header - stream code';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_HEADER"."STH_STR_TEXT" IS 'Stream header - stream text';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_HEADER"."STH_STATUS" IS 'Stream header - stream status';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_HEADER"."STH_UPD_USER" IS 'Stream header - update user';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_HEADER"."STH_UPD_TIME" IS 'Stream header - update time';
   COMMENT ON TABLE "LICS"."LICS_STR_EXE_HEADER"  IS 'LICS Stream Execution Header Table';
  GRANT SELECT ON "LICS"."LICS_STR_EXE_HEADER" TO "LICS_EXEC";
  GRANT UPDATE ON "LICS"."LICS_STR_EXE_HEADER" TO "LICS_APP";
  GRANT SELECT ON "LICS"."LICS_STR_EXE_HEADER" TO "LICS_APP";
  GRANT INSERT ON "LICS"."LICS_STR_EXE_HEADER" TO "LICS_APP";
  GRANT DELETE ON "LICS"."LICS_STR_EXE_HEADER" TO "LICS_APP";

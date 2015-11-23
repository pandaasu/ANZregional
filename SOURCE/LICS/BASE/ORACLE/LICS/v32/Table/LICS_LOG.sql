--------------------------------------------------------
--  DDL for Table LICS_LOG
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_LOG" ("LOG_SEQUENCE" NUMBER(15,0), "LOG_TRACE" NUMBER(7,0), "LOG_TIME" DATE, "LOG_TEXT" VARCHAR2(4000 CHAR), "LOG_SEARCH" VARCHAR2(256 BYTE))  ENABLE ROW MOVEMENT ;

   COMMENT ON COLUMN "LICS"."LICS_LOG"."LOG_SEQUENCE" IS 'Log - log sequence number (sequence generated)';
   COMMENT ON COLUMN "LICS"."LICS_LOG"."LOG_TRACE" IS 'Log - log trace number (incremental)';
   COMMENT ON COLUMN "LICS"."LICS_LOG"."LOG_TIME" IS 'Log - log time';
   COMMENT ON COLUMN "LICS"."LICS_LOG"."LOG_TEXT" IS 'log - log text';
   COMMENT ON COLUMN "LICS"."LICS_LOG"."LOG_SEARCH" IS 'Log - log search';
   COMMENT ON TABLE "LICS"."LICS_LOG"  IS 'LICS Log Table';
  GRANT UPDATE ON "LICS"."LICS_LOG" TO "LICS_APP";
  GRANT SELECT ON "LICS"."LICS_LOG" TO "LICS_APP";
  GRANT INSERT ON "LICS"."LICS_LOG" TO "LICS_APP";
  GRANT DELETE ON "LICS"."LICS_LOG" TO "LICS_APP";

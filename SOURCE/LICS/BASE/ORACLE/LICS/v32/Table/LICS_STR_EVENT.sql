--------------------------------------------------------
--  DDL for Table LICS_STR_EVENT
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_STR_EVENT" ("STE_STR_CODE" VARCHAR2(32 CHAR), "STE_TSK_CODE" VARCHAR2(32 CHAR), "STE_EVT_CODE" VARCHAR2(32 CHAR), "STE_EVT_SEQN" NUMBER, "STE_EVT_TEXT" VARCHAR2(128 CHAR), "STE_EVT_LOCK" VARCHAR2(32 CHAR), "STE_EVT_PROC" VARCHAR2(512 CHAR), "STE_JOB_GROUP" VARCHAR2(10 CHAR), "STE_OPR_ALERT" VARCHAR2(256 CHAR), "STE_EMA_GROUP" VARCHAR2(64 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_STR_EVENT"."STE_STR_CODE" IS 'Stream event - stream code';
   COMMENT ON COLUMN "LICS"."LICS_STR_EVENT"."STE_TSK_CODE" IS 'Stream event - task code';
   COMMENT ON COLUMN "LICS"."LICS_STR_EVENT"."STE_EVT_CODE" IS 'Stream event - event code';
   COMMENT ON COLUMN "LICS"."LICS_STR_EVENT"."STE_EVT_SEQN" IS 'Stream event - event sequence';
   COMMENT ON COLUMN "LICS"."LICS_STR_EVENT"."STE_EVT_TEXT" IS 'Stream event - event text';
   COMMENT ON COLUMN "LICS"."LICS_STR_EVENT"."STE_EVT_LOCK" IS 'Stream event - event lock';
   COMMENT ON COLUMN "LICS"."LICS_STR_EVENT"."STE_EVT_PROC" IS 'Stream event - event procedure';
   COMMENT ON COLUMN "LICS"."LICS_STR_EVENT"."STE_JOB_GROUP" IS 'Stream event - job group';
   COMMENT ON COLUMN "LICS"."LICS_STR_EVENT"."STE_OPR_ALERT" IS 'Stream event - operator alert message';
   COMMENT ON COLUMN "LICS"."LICS_STR_EVENT"."STE_EMA_GROUP" IS 'Stream event - email group';
   COMMENT ON TABLE "LICS"."LICS_STR_EVENT"  IS 'LICS Stream Event Table';
  GRANT SELECT ON "LICS"."LICS_STR_EVENT" TO "LICS_EXEC";
  GRANT UPDATE ON "LICS"."LICS_STR_EVENT" TO "LICS_APP";
  GRANT SELECT ON "LICS"."LICS_STR_EVENT" TO "LICS_APP";
  GRANT INSERT ON "LICS"."LICS_STR_EVENT" TO "LICS_APP";
  GRANT DELETE ON "LICS"."LICS_STR_EVENT" TO "LICS_APP";

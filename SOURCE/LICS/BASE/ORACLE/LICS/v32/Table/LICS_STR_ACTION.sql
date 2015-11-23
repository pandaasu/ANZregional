--------------------------------------------------------
--  DDL for Table LICS_STR_ACTION
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_STR_ACTION" ("STA_STR_SEQN" NUMBER, "STA_TSK_SEQN" NUMBER, "STA_EVT_SEQN" NUMBER, "STA_STR_CODE" VARCHAR2(32 CHAR), "STA_STR_TEXT" VARCHAR2(128 CHAR), "STA_TSK_PCDE" VARCHAR2(32 CHAR), "STA_TSK_CODE" VARCHAR2(32 CHAR), "STA_TSK_TEXT" VARCHAR2(128 CHAR), "STA_EVT_CODE" VARCHAR2(32 CHAR), "STA_EVT_TEXT" VARCHAR2(128 CHAR), "STA_EVT_LOCK" VARCHAR2(32 CHAR), "STA_EVT_PROC" VARCHAR2(512 CHAR), "STA_JOB_GROUP" VARCHAR2(10 CHAR), "STA_OPR_ALERT" VARCHAR2(256 CHAR), "STA_EMA_GROUP" VARCHAR2(64 CHAR), "STA_TIMESTAMP" DATE, "STA_STATUS" VARCHAR2(10 CHAR), "STA_SELECTED" VARCHAR2(1 CHAR), "STA_COMPLETED" VARCHAR2(1 CHAR), "STA_FAILED" VARCHAR2(1 CHAR), "STA_MESSAGE" VARCHAR2(4000 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_STR_SEQN" IS 'Stream action - stream sequence';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_TSK_SEQN" IS 'Stream action - task sequence';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_EVT_SEQN" IS 'Stream action - event sequence';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_STR_CODE" IS 'Stream action - stream code';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_STR_TEXT" IS 'Stream action - stream text';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_TSK_PCDE" IS 'Stream action - task parent';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_TSK_CODE" IS 'Stream action - task code';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_TSK_TEXT" IS 'Stream action - task text';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_EVT_CODE" IS 'Stream action - event code';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_EVT_TEXT" IS 'Stream action - event text';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_EVT_LOCK" IS 'Stream action - event lock';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_EVT_PROC" IS 'Stream action - event procedure';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_JOB_GROUP" IS 'Stream action - job group';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_OPR_ALERT" IS 'Stream action - operator alert message';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_EMA_GROUP" IS 'Stream action - email group';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_TIMESTAMP" IS 'Stream action - creation time';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_STATUS" IS 'Stream action - status';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_SELECTED" IS 'Stream action - status - selected';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_COMPLETED" IS 'Stream action - status - completed';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_FAILED" IS 'Stream action - status - failed';
   COMMENT ON COLUMN "LICS"."LICS_STR_ACTION"."STA_MESSAGE" IS 'Stream action - message';
   COMMENT ON TABLE "LICS"."LICS_STR_ACTION"  IS 'LICS Stream Action Table';
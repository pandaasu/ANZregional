--------------------------------------------------------
--  DDL for Table LICS_STR_EXE_TASK
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_STR_EXE_TASK" ("STT_EXE_SEQN" NUMBER, "STT_EXE_STATUS" VARCHAR2(10 CHAR), "STT_EXE_START" DATE, "STT_EXE_END" DATE, "STT_STR_CODE" VARCHAR2(32 CHAR), "STT_TSK_CODE" VARCHAR2(32 CHAR), "STT_TSK_PCDE" VARCHAR2(32 CHAR), "STT_TSK_SEQN" NUMBER, "STT_TSK_TEXT" VARCHAR2(128 CHAR), "STT_TSK_TYPE" VARCHAR2(10 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_TASK"."STT_EXE_SEQN" IS 'Stream task - execution sequence';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_TASK"."STT_EXE_STATUS" IS 'Stream task - execution status';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_TASK"."STT_EXE_START" IS 'Stream event - execution start time';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_TASK"."STT_EXE_END" IS 'Stream event - execution end time';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_TASK"."STT_STR_CODE" IS 'Stream task - stream code';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_TASK"."STT_TSK_CODE" IS 'Stream task - task code';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_TASK"."STT_TSK_PCDE" IS 'Stream task - task parent';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_TASK"."STT_TSK_SEQN" IS 'Stream task - task sequence';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_TASK"."STT_TSK_TEXT" IS 'Stream task - task text';
   COMMENT ON COLUMN "LICS"."LICS_STR_EXE_TASK"."STT_TSK_TYPE" IS 'Stream task - task type (*EXEC=Execution or *GATE=Gate)';
   COMMENT ON TABLE "LICS"."LICS_STR_EXE_TASK"  IS 'LICS Stream Execution Task Table';

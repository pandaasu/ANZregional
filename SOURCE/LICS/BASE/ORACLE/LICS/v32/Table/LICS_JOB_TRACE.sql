--------------------------------------------------------
--  DDL for Table LICS_JOB_TRACE
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_JOB_TRACE" ("JOT_EXECUTION" NUMBER(15,0), "JOT_JOB" VARCHAR2(32 CHAR), "JOT_TYPE" VARCHAR2(10 CHAR), "JOT_INT_GROUP" VARCHAR2(10 CHAR), "JOT_PROCEDURE" VARCHAR2(256 CHAR), "JOT_USER" VARCHAR2(30 CHAR), "JOT_STR_TIME" DATE, "JOT_END_TIME" DATE, "JOT_STATUS" VARCHAR2(1 CHAR), "JOT_MESSAGE" VARCHAR2(4000 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_JOB_TRACE"."JOT_EXECUTION" IS 'Job trace - job execution number';
   COMMENT ON COLUMN "LICS"."LICS_JOB_TRACE"."JOT_JOB" IS 'Job trace - job identifier';
   COMMENT ON COLUMN "LICS"."LICS_JOB_TRACE"."JOT_TYPE" IS 'Job trace - job type';
   COMMENT ON COLUMN "LICS"."LICS_JOB_TRACE"."JOT_INT_GROUP" IS 'Job trace - interface group';
   COMMENT ON COLUMN "LICS"."LICS_JOB_TRACE"."JOT_PROCEDURE" IS 'Job trace - job procedure';
   COMMENT ON COLUMN "LICS"."LICS_JOB_TRACE"."JOT_USER" IS 'Job trace - user identifier';
   COMMENT ON COLUMN "LICS"."LICS_JOB_TRACE"."JOT_STR_TIME" IS 'Job trace - trace start time';
   COMMENT ON COLUMN "LICS"."LICS_JOB_TRACE"."JOT_END_TIME" IS 'Job trace - trace end time';
   COMMENT ON COLUMN "LICS"."LICS_JOB_TRACE"."JOT_STATUS" IS 'Job trace - job status';
   COMMENT ON COLUMN "LICS"."LICS_JOB_TRACE"."JOT_MESSAGE" IS 'Job trace - job message';
   COMMENT ON TABLE "LICS"."LICS_JOB_TRACE"  IS 'LICS Job Trace Table';

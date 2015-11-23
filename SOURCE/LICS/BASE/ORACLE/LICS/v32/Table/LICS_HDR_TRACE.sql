--------------------------------------------------------
--  DDL for Table LICS_HDR_TRACE
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_HDR_TRACE" ("HET_HEADER" NUMBER(15,0), "HET_HDR_TRACE" NUMBER(5,0), "HET_EXECUTION" NUMBER(15,0), "HET_USER" VARCHAR2(30 CHAR), "HET_STR_TIME" DATE, "HET_END_TIME" DATE, "HET_STATUS" VARCHAR2(1 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_HDR_TRACE"."HET_HEADER" IS 'Header trace - header sequence number';
   COMMENT ON COLUMN "LICS"."LICS_HDR_TRACE"."HET_HDR_TRACE" IS 'Header trace - trace sequence number';
   COMMENT ON COLUMN "LICS"."LICS_HDR_TRACE"."HET_EXECUTION" IS 'Header trace - job execution number';
   COMMENT ON COLUMN "LICS"."LICS_HDR_TRACE"."HET_USER" IS 'Header trace - creation user';
   COMMENT ON COLUMN "LICS"."LICS_HDR_TRACE"."HET_STR_TIME" IS 'Header trace - trace start time';
   COMMENT ON COLUMN "LICS"."LICS_HDR_TRACE"."HET_END_TIME" IS 'Header trace - trace end time';
   COMMENT ON COLUMN "LICS"."LICS_HDR_TRACE"."HET_STATUS" IS 'Header trace - trace status';
   COMMENT ON TABLE "LICS"."LICS_HDR_TRACE"  IS 'LICS Header Trace Table';
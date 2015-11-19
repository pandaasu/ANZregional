--------------------------------------------------------
--  DDL for Table LICS_EVENT
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_EVENT" ("EVE_SEQUENCE" NUMBER(15,0), "EVE_TIME" DATE, "EVE_RESULT" VARCHAR2(10 CHAR), "EVE_JOB" VARCHAR2(32 CHAR), "EVE_EXECUTION" NUMBER(15,0), "EVE_TYPE" VARCHAR2(10 CHAR), "EVE_GROUP" VARCHAR2(10 CHAR), "EVE_PROCEDURE" VARCHAR2(256 CHAR), "EVE_INTERFACE" VARCHAR2(32 CHAR), "EVE_HEADER" NUMBER(15,0), "EVE_HDR_TRACE" NUMBER(5,0), "EVE_MESSAGE" VARCHAR2(4000 CHAR), "EVE_OPR_ALERT" VARCHAR2(256 CHAR), "EVE_EMA_GROUP" VARCHAR2(64 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_EVENT"."EVE_SEQUENCE" IS 'Event - event sequence number (sequence generated)';
   COMMENT ON COLUMN "LICS"."LICS_EVENT"."EVE_TIME" IS 'Event - event time';
   COMMENT ON COLUMN "LICS"."LICS_EVENT"."EVE_RESULT" IS 'Event - event result';
   COMMENT ON COLUMN "LICS"."LICS_EVENT"."EVE_JOB" IS 'Event - job identifier';
   COMMENT ON COLUMN "LICS"."LICS_EVENT"."EVE_EXECUTION" IS 'Event - job execution number';
   COMMENT ON COLUMN "LICS"."LICS_EVENT"."EVE_TYPE" IS 'Event - job type';
   COMMENT ON COLUMN "LICS"."LICS_EVENT"."EVE_GROUP" IS 'Event - interface group';
   COMMENT ON COLUMN "LICS"."LICS_EVENT"."EVE_PROCEDURE" IS 'Event - job procedure';
   COMMENT ON COLUMN "LICS"."LICS_EVENT"."EVE_INTERFACE" IS 'Event - interface identifier';
   COMMENT ON COLUMN "LICS"."LICS_EVENT"."EVE_HEADER" IS 'Event - header sequence number';
   COMMENT ON COLUMN "LICS"."LICS_EVENT"."EVE_HDR_TRACE" IS 'Event - header trace sequence number';
   COMMENT ON COLUMN "LICS"."LICS_EVENT"."EVE_MESSAGE" IS 'Event - message text';
   COMMENT ON COLUMN "LICS"."LICS_EVENT"."EVE_OPR_ALERT" IS 'Event - operator alert message';
   COMMENT ON COLUMN "LICS"."LICS_EVENT"."EVE_EMA_GROUP" IS 'Event - email group';
   COMMENT ON TABLE "LICS"."LICS_EVENT"  IS 'LICS Event Table';

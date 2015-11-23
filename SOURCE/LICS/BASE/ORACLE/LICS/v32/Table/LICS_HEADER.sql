--------------------------------------------------------
--  DDL for Table LICS_HEADER
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_HEADER" ("HEA_HEADER" NUMBER(15,0), "HEA_INTERFACE" VARCHAR2(32 CHAR), "HEA_TRC_COUNT" NUMBER(5,0), "HEA_CRT_USER" VARCHAR2(30 CHAR), "HEA_CRT_TIME" DATE, "HEA_FIL_NAME" VARCHAR2(64 CHAR), "HEA_MSG_NAME" VARCHAR2(64 CHAR), "HEA_STATUS" VARCHAR2(1 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_HEADER"."HEA_HEADER" IS 'Header - header sequence number (sequence generated)';
   COMMENT ON COLUMN "LICS"."LICS_HEADER"."HEA_INTERFACE" IS 'Header - interface identifier';
   COMMENT ON COLUMN "LICS"."LICS_HEADER"."HEA_TRC_COUNT" IS 'Header - trace count';
   COMMENT ON COLUMN "LICS"."LICS_HEADER"."HEA_CRT_USER" IS 'Header - creation user';
   COMMENT ON COLUMN "LICS"."LICS_HEADER"."HEA_CRT_TIME" IS 'Header - creation time';
   COMMENT ON COLUMN "LICS"."LICS_HEADER"."HEA_FIL_NAME" IS 'Header - file name';
   COMMENT ON COLUMN "LICS"."LICS_HEADER"."HEA_MSG_NAME" IS 'Header - message name';
   COMMENT ON COLUMN "LICS"."LICS_HEADER"."HEA_STATUS" IS 'Header - header status';
   COMMENT ON TABLE "LICS"."LICS_HEADER"  IS 'LICS Header Table';
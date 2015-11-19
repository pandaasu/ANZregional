--------------------------------------------------------
--  DDL for Table LICS_FILE
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_FILE" ("FIL_FILE" NUMBER(15,0), "FIL_PATH" VARCHAR2(64 CHAR), "FIL_NAME" VARCHAR2(256 CHAR), "FIL_STATUS" VARCHAR2(1 CHAR), "FIL_CRT_USER" VARCHAR2(30 CHAR), "FIL_CRT_TIME" DATE, "FIL_MESSAGE" VARCHAR2(2000 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_FILE"."FIL_FILE" IS 'File - file sequence number (sequence generated)';
   COMMENT ON COLUMN "LICS"."LICS_FILE"."FIL_PATH" IS 'File - file path';
   COMMENT ON COLUMN "LICS"."LICS_FILE"."FIL_NAME" IS 'File - file name';
   COMMENT ON COLUMN "LICS"."LICS_FILE"."FIL_STATUS" IS 'File - file status';
   COMMENT ON COLUMN "LICS"."LICS_FILE"."FIL_CRT_USER" IS 'File - creation user';
   COMMENT ON COLUMN "LICS"."LICS_FILE"."FIL_CRT_TIME" IS 'File - creation time';
   COMMENT ON COLUMN "LICS"."LICS_FILE"."FIL_MESSAGE" IS 'File - file message';
   COMMENT ON TABLE "LICS"."LICS_FILE"  IS 'LICS File Table';

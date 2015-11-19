--------------------------------------------------------
--  DDL for Table LICS_HDR_MESSAGE
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_HDR_MESSAGE" ("HEM_HEADER" NUMBER(15,0), "HEM_HDR_TRACE" NUMBER(5,0), "HEM_MSG_SEQ" NUMBER(5,0), "HEM_TEXT" VARCHAR2(4000 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_HDR_MESSAGE"."HEM_HEADER" IS 'Header message - header sequence number';
   COMMENT ON COLUMN "LICS"."LICS_HDR_MESSAGE"."HEM_HDR_TRACE" IS 'Header message - trace sequence number';
   COMMENT ON COLUMN "LICS"."LICS_HDR_MESSAGE"."HEM_MSG_SEQ" IS 'Header message - message sequence number';
   COMMENT ON COLUMN "LICS"."LICS_HDR_MESSAGE"."HEM_TEXT" IS 'Header message - message text';
   COMMENT ON TABLE "LICS"."LICS_HDR_MESSAGE"  IS 'LICS Header Message Table';

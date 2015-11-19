--------------------------------------------------------
--  DDL for Table LICS_DTA_MESSAGE
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_DTA_MESSAGE" ("DAM_HEADER" NUMBER(15,0), "DAM_HDR_TRACE" NUMBER(5,0), "DAM_DTA_SEQ" NUMBER(9,0), "DAM_MSG_SEQ" NUMBER(5,0), "DAM_TEXT" VARCHAR2(4000 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_DTA_MESSAGE"."DAM_HEADER" IS 'Data message - header sequence number';
   COMMENT ON COLUMN "LICS"."LICS_DTA_MESSAGE"."DAM_HDR_TRACE" IS 'Data message - header trace sequence number';
   COMMENT ON COLUMN "LICS"."LICS_DTA_MESSAGE"."DAM_DTA_SEQ" IS 'Data message - data sequence number';
   COMMENT ON COLUMN "LICS"."LICS_DTA_MESSAGE"."DAM_MSG_SEQ" IS 'Data message - message sequence number';
   COMMENT ON COLUMN "LICS"."LICS_DTA_MESSAGE"."DAM_TEXT" IS 'Data message - message text';
   COMMENT ON TABLE "LICS"."LICS_DTA_MESSAGE"  IS 'LICS Data Message Table';

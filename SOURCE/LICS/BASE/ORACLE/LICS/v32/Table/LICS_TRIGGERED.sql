--------------------------------------------------------
--  DDL for Table LICS_TRIGGERED
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_TRIGGERED" ("TRI_SEQUENCE" NUMBER(15,0), "TRI_GROUP" VARCHAR2(10 CHAR), "TRI_FUNCTION" VARCHAR2(128 CHAR), "TRI_PROCEDURE" VARCHAR2(512 CHAR), "TRI_TIMESTAMP" DATE, "TRI_OPR_ALERT" VARCHAR2(256 CHAR), "TRI_EMA_GROUP" VARCHAR2(64 CHAR), "TRI_LOG_DATA" VARCHAR2(512 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_TRIGGERED"."TRI_SEQUENCE" IS 'Triggered - trigger sequence number (sequence generated)';
   COMMENT ON COLUMN "LICS"."LICS_TRIGGERED"."TRI_GROUP" IS 'Triggered - trigger group';
   COMMENT ON COLUMN "LICS"."LICS_TRIGGERED"."TRI_FUNCTION" IS 'Triggered - trigger function';
   COMMENT ON COLUMN "LICS"."LICS_TRIGGERED"."TRI_PROCEDURE" IS 'Triggered - execution procedure';
   COMMENT ON COLUMN "LICS"."LICS_TRIGGERED"."TRI_TIMESTAMP" IS 'Triggered - creation time';
   COMMENT ON COLUMN "LICS"."LICS_TRIGGERED"."TRI_OPR_ALERT" IS 'Triggered - operator alert message';
   COMMENT ON COLUMN "LICS"."LICS_TRIGGERED"."TRI_EMA_GROUP" IS 'Triggered - email group';
   COMMENT ON COLUMN "LICS"."LICS_TRIGGERED"."TRI_LOG_DATA" IS 'Triggered - log data';
   COMMENT ON TABLE "LICS"."LICS_TRIGGERED"  IS 'LICS Triggered Table';
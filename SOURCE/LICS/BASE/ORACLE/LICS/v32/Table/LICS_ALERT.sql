--------------------------------------------------------
--  DDL for Table LICS_ALERT
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_ALERT" ("ALE_SRCH_TXT" VARCHAR2(100 BYTE), "ALE_MSG_TXT" VARCHAR2(200 BYTE)) ;

   COMMENT ON COLUMN "LICS"."LICS_ALERT"."ALE_SRCH_TXT" IS 'Alerting - search string';
   COMMENT ON COLUMN "LICS"."LICS_ALERT"."ALE_MSG_TXT" IS 'Alerting - message text';

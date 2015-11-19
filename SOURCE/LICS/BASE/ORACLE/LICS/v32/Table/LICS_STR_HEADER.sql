--------------------------------------------------------
--  DDL for Table LICS_STR_HEADER
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_STR_HEADER" ("STH_STR_CODE" VARCHAR2(32 CHAR), "STH_STR_TEXT" VARCHAR2(128 CHAR), "STH_STATUS" VARCHAR2(1 CHAR), "STH_UPD_USER" VARCHAR2(30 CHAR), "STH_UPD_TIME" DATE) ;

   COMMENT ON COLUMN "LICS"."LICS_STR_HEADER"."STH_STR_CODE" IS 'Stream header - stream code';
   COMMENT ON COLUMN "LICS"."LICS_STR_HEADER"."STH_STR_TEXT" IS 'Stream header - stream text';
   COMMENT ON COLUMN "LICS"."LICS_STR_HEADER"."STH_STATUS" IS 'Stream header - stream status';
   COMMENT ON COLUMN "LICS"."LICS_STR_HEADER"."STH_UPD_USER" IS 'Stream header - update user';
   COMMENT ON COLUMN "LICS"."LICS_STR_HEADER"."STH_UPD_TIME" IS 'Stream header - update time';
   COMMENT ON TABLE "LICS"."LICS_STR_HEADER"  IS 'LICS Stream Header Table';

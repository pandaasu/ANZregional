--------------------------------------------------------
--  DDL for Table LICS_SETTING
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_SETTING" ("SET_GROUP" VARCHAR2(32 CHAR), "SET_CODE" VARCHAR2(32 CHAR), "SET_VALUE" VARCHAR2(256 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_SETTING"."SET_GROUP" IS 'Setting - group';
   COMMENT ON COLUMN "LICS"."LICS_SETTING"."SET_CODE" IS 'Setting - code';
   COMMENT ON COLUMN "LICS"."LICS_SETTING"."SET_VALUE" IS 'Setting - value';
   COMMENT ON TABLE "LICS"."LICS_SETTING"  IS 'LICS Setting Table';

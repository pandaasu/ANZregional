--------------------------------------------------------
--  DDL for Table LICS_LOCK
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_LOCK" ("LOC_LOCK" VARCHAR2(128 BYTE), "LOC_SESSION" VARCHAR2(24 BYTE), "LOC_USER" VARCHAR2(30 BYTE), "LOC_TIME" DATE) ;

   COMMENT ON COLUMN "LICS"."LICS_LOCK"."LOC_LOCK" IS 'Lock - lock name';
   COMMENT ON COLUMN "LICS"."LICS_LOCK"."LOC_SESSION" IS 'Lock - lock session';
   COMMENT ON COLUMN "LICS"."LICS_LOCK"."LOC_USER" IS 'Lock - lock user';
   COMMENT ON COLUMN "LICS"."LICS_LOCK"."LOC_TIME" IS 'Lock - lock time';
   COMMENT ON TABLE "LICS"."LICS_LOCK"  IS 'LICS Lock Table';

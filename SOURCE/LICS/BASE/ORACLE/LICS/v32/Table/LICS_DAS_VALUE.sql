--------------------------------------------------------
--  DDL for Table LICS_DAS_VALUE
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_DAS_VALUE" ("DSV_SYSTEM" VARCHAR2(32 CHAR), "DSV_GROUP" VARCHAR2(32 CHAR), "DSV_CODE" VARCHAR2(32 CHAR), "DSV_SEQUENCE" NUMBER, "DSV_VALUE" VARCHAR2(4000 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_DAS_VALUE"."DSV_SYSTEM" IS 'Datastore Value - system';
   COMMENT ON COLUMN "LICS"."LICS_DAS_VALUE"."DSV_GROUP" IS 'Datastore Value - group';
   COMMENT ON COLUMN "LICS"."LICS_DAS_VALUE"."DSV_CODE" IS 'Datastore Value - code';
   COMMENT ON COLUMN "LICS"."LICS_DAS_VALUE"."DSV_SEQUENCE" IS 'Datastore Value - sequence';
   COMMENT ON COLUMN "LICS"."LICS_DAS_VALUE"."DSV_VALUE" IS 'Datastore Value - value';
   COMMENT ON TABLE "LICS"."LICS_DAS_VALUE"  IS 'LICS Datastore Value Table';
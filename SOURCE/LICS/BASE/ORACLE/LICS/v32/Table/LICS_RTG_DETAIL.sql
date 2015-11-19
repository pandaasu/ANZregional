--------------------------------------------------------
--  DDL for Table LICS_RTG_DETAIL
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_RTG_DETAIL" ("RDE_SOURCE" VARCHAR2(32 CHAR), "RDE_PREFIX" VARCHAR2(32 CHAR), "RDE_INTERFACE" VARCHAR2(32 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_RTG_DETAIL"."RDE_SOURCE" IS 'Routing detail - source code';
   COMMENT ON COLUMN "LICS"."LICS_RTG_DETAIL"."RDE_PREFIX" IS 'Routing detail - prefix';
   COMMENT ON COLUMN "LICS"."LICS_RTG_DETAIL"."RDE_INTERFACE" IS 'Routing detail - interface';
   COMMENT ON TABLE "LICS"."LICS_RTG_DETAIL"  IS 'LICS Routing Detail Table';

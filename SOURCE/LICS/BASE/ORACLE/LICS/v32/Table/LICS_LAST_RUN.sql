--------------------------------------------------------
--  DDL for Table LICS_LAST_RUN
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_LAST_RUN" ("LSR_IDENTIFIER" VARCHAR2(32 CHAR), "LSR_DATE" DATE) ;

   COMMENT ON COLUMN "LICS"."LICS_LAST_RUN"."LSR_IDENTIFIER" IS 'Last Run - item identifier';
   COMMENT ON COLUMN "LICS"."LICS_LAST_RUN"."LSR_DATE" IS 'Last Run - date of last successful run';
   COMMENT ON TABLE "LICS"."LICS_LAST_RUN"  IS 'LICS Last Run Table';

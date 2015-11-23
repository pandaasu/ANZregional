--------------------------------------------------------
--  DDL for Table LICS_PRO_TRACE
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_PRO_TRACE" ("PRT_PROCESS" VARCHAR2(32 CHAR), "PRT_DATE" VARCHAR2(8 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_PRO_TRACE"."PRT_PROCESS" IS 'Processing Trace - process code';
   COMMENT ON COLUMN "LICS"."LICS_PRO_TRACE"."PRT_DATE" IS 'Processing Trace - process date (YYYYMMDD)';
   COMMENT ON TABLE "LICS"."LICS_PRO_TRACE"  IS 'LICS Processing Trace Table';
  GRANT UPDATE ON "LICS"."LICS_PRO_TRACE" TO "LICS_APP";
  GRANT SELECT ON "LICS"."LICS_PRO_TRACE" TO "LICS_APP";
  GRANT INSERT ON "LICS"."LICS_PRO_TRACE" TO "LICS_APP";
  GRANT DELETE ON "LICS"."LICS_PRO_TRACE" TO "LICS_APP";

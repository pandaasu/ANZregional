--------------------------------------------------------
--  DDL for Table LICS_PRO_PROCESS
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_PRO_PROCESS" ("PRP_PROCESS" VARCHAR2(32 CHAR), "PRP_DESCRIPTION" VARCHAR2(128 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_PRO_PROCESS"."PRP_PROCESS" IS 'Processing Process - process code';
   COMMENT ON COLUMN "LICS"."LICS_PRO_PROCESS"."PRP_DESCRIPTION" IS 'Processing Process - process description';
   COMMENT ON TABLE "LICS"."LICS_PRO_PROCESS"  IS 'LICS Processing Process Table';
  GRANT UPDATE ON "LICS"."LICS_PRO_PROCESS" TO "LICS_APP";
  GRANT SELECT ON "LICS"."LICS_PRO_PROCESS" TO "LICS_APP";
  GRANT INSERT ON "LICS"."LICS_PRO_PROCESS" TO "LICS_APP";
  GRANT DELETE ON "LICS"."LICS_PRO_PROCESS" TO "LICS_APP";

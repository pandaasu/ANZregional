--------------------------------------------------------
--  DDL for Table LICS_PRO_CHECK
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_PRO_CHECK" ("PRC_GROUP" VARCHAR2(32 CHAR), "PRC_PROCESS" VARCHAR2(32 CHAR), "PRC_EXIST" VARCHAR2(1 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_PRO_CHECK"."PRC_GROUP" IS 'Processing Check - group code';
   COMMENT ON COLUMN "LICS"."LICS_PRO_CHECK"."PRC_PROCESS" IS 'Processing Check - process code';
   COMMENT ON COLUMN "LICS"."LICS_PRO_CHECK"."PRC_EXIST" IS 'Processing Check - exist test (Y/N)';
   COMMENT ON TABLE "LICS"."LICS_PRO_CHECK"  IS 'LICS Processing Check Table';
  GRANT UPDATE ON "LICS"."LICS_PRO_CHECK" TO "LICS_APP";
  GRANT SELECT ON "LICS"."LICS_PRO_CHECK" TO "LICS_APP";
  GRANT INSERT ON "LICS"."LICS_PRO_CHECK" TO "LICS_APP";
  GRANT DELETE ON "LICS"."LICS_PRO_CHECK" TO "LICS_APP";

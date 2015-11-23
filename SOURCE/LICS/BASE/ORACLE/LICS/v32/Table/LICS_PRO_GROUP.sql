--------------------------------------------------------
--  DDL for Table LICS_PRO_GROUP
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_PRO_GROUP" ("PRG_GROUP" VARCHAR2(32 CHAR), "PRG_DESCRIPTION" VARCHAR2(128 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_PRO_GROUP"."PRG_GROUP" IS 'Processing Group - group code';
   COMMENT ON COLUMN "LICS"."LICS_PRO_GROUP"."PRG_DESCRIPTION" IS 'Processing Group - group description';
   COMMENT ON TABLE "LICS"."LICS_PRO_GROUP"  IS 'LICS Processing Group Table';
  GRANT UPDATE ON "LICS"."LICS_PRO_GROUP" TO "LICS_APP";
  GRANT SELECT ON "LICS"."LICS_PRO_GROUP" TO "LICS_APP";
  GRANT INSERT ON "LICS"."LICS_PRO_GROUP" TO "LICS_APP";
  GRANT DELETE ON "LICS"."LICS_PRO_GROUP" TO "LICS_APP";

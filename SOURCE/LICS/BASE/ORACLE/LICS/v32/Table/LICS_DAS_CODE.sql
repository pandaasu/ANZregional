--------------------------------------------------------
--  DDL for Table LICS_DAS_CODE
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_DAS_CODE" ("DSC_SYSTEM" VARCHAR2(32 CHAR), "DSC_GROUP" VARCHAR2(32 CHAR), "DSC_CODE" VARCHAR2(32 CHAR), "DSC_DESCRIPTION" VARCHAR2(4000 CHAR), "DSC_VAL_TYPE" VARCHAR2(10 CHAR), "DSC_VAL_DATA" VARCHAR2(10 CHAR), "DSC_UPD_USER" VARCHAR2(30 CHAR), "DSC_UPD_DATE" DATE) ;

   COMMENT ON COLUMN "LICS"."LICS_DAS_CODE"."DSC_SYSTEM" IS 'Datastore Code - system';
   COMMENT ON COLUMN "LICS"."LICS_DAS_CODE"."DSC_GROUP" IS 'Datastore Code - group';
   COMMENT ON COLUMN "LICS"."LICS_DAS_CODE"."DSC_CODE" IS 'Datastore Code - code';
   COMMENT ON COLUMN "LICS"."LICS_DAS_CODE"."DSC_DESCRIPTION" IS 'Datastore Code - code description';
   COMMENT ON COLUMN "LICS"."LICS_DAS_CODE"."DSC_VAL_TYPE" IS 'Datastore Code - value type (*SINGLE,*LIST)';
   COMMENT ON COLUMN "LICS"."LICS_DAS_CODE"."DSC_VAL_DATA" IS 'Datastore Code - value data (*UPPER,*MIXED,*NUMBER,*DATE)';
   COMMENT ON COLUMN "LICS"."LICS_DAS_CODE"."DSC_UPD_USER" IS 'Datastore Code - update user';
   COMMENT ON COLUMN "LICS"."LICS_DAS_CODE"."DSC_UPD_DATE" IS 'Datastore Code - update date';
   COMMENT ON TABLE "LICS"."LICS_DAS_CODE"  IS 'LICS Datastore Code Table';
  GRANT UPDATE ON "LICS"."LICS_DAS_CODE" TO "LICS_APP";
  GRANT SELECT ON "LICS"."LICS_DAS_CODE" TO "LICS_APP";
  GRANT INSERT ON "LICS"."LICS_DAS_CODE" TO "LICS_APP";
  GRANT DELETE ON "LICS"."LICS_DAS_CODE" TO "LICS_APP";

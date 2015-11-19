--------------------------------------------------------
--  DDL for Table LICS_STR_DEPEND
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_STR_DEPEND" ("STD_STR_CODE" VARCHAR2(32 CHAR), "STD_TSK_CODE" VARCHAR2(32 CHAR), "STD_DEP_CODE" VARCHAR2(32 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_STR_DEPEND"."STD_STR_CODE" IS 'Stream dependent - stream code';
   COMMENT ON COLUMN "LICS"."LICS_STR_DEPEND"."STD_TSK_CODE" IS 'Stream dependent - task code';
   COMMENT ON COLUMN "LICS"."LICS_STR_DEPEND"."STD_DEP_CODE" IS 'Stream dependent - dependent code (execution task)';
   COMMENT ON TABLE "LICS"."LICS_STR_DEPEND"  IS 'LICS Stream Dependent Table';

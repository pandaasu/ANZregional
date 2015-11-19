--------------------------------------------------------
--  DDL for Table LICS_SEC_OPTION
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_SEC_OPTION" ("SEO_OPTION" VARCHAR2(32 CHAR), "SEO_DESCRIPTION" VARCHAR2(128 CHAR), "SEO_SCRIPT" VARCHAR2(256 CHAR), "SEO_STATUS" VARCHAR2(1 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_SEC_OPTION"."SEO_OPTION" IS 'Security Option - option code';
   COMMENT ON COLUMN "LICS"."LICS_SEC_OPTION"."SEO_DESCRIPTION" IS 'Security Option - option description';
   COMMENT ON COLUMN "LICS"."LICS_SEC_OPTION"."SEO_SCRIPT" IS 'Security Option - option script';
   COMMENT ON COLUMN "LICS"."LICS_SEC_OPTION"."SEO_STATUS" IS 'Security Option - option status';
   COMMENT ON TABLE "LICS"."LICS_SEC_OPTION"  IS 'LICS Security Option Table';

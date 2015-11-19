--------------------------------------------------------
--  DDL for Table LICS_SEC_LINK
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_SEC_LINK" ("SEL_MENU" VARCHAR2(32 CHAR), "SEL_SEQUENCE" NUMBER, "SEL_TYPE" VARCHAR2(4 CHAR), "SEL_LINK" VARCHAR2(32 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_SEC_LINK"."SEL_MENU" IS 'Security Link - menu code';
   COMMENT ON COLUMN "LICS"."LICS_SEC_LINK"."SEL_SEQUENCE" IS 'Security Link - link sequence';
   COMMENT ON COLUMN "LICS"."LICS_SEC_LINK"."SEL_TYPE" IS 'Security Link - link type (*MNU, *OPT)';
   COMMENT ON COLUMN "LICS"."LICS_SEC_LINK"."SEL_LINK" IS 'Security Link - link code';
   COMMENT ON TABLE "LICS"."LICS_SEC_LINK"  IS 'LICS Security Link Table';

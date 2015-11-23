--------------------------------------------------------
--  DDL for Table LICS_SEC_MENU
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_SEC_MENU" ("SEM_MENU" VARCHAR2(32 CHAR), "SEM_DESCRIPTION" VARCHAR2(128 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_SEC_MENU"."SEM_MENU" IS 'Security Menu - menu code';
   COMMENT ON COLUMN "LICS"."LICS_SEC_MENU"."SEM_DESCRIPTION" IS 'Security Menu - menu description';
   COMMENT ON TABLE "LICS"."LICS_SEC_MENU"  IS 'LICS Security Menu Table';
  GRANT UPDATE ON "LICS"."LICS_SEC_MENU" TO "LICS_APP";
  GRANT SELECT ON "LICS"."LICS_SEC_MENU" TO "LICS_APP";
  GRANT INSERT ON "LICS"."LICS_SEC_MENU" TO "LICS_APP";
  GRANT DELETE ON "LICS"."LICS_SEC_MENU" TO "LICS_APP";

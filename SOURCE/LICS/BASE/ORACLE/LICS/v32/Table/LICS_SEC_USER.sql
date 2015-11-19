--------------------------------------------------------
--  DDL for Table LICS_SEC_USER
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_SEC_USER" ("SEU_USER" VARCHAR2(32 CHAR), "SEU_DESCRIPTION" VARCHAR2(128 CHAR), "SEU_MENU" VARCHAR2(32 CHAR), "SEU_STATUS" VARCHAR2(1 CHAR), "SEU_USER_LDPDT" DATE, "SEU_USER_LDPDP" VARCHAR2(72 BYTE)) ;

   COMMENT ON COLUMN "LICS"."LICS_SEC_USER"."SEU_USER" IS 'Security User - user identifier';
   COMMENT ON COLUMN "LICS"."LICS_SEC_USER"."SEU_DESCRIPTION" IS 'Security User - user description';
   COMMENT ON COLUMN "LICS"."LICS_SEC_USER"."SEU_MENU" IS 'Security User - user menu';
   COMMENT ON COLUMN "LICS"."LICS_SEC_USER"."SEU_STATUS" IS 'Security User - user status';
   COMMENT ON TABLE "LICS"."LICS_SEC_USER"  IS 'LICS Security User Table';

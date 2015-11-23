--------------------------------------------------------
--  DDL for Table LICS_SEC_INTERFACE
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_SEC_INTERFACE" ("SEI_INTERFACE" VARCHAR2(128 CHAR), "SEI_USER" VARCHAR2(32 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_SEC_INTERFACE"."SEI_INTERFACE" IS 'Security Interface - Interface identifier';
   COMMENT ON COLUMN "LICS"."LICS_SEC_INTERFACE"."SEI_USER" IS 'Security Interface - User identifier';
   COMMENT ON TABLE "LICS"."LICS_SEC_INTERFACE"  IS 'LICS Security Interface Table';
--------------------------------------------------------
--  DDL for Table LICS_INT_REFERENCE
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_INT_REFERENCE" ("INR_INTERFACE" VARCHAR2(32 CHAR), "INR_REFERENCE" VARCHAR2(64 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_INT_REFERENCE"."INR_INTERFACE" IS 'Interface reference - interface identifier';
   COMMENT ON COLUMN "LICS"."LICS_INT_REFERENCE"."INR_REFERENCE" IS 'Interface reference - reference tag';
   COMMENT ON TABLE "LICS"."LICS_INT_REFERENCE"  IS 'LICS Interface Reference Table';

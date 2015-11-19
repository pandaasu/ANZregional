--------------------------------------------------------
--  DDL for Table LICS_GROUP
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_GROUP" ("GRO_GROUP" VARCHAR2(32 CHAR), "GRO_DESCRIPTION" VARCHAR2(128 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_GROUP"."GRO_GROUP" IS 'Group - group identifier';
   COMMENT ON COLUMN "LICS"."LICS_GROUP"."GRO_DESCRIPTION" IS 'Group - group description';
   COMMENT ON TABLE "LICS"."LICS_GROUP"  IS 'LICS Group Table';

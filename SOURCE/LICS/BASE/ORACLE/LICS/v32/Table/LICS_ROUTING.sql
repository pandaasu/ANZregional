--------------------------------------------------------
--  DDL for Table LICS_ROUTING
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_ROUTING" ("ROU_SOURCE" VARCHAR2(32 CHAR), "ROU_DESCRIPTION" VARCHAR2(128 CHAR), "ROU_PRE_LENGTH" NUMBER(2,0)) ;

   COMMENT ON COLUMN "LICS"."LICS_ROUTING"."ROU_SOURCE" IS 'Routing - source code';
   COMMENT ON COLUMN "LICS"."LICS_ROUTING"."ROU_DESCRIPTION" IS 'Routing - source description';
   COMMENT ON COLUMN "LICS"."LICS_ROUTING"."ROU_PRE_LENGTH" IS 'Routing - prefix length';
   COMMENT ON TABLE "LICS"."LICS_ROUTING"  IS 'LICS Routing Table';

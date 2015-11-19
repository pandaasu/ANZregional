--------------------------------------------------------
--  DDL for Table LICS_GRP_INTERFACE
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_GRP_INTERFACE" ("GRI_GROUP" VARCHAR2(32 CHAR), "GRI_INTERFACE" VARCHAR2(32 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_GRP_INTERFACE"."GRI_GROUP" IS 'Group Interface - group identifier';
   COMMENT ON COLUMN "LICS"."LICS_GRP_INTERFACE"."GRI_INTERFACE" IS 'Group Interface - interface identifier';
   COMMENT ON TABLE "LICS"."LICS_GRP_INTERFACE"  IS 'LICS Group Interface Table';

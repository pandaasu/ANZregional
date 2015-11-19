--------------------------------------------------------
--  DDL for Table LICS_DAS_GROUP
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_DAS_GROUP" ("DSG_SYSTEM" VARCHAR2(32 CHAR), "DSG_GROUP" VARCHAR2(32 CHAR), "DSG_DESCRIPTION" VARCHAR2(128 CHAR), "DSG_UPD_USER" VARCHAR2(30 CHAR), "DSG_UPD_DATE" DATE) ;

   COMMENT ON COLUMN "LICS"."LICS_DAS_GROUP"."DSG_SYSTEM" IS 'Datastore Group - system';
   COMMENT ON COLUMN "LICS"."LICS_DAS_GROUP"."DSG_GROUP" IS 'Datastore Group - group';
   COMMENT ON COLUMN "LICS"."LICS_DAS_GROUP"."DSG_DESCRIPTION" IS 'Datastore Group - group description';
   COMMENT ON COLUMN "LICS"."LICS_DAS_GROUP"."DSG_UPD_USER" IS 'Datastore Group - update user';
   COMMENT ON COLUMN "LICS"."LICS_DAS_GROUP"."DSG_UPD_DATE" IS 'Datastore Group - update date';
   COMMENT ON TABLE "LICS"."LICS_DAS_GROUP"  IS 'LICS Datastore Group Table';

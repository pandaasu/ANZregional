--------------------------------------------------------
--  DDL for Table LICS_DAS_SYSTEM
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_DAS_SYSTEM" ("DSS_SYSTEM" VARCHAR2(32 CHAR), "DSS_DESCRIPTION" VARCHAR2(128 CHAR), "DSS_UPD_USER" VARCHAR2(30 CHAR), "DSS_UPD_DATE" DATE) ;

   COMMENT ON COLUMN "LICS"."LICS_DAS_SYSTEM"."DSS_SYSTEM" IS 'Datastore System - system';
   COMMENT ON COLUMN "LICS"."LICS_DAS_SYSTEM"."DSS_DESCRIPTION" IS 'Datastore System - system description';
   COMMENT ON COLUMN "LICS"."LICS_DAS_SYSTEM"."DSS_UPD_USER" IS 'Datastore System - update user';
   COMMENT ON COLUMN "LICS"."LICS_DAS_SYSTEM"."DSS_UPD_DATE" IS 'Datastore System - update date';
   COMMENT ON TABLE "LICS"."LICS_DAS_SYSTEM"  IS 'LICS Datastore System Table';

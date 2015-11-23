--------------------------------------------------------
--  DDL for Table LICS_HDR_SEARCH
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_HDR_SEARCH" ("HES_HEADER" NUMBER(15,0), "HES_SEA_TAG" VARCHAR2(64 CHAR), "HES_SEA_VALUE" VARCHAR2(128 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_HDR_SEARCH"."HES_HEADER" IS 'Header search - header sequence number';
   COMMENT ON COLUMN "LICS"."LICS_HDR_SEARCH"."HES_SEA_TAG" IS 'Header search - search tag';
   COMMENT ON COLUMN "LICS"."LICS_HDR_SEARCH"."HES_SEA_VALUE" IS 'Header search - search value';
   COMMENT ON TABLE "LICS"."LICS_HDR_SEARCH"  IS 'LICS Header Search Table';
  GRANT UPDATE ON "LICS"."LICS_HDR_SEARCH" TO "LICS_APP";
  GRANT SELECT ON "LICS"."LICS_HDR_SEARCH" TO "LICS_APP";
  GRANT INSERT ON "LICS"."LICS_HDR_SEARCH" TO "LICS_APP";
  GRANT DELETE ON "LICS"."LICS_HDR_SEARCH" TO "LICS_APP";

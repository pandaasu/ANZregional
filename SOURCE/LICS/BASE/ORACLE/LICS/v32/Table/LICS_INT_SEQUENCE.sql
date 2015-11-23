--------------------------------------------------------
--  DDL for Table LICS_INT_SEQUENCE
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_INT_SEQUENCE" ("INS_INTERFACE" VARCHAR2(32 CHAR), "INS_SEQUENCE" NUMBER(15,0)) ;

   COMMENT ON COLUMN "LICS"."LICS_INT_SEQUENCE"."INS_INTERFACE" IS 'Interface sequence - interface identifier';
   COMMENT ON COLUMN "LICS"."LICS_INT_SEQUENCE"."INS_SEQUENCE" IS 'Interface sequence - sequence number';
   COMMENT ON TABLE "LICS"."LICS_INT_SEQUENCE"  IS 'LICS Interface Sequence Table';
  GRANT UPDATE ON "LICS"."LICS_INT_SEQUENCE" TO "LICS_APP";
  GRANT SELECT ON "LICS"."LICS_INT_SEQUENCE" TO "LICS_APP";
  GRANT INSERT ON "LICS"."LICS_INT_SEQUENCE" TO "LICS_APP";
  GRANT DELETE ON "LICS"."LICS_INT_SEQUENCE" TO "LICS_APP";

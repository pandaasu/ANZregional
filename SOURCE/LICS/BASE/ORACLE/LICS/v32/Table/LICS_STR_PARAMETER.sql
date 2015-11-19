--------------------------------------------------------
--  DDL for Table LICS_STR_PARAMETER
--------------------------------------------------------

  CREATE TABLE "LICS"."LICS_STR_PARAMETER" ("STP_STR_SEQN" NUMBER, "STP_PAR_CODE" VARCHAR2(32 CHAR), "STP_PAR_VALUE" VARCHAR2(4000 CHAR)) ;

   COMMENT ON COLUMN "LICS"."LICS_STR_PARAMETER"."STP_STR_SEQN" IS 'Stream parameter - stream sequence';
   COMMENT ON COLUMN "LICS"."LICS_STR_PARAMETER"."STP_PAR_CODE" IS 'Stream parameter - parameter code';
   COMMENT ON COLUMN "LICS"."LICS_STR_PARAMETER"."STP_PAR_VALUE" IS 'Stream parameter - parameter value';
   COMMENT ON TABLE "LICS"."LICS_STR_PARAMETER"  IS 'LICS Stream Parameter Table';

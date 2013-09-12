--------------------------------------------------------
--  File created - Friday-September-13-2013   
--------------------------------------------------------
DROP TABLE "FFLU"."FFLU_LOAD_DATA";
DROP TABLE "FFLU"."FFLU_LOAD_HEADER";
DROP TABLE "FFLU"."FFLU_XACTION_PROGRESS";
DROP TABLE "FFLU"."FFLU_XACTION_WRITEBACK";
--------------------------------------------------------
--  DDL for Table FFLU_LOAD_DATA
--------------------------------------------------------

  CREATE TABLE "FFLU"."FFLU_LOAD_DATA" 
   (	"LOAD_SEQ" NUMBER(15,0), 
	"DATA_SEQ" NUMBER(9,0), 
	"DATA_RECORD" VARCHAR2(4000 BYTE), 
	"DATA_SEG" NUMBER(9,0)
   );

   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_DATA"."LOAD_SEQ" IS 'Load Data - Sequence';
   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_DATA"."DATA_SEQ" IS 'Load Data - Data Row Sequence Number';
   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_DATA"."DATA_RECORD" IS 'Load Data - Data Record';
   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_DATA"."DATA_SEG" IS 'Data Segement this data came in on.';
   COMMENT ON TABLE "FFLU"."FFLU_LOAD_DATA"  IS 'Flat File Data Loading Table';
  GRANT DELETE, INSERT, SELECT, UPDATE ON "FFLU"."FFLU_LOAD_DATA" TO "FFLU_APP";
--------------------------------------------------------
--  DDL for Table FFLU_LOAD_HEADER
--------------------------------------------------------

  CREATE TABLE "FFLU"."FFLU_LOAD_HEADER" 
   (	"LOAD_SEQ" NUMBER(15,0), 
	"USER_CODE" VARCHAR2(32 CHAR), 
	"INTERFACE_CODE" VARCHAR2(32 CHAR), 
	"FILE_NAME" VARCHAR2(64 CHAR), 
	"SEGMENT_COUNT" NUMBER(9,0), 
	"ROW_COUNT" NUMBER(9,0), 
	"LOAD_STATUS" VARCHAR2(32 CHAR), 
	"LICS_HEADER_SEQ" NUMBER(15,0), 
	"LOAD_START_TIME" DATE, 
	"LOAD_COMPLETE_TIME" DATE, 
	"LOAD_EXECUTED" DATE, 
	"ROW_COUNT_TRAN" NUMBER(9,0)
   );

   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_HEADER"."LOAD_SEQ" IS 'Load - Sequence Number';
   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_HEADER"."USER_CODE" IS 'Load - User Code';
   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_HEADER"."INTERFACE_CODE" IS 'Load - Interface Code';
   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_HEADER"."FILE_NAME" IS 'Load - File Name';
   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_HEADER"."SEGMENT_COUNT" IS 'Load - Segment Count';
   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_HEADER"."ROW_COUNT" IS 'Load - Row Count';
   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_HEADER"."LOAD_STATUS" IS 'Load - Load Status';
   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_HEADER"."LICS_HEADER_SEQ" IS 'Load - Lics Header Sequence';
   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_HEADER"."LOAD_START_TIME" IS 'Load - Start Time';
   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_HEADER"."LOAD_COMPLETE_TIME" IS 'Load - Completed Time';
   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_HEADER"."LOAD_EXECUTED" IS 'Load - Executed Time';
   COMMENT ON COLUMN "FFLU"."FFLU_LOAD_HEADER"."ROW_COUNT_TRAN" IS 'Load - Rows transferred to LICS.';
   COMMENT ON TABLE "FFLU"."FFLU_LOAD_HEADER"  IS 'Flat File Loading Data Header';
  GRANT DELETE, INSERT, SELECT, UPDATE ON "FFLU"."FFLU_LOAD_HEADER" TO "FFLU_APP";
--------------------------------------------------------
--  DDL for Table FFLU_XACTION_PROGRESS
--------------------------------------------------------

  CREATE TABLE "FFLU"."FFLU_XACTION_PROGRESS" 
   (	"LICS_HEADER_SEQ" NUMBER(15,0), 
	"DAT_COUNT" NUMBER(9,0), 
	"DAT_SEQ" NUMBER(9,0), 
	"LAST_UPDTD_TIME" DATE
   );

   COMMENT ON COLUMN "FFLU"."FFLU_XACTION_PROGRESS"."LICS_HEADER_SEQ" IS 'This is the sequence number for the interface that we are tracking the progress of.';
   COMMENT ON COLUMN "FFLU"."FFLU_XACTION_PROGRESS"."DAT_COUNT" IS 'This is the number of rows that have to be processed.';
   COMMENT ON COLUMN "FFLU"."FFLU_XACTION_PROGRESS"."DAT_SEQ" IS 'This is the current row number that was last processed.';
   COMMENT ON COLUMN "FFLU"."FFLU_XACTION_PROGRESS"."LAST_UPDTD_TIME" IS 'This is the time that this interface progress was last updated.';
   COMMENT ON TABLE "FFLU"."FFLU_XACTION_PROGRESS"  IS 'This table is used to track loading progress for any interface that wants to show its progress on the new front end website.';
  GRANT DELETE, INSERT, SELECT, UPDATE ON "FFLU"."FFLU_XACTION_PROGRESS" TO "FFLU_APP";
--------------------------------------------------------
--  DDL for Table FFLU_XACTION_WRITEBACK
--------------------------------------------------------

  CREATE TABLE "FFLU"."FFLU_XACTION_WRITEBACK" 
   (	"LICS_HEADER_SEQ" NUMBER(15,0), 
	"USER_CODE" VARCHAR2(30 BYTE), 
	"LAST_UPDTD_TIME" DATE
   );

   COMMENT ON COLUMN "FFLU"."FFLU_XACTION_WRITEBACK"."LICS_HEADER_SEQ" IS 'This is the interface id.';
   COMMENT ON COLUMN "FFLU"."FFLU_XACTION_WRITEBACK"."USER_CODE" IS 'This is the user code to write back on processing an interface.';
   COMMENT ON COLUMN "FFLU"."FFLU_XACTION_WRITEBACK"."LAST_UPDTD_TIME" IS 'This is the time this writeback entry was added.';
  GRANT DELETE, INSERT, SELECT, UPDATE ON "FFLU"."FFLU_XACTION_WRITEBACK" TO "FFLU_APP";
--------------------------------------------------------
--  DDL for Index FFLU_LOAD_DATA_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "FFLU"."FFLU_LOAD_DATA_PK" ON "FFLU"."FFLU_LOAD_DATA" ("LOAD_SEQ", "DATA_SEQ");
--------------------------------------------------------
--  DDL for Index LOAD_HEADER_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "FFLU"."LOAD_HEADER_PK" ON "FFLU"."FFLU_LOAD_HEADER" ("LOAD_SEQ");
--------------------------------------------------------
--  DDL for Index FFLU_XACTION_PROGRESS_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "FFLU"."FFLU_XACTION_PROGRESS_PK" ON "FFLU"."FFLU_XACTION_PROGRESS" ("LICS_HEADER_SEQ");
--------------------------------------------------------
--  DDL for Index FFLU_XACTION_WRITEBACK_NU01
--------------------------------------------------------

  CREATE INDEX "FFLU"."FFLU_XACTION_WRITEBACK_NU01" ON "FFLU"."FFLU_XACTION_WRITEBACK" ("LICS_HEADER_SEQ");
--------------------------------------------------------
--  Constraints for Table FFLU_LOAD_DATA
--------------------------------------------------------

  ALTER TABLE "FFLU"."FFLU_LOAD_DATA" ADD CONSTRAINT "FFLU_LOAD_DATA_PK" PRIMARY KEY ("LOAD_SEQ", "DATA_SEQ");
  ALTER TABLE "FFLU"."FFLU_LOAD_DATA" MODIFY ("DATA_SEQ" NOT NULL ENABLE);
  ALTER TABLE "FFLU"."FFLU_LOAD_DATA" MODIFY ("LOAD_SEQ" NOT NULL ENABLE);
  GRANT DELETE, INSERT, SELECT, UPDATE ON "FFLU"."FFLU_LOAD_DATA" TO "FFLU_APP";
--------------------------------------------------------
--  Constraints for Table FFLU_LOAD_HEADER
--------------------------------------------------------

  ALTER TABLE "FFLU"."FFLU_LOAD_HEADER" ADD CONSTRAINT "LOAD_HEADER_PK" PRIMARY KEY ("LOAD_SEQ");
  ALTER TABLE "FFLU"."FFLU_LOAD_HEADER" MODIFY ("INTERFACE_CODE" NOT NULL ENABLE);
  ALTER TABLE "FFLU"."FFLU_LOAD_HEADER" MODIFY ("USER_CODE" NOT NULL ENABLE);
  ALTER TABLE "FFLU"."FFLU_LOAD_HEADER" MODIFY ("LOAD_SEQ" NOT NULL ENABLE);
  GRANT DELETE, INSERT, SELECT, UPDATE ON "FFLU"."FFLU_LOAD_HEADER" TO "FFLU_APP";
--------------------------------------------------------
--  Constraints for Table FFLU_XACTION_PROGRESS
--------------------------------------------------------

  ALTER TABLE "FFLU"."FFLU_XACTION_PROGRESS" ADD CONSTRAINT "FFLU_XACTION_PROGRESS_PK" PRIMARY KEY ("LICS_HEADER_SEQ");
  ALTER TABLE "FFLU"."FFLU_XACTION_PROGRESS" MODIFY ("LAST_UPDTD_TIME" NOT NULL ENABLE);
  ALTER TABLE "FFLU"."FFLU_XACTION_PROGRESS" MODIFY ("DAT_SEQ" NOT NULL ENABLE);
  ALTER TABLE "FFLU"."FFLU_XACTION_PROGRESS" MODIFY ("LICS_HEADER_SEQ" NOT NULL ENABLE);
  GRANT DELETE, INSERT, SELECT, UPDATE ON "FFLU"."FFLU_XACTION_PROGRESS" TO "FFLU_APP";
--------------------------------------------------------
--  Constraints for Table FFLU_XACTION_WRITEBACK
--------------------------------------------------------

  ALTER TABLE "FFLU"."FFLU_XACTION_WRITEBACK" MODIFY ("LICS_HEADER_SEQ" NOT NULL ENABLE);
  GRANT DELETE, INSERT, SELECT, UPDATE ON "FFLU"."FFLU_XACTION_WRITEBACK" TO "FFLU_APP";
--------------------------------------------------------
--  Ref Constraints for Table FFLU_LOAD_DATA
--------------------------------------------------------

  ALTER TABLE "FFLU"."FFLU_LOAD_DATA" ADD CONSTRAINT "FLD_FLH_FK01" FOREIGN KEY ("LOAD_SEQ")
	  REFERENCES "FFLU"."FFLU_LOAD_HEADER" ("LOAD_SEQ");
  GRANT DELETE, INSERT, SELECT, UPDATE ON "FFLU"."FFLU_LOAD_DATA" TO "FFLU_APP";
GRANT DELETE, INSERT, SELECT, UPDATE ON "FFLU"."FFLU_LOAD_HEADER" TO "FFLU_APP";
GRANT DELETE, INSERT, SELECT, UPDATE ON "FFLU"."FFLU_XACTION_PROGRESS" TO "FFLU_APP";
GRANT DELETE, INSERT, SELECT, UPDATE ON "FFLU"."FFLU_XACTION_WRITEBACK" TO "FFLU_APP";

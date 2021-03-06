CREATE TABLE ODS.EFEX_ASSMNT_QUESTN
(
   ASSMNT_ID     NUMBER(10,0) NOT NULL ENABLE,
   ASSMNT_QUESTN VARCHAR2(4000 BYTE) NOT NULL ENABLE,
   QUESTN_TYPE   VARCHAR2(50 CHAR) NOT NULL ENABLE,
   EFEX_GRP_ID   NUMBER(10,0) NOT NULL ENABLE,
   QUESTN_GRP    VARCHAR2(50 CHAR) NOT NULL ENABLE,
   SGMNT_ID      NUMBER(10,0) NOT NULL ENABLE,
   BUS_UNIT_ID   NUMBER(10,0) NOT NULL ENABLE,
   ACTIVE_DATE DATE NOT NULL ENABLE,
   INACTIVE_DATE DATE NOT NULL ENABLE,
   DUE_DATE DATE NOT NULL ENABLE,
   STATUS              VARCHAR2(1 CHAR) NOT NULL ENABLE,
   VALDTN_STATUS       VARCHAR2(10 CHAR) NOT NULL ENABLE,
   ASSMNT_QUESTN_LUPDP VARCHAR2(8 CHAR) NOT NULL ENABLE,
   ASSMNT_QUESTN_LUPDT DATE NOT NULL ENABLE,
   EFEX_MKT_ID NUMBER(10,0) NOT NULL ENABLE,
   ASSMNT_TITLE   VARCHAR2(50 CHAR),
   CONSTRAINT EFEX_ASSMNT_QUESTN_PK PRIMARY KEY (ASSMNT_ID)
);

COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.ASSMNT_ID IS 'Assessment Unique Sequence ID source from EFEX.COMM';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.ASSMNT_QUESTN IS 'Assessment Question';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.QUESTN_TYPE IS 'Assessment Type';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.EFEX_GRP_ID IS 'EFEX Group ID';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.QUESTN_GRP IS 'Question Group';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.SGMNT_ID IS 'Segment Unique Sequence ID';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.BUS_UNIT_ID IS 'Business Unit Unique Sequence ID';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.ACTIVE_DATE IS 'Assessment Active Date';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.INACTIVE_DATE IS 'Assessment Inactive Date';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.DUE_DATE IS 'Assessment Due Date';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.STATUS IS 'Record Status';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.VALDTN_STATUS IS 'Validation Status';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.ASSMNT_QUESTN_LUPDP IS 'User who last modified record';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.ASSMNT_QUESTN_LUPDT IS 'Date record was last modified';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.EFEX_MKT_ID IS 'Efex Market Unique Sequence Id';
COMMENT ON COLUMN ODS.EFEX_ASSMNT_QUESTN.ASSMNT_TITLE IS 'Assessment Title';
COMMENT ON TABLE ODS.EFEX_ASSMNT_QUESTN IS 'EFEX Assessment Question';

CREATE OR REPLACE TRIGGER ODS.EFEX_ASSMNT_QUESTN_UPDT
   /*********************************************************************************
   DESCRIPTION:
   Updates efex_assmnt_questn_lupdp and efex_assmnt_questn_lupdt columns in efex_assmnt_questn table
   whenever a new record is added or updated.
   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   Sept 2007   John Cho           Created the Trigger.
   *********************************************************************************/
   BEFORE
   INSERT OR
   UPDATE ON ODS.EFEX_ASSMNT_QUESTN FOR EACH ROW BEGIN :NEW.assmnt_questn_lupdt := SYSDATE;
   :NEW.assmnt_questn_lupdp                                                     := USER;
END;
/
ALTER TRIGGER ODS.EFEX_ASSMNT_QUESTN_UPDT ENABLE;

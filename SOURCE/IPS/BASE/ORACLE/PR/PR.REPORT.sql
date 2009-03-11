
CREATE TABLE PR.REPORT
(
  REPORT_ID             NUMBER(20)              NOT NULL,
  REPORT_NAME           VARCHAR2(200 BYTE)      NOT NULL,
  PRICE_SALES_ORG_ID    NUMBER(20)              NOT NULL,
  PRICE_DISTBN_CHNL_ID  NUMBER(20)              NOT NULL,
  PRICE_MDL_ID          NUMBER(20)              NOT NULL,
  STATUS                VARCHAR2(1 BYTE)        NOT NULL,
  REPORT_GRP_ID         NUMBER(20)              NOT NULL,
  MATL_ALRTNG           VARCHAR2(1 BYTE),
  REPORT_NAME_FRMT      VARCHAR2(4000 BYTE),
  CREATE_USER           VARCHAR2(30 BYTE),
  UPDATE_USER           VARCHAR2(30 BYTE),
  EMAIL_ADDRESS         VARCHAR2(64 BYTE),
  AUTO_MATL_UPDATE      VARCHAR2(1 BYTE)
);

COMMENT ON TABLE PR.REPORT IS 'This table holds the reports that are available in the system.';

COMMENT ON COLUMN PR.REPORT.REPORT_ID IS 'The internal id number for this report.';

COMMENT ON COLUMN PR.REPORT.REPORT_NAME IS 'The name of this report and the title that it is given when generated.';

COMMENT ON COLUMN PR.REPORT.PRICE_SALES_ORG_ID IS 'This is the sale org that this report should be run for.';

COMMENT ON COLUMN PR.REPORT.PRICE_DISTBN_CHNL_ID IS 'This is the distribution channel this report should be run for.';

COMMENT ON COLUMN PR.REPORT.PRICE_MDL_ID IS 'This is the pricing model id number.';

COMMENT ON COLUMN PR.REPORT.STATUS IS 'This is the status of the report.  V = Valid and available.  I = Invalid and not available.';

COMMENT ON COLUMN PR.REPORT.REPORT_GRP_ID IS 'This is the report group that this report belongs to.';

COMMENT ON COLUMN PR.REPORT.REPORT_NAME_FRMT IS 'Report name format string - HTML format';

COMMENT ON COLUMN PR.REPORT.CREATE_USER IS 'Report created by user';

COMMENT ON COLUMN PR.REPORT.MATL_ALRTNG IS 'When a material is detected that should be in the list or not in the list an email is sent to the owner if defined, and the users of the price list alerting group.';

COMMENT ON COLUMN PR.REPORT.AUTO_MATL_UPDATE IS 'Report materials automatically updated';

COMMENT ON COLUMN PR.REPORT.UPDATE_USER IS 'Report last updated by user';

COMMENT ON COLUMN PR.REPORT.EMAIL_ADDRESS IS 'Report email address';

CREATE OR REPLACE PUBLIC SYNONYM REPORT FOR PR.REPORT;

ALTER TABLE PR.REPORT ADD (
  CONSTRAINT REPORT_CK01
 CHECK (status in ('V','I')),
  CONSTRAINT REPORT_CK02
 CHECK (matl_alrtng in ('Y','N')),
  CONSTRAINT REPORT_PK01
 PRIMARY KEY
 (REPORT_ID));

GRANT SELECT ON PR.REPORT TO LICS_APP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PR.REPORT TO PR_APP;


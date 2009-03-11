
CREATE TABLE PR.REPORT_GRP
(
  REPORT_GRP_ID    NUMBER(20),
  REPORT_GRP_NAME  VARCHAR2(200 BYTE),
  STATUS           VARCHAR2(1 BYTE)
);

COMMENT ON TABLE PR.REPORT_GRP IS 'This table holds the name of various price list report groups.';

COMMENT ON COLUMN PR.REPORT_GRP.REPORT_GRP_ID IS 'The id of the report group.';

COMMENT ON COLUMN PR.REPORT_GRP.REPORT_GRP_NAME IS 'Name of the report group.';

COMMENT ON COLUMN PR.REPORT_GRP.STATUS IS 'If the group is currently valid or not. (V=Valid, I=Invalid)';

CREATE OR REPLACE PUBLIC SYNONYM REPORT_GRP FOR PR.REPORT_GRP;

ALTER TABLE PR.REPORT_GRP ADD (
  CONSTRAINT REPORT_GRP_CK01
 CHECK (status in ('V','I')),
  CONSTRAINT REPORT_GRP_PK01
 PRIMARY KEY
 (REPORT_GRP_ID));

GRANT SELECT ON PR.REPORT_GRP TO LICS_APP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PR.REPORT_GRP TO PR_APP;


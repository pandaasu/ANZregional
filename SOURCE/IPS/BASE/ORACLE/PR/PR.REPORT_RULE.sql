
CREATE TABLE PR.REPORT_RULE
(
  REPORT_RULE_ID    NUMBER(20)                  NOT NULL,
  REPORT_ID         NUMBER(20)                  NOT NULL,
  REPORT_RULE_NAME  VARCHAR2(200 BYTE)
);

COMMENT ON TABLE PR.REPORT_RULE IS 'This table holds each of the rules that are unioned together to produce a list of materials for validation against the current reports list of materials on a regular basis.  There are two checks performed.  1 to check if the report contains the materials and shouldn''t, and 2 checks to see if the report doesn''t contain the material and should.';

COMMENT ON COLUMN PR.REPORT_RULE.REPORT_RULE_ID IS 'This is the unique id given to this rule for the report.';

COMMENT ON COLUMN PR.REPORT_RULE.REPORT_ID IS 'The report id that this rule belongs to.';

COMMENT ON COLUMN PR.REPORT_RULE.REPORT_RULE_NAME IS 'This is the name or alias given to this rule for user reference.';

CREATE OR REPLACE PUBLIC SYNONYM REPORT_RULE FOR PR.REPORT_RULE;

ALTER TABLE PR.REPORT_RULE ADD (
  CONSTRAINT REPORT_RULE_PK01
 PRIMARY KEY
 (REPORT_RULE_ID));

GRANT SELECT ON PR.REPORT_RULE TO LICS_APP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PR.REPORT_RULE TO PR_APP;


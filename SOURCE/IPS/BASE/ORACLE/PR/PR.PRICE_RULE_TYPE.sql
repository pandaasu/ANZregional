
CREATE TABLE PR.PRICE_RULE_TYPE
(
  PRICE_RULE_TYPE_ID      NUMBER(20)            NOT NULL,
  PRICE_RULE_TYPE_COLUMN  VARCHAR2(32 BYTE)     NOT NULL,
  PRICE_RULE_TYPE_NAME    VARCHAR2(200 BYTE)    NOT NULL,
  SQL_VLU                 VARCHAR2(4000 BYTE)   NOT NULL,
  SQL_WHERE               VARCHAR2(4000 BYTE)   NOT NULL
);

COMMENT ON TABLE PR.PRICE_RULE_TYPE IS 'This table contains the list of available rules types that are available for users to build up rules within their report for.';

COMMENT ON COLUMN PR.PRICE_RULE_TYPE.PRICE_RULE_TYPE_ID IS 'The id given to this rule.';

COMMENT ON COLUMN PR.PRICE_RULE_TYPE.PRICE_RULE_TYPE_COLUMN IS 'This is the name of the column that the rule applies to.';

COMMENT ON COLUMN PR.PRICE_RULE_TYPE.PRICE_RULE_TYPE_NAME IS 'This is the name given to this rule type.';

COMMENT ON COLUMN PR.PRICE_RULE_TYPE.SQL_VLU IS 'This sql statement is run to provide an optional list of values to the client when this rule is selected.  Value and Value_name must be the two columns returned in the query. ';

COMMENT ON COLUMN PR.PRICE_RULE_TYPE.SQL_WHERE IS 'This is the sql statement that will be applied to the in or not in clause of the matl select satement.  This select statement needs to return a list of full matl_code.';

CREATE UNIQUE INDEX PR.PRICE_RULE_TYPE_UK01 ON PR.PRICE_RULE_TYPE
(PRICE_RULE_TYPE_COLUMN);

CREATE OR REPLACE PUBLIC SYNONYM PRICE_RULE_TYPE FOR PR.PRICE_RULE_TYPE;

ALTER TABLE PR.PRICE_RULE_TYPE ADD (
  CONSTRAINT PRICE_RULE_TYPE_PK01
 PRIMARY KEY
 (PRICE_RULE_TYPE_ID));

GRANT SELECT ON PR.PRICE_RULE_TYPE TO LICS_APP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PR.PRICE_RULE_TYPE TO PR_APP;


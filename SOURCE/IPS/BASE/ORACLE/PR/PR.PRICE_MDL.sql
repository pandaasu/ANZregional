
CREATE TABLE PR.PRICE_MDL
(
  PRICE_MDL_ID     NUMBER(20)                   NOT NULL,
  PRICE_MDL_CODE   VARCHAR2(20 BYTE)            NOT NULL,
  PRICE_MDL_NAME   VARCHAR2(200 BYTE)           NOT NULL,
  SQL_FROM_TABLES  VARCHAR2(4000 BYTE),
  SQL_WHERE_JOINS  VARCHAR2(4000 BYTE)
);

COMMENT ON TABLE PR.PRICE_MDL IS 'This table contains contains the pricing models that are available.  This table defines the from clauses and the where lause joins.';

COMMENT ON COLUMN PR.PRICE_MDL.PRICE_MDL_ID IS 'Pricing Model ID.';

COMMENT ON COLUMN PR.PRICE_MDL.PRICE_MDL_CODE IS 'This is the unique code given to this pricing model.';

COMMENT ON COLUMN PR.PRICE_MDL.PRICE_MDL_NAME IS 'The name given to this pricing model.';

COMMENT ON COLUMN PR.PRICE_MDL.SQL_FROM_TABLES IS 'The from clause for the pricing model.';

COMMENT ON COLUMN PR.PRICE_MDL.SQL_WHERE_JOINS IS 'The where clause for the joins.';

CREATE UNIQUE INDEX PR.PRICE_MDL_UK02 ON PR.PRICE_MDL
(PRICE_MDL_CODE);

CREATE OR REPLACE PUBLIC SYNONYM PRICE_MDL FOR PR.PRICE_MDL;

ALTER TABLE PR.PRICE_MDL ADD (
  CONSTRAINT PRICE_MDL_PK01
 PRIMARY KEY
 (PRICE_MDL_ID));

GRANT SELECT ON PR.PRICE_MDL TO LICS_APP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PR.PRICE_MDL TO PR_APP;


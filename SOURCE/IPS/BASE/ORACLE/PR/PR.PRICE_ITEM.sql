
CREATE TABLE PR.PRICE_ITEM
(
  PRICE_ITEM_ID    NUMBER(20)                   NOT NULL,
  PRICE_ITEM_CODE  VARCHAR2(20 BYTE),
  PRICE_ITEM_NAME  VARCHAR2(200 BYTE),
  PRICE_ITEM_DESC  VARCHAR2(1000 BYTE),
  PRICE_MDL_ID     NUMBER(20),
  SQL_SELECT       VARCHAR2(4000 BYTE)
);

COMMENT ON TABLE PR.PRICE_ITEM IS 'This table contains all the available pricing items.';

COMMENT ON COLUMN PR.PRICE_ITEM.PRICE_ITEM_ID IS 'This is the id given to the pricing item.';

COMMENT ON COLUMN PR.PRICE_ITEM.PRICE_ITEM_CODE IS 'This is the code given to the pricing item.';

COMMENT ON COLUMN PR.PRICE_ITEM.PRICE_ITEM_NAME IS 'The name given to this item.';

COMMENT ON COLUMN PR.PRICE_ITEM.PRICE_ITEM_DESC IS 'This is the textual description documenting what this item will display.';

COMMENT ON COLUMN PR.PRICE_ITEM.PRICE_MDL_ID IS 'This is the id of the pricing model that this item belongs to.  Null if it is available to all pricing models.';

COMMENT ON COLUMN PR.PRICE_ITEM.SQL_SELECT IS 'This is the select statement information for this item.';

CREATE UNIQUE INDEX PR.PRICE_ITEM_UK02 ON PR.PRICE_ITEM
(PRICE_ITEM_CODE);

CREATE OR REPLACE PUBLIC SYNONYM PRICE_ITEM FOR PR.PRICE_ITEM;

ALTER TABLE PR.PRICE_ITEM ADD (
  CONSTRAINT PRICE_ITEM_PK01
 PRIMARY KEY
 (PRICE_ITEM_ID));

GRANT SELECT ON PR.PRICE_ITEM TO LICS_APP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PR.PRICE_ITEM TO PR_APP;


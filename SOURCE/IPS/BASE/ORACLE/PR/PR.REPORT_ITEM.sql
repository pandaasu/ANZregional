
CREATE TABLE PR.REPORT_ITEM
(
  REPORT_ITEM_ID    NUMBER(20)                  NOT NULL,
  REPORT_ID         NUMBER(20)                  NOT NULL,
  PRICE_ITEM_ID     NUMBER(20)                  NOT NULL,
  REPORT_ITEM_TYPE  VARCHAR2(1 BYTE)            NOT NULL,
  NAME_OVRD         VARCHAR2(200 BYTE),
  SORT_ORDER        NUMBER(8),
  NAME_FRMT         VARCHAR2(4000 BYTE),
  DATA_FRMT         VARCHAR2(4000 BYTE)
);

COMMENT ON TABLE PR.REPORT_ITEM IS 'This table holds each of the items that will appear on the price list.';

COMMENT ON COLUMN PR.REPORT_ITEM.REPORT_ITEM_ID IS 'This is the unique item id for this report.';

COMMENT ON COLUMN PR.REPORT_ITEM.REPORT_ID IS 'This is the report id that this report item links to.';

COMMENT ON COLUMN PR.REPORT_ITEM.PRICE_ITEM_ID IS 'This is the link to the report item.';

COMMENT ON COLUMN PR.REPORT_ITEM.REPORT_ITEM_TYPE IS 'This is D if it is a data item.  This is a B if this is a break item.';

COMMENT ON COLUMN PR.REPORT_ITEM.NAME_OVRD IS 'If the column name description is to be overrideen, it will appear here.';

COMMENT ON COLUMN PR.REPORT_ITEM.SORT_ORDER IS 'This is the sort order for the breaks or data items.';

COMMENT ON COLUMN PR.REPORT_ITEM.NAME_FRMT IS 'Report item name format string - HTML format';

COMMENT ON COLUMN PR.REPORT_ITEM.DATA_FRMT IS 'Report item data format string - HTML format';

CREATE INDEX PR.REPORT_ITEM_NU02 ON PR.REPORT_ITEM
(REPORT_ID);

CREATE OR REPLACE PUBLIC SYNONYM REPORT_ITEM FOR PR.REPORT_ITEM;

ALTER TABLE PR.REPORT_ITEM ADD (
  CONSTRAINT REPORT_ITEM_CK01
 CHECK (REPORT_ITEM_TYPE IN ('B','D','O')),
  CONSTRAINT REPORT_ITEM_PK01
 PRIMARY KEY
 (REPORT_ITEM_ID));

GRANT SELECT ON PR.REPORT_ITEM TO LICS_APP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PR.REPORT_ITEM TO PR_APP;


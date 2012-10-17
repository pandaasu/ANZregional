CREATE TABLE ODS.EFEX_DISTBN
(
   EFEX_CUST_ID     NUMBER(10,0) NOT NULL ENABLE,
   EFEX_MATL_ID     NUMBER(10,0) NOT NULL ENABLE,
   SALES_TERR_ID    NUMBER(10,0) NOT NULL ENABLE,
   SGMNT_ID         NUMBER(10,0) NOT NULL ENABLE,
   BUS_UNIT_ID      NUMBER(10,0) NOT NULL ENABLE,
   USER_ID          NUMBER(10,0) NOT NULL ENABLE,
   RANGE_ID         NUMBER(10,0),
   DISPLAY_QTY      NUMBER(4,0),
   FACING_QTY       NUMBER(4,0),
   OUT_OF_STOCK_FLG VARCHAR2(1 CHAR),
   OUT_OF_DATE_FLG  VARCHAR2(1 CHAR),
   RQD_FLG          VARCHAR2(1 CHAR),
   INV_QTY          NUMBER(4,0),
   SELL_PRICE       NUMBER(10,2),
   IN_STORE_DATE DATE,
   STATUS VARCHAR2(1 CHAR) NOT NULL ENABLE,
   EFEX_LUPDT DATE NOT NULL ENABLE,
   VALDTN_STATUS VARCHAR2(10 CHAR) NOT NULL ENABLE,
   DISTBN_LUPDP  VARCHAR2(8 CHAR) NOT NULL ENABLE,
   DISTBN_LUPDT DATE NOT NULL ENABLE,
   EFEX_MKT_ID NUMBER(10,0) NOT NULL ENABLE,
   PROMO_PRICE VARCHAR2(50 CHAR),
   CONSTRAINT EFEX_DISTBN_PK PRIMARY KEY (EFEX_CUST_ID, EFEX_MATL_ID)
);

COMMENT ON COLUMN ODS.EFEX_DISTBN.EFEX_CUST_ID IS 'EFEX Customer Unique Sequence ID';
COMMENT ON COLUMN ODS.EFEX_DISTBN.EFEX_MATL_ID IS 'EFEX Material Unique Sequence ID';
COMMENT ON COLUMN ODS.EFEX_DISTBN.SALES_TERR_ID IS 'Sales Territory Unique Sequence ID';
COMMENT ON COLUMN ODS.EFEX_DISTBN.SGMNT_ID IS 'Segment Unique Sequence ID';
COMMENT ON COLUMN ODS.EFEX_DISTBN.BUS_UNIT_ID IS 'Business Unit Unique Sequence ID';
COMMENT ON COLUMN ODS.EFEX_DISTBN.USER_ID IS 'User Unique Sequence ID';
COMMENT ON COLUMN ODS.EFEX_DISTBN.RANGE_ID IS 'Range Unique Sequence ID';
COMMENT ON COLUMN ODS.EFEX_DISTBN.DISPLAY_QTY IS 'Display Quantity';
COMMENT ON COLUMN ODS.EFEX_DISTBN.FACING_QTY IS 'Facting Quantity';
COMMENT ON COLUMN ODS.EFEX_DISTBN.OUT_OF_STOCK_FLG IS 'Out of Stock Flag';
COMMENT ON COLUMN ODS.EFEX_DISTBN.OUT_OF_DATE_FLG IS 'Out of Date Flag';
COMMENT ON COLUMN ODS.EFEX_DISTBN.RQD_FLG IS 'Required Flag';
COMMENT ON COLUMN ODS.EFEX_DISTBN.INV_QTY IS 'Inventory Quantity';
COMMENT ON COLUMN ODS.EFEX_DISTBN.SELL_PRICE IS 'Sell Price';
COMMENT ON COLUMN ODS.EFEX_DISTBN.IN_STORE_DATE IS 'In Store Date';
COMMENT ON COLUMN ODS.EFEX_DISTBN.STATUS IS 'Record Status';
COMMENT ON COLUMN ODS.EFEX_DISTBN.EFEX_LUPDT IS 'Date Time the record was last updated in the EFEX DISTRIBUTION table';
COMMENT ON COLUMN ODS.EFEX_DISTBN.VALDTN_STATUS IS 'Validation Status';
COMMENT ON COLUMN ODS.EFEX_DISTBN.DISTBN_LUPDP IS 'User who last modified record';
COMMENT ON COLUMN ODS.EFEX_DISTBN.DISTBN_LUPDT IS 'Date record was last modified';
COMMENT ON COLUMN ODS.EFEX_DISTBN.EFEX_MKT_ID IS 'Efex Market Unique Sequence Id';
COMMENT ON COLUMN ODS.EFEX_DISTBN.PROMO_PRICE IS 'Promo Price';
COMMENT ON TABLE ODS.EFEX_DISTBN IS 'EFEX Distribution';

CREATE OR REPLACE TRIGGER ODS.EFEX_DISTBN_UPDT
   /*********************************************************************************
   DESCRIPTION:
   Updates efex_distbn_lupdp and efex_distbn_lupdt columns in efex_distbn table
   whenever a new record is added or updated.
   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   Sept 2007   John Cho           Created the Trigger.
   *********************************************************************************/
   BEFORE
   INSERT OR
   UPDATE ON ODS.EFEX_DISTBN FOR EACH ROW BEGIN :NEW.distbn_lupdt := SYSDATE;
   :NEW.distbn_lupdp := USER;
END;
/
ALTER TRIGGER ODS.EFEX_DISTBN_UPDT ENABLE;
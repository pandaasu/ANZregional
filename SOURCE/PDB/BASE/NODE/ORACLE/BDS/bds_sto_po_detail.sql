CREATE TABLE BDS.BDS_STO_PO_DETAIL
(
  PURCH_ORDER_DOC_NUM       VARCHAR2(10 BYTE),
  PURCH_ORDER_DOC_LINE_NUM  VARCHAR2(10 BYTE),
  SAP_MATERIAL_CODE         VARCHAR2(18 BYTE),
  DELIVERY_DATE             DATE,
  QTY                       NUMBER,
  UOM_CODE                  VARCHAR2(3 BYTE),
  ITEM_VALUE_NET            NUMBER,
  PLANT_CODE                VARCHAR2(4 BYTE),
  STORAGE_LOCN_CODE         VARCHAR2(10 BYTE),
  ACTION_CODE               VARCHAR2(5 BYTE),
  DLVRY_COMP                VARCHAR2(1 CHAR),
  OVER_DEL_TOLRNCE          VARCHAR2(5 CHAR),
  STOCK_TYPE                VARCHAR2(1 CHAR)
)
TABLESPACE BDS_DATA
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/

COMMENT ON TABLE BDS.BDS_STO_PO_DETAIL IS 'Business Data Store - Stock Transfer Order / Purchase Order Detail'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_DETAIL.PURCH_ORDER_DOC_NUM IS 'IDOC document number - lads_sto_po_hdr.belnr'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_DETAIL.PURCH_ORDER_DOC_LINE_NUM IS 'Item number - lads_sto_po_gen.posex'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_DETAIL.SAP_MATERIAL_CODE IS 'IDOC material ID - lads_sto_po_oid.idtnr'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_DETAIL.DELIVERY_DATE IS 'IDOC: Date - lads_sto_po_sch.edatu'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_DETAIL.QTY IS 'Quantity - lads_sto_po_gen.menge'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_DETAIL.UOM_CODE IS 'Unit of measure - lads_sto_po_gen.menee'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_DETAIL.ITEM_VALUE_NET IS 'Item value (net) - lads_sto_po_gen.netwr'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_DETAIL.PLANT_CODE IS 'Plant - lads_sto_po_gen.werks'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_DETAIL.STORAGE_LOCN_CODE IS 'Storage Location - lads_sto_po_gen.lgort'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_DETAIL.ACTION_CODE IS 'Action code for the item - lads_sto_po_gen.action'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_DETAIL.DLVRY_COMP IS 'Delivery Completed Indicator - lads_sto_po_gen.elikz'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_DETAIL.OVER_DEL_TOLRNCE IS 'Over Delivery Tolerance Limit - lads_sto_po_gen.uebto'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_DETAIL.STOCK_TYPE IS 'Stock Type - lads_sto_po_gen.insmk'
/



CREATE UNIQUE INDEX BDS.BDS_STO_PO_DETAIL_PK ON BDS.BDS_STO_PO_DETAIL
(PURCH_ORDER_DOC_NUM, PURCH_ORDER_DOC_LINE_NUM)
LOGGING
TABLESPACE BDS_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL
/


ALTER TABLE BDS.BDS_STO_PO_DETAIL ADD (
  CONSTRAINT BDS_STO_PO_DETAIL_PK
  PRIMARY KEY
  (PURCH_ORDER_DOC_NUM, PURCH_ORDER_DOC_LINE_NUM)
  USING INDEX BDS.BDS_STO_PO_DETAIL_PK
  ENABLE VALIDATE)
/

GRANT DELETE, INSERT, SELECT, UPDATE ON BDS.BDS_STO_PO_DETAIL TO BDS_APP
/

create public synonym BDS_STO_PO_DETAIL for bds.BDS_STO_PO_DETAIL;
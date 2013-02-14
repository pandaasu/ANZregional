CREATE TABLE BDS.BDS_STO_PO_HEADER
(
  PURCH_ORDER_DOC_NUM   VARCHAR2(35 BYTE)       NOT NULL,
  DOCUMENT_TYPE         VARCHAR2(4 BYTE),
  CURRENCY_CODE         VARCHAR2(3 BYTE),
  PURCH_ORDER_TYPE      VARCHAR2(35 BYTE),
  VENDOR_CODE           VARCHAR2(10 BYTE),
  DOCUMENT_DATE         DATE,
  COMPANY_CODE          VARCHAR2(10 BYTE),
  PURCH_ORDER_ORG_CODE  VARCHAR2(6 BYTE),
  PURCH_ORDER_GRP_CODE  VARCHAR2(3 BYTE),
  CUSTOMER_CODE         VARCHAR2(10 BYTE),
  UPD_DATIME            DATE
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

COMMENT ON TABLE BDS.BDS_STO_PO_HEADER IS 'Business Data Store - Stock Transfer Order / Purchase Order Detail'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_HEADER.PURCH_ORDER_DOC_NUM IS 'IDOC document number - lads_sto_po_hdr.belnr'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_HEADER.DOCUMENT_TYPE IS 'Document type - lads_sto_po_hdr.bsart'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_HEADER.CURRENCY_CODE IS 'Currency - lads_sto_po_hdr.curcy'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_HEADER.PURCH_ORDER_TYPE IS 'IDOC organization data - lads_sto_po_org.orgid'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_HEADER.VENDOR_CODE IS 'Partner number - lads_sto_po_pnr.partn'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_HEADER.DOCUMENT_DATE IS 'IDOC: Date - lads_sto_po_dat.datum'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_HEADER.COMPANY_CODE IS 'IDOC organization data - lads_sto_po_org.orgid'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_HEADER.PURCH_ORDER_ORG_CODE IS 'IDOC organization data - lads_sto_po_org.orgid'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_HEADER.PURCH_ORDER_GRP_CODE IS 'IDOC organization data - lads_sto_po_org.orgid'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_HEADER.CUSTOMER_CODE IS 'Customer Number - lads_cus_hdr.kunnr'
/

COMMENT ON COLUMN BDS.BDS_STO_PO_HEADER.UPD_DATIME IS 'Date/Time document last updated in plant database'
/



CREATE UNIQUE INDEX BDS.BDS_STO_PO_HEADER_PK ON BDS.BDS_STO_PO_HEADER
(PURCH_ORDER_DOC_NUM)
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


GRANT DELETE, INSERT, SELECT, UPDATE ON BDS.BDS_STO_PO_HEADER TO BDS_APP
/

create public synonym BDS_STO_PO_HEADER for bds.BDS_STO_PO_HEADER;
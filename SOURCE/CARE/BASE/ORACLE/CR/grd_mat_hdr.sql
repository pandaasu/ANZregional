ALTER TABLE CR.GRD_MAT_HDR
 DROP PRIMARY KEY CASCADE;
DROP TABLE CR.GRD_MAT_HDR CASCADE CONSTRAINTS;

CREATE TABLE CR.GRD_MAT_HDR
(
  MATNR            VARCHAR2(18 CHAR)            NOT NULL,
  MAKTX            VARCHAR2(40 CHAR),
  MSTAE            VARCHAR2(2 CHAR),
  EAN11            VARCHAR2(18 CHAR),
  ZZREPMATNR       VARCHAR2(18 CHAR),
  MTART            VARCHAR2(4 CHAR),
  ZZISRSU          VARCHAR2(1 CHAR),
  ZZISMCU          VARCHAR2(1 CHAR),
  ZZISTDU          VARCHAR2(1 CHAR),
  ZZISINT          VARCHAR2(1 CHAR),
  BUSSEG           VARCHAR2(4 CHAR),
  BUSSEGDESC       VARCHAR2(12 CHAR),
  BUSSEGDESCL      VARCHAR2(30 CHAR),
  BRND             VARCHAR2(4 CHAR),
  BRNDDESC         VARCHAR2(12 CHAR),
  BRNDDESCL        VARCHAR2(30 CHAR),
  BRNDSUB          VARCHAR2(4 CHAR),
  BRNDSUBDESC      VARCHAR2(12 CHAR),
  BRNDSUBDESCL     VARCHAR2(30 CHAR),
  CNSPCKFRT        VARCHAR2(4 CHAR),
  CNSPCKFRTDESC    VARCHAR2(12 CHAR),
  CNSPCKFRTDESCL   VARCHAR2(30 CHAR),
  PRDCAT           VARCHAR2(4 CHAR),
  PRDCATDESC       VARCHAR2(12 CHAR),
  PRDCATDESCL      VARCHAR2(30 CHAR),
  PRDTYPE          VARCHAR2(4 CHAR),
  PRDTYPEDESC      VARCHAR2(12 CHAR),
  PRDTYPEDESCL     VARCHAR2(30 CHAR),
  CNSPCKTYPE       VARCHAR2(4 CHAR),
  CNSPCKTYPEDESC   VARCHAR2(12 CHAR),
  CNSPCKTYPEDESCL  VARCHAR2(30 CHAR),
  MAT_SIZE         VARCHAR2(4 CHAR),
  SIZEDESC         VARCHAR2(12 CHAR),
  SIZEDESCL        VARCHAR2(30 CHAR),
  INGVRTY          VARCHAR2(4 CHAR),
  INGVRTYDESC      VARCHAR2(12 CHAR),
  INGVRTYDESCL     VARCHAR2(30 CHAR),
  FUNCVRTY         VARCHAR2(4 CHAR),
  FUNCVRTYDESC     VARCHAR2(12 CHAR),
  FUNCVRTYDESCL    VARCHAR2(30 CHAR),
  SIZEGRP          VARCHAR2(4 CHAR),
  SIZEGRPDESC      VARCHAR2(12 CHAR),
  SIZEGRPDESCL     VARCHAR2(30 CHAR),
  OCCSN            VARCHAR2(4 CHAR),
  OCCSNDESC        VARCHAR2(12 CHAR),
  OCCSNDESCL       VARCHAR2(30 CHAR),
  SPPLYSGMNT       VARCHAR2(4 CHAR),
  SPPLYSGMNTDESC   VARCHAR2(12 CHAR),
  SPPLYSGMNTDESCL  VARCHAR2(30 CHAR),
  IDOC_NAME        VARCHAR2(30 CHAR)            NOT NULL,
  IDOC_NUMBER      NUMBER(16)                   NOT NULL,
  IDOC_TIMESTAMP   VARCHAR2(14 BYTE)            NOT NULL,
  SIL_DATE         DATE                         NOT NULL,
  SIL_STATUS       VARCHAR2(1 BYTE)             NOT NULL,
  MKTSGMNT         VARCHAR2(4 CHAR),
  MKTSGMNTDESC     VARCHAR2(12 CHAR),
  MKTSGMNTDESCL    VARCHAR2(30 CHAR)
)
TABLESPACE CR_DATA
PCTUSED    40
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
MONITORING;

COMMENT ON TABLE CR.GRD_MAT_HDR IS 'GRD Material Header';

COMMENT ON COLUMN CR.GRD_MAT_HDR.MKTSGMNT IS 'Market Segment';

COMMENT ON COLUMN CR.GRD_MAT_HDR.MKTSGMNTDESC IS 'Market Segment Desc';

COMMENT ON COLUMN CR.GRD_MAT_HDR.MKTSGMNTDESCL IS 'Market Segment Desc Long';

COMMENT ON COLUMN CR.GRD_MAT_HDR.SPPLYSGMNTDESCL IS 'Supply Segment Desc Long';

COMMENT ON COLUMN CR.GRD_MAT_HDR.IDOC_NAME IS 'IDOC Name';

COMMENT ON COLUMN CR.GRD_MAT_HDR.IDOC_NUMBER IS 'IDOC Number';

COMMENT ON COLUMN CR.GRD_MAT_HDR.IDOC_TIMESTAMP IS 'IDOC Timestamp YYYYMMDDHHmmSS';

COMMENT ON COLUMN CR.GRD_MAT_HDR.SIL_DATE IS 'SIL Date - Load date';

COMMENT ON COLUMN CR.GRD_MAT_HDR.SIL_STATUS IS 'SIL Status - 1=Active,0=Inactive';

COMMENT ON COLUMN CR.GRD_MAT_HDR.MATNR IS 'Material Number';

COMMENT ON COLUMN CR.GRD_MAT_HDR.MAKTX IS 'Material Description';

COMMENT ON COLUMN CR.GRD_MAT_HDR.MSTAE IS 'Material Status';

COMMENT ON COLUMN CR.GRD_MAT_HDR.EAN11 IS 'EAN/UPC Code';

COMMENT ON COLUMN CR.GRD_MAT_HDR.ZZREPMATNR IS 'Representative Material Number';

COMMENT ON COLUMN CR.GRD_MAT_HDR.MTART IS 'Material Type';

COMMENT ON COLUMN CR.GRD_MAT_HDR.ZZISRSU IS 'RSU';

COMMENT ON COLUMN CR.GRD_MAT_HDR.ZZISMCU IS 'MCU';

COMMENT ON COLUMN CR.GRD_MAT_HDR.ZZISTDU IS 'TDU';

COMMENT ON COLUMN CR.GRD_MAT_HDR.ZZISINT IS 'INT';

COMMENT ON COLUMN CR.GRD_MAT_HDR.BUSSEG IS 'Business Segment';

COMMENT ON COLUMN CR.GRD_MAT_HDR.BUSSEGDESC IS 'Business Segment Desc';

COMMENT ON COLUMN CR.GRD_MAT_HDR.BUSSEGDESCL IS 'Business Segment Desc Long';

COMMENT ON COLUMN CR.GRD_MAT_HDR.BRND IS 'Brand';

COMMENT ON COLUMN CR.GRD_MAT_HDR.BRNDDESC IS 'Brand Desc';

COMMENT ON COLUMN CR.GRD_MAT_HDR.BRNDDESCL IS 'Brand Desc Long';

COMMENT ON COLUMN CR.GRD_MAT_HDR.BRNDSUB IS 'Band Sub Flag';

COMMENT ON COLUMN CR.GRD_MAT_HDR.BRNDSUBDESC IS 'Brand Sub Flag Desc';

COMMENT ON COLUMN CR.GRD_MAT_HDR.BRNDSUBDESCL IS 'Brand Sub Flag Desc Long';

COMMENT ON COLUMN CR.GRD_MAT_HDR.CNSPCKFRT IS 'Consumer Pack Format';

COMMENT ON COLUMN CR.GRD_MAT_HDR.CNSPCKFRTDESC IS 'Consumer Pack Format Desc';

COMMENT ON COLUMN CR.GRD_MAT_HDR.CNSPCKFRTDESCL IS 'Consumer Pack Format Desc Long';

COMMENT ON COLUMN CR.GRD_MAT_HDR.PRDCAT IS 'Product Category';

COMMENT ON COLUMN CR.GRD_MAT_HDR.PRDCATDESC IS 'Product Category Desc';

COMMENT ON COLUMN CR.GRD_MAT_HDR.PRDCATDESCL IS 'Product Category Desc Long';

COMMENT ON COLUMN CR.GRD_MAT_HDR.PRDTYPE IS 'Product Type';

COMMENT ON COLUMN CR.GRD_MAT_HDR.PRDTYPEDESC IS 'Product Type Desc';

COMMENT ON COLUMN CR.GRD_MAT_HDR.PRDTYPEDESCL IS 'Product Type Desc Long';

COMMENT ON COLUMN CR.GRD_MAT_HDR.CNSPCKTYPE IS 'Consumer Pack Type';

COMMENT ON COLUMN CR.GRD_MAT_HDR.CNSPCKTYPEDESC IS 'Consumer Pack Type Desc';

COMMENT ON COLUMN CR.GRD_MAT_HDR.CNSPCKTYPEDESCL IS 'Consumer Pack Type Desc Long';

COMMENT ON COLUMN CR.GRD_MAT_HDR.MAT_SIZE IS 'Size';

COMMENT ON COLUMN CR.GRD_MAT_HDR.SIZEDESC IS 'Size Desc';

COMMENT ON COLUMN CR.GRD_MAT_HDR.SIZEDESCL IS 'Size Desc Long';

COMMENT ON COLUMN CR.GRD_MAT_HDR.INGVRTY IS 'Ingredient Variety';

COMMENT ON COLUMN CR.GRD_MAT_HDR.INGVRTYDESC IS 'Ingredient Variety Desc';

COMMENT ON COLUMN CR.GRD_MAT_HDR.INGVRTYDESCL IS 'Ingredient Variety Desc Long';

COMMENT ON COLUMN CR.GRD_MAT_HDR.FUNCVRTY IS 'Functional Variety';

COMMENT ON COLUMN CR.GRD_MAT_HDR.FUNCVRTYDESC IS 'Functional Variety Desc';

COMMENT ON COLUMN CR.GRD_MAT_HDR.FUNCVRTYDESCL IS 'Functional Variety Desc Long';

COMMENT ON COLUMN CR.GRD_MAT_HDR.SIZEGRP IS 'Size Group';

COMMENT ON COLUMN CR.GRD_MAT_HDR.SIZEGRPDESC IS 'Size Group Desc';

COMMENT ON COLUMN CR.GRD_MAT_HDR.SIZEGRPDESCL IS 'Size Group Desc Long';

COMMENT ON COLUMN CR.GRD_MAT_HDR.OCCSN IS 'Occasion';

COMMENT ON COLUMN CR.GRD_MAT_HDR.OCCSNDESC IS 'Occasion Desc';

COMMENT ON COLUMN CR.GRD_MAT_HDR.OCCSNDESCL IS 'Occasion Desc Long';

COMMENT ON COLUMN CR.GRD_MAT_HDR.SPPLYSGMNT IS 'Supply Segment';

COMMENT ON COLUMN CR.GRD_MAT_HDR.SPPLYSGMNTDESC IS 'Supply Segment Desc';


CREATE UNIQUE INDEX CR.GRD_MAT_HDR_PK ON CR.GRD_MAT_HDR
(MATNR)
LOGGING
TABLESPACE CR_DATA
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
NOPARALLEL;


DROP PUBLIC SYNONYM GRD_MAT_HDR;

CREATE PUBLIC SYNONYM GRD_MAT_HDR FOR CR.GRD_MAT_HDR;


ALTER TABLE CR.GRD_MAT_HDR ADD (
  CONSTRAINT GRD_MAT_HDR_PK
 PRIMARY KEY
 (MATNR)
    USING INDEX 
    TABLESPACE CR_DATA
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
               ));

GRANT DELETE, INSERT, SELECT, UPDATE ON CR.GRD_MAT_HDR TO CR_APP WITH GRANT OPTION;


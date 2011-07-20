--
-- LADS_FLC_HDR  (Table) 
--
CREATE TABLE LADS.LADS_FLC_HDR
(
  TPLNR           VARCHAR2(40 CHAR)                 NULL,
  PLTXT           VARCHAR2(40 CHAR)                 NULL,
  EQFNR           VARCHAR2(30 CHAR)                 NULL,
  SWERK           VARCHAR2(4 CHAR)                  NULL,
  IDOC_NAME       VARCHAR2(30 CHAR)             NOT NULL,
  IDOC_NUMBER     NUMBER(16)                    NOT NULL,
  IDOC_TIMESTAMP  VARCHAR2(14 CHAR)             NOT NULL,
  LADS_DATE       DATE                          NOT NULL,
  LADS_STATUS     VARCHAR2(2 CHAR)              NOT NULL,
  LADS_FLATTENED  VARCHAR2(1 CHAR)              NOT NULL
)
TABLESPACE LADS_DATA
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


--
-- LADS_FLC_HDR_PK  (Index) 
--
CREATE UNIQUE INDEX LADS.LADS_FLC_HDR_PK ON LADS.LADS_FLC_HDR
(TPLNR)
LOGGING
TABLESPACE LADS_DATA
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


--
-- LADS_FLC_HDR  (Synonym) 
--
CREATE PUBLIC SYNONYM LADS_FLC_HDR FOR LADS.LADS_FLC_HDR;


-- 
-- Non Foreign Key Constraints for Table LADS_FLC_HDR 
-- 
ALTER TABLE LADS.LADS_FLC_HDR ADD (
  CONSTRAINT LADS_FLC_HDR_PK
 PRIMARY KEY
 (TPLNR)
    USING INDEX 
    TABLESPACE LADS_DATA
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

GRANT SELECT, UPDATE ON LADS.LADS_FLC_HDR TO BDS_APP;

GRANT SELECT ON LADS.LADS_FLC_HDR TO ICS_READER;

GRANT DELETE, INSERT, SELECT, UPDATE ON LADS.LADS_FLC_HDR TO LADS_APP;

grant delete, insert, select, update on lads.lads_flc_hdr to lics_app;

GRANT SELECT ON LADS.LADS_FLC_HDR TO APPSUPPORT;

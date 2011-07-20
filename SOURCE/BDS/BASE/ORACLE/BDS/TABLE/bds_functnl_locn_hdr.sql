--
-- BDS_FUNCTNL_LOCN_HDR  (Table) 
--
CREATE TABLE BDS.BDS_FUNCTNL_LOCN_HDR
(
  FUNCTNL_LOCN_CODE   VARCHAR2(40 CHAR)         NOT NULL,
  FUNCTNL_LOCN_DESC   VARCHAR2(40 CHAR)             NULL,
  PLANT_CODE          VARCHAR2(4 CHAR)              NULL,
  SORT_FIELD          VARCHAR2(30 CHAR)             NULL,
  SAP_IDOC_NAME       VARCHAR2(30 CHAR)             NULL,
  SAP_IDOC_NUMBER     NUMBER                        NULL,
  SAP_IDOC_TIMESTAMP  VARCHAR2(14 CHAR)             NULL,
  BDS_LADS_DATE       DATE                          NULL,
  BDS_LADS_STATUS     VARCHAR2(2 CHAR)              NULL
)
TABLESPACE BDS_DATA
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

COMMENT ON TABLE BDS.BDS_FUNCTNL_LOCN_HDR IS 'Business Data Store - Plant Maintenance Functional Location Master';

COMMENT ON COLUMN BDS.BDS_FUNCTNL_LOCN_HDR.FUNCTNL_LOCN_CODE IS 'Functional location code - lads_flc_hdr.tpnlr';

COMMENT ON COLUMN BDS.BDS_FUNCTNL_LOCN_HDR.FUNCTNL_LOCN_DESC IS 'Functional location description - lads_flc_hdr.pltxt';

COMMENT ON COLUMN BDS.BDS_FUNCTNL_LOCN_HDR.PLANT_CODE IS 'Plant code - lads_flc_hdr.swerk';

COMMENT ON COLUMN BDS.BDS_FUNCTNL_LOCN_HDR.SORT_FIELD IS 'Sort field - lads_flc_hdr.eqfnr';

COMMENT ON COLUMN BDS.BDS_FUNCTNL_LOCN_HDR.SAP_IDOC_NAME IS 'SAP IDoc name - lads_equ_hdr.idoc_name';

COMMENT ON COLUMN BDS.BDS_FUNCTNL_LOCN_HDR.SAP_IDOC_NUMBER IS 'SAP IDoc number - lads_equ_hdr.idoc_number';

COMMENT ON COLUMN BDS.BDS_FUNCTNL_LOCN_HDR.SAP_IDOC_TIMESTAMP IS 'SAP IDoc timestamp - lads_equ_hdr.idoc_timestamp';

COMMENT ON COLUMN BDS.BDS_FUNCTNL_LOCN_HDR.BDS_LADS_DATE IS 'LADS date loaded - lads_equ_hdr.lads_date';

COMMENT ON COLUMN BDS.BDS_FUNCTNL_LOCN_HDR.BDS_LADS_STATUS IS 'LADS Status - lads_equ_hdr.lads_status';


--
-- BDS_FUNCTNL_LOCN_HDR_IDX1  (Index) 
--
CREATE INDEX BDS.BDS_FUNCTNL_LOCN_HDR_IDX1 ON BDS.BDS_FUNCTNL_LOCN_HDR
(PLANT_CODE)
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
NOPARALLEL;


--
-- BDS_FUNCTNL_LOCN_HDR_PK  (Index) 
--
CREATE UNIQUE INDEX BDS.BDS_FUNCTNL_LOCN_HDR_PK ON BDS.BDS_FUNCTNL_LOCN_HDR
(FUNCTNL_LOCN_CODE)
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
NOPARALLEL;


--
-- BDS_FUNCTNL_LOCN_HDR  (Synonym) 
--
CREATE PUBLIC SYNONYM BDS_FUNCTNL_LOCN_HDR FOR BDS.BDS_FUNCTNL_LOCN_HDR;


-- 
-- Non Foreign Key Constraints for Table BDS_FUNCTNL_LOCN_HDR 
-- 
ALTER TABLE BDS.BDS_FUNCTNL_LOCN_HDR ADD (
  CONSTRAINT BDS_BDS_FUNCTNL_LOCN_HDR_PK
 PRIMARY KEY
 (FUNCTNL_LOCN_CODE));

GRANT DELETE, INSERT, SELECT, UPDATE ON BDS.BDS_FUNCTNL_LOCN_HDR TO BDS_APP;

grant select, insert, update, delete on bds.bds_functnl_locn_hdr to lads_app;

grant select, insert, update, delete on bds.bds_functnl_locn_hdr to lics_app;

grant select on bds.bds_functnl_locn_hdr to ics_app;

grant select on bds.bds_functnl_locn_hdr to ics_reader;

GRANT SELECT ON BDS.BDS_FUNCTNL_LOCN_HDR TO APPSUPPORT;

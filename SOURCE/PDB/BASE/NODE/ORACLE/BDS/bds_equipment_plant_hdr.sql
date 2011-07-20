--
-- BDS_EQUIPMENT_PLANT_HDR  (Table) 
--
CREATE TABLE BDS.BDS_EQUIPMENT_PLANT_HDR
(
  SAP_EQUIPMENT_CODE  VARCHAR2(18 CHAR)         NOT NULL,
  PLANT_CODE          VARCHAR2(4 CHAR)              NULL,
  EQUIPMENT_DESC      VARCHAR2(40 CHAR)             NULL,
  FUNCTNL_LOCN_CODE   VARCHAR2(40 CHAR)             NULL,
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

COMMENT ON COLUMN BDS.BDS_EQUIPMENT_PLANT_HDR.SAP_EQUIPMENT_CODE IS 'SAP equipment code - lads_equ_hdr.equnr';

COMMENT ON COLUMN BDS.BDS_EQUIPMENT_PLANT_HDR.PLANT_CODE IS 'Plant code - lads_equ_hdr.swerk';

COMMENT ON COLUMN BDS.BDS_EQUIPMENT_PLANT_HDR.EQUIPMENT_DESC IS 'Equipment description - lads_equ_hdr.shtxt';

COMMENT ON COLUMN BDS.BDS_EQUIPMENT_PLANT_HDR.FUNCTNL_LOCN_CODE IS 'Functional location code - lads_equ_hdr.tplnr';

COMMENT ON COLUMN BDS.BDS_EQUIPMENT_PLANT_HDR.SORT_FIELD IS 'Sort field - lads_equ_hdr.eqfnr';

COMMENT ON COLUMN BDS.BDS_EQUIPMENT_PLANT_HDR.SAP_IDOC_NAME IS 'SAP IDoc name - lads_equ_hdr.idoc_name';

COMMENT ON COLUMN BDS.BDS_EQUIPMENT_PLANT_HDR.SAP_IDOC_NUMBER IS 'SAP IDoc number - lads_equ_hdr.idoc_number';

COMMENT ON COLUMN BDS.BDS_EQUIPMENT_PLANT_HDR.SAP_IDOC_TIMESTAMP IS 'SAP IDoc timestamp - lads_equ_hdr.idoc_timestamp';

COMMENT ON COLUMN BDS.BDS_EQUIPMENT_PLANT_HDR.BDS_LADS_DATE IS 'LADS date loaded - lads_equ_hdr.lads_date';

COMMENT ON COLUMN BDS.BDS_EQUIPMENT_PLANT_HDR.BDS_LADS_STATUS IS 'LADS Status - lads_equ_hdr.lads_status';


--
-- BDS_EQUIPMENT_PLANT_HDR_IDX1  (Index) 
--
CREATE INDEX BDS.BDS_EQUIPMENT_PLANT_HDR_IDX1 ON BDS.BDS_EQUIPMENT_PLANT_HDR
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
-- BDS_EQUIPMENT_PLANT_HDR_PK  (Index) 
--
CREATE UNIQUE INDEX BDS.BDS_EQUIPMENT_PLANT_HDR_PK ON BDS.BDS_EQUIPMENT_PLANT_HDR
(SAP_EQUIPMENT_CODE)
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
-- BDS_EQUIPMENT_PLANT_HDR  (Synonym) 
--
CREATE PUBLIC SYNONYM BDS_EQUIPMENT_PLANT_HDR FOR BDS.BDS_EQUIPMENT_PLANT_HDR;


-- 
-- Non Foreign Key Constraints for Table BDS_EQUIPMENT_PLANT_HDR 
-- 
ALTER TABLE BDS.BDS_EQUIPMENT_PLANT_HDR ADD (
  CONSTRAINT BDS_EQUIPMENT_PLANT_HDR_PK
 PRIMARY KEY
 (SAP_EQUIPMENT_CODE)
    USING INDEX 
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
               ));

GRANT DELETE, INSERT, SELECT, UPDATE ON BDS.BDS_EQUIPMENT_PLANT_HDR TO BDS_APP;

GRANT DELETE, INSERT, SELECT, UPDATE ON BDS.BDS_EQUIPMENT_PLANT_HDR TO LICS_APP;

grant select on bds.bds_equipment_plant_hdr to appsupport;

grant select on bds.bds_equipment_plant_hdr to ics_reader;

--
-- LICS_ALERT  (Table) 
--
CREATE TABLE LICS.LICS_ALERT
(
  ALE_SRCH_TXT  VARCHAR2(100 BYTE)                  NULL,
  ALE_MSG_TXT   VARCHAR2(200 BYTE)                  NULL
)
TABLESPACE LICS_DATA
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;

COMMENT ON COLUMN LICS.LICS_ALERT.ALE_SRCH_TXT IS 'Alerting - search string';

COMMENT ON COLUMN LICS.LICS_ALERT.ALE_MSG_TXT IS 'Alerting - message text';


--
-- LICS_ALERT_PK  (Index) 
--
CREATE UNIQUE INDEX LICS.LICS_ALERT_PK ON LICS.LICS_ALERT
(ALE_SRCH_TXT)
LOGGING
TABLESPACE LICS_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


--
-- LICS_ALERT  (Synonym) 
--
CREATE PUBLIC SYNONYM LICS_ALERT FOR LICS.LICS_ALERT;
grant select on lics_alert to lics_exec;


-- 
-- Non Foreign Key Constraints for Table LICS_ALERT 
-- 
ALTER TABLE LICS.LICS_ALERT ADD (
  CONSTRAINT LICS_ALE_PK
 PRIMARY KEY
 (ALE_SRCH_TXT));

GRANT DELETE, INSERT, SELECT, UPDATE ON LICS.LICS_ALERT TO LICS_APP;

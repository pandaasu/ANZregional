-- This function moves data from the tempoary pmx_ar_claims_old table into the new table.  
insert into pmx_ar_claims 
select 
 -- Batch Control Fields
  intfc_batch_code as xactn_seq,
  ar_claims_seq as batch_rec_seq,
  -- SAP AR Claims Fields  
  idoc_type,
  idoc_num as idoc_no,
  idoc_date,
  cmpny_code as company_code,
  --decode(cmpny_code,'149',null,div_code) as div_code,
  div_code,
  cust_code,
  claim_amt as claim_amount,
  claim_ref,
  assignmnt_num as assignment_no,
  tax_amt as tax_base,
  postng_date as posting_date,
  period_num as fiscal_period,
  reasn_code as reason_code,
  acctg_doc_num as accounting_doc_no,
  fiscl_year as fiscal_year,
  line_item_num as line_item_no,
  bus_prtnr_ref2 as bus_partner_ref,
  tax_code,
  -- Calculated Fields
  (select count(*) from pmx_ar_claims_old t0 where t0.procg_status = 'PROCESSED' and t0.valdtn_status = 'DUPLICATE' and t0.acctg_doc_num = t1.acctg_doc_num and t0.cmpny_code = t1.cmpny_code and t0.line_item_num = t1.line_item_num and t0.fiscl_year = t1.fiscl_year) as DPLCTS_DTCTD,  
	ar_claims_lupdp as LAST_UPDTD_USER, 
	ar_claims_lupdt as LAST_UPDTD_TIME
from pmx_ar_claims_old t1
where procg_status = 'COMPLETED' and valdtn_status  = 'VALID';

commit;



-- This code creates the old promax table which data needs to be loaded into prior to running the above migration query.

CREATE TABLE PMX_AR_CLAIMS_OLD (
  INTFC_BATCH_CODE       NUMBER(15)             NOT NULL,
  CMPNY_CODE             VARCHAR2(3 BYTE)       NOT NULL,
  DIV_CODE               VARCHAR2(3 BYTE)       NOT NULL,
  AR_CLAIMS_SEQ          NUMBER(5)              NOT NULL,
  CUST_CODE              VARCHAR2(10 BYTE),
  CLAIM_AMT              VARCHAR2(15 BYTE)      NOT NULL,
  CLAIM_REF              VARCHAR2(12 BYTE),
  ASSIGNMNT_NUM          VARCHAR2(18 BYTE),
  TAX_AMT                VARCHAR2(15 BYTE)      NOT NULL,
  POSTNG_DATE            VARCHAR2(8 BYTE)       NOT NULL,
  PERIOD_NUM             VARCHAR2(2 BYTE)       NOT NULL,
  REASN_CODE             VARCHAR2(3 BYTE),
  ACCTG_DOC_NUM          VARCHAR2(10 BYTE)      NOT NULL,
  FISCL_YEAR             VARCHAR2(4 BYTE)       NOT NULL,
  LINE_ITEM_NUM          VARCHAR2(3 BYTE)       NOT NULL,
  BUS_PRTNR_REF2         VARCHAR2(12 BYTE),
  TAX_CODE               VARCHAR2(2 BYTE),
  IDOC_TYPE              VARCHAR2(30 BYTE)      NOT NULL,
  IDOC_NUM               VARCHAR2(16 BYTE)      NOT NULL,
  IDOC_DATE              VARCHAR2(14 BYTE)      NOT NULL,
  PROMAX_CUST_CODE       VARCHAR2(10 BYTE),
  PROMAX_CUST_VNDR_CODE  VARCHAR2(10 BYTE),
  PROMAX_AR_LOAD_DATE    DATE,
  PROMAX_AR_APPRVL_DATE  DATE,
  PROCG_STATUS           VARCHAR2(10 BYTE)      NOT NULL,
  VALDTN_STATUS          VARCHAR2(10 BYTE)      NOT NULL,
  AR_CLAIMS_LUPDP        VARCHAR2(8 BYTE)       NOT NULL,
  AR_CLAIMS_LUPDT        DATE                   NOT NULL
)

COMMENT ON TABLE PMX_AR_CLAIMS_OLD IS 'ar_claims Table';
COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.INTFC_BATCH_CODE IS 'Interface Batch Code';
COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.CMPNY_CODE IS 'Company Code';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.DIV_CODE IS 'Division Code';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.AR_CLAIMS_SEQ IS 'PDS AR Claims Load Sequence';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.CUST_CODE IS 'Customer Code - KACC in Promax';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.CLAIM_AMT IS 'Claim Amount';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.CLAIM_REF IS 'Claim Reference';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.ASSIGNMNT_NUM IS 'Assignment Number';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.TAX_AMT IS 'Tax Amount';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.POSTNG_DATE IS 'Posting Date';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.PERIOD_NUM IS 'Period Number';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.REASN_CODE IS 'Reason Code';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.ACCTG_DOC_NUM IS 'SAP Accounting Document Number';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.FISCL_YEAR IS 'SAP Fiscal Year';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.LINE_ITEM_NUM IS 'Line Item Number';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.BUS_PRTNR_REF2 IS 'Business Partner Reference 2';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.TAX_CODE IS 'Tax Code';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.IDOC_TYPE IS 'Idoc Basic Type (Name)';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.IDOC_NUM IS 'Idoc Number';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.IDOC_DATE IS 'Idoc Creation Date/Timestamp';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.PROMAX_CUST_CODE IS 'Customer loaded into Promax. Populated post upload.';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.PROMAX_CUST_VNDR_CODE IS 'Vendor Code - ACCCODE in Promax. Populated post upload.';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.PROMAX_AR_LOAD_DATE IS 'Claim Load (into Promax) Date/Timestamp. Populated post upload.';

COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.PROMAX_AR_APPRVL_DATE IS 'Claim Approval (from Promax) Date/Timestamp. Populated post upload.';
COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.PROCG_STATUS IS 'Processing Status';
COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.VALDTN_STATUS IS 'Validation Status';
COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.AR_CLAIMS_LUPDP IS 'Last Updated Person';
COMMENT ON COLUMN PMX_AR_CLAIMS_OLD.AR_CLAIMS_LUPDT IS 'Last Updated Time';

ALTER TABLE PMX_AR_CLAIMS_OLD ADD 
  CONSTRAINT PMX_AR_CLAIMS_OLD_PK
  PRIMARY KEY
  (INTFC_BATCH_CODE, CMPNY_CODE, DIV_CODE, AR_CLAIMS_SEQ);
--------------------------------------------------------------------------------
-- Table - SAP to Promax AR Claims Duplicate Checking Table

drop table pxi.pmx_ar_claims cascade constraints;

create table pxi.pmx_ar_claims (
  -- Batch Control Fields
  xactn_seq number(15,0),
  batch_rec_seq number(8,0),
  -- SAP AR Claims Fields  
  idoc_type varchar2(30 char),
  idoc_no number(16,0),
  idoc_date date,
  company_code varchar2(3 char),
  div_code varchar2(3 char),
  cust_code varchar2(10 char),
  claim_amount number(15,4),
  claim_ref varchar2(12 char),
  assignment_no varchar2(18 char),
  tax_base number(15,4),
  posting_date date,
  fiscal_period number(2,0),
  reason_code varchar2(3 char),
  accounting_doc_no varchar2(10 char),
  fiscal_year number(4,0),
  line_item_no varchar2(3),
  bus_partner_ref varchar2(12 char),
  tax_code varchar2(2 char),
  -- Calculated Fields
  DPLCTS_DTCTD number(8,0),  
	LAST_UPDTD_USER VARCHAR2(30 BYTE), 
	LAST_UPDTD_TIME DATE
);

-- Batch Control Fields
comment on column pxi.pmx_ar_claims.xactn_seq is 'This is the ICS interface id number that contained this data.';
comment on column pxi.pmx_ar_claims.batch_rec_seq is 'This is the internal sequence number for the claim record.';
-- SAP AR Claims Fields  
comment on column pxi.PMX_AR_CLAIMS.idoc_type is '';
comment on column pxi.PMX_AR_CLAIMS.idoc_no  is '';
comment on column pxi.PMX_AR_CLAIMS.idoc_date  is '';
comment on column pxi.PMX_AR_CLAIMS.company_code  is '';
comment on column pxi.PMX_AR_CLAIMS.div_code  is '';
comment on column pxi.PMX_AR_CLAIMS.cust_code  is '';
comment on column pxi.PMX_AR_CLAIMS.claim_amount  is '';
comment on column pxi.PMX_AR_CLAIMS.claim_ref  is '';
comment on column pxi.PMX_AR_CLAIMS.assignment_no  is '';
comment on column pxi.PMX_AR_CLAIMS.tax_base  is '';
comment on column pxi.PMX_AR_CLAIMS.posting_date  is '';
comment on column pxi.PMX_AR_CLAIMS.fiscal_period  is '';
comment on column pxi.PMX_AR_CLAIMS.reason_code  is '';
comment on column pxi.PMX_AR_CLAIMS.accounting_doc_no  is '';
comment on column pxi.PMX_AR_CLAIMS.fiscal_year  is '';
comment on column pxi.PMX_AR_CLAIMS.line_item_no  is '';
comment on column pxi.PMX_AR_CLAIMS.bus_partner_ref  is '';
comment on column pxi.PMX_AR_CLAIMS.tax_code  is '';

-- Calculated Fields
COMMENT ON COLUMN pxi.PMX_AR_CLAIMS.LAST_UPDTD_USER IS 'The user that first uploaded or reprocessed the interface that supplied this data.';
COMMENT ON COLUMN pxi.PMX_AR_CLAIMS.LAST_UPDTD_TIME IS 'The time that this supplied data was loaded or reprocessed.';
COMMENT ON COLUMN pxi.PMX_AR_CLAIMS.DPLCTS_DTCTD IS 'This is the number of times a duplicate has been seen for this record.';

comment on table pxi.pmx_ar_claims is 'Promax PX AR Claims Duplicate Interface Checking Table.';

-- Primary Key 
alter table pxi.pmx_ar_claims add constraint pmx_ar_claims_pk primary key (xactn_seq, batch_rec_seq);
  
-- Unique Index
create unique index pmx_ar_claims_uk01 on pxi.pmx_ar_claims (company_code,fiscal_year,accounting_doc_no,line_item_no);
-- Non Unique Keys 
create index pmx_ar_claims_nuk02 on pxi.pmx_ar_claims (company_code,div_code,cust_code,claim_ref);

-- Synonym
create or replace public synonym pmx_ar_claims for pxi.pmx_ar_claims;

-- Grants
grant select, insert, update, delete on pxi.pmx_ar_claims to pxi_app;


-- Now create a table for the duplicates to be stored in. 
drop table pxi.pmx_ar_claims_dups cascade constraints;

create table pxi.pmx_ar_claims_dups (
  -- Batch Control Fields
  xactn_seq number(15,0),
  batch_rec_seq number(8,0),
  -- SAP AR Claims Fields  
  idoc_type varchar2(30 char),
  idoc_no number(16,0),
  idoc_date date,
  company_code varchar2(3 char),
  div_code varchar2(3 char),
  cust_code varchar2(10 char),
  claim_amount number(15,4),
  claim_ref varchar2(12 char),
  assignment_no varchar2(18 char),
  tax_base number(15,4),
  posting_date date,
  fiscal_period number(2,0),
  reason_code varchar2(3 char),
  accounting_doc_no varchar2(10 char),
  fiscal_year number(4,0),
  line_item_no varchar2(3),
  bus_partner_ref varchar2(12 char),
  tax_code varchar2(2 char),
  -- Calculated Fields
	LAST_UPDTD_USER VARCHAR2(30 BYTE), 
	LAST_UPDTD_TIME DATE,
  DUP_TYPE VARCHAR2(20 BYTE)
);
-- Batch Control Fields
comment on column pxi.pmx_ar_claims_dups.xactn_seq is 'This is the ICS interface id number that contained this data.';
comment on column pxi.pmx_ar_claims_dups.batch_rec_seq is 'This is the internal sequence number for the claim record.';

-- SAP AR Claims Fields  
comment on column pxi.pmx_ar_claims_dups.idoc_type is '';
comment on column pxi.pmx_ar_claims_dups.idoc_no  is '';
comment on column pxi.pmx_ar_claims_dups.idoc_date  is '';
comment on column pxi.pmx_ar_claims_dups.company_code  is '';
comment on column pxi.pmx_ar_claims_dups.div_code  is '';
comment on column pxi.pmx_ar_claims_dups.cust_code  is '';
comment on column pxi.pmx_ar_claims_dups.claim_amount  is '';
comment on column pxi.pmx_ar_claims_dups.claim_ref  is '';
comment on column pxi.pmx_ar_claims_dups.assignment_no  is '';
comment on column pxi.pmx_ar_claims_dups.tax_base  is '';
comment on column pxi.pmx_ar_claims_dups.posting_date  is '';
comment on column pxi.pmx_ar_claims_dups.fiscal_period  is '';
comment on column pxi.pmx_ar_claims_dups.reason_code  is '';
comment on column pxi.pmx_ar_claims_dups.accounting_doc_no  is '';
comment on column pxi.pmx_ar_claims_dups.fiscal_year  is '';
comment on column pxi.pmx_ar_claims_dups.line_item_no  is '';
comment on column pxi.pmx_ar_claims_dups.bus_partner_ref  is '';
comment on column pxi.pmx_ar_claims_dups.tax_code  is '';

-- Calculated Fields
COMMENT ON COLUMN pxi.pmx_ar_claims_dups.LAST_UPDTD_USER IS 'The user that first uploaded or reprocessed the interface that supplied this data.';
COMMENT ON COLUMN pxi.pmx_ar_claims_dups.LAST_UPDTD_TIME IS 'The time that this supplied data was loaded or reprocessed.';
COMMENT ON COLUMN pxi.pmx_ar_claims_dups.dup_type IS 'This is the type of duplicate that was detected.';

comment on table pxi.pmx_ar_claims_dups is 'Promax PX AR Claims Duplicate Interface Checking Table.';

-- Primary Key 
alter table pxi.pmx_ar_claims_dups add constraint pmx_ar_claims_dups_pk primary key (xactn_seq, batch_rec_seq);
  
-- Synonym
create or replace public synonym pmx_ar_claims_dups for pxi.pmx_ar_claims_dups;

-- Grants
grant select, insert, update, delete on pxi.pmx_ar_claims_dups to pxi_app;

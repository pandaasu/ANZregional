CREATE OR REPLACE package PXI_APP.pxiatl01_extract as
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System  : PXI - Promax PX Interfacing System
  Owner   : PXI_APP
  Package : PXIATL01_EXTEACT
  Author  : Chris Horn

  Description
  ------------------------------------------------------------------------------
  This package is used to create general ledger IDOCs to be on sent 
  to Atlas via ICS Interface: CISATL03, IDOC:ACC_DOCUMENT02.
  
  Currently it used by the the following promax interfaces.
  PMXPXI01_LOADER - Accruals - 325
  PMXPXI02_LOADER - Once for AP Payments / Once for AR Claims - 331
  
  Functions
  ------------------------------------------------------------------------------
  + Interface Functions 
    - add_general_ledger_record   - Adds a general ledger record.
    - add_payment_record          - Adds a payment record. 
    - add_header_record           - Adds a header record.  Called after others.
    - add_tax_record              - Adds a tax record.
    - create_interface            - Creates and sends interface to ICS.
    - debug_interface             - Can be used to output the data to DBMS_OUTPUT.

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-06-29  Chris Horn            Created
  2013-07-30  Chris Horn            Completed First Version
  2013-08-02  Chris Horn            Included Code Balanced IDOC amounts. 

*******************************************************************************/

/*******************************************************************************
  Interface Data Types
*******************************************************************************/
  -- Sub Type for Interface Output Data 
  subtype st_data is varchar2(4000);
  -- Record Type for Interface Output Data
  type tt_data is table of st_data index by pls_integer;
  
  -- Document Types
  subtype st_doc_type is varchar2(2); 
  gc_doc_type_accrual          st_doc_type := 'ZA'; -- Accrual
  gc_doc_type_accrual_reversal st_doc_type := 'ZB'; -- Accrual Reversal
  gc_doc_type_ap_claim         st_doc_type := 'KN'; -- Accounts Payable Journal
  gc_doc_type_ar_claim         st_doc_type := 'UE'; -- Accounts Receivable
  
/*******************************************************************************
  Generic General Ledger Table 
*******************************************************************************/
  -- General Ledger Record
  type rt_gl_record is record (
    -- Key Document Header Fields New IDOC on a change on any of these records.
    company pxi_common.st_company,
    promax_division pxi_common.st_promax_division,
    document_date date,
    posting_date date,
    currency pxi_common.st_currency,
    -- General detail records 
    account_code pxi_common.st_gl_code,
    cost_center pxi_common.st_gl_code,
    profit_center pxi_common.st_gl_code,
    amount pxi_common.st_amount,
    tax_amount pxi_common.st_amount,
    tax_amount_base pxi_common.st_amount,
    tax_code pxi_common.st_tax_code,
    alloc_ref pxi_common.st_reference,
    item_text pxi_common.st_text,
    -- COPA / Transactional Fields.
    vendor_code pxi_common.st_vendor,
    customer_code pxi_common.st_customer,
    -- COPA Related Fields
    material_code pxi_common.st_material,
    plant_code pxi_common.st_plant_code,
    sales_org pxi_common.st_company,
    dstrbtn_chnnl pxi_common.st_dstrbtn_chnnl,
    -- Claims fields
    claim_text pxi_common.st_text
  );
  -- General Ledger Table.
  type tt_gl_data is table of rt_gl_record index by pls_integer;

/*******************************************************************************
  Package Constants
*******************************************************************************/
  -- Search for a general ledger balancing record with x records of full idoc.
  gc_search_for_balance constant pls_integer := 20;
  -- Number of rows to allow for the header and footer. 
  gc_rows_for_header_footer constant pls_integer := 3;

/*******************************************************************************
  NAME:      ADD_GENERAL_LEDGER_RECORD                                   PRIVATE
  PURPOSE:   This procedure creates a correctly formatted general ledger record.
          
             Note : This should be called before creating the header and tax 
                    records.
  
  ------------------------------------------------------------------------------------------------------------
  Field Name           Description                                     Record FldOutputField  Copybook # Times
  ------------------------------------------------------------------------------------------------------------
  INDICATOR            Record Type = "G"                                   1.4  1     1X(1)                  5
  GL_ACCOUNT           G/L Account Number                                  1.4  2    10X(10)                 1
  AMOUNT               Amount                                              1.4  3    23X(23)                 4
  ITEM_TEXT            Item Text                                           1.4  4    50X(50)                 3
  ALLOC_NMBR           Allocation Number                                   1.4  5    18X(18)                 3
  TAX_CODE             Tax Code                                            1.4  6     2X(2)                  4
  COSTCENTER           Cost Center                                         1.4  7    10X(10)                 1
  ORDERID              Internal Order                                      1.4  8    12X(12)                 1
  WBS_ELEMENT          WBS Element                                         1.4  9    24X(24)                 1
  QUANTITY             Quantity                                            1.4 10    13X(13)                 1
  BASE_UOM             Base Unit of Measure                                1.4 11     3X(3)                  1
  MATERIAL             Material (CO-PA Posting)                            1.4 12    18X(18)                 1
  PLANT                Plant (CO-PA Posting)                               1.4 13     4X(4)                  1
  CUSTOMER             Customer (CO-PA Posting)                            1.4 14    10X(10)                 1
  PROFIT CENTER        Profit Center (CO-PA Posting)                       1.4 15    10X(10)                 1
  SALES ORG            Sales Organisation                                  1.4 16     4X(4)                  1
  DIST CHANNEL         Distribution Channel                                1.4 17     2X(2)                  1
  ------------------------------------------------------------------------------------------------------------

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  procedure add_general_ledger_record(ti_data in out tt_data, 
      i_account in st_data, i_cost_center in st_data, i_profit_center in st_data, 
      i_amount in pxi_common.st_amount, i_item_text in st_data, i_alloc_ref in st_data,
      i_tax_code in pxi_common.st_tax_code, i_material in st_data, 
      i_plant_code in st_data, i_cust_code in st_data, i_sales_org in st_data,
      i_distribution_channel in st_data);

/*******************************************************************************
  NAME:      ADD_AP_CLAIM_RECORD                                          PUBLIC
  PURPOSE:   This procedure creates a correctly formatted vendor payment record.
          
             Note : This should be called before creating the header and tax 
                    records.
  
  ------------------------------------------------------------------------------------------------------------
  Field Name           Description                                     Record FldOutputField  Copybook # Times
  ------------------------------------------------------------------------------------------------------------
  INDICATOR            Record Type = "P"                                   1.2  1     1X(1)                  5
  VENDOR_NO            Vendor Number                                       1.2  2    10X(10)                 1
  AMOUNT               Amount                                              1.2  3    23X(23)                 4
  PMNTTRMS             Payment Terms                                       1.2  4     4X(4)                  2
  BLINE_DATE           Baseline Date                                       1.2  5     8YYYYMMDD              2
  PMNT_BLOCK           Payment Block                                       1.2  6     1X(1)                  2
  ALLOC_NMBR           Allocation Number                                   1.2  7    18X(18)                 3
  ITEM_TEXT            Item Text                                           1.2  8    50X(50)                 3
  W_TAX_CODE           Withholding Tax Code                                1.2  9     2X(2)                  1
  DISC_BASE            Discount Base                                       1.2 10    23X(23)                 1
  ------------------------------------------------------------------------------------------------------------

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  procedure add_ap_claim_record(ti_data in out tt_data, 
      i_vendor in st_data, i_amount in pxi_common.st_amount, 
      i_alloc_ref in st_data, i_item_text in st_data);


/*******************************************************************************
  NAME:      ADD_AR_CLAIM_RECORD                                          PUBLIC
  PURPOSE:   The procedure creates a correctly formatted customer cliam record.
          
             Note : This should be called before creating the header and tax 
                    records.

  ------------------------------------------------------------------------------------------------------------
  Field Name           Description                                     Record FldOutputField  Copybook # Times
  ------------------------------------------------------------------------------------------------------------
  INDICATOR            Record Type = "R"                                   1.3  1     1X(1)                  5
  CUSTOMER             Customer Number                                     1.3  2    10X(10)                 2
  AMOUNT               Amount                                              1.3  3    23X(23)                 4
  PMNTTRMS             Payment Terms                                       1.3  4     4X(4)                  2
  BLINE_DATE           Baseline Date                                       1.3  5     8YYYYMMDD              2
  PMNT_BLOCK           Payment Block                                       1.3  6     1X(1)                  2
  ALLOC_NMBR           Allocation Number                                   1.3  7    18X(18)                 3
  ITEM_TEXT            Item Text                                           1.3  8    50X(50)                 3
  DUNN_BLOCK           Dunn Block                                          1.3  9     1X                     1
  ------------------------------------------------------------------------------------------------------------

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-08-02 Chris Horn           Created.

*******************************************************************************/
  procedure add_ar_claim_record(ti_data in out tt_data, 
    i_cust_code in st_data, i_amount in pxi_common.st_amount, 
    i_alloc_ref in st_data, i_item_text in st_data);

/*******************************************************************************
  NAME:      ADD_HEADER_RECORD                                             
  PURPOSE:   This procedure creates a correctly formatted idoc header record.
          
             Note : This should be called after the data rows have been created
                    and before the tax record is calculated.
  
  ------------------------------------------------------------------------------------------------------------
  Field Name           Description                                     Record FldOutputField  Copybook # Times
  ------------------------------------------------------------------------------------------------------------
  INDICATOR            Record Type = "H"                                     1  1     1X(1)                  5
  OBJ_TYPE             Object Type                                           1  2     5X(5)                  1
  OBJ_KEY              Object Key                                            1  3    20X(20)                 1
  BUS_ACT              Business Transaction                                  1  4     4X(4)                  1
  USERNAME             Username                                              1  5    12X(12)                 1
  HEADER_TEXT          Header Text                                           1  6    25X(25)                 1
  COMP_CODE            Company Code                                          1  7     4X(4)                  1
  DOC_CURR             Document Currency                                     1  8     5X(5)                  1
  DOC_DATE             Document Date                                         1  9     8YYYYMMDD              1
  PSTNG_DATE           Posting Date                                          1 10     8YYYYMMDD              1
  TRANS_DATE           Exchange Rate Translation Date                        1 11     8YYYYMMDD              1
  DOC_TYPE             Document Type                                         1 12     2X(2)                  1
  REF_DOC_NO           Reference Document Number                             1 13    16X(16)                 1
  LOG_SYS              Logical System                                        1 14    10X(10)                 2
  EXCH_RATE            Direct Exchange Rate                                  1 15     9X(9)                  1
  EXCH_RATE_INDIRECT   Indirect Exchange Rate                                1 16     9X(9)                  1
  AC_DOC_NO            Accounting Document Number                            1 17    10X(10)                 1
  ------------------------------------------------------------------------------------------------------------

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  procedure add_header_record(ti_data in out tt_data, i_company in st_data, 
    i_division in st_data,i_currency in st_data, i_doc_type in st_doc_type, 
    i_doc_date in date, i_posting_date in date, i_reference_doc_no in st_data);


/*******************************************************************************
  NAME:      ADD_TAX_RECORD                                               PUBLIC
  PURPOSE:   This procedure creates a correctly formatted tax record.
          
             Note : This should be called after the data rows have been created
                    and after the the header record has been created.  
  
  ------------------------------------------------------------------------------------------------------------
  Field Name           Description                                     Record FldOutputField  Copybook # Times
  ------------------------------------------------------------------------------------------------------------
  INDICATOR            Record Type = "T"                                   1.5  1     1X(1)                  5
  TAX_CODE             Tax Code (Actual Tax Item)                          1.5  2     2X(2)                  4
  AMOUNT               Amount                                              1.5  3    23X(23)                 4
  AMT_BASE             Base Amount for Tax Item                            1.5  4    23X(23)                 1
  COND_KEY             Condition Key                                       1.5  5     4X(4)                  1
  ACCT_KEY             Account Key                                         1.5  6     3X(4)                  1
  AUTO_TAX             Automatic Tax Determination                         1.5  7     1X(1)                  0
  ------------------------------------------------------------------------------------------------------------

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  procedure add_tax_record(ti_data in out tt_data, i_tax_code in pxi_common.st_tax_code, 
      i_tax in pxi_common.st_amount, i_tax_base in pxi_common.st_amount);

/*******************************************************************************
  NAME:      CREATE_INTERFACE                                             PUBLIC
  PURPOSE:   This procedure is used to actually create the interface output it 
             is assumed that it will confirm to the atlas size requirements.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  procedure create_interface(ti_data in out tt_data);

/*******************************************************************************
  NAME:      DEBUG_INTERFACE                                              PUBLIC
  PURPOSE:   This procedure can be called with the interface data to extract 
             that data to DBMS_OUTPUT as needed.  

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  procedure debug_interface(ti_data in tt_data);

  
/*******************************************************************************
  NAME:      SUM_AMMOUNT                                                  PUBLIC
  PURPOSE:   This procedure takes the supplied GL Records and sums the amount
             fields.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-08-02 Chris Horn           Created.

*******************************************************************************/
  function sum_gl_data(ti_gl_data in tt_gl_data) return pxi_common.st_amount;

/*******************************************************************************
  NAME:      SEND_DATA                                                    PUBLIC
  PURPOSE:   This procedure takes the supplied gl data records and creates 
             the corresponding set of Atlas IDOC interfaces.  

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  procedure send_data(
    ti_gl_data in tt_gl_data, 
    i_doc_type in st_doc_type,
    i_doc_reference in st_data);

end pxiatl01_extract;
/

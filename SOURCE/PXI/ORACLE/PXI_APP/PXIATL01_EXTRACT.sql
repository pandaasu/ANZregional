create or replace 
package          pxiatl01_extract as
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
    - add_payment   
    - add_general
    - add_receipt
    - calculate_tax 
    - create_interface 

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-06-29  Chris Horn            Created

*******************************************************************************/

/*******************************************************************************
  Data Table Declaration
*******************************************************************************/
-- Internal General Ledger Record
type tr_gl_record record (
  indicator varchar2(1 char),  -- Record Type Indicator
  tax_code varchar2(2 char);
)

-- Table to contain the data for the interface.
type tt_gl_data is table of tr_gl_record; 

/*******************************************************************************
  NAME:      ADD_PAYMENT
  PURPOSE:   Provides a function to add a payment information to the table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-06-29 Chris Horn           Created.

*******************************************************************************/
  procedure add_payment();

end pxiatl01_extract;

/*******************************************************************************  
Interface - Output Structure 
********************************************************************************

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

INDICATOR            Record Type = "R"                                   1.3  1     1X(1)                  5
CUSTOMER             Customer Number                                     1.3  2    10X(10)                 2
AMOUNT               Amount                                              1.3  3    23X(23)                 4
PMNTTRMS             Payment Terms                                       1.3  4     4X(4)                  2
BLINE_DATE           Baseline Date                                       1.3  5     8YYYYMMDD              2
PMNT_BLOCK           Payment Block                                       1.3  6     1X(1)                  2
ALLOC_NMBR           Allocation Number                                   1.3  7    18X(18)                 3
ITEM_TEXT            Item Text                                           1.3  8    50X(50)                 3
DUNN_BLOCK           Dunn Block                                          1.3  9     1X                     1

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

INDICATOR            Record Type = "T"                                   1.5  1     1X(1)                  5
TAX_CODE             Tax Code (Actual Tax Item)                          1.5  2     2X(2)                  4
AMOUNT               Amount                                              1.5  3    23X(23)                 4
AMT_BASE             Base Amount for Tax Item                            1.5  4    23X(23)                 1
COND_KEY             Condition Key                                       1.5  5     4X(4)                  1
ACCT_KEY             Account Key                                         1.5  6     3X(4)                  1
AUTO_TAX             Automatic Tax Determination                         1.5  7     1X(1)                  0

*******************************************************************************/


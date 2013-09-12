create or replace 
package pxi_common as

/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : PXI
  Owner     : PXI_APP
  Package   : PXI_COMMON
  Author    : Chris Horn, Mal Chambeyron, Jonathan Girling
  Interface : Promax PX Common Interfacing System Utilities

  Description
  ------------------------------------------------------------------------------
  This package is used to supply common handling and processing functions to 
  the various Promax PX interfacing packages.  The Promax Extract formatting 
  constants and functions in particular are used within SQL queries to 
  quickly produces extracts for promax in the correct layout and format.

  Functions
  ------------------------------------------------------------------------------
  + Exception and Error Handling
    - raise_promax_error         Creates a promax error as an exception.
    - raise_promax_exception     Used to report "when others" exceptions.
  + Code Formatting Functions
    - full_matl_code             Correctly formats material codes.
    - short_matl_code            Correctly formats short material codes.
    - full_cust_code             Correctly formats full customer code.
    - full_vend_code             Correctly formats full vendor code.
  + Promax Extract Formatting Constants
    - fc_is_nullable             Function constant for nullable fields.
    - fc_is_not_nullable         Function constant for not nullable fields.
    - fc_format_type_none        Function constant for no triming. 
    - fc_format_type_trim        Function constant for timing whitespace.
    - fc_format_type_ltrim       Function constant for triming left whitepace.
    - fc_format_type_rtrim       Function constant for triming right whitespace.
    - fc_format_type_ltrim_zeros Function constant for triming leading zeros.
  + Promax Extract Formatting Functions
    - char_format                Formats character fields.
    - numb_format                Formats number fields.
    - date_format                Formats date fields.
  + Promax Configuration
    - promax_config              Pipelined promax configuration data.

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-07-27  Mal Chambeyron        Initial promax formatting functions created.
  2013-07-30  Chris Horn            Updated this package with comments and
                                    material functions. 
  2013-08-02  Chris Horn            Added added additional logic checks. 
  2013-08-09  Jonathan Girling		  Added SE Tax Code
  2013-08-20  Chris Horn            Split out to make common between Venus and
                                    LADS, added promax configuration pipe table.
  2013-08-28  Chris Horn            Added customer division codes.

*******************************************************************************/

/*******************************************************************************
  Common Promax PX Interfacing System Constants / Exception Definitions
*******************************************************************************/
  ge_promax_exception exception;
  pragma exception_init(ge_promax_exception, -20000);

/*******************************************************************************
  Common Package Types
*******************************************************************************/
  -- Package System Sub Types
  subtype st_interface_name is varchar2(32 char); -- The ICS Interface Name.
  subtype st_package_name is varchar2(32 char);   -- Package Names  
  subtype st_method_name is varchar2(32 char);    -- Oracle Procedure / Function names  
  subtype st_data is varchar2(4000);              -- Data field for large data records.
  -- Promax Data Types.
  subtype st_company is varchar2(3 char);         -- Company 
  subtype st_promax_division is varchar2(3 char); -- Promax Division  
  subtype st_material is varchar2(18 char);       -- Material Codes. 
  subtype st_gl_code is varchar2(10 char);        -- GL Account, Account Code, Cost Object
  subtype st_customer is varchar2(10 char);       -- Customer
  subtype st_vendor is varchar2(10 char);         -- Vendor
  subtype st_amount is number(22,2);              -- Dollars / Amounts
  subtype st_reference is varchar2(18 char);      -- Reference Fields.
  subtype st_text is varchar2(50 char);           -- Text Fields.
  subtype st_string is varchar2(4000 char);       -- Long String field for messages.
  subtype st_bus_sgmnt is varchar2(2 char);       -- Business Segment Code
  subtype st_cust_division is varchar2(2 char);   -- Customer Division
  subtype st_plant_code is varchar2(4 char);      -- Atlas Plant Code.
  subtype st_dstrbtn_chnnl is varchar2(2 char);   -- Distribution Channel
  subtype st_currency is varchar2(3 char);        -- Currency Information
  subtype st_reason_code is varchar2(2 char);     -- Reason Code
  subtype st_tax_code is varchar2(2);             -- Tax Code

/*******************************************************************************
  Common Constants
*******************************************************************************/
  -- Company Constants / Sales Org Constants
  gc_new_zealand  constant st_company := '149';
  gc_australia    constant st_company := '147';
  -- Business Segment / Material Division Constants
  gc_bus_sgmnt_snack    constant st_bus_sgmnt := '01';
  gc_bus_sgmnt_food     constant st_bus_sgmnt := '02';
  gc_bus_sgmnt_petcare  constant st_bus_sgmnt := '05';
  -- Customer Divivision Constants 
  gc_cust_division_non_specific constant st_cust_division := '51';
  gc_cust_division_food         constant st_cust_division := '57';
  gc_cust_division_snack        constant st_cust_division := '55';
  gc_cust_division_petcare      constant st_cust_division := '56';

  -- Distribution Channel 
  gc_distrbtn_channel_primary  constant st_dstrbtn_chnnl := '10'; -- Primary Channel
  -- Tax Codes
  gc_tax_code_gl               constant st_tax_code := 'GL';  -- General Ledger Tax Code
  gc_tax_code_s1               constant st_tax_code := 'S1';  -- S1 - Tax Rate 1
  gc_tax_code_s2               constant st_tax_code := 'S2';  -- S2 - Tax Rate 2
  gc_tax_code_s3               constant st_tax_code := 'S3';  -- S3 - No Tax.
  gc_tax_code_se               constant st_tax_code := 'SE';  -- SE - No Tax.
  -- Maximum rows per idoc output. 
  gc_max_idoc_rows constant pls_integer := 909;  
  
/*******************************************************************************
  NAME:      RAISE_PROMAX_ERROR                                           PUBLIC
  PURPOSE:   This function formats a the current SQL Error message with a 
             message and raises it as an application exception.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  procedure raise_promax_error(
    i_package_name in st_package_name,
    i_method in st_method_name, 
    i_message in st_string);

/*******************************************************************************
  NAME:      RERAISE_PROMAX_EXCEPTION                                     PUBLIC
  PURPOSE:   This function formats a the current SQL Error message with a 
             message and reraises it as an application exception. 
             
             This can be called in the when others sections of most methods
             as needed.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  procedure reraise_promax_exception(
    i_package_name in st_package_name,
    i_method in st_method_name);
  
/*******************************************************************************
  NAME:      FULL_MATL_CODE                                               PUBLIC
  PURPOSE:   This procedure correctly formats a material code into is long 
             normal SAP format.  Returns zeros if material code is null.  

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  function full_matl_code(i_matl_code in st_material) return st_material;

/*******************************************************************************
  NAME:      SHORT_MATL_CODE                                              PUBLIC
  PURPOSE:   This procedure correctly formats a material code into is short 
             format.  

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  function short_matl_code(i_matl_code in st_material) return st_material;


/*******************************************************************************
  NAME:      FULL_CUST_CODE                                               PUBLIC
  PURPOSE:   This procedure correctly formats a customer code into is long 
             normal SAP format.  Returns zeros if customer code is null.  

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  function full_cust_code (i_cust_code in st_customer) return st_customer;

/*******************************************************************************
  NAME:      FULL_VEND_CODE                                             PUBLIC
  PURPOSE:   This procedure correctly formats a vendor code into is long 
             normal SAP format.  Returns zeros if vendor code is null.  

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-08-02 Chris Horn           Created.

*******************************************************************************/
  function full_vend_code (i_vendor_code in st_vendor) return st_vendor;

/*******************************************************************************
  NAME:      FUNCTIONS AS CONSTANTS FOR FORMATTING FUNCTIONS              PUBLIC
  PURPOSE:   The following function constants are used as input paramters
             into the formatting functions used when producing correctly
             formatted output files for Promax. 
  
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-26 Mal Chambeyron       Created.
  1.2   2013-08-20 Chris Horn           Updated with new exception logic.

*******************************************************************************/
  -- Null / Not Null Functions
  function fc_is_nullable return number;
  function fc_is_not_nullable return number;
  -- Format Type Functions. 
  function fc_format_type_none return number;
  function fc_format_type_trim return number;
  function fc_format_type_ltrim return number;
  function fc_format_type_rtrim return number;
  function fc_format_type_ltrim_zeros return number;
  
/*******************************************************************************
  NAME:      CHAR_FORMAT                                                  PUBLIC
  PURPOSE:   This function produces correctly formated text fields of the 
             correct length and type, and also performs necessary validations.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-27 Mal Chameyron        Created.
  1.2   2013-08-20 Chris Horn           Updated exception handling and format.

*******************************************************************************/
  function char_format(
    i_value in varchar2, 
    i_length in number, 
    i_format_type in number, 
    i_value_is_nullable in number) return varchar2;

/*******************************************************************************
  NAME:      NUMB_FORMAT                                                  PUBLIC
  PURPOSE:   This function produces correctly formated number fields of the 
             correct length and type, and also performs necessary validations.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-27 Mal Chameyron        Created.
  1.2   2013-08-20 Chris Horn           Updated exception handling and format.

*******************************************************************************/
  function numb_format(
    i_value in number, 
    i_format in varchar2, 
    i_value_is_nullable in number) return varchar2;

/*******************************************************************************
  NAME:      DATE_FORMAT                                                  PUBLIC
  PURPOSE:   This function produces correctly formated date fields of the 
             correct length and type, and also performs necessary validations.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-27 Mal Chameyron        Created.
  1.2   2013-08-20 Chris Horn           Updated exception handling and format.

*******************************************************************************/
  function date_format(
    i_value in date, 
    i_format in varchar2, 
    i_value_is_nullable in number) return varchar2;

/*******************************************************************************
  NAME:      PROMAX_CONFIG                                                PUBLIC
  PURPOSE:   This function produces a piplined table output that can be used
             by all the various extract packages.  It returns all the 
             combinations that are live or available for extraction / use.
             
             This is a pipelined table function as the only time this data 
             should change is when new code has been written, also being in 
             code ensures that this updated package is rolled out to both
             Venus and Lads correctly.  It also prevents the need for creating 
             configuration tables in DDS and PXI.  
             
             It also provides some special logic around what it returns.  ie.
             If both filter parameters are supplied, it returns just that data 
             back as the only record, even if that site is not yet live.
             
             If only one or no paramter are supplied then just the matching 
             live sites are returned.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-08-20 Chris Horn           Created.
  
*******************************************************************************/
  -- Interface Group List Record
  type rt_promax_config is record (
    promax_company st_company,          -- Valid companies
    promax_division st_promax_division, -- Valid division for this company.
    cust_division st_cust_division    -- Equivalent Customer Division.
  );

  -- Interface Group List Table
  type tt_promax_config is table of rt_promax_config;

  -- Pipelined table function to retrieve the interface group list.
  function promax_config(
    i_promax_company in st_company default null, 
    i_promax_division in st_promax_division default null) return tt_promax_config pipelined;

end pxi_common;
/

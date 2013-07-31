create or replace package pxi_common as

/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : PXI
  Owner     : PXI_APP
  Package   : PXI_COMMON
  Author    : Chris Horn, Mal Chamberyron, Jonathan Girling
  Interface : Promax PX Common Interfacing System Utilities

  Description
  ------------------------------------------------------------------------------
  This package is used to supply common handling and processing functions to 
  the various Promax PX interfacing packages.

  Functions
  ------------------------------------------------------------------------------
  + Formatting Functions
    - full_matl_code             Correctly formats material codes.
    - short_matl_code            Correctly formats short material codes.
  + Lookup Functions.
    - lookup_tdu_from_zrep       Looks up a TDU from a ZREP based on dates.  

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-07-30  Chris Horn            Updated this package with comments and
                                    material functions. 

*******************************************************************************/

/*******************************************************************************
  Common Promax PX Interfacing System Constants / Exception Definitions
*******************************************************************************/
  gc_application_exception pls_integer := -20000;  -- Custom Exception Code.
  ge_application_exception exception;
  pragma exception_init(ge_application_exception, -20000);

/*******************************************************************************
  Common Package Types
*******************************************************************************/
  -- Package Sub Types
  subtype st_material is varchar2(18);      -- Material Codes. 
  subtype st_gl_code is varchar2(10);        -- GL Account, Account Code, Cost Object
  subtype st_company is varchar2(3);         -- Company 
  subtype st_customer is varchar2(10);       -- Customer
  subtype st_vendor is varchar2(10);         -- Vendor
  subtype st_amount is number(22,2);         -- Dollars / Amounts
  subtype st_reference is varchar2(18);      -- Reference Fields.
  subtype st_text is varchar2(50);           -- Text Fields.
  subtype st_string is varchar2(4000);       -- Long String field for messages.
  subtype st_package_name is varchar2(32);   -- Package Names  
  subtype st_bus_sgmnt is varchar2(2);       -- Business Segment Code
  subtype st_plant_code is varchar2(4);      -- Atlas Plant Code.
  subtype st_dstrbtn_chnnl is varchar2(2);   -- Distribution Channel
  subtype st_promax_division is varchar2(3); -- Promax Division  
  subtype st_currency is varchar2(3);        -- Currency Information

/*******************************************************************************
  Common Constants
*******************************************************************************/
  -- Company Constants / Sales Org Constants
  gc_new_zealand  st_company := '149';
  gc_australia    st_company := '147';
  -- Business Segment Constants
  gc_bus_sgmnt_snack    st_bus_sgmnt := '01';
  gc_bus_sgmnt_food     st_bus_sgmnt := '02';
  gc_bus_sgmnt_petcare  st_bus_sgmnt := '05';
  -- Distribution Channel 
  gc_distrbtn_channel_primary   st_dstrbtn_chnnl := '10'; -- Primary Channel

/*******************************************************************************
  NAME:      RAISE_PROMAX_ERROR                                           PUBLIC
  PURPOSE:   This function formats a the current SQL Error message with a 
             message and raises it as an application exception.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  procedure raise_promax_error(i_message in st_string);

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
  procedure reraise_promax_exception(i_method in st_string);
  
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
  NAME:      LOOKUP_TDU_FROM_ZREP                                         PUBLIC
  PURPOSE:   This function looks up a current tdu for a given zrep and sales
             organisation and buying dates.  Null is returned if no 
             material could be found within that range.  

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  function lookup_tdu_from_zrep (
    i_sales_org in st_company,
    i_zrep_matl_code in st_material,
    i_buy_start_date in date,
    i_buy_end_date in date
    ) return st_material;

/*******************************************************************************
  NAME:      DETERMINE_BUS_SGMNT                                          PUBLIC
  PURPOSE:   This function uses the promax disvision to determine
             the business sgement we should be using for subsequent processing
             for New Zealand it will find the business segement from the 
             current zrep material.  

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  function determine_bus_sgmnt (
    i_sales_org in st_company,
    i_promax_division in st_promax_division,
    i_zrep_matl_code in st_material) return st_bus_sgmnt;


/*******************************************************************************
  NAME:      DETERMINE_DSTRBTN_CHNNL                                      PUBLIC
  PURPOSE:   Using the sales org, material and customer information search for 
             distribution channel infromation.  Giving preference to 
             distribution channel '10'.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
 FUNCTION determine_dstrbtn_chnnl (
    i_sales_org in st_company, 
    i_matl_code IN st_material, 
    i_cust_code in st_customer
    ) RETURN st_dstrbtn_chnnl;

/*******************************************************************************
  NAME:      DETERMINE_MATL_PLANT_CODE                                    PUBLIC
  PURPOSE:   Using company information and material information find an 
             approperiate plant code to use for the lookup. 

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  FUNCTION determine_matl_plant_code (
    i_company_code in st_company,
    i_matl_code IN st_material)
    return st_plant_code;


/*******************************************************************************
********************************************************************************
  CODE BELOW HERE STILL NEEDS TO BE REFORMATTED AND TIDIED UP.
********************************************************************************
*******************************************************************************/


/*******************************************************************************
  NAME:      format_cust_code
  PURPOSE:   This function formats Customer Codes by left padding with '0' to
             10 characters with numeric Customer Codes.  If the Customer Code
             is not numeric then it is right padded with spaces to 10 characters.
             This is the required format when extracting to SAP.

********************************************************************************/
FUNCTION format_cust_code (
  i_cust_code IN VARCHAR2,
  o_cust_code OUT VARCHAR2
  --i_log_level IN NUMBER,
  --o_result_msg OUT VARCHAR2
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      format_pmx_cust_code
  PURPOSE:   This function formats Promax Customer Codes by left trimming '0's from
             the passed Customer Code.

********************************************************************************/
FUNCTION format_pmx_cust_code (
  i_cust_code IN VARCHAR2,
  o_pmx_cust_code OUT VARCHAR2
  --i_log_level IN NUMBER,
  --o_result_msg OUT VARCHAR2
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      format_matl_code
  PURPOSE:   Materials have leading zeroes if they are numeric, otherwise the
             field is left justified with spaces padding (on the right). The
             width returned is 18 characters.

********************************************************************************/
FUNCTION format_matl_code (
  i_matl_code IN VARCHAR2,
  o_matl_code OUT VARCHAR2
  --i_log_level IN NUMBER,
  --o_result_msg OUT VARCHAR2
  ) RETURN NUMBER;
  

/*******************************************************************************
  NAME:      format_pmx_matl_code
  PURPOSE:   Material Codes have leading zeroes if they are numeric. These leading
             zeroes need to be trimmed if they are to be inserted into Promax.

********************************************************************************/
FUNCTION format_pmx_matl_code (
  i_matl_code IN VARCHAR2,
  o_matl_code OUT VARCHAR2
  --i_log_level IN NUMBER,
  --o_result_msg OUT VARCHAR2
  ) RETURN NUMBER;



function char_format(i_value in varchar2, i_length in number, i_format_type in number, i_value_is_nullable in number) return varchar2;
function numb_format(i_value in number, i_format in varchar2, i_value_is_nullable in number) return varchar2;
function date_format(i_value in date, i_format in varchar2, i_value_is_nullable in number) return varchar2;

function is_nullable return number;
function is_not_nullable return number;

function format_type_none return number;
function format_type_trim return number;
function format_type_ltrim return number;
function format_type_rtrim return number;
function format_type_ltrim_zeros return number;




/*******************************************************************************
  NAME:      lookup_matl_tdu_num
  PURPOSE:   This function looks up the material TDU Number.

********************************************************************************/
function lookup_matl_tdu_num (
    i_matl_zrep_code    in  varchar2,
    o_matl_tdu_code     out varchar2,
    i_buy_start_date    in  date,
    i_buy_end_date      in  date
  ) return number;
  
  
/*******************************************************************************
  NAME:      lookup_distbn_chnl_code
  PURPOSE:   This function looks up the distribution channel code. 
  
********************************************************************************/
function lookup_distbn_chnl_code (
    i_cust_code         in  varchar2,
    o_distbn_chnl_code     out varchar2
  ) return number;


/*******************************************************************************
  NAME:      lookup_division_code
  PURPOSE:   This function looks up the division code. 
  
********************************************************************************/
function lookup_division_code (
    i_matl_tdu_code     in  varchar2,
    o_division_code     out varchar2
  ) return number;


/*******************************************************************************
  NAME:      lookup_plant_code
  PURPOSE:   This function looks up the plant code. 
  
********************************************************************************/
function lookup_plant_code (
    i_matl_tdu_code     in  varchar2,
    o_plant_code        out varchar2
  ) return number;

end pxi_common;
/

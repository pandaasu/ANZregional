prompt :: Compile Package [pxi_common] ::::::::::::::::::::::::::::::::::::::::::::::::

create or replace package pxi_common as
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
  + Promax Function Constants
    - fc_new_zealand                  Function constant for Company - New Zealand
    - fc_gc_australia                 Function constant for Company - Australia
    - fc_bus_sgmnt_snack              Function constant for Business Segment / Material Division - Snack
    - fc_bus_sgmnt_food               Function constant for Business Segment / Material Division - Food
    - fc_bus_sgmnt_petcare            Function constant for Business Segment / Material Division - Petcare
    - fc_cust_division_non_specific   Function constant for Customer Division - Non Specific
    - fc_cust_division_food           Function constant for Customer Division - Food
    - fc_cust_division_snack          Function constant for Customer Division - Snack
    - fc_cust_division_petcare        Function constant for Customer Division - Petcare
    - fc_moe_nz                       Function constant for Segment MOE - New Zealand
    - fc_moe_pet                      Function constant for Segment MOE - Pet
    - fc_moe_food                     Function constant for Segment MOE - Food
    - fc_moe_snack                    Function constant for Segment MOE - Snack
    - fc_interface_snack              Function constant for Interface Sufix - Snack
    - fc_interface_food               Function constant for Interface Sufix - Food
    - fc_interface_pet                Function constant for Interface Sufix - Pet
    - fc_interface_nz                 Function constant for Interface Sufix - NZ
    - fc_distrbtn_channel_primary     Function constant for Distribution Channel - Primary
    - fc_tax_code_gl                  Function constant for Tax Codes - General Ledger Tax Code
    - fc_tax_code_s1                  Function constant for Tax Codes - S1 - Tax Rate 1
    - fc_tax_code_s2                  Function constant for Tax Codes - S2 - Tax Rate 2
    - fc_tax_code_s3                  Function constant for Tax Codes - S3 - No Tax
    - fc_tax_code_se                  Function constant for Tax Codes - SE - No Tax
    - fc_max_idoc_rows                Function constant for Maximum rows per iDoc output
    - fc_is_nullable                  Function constant for Format Nullable - Nullable fields
    - fc_is_not_nullable              Function constant for Format Nullable - Not nullable fields
    - fc_format_type_none             Function constant for Format Type - No triming
    - fc_format_type_trim             Function constant for Format Type - Triming whitespace
    - fc_format_type_ltrim            Function constant for Format Type - Triming left whitepace
    - fc_format_type_rtrim            Function constant for Format Type - Triming right whitespace
    - fc_format_type_ltrim_zeros      Function constant for Format Type - Triming leading zeros
  + Exception and Error Handling
    - raise_promax_error              Creates a promax error as an exception.
    - raise_promax_exception          Used to report "when others" exceptions.
  + Code Formatting Functions
    - full_matl_code                  Correctly formats material codes.
    - short_matl_code                 Correctly formats short material codes.
    - full_cust_code                  Correctly formats full customer code.
    - full_vend_code                  Correctly formats full vendor code.
  + Promax Extract Formatting Functions
    - char_format                     Formats character fields.
    - numb_format                     Formats number fields.
    - date_format                     Formats date fields.
  + Promax Configuration
    - promax_config                   Pipelined promax configuration data.
    - promax_interface_suffix         Function to return appropriate interface suffix

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
  2013-11-30  Chris Horn            Removed the promax virtual configuration
                                    table as it has been replaced with a real
                                    table.
  2014-01-14  Mal Chambeyron        Modified [char_format] to substitute "safe"
                                    character "?" in place of non-single-byte
                                    characters
  2014-01-17  Mal Chambeyron        Added function constants [fc] for all
                                    global constants [gc] to allow use in
                                    regular sql (outside of package)
  2014-01-20  Mal Chambeyron        Added [promax_interface_suffix] to return
                                    appropriate interface suffix
  2014-01-20  Mal Chambeyron        Merged in [df_app.pxi_common] Segment MOE Codes
  2014-01-20  Mal Chambeyron        Added back [promax_config] till all interfaces
                                    migrated to [pxi.pmx_extract_criteria]
                                    *** TO BE REMOVED AGAIN on COMPLETION of MIGRATION ***
  2014-01-21  Chris Horn            Added a exception no-data-needed exception.
  2014-01-21  Mal Chambeyron        Added "Field Name" (and Backward Compatible 
                                    Wrapper Function) to Extract Formatting 
                                    Function Error Messages
                                    [char_format], [numb_format], [date_format]

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
  subtype st_moe_code is varchar2(4);             -- Moe Code

/*******************************************************************************
  Common Constants and "Function Constants" to facilitate use in common sql
*******************************************************************************/

  -- Company Constants / Sales Org Constants
  gc_new_zealand                  constant st_company := '149';
  gc_australia                    constant st_company := '147';
  function fc_new_zealand return st_company;
  function fc_australia return st_company;

  -- Business Segment / Material Division Constants
  gc_bus_sgmnt_snack              constant st_bus_sgmnt := '01';
  gc_bus_sgmnt_food               constant st_bus_sgmnt := '02';
  gc_bus_sgmnt_petcare            constant st_bus_sgmnt := '05';
  function fc_bus_sgmnt_snack return st_bus_sgmnt;
  function fc_bus_sgmnt_food return st_bus_sgmnt;
  function fc_bus_sgmnt_petcare return st_bus_sgmnt;

  -- Customer Divivision Constants
  gc_cust_division_non_specific   constant st_cust_division := '51';
  gc_cust_division_food           constant st_cust_division := '57';
  gc_cust_division_snack          constant st_cust_division := '55';
  gc_cust_division_petcare        constant st_cust_division := '56';
  function fc_cust_division_non_specific return st_cust_division;
  function fc_cust_division_food return st_cust_division;
  function fc_cust_division_snack return st_cust_division;
  function fc_cust_division_petcare return st_cust_division;

  -- Segment MOE Codes
  gc_moe_nz                       constant st_moe_code := '0086';
  gc_moe_pet                      constant st_moe_code := '0196';
  gc_moe_food                     constant st_moe_code := '0021';
  gc_moe_snack                    constant st_moe_code := '0009';
  function fc_moe_nz return st_moe_code;
  function fc_moe_pet return st_moe_code;
  function fc_moe_food return st_moe_code;
  function fc_moe_snack return st_moe_code;

  -- Interface Sufix's
  gc_interface_snack              constant fflu_common.st_interface := '1';
  gc_interface_food               constant fflu_common.st_interface := '2';
  gc_interface_pet                constant fflu_common.st_interface := '3';
  gc_interface_nz                 constant fflu_common.st_interface := '4';
  function fc_interface_snack return fflu_common.st_interface;
  function fc_interface_food return fflu_common.st_interface;
  function fc_interface_pet return fflu_common.st_interface;
  function fc_interface_nz return fflu_common.st_interface;

  -- Distribution Channel
  gc_distrbtn_channel_primary     constant st_dstrbtn_chnnl := '10'; -- Primary Channel
  function fc_distrbtn_channel_primary return st_dstrbtn_chnnl;

  -- Tax Codes
  gc_tax_code_gl                  constant st_tax_code := 'GL';  -- General Ledger Tax Code
  gc_tax_code_s1                  constant st_tax_code := 'S1';  -- S1 - Tax Rate 1
  gc_tax_code_s2                  constant st_tax_code := 'S2';  -- S2 - Tax Rate 2
  gc_tax_code_s3                  constant st_tax_code := 'S3';  -- S3 - No Tax.
  gc_tax_code_se                  constant st_tax_code := 'SE';  -- SE - No Tax.
  function fc_tax_code_gl return st_tax_code;
  function fc_tax_code_s1 return st_tax_code;
  function fc_tax_code_s2 return st_tax_code;
  function fc_tax_code_s3 return st_tax_code;
  function fc_tax_code_se return st_tax_code;

  -- Maximum rows per idoc output.
  gc_max_idoc_rows                constant pls_integer := 909;
  function fc_max_idoc_rows return pls_integer;

  -- Constants used in formatting functions

  -- Null / Not Null
  gc_is_nullable                  constant number := 1;
  gc_is_not_nullable              constant number := 0;
  function fc_is_nullable return number;
  function fc_is_not_nullable return number;

  -- Format Type
  gc_format_type_none             constant number := 0;
  gc_format_type_trim             constant number := 1;
  gc_format_type_ltrim            constant number := 2;
  gc_format_type_rtrim            constant number := 3;
  gc_format_type_ltrim_zeros      constant number := 4;
  function fc_format_type_none return number;
  function fc_format_type_trim return number;
  function fc_format_type_ltrim return number;
  function fc_format_type_rtrim return number;
  function fc_format_type_ltrim_zeros return number;

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
  NAME:      CHAR_FORMAT                                                  PUBLIC
  PURPOSE:   This function produces correctly formated text fields of the
             correct length and type, and also performs necessary validations.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-27 Mal Chameyron        Created.
  1.2   2013-08-20 Chris Horn           Updated exception handling and format.
  1.3   2014-01-14 Mal Chambeyron       Modified [char_format] to substitute "safe"
                                        character "?" in place of non-single-byte
                                        characters
  1.4   2014-01-21 Mal Chambeyron       Added "Field Name" (and Backward Compatible 
                                        Wrapper Function) to Extract Formatting 
                                        Function Error Messages

*******************************************************************************/
  function char_format(
    i_field_name in varchar2,
    i_value in varchar2,
    i_length in number,
    i_format_type in number,
    i_value_is_nullable in number
  ) return varchar2;

  function char_format( -- helper function for backward compatibility
    i_value in varchar2,
    i_length in number,
    i_format_type in number,
    i_value_is_nullable in number
  ) return varchar2;

/*******************************************************************************
  NAME:      NUMB_FORMAT                                                  PUBLIC
  PURPOSE:   This function produces correctly formated number fields of the
             correct length and type, and also performs necessary validations.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-27 Mal Chameyron        Created.
  1.2   2013-08-20 Chris Horn           Updated exception handling and format.
  1.3   2014-01-21 Mal Chambeyron       Added "Field Name" (and Backward Compatible 
                                        Wrapper Function) to Extract Formatting 
                                        Function Error Messages

*******************************************************************************/
  function numb_format(
    i_field_name in varchar2,
    i_value in number,
    i_format in varchar2,
    i_value_is_nullable in number
  ) return varchar2;
  
  function numb_format( -- helper function for backward compatibility
    i_value in number,
    i_format in varchar2,
    i_value_is_nullable in number
  ) return varchar2;

/*******************************************************************************
  NAME:      DATE_FORMAT                                                  PUBLIC
  PURPOSE:   This function produces correctly formated date fields of the
             correct length and type, and also performs necessary validations.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-27 Mal Chameyron        Created.
  1.2   2013-08-20 Chris Horn           Updated exception handling and format.
  1.3   2014-01-21 Mal Chambeyron       Added "Field Name" (and Backward Compatible 
                                        Wrapper Function) to Extract Formatting 
                                        Function Error Messages

*******************************************************************************/
  function date_format(
    i_field_name in varchar2,
    i_value in date,
    i_format in varchar2,
    i_value_is_nullable in number
  ) return varchar2;

  function date_format( -- helper function for backward compatibility
    i_value in date,
    i_format in varchar2,
    i_value_is_nullable in number
  ) return varchar2;
  
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
  1.2   2013-10-14 Chris Horn           Added concept of interface suffix.

*******************************************************************************/
  -- Interface Group List Record
  type rt_promax_config is record (
    promax_company st_company,          -- Valid companies
    promax_division st_promax_division, -- Valid division for this company.
    cust_division st_cust_division,     -- Equivalent Customer Division.
    interface_suffix fflu_common.st_interface  -- Interface sufix to use.
  );

  -- Interface Group List Table
  type tt_promax_config is table of rt_promax_config;

  -- Pipelined table function to retrieve the interface group list.
  function promax_config(
    i_promax_company in st_company default null,
    i_promax_division in st_promax_division default null) return tt_promax_config pipelined;

/*******************************************************************************
  NAME:  PROMAX_INTERFACE_SUFFIX                                          PUBLIC
  PURPOSE:   This function returns the appropriate interface suffix for a given
             promax company / division combination

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-01-20 Mal Chameyron        Created.
*******************************************************************************/

  function promax_interface_suffix(
    i_promax_company in st_company,
    i_promax_division in st_promax_division -- ~ Material Business Segment
    ) return fflu_common.st_interface;
    
end pxi_common;
/

create or replace 
package body pxi_common is

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant st_package_name := 'PXI_COMMON';
  pc_promax_exception pls_integer := -20000;
  pc_undefined_field_name constant varchar2(64 char) := 'UNDEFINED';

/*******************************************************************************
  NAME:  HELPER FUNCTIONS - Functions to Return Package Constants         PUBLIC
*******************************************************************************/

  -- Company Constants / Sales Org Constants
  function fc_new_zealand return st_company is begin return gc_new_zealand; end fc_new_zealand;
  function fc_australia return st_company is begin return gc_australia; end fc_australia;

  -- Business Segment / Material Division Constants
  function fc_bus_sgmnt_snack return st_bus_sgmnt is begin return gc_bus_sgmnt_snack; end fc_bus_sgmnt_snack;
  function fc_bus_sgmnt_food return st_bus_sgmnt is begin return gc_bus_sgmnt_food; end fc_bus_sgmnt_food;
  function fc_bus_sgmnt_petcare return st_bus_sgmnt is begin return gc_bus_sgmnt_petcare; end fc_bus_sgmnt_petcare;

  -- Customer Divivision Constants
  function fc_cust_division_non_specific return st_cust_division is begin return gc_cust_division_non_specific; end fc_cust_division_non_specific;
  function fc_cust_division_food return st_cust_division is begin return gc_cust_division_food; end fc_cust_division_food;
  function fc_cust_division_snack return st_cust_division is begin return gc_cust_division_snack; end fc_cust_division_snack;
  function fc_cust_division_petcare return st_cust_division is begin return gc_cust_division_petcare; end fc_cust_division_petcare;

  -- Segment MOE Codes
  function fc_moe_nz return st_moe_code is begin return gc_moe_nz; end fc_moe_nz;
  function fc_moe_pet return st_moe_code is begin return gc_moe_pet; end fc_moe_pet;
  function fc_moe_food return st_moe_code is begin return gc_moe_food; end fc_moe_food;
  function fc_moe_snack return st_moe_code is begin return gc_moe_snack; end fc_moe_snack;

  -- Interface Sufix's
  function fc_interface_snack return fflu_common.st_interface is begin return gc_interface_snack; end fc_interface_snack;
  function fc_interface_food return fflu_common.st_interface is begin return gc_interface_food; end fc_interface_food;
  function fc_interface_pet return fflu_common.st_interface is begin return gc_interface_pet; end fc_interface_pet;
  function fc_interface_nz return fflu_common.st_interface is begin return gc_interface_nz; end fc_interface_nz;

  -- Distribution Channel
  function fc_distrbtn_channel_primary return st_dstrbtn_chnnl is begin return gc_distrbtn_channel_primary; end fc_distrbtn_channel_primary;

  -- Tax Codes
  function fc_tax_code_gl return st_tax_code is begin return gc_tax_code_gl; end fc_tax_code_gl;
  function fc_tax_code_s1 return st_tax_code is begin return gc_tax_code_s1; end fc_tax_code_s1;
  function fc_tax_code_s2 return st_tax_code is begin return gc_tax_code_s2; end fc_tax_code_s2;
  function fc_tax_code_s3 return st_tax_code is begin return gc_tax_code_s3; end fc_tax_code_s3;
  function fc_tax_code_se return st_tax_code is begin return gc_tax_code_se; end fc_tax_code_se;

  -- Maximum rows per idoc output.
  function fc_max_idoc_rows return pls_integer is begin return gc_max_idoc_rows; end fc_max_idoc_rows;

  -- Constants used in formatting functions

  -- Null / Not Null
  function fc_is_nullable return number is begin return gc_is_nullable; end;
  function fc_is_not_nullable return number is begin return gc_is_not_nullable; end;

  -- Format Type
  function fc_format_type_none return number is begin return gc_format_type_none; end;
  function fc_format_type_trim return number is begin return gc_format_type_trim; end;
  function fc_format_type_ltrim return number is begin return gc_format_type_ltrim; end;
  function fc_format_type_rtrim return number is begin return gc_format_type_rtrim; end;
  function fc_format_type_ltrim_zeros return number is begin return gc_format_type_ltrim_zeros; end;

/*******************************************************************************
  NAME:  RERAISE_PROMAX_EXCEPTION                                         PUBLIC
*******************************************************************************/
  procedure reraise_promax_exception(
    i_package_name in st_package_name,
    i_method in st_method_name
  ) is
  begin
    raise_application_error(pc_promax_exception,substr(upper(i_package_name) || '.' || upper(i_method) || ' - ' || SQLERRM,1,4000));
  end reraise_promax_exception;

/*******************************************************************************
  NAME:  RAISE_PROMAX_EXCEPTION                                           PUBLIC
*******************************************************************************/
  procedure raise_promax_error(
    i_package_name in st_package_name,
    i_method in st_method_name,
    i_message in st_string) is
  begin
    raise_application_error(pc_promax_exception,substr(upper(i_package_name) || '.' || upper(i_method) || ' - ' || i_message,1,4000));
  end raise_promax_error;

/*******************************************************************************
  NAME:  FULL_MATL_CODE                                                   PUBLIC
*******************************************************************************/
  function full_matl_code (i_matl_code in st_material) return st_material is
    v_result st_material;
    v_firstchar st_material;
  begin
    -- Trim the inputted Material Code.
    v_result := ltrim(i_matl_code);

    -- Return zero if Material Code is null.
    if v_result is null then
      v_result := '0';
    end if;

    -- Check whether the first character is a number. If so, then left pad with zero's to
    -- eighteen characters. Otherwise right pad with white spaces to eighteen characters.
    v_firstchar := substr(v_result,1,1);
    if v_firstchar >= '0' and v_firstchar <= '9' then
      v_result := lpad(v_result,18,'0');
    else
      v_result := rpad(v_result,18,' ');
    end if;
    return v_result;
  exception
    when others then
      reraise_promax_exception(pc_package_name,'FULL_MATL_CODE');
  end full_matl_code;

/*******************************************************************************
  NAME:  SHORT_MATL_CODE                                                  PUBLIC
*******************************************************************************/
  function short_matl_code (i_matl_code in st_material) return st_material is
  begin
    return trim (ltrim (i_matl_code, '0') );
  exception
    when others then
      reraise_promax_exception(pc_package_name,'SHORT_MATL_CODE');
  end short_matl_code;

/*******************************************************************************
  NAME:  FULL_CUST_CODE                                                  PUBLIC
*******************************************************************************/
  function full_cust_code (i_cust_code in st_customer) return st_customer is
  begin
    return lpad(nvl(i_cust_code,'0'),10,'0');
  exception
    when others then
      reraise_promax_exception(pc_package_name,'FULL_CUST_CODE');
  end full_cust_code;

/*******************************************************************************
  NAME:  FULL_VEND_CODE                                                   PUBLIC
*******************************************************************************/
  function full_vend_code (i_vendor_code in st_vendor) return st_vendor is
  begin
    return lpad(nvl(i_vendor_code,'0'),10,'0');
  exception
    when others then
      reraise_promax_exception(pc_package_name,'FULL_VEND_CODE');
  end full_vend_code;

/*******************************************************************************
  NAME:  CHAR_FORMAT                                                      PUBLIC
*******************************************************************************/
  function char_format(
    i_value in varchar2,
    i_length in number,
    i_format_type in number,
    i_value_is_nullable in number
  ) return varchar2 is
  begin
      return char_format(pc_undefined_field_name, i_value, i_length, i_format_type, i_value_is_nullable);
  end char_format;

  function char_format(
    i_field_name in varchar2,
    i_value in varchar2,
    i_length in number,
    i_format_type in number,
    i_value_is_nullable in number
  ) return varchar2 is
    
    c_method_name constant st_method_name := 'CHAR_FORMAT';
    v_value st_data;
  begin
    if i_length is null then
      raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Length CANNOT be NULL');
    end if;

    if i_format_type is null then
      raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Format Type CANNOT be NULL');
    end if;

    if i_value_is_nullable is null then
      raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Value Is Nullable CANNOT be NULL');
    end if;

    if i_value is null then
      if i_value_is_nullable = fc_is_nullable then
        return rpad(' ', i_length,' '); -- return empty string of correct length
      else
        raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Value CANNOT be NULL');
      end if;
    end if;

    case i_format_type
      when fc_format_type_none then
        v_value := i_value;
      when fc_format_type_trim then
        v_value := trim(i_value);
      when fc_format_type_ltrim then
        v_value := ltrim(i_value);
      when fc_format_type_rtrim then
        v_value := rtrim(i_value);
      when fc_format_type_ltrim_zeros then
        v_value := ltrim(i_value, '0');
      else
        raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Invalid Format Type ['||i_format_type||']');
    end case;

    -- Substitute "?" for non-single-btye-characters
    if length(v_value) != lengthb(v_value) then
      for v_position in 1..length(v_value)
      loop
        if length(substr(v_value, v_position, 1)) != lengthb(substr(v_value, v_position, 1)) then
          v_value := replace(v_value, substr(v_value, v_position, 1), '?');
        end if;
      end loop;
    end if;

    if length(v_value) > i_length then
      raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Value ['||v_value||'] Length ['||length(v_value)||'] Greater Than Length Provided ['||i_length||']');
    else
      return rpad(v_value, i_length, ' ');
    end if;

  exception
    when ge_promax_exception then
      raise;
    when others then
      reraise_promax_exception(pc_package_name,c_method_name);
  end char_format;

/*******************************************************************************
  NAME:  NUMB_FORMAT                                                      PUBLIC
*******************************************************************************/
  function numb_format(
    i_value in number,
    i_format in varchar2,
    i_value_is_nullable in number
  ) return varchar2 is
  begin
      return numb_format(pc_undefined_field_name, i_value, i_format, i_value_is_nullable);
  end;

  function numb_format(
    i_field_name in varchar2,
    i_value in number,
    i_format in varchar2,
    i_value_is_nullable in number
  ) return varchar2 is
    
    c_method_name constant st_method_name := 'NUMB_FORMAT';
    v_value varchar2(128 char);
  begin
    if i_format is null then
      raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Format CANNOT be NULL');
    end if;

    if i_value_is_nullable is null then
      raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Value Is Nullable CANNOT be NULL');
    end if;

    if i_value is null then
      if i_value_is_nullable = fc_is_nullable then
        return rpad(' ', length(i_format)); -- return empty string of correct length
      else
        raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Value CANNOT be NULL');
      end if;
    elsif i_value < 0 and upper(substr(i_format,1,1)) != 'S' then
      raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Value ['||i_value||'] CANNOT be Negative, without Format ['||i_format||'] Including S Prefix');
    end if;

    begin
      v_value := trim(to_char(i_value, i_format));
    exception
      when others then
        raise_promax_error(pc_package_name,c_method_name,substrb('Field Name ['||i_field_name||'] Format ['||i_format||'] on Value ['||i_value||'] Failed : '||SQLERRM, 1, 4000));
    end;

    if instr(v_value, '#') > 0 then
      raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Format ['||i_format||'] on Value ['||i_value||']');
    end if;

    if upper(substr(i_format,1,1)) = 'S' then
      v_value := replace(v_value, '+', ' ');
    end if;

    if length(v_value) > length(i_format) then
      raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Format Length ['||i_format||']['||length(i_format)||'] < Value Length ['||i_value||']['||length(v_value)||']');
    end if;

    return lpad(v_value, length(i_format));

  exception
    when ge_promax_exception then
      raise;
    when others then
      reraise_promax_exception(pc_package_name,c_method_name);
  end numb_format;

/*******************************************************************************
  NAME:  DATE_FORMAT                                                      PUBLIC
*******************************************************************************/
  function date_format(
    i_value in date,
    i_format in varchar2,
    i_value_is_nullable in number
  ) return varchar2 is
  begin
      return date_format(pc_undefined_field_name, i_value, i_format, i_value_is_nullable);
  end;

  function date_format(
    i_field_name in varchar2,
    i_value in date,
    i_format in varchar2,
    i_value_is_nullable in number
  ) return varchar2 is
    
    c_method_name constant st_method_name := 'DATE_FORMAT';
  begin

    if i_format is null then
      raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Format CANNOT be NULL');
    end if;

    if i_value_is_nullable is null then
        raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Value Is Nullable CANNOT be NULL');
    end if;

    if i_value is null then
      if i_value_is_nullable = fc_is_nullable then
        return rpad(' ',length(i_format)); -- return empty string of correct length
      else
        raise_promax_error(pc_package_name,c_method_name,'Field Name ['||i_field_name||'] Value CANNOT be NULL');
      end if;
    end if;

    begin
      return to_char(i_value, i_format);
    exception
      when others then
        raise_promax_error(pc_package_name,c_method_name,substrb('Field Name ['||i_field_name||'] Format ['||i_format||'] on Value ['||i_value||'] Failed : '||SQLERRM, 1, 4000));
    end;

  exception
    when ge_promax_exception then
      raise;
    when others then
      reraise_promax_exception(pc_package_name,c_method_name);
  end date_format;

/*******************************************************************************
  NAME:  PROMAX_CONFIG                                                    PUBLIC
*******************************************************************************/
  function promax_config(
    i_promax_company in st_company default null,
    i_promax_division in st_promax_division default null
    ) return tt_promax_config pipelined is
    c_method_name constant st_method_name := 'PROMAX_CONFIG';
    c_live constant boolean := true;
    c_not_live constant boolean := false;
    rv_row rt_promax_config;

    function add_row(i_live in boolean) return boolean is
      v_result boolean;
    begin
      v_result := false;
      -- Check if both records have been supplied in which case return then even if not yet live.
      if i_promax_company is not null and i_promax_division is not null then
        if rv_row.promax_company = i_promax_company and rv_row.promax_division = i_promax_division then
          v_result := true;
        end if;
      else
        -- Only include rows that are live from this point onwards.
        if i_live = true then
          if i_promax_company is null and i_promax_division is null then
            v_result := true;
          else
            if i_promax_company is null and rv_row.promax_division = i_promax_division then
              v_result := true;
            end if;
            if i_promax_division is null and rv_row.promax_company = i_promax_company then
              v_result := true;
            end if;
          end if;
        end if;
      end if;
      return v_result;
    end add_row;

  begin
    -- Now add new zealand data as necessary.
    rv_row.promax_company := gc_new_zealand;
    rv_row.promax_division := gc_new_zealand;
    rv_row.cust_division := gc_cust_division_non_specific;
    rv_row.interface_suffix := gc_interface_nz;
    if add_row(c_live) = true then
      pipe row(rv_row);
    end if;

    -- Add Australia Petcare Configuration
    rv_row.promax_company := gc_australia;
    rv_row.promax_division := gc_bus_sgmnt_petcare;
    rv_row.cust_division := gc_cust_division_petcare;
    rv_row.interface_suffix := gc_interface_pet;
    if add_row(c_live) = true then
      pipe row(rv_row);
    end if;

    -- Add Australia Food Configuration
    rv_row.promax_company := gc_australia;
    rv_row.promax_division := gc_bus_sgmnt_food;
    rv_row.cust_division := gc_cust_division_food;
    rv_row.interface_suffix := gc_interface_food;
    if add_row(c_not_live) = true then
      pipe row(rv_row);
    end if;

    -- Add Australia Snackfood Configuration
    rv_row.promax_company := gc_australia;
    rv_row.promax_division := gc_bus_sgmnt_snack;
    rv_row.cust_division := gc_cust_division_snack;
    rv_row.interface_suffix := gc_interface_snack;
    if add_row(c_not_live) = true then
      pipe row(rv_row);
    end if;

  exception
    -- Where the calling function has found all the rows it needs this exception may be raised.  Ignore at this point.
    when no_data_needed then 
      null;
    when ge_promax_exception then
      raise;
    when others then
      reraise_promax_exception(pc_package_name,c_method_name);
  end promax_config;

/*******************************************************************************
  NAME:  PROMAX_INTERFACE_SUFFIX                                          PUBLIC
*******************************************************************************/
  function promax_interface_suffix(
    i_promax_company in st_company,
    i_promax_division in st_promax_division -- ~ Material Business Segment
    ) return fflu_common.st_interface is
    c_method_name constant st_method_name := 'PROMAX_INTERFACE_SUFFIX';
  begin

    case i_promax_company
      when gc_australia then
        case i_promax_division
          when gc_bus_sgmnt_snack then return gc_interface_snack;
          when gc_bus_sgmnt_food then return gc_interface_food;
          when gc_bus_sgmnt_petcare then return gc_interface_pet;
          else raise_promax_error(pc_package_name,c_method_name,'Unknown Promax [Company:Division] Combination ['||i_promax_company||':'||i_promax_division||'].');
        end case;
      when gc_new_zealand then
        case i_promax_division
          when gc_new_zealand then return gc_interface_nz;
          else raise_promax_error(pc_package_name,c_method_name,'Unknown Promax [Company:Division] Combination ['||i_promax_company||':'||i_promax_division||'].');
        end case;
      else raise_promax_error(pc_package_name,c_method_name,'Unknown Promax [Company:Division] Combination ['||i_promax_company||':'||i_promax_division||'].');
    end case;

  exception
    when ge_promax_exception then
      raise;
    when others then
      reraise_promax_exception(pc_package_name,c_method_name);
  end promax_interface_suffix;
  
end pxi_common;
/

-- Grants
grant execute	on pxi_common to lics_app;


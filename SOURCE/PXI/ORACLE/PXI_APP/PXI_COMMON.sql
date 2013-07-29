create or replace package pxi_common as


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

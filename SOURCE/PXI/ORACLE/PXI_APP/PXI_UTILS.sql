create or replace 
package pxi_utils as

/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : PXI
  Owner     : PXI_APP
  Package   : PXI_UTILS
  Author    : Chris Horn, Mal Chamberyron, Jonathan Girling
  Interface : Promax PX Utility Interfacing and Lookup Utilities

  Description
  ------------------------------------------------------------------------------
  This package is used to supply common handling and processing functions to 
  the various Promax PX interfacing packages, mostly along the lines 
  of data lookups and determinations.

  Functions
  ------------------------------------------------------------------------------
  + Lookup Functions.
    - lookup_tdu_from_zrep       Looks up a TDU from a ZREP based on dates.  

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-08-20  Chris Horn            Created from old PXI_COMMON Package.

*******************************************************************************/

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
    i_sales_org in pxi_common.st_company,
    i_zrep_matl_code in pxi_common.st_material,
    i_buy_start_date in date,
    i_buy_end_date in date
    ) return pxi_common.st_material;

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
    i_sales_org in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_zrep_matl_code in pxi_common.st_material) return pxi_common.st_bus_sgmnt;


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
 function determine_dstrbtn_chnnl (
    i_sales_org in pxi_common.st_company, 
    i_matl_code in pxi_common.st_material, 
    i_cust_code in pxi_common.st_customer
    ) RETURN pxi_common.st_dstrbtn_chnnl;

/*******************************************************************************
  NAME:      DETERMINE_MATL_PLANT_CODE                                    PUBLIC
  PURPOSE:   Using company information and material information find an 
             approperiate plant code to use for the lookup. 

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
  function determine_matl_plant_code (
    i_company_code in pxi_common.st_company,
    i_matl_code in pxi_common.st_material)
    return pxi_common.st_plant_code;

/*******************************************************************************
  NAME:      DETERMINE_TAX_CODE_FROM_REASON                               PUBLIC
  PURPOSE:   This function will determine the tax code to use from the 
             available reason code information.

             * TP Claim Reason Codes
             - Food =  '40', '41', '51'
             - Snack = '42', '43', '53' 
             - Pet =   '44', '45', '55' 

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-08-03 Chris Horn           Created.

*******************************************************************************/
  function determine_tax_code_from_reason(i_reason_code in pxi_common.st_reason_code) 
    return pxi_common.st_tax_code;

end pxi_utils;
/

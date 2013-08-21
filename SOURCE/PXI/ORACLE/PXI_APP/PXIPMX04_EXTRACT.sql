create or replace 
PACKAGE          PXIPMX04_EXTRACT as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX04_EXTRACT
 Owner   : PXI_APP
 Author  : Chris Horn and Mal Chambeyron

 Description
 -----------
 LADS (Outbound) -> Promax PX - Customer Hierarchy - PX Interface 301 (New Zealand)
 
 Date          Author                Description
 ------------  --------------------  -----------
 28/07/2013    Chris Horn            Created.
 20/08/2013    Chris Horn            Cleaned Up Code.
 
*******************************************************************************/

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
  PURPOSE:   This interface creates an extract of customer hierarchy data.
  
             It defaults to all available live promax companies and divisions 
             and just current data as of yesterday.  If null is supplied as 
             the creation date then historial information will be supplied 
             as defined by the business logic.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.
  1.2   2013-08-21 Chris Horn           Cleaned Up.

*******************************************************************************/
   procedure execute(
     i_pmx_company in pxi_common.st_company default null,
     i_pmx_division in pxi_common.st_promax_division default null, 
     i_creation_date in date default sysdate-1);


/*******************************************************************************
  NAME:      GET_CUSTOMER_HIERARCHY
  PURPOSE:   Calculates a customer hierarchy by taking the customer classification 
             and flatterns its output and outputs.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-07-28 Chris Horn           Created.
  1.1   2013-08-01 Chris Horn           Added a check on order block at header level.
  
*******************************************************************************/
  -- Hierarchy Node Record
  type rt_hierarchy_node is record (
      cust_code varchar2(20),
      cust_name varchar2(40),
      sales_org_code varchar2(3),
      parent_cust_code varchar2(10),
      node_level number(2)
    );  
  -- Define the hierarchy table type.
  type tt_hierachy is table of rt_hierarchy_node;
  -- The pipelined table function to return the product hierarchy nodes.
  function get_customer_hierarchy return tt_hierachy pipelined;

end PXIPMX04_EXTRACT;
create or replace 
PACKAGE          PXIPMX02_EXTRACT as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX02_EXTRACT
 Owner   : PXI_APP
 Author  : Chris Horn and Mal Chambeyron

 Description
 -----------
 LADS (Outbound) -> Promax PX - Product Hierarchy - PX Interface 303 (New Zealand)
 
 Date          Author                Description
 ------------  --------------------  -----------
 28/07/2013    Chris Horn            Created.
 
*******************************************************************************/
   procedure execute;

/*******************************************************************************
  NAME:      GET_PRODUCT_HIERARCHY
  PURPOSE:   Calculates a product hierarchy by taking the product classification 
             and flatterns its output and outputs.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-07-28 Chris Horn           Created.
  
*******************************************************************************/
  -- Hierarchy Node Record
  type rt_hierarchy_node is record (
      node_code varchar2(40),
      node_name varchar2(40),
      parent_node_code varchar2(40),
      material_code varchar2(18),
      node_level number(2)
    );  
  -- Define the hierarchy table type.
  type tt_hierachy is table of rt_hierarchy_node;
  -- The pipelined table function to return the product hierarchy nodes.
  function get_product_hierarchy return tt_hierachy pipelined;

end PXIPMX02_EXTRACT;
/
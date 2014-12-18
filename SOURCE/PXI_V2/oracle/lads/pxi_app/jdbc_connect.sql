create or replace package jdbc_connect as
/*******************************************************************************
/* Package Definition
/*******************************************************************************

 System  : PXI
 Package : JDBC_CONNECT
 Owner   : PXI_APP
 Author  : Mal Chambeyron

 Description
 -------------------------------------------------------------------------------
 JDBC Connection Utility Package

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-02-05   Mal Chambeyron         Created
 2014-12-06   Chris Horn             Copied and placed in Lads PXI_APP.

*******************************************************************************/

  type rt_output is record (
    output_record                   varchar2(512)
  );

  type tt_output is table of rt_output;
 
  function jdbc_select( 
    i_connection_name in varchar2,
    i_sql_string in varchar2
  ) return tt_output pipelined;
  
end jdbc_connect;
/
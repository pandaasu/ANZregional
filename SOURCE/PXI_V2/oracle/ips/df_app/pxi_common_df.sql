prompt :: Compile Package [pxi_common_df] :::::::::::::::::::::::::::::::::::::::::::::

create or replace package df_app.pxi_common_df as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : IPS
 Package : PXI_COMMON_DF
 Owner   : DF_APP
 Author  : Mal Chambeyron

 Description
 -----------
 Promax PX Common, expose Demand Financial Global Constants used in the 
 Promax PX packages as Function Constants.
 
 Date        Author                Description
 ----------  --------------------  ---------------------------------------------
 2014-01-09  Mal Chambeyron        Created.
 
*******************************************************************************/

  function fc_dmnd_type_0 return common.st_status; -- Demand Financials Adjustment            
  function fc_dmnd_type_1 return common.st_status; -- Base            
  function fc_dmnd_type_2 return common.st_status; -- Aggregated Market Activities            
  function fc_dmnd_type_3 return common.st_status; -- Lock
  function fc_dmnd_type_4 return common.st_status; -- Reconcile            
  function fc_dmnd_type_5 return common.st_status; -- Auto Adjustment            
  function fc_dmnd_type_6 return common.st_status; -- Override            
  function fc_dmnd_type_7 return common.st_status; -- Market Activities            
  function fc_dmnd_type_8 return common.st_status; -- Data Driven Event            
  function fc_dmnd_type_9 return common.st_status; -- Target Impact            
  function fc_dmnd_type_b return common.st_status; -- The base as supplied from promax.  - Code 10 in demand file.            
  function fc_dmnd_type_p return common.st_status; -- The retained base, for calculation P = B - 1. Delete B where 1 is not null.            
  function fc_dmnd_type_u return common.st_status; -- Promax Uplift. - Code 11 in demand file.            

  function fc_acct_assgnmnt_domestic return common.st_code; -- Domestic Account Assignment Group            

end pxi_common_df;
/

create or replace package body df_app.pxi_common_df as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXI_COMMON_DF';

  function fc_dmnd_type_0 return common.st_status is begin return demand_forecast.gc_dmnd_type_0; end fc_dmnd_type_0; -- Demand Financials Adjustment            
  function fc_dmnd_type_1 return common.st_status is begin return demand_forecast.gc_dmnd_type_1; end fc_dmnd_type_1; -- Base            
  function fc_dmnd_type_2 return common.st_status is begin return demand_forecast.gc_dmnd_type_2; end fc_dmnd_type_2; -- Aggregated Market Activities            
  function fc_dmnd_type_3 return common.st_status is begin return demand_forecast.gc_dmnd_type_3; end fc_dmnd_type_3; -- Lock
  function fc_dmnd_type_4 return common.st_status is begin return demand_forecast.gc_dmnd_type_4; end fc_dmnd_type_4; -- Reconcile            
  function fc_dmnd_type_5 return common.st_status is begin return demand_forecast.gc_dmnd_type_5; end fc_dmnd_type_5; -- Auto Adjustment            
  function fc_dmnd_type_6 return common.st_status is begin return demand_forecast.gc_dmnd_type_6; end fc_dmnd_type_6; -- Override            
  function fc_dmnd_type_7 return common.st_status is begin return demand_forecast.gc_dmnd_type_7; end fc_dmnd_type_7; -- Market Activities            
  function fc_dmnd_type_8 return common.st_status is begin return demand_forecast.gc_dmnd_type_8; end fc_dmnd_type_8; -- Data Driven Event            
  function fc_dmnd_type_9 return common.st_status is begin return demand_forecast.gc_dmnd_type_9; end fc_dmnd_type_9; -- Target Impact            
  function fc_dmnd_type_b return common.st_status is begin return demand_forecast.gc_dmnd_type_b; end fc_dmnd_type_b; -- The base as supplied from promax.  - Code 10 in demand file.            
  function fc_dmnd_type_p return common.st_status is begin return demand_forecast.gc_dmnd_type_p; end fc_dmnd_type_p; -- The retained base, for calculation P = B - 1. Delete B where 1 is not null.            
  function fc_dmnd_type_u return common.st_status is begin return demand_forecast.gc_dmnd_type_u; end fc_dmnd_type_u; -- Promax Uplift. - Code 11 in demand file.            

  function fc_acct_assgnmnt_domestic return common.st_code is begin return demand_forecast.gc_acct_assgnmnt_domestic; end fc_acct_assgnmnt_domestic; -- Domestic Account Assignment Group            

end pxi_common_df;
/

grant execute on df_app.pxi_common_df to lics_app, fflu_app;


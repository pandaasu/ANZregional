
set define off;

create or replace package ods_app.qu5_constants as
  /*****************************************************************************
  ** Package Definition
  ******************************************************************************

    System  : qu5
    Owner   : ods_app
    Package : qu5_constants
    Author  : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    Common Constants Package

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2012-10-26  Mal Chambeyron        Created
    2013-06-24  Mal Chambeyron        Cloned for Wrigley NZ
    2013-07-11  Mal Chambeyron        Add Source Id to Constants
    2014-05-15  Mal Chambeyron        Make into a Template
    2015-03-18  Mal Chambeyron        Add Application Instance Name
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-05-13  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

  -- Public : Functions : Application Instance Specific
  function app_instance_name return varchar2;
  function setting_group return varchar2;

  -- Public : Functions : Status
  function status_started return varchar2;
  function status_loaded return varchar2;
  function status_processed return varchar2;
  function status_error return varchar2;

end qu5_constants;
/

create or replace package body ods_app.qu5_constants as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Public : Functions : Application Instance Specific
  function app_instance_name return varchar2 as begin return 'Quofore - Mars New Zealand'; end app_instance_name;
  function setting_group return varchar2 as begin return 'QU5_MARS_NZ'; end setting_group;

  -- PUBLIC Function : Status STARTED
  function status_started return varchar2 as begin return '*STARTED'; end status_started;
  -- PUBLIC Function : Status LOADED
  function status_loaded return varchar2 as begin return '*LOADED'; end status_loaded;
  -- PUBLIC Function : Status PROCESSED
  function status_processed return varchar2 as begin return '*PROCESSED'; end status_processed;
  -- PUBLIC Function : Status ERROR
  function status_error return varchar2 as begin return '*ERROR'; end status_error;

  -- PUBLIC Function : Setting Group

end qu5_constants;
/

-- Synonyms
create or replace public synonym qu5_constants for ods_app.qu5_constants;

-- Grants
grant execute on ods_app.qu5_constants to public;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/


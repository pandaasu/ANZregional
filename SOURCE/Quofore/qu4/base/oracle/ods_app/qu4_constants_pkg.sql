
set define off;

create or replace package ods_app.qu4_constants as
  /*****************************************************************************
  ** Package Definition
  ******************************************************************************

    System  : qu4
    Owner   : ods_app
    Package : qu4_constants
    Author  : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    Common Constants Package

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2012-10-26  Mal Chambeyron        Created
    2013-06-24  Mal Chambeyron        Cloned for Wrigley NZ
    2013-07-11  Mal Chambeyron        Add Source Id to Constants
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-06-03  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

  -- Public : Functions : Source Id
  function source_id return number;

  -- Public : Functions : Status
  function status_started return varchar2;
  function status_loaded return varchar2;
  function status_processed return varchar2;
  function status_error return varchar2;

  -- Public : Functions : Setting Group
  function setting_group return varchar2;

end qu4_constants;
/

create or replace package body ods_app.qu4_constants as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- PUBLIC Function : Status STARTED
  function source_id return number as begin return 4; end source_id;

  -- PUBLIC Function : Status STARTED
  function status_started return varchar2 as begin return '*STARTED'; end status_started;
  -- PUBLIC Function : Status LOADED
  function status_loaded return varchar2 as begin return '*LOADED'; end status_loaded;
  -- PUBLIC Function : Status PROCESSED
  function status_processed return varchar2 as begin return '*PROCESSED'; end status_processed;
  -- PUBLIC Function : Status ERROR
  function status_error return varchar2 as begin return '*ERROR'; end status_error;

  -- PUBLIC Function : Setting Group
  function setting_group return varchar2 as begin return 'QUOFORE_QU4'; end setting_group;

end qu4_constants;
/

-- Synonyms
create or replace public synonym qu4_constants for ods_app.qu4_constants;

-- Grants
grant execute on ods_app.qu4_constants to public;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/


set define off;

create or replace package ods_app.quo_constants as

  /*****************************************************************************
  ** Package Definition
  ******************************************************************************

   System  : quo
   Package : ods_app.quo_constants
   Owner   : ods_app
   Author  : Mal Chambeyron

   Description
   -----------------------------------------------------------------------------
   Quofore Interface Package .. Common Constants

   YYYY-MM-DD   Author                 Description
   ----------   --------------------   -----------------------------------------
   2012-10-26   Mal Chambeyron         Created

  *****************************************************************************/

  -- Public : Functions : Status
  function status_started return varchar2;
  function status_loaded return varchar2;
  function status_processed return varchar2;
  function status_error return varchar2;

  -- Public : Functions : Setting Group
  function setting_group return varchar2;
  
end quo_constants;
/

create or replace package body ods_app.quo_constants as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);
  
  -- PUBLIC Function : Status STARTED 
  function status_started return varchar2 as begin return '*STARTED'; end status_started;
  -- PUBLIC Function : Status LOADED 
  function status_loaded return varchar2 as begin return '*LOADED'; end status_loaded;
  -- PUBLIC Function : Status PROCESSED 
  function status_processed return varchar2 as begin return '*PROCESSED'; end status_processed;
  -- PUBLIC Function : Status ERROR 
  function status_error return varchar2 as begin return '*ERROR'; end status_error;

  -- PUBLIC Function : Setting Group 
  function setting_group return varchar2 as begin return 'QUOFORE'; end setting_group;
  
end quo_constants;
/

-- Synonyms
create or replace public synonym quo_constants for ods_app.quo_constants;

-- Grants
grant execute on ods_app.quo_constants to public;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/


-- This is the grant script required to be run on LICS_APP schema for the 
-- purpose of the Flat File Loating Utility.
grant execute on lics_pipe to fflu_app;

-- Add synonym for fflu_common for running tasks from LICS
create or replace synonym fflu_common for fflu_app.fflu_common;
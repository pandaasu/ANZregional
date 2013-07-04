-- This script should be run within FFLU_APP to grant execute access to the 
-- approperiate packages for other app schemas to create interfaces.

grant execute on fflu_common to ods_app;
grant execute on fflu_data to ods_app;
grant execute on fflu_utils to ods_app;  

create or replace public synonym fflu_common for fflu_app.fflu_common;
create or replace public synonym fflu_data for fflu_app.fflu_data;
create or replace public synonym fflu_utils for fflu_app.fflu_utils;
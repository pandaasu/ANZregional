-- This script should be run within FFLU_APP to grant execute access to the 
-- approperiate packages for other app schemas to create interfaces.

grant execute on fflu_common to mblt_app;
grant execute on fflu_data to mblt_app;
grant execute on fflu_utils to mblt_app;  

create or replace synonym fflu_common for fflu_app.fflu_common;
create or replace synonym fflu_data for fflu_app.fflu_data;
create or replace synonym fflu_utils for fflu_app.fflu_utils;
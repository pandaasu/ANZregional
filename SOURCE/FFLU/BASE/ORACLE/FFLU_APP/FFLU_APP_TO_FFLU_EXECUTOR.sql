-- Grant script for FFLU_APP to FLLU_EXECUTOR
grant execute on fflu_api to fflu_executor;

grant execute on fflu_common to fflu_executor;

create or replace public synonym fflu_api for fflu_app.fflu_api;

create or replace public synonym fflu_common for fflu_app.fflu_common;

